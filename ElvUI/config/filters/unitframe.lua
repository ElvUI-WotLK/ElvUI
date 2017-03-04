local E, L, V, P, G, _ = unpack(select(2, ...));

local print, unpack = print, unpack;

local GetSpellInfo = GetSpellInfo;

local function SpellName(id)
	local name, _, _, _, _, _, _, _, _ = GetSpellInfo(id);
	if(not name) then
		print("|cff1784d1ElvUI:|r SpellID is not valid: "..id..". Please check for an updated version, if none exists report to ElvUI author.");
		return "Impale";
	else
		return name;
	end
end

local function Defaults(priorityOverride)
	return {["enable"] = true, ["priority"] = priorityOverride or 0, ["stackThreshold"] = 0};
end

G.unitframe.aurafilters = {};

G.unitframe.aurafilters["CCDebuffs"] = {
	["type"] = "Whitelist",
	["spells"] = {
	-- Рыцарь смерти
		[47476] = Defaults(), -- Удушение
		[51209] = Defaults(), -- Ненасытная стужа
	-- Друид
		[99] = Defaults(), -- Устрашающий рев
		[339] = Defaults(), -- Гнев деревьев
		[2637] = Defaults(), -- Спячка
		[5211] = Defaults(), -- Оглушить
		[9005] = Defaults(), -- Наскок
		[22570] = Defaults(), -- Калечение
		[33786] = Defaults(), -- Смерч
		[45334] = Defaults(), -- Звериная атака - эффект
	-- Охотник
		[1513] = Defaults(), -- Отпугивание зверя
		[3355] = Defaults(), -- Эффект замораживающей ловушки
		[19386] = Defaults(), -- Укус виверны
		[19503] = Defaults(), -- Дезориентирующий выстрел
		[24394] = Defaults(), -- Устрашение
		[34490] = Defaults(), -- Глушащий выстрел
		[50245] = Defaults(), -- Шип
		[50519] = Defaults(), -- Ультразвук
		[50541] = Defaults(), -- Хватка
		[54706] = Defaults(), -- Ядовитая паутина
		[56626] = Defaults(), -- Ужалить
		[60210] = Defaults(), -- Эффект замораживающей стрелы
		[64803] = Defaults(), -- Удержание
	-- Маг
		[118] = Defaults(), -- Превращение
		[122] = Defaults(), -- Кольцо льда
		[18469] = Defaults(), -- Антимагия - немота
		[31589] = Defaults(), -- Замедление
		[31661] = Defaults(), -- Дыхание дракона
		[33395] = Defaults(), -- Холод
		[44572] = Defaults(), -- Глубокая заморозка
		[55080] = Defaults(), -- Разрушенная преграда
		[61305] = Defaults(), -- Превращение
		[55021] = Defaults(), -- Антимагия - немота
	-- Паладин
		[853] = Defaults(), -- Молот правосудия
		[10326] = Defaults(), -- Изгнание зла
		[20066] = Defaults(), -- Покаяние
		[31935] = Defaults(), -- Щит мстителя
	-- Жрец
		[605] = Defaults(), -- Контроль над разумом
		[8122] = Defaults(), -- Ментальный крик
		[9484] = Defaults(), -- Сковывание нежити
		[15487] = Defaults(), -- Безмолвие
		[64044] = Defaults(), -- Глубинный ужас
	-- Разбойник
		[408] = Defaults(), -- Удар по почкам
		[1330] = Defaults(), -- Гаррота - немота
		[1776] = Defaults(), -- Парализующий удар
		[1833] = Defaults(), -- Подлый трюк
		[2094] = Defaults(), -- Ослепление
		[6770] = Defaults(), -- Ошеломление
		[18425] = Defaults(), -- Пинок - немота
		[51722] = Defaults(), -- Долой оружие
	-- Шаман
		[3600] = Defaults(), -- Оковы земли
		[8056] = Defaults(), -- Ледяной шок
		[39796] = Defaults(), -- Оглушение каменного когтя
		[51514] = Defaults(), -- Сглаз
		[63685] = Defaults(), -- Заморозка
		[64695] = Defaults(), -- Хватка земли
	-- Чернокнижник
		[710] = Defaults(), -- Изгнание
		[5782] = Defaults(), -- Страх
		[6358] = Defaults(), -- Соблазн
		[6789] = Defaults(), -- Лик смерти
		[17928] = Defaults(), -- Вой ужаса
		[24259] = Defaults(), -- Запрет чар
		[30283] = Defaults(), -- Неистовство Тьмы
	-- Воин
		[676] = Defaults(), -- Разоружение
		[7922] = Defaults(), -- Наскок и оглушение
		[18498] = Defaults(), -- Обет молчания - немота
		[20511] = Defaults(), -- Устрашающий крик
	-- Racial
		[25046] = Defaults(), -- Волшебный поток
		[20549] = Defaults(), -- Громовой поступь
	--PVE Дебаффы

	-- The Lich King
		[73787] = Defaults() -- Мертвящая чума
	}
};

