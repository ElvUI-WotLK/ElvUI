local E, L, V, P, G = unpack(select(2, ...));
local UF = E:GetModule("UnitFrames");

local tinsert = table.insert;

local CreateFrame = CreateFrame;
local InCombatLockdown = InCombatLockdown;
local IsInInstance = IsInInstance;
local GetInstanceInfo = GetInstanceInfo;
local UnregisterStateDriver = UnregisterStateDriver;
local RegisterStateDriver = RegisterStateDriver;

local _, ns = ...;
local ElvUF = ns.oUF;
assert(ElvUF, "ElvUI was unable to locate oUF.");

function UF:Construct_RaidFrames(unitGroup)
	self:SetScript("OnEnter", UnitFrame_OnEnter);
	self:SetScript("OnLeave", UnitFrame_OnLeave);

	self.RaisedElementParent = CreateFrame("Frame", nil, self);
	self.RaisedElementParent.TextureParent = CreateFrame("Frame", nil, self.RaisedElementParent)
	self.RaisedElementParent:SetFrameLevel(self:GetFrameLevel() + 100);

	self.Health = UF:Construct_HealthBar(self, true, true, "RIGHT");
	self.Power = UF:Construct_PowerBar(self, true, true, "LEFT");
	self.Power.frequentUpdates = false;
	self.Portrait3D = UF:Construct_Portrait(self, "model");
	self.Portrait2D = UF:Construct_Portrait(self, "texture");
	self.Name = UF:Construct_NameText(self);
	self.Buffs = UF:Construct_Buffs(self);
	self.Debuffs = UF:Construct_Debuffs(self);
	self.AuraWatch = UF:Construct_AuraWatch(self);
	self.RaidDebuffs = UF:Construct_RaidDebuffs(self);
	self.DebuffHighlight = UF:Construct_DebuffHighlight(self);
	self.GroupRoleIndicator = UF:Construct_RoleIcon(self);
	self.RaidRoleFramesAnchor = UF:Construct_RaidRoleFrames(self);
	self.TargetGlow = UF:Construct_TargetGlow(self);
	tinsert(self.__elements, UF.UpdateTargetGlow);
	self:RegisterEvent("PLAYER_TARGET_CHANGED", UF.UpdateTargetGlow);
	self:RegisterEvent("PLAYER_ENTERING_WORLD", UF.UpdateTargetGlow);
	self.ThreatIndicator = UF:Construct_Threat(self)
	self.RaidTargetIndicator = UF:Construct_RaidIcon(self);
	self.ReadyCheckIndicator = UF:Construct_ReadyCheckIcon(self);
	self.HealCommBar = UF:Construct_HealComm(self);
	self.GPS = UF:Construct_GPS(self);
	self.Range = UF:Construct_Range(self);
	self.customTexts = {};
	self.InfoPanel = UF:Construct_InfoPanel(self);
	UF:Update_StatusBars();
	UF:Update_FontStrings();
	self.unitframeType = "raid";

	UF:Update_RaidFrames(self, UF.db["units"]["raid"]);

	return self;
end

function UF:RaidSmartVisibility(event)
	if(not self.db or (self.db and not self.db.enable) or (UF.db and not UF.db.smartRaidFilter) or self.isForced) then
		self.blockVisibilityChanges = false;
		return;
	end

	if(event == "PLAYER_REGEN_ENABLED") then self:UnregisterEvent("PLAYER_REGEN_ENABLED"); end

	if(not InCombatLockdown()) then
		self.isInstanceForced = nil;
		local inInstance, instanceType = IsInInstance();
		if(inInstance and (instanceType == "raid" or instanceType == "pvp")) then
			local _, _, _, _, maxPlayers = GetInstanceInfo();
			local mapID = GetCurrentMapAreaID();
			if(UF.mapIDs[mapID]) then
				maxPlayers = UF.mapIDs[mapID];
			end

			UnregisterStateDriver(self, "visibility");

			if(maxPlayers < 40) then
				self:Show();
				self.isInstanceForced = true;
				self.blockVisibilityChanges = false;
				if(ElvUF_Raid.numGroups ~= E:Round(maxPlayers/5) and event) then
					UF:CreateAndUpdateHeaderGroup("raid");
				end
			else
				self:Hide();
				self.blockVisibilityChanges = true;
			end
		elseif(self.db.visibility) then
			RegisterStateDriver(self, "visibility", self.db.visibility);
			self.blockVisibilityChanges = false;
			if(ElvUF_Raid.numGroups ~= self.db.numGroups) then
				UF:CreateAndUpdateHeaderGroup("raid");
			end
		end
	else
		self:RegisterEvent("PLAYER_REGEN_ENABLED");
		return;
	end
end

function UF:Update_RaidHeader(header, db)
	header.db = db;

	if(not header.positioned) then
		header:ClearAllPoints();
		header:Point("BOTTOMLEFT", E.UIParent, "BOTTOMLEFT", 4, 195);

		E:CreateMover(header, header:GetName() .. "Mover", L["Raid Frames"], nil, nil, nil, "ALL,RAID");

		header:RegisterEvent("PLAYER_LOGIN");
		header:RegisterEvent("ZONE_CHANGED_NEW_AREA");
		header:SetScript("OnEvent", UF["RaidSmartVisibility"]);
		header.positioned = true;
	end

	UF.RaidSmartVisibility(header);
end

function UF:Update_RaidFrames(frame, db)
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

		frame.CLASSBAR_WIDTH = 0;
		frame.CLASSBAR_YOFFSET = 0;

		frame.USE_INFO_PANEL = not frame.USE_MINI_POWERBAR and not frame.USE_POWERBAR_OFFSET and db.infoPanel.enable;
		frame.INFO_PANEL_HEIGHT = frame.USE_INFO_PANEL and db.infoPanel.height or 0;

		frame.BOTTOM_OFFSET = UF:GetHealthBottomOffset(frame);

		frame.VARIABLES_SET = true;
	end

	if(not InCombatLockdown()) then
		frame:Size(frame.UNIT_WIDTH, frame.UNIT_HEIGHT);
	else
		frame:SetAttribute("initial-height", frame.UNIT_HEIGHT);
		frame:SetAttribute("initial-width", frame.UNIT_WIDTH);
	end

	UF:Configure_InfoPanel(frame);

	UF:Configure_HealthBar(frame);

	UF:UpdateNameSettings(frame);

	UF:Configure_Power(frame);

	UF:Configure_Portrait(frame);

	UF:Configure_Threat(frame);

	UF:Configure_TargetGlow(frame);

	UF:EnableDisable_Auras(frame);
	UF:Configure_Auras(frame, "Buffs");
	UF:Configure_Auras(frame, "Debuffs");

	UF:Configure_RaidDebuffs(frame);

	UF:Configure_RaidIcon(frame);

	UF:Configure_DebuffHighlight(frame);

	UF:Configure_RoleIcon(frame);

	UF:Configure_HealComm(frame);

	UF:Configure_GPS(frame);

	UF:Configure_RaidRoleIcons(frame);

	UF:Configure_Range(frame);

	UF:UpdateAuraWatch(frame);

	UF:Configure_ReadyCheckIcon(frame);

	UF:Configure_CustomTexts(frame);

	frame:UpdateAllElements("ElvUI_UpdateAllElements");
end

UF["headerstoload"]["raid"] = true;