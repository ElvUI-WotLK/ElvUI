local E, L, V, P, G = unpack(select(2, ...));
local UF = E:GetModule("UnitFrames");

local RegisterStateDriver = RegisterStateDriver;
local InCombatLockdown = InCombatLockdown;

local _, ns = ...;
local ElvUF = ns.oUF;
assert(ElvUF, "ElvUI was unable to locate oUF.");

function UF:Construct_TankFrames(unitGroup)
	self:SetScript("OnEnter", UnitFrame_OnEnter);
	self:SetScript("OnLeave", UnitFrame_OnLeave);

	self.RaisedElementParent = CreateFrame("Frame", nil, self);
	self.RaisedElementParent.TextureParent = CreateFrame("Frame", nil, self.RaisedElementParent)
	self.RaisedElementParent:SetFrameLevel(self:GetFrameLevel() + 100);

	self.Health = UF:Construct_HealthBar(self, true);
	self.Name = UF:Construct_NameText(self);
	self.ThreatIndicator = UF:Construct_Threat(self);
	self.RaidTargetIndicator = UF:Construct_RaidIcon(self);
	self.Range = UF:Construct_Range(self);

	if(not self.isChild) then
		self.Buffs = UF:Construct_Buffs(self);
		self.Debuffs = UF:Construct_Debuffs(self);
		self.AuraWatch = UF:Construct_AuraWatch(self);
		self.RaidDebuffs = UF:Construct_RaidDebuffs(self);
		self.DebuffHighlight = UF:Construct_DebuffHighlight(self);
		self.unitframeType = "tank";
	else
		self.unitframeType = "tanktarget";
	end

	UF:Update_StatusBars();
	UF:Update_FontStrings();

	self.originalParent = self:GetParent();

	UF:Update_TankFrames(self, UF.db["units"]["tank"]);

	return self;
end

function UF:Update_TankHeader(header, db)
	header:Hide();
	header.db = db;

	UF:ClearChildPoints(header:GetChildren());

	header:SetAttribute("startingIndex", -1);
	RegisterStateDriver(header, "visibility", "show")
	RegisterStateDriver(header, "visibility", "[@raid1,exists] show;hide");
	header:SetAttribute("startingIndex", 1);

	header:SetAttribute("point", "BOTTOM");
	header:SetAttribute("columnAnchorPoint", "LEFT");

	UF:ClearChildPoints(header:GetChildren());
	header:SetAttribute("yOffset", db.verticalSpacing);

	local width, height = header:GetSize();
	header.dirtyWidth, header.dirtyHeight = width, max(height, 2*db.height + db.verticalSpacing);

	if(not header.positioned) then
		header:ClearAllPoints();
		header:Point("TOPLEFT", E.UIParent, "TOPLEFT", 4, -186);

		E:CreateMover(header, header:GetName().."Mover", L["MT Frames"], nil, nil, nil, "ALL,RAID");
		header.mover.positionOverride = "TOPLEFT";
		header:SetAttribute("minHeight", header.dirtyHeight);
		header:SetAttribute("minWidth", header.dirtyWidth);
		header.positioned = true;
	end
end

function UF:Update_TankFrames(frame, db)
	frame.db = db;

	do
		frame.ORIENTATION = db.orientation;
		if(self.thinBorders) then
			frame.SPACING = 0;
			frame.BORDER = E.mult;
		else
			frame.BORDER = E.Border;
			frame.SPACING = E.Spacing;
		end
		frame.SHADOW_SPACING = 3;

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

		frame.USE_PORTRAIT = false;
		frame.USE_PORTRAIT_OVERLAY = false;
		frame.PORTRAIT_WIDTH = 0;

		frame.CLASSBAR_WIDTH = 0;
		frame.CLASSBAR_YOFFSET = 0;
		frame.BOTTOM_OFFSET = 0;

		frame.VARIABLES_SET = true;
	end

	frame.colors = ElvUF.colors;
	frame:RegisterForClicks(self.db.targetOnMouseDown and "AnyDown" or "AnyUp");

	if(frame.isChild and frame.originalParent) then
		local childDB = db.targetsGroup;
		frame.db = db.targetsGroup
		if(not frame.originalParent.childList) then
			frame.originalParent.childList = {};
		end
		frame.originalParent.childList[frame] = true;

		if(not InCombatLockdown()) then
			if(childDB.enable) then
				frame:SetParent(frame.originalParent);
				frame:Size(childDB.width, childDB.height);
				frame:ClearAllPoints();
				frame:Point(E.InversePoints[childDB.anchorPoint], frame.originalParent, childDB.anchorPoint, childDB.xOffset, childDB.yOffset);
			else
				frame:SetParent(E.HiddenFrame);
			end
		else
			frame:SetAttribute("initial-height", childDB.height);
			frame:SetAttribute("initial-width", childDB.width);
		end
	end

	if(not InCombatLockdown()) then
		frame.db = db;
		frame:Size(db.width, db.height);
	else
		frame:SetAttribute("initial-height", frame.UNIT_HEIGHT);
		frame:SetAttribute("initial-width", frame.UNIT_WIDTH);
	end

	UF:Configure_HealthBar(frame);

	local name = frame.Name;
	name:Point("CENTER", frame.Health, "CENTER");
	if(UF.db.colors.healthclass) then
		frame:Tag(name, "[name:medium]");
	else
		frame:Tag(name, "[namecolor][name:medium]");
	end

	UF:Configure_Threat(frame);

	UF:Configure_Range(frame);

	if(not frame.isChild) then
		UF:EnableDisable_Auras(frame);
		UF:Configure_Auras(frame, "Buffs");
		UF:Configure_Auras(frame, "Debuffs");

		UF:Configure_RaidDebuffs(frame);

		UF:Configure_DebuffHighlight(frame);

		UF:UpdateAuraWatch(frame);
	end

	frame:UpdateAllElements("ElvUI_UpdateAllElements");
end

UF["headerstoload"]["tank"] = {"MAINTANK", "ELVUI_UNITTARGET"};