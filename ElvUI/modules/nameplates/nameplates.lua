local E, L, V, P, G = unpack(select(2, ...));
local mod = E:NewModule("NamePlates", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0");
local LSM = LibStub("LibSharedMedia-3.0");

local _G = _G;
local tonumber, pairs, select, tostring, unpack = tonumber, pairs, select, tostring, unpack;
local twipe, tinsert, wipe = table.wipe, table.insert, wipe;
local band = bit.band;
local floor = math.floor;
local gsub, format, strsplit = string.gsub, format, strsplit;

local CreateFrame = CreateFrame;
local GetTime = GetTime;
local UnitGUID = UnitGUID;
local UnitName = UnitName;
local InCombatLockdown = InCombatLockdown;
local UnitExists = UnitExists;
local SetCVar = SetCVar;
local IsAddOnLoaded = IsAddOnLoaded;
local GetSpellInfo = GetSpellInfo;
local GetSpellTexture = GetSpellTexture;
local UnitBuff, UnitDebuff = UnitBuff, UnitDebuff;
local UnitPlayerControlled = UnitPlayerControlled;
local GetRaidTargetIndex = GetRaidTargetIndex;
local WorldFrame = WorldFrame;
local RAID_CLASS_COLORS = RAID_CLASS_COLORS;
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS;
local COMBATLOG_OBJECT_CONTROL_PLAYER = COMBATLOG_OBJECT_CONTROL_PLAYER;

local numChildren = 0;
local targetIndicator;
local targetAlpha = 1;

local OVERLAY = [=[Interface\TargetingFrame\UI-TargetingFrame-Flash]=];

--Pattern to remove cross realm label added to the end of plate names
--Taken from http://www.wowace.com/addons/libnameplateregistry-1-0/
local FSPAT = "%s*"..((_G.FOREIGN_SERVER_LABEL:gsub("^%s", "")):gsub("[%*()]", "%%%1")).."$";

mod.NumTargetChecks = -1;
mod.CreatedPlates = {};
mod.Healers = {};
mod.ComboPoints = {};
mod.ByRaidIcon = {};
mod.ByName = {};
mod.AuraList = {};
mod.AuraSpellID = {};
mod.AuraExpiration = {};
mod.AuraStacks = {};
mod.AuraCaster = {};
mod.AuraDuration = {};
mod.AuraTexture = {};
mod.AuraType = {};
mod.AuraTarget = {};
mod.CachedAuraDurations = {};
mod.BuffCache = {};
mod.DebuffCache = {};

mod.RaidTargetReference = {
	["STAR"] = 0x00000001,
	["CIRCLE"] = 0x00000002,
	["DIAMOND"] = 0x00000004,
	["TRIANGLE"] = 0x00000008,
	["MOON"] = 0x00000010,
	["SQUARE"] = 0x00000020,
	["CROSS"] = 0x00000040,
	["SKULL"] = 0x00000080
};

mod.RaidIconCoordinate = {
	[0] =		{[0] = "STAR",		[0.25] = "MOON"},
	[0.25] =	{[0] = "CIRCLE",	[0.25] = "SQUARE"},
	[0.5] =		{[0] = "DIAMOND",	[0.25] = "CROSS"},
	[0.75] =	{[0] = "TRIANGLE",	[0.25] = "SKULL"}
};

mod.ComboColors = {
	[1] = {0.69, 0.31, 0.31},
	[2] = {0.69, 0.31, 0.31},
	[3] = {0.65, 0.63, 0.35},
	[4] = {0.65, 0.63, 0.35},
	[5] = {0.33, 0.59, 0.33}
};

mod.RaidMarkColors = {
	["STAR"] = {r = 0.85, g = 0.81, b = 0.27},
	["MOON"] = {r = 0.60,g = 0.75,b = 0.85},
	["CIRCLE"] = {r = 0.93,g = 0.51,b = 0.06},
	["SQUARE"] = {r = 0,g = 0.64,b = 1},
	["DIAMOND"] = {r = 0.7,g = 0.06,b = 0.84},
	["CROSS"] = {r = 0.82,g = 0.18,b = 0.18},
	["TRIANGLE"] = {r = 0.14,g = 0.66,b = 0.14},
	["SKULL"] = {r = 0.89,g = 0.83,b = 0.74}
};

local AURA_UPDATE_INTERVAL = 0.1;
local AURA_TARGET_HOSTILE = 1;
local AURA_TARGET_FRIENDLY = 2;
local AuraList, AuraGUID = {}, {}

local RaidIconIndex = {
	"STAR",
	"CIRCLE",
	"DIAMOND",
	"TRIANGLE",
	"MOON",
	"SQUARE",
	"CROSS",
	"SKULL"
};

local TimeColors = {
	[0] = "|cffeeeeee",
	[1] = "|cffeeeeee",
	[2] = "|cffeeeeee",
	[3] = "|cffFFEE00",
	[4] = "|cfffe0000"
};

function mod:SetTargetIndicatorDimensions()
	if(self.db.targetIndicator.style == "arrow") then
		targetIndicator.arrow:SetHeight(self.db.targetIndicator.height);
		targetIndicator.arrow:SetWidth(self.db.targetIndicator.width);
	elseif(self.db.targetIndicator.style == "doubleArrow" or self.db.targetIndicator.style == "doubleArrowInverted") then
		targetIndicator.left:SetHeight(self.db.targetIndicator.height);
		targetIndicator.left:SetWidth(self.db.targetIndicator.width);
		targetIndicator.right:SetWidth(self.db.targetIndicator.width);
		targetIndicator.right:SetHeight(self.db.targetIndicator.height);
	end
end

function mod:PositionTargetIndicator(frame)
	targetIndicator:SetParent(frame);
	if(self.db.targetIndicator.style == "arrow") then
		targetIndicator.arrow:ClearAllPoints();
		targetIndicator.arrow:SetPoint("BOTTOM", frame.HealthBar, "TOP", 0, 30 + self.db.targetIndicator.yOffset);
	elseif(self.db.targetIndicator.style == "doubleArrow") then
		targetIndicator.left:SetPoint("RIGHT", frame.HealthBar, "LEFT", -self.db.targetIndicator.xOffset, 0);
		targetIndicator.right:SetPoint("LEFT", frame.HealthBar, "RIGHT", self.db.targetIndicator.xOffset, 0);
		targetIndicator:SetFrameLevel(0);
		targetIndicator:SetFrameStrata("BACKGROUND");
	elseif(self.db.targetIndicator.style == "doubleArrowInverted") then
		targetIndicator.right:SetPoint("RIGHT", frame.HealthBar, "LEFT", -self.db.targetIndicator.xOffset, 0);
		targetIndicator.left:SetPoint("LEFT", frame.HealthBar, "RIGHT", self.db.targetIndicator.xOffset, 0);
		targetIndicator:SetFrameLevel(0);
		targetIndicator:SetFrameStrata("BACKGROUND");
	elseif(self.db.targetIndicator.style == "glow") then
		targetIndicator:SetOutside(frame.HealthBar, 3, 3);
		targetIndicator:SetFrameLevel(0);
		targetIndicator:SetFrameStrata("BACKGROUND");
	end

	targetIndicator:Show();
end

function mod:ColorTargetIndicator(r, g, b)
	if(self.db.targetIndicator.style == "arrow") then
		targetIndicator.arrow:SetVertexColor(r, g, b);
	elseif(self.db.targetIndicator.style == "doubleArrow" or self.db.targetIndicator.style == "doubleArrowInverted") then
		targetIndicator.left:SetVertexColor(r, g, b);
		targetIndicator.right:SetVertexColor(r, g, b);
	elseif(self.db.targetIndicator.style == "glow") then
		targetIndicator:SetBackdropBorderColor(r, g, b);
	end
end

function mod:SetTargetIndicator()
	if(self.db.targetIndicator.style == "arrow") then
		targetIndicator = self.arrowIndicator;
		self.glowIndicator:Hide();
		self.doubleArrowIndicator:Hide();
	elseif(self.db.targetIndicator.style == "doubleArrow" or self.db.targetIndicator.style == "doubleArrowInverted") then
		targetIndicator = self.doubleArrowIndicator;
		targetIndicator.left:ClearAllPoints();
		targetIndicator.right:ClearAllPoints();
		self.arrowIndicator:Hide();
		self.glowIndicator:Hide();
	elseif(self.db.targetIndicator.style == "glow") then
		targetIndicator = self.glowIndicator;
		self.arrowIndicator:Hide();
		self.doubleArrowIndicator:Hide();
	end

	self:SetTargetIndicatorDimensions();
end

function mod:OnUpdate(elapsed)
	local count = WorldFrame:GetNumChildren();
	if(count ~= numChildren) then
		for i = numChildren + 1, count do
			local frame = select(i, WorldFrame:GetChildren())
			local region = frame:GetRegions();

			if(not mod.CreatedPlates[frame] and region and region:GetObjectType() == "Texture" and region:GetTexture() == OVERLAY) then
				mod:CreatePlate(frame);
			end
		end
		numChildren = count;
	end

	if(self.elapsed and self.elapsed > 0.2) then
		for blizzPlate in pairs(mod.CreatedPlates) do
			if(blizzPlate:IsShown()) then
				mod.SetUnitInfo(blizzPlate);
				mod.ColorizeAndScale(blizzPlate);
				mod.UpdateLevelAndName(blizzPlate);
			end
		end

		self.elapsed = 0;
	else
		self.elapsed = (self.elapsed or 0) + elapsed;
	end
end

function mod:CheckFilter()
	local name = gsub(self.oldName:GetText(), FSPAT, "");
	local db = E.global.nameplate["filter"][name];

	if(db and db.enable) then
		if(db.hide) then
			return;
		else
			if(db.customColor) then
				self.customColor = db.color;
				self.HealthBar:SetStatusBarColor(db.color.r, db.color.g, db.color.b);
			else
				self.customColor = nil;
			end

			if(db.customScale and db.customScale ~= 1) then
				self.HealthBar:Height(mod.db.healthBar.height * db.customScale);
				self.HealthBar:Width(mod.db.healthBar.width * db.customScale);
				self.customScale = true;
			else
				self.customScale = nil;
			end
		end
	end

	if(mod.Healers[name]) then
		self.HealerIcon:Show();
	else
		self.HealerIcon:Hide();
	end

	return true;
end

function mod:CheckBGHealers()
	local name, _, damageDone, healingDone;
	for i = 1, GetNumBattlefieldScores() do
		name, _, _, _, _, _, _, _, _, _, damageDone, healingDone = GetBattlefieldScore(i);
		if(name) then
			name = name:match("(.+)%-.+") or name;
			if(name and healingDone > damageDone) then
				self.Healers[name] = true;
			elseif(name and self.Healers[name]) then
				self.Healers[name] = nil;
			end
		end
	end
end

function mod:UpdateLevelAndName()
	if(not mod.db.showLevel) then
		self.Level:SetText("");
		self.Level:Hide();
	else
		local level, elite, boss = self.Level:GetObjectType() == "FontString" and tonumber(self.oldLevel:GetText()) or nil, self.EliteIcon:IsShown(), self.BossIcon:IsShown();
		if(boss) then
			self.Level:SetText("??");
			self.level:SetTextColor(0.8, 0.05, 0);
		elseif(level) then
			self.Level:SetText(level .. (elite and "+" or ""));
			self.Level:SetTextColor(self.oldLevel:GetTextColor());
		end

		if(not self.Level:IsShown()) then
			self.Level:Show();
		end
	end

	if(not mod.db.showName) then
		self.Name:SetText("");
		self.Name:Hide();
	else
		self.Name:SetText(self.oldName:GetText());
		if(not self.Name:IsShown()) then self.Name:Show(); end
	end

	if(self.oldRaidIcon:IsShown()) then
		local ux, uy = self.oldRaidIcon:GetTexCoord();
		if((ux ~= self.RaidIcon.ULx or uy ~= self.RaidIcon.ULy)) then
			self.RaidIcon:Show();
			self.RaidIcon:SetTexCoord(self.oldRaidIcon:GetTexCoord());
			self.RaidIcon.ULx, self.RaidIcon.ULy = ux, uy;
		end
	elseif(self.RaidIcon:IsShown()) then
		self.RaidIcon:Hide();
	end
end

function mod:GetReaction(frame)
	local r, g, b = self:RoundColors(frame.oldHealthBar:GetStatusBarColor());

	for class, _ in pairs(RAID_CLASS_COLORS) do
		if(RAID_CLASS_COLORS[class].r == r and RAID_CLASS_COLORS[class].g == g and RAID_CLASS_COLORS[class].b == b) then
			return class;
		end
	end

	if((r + b + b) == 1.59) then
		return "TAPPED_NPC";
	elseif(g + b == 0) then
		return "HOSTILE_NPC";
	elseif(r + b == 0) then
		return "FRIENDLY_NPC";
	elseif(r + g > 1.95) then
		return "NEUTRAL_NPC";
	elseif(r + g == 0) then
		return "FRIENDLY_PLAYER";
	else
		return "HOSTILE_PLAYER";
	end
end

function mod:GetThreatReaction(frame)
	if(frame.Threat:IsShown()) then
		local r, g, b = frame.Threat:GetVertexColor();
		if(g + b == 0) then
			return "FULL_THREAT";
		else
			if(self.threatReaction == "FULL_THREAT") then
				return "GAINING_THREAT";
			else
				return "LOSING_THREAT";
			end
		end
	else
		return "NO_THREAT";
	end
end

local color, scale;
function mod:ColorizeAndScale()
	local unitType = mod:GetReaction(self);
	local scale = 1;
	local canAttack = false;

	self.unitType = unitType;
	if(CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[unitType]) then
		color = CUSTOM_CLASS_COLORS[unitType]
	elseif(RAID_CLASS_COLORS[unitType]) then
		color = RAID_CLASS_COLORS[unitType];
	elseif(unitType == "TAPPED_NPC") then
		color = mod.db.reactions.tapped;
	elseif(unitType == "HOSTILE_NPC" or unitType == "NEUTRAL_NPC") then
		local classRole = E.Role;
		local threatReaction = mod:GetThreatReaction(self);
		canAttack = true;
		if(not mod.db.threat.useThreatColor) then
			if(unitType == "NEUTRAL_NPC") then
				color = mod.db.reactions.neutral;
			else
				color = mod.db.reactions.enemy;
			end
		elseif(threatReaction == "FULL_THREAT") then
			if(classRole == "Tank") then
				color = mod.db.threat.goodColor;
				scale = mod.db.threat.goodScale;
			else
				color = mod.db.threat.badColor;
				scale = mod.db.threat.badScale;
			end
		elseif(threatReaction == "GAINING_THREAT") then
			if(classRole == "Tank") then
				color = mod.db.threat.goodTransition;
			else
				color = mod.db.threat.badTransition;
			end
		elseif(threatReaction == "LOSING_THREAT") then
			if(classRole == "Tank") then
				color = mod.db.threat.badTransition;
			else
				color = mod.db.threat.goodTransition;
			end
		elseif(InCombatLockdown()) then
			if(classRole == "Tank") then
				color = mod.db.threat.badColor;
				scale = mod.db.threat.badScale;
			else
				color = mod.db.threat.goodColor;
				scale = mod.db.threat.goodScale;
			end
		else
			if(unitType == "NEUTRAL_NPC") then
				color = mod.db.reactions.neutral;
			else
				color = mod.db.reactions.enemy;
			end
		end

		self.threatReaction = threatReaction;
	elseif(unitType == "FRIENDLY_NPC") then
		color = mod.db.reactions.friendlyNPC;
	elseif(unitType == "FRIENDLY_PLAYER") then
		color = mod.db.reactions.friendlyPlayer;
	else
		color = mod.db.reactions.enemy;
	end

	if(self.RaidIcon:IsShown() and mod.db.healthBar.colorByRaidIcon) then
		mod:CheckRaidIcon(self);
		local raidColor = mod.RaidMarkColors[self.raidIconType];
		color = raidColor or color;
	end

	if(mod.db.healthBar.lowHPScale.enable and mod.db.healthBar.lowHPScale.changeColor and self.Glow:IsShown() and canAttack) then
		color = mod.db.healthBar.lowHPScale.color;
	end

	if(not self.customColor) then
		self.HealthBar:SetStatusBarColor(color.r, color.g, color.b);

		if(mod.db.targetIndicator.enable and mod.db.targetIndicator.colorMatchHealthBar and self.unit == "target") then
			mod:ColorTargetIndicator(color.r, color.g, color.b);
		end
	elseif(self.unit == "target" and mod.db.targetIndicator.colorMatchHealthBar and mod.db.targetIndicator.enable) then
		mod:ColorTargetIndicator(self.customColor.r, self.customColor.g, self.customColor.b);
	end

	local w = mod.db.healthBar.width * scale;
	local h = mod.db.healthBar.height * scale;
	if(mod.db.healthBar.lowHPScale.enable) then
		if(self.Glow:IsShown()) then
			w = mod.db.healthBar.lowHPScale.width * scale;
			h = mod.db.healthBar.lowHPScale.height * scale;
			if(mod.db.healthBar.lowHPScale.toFront) then
				self.HealthBar:SetFrameStrata("HIGH");
			end
		else
			if(mod.db.healthBar.lowHPScale.toFront) then
				self.HealthBar:SetFrameStrata("BACKGROUND");
			end
		end
	end

	if(not self.customScale and self.HealthBar:GetWidth() ~= w) then
		self.HealthBar:SetSize(w, h);
		self.CastBar.Icon:SetSize(mod.db.castBar.height + h + 5, mod.db.castBar.height + h + 5);
	end
end

function mod:SetAlpha()
	if(self:GetAlpha() < 1) then
		self:SetAlpha(mod.db.nonTargetAlpha);
	else
		self:SetAlpha(targetAlpha);
	end
end

function mod:SetUnitInfo()
	local plateName = gsub(self.oldName:GetText(), FSPAT,"");
	if(self:GetAlpha() == 1 and mod.targetName and (mod.targetName == plateName)) then
		self.guid = UnitGUID("target");
		self.unit = "target";
		self.Highlight:Hide();

		if(mod.db.targetIndicator.enable) then
			targetIndicator:Show();
			mod:PositionTargetIndicator(self);
		end

		if((mod.NumTargetChecks > -1) or self.allowCheck) then
			mod.NumTargetChecks = mod.NumTargetChecks + 1;
			if(mod.NumTargetChecks > 0) then
				mod.NumTargetChecks = -1;
			end

			mod:UpdateElement_AurasByUnitID("target");
			mod:UpdateElement_CPointsByUnitID("target");
			self.allowCheck = nil;
		end
	elseif(self.oldHighlight:IsShown() and UnitExists("mouseover") and (UnitName("mouseover") == plateName)) then
		if(self.unit ~= "mouseover") then
			self.Highlight:Show();
			mod:UpdateElement_AurasByUnitID("mouseover");
			mod:UpdateElement_CPointsByUnitID("mouseover");
		end
		self.guid = UnitGUID("mouseover");
		self.unit = "mouseover";
		mod:UpdateElement_AurasByUnitID("mouseover");
	else
		self.Highlight:Hide();
		self.unit = nil;
	end
end

function mod:UpdateAllPlates()
	if(E.private["nameplate"].enable ~= true) then return; end
	self:ForEachPlate("UpdateSettings");
end

function mod:ForEachPlate(functionToRun, ...)
	for blizzPlate in pairs(self.CreatedPlates) do
		if(blizzPlate) then
			self[functionToRun](blizzPlate, ...);
		end
	end
end

function mod:RoundColors(r, g, b)
	return floor(r*100+.5)/100, floor(g*100+.5)/100, floor(b*100+.5)/100;
end

function mod:OnSizeChanged(width, height)
	local myPlate = mod.CreatedPlates[self];
	myPlate:SetSize(width, height);
end

function mod:OnShow()
	local objectType;
	for object in pairs(self.queue) do
		objectType = object:GetObjectType();
		if(objectType == "Texture") then
			object.OldTexture = object:GetTexture();
			object:SetTexture("");
			object:SetTexCoord(0, 0, 0, 0)
		elseif(objectType == "FontString") then
			object:SetWidth(0.001);
		elseif(objectType == "StatusBar") then
			object:SetStatusBarTexture("");
		end
		object:Hide();
	end

	if(not mod.CheckFilter(self)) then return; end

	mod.UpdateLevelAndName(self);
	mod.ColorizeAndScale(self);

	mod.UpdateElement_HealthOnValueChanged(self.oldHealthBar, self.oldHealthBar:GetValue());
	self.nameText = gsub(self.oldName:GetText(), FSPAT,"");

	mod:CheckRaidIcon(self);

	if(mod.db.buffs.enable or mod.db.debuffs.enable) then
		mod:UpdateElement_Auras(self);
	end

	mod:UpdateElement_CPoints(self);

	if(not mod.db.targetIndicator.colorMatchHealthBar) then
		mod:ColorTargetIndicator(mod.db.targetIndicator.color.r, mod.db.targetIndicator.color.g, mod.db.targetIndicator.color.b);
	end
end

function mod:OnHide()
	self.threatReaction = nil;
	self.unitType = nil;
	self.guid = nil;
	self.unit = nil;
	self.raidIconType = nil;
	self.customColor = nil;
	self.customScale = nil;
	self.allowCheck = nil;

	if(targetIndicator:GetParent() == self) then
		targetIndicator:Hide();
	end

	mod:HideAuraIcons(self.Buffs);
	mod:HideAuraIcons(self.Debuffs);
	self.RaidIcon.ULx, self.RaidIcon.ULy = nil, nil;
	self.Glow.r, self.Glow.g, self.Glow.b = nil, nil, nil;
	self.Glow:Hide();

	mod:HideComboPoints(self);
end

function mod:UpdateSettings()
	mod:ConfigureElement_HealthBar(self, self.customScale);
	mod:ConfigureElement_Level(self);
	mod:ConfigureElement_Name(self);
	mod:ConfigureElement_CastBar(self);
	mod:ConfigureElement_RaidIcon(self);
	self.Buffs.db = mod.db.buffs;
	if(mod.db.buffs.enable) then
		mod:UpdateAuraIcons(self.Buffs);
	end
	self.Debuffs.db = mod.db.debuffs;
	if(mod.db.debuffs.enable) then
		mod:UpdateAuraIcons(self.Debuffs);
	end
	mod:ConfigureElement_CPoints(self);

	mod.OnShow(self);
end

function mod:CreatePlate(frame)
	local HealthBar, CastBar = frame:GetChildren();
	local Threat, Border, CastBarShield, CastBarBorder, CastBarIcon, Highlight, Name, Level, BossIcon, RaidIcon, EliteIcon = frame:GetRegions();

	frame.HealthBar = self:ConstructElement_HealthBar(frame);
	CastBarIcon:SetParent(E.HiddenFrame);
	frame.CastBar = self:ConstructElement_CastBar(frame);
	frame.Level = self:ConstructElement_Level(frame);
	frame.Name = self:ConstructElement_Name(frame);
	RaidIcon:SetAlpha(0);
	frame.RaidIcon = self:ConstructElement_RaidIcon(frame);

	frame.Highlight = frame.HealthBar:CreateTexture(nil, "OVERLAY");
	frame.Highlight:SetAllPoints();
	frame.Highlight:SetTexture(1, 1, 1, 0.3);
	frame.Highlight:Hide();

	frame.Glow = self:ConstructElement_Glow(frame);
	frame.Buffs = self:ConstructElement_Auras(frame, 5, "RIGHT");
	frame.Debuffs = self:ConstructElement_Auras(frame, 5, "LEFT");

	frame.HealerIcon = self:ConstructElement_HealerIcon(frame);
	frame.CPoints = self:ConstructElement_CPoints(frame);

	frame:HookScript("OnShow", self.OnShow);
	frame:HookScript("OnHide", self.OnHide);
	frame:HookScript("OnSizeChanged", self.OnSizeChanged);
	HealthBar:HookScript("OnValueChanged", self.UpdateElement_HealthOnValueChanged);
	CastBar:HookScript("OnShow", self.UpdateElement_CastBarOnShow);
	CastBar:HookScript("OnHide", self.UpdateElement_CastBarOnHide);
	CastBar:HookScript("OnValueChanged", self.UpdateElement_CastBarOnValueChanged);

	frame.oldHealthBar = HealthBar;
	frame.Threat = Threat;
	frame.oldName = Name;
	frame.oldHighlight = Highlight;
	frame.oldLevel = Level;
	frame.BossIcon = BossIcon;
	frame.oldRaidIcon = RaidIcon;
	frame.EliteIcon = EliteIcon;

	self:QueueObject(frame, HealthBar);
	self:QueueObject(frame, CastBar);
	self:QueueObject(frame, Level);
	self:QueueObject(frame, Name);
	self:QueueObject(frame, Threat);
	self:QueueObject(frame, Border);
	self:QueueObject(frame, CastBarShield);
	self:QueueObject(frame, CastBarBorder);
	self:QueueObject(frame, Highlight);
	self:QueueObject(frame, BossIcon);
	self:QueueObject(frame, EliteIcon);
	self:QueueObject(frame, CastBarIcon);

	self.CreatedPlates[frame] = true;
	self.UpdateSettings(frame);
	if(not CastBar:IsShown()) then
		frame.CastBar:Hide();
	else
		self.UpdateElement_CastBarOnShow(CastBar);
	end
end

function mod:QueueObject(frame, object)
	frame.queue = frame.queue or {};
	frame.queue[object] = true;

	if(object.OldTexture) then
		object:SetTexture(object.OldTexture);
	end
end

function mod:StyleFrame(parent, noBackdrop, point)
	point = point or parent;
	local noscalemult = E.mult * UIParent:GetScale();

	if(point.bordertop) then return; end

	if(not noBackdrop) then
		point.backdrop = parent:CreateTexture(nil, "BACKGROUND");
		point.backdrop:SetAllPoints(point);
		point.backdrop:SetTexture(unpack(E["media"].backdropfadecolor));
	end

	if(E.PixelMode) then
		point.bordertop = parent:CreateTexture(nil, "BORDER");
		point.bordertop:SetPoint("TOPLEFT", point, "TOPLEFT", -noscalemult, noscalemult);
		point.bordertop:SetPoint("TOPRIGHT", point, "TOPRIGHT", noscalemult, noscalemult);
		point.bordertop:SetHeight(noscalemult);
		point.bordertop:SetTexture(unpack(E["media"].bordercolor));

		point.borderbottom = parent:CreateTexture(nil, "BORDER");
		point.borderbottom:SetPoint("BOTTOMLEFT", point, "BOTTOMLEFT", -noscalemult, -noscalemult);
		point.borderbottom:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", noscalemult, -noscalemult)
		point.borderbottom:SetHeight(noscalemult);
		point.borderbottom:SetTexture(unpack(E["media"].bordercolor));

		point.borderleft = parent:CreateTexture(nil, "BORDER");
		point.borderleft:SetPoint("TOPLEFT", point, "TOPLEFT", -noscalemult, noscalemult);
		point.borderleft:SetPoint("BOTTOMLEFT", point, "BOTTOMLEFT", noscalemult, -noscalemult);
		point.borderleft:SetWidth(noscalemult);
		point.borderleft:SetTexture(unpack(E["media"].bordercolor));

		point.borderright = parent:CreateTexture(nil, "BORDER");
		point.borderright:SetPoint("TOPRIGHT", point, "TOPRIGHT", noscalemult, noscalemult);
		point.borderright:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", -noscalemult, -noscalemult);
		point.borderright:SetWidth(noscalemult);
		point.borderright:SetTexture(unpack(E["media"].bordercolor));
	else
		point.bordertop = parent:CreateTexture(nil, "OVERLAY");
		point.bordertop:SetPoint("TOPLEFT", point, "TOPLEFT", -noscalemult*2, noscalemult*2);
		point.bordertop:SetPoint("TOPRIGHT", point, "TOPRIGHT", noscalemult*2, noscalemult*2);
		point.bordertop:SetHeight(noscalemult);
		point.bordertop:SetTexture(unpack(E.media.bordercolor));

		point.bordertop.backdrop = parent:CreateTexture(nil, "BORDER")
		point.bordertop.backdrop:SetPoint("TOPLEFT", point.bordertop, "TOPLEFT", -noscalemult, noscalemult);
		point.bordertop.backdrop:SetPoint("TOPRIGHT", point.bordertop, "TOPRIGHT", noscalemult, noscalemult);
		point.bordertop.backdrop:SetHeight(noscalemult * 3);
		point.bordertop.backdrop:SetTexture(0, 0, 0);

		point.borderbottom = parent:CreateTexture(nil, "OVERLAY");
		point.borderbottom:SetPoint("BOTTOMLEFT", point, "BOTTOMLEFT", -noscalemult*2, -noscalemult*2);
		point.borderbottom:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", noscalemult*2, -noscalemult*2);
		point.borderbottom:SetHeight(noscalemult);
		point.borderbottom:SetTexture(unpack(E.media.bordercolor));

		point.borderbottom.backdrop = parent:CreateTexture(nil, "BORDER");
		point.borderbottom.backdrop:SetPoint("BOTTOMLEFT", point.borderbottom, "BOTTOMLEFT", -noscalemult, -noscalemult);
		point.borderbottom.backdrop:SetPoint("BOTTOMRIGHT", point.borderbottom, "BOTTOMRIGHT", noscalemult, -noscalemult);
		point.borderbottom.backdrop:SetHeight(noscalemult * 3);
		point.borderbottom.backdrop:SetTexture(0, 0, 0);

		point.borderleft = parent:CreateTexture(nil, "OVERLAY");
		point.borderleft:SetPoint("TOPLEFT", point, "TOPLEFT", -noscalemult*2, noscalemult*2);
		point.borderleft:SetPoint("BOTTOMLEFT", point, "BOTTOMLEFT", noscalemult*2, -noscalemult*2);
		point.borderleft:SetWidth(noscalemult);
		point.borderleft:SetTexture(unpack(E.media.bordercolor));

		point.borderleft.backdrop = parent:CreateTexture(nil, "BORDER");
		point.borderleft.backdrop:SetPoint("TOPLEFT", point.borderleft, "TOPLEFT", -noscalemult, noscalemult);
		point.borderleft.backdrop:SetPoint("BOTTOMLEFT", point.borderleft, "BOTTOMLEFT", -noscalemult, -noscalemult);
		point.borderleft.backdrop:SetWidth(noscalemult * 3);
		point.borderleft.backdrop:SetTexture(0, 0, 0);

		point.borderright = parent:CreateTexture(nil, "OVERLAY");
		point.borderright:SetPoint("TOPRIGHT", point, "TOPRIGHT", noscalemult*2, noscalemult*2);
		point.borderright:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", -noscalemult*2, -noscalemult*2);
		point.borderright:SetWidth(noscalemult);
		point.borderright:SetTexture(unpack(E.media.bordercolor));

		point.borderright.backdrop = parent:CreateTexture(nil, "BORDER");
		point.borderright.backdrop:SetPoint("TOPRIGHT", point.borderright, "TOPRIGHT", noscalemult, noscalemult);
		point.borderright.backdrop:SetPoint("BOTTOMRIGHT", point.borderright, "BOTTOMRIGHT", noscalemult, -noscalemult);
		point.borderright.backdrop:SetWidth(noscalemult * 3);
		point.borderright.backdrop:SetTexture(0, 0, 0);
	end
end

do
	local PolledHideIn;
	local Framelist = {};
	local Watcherframe = CreateFrame("Frame");
	local WatcherframeActive = false;
	local select = select;
	local timeToUpdate = 0;

	local function CheckFramelist(self)
		local curTime = GetTime();
		if(curTime < timeToUpdate) then return; end
		local framecount = 0;
		timeToUpdate = curTime + AURA_UPDATE_INTERVAL;

		for frame, expiration in pairs(Framelist) do
			if(expiration < curTime) then
				frame:Hide();
				Framelist[frame] = nil;
			else
				if(frame.Poll) then
					frame.Poll(mod, frame, expiration);
				end
				framecount = framecount + 1;
			end
		end

		if(framecount == 0) then
			Watcherframe:SetScript("OnUpdate", nil);
			WatcherframeActive = false;
		end
	end

	function PolledHideIn(frame, expiration)
		if(not frame) then return; end
		if(expiration == 0) then
			frame:Hide();
			Framelist[frame] = nil;
		else
			Framelist[frame] = expiration;
			frame:Show();

			if(not WatcherframeActive) then
				Watcherframe:SetScript("OnUpdate", CheckFramelist);
				WatcherframeActive = true;
			end
		end
	end

	mod.PolledHideIn = PolledHideIn;
end

function mod:GetSpellDuration(spellID)
	if(spellID) then return self.CachedAuraDurations[spellID]; end
end

function mod:SetSpellDuration(spellID, duration)
	if(spellID) then self.CachedAuraDurations[spellID] = duration; end
end

function mod:UpdateAuraTime(frame, expiration)
	local timeleft = expiration - GetTime();
	local timervalue, formatid = E:GetTimeInfo(timeleft, 4);
	local format = E.TimeFormats[3][2];
	if(timervalue < 4) then
		format = E.TimeFormats[4][2];
	end
	frame.timeLeft:SetFormattedText(("%s%s|r"):format(TimeColors[formatid], format), timervalue);
end

function mod:ClearAuraContext(frame)
	AuraList[frame] = nil;
end

function mod:RemoveAuraInstance(guid, spellID, caster)
	if(guid and spellID and self.AuraList[guid]) then
		local instanceID = tostring(guid) .. tostring(spellID) .. (tostring(caster or "UNKNOWN_CASTER"));
		local auraID = spellID .. (tostring(caster or "UNKNOWN_CASTER"));
		if(self.AuraList[guid][auraID]) then
			self.AuraSpellID[instanceID] = nil;
			self.AuraExpiration[instanceID] = nil;
			self.AuraStacks[instanceID] = nil;
			self.AuraCaster[instanceID] = nil;
			self.AuraDuration[instanceID] = nil;
			self.AuraTexture[instanceID] = nil;
			self.AuraType[instanceID] = nil;
			self.AuraTarget[instanceID] = nil;
			self.AuraList[guid][auraID] = nil;
		end
	end
end

function mod:GetAuraList(guid)
	if(guid and self.AuraList[guid]) then return self.AuraList[guid]; end
end

function mod:GetAuraInstance(guid, auraID)
	if(guid and auraID) then
		local instanceID = guid .. auraID;
		return self.AuraSpellID[instanceID], self.AuraExpiration[instanceID], self.AuraStacks[instanceID], self.AuraCaster[instanceID], self.AuraDuration[instanceID], self.AuraTexture[instanceID], self.AuraType[instanceID], self.AuraTarget[instanceID];
	end
end

function mod:SetAuraInstance(guid, spellID, expiration, stacks, caster, duration, texture, auraType, auraTarget)
	local filter = false;
	local db = self.db.buffs;
	if(auraType == AURA_TYPE_DEBUFF) then
		db = self.db.debuffs;
	end

	if(db.filters.personal and caster == UnitGUID("player")) then
		filter = true;
	end

	local trackFilter = E.global["unitframe"]["aurafilters"][db.filters.filter];
	if(db.filters.filter and trackFilter) then
		local name = GetSpellInfo(spellID);
		local spellList = trackFilter.spells;
		local type = trackFilter.type;
		if(type == "Blacklist") then
			if(spellList[name] and spellList[name].enable) then
				filter = false;
			end
		else
			if(spellList[name] and spellList[name].enable) then
				filter = true;
			end
		end
	end

	if(E.global.unitframe.InvalidSpells[spellID]) then
		filter = false;
	end

	if(filter ~= true) then
		return;
	end

	if(guid and spellID and caster and texture) then
		local auraID = spellID .. (tostring(caster or "UNKNOWN_CASTER"));
		local instanceID = guid .. auraID;
		self.AuraList[guid] = self.AuraList[guid] or {};
		self.AuraList[guid][auraID] = instanceID;
		self.AuraSpellID[instanceID] = spellID;
		self.AuraExpiration[instanceID] = expiration;
		self.AuraStacks[instanceID] = stacks;
		self.AuraCaster[instanceID] = caster;
		self.AuraDuration[instanceID] = duration;
		self.AuraTexture[instanceID] = texture;
		self.AuraType[instanceID] = auraType;
		self.AuraTarget[instanceID] = auraTarget;
	end
end

function mod:WipeAuraList(guid)
	if(guid and self.AuraList[guid]) then
		local unitAuraList = self.AuraList[guid];
		for auraID, instanceID in pairs(unitAuraList) do
			self.AuraSpellID[instanceID] = nil;
			self.AuraExpiration[instanceID] = nil;
			self.AuraStacks[instanceID] = nil;
			self.AuraCaster[instanceID] = nil;
			self.AuraDuration[instanceID] = nil;
			self.AuraTexture[instanceID] = nil;
			self.AuraType[instanceID] = nil;
			self.AuraTarget[instanceID] = nil;
			unitAuraList[auraID] = nil;
		end
	end
end

function mod:CheckRaidIcon(frame)
	if(frame.oldRaidIcon:IsShown()) then
		local ux, uy = frame.oldRaidIcon:GetTexCoord();
		frame.raidIconType = self.RaidIconCoordinate[ux][uy];
	else
		frame.raidIconType = nil;
	end
end

function mod:SearchNameplateByGUID(guid)
	for frame in pairs(self.CreatedPlates) do
		if(frame and frame:IsShown() and frame.guid == guid) then
			return frame;
		end
	end
end

function mod:SearchNameplateByName(sourceName)
	if(not sourceName) then return; end
	local SearchFor = strsplit("-", sourceName)
	for frame in pairs(self.CreatedPlates) do
		if(frame and frame:IsShown() and frame.nameText == SearchFor and RAID_CLASS_COLORS[frame.unitType]) then
			return frame;
		end
	end
end

function mod:SearchNameplateByIconName(raidIcon)
	for frame in pairs(self.CreatedPlates) do
		self:CheckRaidIcon(frame)
		if(frame and frame:IsShown() and frame.oldRaidIcon:IsShown() and (frame.raidIconType == raidIcon)) then
			return frame
		end
	end
end

function mod:SearchForFrame(guid, raidIcon, name)
	local frame;
	if(guid) then frame = self:SearchNameplateByGUID(guid); end
	if((not frame) and name) then frame = self:SearchNameplateByName(name); end
	if((not frame) and raidIcon) then frame = self:SearchNameplateByIconName(raidIcon); end

	return frame;
end

function mod:PLAYER_REGEN_DISABLED()
	if(self.db.showFriendlyCombat == "TOGGLE_ON") then
		SetCVar("nameplateShowFriends", 1);
	elseif(self.db.showFriendlyCombat == "TOGGLE_OFF") then
		SetCVar("nameplateShowFriends", 0);
	end

	if(self.db.showEnemyCombat == "TOGGLE_ON") then
		SetCVar("nameplateShowEnemies", 1);
	elseif(self.db.showEnemyCombat == "TOGGLE_OFF") then
		SetCVar("nameplateShowEnemies", 0);
	end

end

function mod:PLAYER_REGEN_ENABLED()
	if(self.db.showFriendlyCombat == "TOGGLE_ON") then
		SetCVar("nameplateShowFriends", 0);
	elseif(self.db.showFriendlyCombat == "TOGGLE_OFF") then
		SetCVar("nameplateShowFriends", 1);
	end

	if(self.db.showEnemyCombat == "TOGGLE_ON") then
		SetCVar("nameplateShowEnemies", 0);
	elseif(self.db.showEnemyCombat == "TOGGLE_OFF") then
		SetCVar("nameplateShowEnemies", 1);
	end
end

function mod:PLAYER_ENTERING_WORLD()
	twipe(self.Healers);
	twipe(self.ComboPoints);
	local inInstance, instanceType = IsInInstance();
	if inInstance and instanceType == "pvp" --[[and self.db.raidHealIcon.markHealers]] then
		self.CheckHealerTimer = self:ScheduleRepeatingTimer("CheckBGHealers", 3);
		self:CheckBGHealers();
	else
		if(self.CheckHealerTimer) then
			self:CancelTimer(self.CheckHealerTimer);
			self.CheckHealerTimer = nil;
		end
	end
end

local PET = COMBATLOG_OBJECT_TYPE_PET;
local HOSTILE_OUTSIDER = bit.bor(COMBATLOG_OBJECT_AFFILIATION_OUTSIDER, COMBATLOG_OBJECT_REACTION_HOSTILE);
function mod:COMBAT_LOG_EVENT_UNFILTERED(_, _, event, ...)
	local sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellID, spellName, _, auraType, stackCount = ...;
	if(event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH" or event == "SPELL_AURA_APPLIED_DOSE" or event == "SPELL_AURA_REMOVED_DOSE" or event == "SPELL_AURA_BROKEN" or event == "SPELL_AURA_BROKEN_SPELL" or event == "SPELL_AURA_REMOVED") then
		if(event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH") then
			local duration = self:GetSpellDuration(spellID);
			local texture = GetSpellTexture(spellID);
			self:SetAuraInstance(destGUID, spellID, GetTime() + (duration or 0), 1, sourceGUID, duration, texture, auraType, AURA_TARGET_HOSTILE);
		elseif event == "SPELL_AURA_APPLIED_DOSE" or event == "SPELL_AURA_REMOVED_DOSE" then
			local duration = self:GetSpellDuration(spellID);
			local texture = GetSpellTexture(spellID);
			self:SetAuraInstance(destGUID, spellID, GetTime() + (duration or 0), stackCount, sourceGUID, duration, texture, auraType, AURA_TARGET_HOSTILE);
		elseif(event == "SPELL_AURA_BROKEN" or event == "SPELL_AURA_BROKEN_SPELL" or event == "SPELL_AURA_REMOVED") then
			self:RemoveAuraInstance(destGUID, spellID, sourceGUID);
		end

		local name, raidIcon;
		if(band(destFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0 and destName) then
			local rawName = strsplit("-", destName);
			self.ByName[rawName] = destGUID;
			name = rawName;
		end

		for iconName, bitmask in pairs(self.RaidTargetReference) do
			if(band(destFlags, bitmask) > 0) then
				self.ByRaidIcon[iconName] = destGUID;
				raidIcon = iconName;
				break;
			end
		end

		local frame = self:SearchForFrame(destGUID, raidIcon, name);
		if(frame) then
			self:UpdateElement_Auras(frame);
		end
	end

	local inInstance, instanceType = IsInInstance();
	if inInstance and instanceType == "arena" and sourceName --[[and self.db.raidHealIcon.markHealers]] then
		if(not band(sourceFlags, HOSTILE_OUTSIDER) ~= HOSTILE_OUTSIDER or band(destFlags, PET) == PET) then
			if(event:sub(-5) == "_HEAL" and sourceGUID ~= destGUID) then
				self.Healers[sourceName] = true;
			end
		end
	end
end

function mod:UNIT_AURA(event, unit)
	if(unit == "target") then
		self:UpdateElement_AurasByUnitID("target");
	elseif(unit == "focus") then
		self:UpdateElement_AurasByUnitID("focus");
	end
end

function mod:PLAYER_TARGET_CHANGED()
	targetIndicator:Hide();
	if(UnitExists("target")) then
		self.targetName = UnitName("target");
		WorldFrame.elapsed = 0.1;
		mod.NumTargetChecks = 0;
		targetAlpha = E.db.nameplate.targetAlpha;
	else
		targetIndicator:Hide();
		self.targetName = nil;
		targetAlpha = 1;
	end
end

function mod:UPDATE_MOUSEOVER_UNIT()
	WorldFrame.elapsed = 0.1;
end

function mod:UNIT_COMBO_POINTS(event, unit)
	if(unit == "player" or unit == "vehicle") then
		self:UpdateElement_CPointsByUnitID("target");
	end
end

function mod:Initialize()
	self.db = E.db["nameplate"];
	if(E.private["nameplate"].enable ~= true) then return; end

	self.PlateParent = CreateFrame("Frame", nil, WorldFrame);
	self.PlateParent:SetFrameStrata("BACKGROUND");
	self.PlateParent:SetFrameLevel(0);
	WorldFrame:HookScript("OnUpdate", self.OnUpdate);
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	self:RegisterEvent("PLAYER_REGEN_ENABLED");
	self:RegisterEvent("PLAYER_REGEN_DISABLED");
	self:RegisterEvent("UNIT_AURA");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
	self:RegisterEvent("UNIT_COMBO_POINTS");

	self.arrowIndicator = CreateFrame("Frame", nil, WorldFrame);
	self.arrowIndicator.arrow = self.arrowIndicator:CreateTexture(nil, "BORDER");
	self.arrowIndicator.arrow:SetTexture([[Interface\AddOns\ElvUI\media\textures\nameplateTargetIndicator.tga]]);
	self.arrowIndicator:Hide();

	self.doubleArrowIndicator = CreateFrame("Frame", nil, WorldFrame);
	self.doubleArrowIndicator.left = self.doubleArrowIndicator:CreateTexture(nil, "BORDER");
	self.doubleArrowIndicator.left:SetTexture([[Interface\AddOns\ElvUI\media\textures\nameplateTargetIndicatorLeft.tga]]);
	self.doubleArrowIndicator.right = self.doubleArrowIndicator:CreateTexture(nil, "BORDER");
	self.doubleArrowIndicator.right:SetTexture([[Interface\AddOns\ElvUI\media\textures\nameplateTargetIndicatorRight.tga]]);
	self.doubleArrowIndicator:Hide();

	self.glowIndicator = CreateFrame("Frame", nil, WorldFrame);
	self.glowIndicator:SetFrameLevel(0);
	self.glowIndicator:SetFrameStrata("BACKGROUND");
	self.glowIndicator:SetBackdrop( {
 		edgeFile = LSM:Fetch("border", "ElvUI GlowBorder"), edgeSize = 3,
 		insets = {left = 5, right = 5, top = 5, bottom = 5}
 	});
	self.glowIndicator:SetBackdropColor(0, 0, 0, 0);
	self.glowIndicator:SetScale(E.PixelMode and 2.5 or 3);
	self.glowIndicator:Hide();

	self:SetTargetIndicator();
	self.viewPort = IsAddOnLoaded("SunnArt");

	E.NamePlates = self;
end

E:RegisterModule(mod:GetName());