G.unitframe.aurafilters["TurtleBuffs"] = {
	["type"] = "Whitelist",
	["spells"] = {
	-- Маг
		[45438] = Defaults(5), -- Ледяная глыба
	-- Рыцарь смерти
		[48707] = Defaults(5), -- Антимагический панцирь
		[48792] = Defaults(), -- Незыблемость льда
		[49039] = Defaults(), -- Перерождение
		[50461] = Defaults(), -- Зона антимагии
		[55233] = Defaults(), -- Кровь вампира
	-- Жрец
		[33206] = Defaults(3), -- Подавление боли
		[47585] = Defaults(5), -- Слияние с тьмой
		[47788] = Defaults(), -- Оберегающий дух
	-- Чернокнижник

	-- Друид
		[22812] = Defaults(2), -- Дубовая кожа
		[61336] = Defaults(), -- Инстинкт выживания
	-- Охотник
		[19263] = Defaults(5), -- Сдерживание
		[53480] = Defaults(), -- Рев самопожертвования
	-- Разбойник
		[5277] = Defaults(5), -- Ускользание
		[31224] = Defaults(), -- Плащ Теней
		[45182] = Defaults(), -- Обман смерти
	-- Шаман
		[30823] = Defaults(), -- Ярость шамана
	-- Паладин
		[498] = Defaults(2), -- Божественная защита
		[642] = Defaults(5), -- Божественный щит
		[1022] = Defaults(5), -- Длань защиты
		[6940] = Defaults(), -- Длань жертвенности
		[31821] = Defaults(3), -- Мастер аур
	-- Воин
		[871] = Defaults(3), -- Глухая оборона
		[55694] = Defaults() -- Безудержное восстановление
	}
};

