-- Russian localization file for ruRU.
local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("ElvUI", "ruRU")
if not L then return; end

-- *_DESC locales
L['AURAS_DESC'] = 'Настройка иконок эффектов, находящихся у миникарты.'
L["BAGS_DESC"] = "Настройки сумок ElvUI"
L["CHAT_DESC"] = "Настройте отображение чата ElvUI."
L["DATATEXT_DESC"] = "Установка отображения информационных текстов."
L["ELVUI_DESC"] = "ElvUI это аддон для полной замены пользовательского интерфейса World of Warcraft."
L["NAMEPLATE_DESC"] = "Настройки индикаторов здоровья."
L["PANEL_DESC"] = "Регулирование размеров левой и правой панелей. Это окажет эффект на чат и сумки."
L["SKINS_DESC"] = "Установки скинов"
L["TOGGLESKIN_DESC"] = "Включить/выключить этот скин."
L["TOOLTIP_DESC"] = "Опций подсказки"
L["SEARCH_SYNTAX_DESC"] = [=[С добавлением библиотеки LibItemSearch, у вас появился доступ к большему количеству поисковых запросов. Здесь представлена документация по синтаксису поисковых запросов. Полная инструкция доступна по адресу: https://github.com/Jaliborc/LibItemSearch-1.2/wiki/Search-Syntax.

Специфический поик:
    • q:[качество] или quality:[качество]. Например, q:эпическое покажет все предметы эпического качества (слово "эпическое" не обязательно вводить до конца).
    • l:[уровень], lvl:[уровень] or level:[уровень]. Например, l:30 покажет все предметы с уровнем 30. Это относитя именно к уровню предметов, а не требуемому уровню персонажа.
    • t:[запрос], type:[запрос] or slot:[запрос]. Например, t:оружие покажет все предметы, являющиеся оружием.
    • n:[имя] or name:[имя]. Например, n:muffins покажет все предметы, в имени которых соержится "muffins".
    • s:[набор] or set:[набор]. Например, s:fire покажет предметы из наборов экипировки, название которых начинается с "fire".
    • tt:[запрос], tip:[запрос] or tooltip:[запрос]. Например, tt:уникальный покажет все предметы, которые являются уникальными или уникальными использующимися.


Операторы поиска:
    • ! : Обращает результат поиска. Например, !q:эпическое покажет все НЕ эпические предметы.
    • | : Объединет запросы. Например, "q:эпическое | t:оружие" отобразит все предметы эпического качества ИЛИ являющиеся оружием.
    • & : Суммирует запросы. Например, "q:эпическое & t:оружие" отобразит все оружие эпического качества.
    • >, <, <=, => : сразнения для численных запросов. Например, запрос "lvl: >30" покажет все предметы с уровнем выше 30.


Также могут быть использованы следующие параметры:
    • soulbound, bound, bop : персональные при поднятии.
    • bou : персональные при использовании.
    • boe : персональные при одевании.
    • boa : привязоные к учетной записи.
    • quest : специальные предметы для заданий.]=];
