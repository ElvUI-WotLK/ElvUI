local E, L, V, P, G = unpack(select(2, ...));
local UF = E:GetModule("UnitFrames");

local _G = _G;
local tinsert = table.insert;

local CreateFrame = CreateFrame;

local _, ns = ...;
local ElvUF = ns.oUF;
assert(ElvUF, "ElvUI was unable to locate oUF.");

local ArenaHeader = CreateFrame("Frame", "ArenaHeader", UIParent);

function UF:Construct_ArenaFrames(frame)
	frame.RaisedElementParent = CreateFrame("Frame", nil, frame);
	frame.RaisedElementParent.TextureParent = CreateFrame("Frame", nil, frame.RaisedElementParent)
	frame.RaisedElementParent:SetFrameLevel(frame:GetFrameLevel() + 100);

	frame.Health = self:Construct_HealthBar(frame, true, true, "RIGHT");
	frame.Name = self:Construct_NameText(frame);
	frame.Power = self:Construct_PowerBar(frame, true, true, "LEFT");
	frame.Portrait3D = self:Construct_Portrait(frame, "model");
	frame.Portrait2D = self:Construct_Portrait(frame, "texture");
	frame.Buffs = self:Construct_Buffs(frame);
	frame.Debuffs = self:Construct_Debuffs(frame);
	frame.Castbar = self:Construct_Castbar(frame);
	frame.HealCommBar = UF:Construct_HealComm(frame);
	frame.Trinket = self:Construct_Trinket(frame);
	frame.Range = UF:Construct_Range(frame);
	frame:SetAttribute("type2", "focus");
	frame.TargetGlow = UF:Construct_TargetGlow(frame);
	tinsert(frame.__elements, UF.UpdateTargetGlow);
	frame:RegisterEvent("PLAYER_TARGET_CHANGED", UF.UpdateTargetGlow);
	frame:RegisterEvent("PLAYER_ENTERING_WORLD", UF.UpdateTargetGlow);
	frame:RegisterEvent("GROUP_ROSTER_UPDATE", UF.UpdateTargetGlow);
	frame.customTexts = {};
	frame.InfoPanel = self:Construct_InfoPanel(frame);
	frame.unitframeType = "arena";

	ArenaHeader:Point("BOTTOMRIGHT", E.UIParent, "RIGHT", -105, -165);
	E:CreateMover(ArenaHeader, ArenaHeader:GetName() .. "Mover", L["Arena Frames"], nil, nil, nil, "ALL,ARENA");
	frame.mover = ArenaHeader.mover;
end