G.unitframe.aurafilters["PlayerBuffs"] = {
	["type"] = "Whitelist",
	["spells"] = {
	-- Маг
		[12042] = Defaults(), -- Мощь тайной магии
		[12051] = Defaults(), -- Прилив сил
		[12472] = Defaults(), -- Стальная кровь
		[32612] = Defaults(), -- Невидимость
		[45438] = Defaults(), -- Ледяная глыба
	-- Рыцарь смерти
		[48707] = Defaults(), -- Антимагический панцирь
		[48792] = Defaults(), -- Незыблемость льда
		[49016] = Defaults(), -- Истерия
		[49039] = Defaults(), -- Перерождение
		[49222] = Defaults(), -- Костяной щит
		[50461] = Defaults(), -- Зона антимагии
		[51271] = Defaults(), -- Несокрушимая броня
		[55233] = Defaults(), -- Кровь вампира
	-- Жрец
		[6346] = Defaults(), -- Защита от страха
		[10060] = Defaults(), -- Придание сил
		[27827] = Defaults(), -- Дух воздаяния
		[33206] = Defaults(), -- Подавление боли
		[47585] = Defaults(), -- Слияние с тьмой
		[47788] = Defaults(), -- Оберегающий дух
	-- Чернокнижник

	-- Друид
		[1850] = Defaults(), -- Dash
		[22812] = Defaults(), -- Barkskin
		[52610] = Defaults(), -- Savage Roar
	-- Охотник
		[3045] = Defaults(), -- Rapid Fire
		[3584] = Defaults(), -- Feign Death
		[19263] = Defaults(), -- Deterrence
		[53480] = Defaults(), -- Roar of Sacrifice (Cunning)
		[54216] = Defaults(), -- Master's Call
	-- Разбойник
		[2983] = Defaults(), -- Sprint
		[5277] = Defaults(), -- Evasion
		[11327] = Defaults(), -- Vanish
		[13750] = Defaults(), -- Adrenaline Rush
		[31224] = Defaults(), -- Cloak of Shadows
		[45182] = Defaults(), -- Cheating Death
	-- Шаман
		[2825] = Defaults(), -- Жажда крови
		[8178] = Defaults(), -- Эффект тотема заземления
		[16166] = Defaults(), -- Покорение стихий
		[16188] = Defaults(), -- Природная стремительность
		[16191] = Defaults(), -- Тотем прилива маны
		[30823] = Defaults(), -- Ярость шамана
		[32182] = Defaults(), -- Героизм
		[58875] = Defaults(), -- Поступь духа
	-- Паладин
		[498] = Defaults(), -- Divine Protection
		[1022] = Defaults(), -- Hand of Protection
		[1044] = Defaults(), -- Hand of Freedom
		[6940] = Defaults(), -- Hand of Sacrifice
		[31821] = Defaults(), -- Devotion Aura
		[31842] = Defaults(), -- Divine Favor
		[31850] = Defaults(), -- Ardent Defender
		[31884] = Defaults(), -- Avenging Wrath
		[53563] = Defaults(), -- Beacon of Light
	-- Воин
		[871] = Defaults(), -- Shield Wall
		[1719] = Defaults(), -- Recklessness
		[3411] = Defaults(), -- Intervene
		[12975] = Defaults(), -- Last Stand
		[18499] = Defaults(), -- Berserker Rage
		[23920] = Defaults(), -- Spell Reflection
		[46924] = Defaults(), -- Bladestorm
	-- Рассовые
		[20594] = Defaults(), -- Каменная форма
		[59545] = Defaults(), -- Дар наару
		[20572] = Defaults(), -- Кровавое неистовство
		[26297] = Defaults() -- Берсек
	}
};

G.unitframe.aurafilters["Blacklist"] = {
	["type"] = "Blacklist",
	["spells"] = {
		[6788] = Defaults(), -- Ослабленная душа
		[8326] = Defaults(), -- Призрак
		[15007] = Defaults(), -- Слабость после воскрешения
		[23445] = Defaults(), -- Злой двойник
		[24755] = Defaults(), -- Конфета или жизнь
		[25771] = Defaults(), -- Воздержанность
		[26013] = Defaults(), -- Дезертир
		[36032] = Defaults(), -- Чародейская вспышка
		[36893] = Defaults(), -- Неисправность транспортера
		[36900] = Defaults(), -- Расщепление души: Зло!
		[36901] = Defaults(), -- Расщепление души: Добро
		[41425] = Defaults(), -- Гипотермия
		[55711] = Defaults(), -- Сердце феникса
		[57723] = Defaults(), -- Изнеможение
		[57724] = Defaults(), -- Пресыщение
		[58539] = Defaults(), -- Тело наблюдателя
		[67604] = Defaults(), -- Накопление энергии
		[69127] = Defaults(), -- Холод Трона
		[71041] = Defaults(), -- Покинувший подземелье
	-- Blood Princes
		[71911] = Defaults(), -- Теневой резонанс
	-- Festergut
		[70852] = Defaults(), -- Вязкая гадость
		[72144] = Defaults(), -- Шлейф оранжевой заразы
		[73034] = Defaults(), -- Зараженные гнилью споры
	-- Rotface
		[72145] = Defaults(), -- Шлейф зеленой заразы
	-- Putricide
		[72460] = Defaults(), -- Удушливый газ
		[72511] = Defaults() -- Мутация
	}
};

