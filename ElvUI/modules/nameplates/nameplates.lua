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

mod.HealerSpecs = {
	[L["Restoration"]] = true,
	[L["Holy"]] = true,
	[L["Discipline"]] = true
};

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

function mod:PositionTargetIndicator(myPlate)
	targetIndicator:SetParent(myPlate);
	if(self.db.targetIndicator.style == "arrow") then
		targetIndicator.arrow:ClearAllPoints();
		targetIndicator.arrow:SetPoint("BOTTOM", myPlate.HealthBar, "TOP", 0, 30 + self.db.targetIndicator.yOffset);
	elseif(self.db.targetIndicator.style == "doubleArrow") then
		targetIndicator.left:SetPoint("RIGHT", myPlate.HealthBar, "LEFT", -self.db.targetIndicator.xOffset, 0);
		targetIndicator.right:SetPoint("LEFT", myPlate.HealthBar, "RIGHT", self.db.targetIndicator.xOffset, 0);
		targetIndicator:SetFrameLevel(0);
		targetIndicator:SetFrameStrata("BACKGROUND");
	elseif(self.db.targetIndicator.style == "doubleArrowInverted") then
		targetIndicator.right:SetPoint("RIGHT", myPlate.HealthBar, "LEFT", -self.db.targetIndicator.xOffset, 0);
		targetIndicator.left:SetPoint("LEFT", myPlate.HealthBar, "RIGHT", self.db.targetIndicator.xOffset, 0);
		targetIndicator:SetFrameLevel(0);
		targetIndicator:SetFrameStrata("BACKGROUND");
	elseif(self.db.targetIndicator.style == "glow") then
		targetIndicator:SetOutside(myPlate.HealthBar, 3, 3);
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

			if(not mod.CreatedPlates[frame] and not frame:GetName() and region and region:GetObjectType() == "Texture" and region:GetTexture() == OVERLAY) then
				mod:CreatePlate(frame);
			end
		end
		numChildren = count;
	end

	--mod.PlateParent:Hide()
	for blizzPlate, plate in pairs(mod.CreatedPlates) do
		if(blizzPlate:IsShown()) then
			if(not self.viewPort) then
				plate:SetPoint("CENTER", WorldFrame, "BOTTOMLEFT", blizzPlate:GetCenter());
			end
			mod.SetAlpha(blizzPlate, plate);
		elseif(plate:IsShown()) then
			plate:Hide();
		end
	end
	--mod.PlateParent:Show();

	if(self.elapsed and self.elapsed > 0.2) then
		for blizzPlate, plate in pairs(mod.CreatedPlates) do
			if(blizzPlate:IsShown() and plate:IsShown()) then
				mod.SetUnitInfo(blizzPlate, plate);
				mod.ColorizeAndScale(blizzPlate, plate);
				mod.UpdateLevelAndName(blizzPlate, plate);
				plate:SetDepth(25);
			end
		end

		self.elapsed = 0;
	else
		self.elapsed = (self.elapsed or 0) + elapsed;
	end
end

function mod:CheckFilter(myPlate)
	local name = gsub(self.Name:GetText(), FSPAT, "");
	local db = E.global.nameplate["filter"][name];

	if(db and db.enable) then
		if(db.hide) then
			myPlate:Hide();
			return;
		else
			if(not myPlate:IsShown()) then
				myPlate:Show();
			end

			if(db.customColor) then
				self.customColor = db.color;
				myPlate.HealthBar:SetStatusBarColor(db.color.r, db.color.g, db.color.b);
			else
				self.customColor = nil;
			end

			if(db.customScale and db.customScale ~= 1) then
				myPlate.HealthBar:Height(mod.db.healthBar.height * db.customScale);
				myPlate.HealthBar:Width(mod.db.healthBar.width * db.customScale);
				self.customScale = true;
			else
				self.customScale = nil;
			end
		end
	elseif(not myPlate:IsShown()) then
		myPlate:Show();
	end

	if(mod.Healers[name]) then
		myPlate.HealerIcon:Show();
	else
		myPlate.HealerIcon:Hide();
	end

	return true;
end

function mod:CheckBGHealers()
	local name, _;
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

function mod:CheckArenaHealers()
	for i = 1, 5 do
		local name = UnitName(format("arena%d", i));
		if(name and name ~= UNKNOWN) then
			local talentSpec = E:GetModule("Tooltip"):GetTalentSpec(nil, format("arena%d", i));
			if(talentSpec and self.HealerSpecs[talentSpec]) then
				self.Healers[name] = talentSpec;
			end
		end
	end
