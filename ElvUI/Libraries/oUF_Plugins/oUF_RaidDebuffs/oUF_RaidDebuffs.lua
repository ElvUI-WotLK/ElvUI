local _, ns = ...
local oUF = ns.oUF or oUF

local select, pairs, type = select, pairs, type
local abs = math.abs
local format = string.format
local wipe = table.wipe

local GetSpellInfo = GetSpellInfo
local GetTime = GetTime
local IsSpellKnown = IsSpellKnown
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

	if spell then
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

local playerClass = select(2, UnitClass("player"))

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
			["Curse"] = false
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

	DispellFilter = dispellClasses[playerClass] or {}
end

local specChecked
local function CheckSpec(self, event, levels)
	if event == "CHARACTER_POINTS_CHANGED" and levels > 0 then return end

	if not event then
		if specChecked then return end
		specChecked = true
	else
		specChecked = nil
	end

	if IsSpellKnown(51886) then
		DispellFilter.Curse = true
	else
		DispellFilter.Curse = false
	end
end

local function formatTime(s)
	if s < 10 then
		return format("%.1f", s)
	elseif s > 60 then
		return format("%dm", s / 60)
	else
		return format("%d", s)
	end
end

local function OnUpdate(self, elapsed)
	self.elapsed = self.elapsed + elapsed

	if self.elapsed >= 0.1 then
		local timeLeft

		if self.reverse then
			timeLeft = abs((self.endTime - GetTime()) - self.duration)
		else
			timeLeft = self.endTime - GetTime()
		end

		if timeLeft > 0 then
			self.time:SetText(formatTime(timeLeft))
		else
			self:SetScript("OnUpdate", nil)
			self.time:Hide()
		end

		self.elapsed = 0
	end
end

local function UpdateDebuff(self, name, icon, count, debuffType, duration, endTime, spellId, stackThreshold)
	local element = self.RaidDebuffs

	if name and count >= stackThreshold then
		element.icon:SetTexture(icon)
		element.icon:Show()
		element.duration = duration

		if element.count then
			if count and count > 1 then
				element.count:SetText(count)
				element.count:Show()
			else
				element.count:SetText("")
				element.count:Hide()
			end
		end

		if spellId and ElvUI[1].ReverseTimer[spellId] then
			element.reverse = true
		else
			element.reverse = nil
		end

		if element.time then
			if duration and (duration > 0) then
				element.endTime = endTime
				element.nextUpdate = 0
				element.elapsed = 0
				element:SetScript("OnUpdate", OnUpdate)
				element.time:Show()
			else
				element:SetScript("OnUpdate", nil)
				element.time:Hide()
			end
		end

		if element.cd then
			if duration and (duration > 0) then
				element.cd:SetCooldown(endTime - duration, duration)
				element.cd:Show()
			else
				element.cd:Hide()
			end
		end

		local c = DispellColor[debuffType] or ElvUI[1].media.bordercolor
		element:SetBackdropBorderColor(c[1], c[2], c[3])

		element:Show()
	else
		element:Hide()
	end
end

local function Update(self, event, unit)
	if unit ~= self.unit then return end

	local element = self.RaidDebuffs

	local _name, _icon, _count, _dtype, _duration, _endTime, _spellId
	local _stackThreshold = 0

	if element.forceShow then
		_spellId = 47540
		_name, _, _icon = GetSpellInfo(_spellId)
		_count = 5
		_dtype = "Magic"
		_duration = 0
		_endTime = 60
		_stackThreshold = 0
	else
		local _, name, icon, count, debuffType, duration, expirationTime, spellId
		local _priority, priority = 0

		for i = 1, 40 do
			name, _, icon, count, debuffType, duration, expirationTime, _, _, _, spellId = UnitAura(unit, i, "HARMFUL")
			if not name then break end

			--we couldn't dispell if the unit its charmed, or its not friendly
			if addon.ShowDispellableDebuff and (element.showDispellableDebuff ~= false) and debuffType then
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
			if element.onlyMatchSpellID then
				debuff = debuff_data[spellId]
			else
				if debuff_data[spellId] then
					debuff = debuff_data[spellId]
				else
					debuff = debuff_data[name]
				end
			end

			priority = debuff and debuff.priority

			if priority and priority > _priority then
				_priority, _name, _icon, _count, _dtype, _duration, _endTime, _spellId = priority, name, icon, count, debuffType, duration, expirationTime, spellId
			end
		end
	end

	if _name then
		local data = debuff_data[addon.MatchBySpellName and _name or _spellId]
		_stackThreshold = data and data.stackThreshold or _stackThreshold
	end

	UpdateDebuff(self, _name, _icon, _count, _dtype, _duration, _endTime, _spellId, _stackThreshold)

	--Reset the DispellPriority
	DispellPriority["Magic"] = 4
	DispellPriority["Curse"] = 3
	DispellPriority["Disease"] = 2
	DispellPriority["Poison"] = 1
end

local function Enable(self)
	if self.RaidDebuffs then
		self:RegisterEvent("UNIT_AURA", Update)

		if playerClass == "SHAMAN" then
			self:RegisterEvent("PLAYER_TALENT_UPDATE", CheckSpec)
			self:RegisterEvent("CHARACTER_POINTS_CHANGED", CheckSpec)
			CheckSpec()
		end

		return true
	end
end

local function Disable(self)
	if self.RaidDebuffs then
		self:UnregisterEvent("UNIT_AURA", Update)

		if playerClass == "SHAMAN" then
			self:UnregisterEvent("PLAYER_TALENT_UPDATE", CheckSpec)
			self:UnregisterEvent("CHARACTER_POINTS_CHANGED", CheckSpec)
		end

		self.RaidDebuffs:Hide()
	end
end

oUF:AddElement("RaidDebuffs", Update, Enable, Disable)