G.unitframe.aurafilters["Whitelist"] = {
	["type"] = "Whitelist",
	["spells"] = {
		[1022] = Defaults(), -- Длань защиты
		[1490] = Defaults(), -- Проклятие стихий
		[2825] = Defaults(), -- Жажда крови
		[12051] = Defaults(), -- Прилив сил
		[18708] = Defaults(), -- Господство Скверны
		[22812] = Defaults(), -- Дубовая кожа
		[29166] = Defaults(), -- Озаренье
		[31821] = Defaults(), -- Мастер аур
		[32182] = Defaults(), -- Героизм
		[33206] = Defaults(), -- Подавление боли
		[47788] = Defaults(), -- Оберегающий дух
		[54428] = Defaults(), -- Святая клятва
	-- Turtling abilities
		[871] = Defaults(), -- Глухая оборона
		[19263] = Defaults(), -- Сдерживание
		[31224] = Defaults(), -- Плащ Теней
		[48707] = Defaults(), -- Антимагический панцирь
	-- Immunities
		[642] = Defaults(), -- Божественный щит
		[45438] = Defaults(), -- Ледяная глыба
	-- Offensive
		[31884] = Defaults(), -- Гнев карателя
		[34471] = Defaults(), -- Зверь внутри
	}
};

G.unitframe.aurafilters["RaidDebuffs"] = {
	["type"] = "Whitelist",
	["spells"] = {
	-- Naxxramas
		-- Kel'Thuzad
		[28410] = Defaults(), -- Chains of Kel'Thuzad
		[27819] = Defaults(), -- Detonate Mana
		[27808] = Defaults(), -- Frost Blast

	-- Ulduar
		-- Ignis the Furnace Master
		[62717] = Defaults(), -- Slag Pot

		-- XT-002
		[63024] = Defaults(), -- Gravity Bomb
		[63018] = Defaults(), -- Light Bomb

		-- The Assembly of Iron
		[61903] = Defaults(), -- Fusion Punch
		[61912] = Defaults(), -- Static Disruption

		-- Kologarn
		[64290] = Defaults(), -- Stone Grip

		-- Thorim
		[62130] = Defaults(), -- Unbalancing Strike

		-- Yogg-Saron
		[63134] = Defaults(), -- Sara's Blessing
		[64157] = Defaults(), -- Curse of Doom

		-- Algalon
		[64412] = Defaults(), -- Phase Punch

	-- Trial of the Crusader
		-- Beast of Northrend
		-- Gormok the Impaler
		[66331] = Defaults(), -- Impale
		[66406] = Defaults(), -- Snowbolled!
		-- Jormungar Behemoth
		[66869] = Defaults(), -- Burning Bile
		[67618] = Defaults(), -- Paralytic Toxin
		-- Icehowl
		[66689] = Defaults(), -- Arctic Breathe

		-- Lord Jaraxxus
		[66237] = Defaults(), -- Incinerate Flesh
		[66197] = Defaults(), -- Legion Flame

		-- Faction Champions
		[65812] = Defaults(), -- Unstable Affliction

		-- The Twin Val'kyr
		[67309] = Defaults(), -- Twin Spike

		-- Anub'arak
		[66013] = Defaults(), -- Penetrating Cold
		[67574] = Defaults(), -- Pursued by Anub'arak
		[67847] = Defaults(), -- Expose Weakness

	-- Icecrown Citadel
		-- Lord Marrowgar
		[69065] = Defaults(), -- Impaled

		-- Lady Deathwhisper
		[72109] = Defaults(), -- Death and Decay
		[71289] = Defaults(), -- Dominate Mind
		[71237] = Defaults(), -- Curse of Torpor

		-- Deathbringer Saurfang
		[72293] = Defaults(), -- Mark of the Fallen Champion
		[72442] = Defaults(), -- Boiling Blood
		[72449] = Defaults(), -- Rune of Blood
		[72769] = Defaults(), -- Scent of Blood

		-- Festergut
		[71218] = Defaults(), -- Vile Gas
		[72219] = Defaults(), -- Gastric Bloat
		[69279] = Defaults(), -- Gas Spore

		-- Rotface
		[71224] = Defaults(), -- Mutated Infection

		-- Proffessor
		[71278] = Defaults(), -- Choking Gas Bomb
		[70215] = Defaults(), -- Gaseous Bloat
		[72549] = Defaults(), -- Malleable Goo
		[70953] = Defaults(), -- Plague Sickness
		[72856] = Defaults(), -- Unbound Plague
		[70447] = Defaults(), -- Volatile Ooze Adhesive

		-- Blood Prince Council
		[72796] = Defaults(), -- Glittering Sparks
		[71822] = Defaults(), -- Shadow Resonance

		-- Blood-Queen Lana'thel
		[72265] = Defaults(), -- Delirious Slash
		[71473] = Defaults(), -- Essence of the Blood Queen
		[71474] = Defaults(), -- Frenzied Bloodthirst
		[71340] = Defaults(), -- Pact of the Darkfallen
		[71265] = Defaults(), -- Swarming Shadows
		[70923] = Defaults(), -- Uncontrollable Frenzy

		-- Valithria Dreamwalker
		[71733] = Defaults(), -- Acid Burst
		[71738] = Defaults(), -- Corrosion
		[70873] = Defaults(), -- Emerald Vigor
		[71283] = Defaults(), -- Gut Spray

		-- Sindragosa
		[70106] = Defaults(), -- Chilled to the Bone
		[70126] = Defaults(), -- Frost Beacon
		[70157] = Defaults(), -- Ice Tomb
		[69766] = Defaults(), -- Instability
		[69762] = Defaults(), -- Unchained Magic

		-- The Lich King
		[72762] = Defaults(), -- Defile
		[70541] = Defaults(), -- Infest
		[70337] = Defaults(), -- Necrotic plague
		[72149] = Defaults(), -- Shockwave
		[69409] = Defaults(), -- Soul Reaper
		[69242] = Defaults(), -- Soul Shriek

	-- The Ruby Sanctum
		-- Trash
		-- Baltharus the Warborn
		[75887] = Defaults(), -- Blazing Aura
		[74502] = Defaults(), -- Enervating Brand
		-- General Zarithrian
		[74367] = Defaults(), -- Cleave Armor

		-- Halion
		[74562] = Defaults(), -- Fiery Combustion
		[74567] = Defaults(), -- Mark of Combustion
		[74792] = Defaults(), -- Soul Consumption
		[74795] = Defaults(), -- Mark of Consumption
	}
};

