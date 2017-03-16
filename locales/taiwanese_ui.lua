-- Taiwanese localization file for zhTW.
local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("ElvUI", "zhTW")
if not L then return end

--*_ADDON locales
L["INCOMPATIBLE_ADDON"] = "插件 %s 與 ElvUI 的 %s 模組不相容。請停用不相容的插件，或停用模組."

--*_MSG locales
L["LOGIN_MSG"] = "歡迎使用%sElvUI |r %s%s|r 版, 請輸入/ec 進入設定介面. 如需技術支援請至 https://github.com/ElvUI-WotLK/ElvUI"

--ActionBars
L["Binding"] = "綁定"
L["Key"] = "鍵"
L["KEY_ALT"] = "A"
L["KEY_CTRL"] = "C"
L["KEY_DELETE"] = "Del"
L["KEY_HOME"] = "Hm"
L["KEY_INSERT"] = "Ins"
L["KEY_MOUSEBUTTON"] = "M"
L["KEY_MOUSEWHEELDOWN"] = "MwD"
L["KEY_MOUSEWHEELUP"] = "MwU"
L["KEY_NUMPAD"] = "N"
L["KEY_PAGEDOWN"] = "PD"
L["KEY_PAGEUP"] = "PU"
L["KEY_SHIFT"] = "S"
L["KEY_SPACE"] = "SpB"
L["No bindings set."] = "未設定快捷綁定."
L["Remove Bar %d Action Page"] = "移除第 %d 快捷列"
L["Trigger"] = "觸發器"

--Bags
L["Bank"] = true;
L["Hold Control + Right Click:"] = "按住 Ctrl 並按滑鼠右鍵："
L["Hold Shift + Drag:"] = true;
L["Purchase Bags"] = true;
L["Reset Position"] = "重設位置"
L["Sort Bags"] = true;
L["Temporary Move"] = "移動背包"
L["Toggle Bags"] = "開啟/關閉背包"
L["Toggle Key"] = true;
L["Vendor Grays"] = "出售灰色物品"

--Chat
L["AFK"] = "離開" --Also used in datatexts and tooltip
L["BG"] = true;
L["BGL"] = true;
L["DND"] = "忙碌" --Also used in datatexts and tooltip
L["G"] = "公會"
L["Invalid Target"] = "無效的目標"
L["O"] = "幹部"
L["P"] = "隊伍"
L["PL"] = "隊長"
L["R"] = "團隊"
L["RL"] = "團隊隊長"
L["RW"] = "團隊警告"
L["says"] = "說"
L["whispers"] = "密語"
L["yells"] = "大喊"

--DataTexts
L["(Hold Shift) Memory Usage"] = "(按住Shift) 記憶體使用量"
L["Avoidance Breakdown"] = "免傷統計"
L["Character: "] = "角色: "
L["Chest"] = "胸部"
L["Combat Time"] = true;
L["copperabbrev"] = "|cffeda55f銅|r" --Also used in Bags
L["Deficit:"] = "赤字:"
L["DPS"] = "傷害輸出"
L["Earned:"] = "賺取:"
L["Friends List"] = "好友列表"
L["Friends"] = "好友" --Also in Skins
L["goldabbrev"] = "|cffffd700金|r" --Also used in Bags
L["Hit"] = "命中"
L["Hold Shift + Right Click:"] = true;
L["Home Latency:"] = "本機延遲:"
L["HP"] = "生命值"
L["HPS"] = "治療輸出"
L["lvl"] = "等級"
L["Miss Chance"] = true;
L["Mitigation By Level: "] = "等級減傷: "
L["No Guild"] = "沒有公會"
L["Profit:"] = "利潤: "
L["Reload UI"] = true;
L["Reset Data: Hold Shift + Right Click"] = "重置數據: 按住 Shift + 右鍵點擊"
L["Right Click: Reset CPU Usage"] = true;
L["Saved Raid(s)"] = "已有進度的副本"
L["Server: "] = "伺服器: "
L["Session:"] = "本次登入:"
L["silverabbrev"] = "|cffc7c7cf銀|r" --Also used in Bags
L["SP"] = "法術能量"
L["Spent:"] = "花費:"
L["Stats For:"] = "統計:"
L["Total CPU:"] = "CPU佔用"
L["Total Memory:"] = "總記憶體:"
L["Total: "] = "合計: "
L["Unhittable:"] = "未命中:"
L["Wintergrasp"] = true;

