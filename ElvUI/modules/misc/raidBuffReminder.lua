local E, L, V, P, G = unpack(select(2, ...));
local RB = E:NewModule('ReminderBuffs', 'AceEvent-3.0');
local LSM = LibStub('LibSharedMedia-3.0');

E.ReminderBuffs = RB;

RB.Spell1Buffs = {
	67016, --'Flask of the North-SP'
	67017, --'Flask of the North-AP'
	67018, --'Flask of the North-STR'
	53758, --'Flask of Stoneblood'
	53755, --'Flask of the Frost Wyrm',
	54212, --'Flask of Pure Mojo',
	53760, --'Flask of Endless Rage',
	17627, --'Flask of Distilled Wisdom',
	
	33721, --'Spellpower Elixir',
	53746, --'Wrath Elixir',
	28497, --'Elixir of Mighty Agility',
	53748, --'Elixir of Mighty Strength',
	60346, --'Elixir of Lightning Speed',
	60344, --'Elixir of Expertise',
	60341, --'Elixir of Deadly Strikes',
	60345, --'Elixir of Armor Piercing',
	60340, --'Elixir of Accuracy',
	53749, --'Guru's Elixir',
	
	60343, --'Elixir of Mighty Defense',
	53751, --'Elixir of Mighty Fortitude',
	53764, --'Elixir of Mighty Mageblood',
	60347, --'Elixir of Mighty Thoughts',
	53763, --'Elixir of Protection',
	53747, --'Elixir of Spirit',
};

RB.Spell2Buffs = {
	57325, -- 80 Силы атаки;
	57327, -- 46 Силы заклинаний;
	57329, -- 40 Критического удара;
	57332, -- 40 Скорости;
	57334, -- 20 Восполнение маны;
	57356, -- 40 Мастерства;
	57358, -- 40 Пробивание брони;
	57360, -- 40 Меткости;
	57363, -- Выслеживание гуманойдов;
	57365, -- 40 Духа;
	57367, -- 40 Ловкости;
	57371, -- 40 Силы;
	57373, -- Выслеживание животных;
	57399, -- 80 Силы, 46 Силы заклинаний (Рыбный пир);
	59230, -- 40 Рейтинг уклонений;
	65247 -- 20 Силы;
};

RB.Spell3Buffs = {
	48469, -- Знак дикой природы;
	72588 -- Дар дикой природы;
};

RB.Spell4Buffs = {
	20217, -- Благословение королей;
	25898 -- Великое благословение королей;
};

RB.CasterSpell5Buffs = {
	42995, -- Чародейский интелект;
	43002, -- Чародейская гениальность;
	61316 -- Чародейская гениальность Даларана;
};

RB.MeleeSpell5Buffs = {
	48161, -- Слово силы: Стойкость;
	48162 -- Молитва стойкости;
};

RB.CasterSpell6Buffs = {
	48936, -- Благословение мудрости;
	48938, -- Великое благословение мудрости;
	58777 -- Источник маны;
};

RB.MeleeSpell6Buffs = {
	48932, -- Благословение могущества;
	48934, -- Великое благословение могущества;
	47436 -- Боевой крик;
};

function RB:CheckFilterForActiveBuff(filter)
	local spellName, texture, name, duration, expirationTime;
	
	for _, spell in pairs(filter) do
		spellName = GetSpellInfo(spell);
		name, _, texture, _, _, duration, expirationTime = UnitAura('player', spellName);
		
		if(name) then
			return true, texture, duration, expirationTime;
		end
	end

	return false, texture, duration, expirationTime;
end

function RB:UpdateReminderTime(elapsed)
	self.expiration = self.expiration - elapsed;
	
	if(self.nextupdate > 0) then
		self.nextupdate = self.nextupdate - elapsed;
		
		return;
	end
	
	if(self.expiration <= 0) then
		self.timer:SetText('');
		self:SetScript('OnUpdate', nil);
		
		return;
	end
	
	local timervalue, formatid;
	timervalue, formatid, self.nextupdate = E:GetTimeInfo(self.expiration, 4);
	self.timer:SetFormattedText(('%s%s|r'):format(E.TimeColors[formatid], E.TimeFormats[formatid][1]), timervalue);
end

