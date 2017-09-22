local _, ns = ...
local oUF = ns.oUF or oUF

local select, pairs, type = select, pairs, type
local format = string.format
local floor, abs = math.floor, math.abs

local GetTime = GetTime
local GetSpellInfo = GetSpellInfo
local UnitAura = UnitAura

local addon = {}
ns.oUF_RaidDebuffs = addon
oUF_RaidDebuffs = ns.oUF_RaidDebuffs
if not _G.oUF_RaidDebuffs then
	_G.oUF_RaidDebuffs = addon
end

local debuff_data = {}
addon.DebuffData = debuff_data


addon.ShowDispellableDebuff = true
addon.FilterDispellableDebuff = true
addon.MatchBySpellName = false

addon.priority = 10

local function add(spell, priority, stackThreshold)
	if addon.MatchBySpellName and type(spell) == "number" then
		spell = GetSpellInfo(spell)
	end

	if(spell) then
		debuff_data[spell] = {
			priority = (addon.priority + priority),
			stackThreshold = (stackThreshold or 0),
		}
	end
end

function addon:RegisterDebuffs(t)
	for spell, value in pairs(t) do
		if type(t[spell]) == "boolean" then
			local oldValue = t[spell]
			t[spell] = {
				["enable"] = oldValue,
				["priority"] = 0,
				["stackThreshold"] = 0
			}
		else
			if t[spell].enable then
				add(spell, t[spell].priority, t[spell].stackThreshold)
			end
		end
	end
end

function addon:ResetDebuffData()
	wipe(debuff_data)
end

local DispellColor = {
	["Magic"] = {.2, .6, 1},
	["Curse"] = {.6, 0, 1},
	["Disease"] = {.6, .4, 0},
	["Poison"] = {0, .6, 0}
}

local DispellPriority = {
	["Magic"] = 4,
	["Curse"] = 3,
	["Disease"] = 2,
	["Poison"] = 1
}

local DispellFilter
do
	local dispellClasses = {
		["PRIEST"] = {
			["Magic"] = true,
			["Disease"] = true
		},
		["SHAMAN"] = {
			["Poison"] = true,
			["Disease"] = true,
			["Curse"] = true
		},
		["PALADIN"] = {
			["Poison"] = true,
			["Magic"] = true,
			["Disease"] = true
		},
		["MAGE"] = {
			["Curse"] = true
		},
		["DRUID"] = {
			["Curse"] = true,
			["Poison"] = true
		}
	}

	DispellFilter = dispellClasses[select(2, UnitClass("player"))] or {}
end

local function formatTime(s)
	if s > 60 then
		return format("%dm", s/60), s%60
	elseif s < 1 then
		return format("%.1f", s), s - floor(s)
	else
		return format("%d", s), s - floor(s)
	end
end

local function OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed >= 0.1 then
		local timeLeft = self.endTime - GetTime()
		if self.reverse then timeLeft = abs((self.endTime - GetTime()) - self.duration) end
		if timeLeft > 0 then
			local text = formatTime(timeLeft)
			self.time:SetText(text)
		else
			self:SetScript("OnUpdate", nil)
			self.time:Hide()
		end
		self.elapsed = 0
	end
end

local function UpdateDebuff(self, name, icon, count, debuffType, duration, endTime, spellId, stackThreshold)
	local f = self.RaidDebuffs

	if name and (count >= stackThreshold) then
		f.icon:SetTexture(icon)
		f.icon:Show()
		f.duration = duration

		if f.count then
			if count and (count > 1) then
				f.count:SetText(count)
				f.count:Show()
			else
				f.count:SetText("")
				f.count:Hide()
			end
		end

		if spellId and ElvUI[1].ReverseTimer[spellId] then
			f.reverse = true
		else
			f.reverse = nil
		end

		if f.time then
			if duration and (duration > 0) then
				f.endTime = endTime
				f.nextUpdate = 0
				f:SetScript("OnUpdate", OnUpdate)
				f.time:Show()
			else
				f:SetScript("OnUpdate", nil)
				f.time:Hide()
			end
		end

		if f.cd then
			if duration and (duration > 0) then
				f.cd:SetCooldown(endTime - duration, duration)
				f.cd:Show()
			else
				f.cd:Hide()
			end
		end

		local c = DispellColor[debuffType] or ElvUI[1].media.bordercolor;
		f:SetBackdropBorderColor(c[1], c[2], c[3])

		f:Show()
	else
		f:Hide()
	end
end

local function Update(self, event, unit)
	if unit ~= self.unit then return end

	local _, name, icon, count, debuffType, duration, expirationTime, spellId
	local _name, _icon, _count, _dtype, _duration, _endTime, _spellId
	local _priority, priority = 0, 0
	local _stackThreshold = 0

	local i = 0
	while true do
		i = i + 1
		name, _, icon, count, debuffType, duration, expirationTime, _, _, _, spellId = UnitAura(unit, i, "HARMFUL")
		if not name then break end

		--we coudln't dispell if the unit its charmed, or its not friendly
		if addon.ShowDispellableDebuff and (self.RaidDebuffs.showDispellableDebuff ~= false) and debuffType then
			if addon.FilterDispellableDebuff then
				DispellPriority[debuffType] = (DispellPriority[debuffType] or 0) + addon.priority --Make Dispell buffs on top of Boss Debuffs
				priority = DispellFilter[debuffType] and DispellPriority[debuffType] or 0
				if priority == 0 then
					debuffType = nil
				end
			else
				priority = DispellPriority[debuffType] or 0
			end

			if priority > _priority then
				_priority, _name, _icon, _count, _dtype, _duration, _endTime, _spellId = priority, name, icon, count, debuffType, duration, expirationTime, spellId
			end
		end

		local debuff
		if self.RaidDebuffs.onlyMatchSpellID then
			debuff = debuff_data[spellId]
		else
			if debuff_data[spellId] then
				debuff = debuff_data[spellId]
			else
				debuff = debuff_data[name]
			end
		end

		priority = debuff and debuff.priority
		if priority and (priority > _priority) then
			_priority, _name, _icon, _count, _dtype, _duration, _endTime, _spellId = priority, name, icon, count, debuffType, duration, expirationTime, spellId
		end
	end

	if self.RaidDebuffs.forceShow then
		_spellId = 47540
		_name, _, _icon = GetSpellInfo(_spellId)
		_count, _dtype, _duration, _endTime, _stackThreshold = 5, "Magic", 0, 60, 0
	end

	if _name then
		_stackThreshold = debuff_data[addon.MatchBySpellName and _name or _spellId] and debuff_data[addon.MatchBySpellName and _name or _spellId].stackThreshold or _stackThreshold
	end

	UpdateDebuff(self, _name, _icon, _count, _dtype, _duration, _endTime, _spellId, _stackThreshold)

	--Reset the DispellPriority
	DispellPriority = {
		["Magic"] = 4,
		["Curse"] = 3,
		["Disease"] = 2,
		["Poison"] = 1
	}
end

local function Enable(self)
	if self.RaidDebuffs then
		self:RegisterEvent("UNIT_AURA", Update)
		return true
	end
end

local function Disable(self)
	if self.RaidDebuffs then
		self:UnregisterEvent("UNIT_AURA", Update)
		self.RaidDebuffs:Hide()
	end
end

oUF:AddElement("RaidDebuffs", Update, Enable, Disable)