--DebugTools
L["%s: %s tried to call the protected function '%s'."] = "%s: %s 嘗試調用保護函數'%s'."
L["No locals to dump"] = "沒有本地文件"

--Distributor
L["%s is attempting to share his filters with you. Would you like to accept the request?"] = "%s 試圖與你分享過濾器配置. 你是否接受?"
L["%s is attempting to share the profile %s with you. Would you like to accept the request?"] = "%s 試圖與你分享配置文件 %s. 你是否接受?"
L["Data From: %s"] = "數據來源: %s"
L["Filter download complete from %s, would you like to apply changes now?"] = "過濾器配置下載於 %s, 你是否現在變更?"
L["Lord! It's a miracle! The download up and vanished like a fart in the wind! Try Again!"] = "天啊! 太奇葩啦! 下載消失了! 就像是在風中放了個屁... 再試一次吧!"
L["Profile download complete from %s, but the profile %s already exists. Change the name or else it will overwrite the existing profile."] = "配置文件從 %s 下載完成, 但是配置文件 %s 已存在. 請更改名稱, 否則它會覆蓋你的現有配置文件."
L["Profile download complete from %s, would you like to load the profile %s now?"] = "配置文件從 %s 下載完成, 你是否要加載配置文件 %s?"
L["Profile request sent. Waiting for response from player."] = "已發送文件請求. 等待對方響應."
L["Request was denied by user."] = "請求被對方拒絕."
L["Your profile was successfully recieved by the player."] = "你的配置文件已被其他玩家成功接收."

