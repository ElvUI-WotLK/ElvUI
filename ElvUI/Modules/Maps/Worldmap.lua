local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:GetModule("WorldMap")
local S = E:GetModule("Skins")

--Lua functions
local find = string.find
--WoW API / Variables
local CreateFrame = CreateFrame
local GetCVarBool = GetCVarBool
local GetCursorPosition = GetCursorPosition
local GetPlayerMapPosition = GetPlayerMapPosition

local MOUSE_LABEL = MOUSE_LABEL
local PLAYER = PLAYER
local WORLDMAP_SETTINGS = WORLDMAP_SETTINGS

local INVERTED_POINTS = {
	["TOPLEFT"] = "BOTTOMLEFT",
	["TOPRIGHT"] = "BOTTOMRIGHT",
	["BOTTOMLEFT"] = "TOPLEFT",
	["BOTTOMRIGHT"] = "TOPRIGHT",
	["TOP"] = "BOTTOM",
	["BOTTOM"] = "TOP"
}

local function BloobFrameHide()
	M.blobWasVisible = nil
end

local function BloobFrameShow()
	M.blobWasVisible = true
end

function M:PLAYER_REGEN_ENABLED()
	WorldMapBlobFrame.SetFrameLevel = nil
	WorldMapBlobFrame.SetScale = nil
	WorldMapBlobFrame.Hide = nil
	WorldMapBlobFrame.Show = nil

	local frameLevel = WorldMapDetailFrame:GetFrameLevel() + 1

	WorldMapBlobFrame:SetParent(WorldMapFrame)
	WorldMapBlobFrame:ClearAllPoints()
	WorldMapBlobFrame:SetPoint("TOPLEFT", WorldMapDetailFrame)
	WorldMapBlobFrame:SetScale(self.blobNewScale or WORLDMAP_SETTINGS.size)
	WorldMapBlobFrame:SetFrameLevel(frameLevel)
	WorldMapBlobFrame:SetFrameLevel(frameLevel)	-- called twice to set frame level above the default limit (256)

	if self.blobWasVisible then
		WorldMapBlobFrame:Show()
	end

	if WORLDMAP_SETTINGS.selectedQuest then
		WorldMapBlobFrame:DrawQuestBlob(WORLDMAP_SETTINGS.selectedQuest.questId, false)
	end

	if self.blobWasVisible then
		WorldMapBlobFrame_CalculateHitTranslations()

		if WORLDMAP_SETTINGS.selectedQuest and not WORLDMAP_SETTINGS.selectedQuest.completed then
			WorldMapBlobFrame:DrawQuestBlob(WORLDMAP_SETTINGS.selectedQuest.questId, true)
		end
	end
end

function M:PLAYER_REGEN_DISABLED()
	self.blobWasVisible = WorldMapFrame:IsShown() and WorldMapBlobFrame:IsShown()

	WorldMapBlobFrame:SetParent(nil)
	WorldMapBlobFrame:ClearAllPoints()
	WorldMapBlobFrame:SetPoint("TOP", UIParent, "BOTTOM")
	WorldMapBlobFrame:Hide()
	WorldMapBlobFrame.Hide = BloobFrameHide
	WorldMapBlobFrame.Show = BloobFrameShow
	WorldMapBlobFrame.SetFrameLevel = E.noop
	WorldMapBlobFrame.SetScale = E.noop

	self.blobNewScale = nil
end

local t = 0
local function UpdateCoords(self, elapsed)
	t = t + elapsed
	if t < 0.03333 then return end
	t = 0

	local x, y = GetPlayerMapPosition("player")

	if self.playerCoords.x ~= x or self.playerCoords.y ~= y then
		if x ~= 0 or y ~= 0 then
			self.playerCoords.x = x
			self.playerCoords.y = y
			self.playerCoords:SetFormattedText("%s:   %.2f, %.2f", PLAYER, x * 100, y * 100)
		else
			self.playerCoords.x = nil
			self.playerCoords.y = nil
			self.playerCoords:SetFormattedText("%s:   %s", PLAYER, "N/A")
		end
	end

	if WorldMapDetailFrame:IsMouseOver() then
		local curX, curY = GetCursorPosition()

		if self.mouseCoords.x ~= curX or self.mouseCoords.y ~= curY then
			local scale = WorldMapDetailFrame:GetEffectiveScale()
			local width, height = WorldMapDetailFrame:GetSize()
			local centerX, centerY = WorldMapDetailFrame:GetCenter()
			local adjustedX = (curX / scale - (centerX - (width * 0.5))) / width
			local adjustedY = (centerY + (height * 0.5) - curY / scale) / height

			if adjustedX >= 0 and adjustedY >= 0 and adjustedX <= 1 and adjustedY <= 1 then
				self.mouseCoords.x = curX
				self.mouseCoords.y = curY
				self.mouseCoords:SetFormattedText("%s:  %.2f, %.2f", MOUSE_LABEL, adjustedX * 100, adjustedY * 100)
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
	if WORLDMAP_SETTINGS.size == WORLDMAP_FULLMAP_SIZE or WORLDMAP_SETTINGS.size == WORLDMAP_QUESTLIST_SIZE then
		WorldMapFrame:SetAttribute("UIPanelLayout-area", "center")
		WorldMapFrame:SetAttribute("UIPanelLayout-allowOtherPanels", true)

		WorldMapFrame:SetScale(1)
		WorldMapFrame:EnableKeyboard(false)
		WorldMapFrame:EnableMouse(false)
	else
		S:SetUIPanelWindowInfo(WorldMapFrame, "width", 591)
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

		if GetCVarBool("miniWorldMap") then
			S:SetUIPanelWindowInfo(WorldMapFrame, "width", 591)
		else
			ShowUIPanel(WorldMapFrame)
			self:ToggleMapFramerate()
			HideUIPanel(WorldMapFrame)
		end

		M:SecureHook("ToggleMapFramerate")

		hooksecurefunc(WorldMapDetailFrame, "SetScale", function(_, scale)
			self.blobNewScale = scale
		end)

		DropDownList1:HookScript("OnShow", function(self)
			if self:GetScale() ~= UIParent:GetScale() then
				self:SetScale(UIParent:GetScale())
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