--Spells that we want to show the duration backwards
E.ReverseTimer = {

}

--BuffWatch
--List of personal spells to show on unitframes as icon
local function ClassBuff(id, point, color, anyUnit, onlyShowMissing, style, displayText, decimalThreshold, textColor, textThreshold, xOffset, yOffset, sizeOverride)
	local r, g, b = unpack(color);
	local r2, g2, b2 = 1, 1, 1;
	if(textColor) then
		r2, g2, b2 = unpack(textColor);
	end

	return {["enabled"] = true, ["id"] = id, ["point"] = point, ["color"] = {["r"] = r, ["g"] = g, ["b"] = b},
	["anyUnit"] = anyUnit, ["onlyShowMissing"] = onlyShowMissing, ["style"] = style or "coloredIcon", ["displayText"] = displayText or false, ["decimalThreshold"] = decimalThreshold or 5,
	["textColor"] = {["r"] = r2, ["g"] = g2, ["b"] = b2}, ["textThreshold"] = textThreshold or -1, ["xOffset"] = xOffset or 0, ["yOffset"] = yOffset or 0, ["sizeOverride"] = sizeOverride or 0};
end

G.unitframe.buffwatch = {
	PRIEST = {
		[6788] = ClassBuff(6788, "TOPLEFT", {1, 0, 0}, true), -- Ослабленная душа
		[10060] = ClassBuff(10060 , "RIGHT", {227/255, 23/255, 13/255}), -- Придание сил
		[48066] = ClassBuff(48066, "BOTTOMRIGHT", {0.81, 0.85, 0.1}, true), -- Слово силы: Щит
		[48068] = ClassBuff(48068, "BOTTOMLEFT", {0.4, 0.7, 0.2}), -- Обновление
		[48111] = ClassBuff(48111, "TOPRIGHT", {0.2, 0.7, 0.2}), -- Молитва восстановления
	},
	DRUID = {
		[48441] = ClassBuff(48441, "TOPRIGHT", {0.8, 0.4, 0.8}), -- Омоложение
		[48443] = ClassBuff(48443, "BOTTOMLEFT", {0.2, 0.8, 0.2}), -- Восстановление
		[48451] = ClassBuff(48451, "TOPLEFT", {0.4, 0.8, 0.2}), -- Жизнецвет
		[53251] = ClassBuff(53251, "BOTTOMRIGHT", {0.8, 0.4, 0}), -- Буйный рост
	},
	PALADIN = {
		[1038] = ClassBuff(1038, "BOTTOMRIGHT", {238/255, 201/255, 0}, true), -- Длань спасения
		[1044] = ClassBuff(1044, "BOTTOMRIGHT", {221/255, 117/255, 0}, true), -- Длань свободы
		[6940] = ClassBuff(6940, "BOTTOMRIGHT", {227/255, 23/255, 13/255}, true), -- Длань жертвенности
		[10278] = ClassBuff(10278, "BOTTOMRIGHT", {0.2, 0.2, 1}, true), -- Длань защиты
		[53563] = ClassBuff(53563, "TOPLEFT", {0.7, 0.3, 0.7}), -- Частица Света
		[53601] = ClassBuff(53601, "TOPRIGHT", {0.4, 0.7, 0.2}), -- Священный щит
	},
	SHAMAN = {
		[16237] = ClassBuff(16237, "BOTTOMLEFT", {0.4, 0.7, 0.2}), -- Стойкость предков
		[49284] = ClassBuff(49284, "TOPRIGHT", {0.2, 0.7, 0.2}), -- Щит земли
		[52000] = ClassBuff(52000, "BOTTOMRIGHT", {0.7, 0.4, 0}), -- Жизнь земли
		[61301] = ClassBuff(61301, "TOPLEFT", {0.7, 0.3, 0.7}), -- Быстрина
	},
	ROGUE = {
		[57933] = ClassBuff(57933, "TOPRIGHT", {227/255, 23/255, 13/255}), -- Маленькие хитрости
	},
	MAGE = {
		[54646] = ClassBuff(54646, "TOPRIGHT", {0.2, 0.2, 1}), -- Магическая консетрация
	},
	WARRIOR = {
		[3411] = ClassBuff(3411, "TOPRIGHT", {227/255, 23/255, 13/255}), -- Вмешательство
		[59665] = ClassBuff(59665, "TOPLEFT", {0.2, 0.2, 1}), -- Бдительность
	},
	DEATHKNIGHT = {
		[49016] = ClassBuff(49016, "TOPRIGHT", {227/255, 23/255, 13/255}) -- Истерия
	},
	HUNTER = {}
};