--Install
L["Aura Bars & Icons"] = true;
L["Auras Set"] = "光環樣式設定"
L["Auras"] = true;
L["Caster DPS"] = "法系輸出"
L["Chat Set"] = "對話设置"
L["Chat"] = "對話"
L["Choose a theme layout you wish to use for your initial setup."] = "為你的個人設定選擇一個你喜歡的皮膚主題."
L["Classic"] = "經典"
L["Click the button below to resize your chat frames, unitframes, and reposition your actionbars."] = "點擊下面的按鈕調整對話框、單位框架的尺寸, 以及移動快捷列位置."
L["Config Mode:"] = "設定模式:"
L["CVars Set"] = "參數設定"
L["CVars"] = "參數"
L["Dark"] = "黑暗"
L["Disable"] = "禁用"
L["ElvUI Installation"] = "安裝 ElvUI"
L["Finished"] = "設定完畢"
L["Grid Size:"] = "網格尺寸："
L["Healer"] = "補師"
L["High Resolution"] = "高解析度"
L["high"] = "高"
L["Icons Only"] = "圖示" --Also used in Bags
L["If you have an icon or aurabar that you don't want to display simply hold down shift and right click the icon for it to disapear."] = "如果你有不想顯示的圖示或光環條, 你可以簡單的通過按住Shift右鍵點擊使它隱藏."
L["Importance: |cff07D400High|r"] = "重要性: |cff07D400高|r"
L["Importance: |cffD3CF00Medium|r"] = "重要性: |cffD3CF00中|r"
L["Importance: |cffFF0000Low|r"] = "重要性: |cffFF0000低|r"
L["Installation Complete"] = "安裝完畢"
L["Layout Set"] = "版面配置設定"
L["Layout"] = "介面佈局"
L["Lock"] = "鎖定"
L["Low Resolution"] = "低解析度"
L["low"] = "低"
L["Nudge"] = "微調"
L["Physical DPS"] = "物理輸出"
L["Please click the button below so you can setup variables and ReloadUI."] = "請按下方按鈕設定變數並重載介面."
L["Please click the button below to setup your CVars."] = "請按下方按鈕設定參數."
L["Please press the continue button to go onto the next step."] = "請按「繼續」按鈕，執行下一個步驟."
L["Resolution Style Set"] = "解析度樣式設定"
L["Resolution"] = "解析度"
L["Select the type of aura system you want to use with ElvUI's unitframes. Set to Aura Bar & Icons to use both aura bars and icons, set to icons only to only see icons."] = true;
L["Setup Chat"] = "設定對話視窗"
L["Setup CVars"] = "設定參數"
L["Skip Process"] = "略過"
L["Sticky Frames"] = "框架依附"
L["Tank"] = "坦克"
L["The chat windows function the same as Blizzard standard chat windows, you can right click the tabs and drag them around, rename, etc. Please click the button below to setup your chat windows."] = "對話視窗與WOW 原始對話視窗的操作方式相同, 你可以拖拉、移動分頁或重新命名分頁. 請按下方按鈕以設定對話視窗."
L["The in-game configuration menu can be accessed by typing the /ec command or by clicking the 'C' button on the minimap. Press the button below if you wish to skip the installation process."] = "若要進入內建設定選單, 請輸入/ec, 或者按一下小地圖旁的「C」按鈕.若要略過安裝程序, 請按下方按鈕."
L["Theme Set"] = "主題設置"
L["Theme Setup"] = "主題安裝"
L["This install process will help you learn some of the features in ElvUI has to offer and also prepare your user interface for usage."] = "此安裝程序有助你瞭解ElvUI 部份功能, 並可協助你預先設定UI."
L["This is completely optional."] = "此為選擇性功能."
L["This part of the installation process sets up your chat windows names, positions and colors."] = "此安裝步驟將會設定對話視窗的名稱、位置和顏色."
L["This part of the installation process sets up your World of Warcraft default options it is recommended you should do this step for everything to behave properly."] = "此安裝步驟將會設定 WOW 預設選項, 建議你執行此步驟, 以確保功能均可正常運作."
L["This resolution doesn't require that you change settings for the UI to fit on your screen."] = "這個解析度不需要你改動任何設定以適應你的屏幕."
L["This resolution requires that you change some settings to get everything to fit on your screen."] = "這個解析度需要你改變一些設定才能適應你的屏幕."
L["This will change the layout of your unitframes and actionbars."] = true;
L["Trade"] = "拾取/交易"
L["Welcome to ElvUI version %s!"] = "歡迎使用 ElvUI %s 版！"
L["You are now finished with the installation process. If you are in need of technical support please visit us at https://github.com/ElvUI-WotLK/ElvUI"] = "已完成安裝程序. 小提示: 若想開啟微型選單, 請在小地圖按滑鼠中鍵. 如果沒有中鍵按鈕, 請按住Shift鍵, 並在小地圖按滑鼠右鍵. 如需技術支援請至https://github.com/ElvUI-WotLK/ElvUI"
L["You can always change fonts and colors of any element of ElvUI from the in-game configuration."] = "你可以在遊戲內的設定選項內更改ElvUI的字體、顏色等設定."
L["You can now choose what layout you wish to use based on your combat role."] = "你現在可以根據你的戰鬥角色選擇合適的佈局."
L["You may need to further alter these settings depending how low you resolution is."] = "根據你的解析度你可能需要改動這些設定."
L["Your current resolution is %s, this is considered a %s resolution."] = "你當前的解析度是%s, 這被認為是個%s 解析度."

--Misc
L["ABOVE_THREAT_FORMAT"] = "%s: %.0f%% [%.0f%% 以上 |cff%02x%02x%02x%s|r]"
L["Bars"] = "條" --Also used in UnitFrames
L["Calendar"] = "日曆"
L["Can't Roll"] = "無法需求此裝備"
L["Disband Group"] = "解散隊伍"
L["Empty Slot"] = true;
L["Enable"] = "啟用" --Doesn't fit a section since it's used a lot of places
L["Experience"] = "經驗/聲望條"
L["Farm Mode"] = true;
L["Fishy Loot"] = "貪婪";
L["Left Click:"] = "滑鼠左鍵：" --layout\layout.lua
L["Raid Menu"] = "團隊選單"
L["Remaining:"] = "剩餘:"
L["Rested:"] = "休息:"
L["Right Click:"] = "滑鼠右鍵：" --layout\layout.lua
L["Show BG Texts"] = "顯示戰場資訊文字" --layout\layout.lua
L["Toggle Chat Frame"] = "開關對話框架" --layout\layout.lua
L["Toggle Configuration"] = "開啟/關閉設定" --layout\layout.lua
L["XP:"] = "經驗:"
L["You don't have permission to mark targets."] = "你沒有標記目標的權限."