function UF:Update_ArenaFrames(frame, db)
	frame.db = db;

	do
		frame.ORIENTATION = db.orientation;
		frame.UNIT_WIDTH = db.width;
		frame.UNIT_HEIGHT = db.infoPanel.enable and db.height + db.infoPanel.height or db.height;

		frame.USE_POWERBAR = db.power.enable;
		frame.POWERBAR_DETACHED = db.power.detachFromFrame;
		frame.USE_INSET_POWERBAR = not frame.POWERBAR_DETACHED and db.power.width == "inset" and frame.USE_POWERBAR;
		frame.USE_MINI_POWERBAR = (not frame.POWERBAR_DETACHED and db.power.width == "spaced" and frame.USE_POWERBAR);
		frame.USE_POWERBAR_OFFSET = db.power.offset ~= 0 and frame.USE_POWERBAR and not frame.POWERBAR_DETACHED;
		frame.POWERBAR_OFFSET = frame.USE_POWERBAR_OFFSET and db.power.offset or 0;

		frame.POWERBAR_HEIGHT = not frame.USE_POWERBAR and 0 or db.power.height;
		frame.POWERBAR_WIDTH = frame.USE_MINI_POWERBAR and (frame.UNIT_WIDTH - (frame.BORDER*2))/2 or (frame.POWERBAR_DETACHED and db.power.detachedWidth or (frame.UNIT_WIDTH - ((frame.BORDER+frame.SPACING)*2)));

		frame.USE_PORTRAIT = db.portrait and db.portrait.enable;
		frame.USE_PORTRAIT_OVERLAY = frame.USE_PORTRAIT;
		frame.PORTRAIT_WIDTH = (frame.USE_PORTRAIT_OVERLAY or not frame.USE_PORTRAIT) and 0 or db.portrait.width;

		frame.CLASSBAR_YOFFSET = 0;

		frame.USE_INFO_PANEL = not frame.USE_MINI_POWERBAR and not frame.USE_POWERBAR_OFFSET and db.infoPanel.enable;
		frame.INFO_PANEL_HEIGHT = frame.USE_INFO_PANEL and db.infoPanel.height or 0;

		frame.BOTTOM_OFFSET = UF:GetHealthBottomOffset(frame);

		frame.VARIABLES_SET = true;
	end

	frame.colors = ElvUF.colors;
	frame.Portrait = frame.Portrait or (db.portrait.style == "2D" and frame.Portrait2D or frame.Portrait3D);
	frame:RegisterForClicks(self.db.targetOnMouseDown and "AnyDown" or "AnyUp");
	frame:Size(frame.UNIT_WIDTH, frame.UNIT_HEIGHT);

	UF:Configure_InfoPanel(frame);

	UF:Configure_HealthBar(frame);

	UF:UpdateNameSettings(frame);

	UF:Configure_Power(frame);

	UF:Configure_Portrait(frame);

	UF:Configure_TargetGlow(frame);

	UF:EnableDisable_Auras(frame);
	UF:Configure_Auras(frame, "Buffs");
	UF:Configure_Auras(frame, "Debuffs");

	UF:Configure_Castbar(frame);

	UF:Configure_Trinket(frame);

	UF:Configure_Range(frame);

	UF:Configure_HealComm(frame);

	UF:Configure_CustomTexts(frame);

	frame:ClearAllPoints();
	if(frame.index == 1) then
		if(db.growthDirection == "UP") then
			frame:Point("BOTTOMRIGHT", ArenaHeaderMover, "BOTTOMRIGHT");
		elseif(db.growthDirection == "RIGHT") then
			frame:Point("LEFT", ArenaHeaderMover, "LEFT");
		elseif(db.growthDirection == "LEFT") then
			frame:Point("RIGHT", ArenaHeaderMover, "RIGHT");
		else
			frame:Point("TOPRIGHT", ArenaHeaderMover, "TOPRIGHT");
		end
	else
		if(db.growthDirection == "UP") then
			frame:Point("BOTTOMRIGHT", _G["ElvUF_Arena"..frame.index-1], "TOPRIGHT", 0, db.spacing);
		elseif(db.growthDirection == "RIGHT") then
			frame:Point("LEFT", _G["ElvUF_Arena"..frame.index-1], "RIGHT", db.spacing, 0);
		elseif(db.growthDirection == "LEFT") then
			frame:Point("RIGHT", _G["ElvUF_Arena"..frame.index-1], "LEFT", -db.spacing, 0);
		else
			frame:Point("TOPRIGHT", _G["ElvUF_Arena"..frame.index-1], "BOTTOMRIGHT", 0, -db.spacing);
		end
	end

	if(db.growthDirection == "UP" or db.growthDirection == "DOWN") then
		ArenaHeader:Width(frame.UNIT_WIDTH);
		ArenaHeader:Height(frame.UNIT_HEIGHT + ((frame.UNIT_HEIGHT + db.spacing) * 4));
	elseif(db.growthDirection == "LEFT" or db.growthDirection == "RIGHT") then
		ArenaHeader:Width(frame.UNIT_WIDTH + ((frame.UNIT_WIDTH + db.spacing) * 4));
		ArenaHeader:Height(frame.UNIT_HEIGHT);
	end

	frame:UpdateAllElements("ElvUI_UpdateAllElements");
end

UF["unitgroupstoload"]["arena"] = {5};