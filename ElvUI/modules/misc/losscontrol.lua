local E, L, V, P, G = unpack(select(2, ...));
local LOS = E:NewModule('LoseOfControl', 'AceEvent-3.0');
local LSM = LibStub("LibSharedMedia-3.0")

local SpellID = {
-- Рыцарь смерти
	[47481] = 'CC', -- Отгрызть
	[51209] = 'CC', -- Ненасытная стужа
	[47476] = 'Silence', -- Удушение
	[45524] = 'Snare', -- Ледяные оковы
	[55666] = 'Snare', -- Осквернение
	[58617] = 'Snare', -- Символ удара в сердце
	[50436] = 'Snare', -- Ледяная хватка
-- Друид
	[5211] = 'CC', -- Оглушить
	[33786] = 'CC', -- Смерч
	[2637] = 'CC', -- Спячка
	[22570] = 'CC', -- Калечение
	[9005] = 'CC', -- Наскок
	[339] = 'Root',	-- Гнев деревьев
	[19675] = 'Root', -- Звериная атака - эффект
	[58179] = 'Snare', -- Зараженные раны
	[61391] = 'Snare', -- Тайфун
-- Охотник
	[60210] = 'CC', -- Эффект замораживающей стрелы
	[3355] = 'CC', -- Эффект замораживающей ловушки
	[24394] = 'CC', -- Устрашение
	[1513] = 'CC', -- Отпугивание зверя
	[19503] = 'CC', -- Дизориентирующий выстрел
	[19386] = 'CC', -- Укус виверны
	[34490] = 'Silence', -- Глушащий выстрел
	[53359] = 'Disarm', -- Выстрел химеры - сорпид
	[19306] = 'Root', -- Контратака
	[19185] = 'Root', -- Удержание
	[35101] = 'Snare', -- Шокирующий залп
	[5116] = 'Snare', -- Контузящий выстрел
	[13810] = 'Snare', -- Аура ледяной ловушки
	[61394] = 'Snare', -- Символ заморажевающей ловушки
	[2974] = 'Snare', -- Подрезать крылья
-- Питомец Охотника
	[50519] = 'CC', -- Ультразвук
	[50541] = 'Disarm', -- Хватка
	[54644] = 'Snare', -- Дыхание ледяной бури
	[50245] = 'Root', -- Шип
	[50271] = 'Snare', -- Повреждение сухожилий
	[50518] = 'CC', -- Накинуться
	[54706] = 'Root', -- Ядовитая паутина
	[4167] = 'Root', -- Сеть
-- Маг
	[44572] = 'CC', -- Глубокая замарозка
	[31661] = 'CC', -- Дыхание дракона
	[12355] = 'CC', -- Сотрясение
	[118] = 'CC', -- Превращение
	[18469] = 'Silence', -- Антимагия - немота
	[64346] = 'Disarm', -- Огненная расплата
	[33395] = 'Root', -- Холод
	[122] = 'Root', -- Кольцо льда
	[11071] = 'Root', -- Обморожение
	[55080] = 'Root', -- Разрушенная преграда
	[11113] = 'Snare', -- Врзрывная волна
	[6136] = 'Snare', -- Окоченение
	[120] = 'Snare', -- Конус льда
	[116] = 'Snare', -- Ледяная стрела
	[47610] = 'Snare', -- Стрела ледяного огня
	[31589] = 'Snare', -- Замедление
-- Паладин
	[853] = 'CC', -- Молот правосудия
	[2812] = 'CC', -- Гнев небес
	[20066] = 'CC', -- Покаяние
	[20170] = 'CC', -- Оглушение
	[10326] = 'CC', -- Изгнание зла
	[63529] = 'Silence', -- Немота - Щит храмовника
	[20184] = 'Snare', -- Правосудие справедливости
-- Жрец
	[605] = 'CC', -- Контроль над разумом
	[64044] = 'CC', -- Глубинный ужас
	[8122]  = 'CC', -- Ментальный крик
	[9484]  = 'CC', -- Сковывание нежити
	[15487] = 'Silence', -- Безмолвие
	[64058] = 'Disarm', -- Глубинный ужас
	[15407] = 'Snare', -- Пытка разума
-- Разбойник
	[2094]  = 'CC', -- Ослепление
	[1833]  = 'CC', -- Подлый трюк
	[1776]  = 'CC', -- Парализующий удар
	[408]   = 'CC', -- Удар по почкам
	[6770]  = 'CC', -- Ошеломление
	[1330]  = 'Silence', -- Гаррота - немота
	[18425] = 'Silence', -- Пинок - немота
	[51722] = 'Disarm', -- Долой оружие
	[31125] = 'Snare', -- Вращение лезвий
	[3409]  = 'Snare', -- Калечащий яд
	[26679] = 'Snare', -- Смертельный бросок
-- Шаман
	[39796] = 'CC', -- Оглушение каменного когтя
	[51514] = 'CC', -- Сглаз
	[64695] = 'Root', -- Хватка земли
	[63685] = 'Root', -- Заморозка
	[3600]  = 'Snare', -- Оковы земли
	[8056]  = 'Snare', -- Ледяной шок
	[8034]  = 'Snare', -- Наложение ледяного клейма
-- Чернокнижник
	[710]   = 'CC', -- Изгнание
	[6789]  = 'CC', -- Лик смерти
	[5782]  = 'CC', -- Страх
	[5484]  = 'CC', -- Вой ужаса
	[6358]  = 'CC', -- Соблазн
	[30283] = 'CC', -- Неистовство Тьмы
	[24259] = 'Silence', -- Запрет чар
	[18118] = 'Snare', -- Огненный шлейф
	[18223] = 'Snare', -- Проклятие изнеможения
-- Воин
	[7922]  = 'CC', -- Наскок и оглушение
	[12809] = 'CC', -- Оглушающий удар
	[20253] = 'CC', -- Перехват
	[5246]  = 'CC', -- Устрашающий крик
	[12798] = 'CC', -- Реванш - оглушение
	[46968] = 'CC', -- Ударная волна
	[18498] = 'Silence', -- Обет молчания - немота
	[676]   = 'Disarm', -- Разоружение
	[58373] = 'Root', -- Символ подрезанного сухожилия
	[23694] = 'Root', -- Улучшенное подрезание сухожилий
	[1715]  = 'Snare', -- Подрезать сухожилия
	[12323] = 'Snare', -- Пронзительный вой
-- Разные
	[30217] = 'CC', -- Адамантитовая граната
	[67769] = 'CC', -- Кобальтовая осколочная бомба
	[30216] = 'CC', -- Бомба из оскверненного железа
	[20549] = 'CC', -- Громовая поступь
	[25046] = 'Silence', -- Волшебный поток
	[39965] = 'Root', -- Замораживающая граната
	[55536] = 'Root', -- Сеть из ледяной ткани
	[13099] = 'Root', -- Сетестрел
	[29703] = 'Snare', -- Головокружение
-- PvE
	[28169] = 'PvE', -- Мутагенный укол
	[28059] = 'PvE', -- Положительный заряд
	[28084] = 'PvE', -- Отрицательный заряд
	[27819] = 'PvE', -- Взрыв маны
	[63024] = 'PvE', -- Гравитационная бомба
	[63018] = 'PvE', -- Опаляющий свет
	[62589] = 'PvE', -- Гнев природы
	[63276] = 'PvE', -- Метка Безликого
	[66770] = 'PvE', -- Свирепое бодание
	[71340] = 'PvE', -- Пакт Омраченных
	[70126] = 'PvE', -- Ледяная метка
	[73785] = 'PvE', -- Мертвящая чума
}

