local E, L, V, P, G, _ = unpack(select(2, ...));

local print, unpack = print, unpack;

local GetSpellInfo = GetSpellInfo;
local UnitClass = UnitClass;

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

local function DefaultsID(spellID, priorityOverride)
	return {["enable"] = true, ["spellID"] = spellID, ["priority"] = priorityOverride or 0};
end
G.unitframe.aurafilters = {};

G.unitframe.aurafilters["CCDebuffs"] = {
	["type"] = "Whitelist",
	["spells"] = {
	-- Рыцарь смерти
		[SpellName(47476)] = Defaults(), -- Удушение
		[SpellName(51209)] = Defaults(), -- Ненасытная стужа
	-- Друид
		[SpellName(99)] = Defaults(), -- Устрашающий рев
		[SpellName(339)] = Defaults(), -- Гнев деревьев
		[SpellName(2637)] = Defaults(), -- Спячка
		[SpellName(5211)] = Defaults(), -- Оглушить
		[SpellName(9005)] = Defaults(), -- Наскок
		[SpellName(22570)] = Defaults(), -- Колечение
		[SpellName(33786)] = Defaults(), -- Смерч
		[SpellName(45334)] = Defaults(), -- Звериная атака - эффект
	-- Охотник
		[SpellName(1513)] = Defaults(), -- Отпугивание зверя
		[SpellName(3355)] = Defaults(), -- Эффект замораживающей ловушки
		[SpellName(19386)] = Defaults(), -- Укус виверны
		[SpellName(19503)] = Defaults(), -- Дезориентирующий выстрел
		[SpellName(24394)] = Defaults(), -- Устрашение
		[SpellName(34490)] = Defaults(), -- Глушащий выстрел
		[SpellName(50245)] = Defaults(), -- Шип
		[SpellName(50519)] = Defaults(), -- Ультразвук
		[SpellName(50541)] = Defaults(), -- Хватка
		[SpellName(54706)] = Defaults(), -- Ядовитая поутина
		[SpellName(56626)] = Defaults(), -- Ужалить
		[SpellName(60210)] = Defaults(), -- Эффект замораживающей стрелы
		[SpellName(64803)] = Defaults(), -- Удержание
	-- Маг
		[SpellName(118)] = Defaults(), -- Преврашение
		[SpellName(122)] = Defaults(), -- Кольцо льда
		[SpellName(18469)] = Defaults(), -- Антимагия - немота
		[SpellName(31589)] = Defaults(), -- Замедление
		[SpellName(31661)] = Defaults(), -- Дыхание дракона
		[SpellName(33395)] = Defaults(), -- Холод
		[SpellName(44572)] = Defaults(), -- Глубокая заморозка
		[SpellName(55080)] = Defaults(), -- Разрушенная преграда
		[SpellName(61305)] = Defaults(), -- Превращение
		[SpellName(55021)] = Defaults(), -- Антимагия - немота
	-- Паладин
		[SpellName(853)] = Defaults(), -- Молот правосудия
		[SpellName(10326)] = Defaults(), -- Изгнание зла
		[SpellName(20066)] = Defaults(), -- Покаяние
		[SpellName(31935)] = Defaults(), -- Щит мстителя
	-- Жрец
		[SpellName(605)] = Defaults(), -- Контроль над разумом
		[SpellName(8122)] = Defaults(), -- Ментальный крик
		[SpellName(9484)] = Defaults(), -- Сковывание нежити
		[SpellName(15487)] = Defaults(), -- Безмолвие
		[SpellName(64044)] = Defaults(), -- Глубинный ужас
	-- Разбойник
		[SpellName(408)] = Defaults(), -- Удар по почкам
		[SpellName(1330)] = Defaults(), -- Гаррота - немота
		[SpellName(1776)] = Defaults(), -- Парализующий удар
		[SpellName(1833)] = Defaults(), -- Подлый трюк
		[SpellName(2094)] = Defaults(), -- Ослепление
		[SpellName(6770)] = Defaults(), -- Ошеломление
		[SpellName(18425)] = Defaults(), -- Пинок - немота
		[SpellName(51722)] = Defaults(), -- Долой оружие
	-- Шаман
		[SpellName(3600)] = Defaults(), -- Оковы земли
		[SpellName(8056)] = Defaults(), -- Ледяной шок
		[SpellName(39796)] = Defaults(), -- Оглушение каменного когтя
		[SpellName(51514)] = Defaults(), -- Сглаз
		[SpellName(63685)] = Defaults(), -- Заморозка
		[SpellName(64695)] = Defaults(), -- Хватка земли
	-- Чернокнижник
		[SpellName(710)] = Defaults(), -- Изгнание
		[SpellName(5782)] = Defaults(), -- Страх
		[SpellName(6358)] = Defaults(), -- Соблазн
		[SpellName(6789)] = Defaults(), -- Лик смерти
		[SpellName(17928)] = Defaults(), -- Вой ужаса
		[SpellName(24259)] = Defaults(), -- Запрет чар
		[SpellName(30283)] = Defaults(), -- Неистовство Тьмы
	-- Воин
		[SpellName(676)] = Defaults(), -- Разоружие
		[SpellName(7922)] = Defaults(), -- Наскок и оглушение
		[SpellName(18498)] = Defaults(), -- Обет молчания - немота
		[SpellName(20511)] = Defaults(), -- Устрашающий крик
	-- Racial
		[SpellName(25046)] = Defaults(), -- Волшебный поток
		[SpellName(20549)] = Defaults(), -- Громовой поступь
	--PVE Дебаффы
		
	-- Король лич
		[SpellName(73787)] = Defaults() -- Мертвящая чума
	}
};

