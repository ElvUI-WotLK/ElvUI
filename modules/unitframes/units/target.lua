local E, L, V, P, G = unpack(select(2, ...));
local UF = E:GetModule("UnitFrames");

local _G = _G;
local tinsert = table.insert;

local IsAddOnLoaded = IsAddOnLoaded;
local MAX_COMBO_POINTS = MAX_COMBO_POINTS;

local _, ns = ...;
local ElvUF = ns.oUF;
assert(ElvUF, "ElvUI was unable to locate oUF.");

function UF:Construct_TargetFrame(frame)
	frame.Health = self:Construct_HealthBar(frame, true, true, "RIGHT");
	frame.Health.frequentUpdates = true;
	frame.Power = self:Construct_PowerBar(frame, true, true, "LEFT");
	frame.Power.frequentUpdates = true;
	frame.Name = self:Construct_NameText(frame);
	frame.Portrait3D = self:Construct_Portrait(frame, "model");
	frame.Portrait2D = self:Construct_Portrait(frame, "texture");
	frame.Buffs = self:Construct_Buffs(frame);
	frame.Debuffs = self:Construct_Debuffs(frame);
	frame.Threat = self:Construct_Threat(frame);
	frame.Castbar = self:Construct_Castbar(frame, L["Target Castbar"]);
	frame.Castbar.SafeZone = nil;
	frame.Castbar.LatencyTexture:Hide();
	frame.RaidIcon = UF:Construct_RaidIcon(frame);
	frame.CPoints = self:Construct_Combobar(frame);
	frame.HealCommBar = self:Construct_HealComm(frame);
	frame.DebuffHighlight = self:Construct_DebuffHighlight(frame);
	frame.GPS = self:Construct_GPS(frame);
	frame.InfoPanel = self:Construct_InfoPanel(frame);
	frame.AuraBars = self:Construct_AuraBarHeader(frame);
	frame.Range = UF:Construct_Range(frame);
	frame.PvP = UF:Construct_PvPIcon(frame);
	frame.customTexts = {};

	frame:Point("BOTTOMRIGHT", E.UIParent, "BOTTOM", 413, 68);
	E:CreateMover(frame, frame:GetName() .. "Mover", L["Target Frame"], nil, nil, nil, "ALL,SOLO");
	frame.unitframeType = "target";
end

function UF:Update_TargetFrame(frame, db)
	frame.db = db;

	do
		frame.ORIENTATION = db.orientation;
		frame.UNIT_WIDTH = db.width;
		frame.UNIT_HEIGHT = db.infoPanel.enable and (db.height + db.infoPanel.height) or db.height;

		frame.USE_POWERBAR = db.power.enable;
		frame.POWERBAR_DETACHED = db.power.detachFromFrame;
		frame.USE_INSET_POWERBAR = not frame.POWERBAR_DETACHED and db.power.width == "inset" and frame.USE_POWERBAR;
		frame.USE_MINI_POWERBAR = (not frame.POWERBAR_DETACHED and db.power.width == "spaced" and frame.USE_POWERBAR);
		frame.USE_POWERBAR_OFFSET = db.power.offset ~= 0 and frame.USE_POWERBAR and not frame.POWERBAR_DETACHED;
		frame.POWERBAR_OFFSET = frame.USE_POWERBAR_OFFSET and db.power.offset or 0;

		frame.POWERBAR_HEIGHT = not frame.USE_POWERBAR and 0 or db.power.height;
		frame.POWERBAR_WIDTH = frame.USE_MINI_POWERBAR and (frame.UNIT_WIDTH - (frame.BORDER*2))/2 or (frame.POWERBAR_DETACHED and db.power.detachedWidth or (frame.UNIT_WIDTH - ((frame.BORDER+frame.SPACING)*2)));

		frame.USE_PORTRAIT = db.portrait and db.portrait.enable;
		frame.USE_PORTRAIT_OVERLAY = frame.USE_PORTRAIT and (db.portrait.overlay or frame.ORIENTATION == "MIDDLE");
		frame.PORTRAIT_WIDTH = (frame.USE_PORTRAIT_OVERLAY or not frame.USE_PORTRAIT) and 0 or db.portrait.width;

		frame.CAN_HAVE_CLASSBAR = db.combobar.enable;
		frame.MAX_CLASS_BAR = MAX_COMBO_POINTS;
		frame.USE_CLASSBAR = db.combobar.enable;
		frame.CLASSBAR_SHOWN = frame.CAN_HAVE_CLASSBAR and frame.CPoints:IsShown();
		frame.CLASSBAR_DETACHED = db.combobar.detachFromFrame;
		frame.USE_MINI_CLASSBAR = db.combobar.fill == "spaced" and frame.USE_CLASSBAR;
		frame.CLASSBAR_HEIGHT = frame.USE_CLASSBAR and db.combobar.height or 0;
		frame.CLASSBAR_WIDTH = frame.UNIT_WIDTH - ((frame.BORDER+frame.SPACING)*2) - frame.PORTRAIT_WIDTH - frame.POWERBAR_OFFSET;
		frame.CLASSBAR_YOFFSET = (not frame.USE_CLASSBAR or not frame.CLASSBAR_SHOWN or frame.CLASSBAR_DETACHED) and 0 or (frame.USE_MINI_CLASSBAR and (frame.SPACING+(frame.CLASSBAR_HEIGHT/2)) or (frame.CLASSBAR_HEIGHT + frame.SPACING));

		frame.USE_INFO_PANEL = not frame.USE_MINI_POWERBAR and not frame.USE_POWERBAR_OFFSET and db.infoPanel.enable;
		frame.INFO_PANEL_HEIGHT = frame.USE_INFO_PANEL and db.infoPanel.height or 0;

		frame.BOTTOM_OFFSET = UF:GetHealthBottomOffset(frame);

		frame.VARIABLES_SET = true;
	end

	frame.colors = ElvUF.colors;
	frame.Portrait = frame.Portrait or (db.portrait.style == "2D" and frame.Portrait2D or frame.Portrait3D);
	frame:RegisterForClicks(self.db.targetOnMouseDown and "AnyDown" or "AnyUp");
	frame:Size(frame.UNIT_WIDTH, frame.UNIT_HEIGHT);
	_G[frame:GetName() .. "Mover"]:Size(frame:GetSize());

	if(not IsAddOnLoaded("Clique")) then
		if(db.middleClickFocus) then
			frame:SetAttribute("type3", "focus")
		elseif(frame:GetAttribute("type3") == "focus") then
			frame:SetAttribute("type3", nil);
		end
	end

	UF:Configure_InfoPanel(frame);

	UF:Configure_HealthBar(frame);

	UF:UpdateNameSettings(frame);

	UF:Configure_Power(frame);

	UF:Configure_Portrait(frame);

	UF:Configure_Threat(frame);

	UF:EnableDisable_Auras(frame);
	UF:Configure_Auras(frame, "Buffs");
	UF:Configure_Auras(frame, "Debuffs");

	UF:Configure_Castbar(frame);

	UF:Configure_ComboPoints(frame);

	UF:Configure_DebuffHighlight(frame);

	UF:Configure_HealComm(frame);

	UF:Configure_GPS(frame);

	UF:Configure_RaidIcon(frame);

	UF:Configure_AuraBars(frame);

	UF:Configure_Range(frame);

	UF:Configure_PVPIcon(frame)

	UF:Configure_CustomTexts(frame);

	E:SetMoverSnapOffset(frame:GetName() .. "Mover", -(12 + db.castbar.height));
	frame:UpdateAllElements("ElvUI_UpdateAllElements");
end

tinsert(UF["unitstoload"], "target");