local abilities = {};
for k, v in pairs(SpellID) do
	local name = GetSpellInfo(k);
	if(name) then
		abilities[name] = v;
	end
end

local Defaults = {
	['CC'] = true, -- Потеря контроля
	['PvE'] = true, -- PvE
	['Silence'] = true, -- Антимагия
	['Disarm'] = true, -- Разоружение
	['Root'] = true, -- Удержание на месте
	['Snare'] = false, -- Замедления
}

function LOS:OnUpdate(elapsed)
	if(self.timeLeft) then
		self.timeLeft = self.timeLeft - elapsed;
		
		if(self.timeLeft >= 10) then
			self.NumberText:SetFormattedText('%d', self.timeLeft);
		elseif (self.timeLeft < 9.95) then
			self.NumberText:SetFormattedText('%.1f', self.timeLeft);
		end
	end
end

function LOS:UNIT_AURA()
	local maxExpirationTime = 0;
	local _, name, icon, Icon, duration, Duration, expirationTime;

	for i = 1, 40 do
		name, _, icon, _, _, duration, expirationTime = UnitDebuff('player', i);
		
		if(Defaults[abilities[name]] and expirationTime > maxExpirationTime) then
			maxExpirationTime = expirationTime;
			Icon = icon;
			Duration = duration;
			
			self.AbilityName:SetText(name);
		end
	end
	
	if(maxExpirationTime == 0) then
		self.maxExpirationTime = 0;
		self.frame.timeLeft = nil;
		self.frame:SetScript('OnUpdate', nil);
		self.frame:Hide();
	elseif(maxExpirationTime ~= self.maxExpirationTime) then
		self.maxExpirationTime = maxExpirationTime;
		
		self.Icon:SetTexture(Icon);
		
		self.Cooldown:SetCooldown(maxExpirationTime - Duration, Duration);
		
		local timeLeft = maxExpirationTime - GetTime();
		if(not self.frame.timeLeft) then
			self.frame.timeLeft = timeLeft;
			
			self.frame:SetScript('OnUpdate', self.OnUpdate);
		else
			self.frame.timeLeft = timeLeft;
		end
		
		self.frame:Show();
	end
