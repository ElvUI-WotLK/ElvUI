local parent, ns = ...
local oUF = ns.oUF

local _FRAMES = {}
local OnRangeFrame

local UnitIsConnected = UnitIsConnected
local tinsert, tremove, twipe = table.insert, table.remove, table.wipe

local friendlySpells, resSpells, longEnemySpells, enemySpells, petSpells = {}, {}, {}, {}, {}

local function AddSpell(table, spellID)
	local name = GetSpellInfo(spellID)
	if name then
		local usable, nomana = IsUsableSpell(name)
		if usable or nomana then
			table[#table + 1] = name
		end
	end
end

local _,class = UnitClass("player")
local function UpdateSpellList()
	twipe(friendlySpells)
	twipe(resSpells)
	twipe(longEnemySpells)
	twipe(enemySpells)
	twipe(petSpells)
	
	if class == "PRIEST" then
		AddSpell(enemySpells, 585) -- Smite
		AddSpell(longEnemySpells, 589) -- Shadow Word: Pain
		AddSpell(friendlySpells, 2061) -- Flash Heal
		AddSpell(resSpells, 2006) -- Resurrection
	elseif class == "DRUID" then
		AddSpell(enemySpells, 33786) -- Cyclone
		AddSpell(longEnemySpells, 5176) -- Wrath
		AddSpell(friendlySpells, 774) -- Rejuvenation
		AddSpell(resSpells, 50769) -- Revive 
		AddSpell(resSpells, 20484) -- Rebirth 
	elseif class == "PALADIN" then
		AddSpell(enemySpells, 20271) -- Judgement
		AddSpell(friendlySpells, 635) -- Holy Light
		AddSpell(resSpells, 7328) -- Redemption
	elseif class == "SHAMAN" then
		AddSpell(enemySpells, 8042) -- Earth Shock 
		AddSpell(longEnemySpells, 403) -- Lightning Bolt
		AddSpell(friendlySpells, 8004) -- Healing Surge
		AddSpell(resSpells, 2008) -- Ancestral Spirit 
	elseif class == "WARLOCK" then
		AddSpell(enemySpells, 5782) -- Страх
		AddSpell(longEnemySpells, 172) -- Порча
		AddSpell(longEnemySpells, 686) -- Стрела тьмы
		AddSpell(longEnemySpells, 17962) -- Поджигание
		AddSpell(petSpells, 755) -- Канал здоровья
		AddSpell(friendlySpells, 5697) -- Бесконечное дыхание
	elseif class == "MAGE" then
		AddSpell(enemySpells, 12826) -- Превращение
		AddSpell(longEnemySpells, 133) -- Огненный шар
		AddSpell(longEnemySpells, 47610) -- Стрела ледяного огня
		AddSpell(friendlySpells, 475) -- Снятие проклятия
	elseif class == "HUNTER" then
		AddSpell(petSpells, 136) -- Лечение питомца
		AddSpell(enemySpells, 75) -- Автоматическая стрельба
	elseif class == "DEATHKNIGHT" then
		AddSpell(enemySpells, 49576) -- Хватка смерти
		AddSpell(friendlySpells, 47541) -- Лик смерти
		AddSpell(resSpells, 61999) -- Воскрешение союзника
	elseif class == "ROGUE" then
		AddSpell(enemySpells, 2094) -- Ослепление
		AddSpell(longEnemySpells, 1725) -- Отвлечение
		AddSpell(friendlySpells, 57934) -- Маленькие хитрость
	elseif class == "WARRIOR" then
		AddSpell(enemySpells, 5246) -- Устрашающий крик
		AddSpell(enemySpells, 11578) -- Рывок
		AddSpell(longEnemySpells, 355) -- Провокация
		AddSpell(friendlySpells, 3411) -- Вмешательство
	end
end

local function getUnit(unit)
	if not unit:find("party") or not unit:find("raid") then
		for i=1, 4 do
			if UnitIsUnit(unit, "party"..i) then
				return "party"..i
			end
		end

		for i=1, 40 do
			if UnitIsUnit(unit, "raid"..i) then
				return "raid"..i
			end
		end
	else
		return unit
	end
end

local function friendlyIsInRange(unit)
	if CheckInteractDistance(unit, 1) then
		return true
	end
	
	if UnitIsDeadOrGhost(unit) and #resSpells > 0 then
		for _, name in ipairs(resSpells) do
			if IsSpellInRange(name, unit) == 1 then
				return true
			end
		end

		return false
	end

	if #friendlySpells == 0 and (UnitInRaid(unit) or UnitInParty(unit)) then
		unit = getUnit(unit)
		return unit and UnitInRange(unit)
	else
		for _, name in ipairs(friendlySpells) do
			if IsSpellInRange(name, unit) == 1 then
				return true
			end
		end
	end
	
	return false
end

local function petIsInRange(unit)
	if CheckInteractDistance(unit, 2) then
		return true
	end
	
	for _, name in ipairs(friendlySpells) do
		if IsSpellInRange(name, unit) == 1 then
			return true
		end
	end
	for _, name in ipairs(petSpells) do
		if IsSpellInRange(name, unit) == 1 then
			return true
		end
	end
	
	return false
end

local function enemyIsInRange(unit)
	if CheckInteractDistance(unit, 2) then
		return true
	end
	
	for _, name in ipairs(enemySpells) do
		if IsSpellInRange(name, unit) == 1 then
			return true
		end
	end
	
	return false
end

local function enemyIsInLongRange(unit)
	for _, name in ipairs(longEnemySpells) do
		if IsSpellInRange(name, unit) == 1 then
			return true
		end
	end
	
	return false
end

-- updating of range.
local timer = 0
local OnRangeUpdate = function(self, elapsed)
	timer = timer + elapsed

	if(timer >= .20) then
		for _, object in next, _FRAMES do
			if(object:IsShown()) then
				local range = object.Range
				local unit = object.unit
				if(unit) then
					if UnitCanAttack("player", unit) then
						if enemyIsInRange(unit) then
							object:SetAlpha(range.insideAlpha)
						elseif enemyIsInLongRange(unit) then
							object:SetAlpha(range.insideAlpha)
						else
							object:SetAlpha(range.outsideAlpha)
						end
					elseif UnitIsUnit(unit, "pet") then
						if petIsInRange(unit) then
							object:SetAlpha(range.insideAlpha)
						else
							object:SetAlpha(range.outsideAlpha)
						end
					else
						if friendlyIsInRange(unit) and UnitIsConnected(unit) then
							object:SetAlpha(range.insideAlpha)
						else
							object:SetAlpha(range.outsideAlpha)
						end
					end
				else
					object:SetAlpha(range.insideAlpha)	
				end
			end
		end

		timer = 0
	end
end

local Enable = function(self)
	local range = self.Range
	if(range and range.insideAlpha and range.outsideAlpha) then
		tinsert(_FRAMES, self)

		if(not OnRangeFrame) then
			OnRangeFrame = CreateFrame"Frame"
			OnRangeFrame:RegisterEvent("LEARNED_SPELL_IN_TAB");
			OnRangeFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
			OnRangeFrame:SetScript("OnUpdate", OnRangeUpdate)
			OnRangeFrame:SetScript("OnEvent", UpdateSpellList)
		end

		OnRangeFrame:Show()

		return true
	end
end

local Disable = function(self)
	local range = self.Range
	if(range) then
		for k, frame in next, _FRAMES do
			if(frame == self) then
				tremove(_FRAMES, k)
				frame:SetAlpha(1)
				break
			end
		end

		if(#_FRAMES == 0) then
			OnRangeFrame:Hide()
		end
	end
end

oUF:AddElement('Range', nil, Enable, Disable)