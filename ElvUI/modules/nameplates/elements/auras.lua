local E, L, V, P, G = unpack(select(2, ...));
local mod = E:GetModule("NamePlates")
local LSM = LibStub("LibSharedMedia-3.0")

local select, unpack, pairs = select, unpack, pairs;
local tonumber = tonumber;
local tinsert = table.insert;
local gsub = string.gsub;

local CreateFrame = CreateFrame;
local UnitAura = UnitAura;
local UnitGUID = UnitGUID;
local RAID_CLASS_COLORS = RAID_CLASS_COLORS;

local auraCache = {};

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

function mod:SetAura(aura, icon, count, expirationTime)
	aura.icon:SetTexture(icon);
	if(count > 1) then
		aura.count:SetText(count);
	else
		aura.count:SetText("");
	end
	aura:Show();
	mod.PolledHideIn(aura, expirationTime);
end

function mod:HideAuraIcons(auras)
	for i = 1, #auras.icons do
		self.PolledHideIn(auras.icons[i], 0);
	end
end

function mod:UpdateElement_Auras(frame)
	local guid = frame.guid;

	if(not guid) then
		if(RAID_CLASS_COLORS[frame.unitType]) then
			local name = gsub(frame.oldName:GetText(), "%s%(%*%)","");
			guid = self.ByName[name];
		elseif(frame.RaidIcon:IsShown()) then
			guid = self.ByRaidIcon[frame.raidIconType];
		end

		if(guid) then
			frame.guid = guid;
		else
			return;
		end
	end

	local hasBuffs = false;
	local hasDebuffs = false;
	local aurasOnUnit = self:GetAuraList(guid);

	if(aurasOnUnit) then
		for instanceid in pairs(aurasOnUnit) do
			local aura = {};
			aura.spellID, aura.name, aura.expirationTime, aura.count, aura.caster, aura.duration, aura.icon, aura.type, aura.target = self:GetAuraInstance(guid, instanceid);
			if(tonumber(aura.spellID)) then
				aura.unit = frame.unit;
				if(aura.expirationTime > GetTime()) then
					if(aura.type == "BUFF") then
						tinsert(self.BuffCache, aura);
					else
						tinsert(self.DebuffCache, aura);
					end
				end
			end
		end
	end

	local index = 1;
	local frameNum = 1;
	local maxAuras = #frame.Debuffs.icons;
	local maxDuration = self.db.debuffs.filters.maxDuration;

	self:HideAuraIcons(frame.Debuffs);
	if(self.db.debuffs.enable) then
		while(frameNum <= maxAuras) do
			local cachedaura = self.DebuffCache[index];
			if(cachedaura and cachedaura.spellID and cachedaura.expirationTime and cachedaura.duration <= maxDuration) then
				self:SetAura(frame.Debuffs.icons[frameNum], cachedaura.icon, cachedaura.count, cachedaura.expirationTime);
				frameNum = frameNum + 1;
				hasDebuffs = true;
			else
				break;
			end
			index = index + 1;
		end
	end

	index = 1;
	frameNum = 1;
	maxAuras = #frame.Buffs.icons;
	maxDuration = self.db.buffs.filters.maxDuration;

	self:HideAuraIcons(frame.Buffs);
	if(self.db.buffs.enable) then
		while(frameNum <= maxAuras) do
			local cachedaura = self.BuffCache[index];
			if(cachedaura and cachedaura.spellID and cachedaura.expirationTime and cachedaura.duration <= maxDuration) then
				self:SetAura(frame.Buffs.icons[frameNum], cachedaura.icon, cachedaura.count, cachedaura.expirationTime);
				frameNum = frameNum + 1;
				hasBuffs = true;
			else
				break;
			end
			index = index + 1
		end
	end

	self.DebuffCache = wipe(self.DebuffCache);
	self.BuffCache = wipe(self.BuffCache);

	local TopLevel = frame.HealthBar;
	local TopOffset = select(2, frame.Name:GetFont()) + 5 or 0;
	if(hasDebuffs) then
		TopOffset = TopOffset + 3;
		frame.Debuffs:SetPoint("BOTTOMLEFT", TopLevel, "TOPLEFT", 0, TopOffset);
		frame.Debuffs:SetPoint("BOTTOMRIGHT", TopLevel, "TOPRIGHT", 0, TopOffset);
		TopLevel = frame.Debuffs;
		TopOffset = 3;
	end

	if(hasBuffs) then
		if(not hasDebuffs) then
			TopOffset = TopOffset + 3;
		end
		frame.Buffs:SetPoint("BOTTOMLEFT", TopLevel, "TOPLEFT", 0, TopOffset);
		frame.Buffs:SetPoint("BOTTOMRIGHT", TopLevel, "TOPRIGHT", 0, TopOffset);
		TopLevel = frame.Buffs;
		TopOffset = 3;
	end
end