--Movers
L["Arena Frames"] = "競技場框架" --Also used in UnitFrames
L["Bag Mover (Grow Down)"] = true;
L["Bag Mover (Grow Up)"] = true;
L["Bag Mover"] = true;
L["Bags"] = "背包" --Also in DataTexts
L["Bank Mover (Grow Down)"] = true;
L["Bank Mover (Grow Up)"] = true;
L["Bar "] = "快捷列 " --Also in ActionBars
L["BNet Frame"] = "戰網提示資訊"
L["Boss Frames"] = "首領框架" --Also used in UnitFrames
L["Classbar"] = "職業特有條"
L["Experience Bar"] = "經驗條"
L["Focus Castbar"] = "焦點目標施法條"
L["Focus Frame"] = "焦點目標框架" --Also used in UnitFrames
L["FocusTarget Frame"] = "焦點目標的目標框架" --Also used in UnitFrames
L["GM Ticket Frame"] = "GM 對話框"
L["Left Chat"] = "左側對話框"
L["Loot / Alert Frames"] = "拾取 / 提醒框架"
L["Loot Frame"] = true;
L["MA Frames"] = "主助理框架"
L["Micro Bar"] = "微型系統菜單" --Also in ActionBars
L["Minimap"] = "小地圖"
L["MirrorTimer"] = true;
L["MT Frames"] = "主坦克框架"
L["Party Frames"] = "隊伍框架" --Also used in UnitFrames
L["Pet Bar"] = "寵物快捷列" --Also in ActionBars
L["Pet Castbar"] = true;
L["Pet Frame"] = "寵物框架" --Also used in UnitFrames
L["PetTarget Frame"] = "寵物目標框架" --Also used in UnitFrames
L["Player Buffs"] = true;
L["Player Castbar"] = "玩家施法條"
L["Player Debuffs"] = true;
L["Player Frame"] = "玩家框架" --Also used in UnitFrames
L["Player Powerbar"] = true;
L["Raid Frames"] = true;
L["Raid Pet Frames"] = true;
L["Raid-40 Frames"] = true;
L["Reputation Bar"] = "聲望條"
L["Right Chat"] = "右側對話框"
L["Stance Bar"] = "姿態列" --Also in ActionBars
L["Target Castbar"] = "目標施法條"
L["Target Frame"] = "目標框架" --Also used in UnitFrames
L["Target Powerbar"] = true;
L["TargetTarget Frame"] = "目標的目標框架" --Also used in UnitFrames
L["TargetTargetTarget Frame"] = true;
L["Time Manager Frame"] = true;
L["Tooltip"] = "浮動提示"
L["Totems"] = true;
L["Vehicle Seat Frame"] = "載具座位框"
L["Watch Frame"] = true;
L["Weapons"] = true;
L["DESC_MOVERCONFIG"] = [=[解除框架移動鎖定. 現在可以移動它們, 移好後請點擊「鎖定」.

Options:
  Shift + RightClick - Hides mover temporarily.
  Ctrl + RightClick - Resets mover position to default.
]=]

--Plugin Installer
L["ElvUI Plugin Installation"] = true;
L["In Progress"] = true;
L["List of installations in queue:"] = true;
L["Pending"] = true;
L["Steps"] = true;