end

function mod:UpdateLevelAndName(myPlate)
	if(not mod.db.showLevel) then
		myPlate.Level:SetText("");
		myPlate.Level:Hide();
	else
		local level, elite, boss = self.Level:GetObjectType() == "FontString" and tonumber(self.Level:GetText()) or nil, self.eliteIcon:IsShown(), self.bossIcon:IsShown();
		if(boss) then
			myPlate.Level:SetText("??");
			myPlate.level:SetTextColor(0.8, 0.05, 0);
		elseif(level) then
			myPlate.Level:SetText(level .. (elite and "+" or ""));
			myPlate.Level:SetTextColor(self.Level:GetTextColor());
		end
		
		if(not myPlate.Level:IsShown()) then
			myPlate.Level:Show();
		end
	end

	if(not mod.db.showName) then
		myPlate.Name:SetText("");
		myPlate.Name:Hide();
	else
		myPlate.Name:SetText(self.Name:GetText());
		if(not myPlate.Name:IsShown()) then myPlate.Name:Show(); end
	end

	if(self.RaidIcon:IsShown()) then
		local ux, uy = self.RaidIcon:GetTexCoord();
		if((ux ~= myPlate.RaidIcon.ULx or uy ~= myPlate.RaidIcon.ULy)) then
			myPlate.RaidIcon:Show();
			myPlate.RaidIcon:SetTexCoord(self.RaidIcon:GetTexCoord());
			myPlate.RaidIcon.ULx, myPlate.RaidIcon.ULy = ux, uy;
		end
	elseif(myPlate.RaidIcon:IsShown()) then
		myPlate.RaidIcon:Hide();
	end
end

function mod:GetReaction(frame)
	local r, g, b = self:RoundColors(frame.HealthBar:GetStatusBarColor());
	
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
	if(frame.threat:IsShown()) then
		local r, g, b = frame.threat:GetVertexColor();
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
function mod:ColorizeAndScale(myPlate)
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

	if(mod.db.healthBar.lowHPScale.enable and mod.db.healthBar.lowHPScale.changeColor and myPlate.Glow:IsShown() and canAttack) then
		color = mod.db.healthBar.lowHPScale.color;
	end

	if(not self.customColor) then
		myPlate.HealthBar:SetStatusBarColor(color.r, color.g, color.b);

		if(mod.db.targetIndicator.enable and mod.db.targetIndicator.colorMatchHealthBar and self.unit == "target") then
			mod:ColorTargetIndicator(color.r, color.g, color.b);
		end
	elseif(self.unit == "target" and mod.db.targetIndicator.colorMatchHealthBar and mod.db.targetIndicator.enable) then
		mod:ColorTargetIndicator(self.customColor.r, self.customColor.g, self.customColor.b);
	end

	local w = mod.db.healthBar.width * scale;
	local h = mod.db.healthBar.height * scale;
	if(mod.db.healthBar.lowHPScale.enable) then
		if(myPlate.Glow:IsShown()) then
			w = mod.db.healthBar.lowHPScale.width * scale;
			h = mod.db.healthBar.lowHPScale.height * scale;
			if(mod.db.healthBar.lowHPScale.toFront) then
				myPlate:SetFrameStrata("HIGH");
			end
		else
			if(mod.db.healthBar.lowHPScale.toFront) then
				myPlate:SetFrameStrata("BACKGROUND");
			end
		end
	end

	if(not self.customScale and myPlate.HealthBar:GetWidth() ~= w) then
		myPlate.HealthBar:SetSize(w, h);
		myPlate.CastBar.Icon:SetSize(mod.db.castBar.height + h + 5, mod.db.castBar.height + h + 5);
	end
end

function mod:SetAlpha(myPlate)
	if(self:GetAlpha() < 1) then
		myPlate:SetAlpha(mod.db.nonTargetAlpha);
	else
		myPlate:SetAlpha(targetAlpha);
	end
end