function mod:UpdateElement_AurasByUnitID(unit)
	local guid = UnitGUID(unit);
	self:WipeAuraList(guid);

	local index = 1;
	local name, _, texture, count, _, duration, expirationTime, unitCaster, _, _, spellID = UnitAura(unit, index, "HARMFUL");
	while(name) do
		self:SetSpellDuration(spellID, duration);
		self:SetAuraInstance(guid, name, spellID, expirationTime, count, UnitGUID(unitCaster or ""), duration, texture, AURA_TYPE_DEBUFF);
		index = index + 1;
		name , _, texture, count, _, duration, expirationTime, unitCaster, _, _, spellID = UnitAura(unit, index, "HARMFUL");
	end

	index = 1;
	local name, _, texture, count, _, duration, expirationTime, unitCaster, _, _, spellID = UnitAura(unit, index, "HELPFUL");
	while(name) do
		self:SetSpellDuration(spellID, duration);
		self:SetAuraInstance(guid, name, spellID, expirationTime, count, UnitGUID(unitCaster or ""), duration, texture, AURA_TYPE_BUFF);
		index = index + 1;
		name, _, texture, count, _, duration, expirationTime, unitCaster, _, _, spellID = UnitAura(unit, index, "HELPFUL");
	end

	local raidIcon, name;
	if(UnitPlayerControlled(unit)) then name = UnitName(unit); end
	raidIcon = RaidIconIndex[GetRaidTargetIndex(unit) or ""];
	if(raidIcon) then self.ByRaidIcon[raidIcon] = guid; end

	local frame = self:SearchForFrame(guid, raidIcon, name);
	if(frame) then
		self:UpdateElement_Auras(frame);
	end
end

function mod:UpdateElement_AurasByLookup(guid)
 	if(guid == UnitGUID("target")) then
		self:UpdateElement_AurasByUnitID("target");
	elseif(guid == UnitGUID("mouseover")) then
		self:UpdateElement_AurasByUnitID("mouseover");
	end
end

function mod:CreateAuraIcon(parent)
	local aura = CreateFrame("Frame", nil, parent);
	self:StyleFrame(aura, true);

	aura.icon = aura:CreateTexture(nil, "OVERLAY");
	aura.icon:SetAllPoints();
	aura.icon:SetTexCoord(unpack(E.TexCoords));

	aura.timeLeft = aura:CreateFontString(nil, "OVERLAY");
	aura.timeLeft:SetPoint("TOPLEFT", 2, 2);
	aura.timeLeft:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline);

	aura.count = aura:CreateFontString(nil, "OVERLAY");
	aura.count:SetPoint("BOTTOMRIGHT");
	aura.count:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline);
	aura.Poll = parent.PollFunction;

	return aura;
end

function mod:Auras_SizeChanged(width)
	local numAuras = #self.icons;
	for i = 1, numAuras do
		self.icons[i]:SetWidth((width - (E.mult*numAuras)) / numAuras);
		self.icons[i]:SetHeight((self.db.baseHeight or 18) * --[[self:GetParent().HealthBar.currentScale or ]] 1);
	end
end

function mod:UpdateAuraIcons(auras)
	local maxAuras = auras.db.numAuras;
	local numCurrentAuras = #auras.icons;
	if(numCurrentAuras > maxAuras) then
		for i = maxAuras, numCurrentAuras do
			tinsert(auraCache, auras.icons[i]);
			auras.icons[i]:Hide();
			auras.icons[i] = nil;
		end
	end

	if(numCurrentAuras ~= maxAuras) then
		self.Auras_SizeChanged(auras, auras:GetWidth(), auras:GetHeight());
	end

	for i = 1, maxAuras do
		auras.icons[i] = auras.icons[i] or tremove(auraCache) or mod:CreateAuraIcon(auras);
		auras.icons[i]:SetParent(auras);
		auras.icons[i]:ClearAllPoints();
		auras.icons[i]:Hide();
		auras.icons[i]:SetHeight(auras.db.baseHeight or 18);

		if(auras.side == "LEFT") then
			if(i == 1) then
				auras.icons[i]:SetPoint("BOTTOMLEFT", auras, "BOTTOMLEFT");
			else
				auras.icons[i]:SetPoint("LEFT", auras.icons[i-1], "RIGHT", E.Border + E.Spacing*3, 0);
			end
		else
			if(i == 1) then
				auras.icons[i]:SetPoint("BOTTOMRIGHT", auras, "BOTTOMRIGHT");
			else
				auras.icons[i]:SetPoint("RIGHT", auras.icons[i-1], "LEFT", -(E.Border + E.Spacing*3), 0);
			end
		end
	end
end

function mod:ConstructElement_Auras(frame, side)
	local auras = CreateFrame("Frame", nil, frame);
	auras:SetFrameStrata("BACKGROUND");

	auras:SetScript("OnSizeChanged", mod.Auras_SizeChanged);
	auras:SetHeight(18);
	auras.side = side;
	auras.PollFunction = mod.UpdateAuraTime;
	auras.icons = {};

	return auras;
end