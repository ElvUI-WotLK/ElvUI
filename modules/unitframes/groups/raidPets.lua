local E, L, V, P, G = unpack(select(2, ...));
local UF = E:GetModule("UnitFrames");

local tinsert = table.insert;

local CreateFrame = CreateFrame;
local IsInInstance = IsInInstance;
local InCombatLockdown = InCombatLockdown;
local UnregisterStateDriver = UnregisterStateDriver;
local RegisterStateDriver = RegisterStateDriver;

local _, ns = ...;
local ElvUF = ns.oUF;
assert(ElvUF, "ElvUI was unable to locate oUF.");

function UF:Construct_RaidpetFrames(unitGroup)
	self:SetScript("OnEnter", UnitFrame_OnEnter);
	self:SetScript("OnLeave", UnitFrame_OnLeave);

	self.RaisedElementParent = CreateFrame("Frame", nil, self);
	self.RaisedElementParent:SetFrameLevel(self:GetFrameLevel() + 100);

	self.Health = UF:Construct_HealthBar(self, true, true, "RIGHT");
	self.Name = UF:Construct_NameText(self);
	self.Portrait3D = UF:Construct_Portrait(self, "model");
	self.Portrait2D = UF:Construct_Portrait(self, "texture");
	self.Buffs = UF:Construct_Buffs(self);
	self.Debuffs = UF:Construct_Debuffs(self);
	self.AuraWatch = UF:Construct_AuraWatch(self);
	self.RaidDebuffs = UF:Construct_RaidDebuffs(self);
	self.DebuffHighlight = UF:Construct_DebuffHighlight(self);
	self.TargetGlow = UF:Construct_TargetGlow(self);
	tinsert(self.__elements, UF.UpdateTargetGlow);
	self:RegisterEvent("PLAYER_TARGET_CHANGED", UF.UpdateTargetGlow);
	self:RegisterEvent("PLAYER_ENTERING_WORLD", UF.UpdateTargetGlow);
	self.Threat = UF:Construct_Threat(self);
	self.RaidIcon = UF:Construct_RaidIcon(self);
	self.HealCommBar = UF:Construct_HealComm(self);
	self.Range = UF:Construct_Range(self);
	self.customTexts = {};

	UF:Update_StatusBars();
	UF:Update_FontStrings();
	self.unitframeType = "raidpet";

	UF:Update_RaidpetFrames(self, UF.db["units"]["raidpet"]);

	return self;
end

function UF:RaidPetsSmartVisibility(event)
	if(not self.db or (self.db and not self.db.enable) or (UF.db and not UF.db.smartRaidFilter) or self.isForced) then return; end
	if(event == "PLAYER_REGEN_ENABLED") then self:UnregisterEvent("PLAYER_REGEN_ENABLED") end

	if(not InCombatLockdown()) then
		local inInstance, instanceType = IsInInstance();
		if(inInstance and instanceType == "raid") then
			UnregisterStateDriver(self, "visibility");
			self:Show();
		elseif(self.db.visibility) then
			RegisterStateDriver(self, "visibility", self.db.visibility);
		end
	else
		self:RegisterEvent("PLAYER_REGEN_ENABLED");
		return;
	end
end

function UF:Update_RaidpetHeader(header, db)
	header.db = db;

	if(not header.positioned) then
		header:ClearAllPoints();
		header:Point("BOTTOMLEFT", E.UIParent, "BOTTOMLEFT", 4, 574);

		E:CreateMover(header, header:GetName() .. "Mover", L["Raid Pet Frames"], nil, nil, nil, "ALL,RAID10,RAID25,RAID40");
		header.positioned = true;

		header:RegisterEvent("PLAYER_LOGIN");
		header:RegisterEvent("ZONE_CHANGED_NEW_AREA");
		header:SetScript("OnEvent", UF["RaidPetsSmartVisibility"]);
	end

	UF.RaidPetsSmartVisibility(header);
end

function UF:Update_RaidpetFrames(frame, db)
	frame.db = db;

	frame.Portrait = frame.Portrait or (db.portrait.style == "2D" and frame.Portrait2D or frame.Portrait3D);
	frame.colors = ElvUF.colors;
	frame:RegisterForClicks(self.db.targetOnMouseDown and "AnyDown" or "AnyUp");

	do
		if(self.thinBorders) then
			frame.SPACING = 0;
			frame.BORDER = E.mult;
		else
			frame.BORDER = E.Border;
			frame.SPACING = E.Spacing;
		end

		frame.SHADOW_SPACING = 3;

		frame.ORIENTATION = db.orientation;

		frame.UNIT_WIDTH = db.width;
		frame.UNIT_HEIGHT = db.height;

		frame.USE_POWERBAR = false;
		frame.POWERBAR_DETACHED = false;
		frame.USE_INSET_POWERBAR = false;
		frame.USE_MINI_POWERBAR = false;
		frame.USE_POWERBAR_OFFSET = false;
		frame.POWERBAR_OFFSET = 0;
		frame.POWERBAR_HEIGHT = 0;
		frame.POWERBAR_WIDTH = 0;

		frame.USE_PORTRAIT = db.portrait and db.portrait.enable;
		frame.USE_PORTRAIT_OVERLAY = frame.USE_PORTRAIT and (db.portrait.overlay or frame.ORIENTATION == "MIDDLE");
		frame.PORTRAIT_WIDTH = (frame.USE_PORTRAIT_OVERLAY or not frame.USE_PORTRAIT) and 0 or db.portrait.width;

		frame.CLASSBAR_WIDTH = 0;
		frame.CLASSBAR_YOFFSET = 0;
		frame.BOTTOM_OFFSET = 0;

		frame.VARIABLES_SET = true;
	end

	if(not InCombatLockdown()) then
		frame:Size(frame.UNIT_WIDTH, frame.UNIT_HEIGHT);
	else
		frame:SetAttribute("initial-height", frame.UNIT_HEIGHT);
		frame:SetAttribute("initial-width", frame.UNIT_WIDTH);
	end

	UF:Configure_HealthBar(frame);

	UF:UpdateNameSettings(frame);

	UF:Configure_Portrait(frame);

	UF:Configure_Threat(frame);

	UF:Configure_TargetGlow(frame);

	UF:EnableDisable_Auras(frame);
	UF:Configure_Auras(frame, "Buffs");
	UF:Configure_Auras(frame, "Debuffs");

	UF:Configure_RaidDebuffs(frame);

	UF:Configure_RaidIcon(frame);

	UF:Configure_DebuffHighlight(frame);

	UF:Configure_HealComm(frame);

	UF:Configure_Range(frame);

	UF:UpdateAuraWatch(frame, true);

	UF:Configure_CustomTexts(frame);

	frame:UpdateAllElements("ElvUI_UpdateAllElements");
end

UF["headerstoload"]["raidpet"] = {nil, nil, "SecureGroupPetHeaderTemplate"};