function mod:SetUnitInfo(myPlate)
	local plateName = gsub(self.Name:GetText(), FSPAT,"");
	if(self:GetAlpha() == 1 and mod.targetName and (mod.targetName == plateName)) then
		self.guid = UnitGUID("target");
		self.unit = "target";
		myPlate:SetFrameLevel(2);
		myPlate.overlay:Hide();

		if(mod.db.targetIndicator.enable) then
			targetIndicator:Show();
			mod:PositionTargetIndicator(myPlate);
			targetIndicator:SetDepth(myPlate:GetDepth());
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
	elseif(self.highlight:IsShown() and UnitExists("mouseover") and (UnitName("mouseover") == plateName)) then
		if(self.unit ~= "mouseover") then
			myPlate:SetFrameLevel(1);
			myPlate.overlay:Show();
			mod:UpdateElement_AurasByUnitID("mouseover");
			mod:UpdateElement_CPointsByUnitID("mouseover");
		end
		self.guid = UnitGUID("mouseover");
		self.unit = "mouseover";
		mod:UpdateElement_AurasByUnitID("mouseover");
	else
		myPlate:SetFrameLevel(0);
		myPlate.overlay:Hide();
		self.unit = nil;
	end
end

function mod:UpdateAllPlates()
	if(E.private["nameplate"].enable ~= true) then return; end
	self:ForEachPlate("UpdateSettings");
end

function mod:ForEachPlate(functionToRun, ...)
	for blizzPlate, plate in pairs(self.CreatedPlates) do
		if(blizzPlate) then
			self[functionToRun](blizzPlate, plate, ...);
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
	local myPlate = mod.CreatedPlates[self];
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

	if(not mod.CheckFilter(self, myPlate)) then return; end
	myPlate:SetSize(self:GetSize());

	mod.UpdateLevelAndName(self, myPlate);
	mod.ColorizeAndScale(self, myPlate);

	mod.UpdateElement_HealthOnValueChanged(self.HealthBar, self.HealthBar:GetValue());
	myPlate.nameText = gsub(self.Name:GetText(), FSPAT,"");

	mod:CheckRaidIcon(self);

	if(mod.db.buffs.enable) then
		mod:UpdateAuraIcons(myPlate.Buffs);
	end

	if(mod.db.debuffs.enable) then
		mod:UpdateAuraIcons(myPlate.Debuffs);
	end

	if(mod.db.buffs.enable or mod.db.debuffs.enable) then
		mod:UpdateElement_Auras(self);
	end

	mod:UpdateElement_CPoints(self);

	if(not mod.db.targetIndicator.colorMatchHealthBar) then
		mod:ColorTargetIndicator(mod.db.targetIndicator.color.r, mod.db.targetIndicator.color.g, mod.db.targetIndicator.color.b);
	end
end

function mod:OnHide()
	local myPlate = mod.CreatedPlates[self];
	self.threatReaction = nil;
	self.unitType = nil;
	self.guid = nil;
	self.unit = nil;
	self.raidIconType = nil;
	self.customColor = nil;
	self.customScale = nil;
	self.allowCheck = nil;

	if(targetIndicator:GetParent() == myPlate) then
		targetIndicator:Hide();
	end

	mod:HideAuraIcons(myPlate.Buffs);
	mod:HideAuraIcons(myPlate.Debuffs);
	myPlate.RaidIcon.ULx, myPlate.RaidIcon.ULy = nil, nil;
	myPlate.Glow.r, myPlate.Glow.g, myPlate.Glow.b = nil, nil, nil;
	myPlate.Glow:Hide();

	myPlate:SetAlpha(0);

	mod:HideComboPoints(myPlate);

	--UIFrameFadeOut(myPlate, 0.1, myPlate:GetAlpha(), 0)
	--myPlate:Hide()

	--myPlate:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT") --Prevent nameplate being in random location on screen when first shown
end

function mod:UpdateSettings()
	local myPlate = mod.CreatedPlates[self];

	mod:ConfigureElement_HealthBar(myPlate, self.customScale);
	mod:ConfigureElement_Level(myPlate);
	mod:ConfigureElement_Name(myPlate);
	mod:ConfigureElement_CastBar(myPlate);
	mod:ConfigureElement_RaidIcon(myPlate);
	myPlate.Buffs.db = mod.db.buffs;
	myPlate.Debuffs.db = mod.db.debuffs;
	mod:ConfigureElement_CPoints(myPlate);

	mod.OnShow(self);
end