L['TEXT_FORMAT_DESC'] = [=[Строка для изменения вида текста.

Примеры:
[namecolor][name] [difficultycolor][smartlevel] [shortclassification]
[healthcolor][health:current-max]
[powercolor][power:current]

Форматы здоровья/резурсов:
'current' - текущее значение
'percent' - значение в процентах
'current-max' - текущее значение, за которым идет максимальное значение. Будет отображать только максимальное значение, если текущее равно ему.
'current-percent' - текущее значение, за которым идет значение в процентах.Будет отображать только максимальное значение, если текущее равно ему.
'current-max-percent' - текущее значение, максимальное значение, за которым идет значение в процентах, Будет отображать только максимальное значение, если текущее равно ему.
'deficit' - отображает значение недостающего до максимума здоровья/ресурса. Не будет отображать ничего, если текущее значение равно максимальному.

Форматы имени:
'name-short' - Имя с ограничением длины в 10 символов
'name-medium' - Имя с ограничением длины в 15 символов
'name-long' - Имя с ограничением длины в 20 символов

Для отключения оставьте поле пустым, для дополнительной информации посетите http://www.tukui.org]=];

-- Панели команд
L["Action Paging"] = "Переключение панелей"
L["ActionBars"] = "Панели команд"
L['Alpha'] = "Прозрачность"
L["Anchor Point"] = "Точка фиксации"
L['Animation snake :D'] = 'Анимация змея :D'
L["Backdrop"] = "Фон"
L['Bar '] = "Панель "
L["Button Size"] = "Размер кнопок"
L["Button Spacing"] = "Отступ кнопок"
L["Buttons Per Row"] = "Кнопок в ряду"
L["Buttons"] = "Кнопок"
L['Change the alpha level of the frame.'] = "Изменяет прозрачность этого элемента"
L["Color when the text is about to expire"] = "Цвет текста почти завершившегося восстановления."
L["Color when the text is in the days format."] = "Цвет текста времени восстановления в днях."
L["Color when the text is in the hours format."] = "Цвет текста времени восстановления в часах."
L["Color when the text is in the minutes format."] = "Цвет текста времени восстановления в минутах."
L["Color when the text is in the seconds format."] = "Цвет текста времени восстановления в секундах."
L["Cooldown Text"] = "Текст восстановления"
L["Days"] = "Дни"
L["Display bind names on action buttons."] = "Отображать назначенные клавиши на кнопках."
L["Display cooldown text on anything with the cooldown spiril."] = "Отображать время восстановления на кнопках/предметах."
L["Display macro names on action buttons."] = "Отображать названия макросов на кнопках."
L["Expiring"] = "Завершение"
L["Height Multiplier"] = "Множитель высоты"
L["Hours"] = "Часы"
L['Key Down'] = "При нажатии клавиши"
L["Keybind Mode"] = "Назначить клавиши"
L["Keybind Text"] = "Текст клавиш"
L["Low Threshold"] = "Минимальное значение"
L["Macro Text"] = "Названия макросов"
L["Minutes"] = "Минуты"
L["Mouse Over"] = "При наведении"
L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."] = "Умножает высоту или ширину фона панели на это значение. Это полезно, когда Вы хотите иметь более одной панели на данном фоне."
L["Restore Bar"] = "Восстановить панель"
L["Restore the actionbars default settings"] = "Восстанавливает настройки панели по умолчанию."
L["Scale"] = "Масштаб"
L["Seconds"] = "Секунды"
L['Speed of the animation when you hover'] = 'Скорость анимации при наведении'
L["The amount of buttons to display per row."] = "Количество кнопок в каждом ряду"
L["The amount of buttons to display."] = "Количество отображаемых кнопок."
L["The size of the action buttons."] = "Размер кнопок панели команд."
L["Threshold before text turns red and is in decimal form. Set to -1 for it to never turn red"] = "Время, после которого текст станет красным и начнет отображать доли секунды. Установите -1, чтобы не отображать текст в такой форме."
L["The first button anchors itself to this point on the bar."] = "Первая кнопка прикрепляется к этой точке панели"
L["Toggles the display of the actionbars backdrop."] = "Включить отображение фона панели команд."
L["Visibility State"] = "Статус отображения"
L["Width Multiplier"] = "Множитель ширины"
L[ [=[This works like a macro, you can run different situations to get the actionbar to page differently.
 Example: '[combat] 2;']=] ] = [=[Работает как макрос. Вы можете задать различные условия для отображения разных панелей.
 Пример: '[combat] 2;']=]
L[ [=[This works like a macro, you can run different situations to get the actionbar to show/hide differently.
 Example: '[combat] show;hide']=] ] = [=[Работает как макрос. Вы можете задать различные условия для показа/скрытия панели.
 Пример: '[combat] show;hide']=]

-- Сумки
L["Adjust the width of the bag frame."] = "Установить размер фрейма сумок";
L["Adjust the width of the bank frame."] = "Установить размер фрейма банка";
L["Align the width of the bag frame to fit inside the chat box."] = "Установить размер сумок/банка по ширине чата";
L["Align To Chat"] = "По чату";
L["Ascending"] = "Восходящее";
L["Bag-Bar"] = "Панель сумок";
L["Bar Direction"] = "Направление панели";
L["Blizzard Style"] = "Стиль Blizzard";
L["Bottom to Top"] = "Снизу вверх";
L["Button Size (Bag)"] = "Размер слотов сумок";
L["Button Size (Bank)"] = "Размер слотов банка";
L["Condensed"] = "Через запятую";
L['Currency Format'] = "Формат валюты";
L["Descending"] = "Нисходящее";
L["Direction the bag sorting will use to allocate the items."] = "Направление расположения предметов при сортировке.";
L["Display Item Level"] = "Отображать уровень предметов";
L["Displays item level on equippable items."] = "Отображает уровень предметов, которые можно надеть.";
L["Enable/Disable the all-in-one bag."] = "Включить/выключить режим сумки 'все в одной'. ";
L["Enable/Disable the Bag-Bar."] = "Включить/выключить панель сумок";
L["Full"] = "Полный";
L["Icons and Text"] = "Иконки и текст";
L["Ignore Items"] = "Игнорировать предметы";
L["Item Count Font"] = "Шрифт кол-ва предметов";
L["Item Level Threshold"] = "Ограничение уровня предметов";
L["Item Level"] = "Уровень предметов";
L["List of items to ignore when sorting. If you wish to add multiple items you must seperate the word with a comma."] = "Список предметов, игнорируемых при сортироваке. Если Вы хотите добавить несколько предметов, то должны разделять их запятой.";
L["Money Format"] = "Формат денег";
L['Panel Width (Bags)'] = "Ширина сумок";
L['Panel Width (Bank)'] = "Ширина банка";
L["Search Syntax"] = "Синтакс поиска";
L["Set the size of your bag buttons."] = "Установите размер кнопок на панели.";
L["Short (Whole Numbers)"] = "Короткий (целые)";
L["Short"] = "Короткий";
L["Show Coins"] = "Показывать монеты";
L["Smart"] = "Умный";
L["Sort Direction"] = "Направление сортировки"; -- Так же используется в Баффы и Дебаффы
L["Sort Inverted"] = "Инвертированная сортировка";
L["The direction that the bag frames be (Horizontal or Vertical)."] = "Расположение сумок (горизонтально или вертикально)";
L["The direction that the bag frames will grow from the anchor."] = "Направление, в котором будут расположены кнопки сумок относительно фиксатора.";
L["The display format of the currency icons that get displayed below the main bag. (You have to be watching a currency for this to display)"] = "Формат отображения валюты в сумках. (У вас должна быть выбрана валюта для отслеживания, чтобы видеть результат)";
L["The display format of the money text that is shown at the top of the main bag."] = "Формат отображения текста золота в верхней части основной сумки.";
L["The frame is not shown unless you mouse over the frame."] = "Отображать только при наведении мыши.";
L["The minimum item level required for it to be shown."] = "Минимальный уровень предмета, который будет показан в сумках.";
L["The size of the individual buttons on the bag frame."] = "Размер каждого слота в сумок";
L["The size of the individual buttons on the bank frame."] = "Размер каждого слота в банке";
L["The spacing between buttons."] = "Расстояние между кнопками";
L["Top to Bottom"] = "Сверху вниз";
L["Use coin icons instead of colored text."] = "Использовать иконки монет вместо окрашенного текста.";
L["X Offset Bags"] = "Отступ сумок по X";
L["X Offset Bank"] = "Отступ банка по X";
L["Y Offset Bags"] = "Отступ сумок по Y";
L["Y Offset Bank"] = "Отступ банка по Y";

--Buffs and Debuffs
L['Begin a new row or column after this many auras.'] = "Начинать новый ряд/столбец после этого количества аур."
L['Count xOffset'] = "Отступ стаков по X"
L['Count yOffset'] = "Отступ стаков по Y"
L['Defines how the group is sorted.'] = "Определяет условия сортировки"
L['Defines the sort order of the selected sort method.'] = "Определяет порядок в выбранном методе сортировки."
L['Disabled Blizzard'] = "Отключить ауры Blizzard"
L["Fade Threshold"] = "Значение мерцания"
L['Index'] = "Порядок наложения"
L['Indicate whether buffs you cast yourself should be separated before or after.'] = "Определяет должны ли Ваши баффы находиться отдельно перед или после остальных."
L['Limit the number of rows or columns.'] = "Определяет максимальное количество рядов/столбцов."
L['Max Wraps'] = "Максимум рядов"
L['No Sorting'] = "Без сортировки"
L["Other's First"] = "Сначала чужие"
L['Seperate'] = "Разделение"
L['Set the size of the individual auras.'] = "Устанавливает размер аур"
L['Sort Method'] = "Метод сортировки"
L['The direction the auras will grow and then the direction they will grow after they reach the wrap after limit.'] = "Направление роста аур и сторона с которой будет добавляться новый ряд."
L['Threshold before text changes red, goes into decimal form, and the icon will fade. Set to -1 to disable.'] = "Пороговое значение, после которого цвет текста изменится на красный и начнет показывать десятые доли секунд, а иконка начнет мигать. Установите на -1 для отключения"
L['Time xOffset'] = "Отступ времени по X"
L['Time yOffset'] = "Отступ времени по Y"
L['Time'] = "Время"
L['Wrap After'] = "Размер ряда"
L['Your Auras First'] = "Сначала свои"

--Chat
L['Above Chat'] = "Над чатом"
L["Attempt to create URL links inside the chat."] = "Пытаться создавать интернет-ссылки в чате."
L['Attempt to lock the left and right chat frame positions. Disabling this option will allow you to move the main chat frame anywhere you wish.'] = "Закрепляет позиции левого и правого чата к соответственным панелям. Отключение этой опции позволит перемещать чат независимо от них."
L['Below Chat'] = "Под чатом"
L['Chat EditBox Position'] = "Позиция поля ввода"
L['Chat History'] = "История чата"
L["Copy Text"] = "Копировать текст"
L["Display the hyperlink tooltip while hovering over a hyperlink."] = "Отображать подсказку ссылки на при наведении на нее мыши. Действует на предметы, достижения, сохранения подземелий и тд."
L['Fade Chat'] = "Затухание чата"
L["Fade Tabs No Backdrop"] = "Затухание без фона";
L['Fade the chat text when there is no activity.'] = "Исчезновение строк чата при отсутствии аткивности"
L["Fade Undocked Tabs"] = "Затухание незакрепленных";
L["Fades the text on chat tabs that are docked in a panel where the backdrop is disabled."] = "Исчезновение текста на вкладках, закрепленных на какой-либо из панелей чата, при отключенном фоне.";
L["Fades the text on chat tabs that are not docked at the left or right chat panel."] = "Заставляет текст на вкладках, не закрепленных на правой или левой панелях чата, исчезать до наведения курсора.";
L["Font Outline"] = "Граница шрифта" --Also used in UnitFrames section
L["Font"] = "Шрифт"
L['Hide Both'] = "Скрыть оба"
L["Hyperlink Hover"] = "Подсказка над ссылками"
L["Keyword Alert"] = "Звук ключевых слов"
L['Keywords'] = "Ключевые слова"
L['Left Only'] = "Только левый"
L['List of words to color in chat if found in a message. If you wish to add multiple words you must seperate the word with a comma. To search for your current name you can use %MYNAME%.\n\nExample:\n%MYNAME%, ElvUI, RBGs, Tank'] = "Список слов для окрашивания, если они обнаружены в чате. Если Вы хотите добавить несколько слов, то разделяйте их запятыми. Для поиска имени Вашего текущего персонажа используйте %MYNAME%.\n\nПример:\n%MYNAME%, ElvUI, РБГ, Танк"
L['Lock Positions'] = "Закрепить"
L['Log the main chat frames history. So when you reloadui or log in and out you see the history from your last session.'] = "Записывать содержимое основных чатов. Таким образом, после перезагрузки интерфейса или входа/выхода из игры, Вы увидите сообщения из прошлой сессии."
L["No Alert In Combat"] = "Без оповещений в бою";
L["Number of time in seconds to scroll down to the bottom of the chat window if you are not scrolled down completely."] = "Время в секундах, через которое чат автоматически покрутится вниз до конца, если Вы не сделаете это вручную."
L["Panel Backdrop"] = "Фон панелей"
L["Panel Height"] = "Высота панели"
L["Panel Texture (Left)"] = "Текстура левой панели"
L["Panel Texture (Right)"] = "Текстура правой панели"
L['Panel Width'] = "Ширина панели"
L['Position of the Chat EditBox, if datatexts are disabled this will be forced to be above chat.'] = "Позиция поля ввода для чата. Если инфо-тексты отключены, оно всегда будет над чатом."
L["Prevent the same messages from displaying in chat more than once within this set amount of seconds, set to zero to disable."] = "Предотвращает появление одинаковых сообщения в чате чаще указанного количества секунд. Установите на нуль для отключения."
L['Right Only'] = "Только правый"
L['Right Panel Height'] = "Высота правого чата"
L['Right Panel Width'] = "Ширина правого чата"
L["Scroll Interval"] = "Интервал прокрутки"
L["Separate Panel Sizes"] = "Разные размеры панелей"
L["Set the font outline."] = "Устанавливает границу шрифта."
L["Short Channels"] = "Короткие каналы"
L["Shorten the channel names in chat."] = "Сокращать названия каналов чата."
L['Show Both'] = "Показать оба"
L["Spam Interval"] = "Интервал спама"
L["Sticky Chat"] = "Клейкий чат"
L["Tab Font Outline"] = "Граница шрифта вкладок"
L["Tab Font Size"] = "Размер шрифта вкладок"
L["Tab Font"] = "Шрифт вкладок"
L['Tab Panel Transparency'] = "Прозрачность панели вкладок"
L['Tab Panel'] = "Панель вкладок"
L['Toggle showing of the left and right chat panels.'] = "Переключить отображение панелей чата."
L['Toggle the chat tab panel backdrop.'] = "Показать/скрыть фон панели под вкладками чата"
L["URL Links"] = "Интернет-ссылки"
L["When opening the Chat Editbox to type a message having this option set means it will retain the last channel you spoke in. If this option is turned off opening the Chat Editbox should always default to the SAY channel."] = "При открытии строки ввода сообщения, если эта опция включена, будет выбран последний канал, в который Вы писали. В противном случае всегда будет установлен канал 'сказать'."
L["Whisper Alert"] = "Звук шепота"
L[ [=[Specify a filename located inside the World of Warcraft directory. Textures folder that you wish to have set as a panel background.

Please Note:
-The image size recommended is 256x128
-You must do a complete game restart after adding a file to the folder.
-The file type must be tga format.

Example: Interface\AddOns\ElvUI\media\textures\copy

Or for most users it would be easier to simply put a tga file into your WoW folder, then type the name of the file here.]=] ] = [=[Укажите имя файла в папке World of Warcraft, который Вы хотите использовать в качестве фона панелей.

Пожалуйста, учтите:
-Рекомендованный размер изображения 256x128
-Вы должны полностью перезапустить игру после добавления нового файла в папку.
-Тип файла должен быть tga.

Пример: Interface\AddOns\ElvUI\media\textures\copy

Для большинства пользователей будет легче просто положить tga файл в папку игры, а затем написать имя файла здесь.]=]

--Credits
L["Coding:"] = "Написание кода:"
L["Credits"] = "Благодарности"
L["Donations:"] = "Финансовая поддержка:"
L["ELVUI_CREDITS"] = "Я бы хотел выделить следующих людей, которые помогли мне в разработке аддона тестированием, кодингом и поддержкой при помощи донаций. Пожалуйста, отметьте, что в разделе донаций я написал имена людей, написавших мне в ЛС на форуме. Если Ваше имя пропущено, и Вы хотите его видеть, отправьте мне сообщение."
L["Testing:"] = "Тестирование:"

--DataTexts
L["24-Hour Time"] = "24х часовой формат"
L['Always Display'] = "Всегда отображать"
L['Battleground Texts'] = "Текст ПБ"
L['Change settings for the display of the location text that is on the minimap.'] = "Изменяет опции отображения названия локации на миникарте"
L['Datatext Panel (Left)'] = "Панель информации (левая)"
L['Datatext Panel (Right)'] = "Панель информации (правая)"
L["DataTexts"] = "Инфо-тексты"
L['Display data panels below the chat, used for datatexts.'] = "Отображать панели под чатом, используется для инфо-текстов"
L['Display minimap panels below the minimap, used for datatexts.'] = "Отображать панели информационных текстов под миникартой."
L["If not set to true then the server time will be displayed instead."] = "Если отключено, будет отображаться серверное время."
L["left"] = "Слева"
L["LeftChatDataPanel"] = "Левая панель чата"
L["LeftMiniPanel"] = "Миникарта, слева"
L["Local Time"] = "Местное время"
L['Location Text'] = "Текст локации"
L["middle"] = "В центре"
L['Minimap Mouseover'] = "При наведении мыши"
L['Minimap Panels'] = "Информация у миникарты"
L['Panel Transparency'] = "Прозрачность панели"
L["Panels"] = "Панели"
L["right"] = "Справа"
L["RightChatDataPanel"] = "Правая панель чата"
L["RightMiniPanel"] = "Миникарта, справа"
L["Toggle 24-hour mode for the time datatext."] = "Включить 24х часовой формат отображения времени."
L['When inside a battleground display personal scoreboard information on the main datatext bars.'] = "На полях боя отображать личную информацию на основных полосах инфо-текстов"

--Distributor
L["Must be in group with the player if he isn't on the same server as you."] = "Вы должны быть в группе в данным игроком, если он не с Вашего сервера."
L["Sends your current profile to your target."] = "Отправить текущий профиль цели."
L["Sends your filter settings to your target."] = "Отправить Ваши фильтры цели."
L["Share Current Profile"] = "Передать текущий профиль"
L["Share Filters"] = "Передать фильтры"
L["This feature will allow you to transfer, settings to other characters."] = "Эта функция позволит Вам передавать свои настройки другим персонажам."
L["You must be targeting a player."] = "Целью должен быть игрок."

--General
L["Accept Invites"] = "Принимать приглашения"
L['Adjust the position of the threat bar to either the left or right datatext panels.'] = "Изменяет позицию полосы угрозы"
L['Adjust the size of the minimap.'] = "Изменяет размер миникарты"
L["Announce Interrupts"] = "Объявлять о прерываниях"
L["Announce when you interrupt a spell to the specified chat channel."] = "Объявлять о прерванных Вами заклинаниях в указанный канал чата."
L["Attempt to support eyefinity/nvidia surround."] = "Пытаться поддерживать eyefinity/nvidia surround"
L['Auto Greed/DE'] = "Авто. не откажусь/распылить"
L["Auto Repair"] = "Автоматический ремонт"
L["Auto Scale"] = "Автоматический масштаб"
L["Automatically accept invites from guild/friends."] = "Автоматически принимать приглашения в группу от друзей и гильдии."
L["Automatically repair using the following method when visiting a merchant."] = "Автоматически чинить экипировку за счет выбранного источника при посещении торговца."
L["Automatically scale the User Interface based on your screen resolution"] = "Автоматически масштабировать UI в зависимости от вашего разрешения"
L['Automatically select greed or disenchant (when available) on green quality items. This will only work if you are the max level.'] = "Автоматически выбирать \"не откажусь\" или \"распылить\" (когда доступно) при розыгрыше предметов зеленого качества. Эта опция работает, только если вы максимального уровня."
L["Automatically vendor gray items when visiting a vendor."] = "Автоматически продавать предметы серого качества при посещении торговца."
L['Bottom Panel'] = "Нижняя панель"
L['Chat Bubbles Style'] = "Стиль облачков сообщений"
L["Controls what the transparency of the worldmap will be set to when you are moving."] = "Устанавливает прозрачность карты мира при движении персонажа."
L['Display a panel across the bottom of the screen. This is for cosmetic only.'] = "Отображать панель на нижней границе экрана. Это косметический элемент."
L['Display a panel across the top of the screen. This is for cosmetic only.'] = "Отображать панель на верхней границе экрана. Это косметический элемент."
L['Display emotion icons in chat.'] = "Показывать смайлы в чате"
L['Emotion Icons'] = "Иконки эмоций"
L["Enable/Disable the loot frame."] = "Включить/выключить окно добычи ElvUI."
L["Enable/Disable the loot roll frame."] = "Включить/выключить фрейм распределения добычи ElvUI."
L['Enable/Disable the minimap. |cffFF0000Warning: This will prevent you from seeing the consolidated buffs bar, and prevent you from seeing the minimap datatexts.|r'] = 'Включить/выключить миникарту. |cffFF0000ВНИМАНИЕ: Отключив карту, вы более не сможете видеть полосу объедененных эффектов и информационные тексты, привязанные к миникарте.|r'
L["General"] = "Общие"
L["Hide Error Text"] = "Прятать сообщения об ошибках"
L["Hides the red error text at the top of the screen while in combat."] = "Скрывать красный текст ошибок вверху экрана в бою."
L['Left'] = "Левый"
L["Log Taints"] = "Отслеживать недочеты"
L["Login Message"] = "Сообщение загрузки"
L["Loot Roll"] = "Раздел добычи"
L["Loot"] = "Добыча"
L["Make the world map smaller."] = "Сделать карту мира меньше. Она больше не будет занимать весь экран в увеличенном варианте.";
L["Map Alpha While Moving"] = "Прозрачность карты в движении"
L["Multi-Monitor Support"] = "Поддержка нескольких мониторов"
L["Name Font"] = "Шрифт имени"
L["Party / Raid"] = "Группа / Рейд";
L["Party Only"] = "Только группа";
L["Puts coordinates on the world map."] = "Добавляет координаты на карту мира.";
L["Raid Only"] = "Только рейд";
L['Remaining Time'] = 'Оставшееся время';
L['Remove Backdrop'] = "Скрыть фон"
L["Reset all frames to their original positions."] = "Установить все фреймы на позиции по умолчанию"
L["Reset Anchors"] = "Сбросить позиции"
L["Send ADDON_ACTION_BLOCKED errors to the Lua Error frame. These errors are less important in most cases and will not effect your game performance. Also a lot of these errors cannot be fixed. Please only report these errors if you notice a Defect in gameplay."] = "Отображать ошибки типа ADDON_ACTION_BLOCKED в фрейме ошибок lua. Эти ошибки в большинстве случаев не сильно важны и не влияют на производительность. Также многие из этих ошибок не могут быть исправлены. Пожалуйста, сообщайте об этих ошибках только если Вы заметите дефект в игре."
L['Skin Backdrop'] = "Стилизовать фон"
L["Skin the blizzard chat bubbles."] = "Стилизовать облачка сообщения Blizzard"
L["Smaller World Map"] = "Маленькая карта мира";
L["The font that appears on the text above players heads. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"] = "Шрифт, которым будет написан текст над головами игроков. |cffFF0000ВНИМАНИЕ: Необходим перезапуск игры или релог для начала действия этой настройки.|r"
L['Toggle Tutorials'] = "Показать помощь"
L['Top Panel'] = "Верхняя панель"
L["When you go AFK display the AFK screen."] = "Отображать специальный экран, когда вы переходите в состояние \"Отсутствует\".";
L["World Map Coordinates"] = "Координаты карты мира";

--Media
L["Backdrop color of transparent frames"] = "Цвет фона прозрачных фреймов"
L["Backdrop Color"] = "Цвет фона"
L["Backdrop Faded Color"] = "Цвет прозрачного фона"
L["Border Color"] = "Цвет окантовки"
L["Color some texts use."] = "Цвет некоторых текстов."
L["Colors"] = "Цвета" --Also in UnitFrames
L["CombatText Font"] = "Шрифт текста боя"
L["Default Font"] = "Шрифт по умолчанию"
L["Font Size"] = "Размер шрифта" --Also in UnitFrames
L["Fonts"] = "Шрифты"
L["Main backdrop color of the UI."] = "Основной цвет фона интерфейса."
L["Main border color of the UI. |cffFF0000This is disabled if you are using the pixel perfect theme.|r"] = "Основной цвет окантовок. Опция отключена при использовании pixel perfect."
L["Media"] = "Медиа"
L["Primary Texture"] = "Основная текстура"
L["Secondary Texture"] = "Вторичная текстура"
L["Set the font size for everything in UI. Note: This doesn't effect somethings that have their own seperate options (UnitFrame Font, Datatext Font, ect..)"] = "Установите размер шрифта для всего интерфейса. Это не действует на элементы с собственными настройками шрифтов (например, рамки юнитов)."
L["Textures"] = "Текстуры"
L["The font that combat text will use. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"] = "Шрифт текста боя. |cffFF0000ВНИМАНИЕ: это действие потребует перезапуска игры или повторного входа в мир.|r"
L["The font that the core of the UI will use."] = "Шрифт для основного интерфейса."
L["The texture that will be used mainly for statusbars."] = "Эта текстура будет использоваться в основном для полос состояния."
L["This texture will get used on objects like chat windows and dropdown menus."] = "Эта текстура будет использоваться для таких объектов как окно чата и выпадающие меню."
L["Value Color"] = "Цвет значений"

--Misc
L['Install'] = "Установка"
L["Run the installation process."] = "Запустить процесс установки"
L["Toggle Anchors"] = "Показать фиксаторы"
L["Unlock various elements of the UI to be repositioned."] = "Разблокировать элементы интерфейса для их перемещения."
L["Version"] = "Версия"

--NamePlates
L["Add Name"] = "Добавить имя"
L["Adjust nameplate size on low health"] = "Изменять размер при низком здоровье";
L["All"] = "Все";
L["Alpha of current target nameplate."] = "Прозрачность индикатора текущей цели.";
L["Alpha of nameplates that are not your current target."] = "Прозрачность индикаторов, не принадлежащих текущей цели.";
L["Always display your personal auras over the nameplate."] = "Всегда показывать ваши личные ауры на индикаторах";
L["Bad Transition"] = "Плохой переход";
L["Bring nameplate to front on low health"] = "Выносить на передний план при низком здоровье";
L["Bring to front on low health"] = "На передний план";
L["Can Interrupt"] = "Можно прервать";
L["Cast Bar"] = "Полоса заклинаний";
L["Castbar Height"] = "Высота полосы заклинаний";
L["Change color on low health"] = "Изменять цвет";
L["Color By Healthbar"]  = "По цвету здоровья";
L["Color By Raid Icon"] = "Окрашивать по рейдовой метке";
L["Color Name By Health Value"] = "Окрашивать имя по значению здоровья";
L["Color on low health"] = "Цвет";
L["Color the border of the nameplate yellow when it reaches this point, it will be colored red when it reaches half this value."] = "Окрашивать границу индикатора желтым, когда уровень здоровья достигает этого значения. Окраска сменится на красную при достижении половины этого значения.";
L["Combat Toggle"] = "Только в бою";
L["Combo Points"] = "Очки серии";
L["Configure Selected Filter"] = "Настроить выбранный фильтр";
L["Controls the height of the nameplate on low health"] = "Задать высоту при низком здоровье";
L["Controls the height of the nameplate"] = "Контролирует высоту индикатора";
L["Controls the width of the nameplate on low health"] = "Задать ширину при низком здоровье";
L["Controls the width of the nameplate"] = "Контролирует ширину индикатора";
L["Custom Color"] = "Свой цвет";
L["Custom Scale"] = "Свой масштаб";
L["Disable threat coloring for this plate and use the custom color."] = "Отключить цвет угрозы для этого индикатора и использовать установленный цвет.";
L["Display combo points on nameplates."] = "Отображать очки серии на индикаторах";
L["Enemy"] = "Враг"; --Also used in UnitFrames
L["Filter already exists!"] = "Фильтр уже существует!";
L["Filters"] = "Фильтры"; --Also used in UnitFrames
L["Friendly NPC"] = "Дружественный НИП";
L["Friendly Player"] = "Дружественный игрок";
L["Good Transition"] = "Хороший переход";
L["Hide"] = "Скрыть"; --Also used in DataTexts
L["Horrizontal Arrows (Inverted)"] = "Горизонтальные стрелки (внутрь)";
L["Horrizontal Arrows"] = "Горизонтальные стрелки";
L["Low Health Threshold"] = "Пороговое значение здоровья";
L["Low HP Height"] = "Высота";
L["Low HP Width"] = "Ширина";
L["Match the color of the healthbar."] = "Окрашивать по цвету полосы здоровья.";
L["NamePlates"] = "Индикаторы здоровья";
L["No Interrupt"] = "Нельзя прервать";
L["Non-Target Alpha"] = "Прозрачность не выделенных";
L["Number of Auras"] = "Кол-во аур";
L["Prevent any nameplate with this unit name from showing."] = "Не показывать индикаторы существ с данным именем.";
L["Raid Icon"] = "Иконка цели";
L["Reaction Coloring"] = "Цвета отношения";
L["Remove Name"] = "Удалить имя";
L["Scale if Low Health"] = "Размер при низком здоровье";
L["Scaling"] = "Масштаб";
L["Set the scale of the nameplate."] = "Установите масштаб индикатора";
L["Show Level"] = "Показывать уровень";
L["Show Name"] = "Показывать имя";
L["Show Personal Auras"] = "Показывать личные ауры";
L["Stretch Texture"] = "Растягивать текстуру";
L["Stretch the icon texture, intended for icons that don't have the same width/height."] = "Растягивать текстуру иконки. Предназначено для иконок с разными значениями ширины/высоты.";
L["Tagged NPC"] = "Чужой НИП";
L["Target Alpha"] = "Прозрачность цели";
L["Target Indicator"] = "Индикатор цели";
L["Threat"] = "Угроза";
L["Toggle the nameplates to be visible outside of combat and visible inside combat."] = "Прячет индикаторы вне боя и показывает их в бою.";
L["Use this filter."] = "Использовать этот фильтр";
L["Vertical Arrow"] = "Вертикальная стрелка";
L["Wrap Name"] = "Перенос имени";
L["Wraps name instead of truncating it."] = "Отображать имя в несколько строк вместо сокращения.";
L["X-Offset"] = "Смещение по Х";
L["Y-Offset"] = "Смещение по Y";
L["You can't remove a default name from the filter, disabling the name."] = "Вы не можете удалить имя по умолчанию из фильтра. Отключаю использование указанного имени.";

--Skins
L["Achievement Frame"] = "Достижения"
L['Alert Frames'] = "Предупреждения"
L["Archaeology Frame"] = "Археология"
L["Arena Frame"] = "Бои арены"
L["Arena Registrar"] = "Регистратор арены"
L["Auction Frame"] = "Аукцион"
L["Barbershop Frame"] = "Парикмахерская"
L["BG Map"] = "Карта ПБ"
L["BG Score"] = "Таблица ПБ"
L['Black Market AH'] = "Черный Рынок"
L["Calendar Frame"] = "Календарь"
L["Character Frame"] = "Окно персонажа"
L["Debug Tools"] = "Инструменты отладки"
L["Dressing Room"] = "Примерочная"
L["Encounter Journal"] = "Атлас подземелий"
L["Glyph Frame"] = "Символы"
L["Gossip Frame"] = "Диалоги"
L["Greeting Frame"] = "Приветствия"
L["Guild Bank"] = "Банк гильдии"
L["Guild Control Frame"] = "Управление гильдией"
L["Guild Frame"] = "Гильдия"
L["Guild Registrar"] = "Регистратор гильдий"
L["Help Frame"] = "Помощь"
L["Inspect Frame"] = "Осмотр"
L['Item Upgrade'] = "Улучшение предметов"
L["KeyBinding Frame"] = "Назначение клавиш"
L["LF Guild Frame"] = "Поиск гильдии"
L["LFD Frame"] = "Поиск группы"
L["LFR Frame"] = "Поиск рейда"
L["Loot Frames"] = "Добыча"
L['Loss Control'] = "Потеря контроля"
L["Macro Frame"] = "Макросы"
L["Mail Frame"] = "Почта"
L["Merchant Frame"] = "Торговец"
L["Misc Frames"] = "Прочие фреймы"
L["Mounts & Pets"] = "Транспорт и питомцы"
L["Non-Raid Frame"] = "Не рейдовые фреймы"
L["Pet Battle"] = "Битвы питомцев"
L["Petition Frame"] = "Хартия гильдии"
L["PvP Frames"] = "ПвП фреймы"
L["Quest Frames"] = "Задания"
L["Raid Frame"] = "Рейд"
L["Reforge Frame"] = "Перековка"
L["Skins"] = "Скины"
L["Socket Frame"] = "Инкрустирование"
L["Spellbook"] = "Книга заклинаний"
L["Stable"] = "Стойла"
L["Tabard Frame"] = "Создание накидки"
L["Talent Frame"] = "Таланты"
L["Taxi Frame"] = "Такси"
L["Time Manager"] = "Секундомер"
L["Trade Frame"] = "Обмен"
L["TradeSkill Frame"] = "Профессия"
L["Trainer Frame"] = "Тренер"
L['Transmogrify Frame'] = "Окно транмсмогрификации"
L['Void Storage'] = "Хранилище бездны"
L["World Map"] = "Карта мира"

--Static Popups
L["Are you sure you want to reset all the settings on this profile?"] = "Вы уверены, что хотите сбросить все настройки для этого профиля?"
L["Enabling/Disabling Bar #6 will toggle a paging option from your main actionbar to prevent duplicating bars, are you sure you want to do this?"] = true;

--Tooltip
L['Always Hide'] = "Всегда скрывать"
L["Anchor Mode"] = "Режим прикрепления"
L["Anchor"] = "Фиксатор"
L["Bags Only"] = "Только в сумках";
L["Bags/Bank"] = true;
L["Bank Only"] = "Только в банке";
L["Both"] = "Оба";
L["Choose when you want the tooltip to show. If a modifer is chosen, then you need to hold that down to show the tooltip."] = true;
L['Cursor Anchor'] = "Около курсора"
L["Cursor"] = "Курсор"
L['Display guild ranks if a unit is guilded.'] = "Отображать рагн в гильдии."
L['Display how many of a certain item you have in your possession.'] = "Отображать количество предметов в сумках"
L['Display player titles.'] = "Отображать звания"
L['Display the players talent spec and item level in the tooltip, this may not immediately update when mousing over a unit.'] = "Показывать специализацию и уровень предметов в подсказке. Может обновиться не сразу после наведения курсора."
L['Display the spell or item ID when mousing over a spell or item tooltip.'] = "Отображать ID заклинания или предмета в подсказке при наведении мыши."
L["Don't display the tooltip when mousing over a unitframe."] = "Не отображать подсказку при наведении курсора на рамки юнитов."
L['Guild Ranks'] = "Ранги гильдии"
L["Health Bar"] = "Полоса здоровья"
L["Hide tooltip while in combat."] = "Скрывать подсказку в бою"
L['Inspect Info'] = "Информация осмотра"
L['Item Count'] = "Кол-во предметов"
L['Never Hide'] = "Никогда не скрывать"
L['Player Titles'] = "Звания игроков"
L["Set the type of anchor mode the tooltip should use."] = "Установите тип прикрепления, который должна использовать подсказка"
L['Should tooltip be anchored to mouse cursor'] = "Привязывает подсказку к курсору мыши."
L["Smart"] = "Умный режим"
L['Spell/Item IDs'] = "ID заклинаний/предметов"
L["Target Info"] = "Информация о цели"
L["Unitframes"] = true;
L["When in a raid group display if anyone in your raid is targeting the current tooltip unit."] = "В рейдовой группе отображать выбравших в цель юнит, для которого показана подсказка"

--UnitFrames
L['%s and then %s'] = "%s, а затем %s"
L['2D'] = '2D'
L['3D'] = '3D'
L['Above'] = "Сверху"
L["Absorbs"] = "Поглощения"
L["Add a spell to the filter."] = "Добавить заклинание в фильтр"
L["Add Spell Name"] = "Добавить имя заклинания";
L["Add Spell or spellID"] = "Добавить заклинание или ID";
L["Add Spell"] = "Добавить заклинание"
L["Add SpellID"] = "Добавить ID заклинания"
L["Additional Filter"] = "Дополнительный фильтр"
L["Affliction"] = "Колдовство"
L["Allow auras considered to be part of a boss encounter."] = true;
L["Allow Boss Encounter Auras"] = true;
L["Allow Whitelisted Auras"] = "Разрешиь ауры из белого списка"
L["An X offset (in pixels) to be used when anchoring new frames."] = "Отступ по оси X (в пикселях) при фиксации новой рамки.";
L["An Y offset (in pixels) to be used when anchoring new frames."] = "Отступ по оси Y (в пикселях) при фиксации новой рамки.";
L["Ascending or Descending order."] = "Восходящий или нисходящий порядок.";
L['Arcane Charges'] = "Чародейские заряды"
L['Ascending'] = "Восходящее"
L["Assist Frames"] = "Помощники"
L['Assist Target'] = "Цели помощников"
L['At what point should the text be displayed. Set to -1 to disable.'] = "При каком значении должен показываться текст. Установите -1 для отключения."
L['Attach Text to Power'] = "Привязать текст к ресурсу"
L["Attach To"] = "Прикрепить к"
L['Aura Bars'] = "Полосы аур"
L['Auto-Hide'] = "Автоматически скрывать"
L["Bad"] = "Плохое"
L["Bars will transition smoothly."] = "Полосы будут изменяться плавно"
L['Below'] = "Снизу"
L["Blacklist"] = "Черный список"
L["Block Auras Without Duration"] = "Блокировать ауры без длительности"
L["Block Blacklisted Auras"] = "Блокировать ауры из черного списка"
L['Block Non-Dispellable Auras'] = "Блокировать не развеиваемые ауры"
L["Block Non-Personal Auras"] = "Блокировать чужие ауры"
L["Block Raid Buffs"] = "Блокировать рейдовые баффы"
L['Blood'] = "Кровь"
L['Borders'] = "Границы"
L["Buff Indicator"] = "Индикатор баффов"
L["Buffs"] = "Баффы"
L['By Type'] = "По типу"
L["Camera Distance Scale"] = "Дистанция камеры"
L["Castbar"] = "Полоса заклинаний"
L['Center'] = "Центр"
L["Check if you are in range to cast spells on this specific unit."] = "Проверять находится ли конкретный юнит в радиюсе действия Ваших заклинаний."
L["Class Backdrop"] = "Фон по классу"
L['Class Castbars'] = "Полоса заклинаний по классу"
L['Class Color Override'] = "Принудительный цвет класса"
L["Class Health"] = "Здоровье по классу"
L["Class Power"] = "Ресурс по классу"
L['Class Resources'] = "Ресурсы класса"
L["Classbar"] = "Полоса класса"
L['Click Through'] = "Клик насквозь"
L["Color all buffs that reduce the unit's incoming damage."] = "Окрашивать все баффы, уменьшающие входящий урон по цели."
L['Color aurabar debuffs by type.'] = "Окрашивать полосы аур-дебаффов по типу"
L['Color castbars by the class or reaction type of the unit.'] = "Окрашивать полосу заклинаний по цвету класса или реакции юнита."
L["Color health by amount remaining."] = "Окрашивает полосу здоровья в зависимости от оставшегося его количества."
L["Color health by classcolor or reaction."] = "Окрашивает полосу здоровья по цвету класса или отношению."
L["Color power by classcolor or reaction."] = "Окрашивает полосу ресурсов по цвету класса или реакции."
L["Color the health backdrop by class or reaction."] = "Окрасить фон полосы здоровья по цвету класса или реакции."
L["Color the unit healthbar if there is a debuff that can be dispelled by you."] = "Изменять цвет полосы здоровья, если на юните есть дебафф, который Вы можете снять."
L['Color Turtle Buffs'] = "Окрашивать Turtle Buffs"
L["Color"] = "Цвет"
L['Colored Icon'] = "Окрашенная иконка"
L['Coloring (Specific)'] = "Окрашивание конкретных"
L['Coloring'] = "Окрашивание"
L["Combat Fade"] = "Скрытие"
L["Combobar"] = "Полоса серии"
L['Configure Auras'] = "Настроить Ауры"
L["Copy From"] = "Скопировать из"
L["Count Font Size"] = "Размер шрифта стаков"
L['Create a custom fontstring. Once you enter a name you will be able to select it from the elements dropdown list.'] = "Создать свою текстовую строку. После воода имени вы сможете выбрать его в выпадающем списке"
L["Create a filter, once created a filter can be set inside the buffs/debuffs section of each unit."] = "Создает фильтр. После создания он может быть установлен в секции баффов/дебаффов любого юнита."
L["Create Filter"] = "Создать фильтр"
L['Current - Max | Percent'] = "Текущее - Макс. | Процент"
L["Current - Max"] = "Текущее - Максимальное"
L["Current - Percent"] = "Текущее - Процент"
L["Current / Max"] = "Текущее / Максимальное"
L["Current"] = "Текущее"
L["Custom Dead Backdrop"] = "Свой фон мертвого";
L["Custom Health Backdrop"] = "Свой фон полосы здоровья"
L['Custom Texts'] = "Свой текст"
L['Death'] = "Смерть"
L["Debuff Highlighting"] = "Подсветка дебаффов"
L["Debuffs"] = "Дебаффы"
L["Decimal Threshold"] = "Десятые доли после...";
L["Deficit"] = "Дефицит"
L["Delete a created filter, you cannot delete pre-existing filters, only custom ones."] = "Удалить созданный фильтр. Вы не можете удалять фильтры по умолчанию, только созданные вручную."
L["Delete Filter"] = "Удалить фильтр"
L["Demonology"] = "Демонология"
L['Descending'] = "Нисходящий"
L["Destruction"] = "Разрушение"
L['Detach From Frame'] = "Открепить от рамки"
L['Detached Width'] = "Ширина при откреплении"
L["Direction the health bar moves when gaining/losing health."] = "Направление, в котором заполняется полоса при потере/восполнении здоровья."
L["Disable Blizzard"] = "Отключить фреймы Blizard"
L['Disabled'] = "Отключено"
L["Disables the blizzard party/raid frames."] = "Отключает фреймы группы/рейда от Blizzard."
L["Disconnected"] = "Не в сети"
L["Display a spark texture at the end of the castbar statusbar to help show the differance between castbar and backdrop."] = "Отображать свечение на краю полосы заклинаний для более четкого отделения ее от фона."
L['Display druid mana bar when in cat or bear form and when mana is not 100%.'] = "Отображать ману друида в формах кота/медведя, пока она меньше 100%."
L['Display Frames'] = "Показать рамки"
L['Display icon on arena frame indicating the units talent specialization or the units faction if inside a battleground.'] = "Отображать иконку на рамках арены, показывающую специализацию или фракцию на полях боя."
L["Display Player"] = "Показывать себя"
L['Display Target'] = "Показывать цель"
L['Display Text'] = "Показывать текст"
L["Display the rested icon on the unitframe."] = "Отображать иконку отдыха на рамке игрока"
L['Display the target of your current cast. Useful for mouseover casts.'] = "Отображать имя цели заклинания на полосе."
L["Display tick marks on the castbar for channelled spells. This will adjust automatically for spells like Drain Soul and add additional ticks based on haste."] = "Отображать метки тиков на полосе заклинаний для поддерживаемых заклинаний. Они будут автоматически масштабироваться для заклинаний вроде Похищения души и добавлять новые тики, основываясь на показателе скорости."
L["Don't display any auras found on the 'Blacklist' filter."] = 'Не отображать ауры, обнаруженные в фильтре "Blacklist".'
L["Don't display auras that are longer than this duration (in seconds). Set to zero to disable."] = "Не отображать ауры длительностью более этого значения (в секундах). Установите на 0 для отключения.";
L["Don't display auras that are not yours."] = "Не отображать ауры, наложенные не вами."
L["Don't display auras that cannot be purged or dispelled by your class."] = "Не отображать ауры, которые не могут быть развеяны вашим классом."
L["Don't display auras that have no duration."] = "Не отображать ауры без длительности"
L["Don't display raid buffs such as Blessing of Kings or Mark of the Wild."] = "Не отображать рейдовые баффы, такие как Каска или Лапа."
L["Down"] = "Вниз"
L['Druid Mana'] = "Мана друида"
L['Duration Reverse'] = "Длительность, обратное"
L['Duration'] = "Длительность"
L['Enabling this allows raid-wide sorting however you will not be able to distinguish between groups.'] = "Включение опции позволит Вам проводить сортировку в пределах всего рейда, но в замен Вы не сможете понять кто в какой группе."
L['Enabling this inverts the grouping order when the raid is not full, this will reverse the direction it starts from.'] = "Включение опции инвертирует порядок группировки в неполном рейде, она изменит направление роста и точку его начала."
L['Enemy Aura Type'] = "Тип аур врага"
L["Fade the unitframe when out of combat, not casting, no target exists."] = "Скрывать фрейм, когда Вы вне боя, не произносите заклинаний или отсутствует цель."
L["Fill"] = "Заполнение"
L["Filled"] = "По ширине рамки"
L["Filter Type"] = "Тип фильтра"
L['Force Off'] = "Постоянно выключен"
L['Force On'] = "Постоянно включен"
L['Force Reaction Color'] = "Принудительная реакция";
L['Force the frames to show, they will act as if they are the player frame.'] = "Принудительно показать рамки, они будут вести себя как рамка игрока."
L['Forces reaction color instead of class color on units controlled by players.'] = "Принудительно окрашивает полосу здоровья по цвету реакции для рамок игроков.";
L["Format"] = "Формат"
L["Frame"] = "Рамка"
L["Frequent Updates"] = "Частое обновление"
L['Friendly Aura Type'] = "Тип аур друга"
L['Friendly'] = "Дружественный"
L['Frost'] = "Лед"
L['Glow'] = "Свечение"
L["Good"] = "Хорошее"
L["GPS Arrow"] = "Стрелка направления";
L["Group By"] = "Группировать по"
L['Group Size'] = "Размер группы"
L['Grouping & Sorting'] = "Группировка и сортировка"
L["Groups Per Row/Column"] = "Групп на ряд/столбец"
L['Growth direction from the first unitframe.'] = "Направление роста от перфого фрейма."
L['Growth Direction'] = "Направление роста"
L['Harmony'] = "Ци"
L["Heal Prediction"] = "Входящее исцеление"
L["Health Backdrop"] = "Фон полосы здоровья"
L['Health Border'] = "Граница здоровья"
L["Health By Value"] = "Здоровье по значению"
L["Health"] = "Здоровье"
L["Height"] = "Высота"
L['Holy Power'] = "Сила Света"
L['Horizontal Spacing'] = "Отступ по горизонтали"
L["Horizontal"] = "Горизонтально" --Also used in bags module
L["How far away the portrait is from the camera."] = "Как далеко от персонажа находится камера."
L["Icon"] = "Иконка"
L['Icon: BOTTOM'] = "Иконка: внизу"
L['Icon: BOTTOMLEFT'] = "Иконка: внизу слева"
L['Icon: BOTTOMRIGHT'] = "Иконка: внизу справа"
L['Icon: LEFT'] = "Иконка: слева"
L['Icon: RIGHT'] = "Иконка: справа"
L['Icon: TOP'] = "Иконка: вверху"
L['Icon: TOPLEFT'] = "Иконка: вверху слева"
L['Icon: TOPRIGHT'] = "Иконка: вверху справа"
L["If no other filter options are being used then it will block anything not on the 'Whitelist' filter, otherwise it will simply add auras on the whitelist in addition to any other filter settings."] = 'Если не используется никакой другой фильтр, то будут блокироваться ауры вне фильтра "Whitelist". В противном случае будет просо добавлять ауры в белый список в дополнение к другим опциям фильтрации.'
L['If not set to 0 then override the size of the aura icon to this.'] = "Если установлено не на 0, то устанавливать размер иконок аур на заданное число."
L["If the unit is an enemy to you."] = "Если юнит враждебен вам."
L["If the unit is friendly to you."] = "Если юнит дружественен к вам."
L['Ignore mouse events.'] = "Игнорировать мышь"
L['Inset'] = "Внутри"
L['Interruptable'] = "Прерываемые"
L['Invert Grouping Order'] = "Инвертировать порядок группировки"
L['JustifyH'] = "Выравнивание"
L["Latency"] = "Задержка"
L["Left to Right"] = "Слева направо";
L["Low Mana Threshold"] = "Низкое значение маны"
L['Lunar'] = "Луна"
L["Main statusbar texture."] = "Основная текстура полос состояния (здоровье, ресурс и тд)."
L['Main Tanks / Main Assist'] = "Танки/помощники"
L['Make textures transparent.'] = "Сделать текстуры прозрачными"
L["Match Frame Width"] = "По ширине рамки"
L["Maximum Duration"] = "Максимальная длительность";
L["Method to sort by."] = "Метод сортировки.";
L['Middle Click - Set Focus'] = "Средний клик - фокус"
L['Middle clicking the unit frame will cause your focus to match the unit.'] = "Нажатие средней кнопкой мыши на фрейм юнита запомнит его в фокус."
L['Model Rotation'] = "Вращение модели"
L['Mouseover'] = "При наведении"
L['Name (Entire Group)'] = "Имя (в группе)"
L["Name"] = "Имя" --Also used in Buffs and Debuffs
L["Neutral"] = "Нейтральный"
L['Non-Interruptable'] = "Не прерываемые"
L["None"] = "Нет" --Also used in chat
L["Not valid spell id"] = "Неверный ID заклинания"
L["Num Rows"] = "Рядов"
L['Number of Groups'] = "Количество групп"
L['Number of units in a group.'] = "Количество юнитов в группе." 
L["Offset of the powerbar to the healthbar, set to 0 to disable."] = "Смещение полосы ресурсов относительно полосы здоровья. Установите на 0 для отключения."
L['Offset position for text.'] = "Отступ для текста."
L["Offset"] = "Смещение"
L['Only show when the unit is not in range.'] = "Отображать только когда юнит вне радиуса."
L['Only show when you are mousing over a frame.'] = "Отображать только при наведении курсора на фрейм."
L["OOR Alpha"] = "Прозрачность вне радиуса"
L["Orientation"] = "Ориентация"
L["Others"] = "Чужое";
L["Overlay the healthbar"] = "Отображение портрета на полосе здоровья."
L["Overlay"] = "Наложение"
L["Override any custom visibility setting in certain situations, EX: Only show groups 1 and 2 inside a 10 man instance."] = "Игнорировать пользовательские настройки отображения в определенных ситуациях. Пример: показывать только группы 1 и 2 в подземелье на 10 человек."
L['Override the default class color setting.'] = "Перекрывает установки цвета класса по умолчанию."
L['Owners Name'] = "Имя хозяина"
L["Party Pets"] = "Питомцы группы"
L["Party Targets"] = "Цели группы"
L["Per Row"] = "Кол-во в ряду"
L["Percent"] = "Процент"
L["Personal"] = "Свое";
L['Pet Name'] = "Имя питомца"
L['Player Frame Aura Bars'] = "Полосы аур игрока"
L["Portrait"] = "Портрет"
L["Position"] = "Позиция"
L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."] = "Текст ресурса будет спрятан для НИП. Также текст имени будет смещен в точку расположения текста ресурса."
L["Power"] = "Ресурс"
L["Powers"] = "Ресурсы"
L["Priority"] = "Приоритет"
L['PVP Trinket'] = "ПвП Аксессуар"
L['Raid Icon'] = "Рейдовая иконка"
L['Raid-Wide Sorting'] = "Общерейдовая сортировка"
L["RaidDebuff Indicator"] = "Индикатор рейдовых дебаффов"
L["Range Check"] = "Проверка дистанции"
L["Rapidly update the health, uses more memory and cpu. Only recommended for healing."] = "Более частое обновление состояния здоровья, использует больше памяти и ресурсов процессора. Рекомендуется только для целителей."
L["Reactions"] = "Отношение"
L["Remaining"] = "Оставшееся"
L["Remove a spell from the filter."] = "Удаляет заклинание из фильтра"
L["Remove Spell or spellID"] = "Удалить заклинание или ID";
L["Remove Spell"] = "Удалить заклинание"
L["Remove SpellID"] = "Удалить ID заклинания"
L["Rest Icon"] = "Иконка отдыха"
L["Restore Defaults"] = "Восстановить умолчания" --Also used in Media and ActionBars sections
L['Reverses the grouping order. For example if your group is to grow right than up by default the first group is always at the bottom. With this option set then the first group will start at the bottom but as the number of groups grow it will always be near the top.'] = "Обращает настройки роста групп. Например, если у Вас установлено расти врпаво и вверх, то первая группа всегда будет снизу. При включении опции первая группа сначала появится внизу, но с увеличением их количества будет оставаться наверху."
L["Right to Left"] = "Справа налево";
L['RL / ML Icons'] = "Иконки лидера/ответственного"
L["Role Icon"] = "Иконка роли"
L["Seconds remaining on the aura duration before the bar starts moving. Set to 0 to disable."] = "Полоса начнет убывать, когда оставшееся время ауры упадет ниже этого значения в секундах. Установите на 0 для отключения.";
L["Select a filter to use."] = "Выберите фильтр для использования." --Also used in NamePlates
L["Select a unit to copy settings from."] = "Выберите юнит, установки которого Вы хотите скопировать."
L['Select an additional filter to use. If the selected filter is a whitelist and no other filters are being used (with the exception of Block Non-Personal Auras) then it will block anything not on the whitelist, otherwise it will simply add auras on the whitelist in addition to any other filter settings.'] = 'Выберите дополнительный фильтр для использования. Если выбраный фильтр имеет тип "белый список" и не используется никакой другой фильтр (за исключением блокиования чужих аур), то будут блокироваться ауры вне белого списка. В противном случае будет просо добавлять ауры в белый список в дополнение к другим опциям фильтрации.'
L["Select Filter"] = "Выбрать фильтр"
L["Select Spell"] = "Выбрать заклинание"
L['Select the display method of the portrait.'] = "Выбирите метод отображения портрета"
L["Set the filter type, blacklisted filters hide any aura on the like and show all else, whitelisted filters show any aura on the filter and hide all else."] = "Выберите тип фильтра. Фильтры типа 'черный список' скрывают все баффы в них и показывают остальные, фильтры типа 'белый список' показывают только присутствующие в них баффы"
L["Set the font size for unitframes."] = "Устанавливает шрифт для рамок юнитов."
L["Set the order that the group will sort."] = "Устанавливает метод сортировки в группе."
L["Set the priority order of the spell, please note that prioritys are only used for the raid debuff module, not the standard buff/debuff module. If you want to disable set to zero."] = "Устанавливает порядок заклинания. Заметьте, что приоритеты используются только для модуля рейдовых дебаффов, а не для стандартных баффов/дебаффов. Для отключения приоритетности установите на 0."
L['Set the type of auras to show when a unit is a foe.'] = "Устанавливает тип аур для отображения, когда юнит враг."
L['Set the type of auras to show when a unit is friendly.'] = "Устанавливает тип аур для отображения, когда юнит друг."
L["Sets the font instance's horizontal text alignment style."] = "Устанавливает выравнивание текста по горизонтали"
L['Shadow Orbs'] = "Сферы Тьмы"
L["Show a incomming heal prediction bar on the unitframe. Also display a slightly different colored bar for incoming overheals."] = "Отображать объем входящего исцеления на рамках. Также отображает немного иначе окрашенную полосу для избыточного исцеления."
L["Show Aura From Other Players"] = "Отображать чужие"
L['Show Auras'] = "Показать ауры"
L["Show When Not Active"] = "Показывать при отсутствии"
L["Show"] = "Показать";
L["Size and Positions"] = "Размер и позиция";
L["Size of the indicator icon."] = "Размер иконки индикатора"
L['Size Override'] = "Свой размер"
L["Size"] = "Размер"
L["Smart Raid Filter"] = "Умный фильтр рейда"
L["Smooth Bars"] = "Плавные полосы"
L["Sort By"] = "Сортировать по";
L["Spaced"] = "Раздельно"
L["Spacing"] = "Отступ";
L["Spark"] = "Искра"
L['Spec Icon'] = "Иконка специализации"
L["Spell not found in list."] = "Заклинание не найдено в этом списке"
L['Spells'] = "Заклинания"
L["Stack Threshold"] = "Стаки";
L['Start Near Center'] = "Начинать от центра"
L["StatusBar Texture"] = "Текстура полос состояния"
L['Style'] = "Стиль"
L["Tank Frames"] = "Танки"
L['Tank Target'] = "Цели танков"
L["Tapped"] = "Чужой"
L["Target On Mouse-Down"] = "Выделение при нажати"
L["Target units on mouse down rather than mouse up. \n\n|cffFF0000Warning: If you are using the addon 'Clique' you may have to adjust your clique settings when changing this."] = "Выделять при нажатии кнопки мыши, а не при ее отпускании.\n\n|cffFF0000Внимание: Если Вы используете аддон 'Clique', то Вы также должны изменить его настройки при изменении этой."
L['Text Color'] = "Цвет текста"
L["Text Format"] = "Формат текста"
L['Text Position'] = "Позиция текста"
L['Text Threshold'] = "Значение текста"
L["Text Toggle On NPC"] = "Переключение текста для НИП"
L['Text xOffset'] = "Отсуп текста по Х"
L['Text yOffset'] = "Отсуп текста по Y"
L['Text'] = "Текст"
L['Textured Icon'] = "Иконка с текстурой"
L["The alpha to set units that are out of range to."] = "Прозрачность рамок юнитов, находящихся вне дальности действия заклинаний."
L["The debuff needs to reach this amount of stacks before it is shown. Set to 0 to always show the debuff."] = "Для показа этого дебаффа, он должен набрать указанное количество стаков. Пи установке на 0, показывается всегда.";
L["The following macro must be true in order for the group to be shown, in addition to any filter that may already be set."] = "Следующий фильтр должен быть верен для отображения группы в дополнение к любому другому уже установленному фильтру."
L["The font that the unitframes will use."] = "Шрифт рамок юнитов"
L['The initial group will start near the center and grow out.'] = "Первая группа появится в центре и будет расти наружу."
L['The name you have selected is already in use by another element.'] = "Выбранное вами имя уже используется другим элементом"
L['The object you want to attach to.'] = "Объект, к которому Вы хотите прикрепить полосы"
L["This filter is meant to be used when you only want to whitelist specific spellIDs which share names with unwanted spells."] = "Этот фильтр используется, когда нужно добавить в белый спиок определенный ID заклинания, имеющие одинаковое название с нежелательными.";
L['This filter is used for both aura bars and aura icons no matter what. Its purpose is to block out specific spellids from being shown. For example a paladin can have two sacred shield buffs at once, we block out the short one.'] = "Этот фильтр всегда используется для полос и иконок аур. Его предназначение блокировать показ специфических заклинаний. Например, паладин может иметь 2 баффа Щита небес одновременно, мы блокируем короткий."
L['Threat Display Mode'] = "Режим отображения угрозы"
L["Threshold before text goes into decimal form. Set to -1 to disable decimals."] = "Граница, после которых текст будет показывать десятые доли. Установите на -1 для отключения.";
L["Ticks"] = "Тики"
L['Time Remaining Reverse'] = "Оставшееся время, обратное"
L['Time Remaining'] = "Оставшееся время"
L["Toggles health text display"] = "Включает отображение текста здоровья на индикаторах"
L['Transparent'] = "Прозрачный"
L['Turtle Color'] = "Цвет Turtle Buffs"
L['Unholy'] = "Нечистивость"
L["Uniform Threshold"] = "Граница убывания";
L["UnitFrames"] = "Рамки юнитов"
L["Up"] = "Вверх"
L['Use Default'] = "Использовать умолчания"
L["Use the custom health backdrop color instead of a multiple of the main health color."] = "Использовать свой фоновый цвет вместо основного цвета полосы здоровья."
L["Use this backdrop color for units that are dead or ghosts."] = "Использовать этот цвет фона для юнитов, которые мертвы или бегут  кладбища.";
L["Value must be a number"] = "Значение должно быть числом"
L['Vertical Spacing'] = "Отступ по вертикали"
L["Vertical"] = "Вертикально" --Also used in bags section
L["Visibility"] = "Видимость"
L["What point to anchor to the frame you set to attach to."] = "К какой точке выбранного фиксатора прикрепить ауры."
L["What to attach the buff anchor frame to."] = "К чему прикреплять баффы."
L["What to attach the debuff anchor frame to."] = "К чему прикреплять дебаффы."
L["When true, the header includes the player when not in a raid."] = "Отображать игрока в группе."
L["When you mana falls below this point, text will flash on the player frame."] = "Когда мана опускается ниже этого процента, на фрейме игрока начнет мигать предупреждающий текст."
L["Whitelist"] = "Белый список"
L["Width"] = "Ширина" --Also used in NamePlates module
L["xOffset"] = "Отступ по Х"
L["yOffset"] = "Отступ по Y"
L["You can't remove a pre-existing filter."] = "Вы не можете удалить фильтр по умолчанию."
L["You cannot copy settings from the same unit."] = "Вы не можете копировать установки из того же юнита."
L["You may not remove a spell from a default filter that is not customly added. Setting spell to false instead."] = "Вы не можете удалить заклинание из фильтра по умолчанию, которое не было добавлено в него вручную. Отключаю использование в фильтре этого заклинания."