function RB:UpdateReminder(event, unit)
	if(event == 'UNIT_AURA' and unit ~= 'player') then
		return;
	end
	
	local frame = self.frame;
	
	if(E.Role == 'Caster') then
		self.Spell5Buffs = self.CasterSpell5Buffs;
		self.Spell6Buffs = self.CasterSpell6Buffs;
	else
		self.Spell5Buffs = self.MeleeSpell5Buffs;
		self.Spell6Buffs = self.MeleeSpell6Buffs;
	end
	
	for i = 1, 6 do
		local hasBuff, texture, duration, expirationTime = self:CheckFilterForActiveBuff(self['Spell'..i..'Buffs']);
		local button = frame[i];
		
		if(hasBuff) then
			button.expiration = expirationTime - GetTime();
			button.nextupdate = 0;
			button.t:SetTexture(texture);
			
			if(duration == 0 and expirationTime == 0) then
			--	button.t:SetAlpha(0.3);
				button:SetScript('OnUpdate', nil);
				button.timer:SetText(nil);
				CooldownFrame_SetTimer(button.cd, 0, 0, 0);
			else
				button.t:SetAlpha(1)
				CooldownFrame_SetTimer(button.cd, expirationTime - duration, duration, 1);
				button:SetScript('OnUpdate', self.UpdateReminderTime);
			end
		else
			CooldownFrame_SetTimer(button.cd, 0, 0, 0);
			button.t:SetAlpha(0.3);
			button:SetScript('OnUpdate', nil);
			button.timer:SetText(nil);
			button.t:SetTexture(self.DefaultIcons[i]);
		end
	end
end

function RB:CreateButton()
	local button = CreateFrame('Button', nil, ElvUI_ReminderBuffs);
	button:SetTemplate('Default');
	
	button.t = button:CreateTexture(nil, 'OVERLAY');
	button.t:SetTexCoord(unpack(E.TexCoords));
	button.t:SetInside();
	button.t:SetTexture('Interface\\Icons\\INV_Misc_QuestionMark');
	
	button.cd = CreateFrame('Cooldown', nil, button, 'CooldownFrameTemplate');
	button.cd:SetInside();
	button.cd.noOCC = true;
	button.cd.noCooldownCount = true;
	button.cd:SetReverse(true);
	
	button.timer = button.cd:CreateFontString(nil, 'OVERLAY');
	button.timer:SetPoint('CENTER');
	
	return button;
end

function RB:EnableRB()
	ElvUI_ReminderBuffs:Show()
	self:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED', 'UpdateReminder');
	self:RegisterEvent('UNIT_INVENTORY_CHANGED', 'UpdateReminder');
	self:RegisterEvent('UNIT_AURA', 'UpdateReminder');
	self:RegisterEvent('PLAYER_REGEN_ENABLED', 'UpdateReminder');
	self:RegisterEvent('PLAYER_REGEN_DISABLED', 'UpdateReminder');
	self:RegisterEvent('PLAYER_ENTERING_WORLD', 'UpdateReminder');
	self:RegisterEvent('UPDATE_BONUS_ACTIONBAR', 'UpdateReminder');
	self:RegisterEvent('CHARACTER_POINTS_CHANGED', 'UpdateReminder');
	self:RegisterEvent('ZONE_CHANGED_NEW_AREA', 'UpdateReminder');
	self:UpdateReminder();
end

function RB:DisableRB()
	ElvUI_ReminderBuffs:Hide()
	self:UnregisterEvent('ACTIVE_TALENT_GROUP_CHANGED');
	self:UnregisterEvent('UNIT_INVENTORY_CHANGED');
	self:UnregisterEvent('UNIT_AURA');
	self:UnregisterEvent('PLAYER_REGEN_ENABLED');
	self:UnregisterEvent('PLAYER_REGEN_DISABLED');
	self:UnregisterEvent('PLAYER_ENTERING_WORLD');
	self:UnregisterEvent('UPDATE_BONUS_ACTIONBAR');
	self:UnregisterEvent('CHARACTER_POINTS_CHANGED');
	self:UnregisterEvent('ZONE_CHANGED_NEW_AREA');
end