end

function LOS:Initialize()
	if(E.private["general"].lossControl ~= true) then return; end
	
	self.frame = CreateFrame('Frame', 'ElvUI_LoseOfControlFrame', UIParent);
	self.frame:Point('CENTER', 0, 0);
	self.frame:Size(54);
	self.frame:SetTemplate();
	self.frame:Hide();
	
	E:CreateMover(self.frame, 'LossControlMover', L['Loss Control Icon']);
	
	self.Icon = self.frame:CreateTexture(nil, 'ARTWORK');
	self.Icon:SetInside();
	self.Icon:SetTexCoord(.1, .9, .1, .9);
	
	self.AbilityName = self.frame:CreateFontString(nil, 'OVERLAY');
	self.AbilityName:FontTemplate(E['media'].normFont, 20, 'OUTLINE');
	self.AbilityName:SetPoint('BOTTOM', self.frame, 0, -28);
	
	self.Cooldown = CreateFrame('Cooldown', self.frame:GetName()..'Cooldown', self.frame, 'CooldownFrameTemplate');
	self.Cooldown:SetInside();
	
	self.frame.NumberText = self.frame:CreateFontString(nil, 'OVERLAY');
	self.frame.NumberText:FontTemplate(E['media'].normFont, 20, 'OUTLINE');
	self.frame.NumberText:SetPoint("BOTTOM", self.frame, 0, -58);
	
	self.SecondsText = self.frame:CreateFontString(nil, 'OVERLAY');
	self.SecondsText:FontTemplate(E['media'].normFont, 20, 'OUTLINE');
	self.SecondsText:SetPoint("BOTTOM", self.frame, 0, -80);
	self.SecondsText:SetText(L['seconds']);
	
	self:RegisterEvent('UNIT_AURA');
end

E:RegisterModule(LOS:GetName());