function mod:CreatePlate(frame)
	frame.HealthBar, frame.CastBar = frame:GetChildren();
	frame.threat, frame.border, frame.CastBar.Shield, frame.CastBar.Border, frame.CastBar.Icon, frame.highlight, frame.Name, frame.Level, frame.bossIcon, frame.RaidIcon, frame.eliteIcon = frame:GetRegions();
	local myPlate = CreateFrame("Frame", nil, self.PlateParent);

	myPlate.hiddenFrame = CreateFrame("Frame", nil, myPlate);
	myPlate.hiddenFrame:Hide();
	
	myPlate.HealthBar = self:ConstructElement_HealthBar(myPlate);
	frame.CastBar.Icon:SetParent(myPlate.hiddenFrame);
	myPlate.CastBar = self:ConstructElement_CastBar(myPlate);
	myPlate.Level = self:ConstructElement_Level(myPlate);
	myPlate.Name = self:ConstructElement_Name(myPlate);
	frame.RaidIcon:SetAlpha(0);
	myPlate.RaidIcon = self:ConstructElement_RaidIcon(myPlate);

	myPlate.overlay = myPlate:CreateTexture(nil, "OVERLAY");
	myPlate.overlay:SetAllPoints(myPlate.HealthBar);
	myPlate.overlay:SetTexture(1, 1, 1, 0.3);
	myPlate.overlay:Hide();

	myPlate.Glow = self:ConstructElement_Glow(myPlate);
	myPlate.Buffs = self:ConstructElement_Auras(myPlate, 5, "RIGHT");
	myPlate.Debuffs = self:ConstructElement_Auras(myPlate, 5, "LEFT");

	myPlate.HealerIcon = self:ConstructElement_HealerIcon(myPlate);
	myPlate.CPoints = self:ConstructElement_CPoints(myPlate);

	frame:HookScript("OnShow", self.OnShow);
	frame:HookScript("OnHide", self.OnHide);
	frame:HookScript("OnSizeChanged", self.OnSizeChanged);
	frame.HealthBar:HookScript("OnValueChanged", self.UpdateElement_HealthOnValueChanged);
	frame.CastBar:HookScript("OnShow", self.UpdateElement_CastBarOnShow);
	frame.CastBar:HookScript("OnHide", self.UpdateElement_CastBarOnHide);
	frame.CastBar:HookScript("OnValueChanged", self.UpdateElement_CastBarOnValueChanged);

	self:QueueObject(frame, frame.HealthBar);
	self:QueueObject(frame, frame.CastBar);
	self:QueueObject(frame, frame.Level);
	self:QueueObject(frame, frame.Name);
	self:QueueObject(frame, frame.threat);
	self:QueueObject(frame, frame.border);
	self:QueueObject(frame, frame.CastBar.Shield);
	self:QueueObject(frame, frame.CastBar.Border);
	self:QueueObject(frame, frame.highlight);
	self:QueueObject(frame, frame.bossIcon);
	self:QueueObject(frame, frame.eliteIcon);
	self:QueueObject(frame, frame.CastBar.Icon);

	self.CreatedPlates[frame] = myPlate;
	self.UpdateSettings(frame);
	if(not frame.CastBar:IsShown()) then
		myPlate.CastBar:Hide();
	else
		self.UpdateElement_CastBarOnShow(frame.CastBar);
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
	if(frame.RaidIcon:IsShown()) then
		local ux, uy = frame.RaidIcon:GetTexCoord();
		frame.raidIconType = self.RaidIconCoordinate[ux][uy];
	else
		frame.raidIconType = nil;
	end
end

function mod:SearchNameplateByGUID(guid)
	for frame, _ in pairs(self.CreatedPlates) do
		if(frame and frame:IsShown() and frame.guid == guid) then
			return frame;
		end
	end
end

function mod:SearchNameplateByName(sourceName)
	if(not sourceName) then return; end
	local SearchFor = strsplit("-", sourceName)
	for frame, myPlate in pairs(self.CreatedPlates) do
		if(frame and frame:IsShown() and myPlate.nameText == SearchFor and RAID_CLASS_COLORS[frame.unitType]) then
			return frame;
		end
	end
end

function mod:SearchNameplateByIconName(raidIcon)
	for frame, _ in pairs(self.CreatedPlates) do
		self:CheckRaidIcon(frame)
		if(frame and frame:IsShown() and frame.RaidIcon:IsShown() and (frame.raidIconType == raidIcon)) then
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
	elseif inInstance and instanceType == "arena" --[[and self.db.raidHealIcon.markHealers]] then
		self:RegisterEvent("UNIT_NAME_UPDATE", "CheckArenaHealers");
	--	self:RegisterEvent("ARENA_OPPONENT_UPDATE", "CheckArenaHealers");
		self:CheckArenaHealers();
	else
		self:UnregisterEvent("UNIT_NAME_UPDATE");
	--	self:UnregisterEvent("ARENA_OPPONENT_UPDATE");
		if(self.CheckHealerTimer) then
			self:CancelTimer(self.CheckHealerTimer);
			self.CheckHealerTimer = nil;
		end
	end
end

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