G.unitframe.aurafilters["TurtleBuffs"] = {
	["type"] = "Whitelist",
	["spells"] = {
	-- Маг
		[SpellName(45438)] = Defaults(5), -- Ледяная глыба
	-- Рыцарь сперти
		[SpellName(48707)] = Defaults(5), -- Антимагический панцирь
		[SpellName(48792)] = Defaults(), -- Незыблемость льда
		[SpellName(49039)] = Defaults(), -- Перерождение
		[SpellName(50461)] = Defaults(), -- Зона антимагии
		[SpellName(55233)] = Defaults(), -- Кровь вампира
	-- Жрец
		[SpellName(33206)] = Defaults(3), -- Подавление боли
		[SpellName(47585)] = Defaults(5), -- Слияние с тьмой
		[SpellName(47788)] = Defaults(), -- Оберегающий дух
	-- Чернокнижник
	
	-- Друид
		[SpellName(22812)] = Defaults(2), -- Дубовая кожа
		[SpellName(61336)] = Defaults(), -- Инстинкт выживания
	-- Охотник
		[SpellName(19263)] = Defaults(5), -- Сдерживание
		[SpellName(53480)] = Defaults(), -- Рев самопожертвования
	-- Разбойник
		[SpellName(5277)] = Defaults(5), -- Ускользание
		[SpellName(31224)] = Defaults(), -- Плащь Теней
		[SpellName(45182)] = Defaults(), -- Обман смерти
	-- Шаман
		[SpellName(30823)] = Defaults(), -- Ярость шамана
	-- Паладин
		[SpellName(498)] = Defaults(2), -- Божественная защита
		[SpellName(642)] = Defaults(5), -- Божественный щит
		[SpellName(1022)] = Defaults(5), -- Длань защиты
		[SpellName(6940)] = Defaults(), -- Длань жертвенности
		[SpellName(31821)] = Defaults(3), -- Мастер аур
	-- Воин
		[SpellName(871)] = Defaults(3), -- Глухая оборона
		[SpellName(55694)] = Defaults() -- Безудержное восстановление
	}
};

G.unitframe.aurafilters["PlayerBuffs"] = {
	["type"] = "Whitelist",
	["spells"] = {
	-- Маг
		[SpellName(12042)] = Defaults(), -- Мощь тайной магии
		[SpellName(12051)] = Defaults(), -- Прилив сил
		[SpellName(12472)] = Defaults(), -- Стальная кровь
		[SpellName(32612)] = Defaults(), -- Невидимость
		[SpellName(45438)] = Defaults(), -- Ледяная глыба
	-- Рыцарь сперти
		[SpellName(48707)] = Defaults(), -- Антимагический панцирь
		[SpellName(48792)] = Defaults(), -- Незыблемость льда
		[SpellName(49016)] = Defaults(), -- Истерия
		[SpellName(49039)] = Defaults(), -- Перерождение
		[SpellName(49222)] = Defaults(), -- Костяной щит
		[SpellName(50461)] = Defaults(), -- Зона антимагии
		[SpellName(51271)] = Defaults(), -- Несокрушимая броня
		[SpellName(55233)] = Defaults(), -- Кровь вампира
	-- Жрец
		[SpellName(6346)] = Defaults(), -- Защита от страха
		[SpellName(10060)] = Defaults(), -- Придание сил
		[SpellName(27827)] = Defaults(), -- Дух воздания
		[SpellName(33206)] = Defaults(), -- Подавление боли
		[SpellName(47585)] = Defaults(), -- Слияние с тьмой
		[SpellName(47788)] = Defaults(), -- Оберегающий дух
	-- Чернокнижник
	
	-- Друид
	
	-- Охотник
	
	-- Разбойник
	
	-- Шаман
		[SpellName(2825)] = Defaults(), -- Жажда крови
		[SpellName(8178)] = Defaults(), -- Эффект тотема заземления
		[SpellName(16166)] = Defaults(), -- Покорение стехий
		[SpellName(16188)] = Defaults(), -- Природная стремительность
		[SpellName(16191)] = Defaults(), -- Тотем прилива маны
		[SpellName(30823)] = Defaults(), -- Ярость шамана
		[SpellName(32182)] = Defaults(), -- Героизм
		[SpellName(58875)] = Defaults(), -- Поступь духа
	-- Паладин
	
	-- Воин
	
	-- Рассовые
		[SpellName(20594)] = Defaults(), -- Каменная форма
		[SpellName(59545)] = Defaults(), -- Дар наару
		[SpellName(20572)] = Defaults(), -- Кровавое неистовство
		[SpellName(26297)] = Defaults() -- Берсек
	}
};