P["unitframe"]["filters"] = {
	["buffwatch"] = {}
};

G.unitframe.ChannelTicks = {
	-- Чернокнижник
	[SpellName(1120)] = 5, -- Похищение души
	[SpellName(689)] = 5, -- Похищение жизни
	[SpellName(5138)] = 5, -- Похищение маны
	[SpellName(5740)] = 4, -- Огненный ливень
	[SpellName(755)] = 10, -- Канал здоровья
	-- Друид
	[SpellName(44203)] = 4, -- Спокойствие
	[SpellName(16914)] = 10, -- Гроза
	-- Жрец
	[SpellName(15407)] = 3, -- Пытка разума
	[SpellName(48045)] = 5, -- Искушение разума
	[SpellName(47540)] = 3, -- Исповедь
	-- Маг
	[SpellName(5143)] = 5, -- Чародейские стрелы
	[SpellName(10)] = 8, -- Снежная буря
	[SpellName(12051)] = 4 -- Прилив сил
};

G.unitframe.AuraBarColors = {
	[SpellName(2825)] = {r = 250/255, g = 146/255, b = 27/255},	-- Жажда крови
	[SpellName(32182)] = {r = 250/255, g = 146/255, b = 27/255} -- Героизм
};

G.unitframe.InvalidSpells = {

};

