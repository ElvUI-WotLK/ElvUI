local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:GetModule("WorldMap")

--Lua functions
local find = string.find
--WoW API / Variables
local CreateFrame = CreateFrame
local GetCVarBool = GetCVarBool
local GetCursorPosition = GetCursorPosition
local GetPlayerMapPosition = GetPlayerMapPosition
local InCombatLockdown = InCombatLockdown
local PLAYER = PLAYER
local MOUSE_LABEL = MOUSE_LABEL
local WORLDMAP_POI_FRAMELEVEL = WORLDMAP_POI_FRAMELEVEL

local INVERTED_POINTS = {
	["TOPLEFT"] = "BOTTOMLEFT",
	["TOPRIGHT"] = "BOTTOMRIGHT",
	["BOTTOMLEFT"] = "TOPLEFT",
	["BOTTOMRIGHT"] = "TOPRIGHT",
	["TOP"] = "BOTTOM",
	["BOTTOM"] = "TOP"
}

function M:PLAYER_REGEN_ENABLED()
	WorldMapFrameSizeUpButton:Enable()
	WorldMapFrameSizeDownButton:Enable()

	WorldMapQuestShowObjectives:Enable()

	WorldMapBlobFrame:SetParent(WorldMapFrame)
	WorldMapBlobFrame:ClearAllPoints()
	WorldMapBlobFrame:SetPoint("TOPLEFT", WorldMapDetailFrame)
	WorldMapBlobFrame:SetScale(self.blobNewScale or WORLDMAP_SETTINGS.size)
	WorldMapBlobFrame.Hide = nil
	WorldMapBlobFrame.Show = nil

	if self.blobWasVisible then
		WorldMapBlobFrame:Show()
	end

	if WorldMapQuestScrollChildFrame.selected then
		WorldMapBlobFrame:DrawQuestBlob(WorldMapQuestScrollChildFrame.selected.questId, false)
	end

	if self.blobWasVisible then
		WorldMapBlobFrame_CalculateHitTranslations()

		if WorldMapQuestScrollChildFrame.selected and not WorldMapQuestScrollChildFrame.selected.completed then
			WorldMapBlobFrame:DrawQuestBlob(WorldMapQuestScrollChildFrame.selected.questId, true)
		end
	end
end

function M:PLAYER_REGEN_DISABLED()
	WorldMapFrameSizeUpButton:Disable()
	WorldMapFrameSizeDownButton:Disable()

	if not GetCVarBool("miniWorldMap") then
		WorldMapQuestShowObjectives:Disable()
	end

	self.blobWasVisible = WorldMapFrame:IsShown() and WorldMapBlobFrame:IsShown()

	WorldMapBlobFrame:SetParent(nil)
	WorldMapBlobFrame:ClearAllPoints()
	WorldMapBlobFrame:SetPoint("TOP", UIParent, "BOTTOM")
	WorldMapBlobFrame:Hide()
	WorldMapBlobFrame.Hide = function() M.blobWasVisible = nil end
	WorldMapBlobFrame.Show = function() M.blobWasVisible = true end
	self.blobNewScale = nil
end

local t = 0
local function UpdateCoords(self, elapsed)
	t = t + elapsed
	if t < 0.03333 then return end
	t = 0

	local x, y = GetPlayerMapPosition("player")

	if self.playerCoords.x ~= x and self.playerCoords.y ~= y then
		local adjustedX, adjustedY

		if x then
			adjustedX = E:Round(100 * x, 2)
			adjustedY = E:Round(100 * y, 2)
		else
			adjustedX = 0
			adjustedY = 0
		end

		if adjustedX ~= 0 and adjustedY ~= 0 then
			self.playerCoords.x = x
			self.playerCoords.y = y
			self.playerCoords:SetFormattedText("%s:   %.2f, %.2f", PLAYER, adjustedX, adjustedY)
		else
			self.playerCoords.x = nil
			self.playerCoords.y = nil
			self.playerCoords:SetFormattedText("%s:   %s", PLAYER, "N/A")
		end
	end

	if WorldMapDetailFrame:IsMouseOver() then
		local curX, curY = GetCursorPosition()

		if self.mouseCoords.x ~= curX and self.mouseCoords.y ~= curY then
			local scale = WorldMapDetailFrame:GetEffectiveScale()
			local width = WorldMapDetailFrame:GetWidth()
			local height = WorldMapDetailFrame:GetHeight()
			local centerX, centerY = WorldMapDetailFrame:GetCenter()
			local adjustedX = (curX / scale - (centerX - (width / 2))) / width
			local adjustedY = (centerY + (height / 2) - curY / scale) / height

			if adjustedX >= 0 and adjustedY >= 0 and adjustedX <= 1 and adjustedY <= 1 then
				adjustedX = E:Round(100 * adjustedX, 2)
				adjustedY = E:Round(100 * adjustedY, 2)

				self.mouseCoords.x = curX
				self.mouseCoords.y = curY
				self.mouseCoords:SetFormattedText("%s:  %.2f, %.2f", MOUSE_LABEL, adjustedX, adjustedY)
			else
				self.mouseCoords.x = nil
				self.mouseCoords.y = nil
				self.mouseCoords:SetText("")
			end
		end
	elseif self.mouseCoords.x then
		self.mouseCoords.x = nil
		self.mouseCoords.y = nil
		self.mouseCoords:SetText("")
	end
