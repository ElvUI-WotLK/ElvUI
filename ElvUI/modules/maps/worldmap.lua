local E, L, V, P, G = unpack(select(2, ...));
local M = E:NewModule("WorldMap", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0");
E.WorldMap = M;

local find, format = string.find, string.format;

local CreateFrame = CreateFrame;
local InCombatLockdown = InCombatLockdown;
local GetPlayerMapPosition = GetPlayerMapPosition;
local GetCursorPosition = GetCursorPosition;
local PLAYER = PLAYER;
local MOUSE_LABEL = MOUSE_LABEL;
local WORLDMAP_POI_FRAMELEVEL = WORLDMAP_POI_FRAMELEVEL;

local INVERTED_POINTS = {
	["TOPLEFT"] = "BOTTOMLEFT",
	["TOPRIGHT"] = "BOTTOMRIGHT",
	["BOTTOMLEFT"] = "TOPLEFT",
	["BOTTOMRIGHT"] = "TOPRIGHT",
	["TOP"] = "BOTTOM",
	["BOTTOM"] = "TOP"
};

function SetUIPanelAttribute(frame, name, value)
	local info = UIPanelWindows[frame:GetName()];
	if(not info) then
		return;
	end

	if(not frame:GetAttribute("UIPanelLayout-defined")) then
		frame:SetAttribute("UIPanelLayout-defined", true);
		for name,value in pairs(info) do
			frame:SetAttribute("UIPanelLayout-"..name, value);
		end
	end

	frame:SetAttribute("UIPanelLayout-"..name, value);
end

function M:SetLargeWorldMap()
	if(InCombatLockdown()) then return; end

	WorldMapFrame:SetParent(E.UIParent);
	WorldMapFrame:EnableKeyboard(false);
	WorldMapFrame:SetScale(1);
	WorldMapFrame:EnableMouse(false);

	if(WorldMapFrame:GetAttribute("UIPanelLayout-area") ~= "center") then
		SetUIPanelAttribute(WorldMapFrame, "area", "center");
	end

	if(WorldMapFrame:GetAttribute("UIPanelLayout-allowOtherPanels") ~= true) then
		SetUIPanelAttribute(WorldMapFrame, "allowOtherPanels", true);
	end

	WorldMapFrameSizeUpButton:Hide();
	WorldMapFrameSizeDownButton:Show();
end

function M:SetSmallWorldMap()
	WorldMapFrameSizeUpButton:Show();
	WorldMapFrameSizeDownButton:Hide();
end

function M:PLAYER_REGEN_ENABLED()
	WorldMapFrameSizeUpButton:Enable();
	WorldMapQuestShowObjectives:Enable();

	WorldMapBlobFrame:SetParent(WorldMapFrame);
	WorldMapBlobFrame:ClearAllPoints();
	WorldMapBlobFrame:SetPoint("TOPLEFT", WorldMapDetailFrame);
	WorldMapBlobFrame.Hide = nil;
	WorldMapBlobFrame.Show = nil;

	if (self.blobWasVisible) then
		WorldMapBlobFrame:Show();
	end

	if (WorldMapQuestScrollChildFrame.selected) then
		WorldMapBlobFrame:DrawQuestBlob(WorldMapQuestScrollChildFrame.selected.questId, false);
	end

	if (self.blobWasVisible) then
		WorldMapBlobFrame_CalculateHitTranslations();

		if (WorldMapQuestScrollChildFrame.selected and not WorldMapQuestScrollChildFrame.selected.completed) then
			WorldMapBlobFrame:DrawQuestBlob(WorldMapQuestScrollChildFrame.selected.questId, true);
		end
	end
end

function M:PLAYER_REGEN_DISABLED()
	WorldMapFrameSizeUpButton:Disable();

	if(not GetCVarBool("miniWorldMap")) then
		WorldMapQuestShowObjectives:Disable();
	end

	self.blobWasVisible = WorldMapFrame:IsShown() and WorldMapBlobFrame:IsShown();

	WorldMapBlobFrame:SetParent(nil);
	WorldMapBlobFrame:ClearAllPoints();
	WorldMapBlobFrame:SetPoint("TOP", UIParent, "BOTTOM");
	WorldMapBlobFrame:Hide();
	WorldMapBlobFrame.Hide = function() M.blobWasVisible = nil end;
	WorldMapBlobFrame.Show = function() M.blobWasVisible = true end;
end

function M:UpdateCoords()
	if(not WorldMapFrame:IsShown()) then return; end
	local x, y = GetPlayerMapPosition("player");
	x = x and E:Round(100 * x, 2) or 0
	y = y and E:Round(100 * y, 2) or 0

	if(x ~= 0 and y ~= 0) then
		CoordsHolder.playerCoords:SetText(PLAYER .. ":   " .. format("%.2f, %.2f", x, y));
	else
		CoordsHolder.playerCoords:SetText("");
	end

	local scale = WorldMapDetailFrame:GetEffectiveScale();
	local width = WorldMapDetailFrame:GetWidth();
	local height = WorldMapDetailFrame:GetHeight();
	local centerX, centerY = WorldMapDetailFrame:GetCenter();
	local x, y = GetCursorPosition();
	local adjustedX = (x / scale - (centerX - (width / 2))) / width;
	local adjustedY = (centerY + (height / 2) - y / scale) / height;

	if(adjustedX >= 0 and adjustedY >= 0 and adjustedX <= 1 and adjustedY <= 1) then
		adjustedX = E:Round(100 * adjustedX, 2);
		adjustedY = E:Round(100 * adjustedY, 2);
		CoordsHolder.mouseCoords:SetText(MOUSE_LABEL .. ":  " .. format("%.2f, %.2f", adjustedX, adjustedY));
	else
		CoordsHolder.mouseCoords:SetText("");
	end
end

function M:PositionCoords()
	local db = E.global.general.WorldMapCoordinates;
	local position = db.position;
	local xOffset = db.xOffset;
	local yOffset = db.yOffset;

	local x, y = 5, 5;
	if(find(position, "RIGHT")) then x = -5; end
	if(find(position, "TOP")) then y = -5; end

	CoordsHolder.playerCoords:ClearAllPoints();
	CoordsHolder.playerCoords:Point(position, WorldMapDetailFrame, position, x + xOffset, y + yOffset);
	CoordsHolder.mouseCoords:ClearAllPoints();
	CoordsHolder.mouseCoords:Point(position, CoordsHolder.playerCoords, INVERTED_POINTS[position], 0, y);
end

function M:Initialize()
	if(E.global.general.WorldMapCoordinates.enable) then
		local coordsHolder = CreateFrame("Frame", "CoordsHolder", WorldMapFrame);
		coordsHolder:SetFrameLevel(WORLDMAP_POI_FRAMELEVEL + 100);
		coordsHolder:SetFrameStrata(WorldMapDetailFrame:GetFrameStrata());
		coordsHolder.playerCoords = coordsHolder:CreateFontString(nil, "OVERLAY");
		coordsHolder.mouseCoords = coordsHolder:CreateFontString(nil, "OVERLAY");
		coordsHolder.playerCoords:SetTextColor(1, 1 ,0);
		coordsHolder.mouseCoords:SetTextColor(1, 1 ,0);
		coordsHolder.playerCoords:SetFontObject(NumberFontNormal);
		coordsHolder.mouseCoords:SetFontObject(NumberFontNormal);
		coordsHolder.playerCoords:SetPoint("BOTTOMLEFT", WorldMapDetailFrame, "BOTTOMLEFT", 5, 5);
		coordsHolder.playerCoords:SetText(PLAYER .. ":   0, 0");
		coordsHolder.mouseCoords:SetPoint("BOTTOMLEFT", coordsHolder.playerCoords, "TOPLEFT", 0, 5);
		coordsHolder.mouseCoords:SetText(MOUSE_LABEL .. ":   0, 0");

		coordsHolder:SetScript("OnUpdate", self.UpdateCoords);

		self:PositionCoords();
	end

	if(E.global.general.smallerWorldMap) then
		BlackoutWorld:SetTexture(nil);
		self:SecureHook("WorldMap_ToggleSizeDown", "SetSmallWorldMap");
		self:SecureHook("WorldMap_ToggleSizeUp", "SetLargeWorldMap");
		self:RegisterEvent("PLAYER_REGEN_ENABLED");
		self:RegisterEvent("PLAYER_REGEN_DISABLED");

		if(WORLDMAP_SETTINGS.size == WORLDMAP_FULLMAP_SIZE or WORLDMAP_SETTINGS.size == WORLDMAP_QUESTLIST_SIZE) then
			SetCVar("miniWorldMap", 1);
			WorldMap_ToggleSizeDown();
		elseif(WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE) then
			SetCVar("miniWorldMap", 0);
			self:SetSmallWorldMap();
		end

		DropDownList1:HookScript("OnShow", function()
			if(DropDownList1:GetScale() ~= UIParent:GetScale()) then
				DropDownList1:SetScale(UIParent:GetScale());
			end
		end);

		WorldMapTooltip:SetFrameLevel(WORLDMAP_POI_FRAMELEVEL + 110);
		WorldMapCompareTooltip1:SetFrameLevel(WORLDMAP_POI_FRAMELEVEL + 110);
		WorldMapCompareTooltip2:SetFrameLevel(WORLDMAP_POI_FRAMELEVEL + 110);
	end
end

local function InitializeCallback()
	M:Initialize()
end

E:RegisterInitialModule(M:GetName(), InitializeCallback)