G.unitframe.DebuffHighlightColors = {
	[SpellName(25771)] = {enable = false, style = "FILL", color = { r = 0.85, g = 0, b = 0, a = 0.85 }}
};

G.oldBuffWatch = {
	PRIEST = {
		ClassBuff(6788, "TOPLEFT", {1, 0, 0}, true), -- Ослабленная душа
		ClassBuff(10060 , "RIGHT", {227/255, 23/255, 13/255}), -- Придание сил
		ClassBuff(48066, "BOTTOMRIGHT", {0.81, 0.85, 0.1}, true), -- Слово силы: Щит
		ClassBuff(48068, "BOTTOMLEFT", {0.4, 0.7, 0.2}), -- Обновление
		ClassBuff(48111, "TOPRIGHT", {0.2, 0.7, 0.2}), -- Молитва восстановления
	},
	DRUID = {
		ClassBuff(48441, "TOPRIGHT", {0.8, 0.4, 0.8}), -- Омоложение
		ClassBuff(48443, "BOTTOMLEFT", {0.2, 0.8, 0.2}), -- Востановление
		ClassBuff(48451, "TOPLEFT", {0.4, 0.8, 0.2}), -- Жизнецвет
		ClassBuff(53251, "BOTTOMRIGHT", {0.8, 0.4, 0}), -- Буйный рост
	},
	PALADIN = {
		ClassBuff(1038, "BOTTOMRIGHT", {238/255, 201/255, 0}, true), -- Длань спасения
		ClassBuff(1044, "BOTTOMRIGHT", {221/255, 117/255, 0}, true), -- Длань свободы
		ClassBuff(6940, "BOTTOMRIGHT", {227/255, 23/255, 13/255}, true), -- Длань жертвенности
		ClassBuff(10278, "BOTTOMRIGHT", {0.2, 0.2, 1}, true), -- Длань защиты
		ClassBuff(53563, "TOPLEFT", {0.7, 0.3, 0.7}), -- Частица Света
		ClassBuff(53601, "TOPRIGHT", {0.4, 0.7, 0.2}), -- Священный щит
	},
	SHAMAN = {
		ClassBuff(16237, "BOTTOMLEFT", {0.4, 0.7, 0.2}), -- Стойкость предков
		ClassBuff(49284, "TOPRIGHT", {0.2, 0.7, 0.2}), -- Щит земли
		ClassBuff(52000, "BOTTOMRIGHT", {0.7, 0.4, 0}), -- Жизнь земли
		ClassBuff(61301, "TOPLEFT", {0.7, 0.3, 0.7}), -- Быстрина
	},
	ROGUE = {
		ClassBuff(57933, "TOPRIGHT", {227/255, 23/255, 13/255}), -- Маленькие хитрости
	},
	MAGE = {
		ClassBuff(54646, "TOPRIGHT", {0.2, 0.2, 1}), -- Магическая концентрация
	},
	WARRIOR = {
		ClassBuff(3411, "TOPRIGHT", {227/255, 23/255, 13/255}), -- Вмешательство
		ClassBuff(59665, "TOPLEFT", {0.2, 0.2, 1}), -- Бдительность
	},
	DEATHKNIGHT = {
		ClassBuff(49016, "TOPRIGHT", {227/255, 23/255, 13/255}) -- Истерия
	}
};