G.unitframe.aurafilters["Blacklist"] = {
	["type"] = "Blacklist",
	["spells"] = {
		[SpellName(6788)] = Defaults(), -- Ослабленная душа
		[SpellName(8326)] = Defaults(), -- Призрак
		[SpellName(15007)] = Defaults(), -- Слабость после воскрешения
		[SpellName(23445)] = Defaults(), -- Злой двойник
		[SpellName(24755)] = Defaults(), -- Конфета или жизнь
		[SpellName(25771)] = Defaults(), -- Воздержанность
		[SpellName(26013)] = Defaults(), -- Дезертир
		[SpellName(36032)] = Defaults(), -- Чародейская вспышка
		[SpellName(36893)] = Defaults(), -- Неисправность транспортера
		[SpellName(36900)] = Defaults(), -- Расщипление души: Зло!
		[SpellName(36901)] = Defaults(), -- Расщипление души: Добро
		[SpellName(41425)] = Defaults(), -- Гипотермия
		[SpellName(55711)] = Defaults(), -- Сердце феникса
		[SpellName(57723)] = Defaults(), -- Изнеможение
		[SpellName(57724)] = Defaults(), -- Пресыщение
		[SpellName(58539)] = Defaults(), -- Тело наблюдателя
		[SpellName(67604)] = Defaults(), -- Накопление энергии
		[SpellName(69127)] = Defaults(), -- Холод Трона
		[SpellName(71041)] = Defaults(), -- Покинувший подземелье
	-- Blood Princes
		[SpellName(71911)] = Defaults(), -- Теневой резонанс
	-- Festergut
		[SpellName(70852)] = Defaults(), -- Вязкая гадость
		[SpellName(72144)] = Defaults(), -- Шлейф оранжевой заразы
		[SpellName(73034)] = Defaults(), -- Зараженные гнилью споры
	-- Rotface
		[SpellName(72145)] = Defaults(), -- Шлейф зеленой заразы
	-- Putricide
		[SpellName(72460)] = Defaults(), -- Удушливый газ
		[SpellName(72511)] = Defaults() -- Мутация
	}
};

G.unitframe.aurafilters["Whitelist"] = {
	["type"] = "Whitelist",
	["spells"] = {
		[SpellName(1022)] = Defaults(), -- Длань защиты
		[SpellName(1490)] = Defaults(), -- Проклятие стихий
		[SpellName(2825)] = Defaults(), -- Жажда крови
		[SpellName(12051)] = Defaults(), -- Прилив сил
		[SpellName(18708)] = Defaults(), -- Господство Скверны
		[SpellName(22812)] = Defaults(), -- Дубовая кожа
		[SpellName(29166)] = Defaults(), -- Озаренье
		[SpellName(31821)] = Defaults(), -- Мастер аур
		[SpellName(32182)] = Defaults(), -- Героизм
		[SpellName(33206)] = Defaults(), -- Подавление боли
		[SpellName(47788)] = Defaults(), -- Оберегающий дух
		[SpellName(54428)] = Defaults(), -- Святая клятва
	-- Turtling abilities
		[SpellName(871)] = Defaults(), -- Глухая оборона
		[SpellName(19263)] = Defaults(), -- Сдерживание
		[SpellName(31224)] = Defaults(), -- Плащь Теней
		[SpellName(48707)] = Defaults(), -- Антимагический панцирь
	-- Imm
		[SpellName(642)] = Defaults(), -- Божественный щит
		[SpellName(45438)] = Defaults(), -- Ледяная глыба
	-- Offensive Shit
		[SpellName(31884)] = Defaults(), -- Гнев карателя
		[SpellName(34471)] = Defaults(), -- Зверь внутри
	}
};

