local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local RBR = E:NewModule('RaidBuffReminder', 'AceEvent-3.0');

E.RaidBuffReminder = RBR

RBR.Spell1Buffs = {
	67016, --"Flask of the North-SP"
	67017, --"Flask of the North-AP"
	67018, --"Flask of the North-STR"
	53758, --"Flask of Stoneblood"
	53755, --"Flask of the Frost Wyrm",
	54212, --"Flask of Pure Mojo",
	53760, --"Flask of Endless Rage",
	17627, --"Flask of Distilled Wisdom", 
}

RBR.BattleElixir = {
	33721, --"Spellpower Elixir",
	53746, --"Wrath Elixir",
	28497, --"Elixir of Mighty Agility",
	53748, --"Elixir of Mighty Strength",
	60346, --"Elixir of Lightning Speed",
	60344, --"Elixir of Expertise",
	60341, --"Elixir of Deadly Strikes",
	60345, --"Elixir of Armor Piercing",
	60340, --"Elixir of Accuracy",
	53749, --"Guru's Elixir",
}
	
RBR.GuardianElixir = {
	60343, --"Elixir of Mighty Defense",
	53751, --"Elixir of Mighty Fortitude",
	53764, --"Elixir of Mighty Mageblood",
	60347, --"Elixir of Mighty Thoughts",
	53763, --"Elixir of Protection",
	53747, --"Elixir of Spirit",
}
	
RBR.Spell2Buffs = {
	57325, -- 80 AP
	57327, -- 46 SP
	57329, -- 40 CS
	57332, -- 40 Haste
	57334, -- 20 MP5
	57356, -- 40 EXP
	57358, -- 40 ARP
	57360, -- 40 Hit
	57363, -- Track Humanoids
	57365, -- 40 Spirit
	57367, -- 40 AGI
	57371, -- 40 STR
	57373, -- Track Beasts
	57399, -- 80AP, 46SP (fish feast)
	59230, -- 40 DODGE
	65247, -- Pet 40 STR
}

RBR.Spell3Buffs = {
	48469, --"Mark of the Wild",
	72588, --"Gift of the Wild",
}

RBR.Spell4Buffs = {
	20217, --"Blessing of Kings",
	25898, --"Greater Blessing of Kings",
}

RBR.CasterSpell5Buffs = {--
	42995, --"Arcane Intellect"
	43002, --"Arcane Brilliance"
	61316, --"Dalaran Brilliance"
}

RBR.MeleeSpell5Buffs = {--
	48161, --"Power Word: Fortitude"
	48162, --"Prayer of Fortitude"
}

RBR.CasterSpell6Buffs = {--
	48936, --"Blessing of Wisdom"
	48938, --"Greater Blessing Of Wisdom"		
	58777, --"Mana Spring Totem"
}

RBR.MeleeSpell6Buffs = {--
	48932, --"Blessing of Might"
	48934, --"Greater Blessing Of Might"
	47436, --"Battle Shout"
}

function RBR:CheckFilterForActiveBuff(filter)
	local spellName, texture
	for _, spell in pairs(filter) do
		spellName, _, texture = GetSpellInfo(spell)
		if UnitAura("player", spellName) then
			return true, texture
		end
	end

	return false, texture
end