--Prints
L[" |cff00ff00bound to |r"] = " |cff00ff00綁定到 |r"
L["%s frame(s) has a conflicting anchor point, please change either the buff or debuff anchor point so they are not attached to each other. Forcing the debuffs to be attached to the main unitframe until fixed."] = " %s 個框架錨點衝突, 請移動buff或者debuff錨點讓他們彼此不依附. 暫時強制debuff依附到主框架."
L["All keybindings cleared for |cff00ff00%s|r."] = "取消|cff00ff00%s|r 所有綁定的快捷​​鍵."
L["Already Running.. Bailing Out!"] = "正在運行"
L["Battleground datatexts temporarily hidden, to show type /bgstats or right click the 'C' icon near the minimap."] = "戰場資訊暫時隱藏, 你可以通過輸入/bgstats 或右鍵點擊小地圖旁「C」按鈕顯示."
L["Battleground datatexts will now show again if you are inside a battleground."] = "當你處於戰場時戰場資訊將再次顯示."
L["Binds Discarded"] = "取消綁定"
L["Binds Saved"] = "儲存綁定"
L["Confused.. Try Again!"] = "請再試一次！"
L["No gray items to delete."] = "沒有可刪除的灰色物品."
L["The spell '%s' has been added to the Blacklist unitframe aura filter."] = "法術"%s"已經被添加到單位框架的光環過濾器中."
L["This setting caused a conflicting anchor point, where '%s' would be attached to itself. Please check your anchor points. Setting '%s' to be attached to '%s'."] = true;
L["Vendored gray items for:"] = "已售出灰色物品，共得："
L["You don't have enough money to repair."] = "沒有足夠的資金來修復."
L["You must be at a vendor."] = "你必須與商人對話."
L["Your items have been repaired for: "] = "裝備已修復，共支出："
L["Your items have been repaired using guild bank funds for: "] = "已使用公會資金修復裝備，共支出："
L["|cFFE30000Lua error recieved. You can view the error message when you exit combat."] = "|cFFE30000LUA錯誤已接收, 你可以在脫離戰鬥後檢查.|r"

--Static Popups
L["A setting you have changed will change an option for this character only. This setting that you have changed will be uneffected by changing user profiles. Changing this setting requires that you reload your User Interface."] = "你所做的改動只會影響到使用這個插件的本角色, 你需要重新加載介面才能使改動生效."
L["Are you sure you want to apply this font to all ElvUI elements?"] = true;
L["Are you sure you want to delete all your gray items?"] = "是否確定要刪除所有灰色物品?"
L["Are you sure you want to disband the group?"] = "確定要解散隊伍?"
L["Are you sure you want to reset all the settings on this profile?"] = "確定需要重置這個配置文件中的所有設置?"
L["Are you sure you want to reset every mover back to it's default position?"] = "確定需要重置所有框架至默認位置?"
L["Because of the mass confusion caused by the new aura system I've implemented a new step to the installation process. This is optional. If you like how your auras are setup go to the last step and click finished to not be prompted again. If for some reason you are prompted repeatedly please restart your game."] = "由於大量的問題導致光環系統需要一個新的安裝過程. 這是可選的, 最後一步將設置你的光環. 點擊「完成」將不再提示. 如果由於某些原因反復提示, 請重新開啟遊戲."
L["Can't buy anymore slots!"] = "無法再購買更多銀行欄位!"
L["Disable Warning"] = "停用警告"
L["Discard"] = "取消"
L["Do you enjoy the new ElvUI?"] = true;
L["Do you swear not to post in technical support about something not working without first disabling the addon/module combination first?"] = true;
L["ElvUI is five or more revisions out of date. You can download the newest version from https://github.com/ElvUI-WotLK/ElvUI/"] = true;
L["ElvUI is out of date. You can download the newest version from https://github.com/ElvUI-WotLK/ElvUI/"] = true;
L["ElvUI needs to perform database optimizations please be patient."] = true;
L["Hover your mouse over any actionbutton or spellbook button to bind it. Press the escape key or right click to clear the current actionbutton's keybinding."] = "移動滑鼠到快捷列或技能書按鈕上綁定快捷鍵.按ESC或滑鼠右鍵取消目前快捷鍵."
L["I Swear"] = "我承諾"
L["No, Revert Changes!"] = true;
L["Oh lord, you have got ElvUI and Tukui both enabled at the same time. Select an addon to disable."] = "你不能同時啓用Elvui和Tukui， 請選擇一個禁用."
L["One or more of the changes you have made require a ReloadUI."] = "已變更一或多個設定, 需重載介面."
L["One or more of the changes you have made will effect all characters using this addon. You will have to reload the user interface to see the changes you have made."] = "你所做的改動可能會影響到使用這個插件的所有角色, 你需要重新加載介面才能使改動生效."
L["Save"] = "儲存"
L["The profile you tried to import already exists. Choose a new name or accept to overwrite the existing profile."] = true;
L["Type /hellokitty to revert to old settings."] = true;
L["Using the healer layout it is highly recommended you download the addon Clique if you wish to have the click-to-heal function."] = true;
L["Yes, Keep Changes!"] = true;
L["You have changed the Thin Border Theme option. You will have to complete the installation process to remove any graphical bugs."] = true;
L["You have changed your UIScale, however you still have the AutoScale option enabled in ElvUI. Press accept if you would like to disable the Auto Scale option."] = "你改變了介面縮放比例, 然而ElvUI的自動縮放選項是開啟的. 點擊接受以關閉ElvUI的自動縮放."
L["You have imported settings which may require a UI reload to take effect. Reload now?"] = true;
L["You must purchase a bank slot first!"] = "你必需購買一個銀行背包欄位!"