G.unitframe.aurafilters["Whitelist (Strict)"] = {
	["type"] = "Whitelist",
	["spells"] = {
		
	}
};

G.unitframe.aurafilters["RaidDebuffs"] = { -- Рейд дебаффы
	["type"] = "Whitelist",
	["spells"] = {
	-- Наксрамас
		[SpellName(27808)] = Defaults(), -- Ледяной взрыв
		[SpellName(28408)] = Defaults(), -- Цепи Кел"Тузада
		[SpellName(32407)] = Defaults(), -- Странная аура
	-- Ульдуар
		[SpellName(66313)] = Defaults(), -- Огненная бомба
		[SpellName(63134)] = Defaults(), -- Благословение Сары
		[SpellName(62717)] = Defaults(), -- Шлаковый ковш
		[SpellName(63018)] = Defaults(), -- Опаляющий свет
		[SpellName(64233)] = Defaults(), -- Гравитационная бомба
		[SpellName(63495)] = Defaults(), -- Статический сбой
	-- Испытание крестоносца
		[SpellName(66406)] = Defaults(), -- Получи снобольда!
		[SpellName(67574)] = Defaults(), -- Вас преследует Ануб"арак
		[SpellName(68509)] = Defaults(), -- Пронизывающий холод
		[SpellName(67651)] = Defaults(), -- Арктическое дыхание
		[SpellName(68127)] = Defaults(), -- Пламя Легиона
		[SpellName(67049)] = Defaults(), -- Испепеление плоти
		[SpellName(66869)] = Defaults(), -- Горящая желчь
		[SpellName(66823)] = Defaults(), -- Паралитический токсин
	-- Цитадель Ледяной Кароны
		[SpellName(71224)] = Defaults(), -- Мутировавшая инфекция
		[SpellName(71822)] = Defaults(), -- Теневой резонанс
		[SpellName(70447)] = Defaults(), -- Выделение неустойчивого слизнюка
		[SpellName(72293)] = Defaults(), -- Метка падшего воителя
		[SpellName(72448)] = Defaults(), -- Руна крови
		[SpellName(71473)] = Defaults(), -- Сущность Кровавой королевы
		[SpellName(71624)] = Defaults(), -- Безумный выпад
		[SpellName(70923)] = Defaults(), -- Неконтролируемое бешенство
		[SpellName(70588)] = Defaults(), -- Падавление
		[SpellName(71738)] = Defaults(), -- Коррозия
		[SpellName(71733)] = Defaults(), -- Кислотный взрыв
		[SpellName(72108)] = Defaults(), -- Смерть и разложение
		[SpellName(71289)] = Defaults(), -- Господство над разумом
		[SpellName(69762)] = Defaults(), -- Освобожденная магия
		[SpellName(69651)] = Defaults(), -- Ранящий удар
		[SpellName(69065)] = Defaults(), -- Прокалывание
		[SpellName(71218)] = Defaults(), -- Губительный газ
		[SpellName(72442)] = Defaults(), -- Кипящая кровь
		[SpellName(72769)] = Defaults(), -- Запах крови
		[SpellName(69279)] = Defaults(), -- Газообразные споры
		[SpellName(70949)] = Defaults(), -- Сущность Кровавой королевы
		[SpellName(72151)] = Defaults(), -- Бешеная кровожадность
		[SpellName(71474)] = Defaults(), -- Бешеная кровожадность
		[SpellName(71340)] = Defaults(), -- Пакт Омраченных
		[SpellName(72985)] = Defaults(), -- Роящиеся тени
		[SpellName(71267)] = Defaults(), -- Роящиеся тени
		[SpellName(71264)] = Defaults(), -- Роящиеся тени
		[SpellName(71807)] = Defaults(), -- Ослепительные искры
		[SpellName(70873)] = Defaults(), -- Изумрудная энергия
		[SpellName(71283)] = Defaults(), -- Выброс внутренностей
		[SpellName(69766)] = Defaults(), -- Неустойчивость
		[SpellName(70126)] = Defaults(), -- Ледяная метка
		[SpellName(70157)] = Defaults(), -- Ледяной склеп
		[SpellName(71056)] = Defaults(), -- Ледяное дыхание
		[SpellName(70106)] = Defaults(), -- Обморожение
		[SpellName(70128)] = Defaults(), -- Таинственная энергия
		[SpellName(73785)] = Defaults(), -- Мертвящая чума
		[SpellName(73779)] = Defaults(), -- Заражение
		[SpellName(73800)] = Defaults(), -- Визг души
		[SpellName(73797)] = Defaults(), -- Жнец душ
		[SpellName(73708)] = Defaults(), -- Осквернение
		[SpellName(74322)] = Defaults(), -- Жнец душ
	-- Рубиновое святилище
		[SpellName(74502)] = Defaults(), -- Ослабляющее прижигание
		[SpellName(75887)] = Defaults(), -- Пылающая аура
		[SpellName(74562)] = Defaults(), -- Пылающий огонь
		[SpellName(74567)] = Defaults(), -- Метка пылающего огня
		[SpellName(74792)] = Defaults(), -- Пожирание души
		[SpellName(74795)] = Defaults(), -- Метка пожирания
	-- Разные
		[SpellName(67479)] = Defaults() -- Прокалывание
	}
};