function RB:UpdateSettings(isCallback)
	local frame = self.frame;
	frame:Width(E.RBRWidth);
	
	for i = 1, 6 do
		local button = frame[i];
		button:ClearAllPoints();
		button:SetWidth(E.RBRWidth);
		button:SetHeight(E.RBRWidth);
		
		if(i == 1) then
			button:Point("TOP", ElvUI_ReminderBuffs, "TOP", 0, 0);
		else
			button:Point("TOP", frame[i - 1], "BOTTOM", 0, E.Border - E.Spacing);
		end
		
		if(i == 6) then
			button:Point('BOTTOM', ElvUI_ReminderBuffs, 'BOTTOM', 0, (E.PixelMode and 0 or 2));
		end
		
		if(E.db.general.reminder.durations) then
			button.cd:SetAlpha(1);
		else
			button.cd:SetAlpha(0);
		end
		
		button.cd:SetReverse(E.db.general.reminder.reverse);

		local font = LSM:Fetch("font", E.db.general.reminder.font);
		button.timer:FontTemplate(font, E.db.general.reminder.fontSize, E.db.general.reminder.fontOutline);
	end
	
	if(not isCallback) then
		if(E.db.general.reminder.enable) then
			RB:EnableRB();
		else
			RB:DisableRB();
		end
	end
end

function RB:UpdatePosition()
	Minimap:ClearAllPoints();
	ElvConfigToggle:ClearAllPoints();
	ElvUI_ReminderBuffs:ClearAllPoints();
	if(E.db.general.reminder.position == "LEFT") then
		Minimap:Point("TOPRIGHT", MMHolder, "TOPRIGHT", -2, -2);
		ElvConfigToggle:SetPoint("TOPRIGHT", LeftMiniPanel, "TOPLEFT", (E.PixelMode and 1 or -1), 0);
		ElvConfigToggle:SetPoint("BOTTOMRIGHT", LeftMiniPanel, "BOTTOMLEFT", (E.PixelMode and 1 or -1), 0);
		ElvUI_ReminderBuffs:SetPoint("TOPRIGHT", Minimap.backdrop, "TOPLEFT", (E.PixelMode and 1 or -1), 0);
		ElvUI_ReminderBuffs:SetPoint("BOTTOMRIGHT", Minimap.backdrop, "BOTTOMLEFT", (E.PixelMode and 1 or -1), 0);
	else
		Minimap:Point("TOPLEFT", MMHolder, "TOPLEFT", 2, -2);
		ElvConfigToggle:SetPoint("TOPLEFT", RightMiniPanel, "TOPRIGHT", (E.PixelMode and -1 or 1), 0);
		ElvConfigToggle:SetPoint("BOTTOMLEFT", RightMiniPanel, "BOTTOMRIGHT", (E.PixelMode and -1 or 1), 0);
		ElvUI_ReminderBuffs:SetPoint("TOPLEFT", Minimap.backdrop, "TOPRIGHT", (E.PixelMode and -1 or 1), 0);
		ElvUI_ReminderBuffs:SetPoint("BOTTOMLEFT", Minimap.backdrop, "BOTTOMRIGHT", (E.PixelMode and -1 or 1), 0);
	end
end

function RB:Initialize()
	self.db = E.db.general.reminder;
	
	self.DefaultIcons = {
		[1] = 'Interface\\Icons\\INV_Potion_97',
		[2] = 'Interface\\Icons\\Spell_Misc_Food',
		[3] = 'Interface\\Icons\\Spell_Nature_Regeneration',
		[4] = 'Interface\\Icons\\Spell_Magic_GreaterBlessingofKings',
		[5] = (E.Role == 'Caster' and 'Interface\\Icons\\Spell_Holy_MagicalSentry') or 'Interface\\Icons\\Spell_Holy_WordFortitude',
		[6] = (E.Role == 'Caster' and 'Interface\\Icons\\Spell_Holy_GreaterBlessingofWisdom') or 'Interface\\Icons\\Ability_Warrior_BattleShout'
	};
	
	local frame = CreateFrame('Frame', 'ElvUI_ReminderBuffs', Minimap);
	frame:SetTemplate('Default');
	frame:Width(E.RBRWidth);
	if(E.db.general.reminder.position == "LEFT") then
		frame:Point('TOPRIGHT', Minimap.backdrop, 'TOPLEFT', E.Border - E.Spacing*3, 0);
		frame:Point('BOTTOMRIGHT', Minimap.backdrop, 'BOTTOMLEFT', E.Border - E.Spacing*3, 0);
	else
		frame:Point('TOPLEFT', Minimap.backdrop, 'TOPRIGHT', -E.Border + E.Spacing*3, 0);
		frame:Point('BOTTOMLEFT', Minimap.backdrop, 'BOTTOMRIGHT', -E.Border + E.Spacing*3, 0);
	end
	self.frame = frame;
	
	for i = 1, 6 do
		frame[i] = self:CreateButton();
		frame[i]:SetID(i);
	end
	
	self:UpdateSettings();
end

E:RegisterInitialModule(RB:GetName());