end

function M:PositionCoords()
	if not self.coordsHolder then return end

	local db = E.global.general.WorldMapCoordinates
	local position = db.position
	local xOffset = db.xOffset
	local yOffset = db.yOffset

	local x, y = 5, 5
	if find(position, "RIGHT") then x = -5 end
	if find(position, "TOP") then y = -5 end

	self.coordsHolder.playerCoords:ClearAllPoints()
	self.coordsHolder.playerCoords:Point(position, WorldMapDetailFrame, position, x + xOffset, y + yOffset)

	self.coordsHolder.mouseCoords:ClearAllPoints()
	self.coordsHolder.mouseCoords:Point(position, self.coordsHolder.playerCoords, INVERTED_POINTS[position], 0, y)
end

function M:ToggleMapFramerate()
	if InCombatLockdown() then return end

	if WORLDMAP_SETTINGS.size == WORLDMAP_FULLMAP_SIZE or WORLDMAP_SETTINGS.size == WORLDMAP_QUESTLIST_SIZE then
		WorldMapFrame:SetAttribute("UIPanelLayout-area", "center")
		WorldMapFrame:SetAttribute("UIPanelLayout-allowOtherPanels", true)

		WorldMapFrame:SetScale(1)
		WorldMapFrame:EnableKeyboard(false)
		WorldMapFrame:EnableMouse(false)
	end
end

function M:Initialize()
	if not E.private.worldmap.enable then return end

	if E.global.general.WorldMapCoordinates.enable then
		local coordsHolder = CreateFrame("Frame", "ElvUI_CoordsHolder", WorldMapFrame)
		coordsHolder:SetFrameLevel(WORLDMAP_POI_FRAMELEVEL + 100)
		coordsHolder:SetFrameStrata(WorldMapDetailFrame:GetFrameStrata())

		coordsHolder.playerCoords = coordsHolder:CreateFontString(nil, "OVERLAY")
		coordsHolder.playerCoords:SetTextColor(1, 1 ,0)
		coordsHolder.playerCoords:SetFontObject(NumberFontNormal)
		coordsHolder.playerCoords:SetPoint("BOTTOMLEFT", WorldMapDetailFrame, "BOTTOMLEFT", 5, 5)
		coordsHolder.playerCoords:SetText(PLAYER..":   0, 0")

		coordsHolder.mouseCoords = coordsHolder:CreateFontString(nil, "OVERLAY")
		coordsHolder.mouseCoords:SetTextColor(1, 1 ,0)
		coordsHolder.mouseCoords:SetFontObject(NumberFontNormal)
		coordsHolder.mouseCoords:SetPoint("BOTTOMLEFT", coordsHolder.playerCoords, "TOPLEFT", 0, 5)
		coordsHolder.mouseCoords:SetText(MOUSE_LABEL..":   0, 0")

		coordsHolder:SetScript("OnUpdate", UpdateCoords)

		self.coordsHolder = coordsHolder
		self:PositionCoords()
	end

	if E.global.general.smallerWorldMap or (E.private.skins.blizzard.enable and E.private.skins.blizzard.worldmap) then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		self:RegisterEvent("PLAYER_REGEN_DISABLED")
	end

	if E.global.general.smallerWorldMap then
		BlackoutWorld:SetTexture(nil)

		WorldMapFrame:SetParent(UIParent)
		WorldMapFrame.SetParent = E.noop

		if not GetCVarBool("miniWorldMap") then
			ShowUIPanel(WorldMapFrame)
			self:ToggleMapFramerate()
			HideUIPanel(WorldMapFrame)
		end

		M:SecureHook("ToggleMapFramerate")

		hooksecurefunc(WorldMapDetailFrame, "SetScale", function(_, scale)
			self.blobNewScale = scale
		end)

		DropDownList1:HookScript("OnShow", function()
			if DropDownList1:GetScale() ~= UIParent:GetScale() then
				DropDownList1:SetScale(UIParent:GetScale())
			end
		end)

		self:RawHook("WorldMapQuestPOI_OnLeave", function()
			WorldMapPOIFrame.allowBlobTooltip = true
			WorldMapTooltip:Hide()
		end, true)

	--	WorldMapTooltip:SetFrameLevel(WORLDMAP_POI_FRAMELEVEL + 110)
	--	WorldMapCompareTooltip1:SetFrameLevel(WORLDMAP_POI_FRAMELEVEL + 110)
	--	WorldMapCompareTooltip2:SetFrameLevel(WORLDMAP_POI_FRAMELEVEL + 110)
	end

	self.Initialized = true
end

local function InitializeCallback()
	M:Initialize()
end

E:RegisterInitialModule(M:GetName(), InitializeCallback)