--Spells that we want to show the duration backwards
E.ReverseTimer = {

}

--BuffWatch
--List of personal spells to show on unitframes as icon
local function ClassBuff(id, point, color, anyUnit, onlyShowMissing, style, displayText, decimalThreshold, textColor, textThreshold, xOffset, yOffset)
	local r, g, b = unpack(color);
	local r2, g2, b2 = 1, 1, 1;
	if(textColor) then
		r2, g2, b2 = unpack(textColor);
	end
	
	return {["enabled"] = true, ["id"] = id, ["point"] = point, ["color"] = {["r"] = r, ["g"] = g, ["b"] = b},
	["anyUnit"] = anyUnit, ["onlyShowMissing"] = onlyShowMissing, ["style"] = style or "coloredIcon", ["displayText"] = displayText or false, ["decimalThreshold"] = decimalThreshold or 5,
	["textColor"] = {["r"] = r2, ["g"] = g2, ["b"] = b2}, ["textThreshold"] = textThreshold or -1, ["xOffset"] = xOffset or 0, ["yOffset"] = yOffset or 0};
end

G.unitframe.buffwatch = { -- Индикатор баффов
	PRIEST = {
		[6788] = ClassBuff(6788, "TOPLEFT", {1, 0, 0}, true), -- Ослабленная душа
		[10060] = ClassBuff(10060 , "RIGHT", {227/255, 23/255, 13/255}), -- Придание сил
		[48066] = ClassBuff(48066, "BOTTOMRIGHT", {0.81, 0.85, 0.1}, true), -- Слово силы: Щит
		[48068] = ClassBuff(48068, "BOTTOMLEFT", {0.4, 0.7, 0.2}), -- Обновление
		[48111] = ClassBuff(48111, "TOPRIGHT", {0.2, 0.7, 0.2}), -- Молитва восстановления
	},
	DRUID = {
		[48441] = ClassBuff(48441, "TOPRIGHT", {0.8, 0.4, 0.8}), -- Омоложение
		[48443] = ClassBuff(48443, "BOTTOMLEFT", {0.2, 0.8, 0.2}), -- Востановление
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

G.unitframe.ChannelTicks = { -- Тики
	-- Чернокнижник
	[SpellName(1120)] = 5, -- "Похищение душы"
	[SpellName(689)] = 5, -- "Похишение жызни"
	[SpellName(5138)] = 5, -- "Похишение маны"
	[SpellName(5740)] = 4, -- "Огненный ливень"
	[SpellName(755)] = 10, -- "Канал здоровья"
	-- Друид
	[SpellName(44203)] = 4, -- "Спокайствие"
	[SpellName(16914)] = 10, -- "Гроза"
	-- Жрец
	[SpellName(15407)] = 3, -- "Пытка разума"
	[SpellName(48045)] = 5, -- "Искушение разума"
	[SpellName(47540)] = 3, -- "Исповедь"
	-- Маг
	[SpellName(5143)] = 5, -- "Чародейские стрелы"
	[SpellName(10)] = 8, -- "Снежная буря"
	[SpellName(12051)] = 4 -- "Прилив сил"
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
		ClassBuff(54646, "TOPRIGHT", {0.2, 0.2, 1}), -- Магическая консетрация
	},
	WARRIOR = {
		ClassBuff(3411, "TOPRIGHT", {227/255, 23/255, 13/255}), -- Вмешательство
		ClassBuff(59665, "TOPLEFT", {0.2, 0.2, 1}), -- Бдительность
	},
	DEATHKNIGHT = {
		ClassBuff(49016, "TOPRIGHT", {227/255, 23/255, 13/255}) -- Истерия
	}
};