function RBR:UpdateReminder(event, unit)
	if (event == "UNIT_AURA" and unit ~= "player") then return end
	local frame = self.frame
	
	if E.Role == 'Caster' then
		self.Spell5Buffs = self.CasterSpell5Buffs
		self.Spell6Buffs = self.CasterSpell6Buffs
	else
		self.Spell5Buffs = self.MeleeSpell5Buffs
		self.Spell6Buffs = self.MeleeSpell6Buffs
	end
	
	local hasFlask, flaskTex = self:CheckFilterForActiveBuff(self.Spell1Buffs)
	if hasFlask then
		frame.spell1.t:SetTexture(flaskTex)
		frame.spell1:SetAlpha(0.2)
	else
		local hasBattle, battleTex = self:CheckFilterForActiveBuff(self.BattleElixir)
		local hasGuardian, guardianTex = self:CheckFilterForActiveBuff(self.GuardianElixir)

		if (hasBattle and hasGuardian) or not hasGuardian and hasBattle then
			frame.spell1:SetAlpha(1)
			frame.spell1.t:SetTexture(battleTex)				
		elseif hasGuardian then
			frame.spell1:SetAlpha(1)
			frame.spell1.t:SetTexture(guardianTex)		
		else
			frame.spell1:SetAlpha(1)
			frame.spell1.t:SetTexture(flaskTex)
		end
	end
	
	for i = 2, 6 do
		local hasBuff, texture = self:CheckFilterForActiveBuff(self['Spell'..i..'Buffs'])
		frame['spell'..i].t:SetTexture(texture)
		if hasBuff then
			frame['spell'..i]:SetAlpha(0.2)
		else
			frame['spell'..i]:SetAlpha(1)
		end
	end
end

function RBR:CreateButton(relativeTo, isFirst, isLast)
	local button = CreateFrame("Frame", name, RaidBuffReminder)
	button:SetTemplate('Default')
	button:Size(E.RBRWidth - (E.PixelMode and 1 or 4))
	if isFirst then
		button:Point("TOP", relativeTo, "TOP", 0, -(E.PixelMode and 0 or 2))
	else
		button:Point("TOP", relativeTo, "BOTTOM", 0, (E.PixelMode and 1 or -1))
	end
	
	if isLast then
		button:Point("BOTTOM", RaidBuffReminder, "BOTTOM", 0, (E.PixelMode and 0 or 2))
	end
	
	button.t = button:CreateTexture(nil, "OVERLAY")
	button.t:SetTexCoord(unpack(E.TexCoords))
	button.t:SetInside()
	button.t:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
	
	return button
end

function RBR:EnableRBR()
	RaidBuffReminder:Show()
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", 'UpdateReminder')
	self:RegisterEvent("UNIT_INVENTORY_CHANGED", 'UpdateReminder')
	self:RegisterEvent("UNIT_AURA", 'UpdateReminder')
	self:RegisterEvent("PLAYER_REGEN_ENABLED", 'UpdateReminder')
	self:RegisterEvent("PLAYER_REGEN_DISABLED", 'UpdateReminder')
	self:RegisterEvent("PLAYER_ENTERING_WORLD", 'UpdateReminder')
	self:RegisterEvent("UPDATE_BONUS_ACTIONBAR", 'UpdateReminder')
	self:RegisterEvent("CHARACTER_POINTS_CHANGED", 'UpdateReminder')
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", 'UpdateReminder')
	self:UpdateReminder()
end

function RBR:DisableRBR()
	RaidBuffReminder:Hide()
	self:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	self:UnregisterEvent("UNIT_INVENTORY_CHANGED")
	self:UnregisterEvent("UNIT_AURA")
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnregisterEvent("UPDATE_BONUS_ACTIONBAR")
	self:UnregisterEvent("CHARACTER_POINTS_CHANGED")
	self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
end

function RBR:Initialize()
	local frame = CreateFrame('Frame', 'RaidBuffReminder', Minimap)
	frame:SetTemplate('Default')
	frame:Width(E.RBRWidth)
	frame:Point('TOPLEFT', Minimap.backdrop, 'TOPRIGHT', (E.PixelMode and -1 or 1), 0)
	frame:Point('BOTTOMLEFT', Minimap.backdrop, 'BOTTOMRIGHT', (E.PixelMode and -1 or 1), 0)

	frame.spell1 = self:CreateButton(frame, true)
	frame.spell2 = self:CreateButton(frame.spell1)
	frame.spell3 = self:CreateButton(frame.spell2)
	frame.spell4 = self:CreateButton(frame.spell3)
	frame.spell5 = self:CreateButton(frame.spell4)
	frame.spell6 = self:CreateButton(frame.spell5, nil, true)
	self.frame = frame
	
	if E.db.general.raidReminder then
		self:EnableRBR()
	else
		self:DisableRBR()
	end
end

E:RegisterModule(RBR:GetName())