--Tooltip
L["Count"] = "計數"
L["Item Level:"] = true;
L["Talent Specialization:"] = true;
L["Targeted By:"] = "同目標的有:"

--Tutorials
L["A raid marker feature is available by pressing Escape -> Keybinds scroll to the bottom under ElvUI and setting a keybind for the raid marker."] = "你可以通過按ESC鍵-> 按鍵設定, 滾動到ElvUI設定下方設定一個快速標記的快捷鍵."
L["ElvUI has a dual spec feature which allows you to load different profiles based on your current spec on the fly. You can enable this from the profiles tab."] = "ElvUI可以根據你所使用的天賦自動套用不同的設定檔. 你可以在配置文件中使用此功能."
L["For technical support visit us at https://github.com/ElvUI-WotLK/ElvUI"] = "如需技術支援請至https://github.com/ElvUI-WotLK/ElvUI"
L["If you accidently remove a chat frame you can always go the in-game configuration menu, press install, go to the chat portion and reset them."] = "如果你不慎移除了對話框, 你可以重新安裝一次重置他們."
L["If you are experiencing issues with ElvUI try disabling all your addons except ElvUI, remember ElvUI is a full UI replacement addon, you cannot run two addons that do the same thing."] = "如果你遇到問題, ElvUI會嘗試禁用你除了ElvUI之外的插件. 請記住你不能用不同的插件實現同一功能."
L["The focus unit can be set by typing /focus when you are targeting the unit you want to focus. It is recommended you make a macro to do this."] = "你可以通過/focus 命令設定焦點目標."
L["To move abilities on the actionbars by default hold shift + drag. You can change the modifier key from the actionbar options menu."] = "你可以通過按住Shift拖動技能條中的按鍵. 你可以在Blizzard的快捷列設定中更改按鍵."
L["To setup which channels appear in which chat frame, right click the chat tab and go to settings."] = "你可以通過右鍵點擊對話框標籤欄設定你需要在對話框內顯示的頻道."
L["You can access copy chat and chat menu functions by mouse over the top right corner of chat panel and left/right click on the button that will appear."] = "你可以通過滑鼠滑過對話框右上角點擊複製圖示打開對話復制窗口."
L["You can see someones average item level of their gear by holding shift and mousing over them. It should appear inside the tooltip."] = "你可以通過按住Shift並將滑鼠滑過目標看到目標的裝備等級, 這將顯示在你的滑鼠提示框內."
L["You can set your keybinds quickly by typing /kb."] = "你可以通過輸入/kb 快速綁定按鍵."
L["You can toggle the microbar by using your middle mouse button on the minimap you can also accomplish this by enabling the actual microbar located in the actionbar settings."] = "你可以通過滑鼠中鍵點擊小地圖或在快捷列設定內選擇打開微型系統欄."
L["You can use the /resetui command to reset all of your movers. You can also use the command to reset a specific mover, /resetui <mover name>.\nExample: /resetui Player Frame"] = "使用/resetui命令可以重置你的所有框架位置. 你也可以通過命令/resetui <框架名稱> 單獨重置某個框架.\n例如: /resetui Player Frame"

--UnitFrames
L["Dead"] = true;
L["Ghost"] = "鬼魂"
L["Offline"] = "離線"
