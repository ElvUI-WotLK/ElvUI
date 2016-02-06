local E, L, V, P, G = unpack(select(2, ...));
local UF = E:GetModule("UnitFrames");

local RegisterStateDriver = RegisterStateDriver;
local InCombatLockdown = InCombatLockdown;

local _, ns = ...;
local ElvUF = ns.oUF;
assert(ElvUF, "ElvUI was unable to locate oUF.");

function UF:Construct_AssistFrames(unitGroup)
	self:SetScript("OnEnter", UnitFrame_OnEnter);
	self:SetScript("OnLeave", UnitFrame_OnLeave);
	
	self.Health = UF:Construct_HealthBar(self, true);
	self.Name = UF:Construct_NameText(self);
	self.Threat = UF:Construct_Threat(self);
	self.RaidIcon = UF:Construct_RaidIcon(self);
	self.Range = UF:Construct_Range(self);
	
	if(not self.isChild) then
		self.Buffs = UF:Construct_Buffs(self);
		self.Debuffs = UF:Construct_Debuffs(self);
		self.AuraWatch = UF:Construct_AuraWatch(self);
		self.RaidDebuffs = UF:Construct_RaidDebuffs(self);
		self.DebuffHighlight = UF:Construct_DebuffHighlight(self);
	end
	
	UF:Update_AssistFrames(self, E.db["unitframe"]["units"]["assist"]);
	UF:Update_StatusBars();
	UF:Update_FontStrings();
	
	self.originalParent = self:GetParent();
	
	return self;
end

function UF:Update_AssistHeader(header, db)
	header:Hide();
	header.db = db;
	
	UF:ClearChildPoints(header:GetChildren());
	
	header:SetAttribute("startingIndex", -1);
	RegisterStateDriver(header, "visibility", "show");
	header.dirtyWidth, header.dirtyHeight = header:GetSize();
	RegisterStateDriver(header, "visibility", "[@raid1,exists] show;hide");
	header:SetAttribute("startingIndex", 1);
	
	header:SetAttribute("point", "BOTTOM");
	header:SetAttribute("columnAnchorPoint", "LEFT");
	
	UF:ClearChildPoints(header:GetChildren());
	header:SetAttribute("yOffset", db.verticalSpacing);
	
	if(not header.positioned) then
		header:ClearAllPoints();
		header:Point("TOPLEFT", E.UIParent, "TOPLEFT", 4, -248);
		
		E:CreateMover(header, header:GetName().."Mover", L["MA Frames"], nil, nil, nil, "ALL,RAID");
		header.mover.positionOverride = "TOPLEFT";
		header:SetAttribute("minHeight", header.dirtyHeight);
		header:SetAttribute("minWidth", header.dirtyWidth);
		header.positioned = true;
	end
end

function UF:Update_AssistFrames(frame, db)
	frame.db = db;
	
	do
		frame.ORIENTATION = db.orientation;
		frame.BORDER = E.Border;
		frame.SPACING = E.Spacing;
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
	end
	
	frame.colors = ElvUF.colors;
	frame:RegisterForClicks(self.db.targetOnMouseDown and "AnyDown" or "AnyUp");
	
	if(frame.isChild and frame.originalParent) then
		local childDB = db.targetsGroup;
		frame.db = db.targetsGroup;
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
		end
	elseif(not InCombatLockdown()) then
		frame.db = db;
		frame:Size(frame.UNIT_WIDTH, frame.UNIT_HEIGHT);
	end
	
	UF:Configure_HealthBar(frame);
	
	UF:Configure_Threat(frame);
	
	local name = frame.Name;
	name:Point("CENTER", frame.Health, "CENTER");
	if(UF.db.colors.healthclass) then
		frame:Tag(name, "[name:medium]");
	else
		frame:Tag(name, "[namecolor][name:medium]");
	end
	
	UF:Configure_Range(frame);
	
	if(not frame.isChild) then
		UF:EnableDisable_Auras(frame);
		UF:Configure_Auras(frame, "Buffs");
		UF:Configure_Auras(frame, "Debuffs");
		
		UF:Configure_RaidDebuffs(frame);
		
		UF:Configure_DebuffHighlight(frame);
		
		UF:UpdateAuraWatch(frame);
	end
	
	UF:ToggleTransparentStatusBar(UF.db.colors.transparentHealth, frame.Health, frame.Health.bg, true);
	
	frame:UpdateAllElements();
end

UF["headerstoload"]["assist"] = {"MAINASSIST", "ELVUI_UNITTARGET"};