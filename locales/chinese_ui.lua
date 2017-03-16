-- Chinese localization file for zhCN.
local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("ElvUI", "zhCN")
if not L then return end

--*_ADDON locales
L["INCOMPATIBLE_ADDON"] = "插件 %s 不相容于 ElvUI 的 %s 模组。请停用不相容的插件，或停用模组。"

--*_MSG locales
L["LOGIN_MSG"] = "欢迎使用 %sElvUI|r %s%s|r 版，请输入 /ec 进入设定介面。如需技术支援，请至 https://github.com/ElvUI-WotLK/ElvUI"

--ActionBars
L["Binding"] = "绑定"
L["Key"] = "键"
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
L["No bindings set."] = "无绑定设定"
L["Remove Bar %d Action Page"] = "移除第 %d 动作条"
L["Trigger"] = "触发器"

--Bags
L["Bank"] = "银行"
L["Hold Control + Right Click:"] = "按住 Ctrl 并按鼠标右键："
L["Hold Shift + Drag:"] = true;
L["Purchase Bags"] = "购买背包"
L["Reset Position"] = "重设位置"
L["Sort Bags"] = true;
L["Temporary Move"] = "移动背包"
L["Toggle Bags"] = "背包开关"
L["Toggle Key"] = true;
L["Vendor Grays"] = "出售灰色物品"

--Chat
L["AFK"] = "离开" --Also used in datatexts and tooltip
L["BG"] = true;
L["BGL"] = true;
L["DND"] = "忙碌" --Also used in datatexts and tooltip
L["G"] = "公会"
L["Invalid Target"] = "无效的目标"
L["O"] = "干部"
L["P"] = "队伍"
L["PL"] = "队长"
L["R"] = "团队"
L["RL"] = "团队队长"
L["RW"] = "团队警告"
L["says"] = "说"
L["whispers"] = "密语"
L["yells"] = "大喊"

--DataTexts
L["(Hold Shift) Memory Usage"] = "(按住Shift) 内存占用"
L["Avoidance Breakdown"] = "免伤统计"
L["Character: "] = "角色: "
L["Chest"] = "胸"
L["Combat Time"] = true;
L["copperabbrev"] = "|cffeda55f铜|r"
L["Deficit:"] = "赤字:"
L["DPS"] = "伤害输出"
L["Earned:"] = "赚取:"
L["Friends List"] = "好友列表"
L["Friends"] = "好友" --Also in Skins
L["goldabbrev"] = "|cffffd700金|r"
L["Hit"] = "命中"
L["Hold Shift + Right Click:"] = "按住Shift + 右键点击"
L["Home Latency:"] = "本机延迟:"
L["HP"] = "生命值"
L["HPS"] = "治疗输出"
L["lvl"] = "等级"
L["Miss Chance"] = true;
L["Mitigation By Level: "] = "等级减伤: "
L["No Guild"] = "没有公会"
L["Profit:"] = "利润:"
L["Reload UI"] = true;
L["Reset Data: Hold Shift + Right Click"] = "重置数据: 按住 Shift + 右键点击"
L["Right Click: Reset CPU Usage"] = true;
L["Saved Raid(s)"] = "已有进度的副本"
L["Server: "] = "服务器: "
L["Session:"] = "本次登入:"
L["silverabbrev"] = "|cffc7c7cf银|r"
L["SP"] = "法术强度"
L["Spent:"] = "花费:"
L["Stats For:"] = "统计:"
L["Total CPU:"] = "CPU占用"
L["Total Memory:"] = "总内存:"
L["Total: "] = "合计: "
L["Unhittable:"] = "未命中:"
L["Wintergrasp"] = true;

--DebugTools
L["%s: %s tried to call the protected function '%s'."] = "%s: %s 尝试调用保护函数 '%s'."
L["No locals to dump"] = "没有本地文件"

--Distributor
L["%s is attempting to share his filters with you. Would you like to accept the request?"] = "%s 试图与你分享过滤器配置. 你是否接受?"
L["%s is attempting to share the profile %s with you. Would you like to accept the request?"] = "%s 试图与你分享配置文件 %s. 你是否接受?"
L["Data From: %s"] = "数据来源: %s"
L["Filter download complete from %s, would you like to apply changes now?"] = "过滤器配置下载于 %s, 你是否现在变更?"
L["Lord! It's a miracle! The download up and vanished like a fart in the wind! Try Again!"] = "天啊! 太奇葩了! 下载消失了! 就像在风中放了一个屁... 再试一次吧!"
L["Profile download complete from %s, but the profile %s already exists. Change the name or else it will overwrite the existing profile."] = "配置文件从 %s 下载完成, 但是配置文件 %s 已存在. 请更改名称, 否则它会覆盖你的现有配置文件."
L["Profile download complete from %s, would you like to load the profile %s now?"] = "配置文件从 %s 下载完成, 你是否加载配置文件 %s?"
L["Profile request sent. Waiting for response from player."] = "已发送文件请求. 等待对方响应."
L["Request was denied by user."] = "请求被对方拒绝."
L["Your profile was successfully recieved by the player."] = "你的配置文件已被其他玩家成功接收."

--Install
L["Aura Bars & Icons"] = "光环条与图标"
L["Auras Set"] = "光环样式设置"
L["Auras"] = "光环"
L["Caster DPS"] = "法系输出"
L["Chat Set"] = "对话设定"
L["Chat"] = "聊天框设定"
L["Choose a theme layout you wish to use for your initial setup."] = "为你的个人设置选择一个你喜欢的皮肤主题."
L["Classic"] = "经典"
L["Click the button below to resize your chat frames, unitframes, and reposition your actionbars."] = "点击下面的按钮调整聊天框、单位框架的尺寸，以及移动动作条位置"
L["Config Mode:"] = "设置模式:"
L["CVars Set"] = "参数设定"
L["CVars"] = "参数"
L["Dark"] = "黑暗"
L["Disable"] = "禁用"
L["ElvUI Installation"] = "安装 ElvUI"
L["Finished"] = "完成"
L["Grid Size:"] = "网格尺寸:"
L["Healer"] = "治疗"
L["High Resolution"] = "高分辨率"
L["high"] = "高"
L["Icons Only"] = "图标"
L["If you have an icon or aurabar that you don't want to display simply hold down shift and right click the icon for it to disapear."] = "如果你有不想显示的图标或光环条, 你可以简单的通过按住Shift右键点击使它隐藏."
L["Importance: |cff07D400High|r"] = "重要度: |cff07D400高|r"
L["Importance: |cffD3CF00Medium|r"] = "重要性: |cffD3CF00中|r"
L["Importance: |cffFF0000Low|r"] = "重要性：|cffFF0000低|r"
L["Installation Complete"] = "安装完成"
L["Layout Set"] = "界面布局设置"
L["Layout"] = "界面布局"
L["Lock"] = "锁定"
L["Low Resolution"] = "低分辨率"
L["low"] = "低"
L["Nudge"] = "微调"
L["Physical DPS"] = "物理输出"
L["Please click the button below so you can setup variables and ReloadUI."] = "请按下方按钮设定变数并重载介面。"
L["Please click the button below to setup your CVars."] = "请按下方按钮设定参数."
L["Please press the continue button to go onto the next step."] = "请按继续按钮到下一步"
L["Resolution Style Set"] = "分辨率样式设置"
L["Resolution"] = "分辨率"
L["Select the type of aura system you want to use with ElvUI's unitframes. Set to Aura Bar & Icons to use both aura bars and icons, set to icons only to only see icons."] = true;
L["Setup Chat"] = "设定聊天框"
L["Setup CVars"] = "设定参数"
L["Skip Process"] = "略过"
L["Sticky Frames"] = "框架依附"
L["Tank"] = "坦克"
L["The chat windows function the same as Blizzard standard chat windows, you can right click the tabs and drag them around, rename, etc. Please click the button below to setup your chat windows."] = "对话视窗与 WOW 原始对话视窗的操作方式相同，你可以拖拉、移动分页或重新命名分页。请按下方按钮以设定对话视窗。"
L["The in-game configuration menu can be accessed by typing the /ec command or by clicking the 'C' button on the minimap. Press the button below if you wish to skip the installation process."] = "若要进入内建设定选单，请输入 /ec，或者按一下小地图旁的 C 按钮。若要略过安装程序，请按下方按钮。"
L["Theme Set"] = "主题设置"
L["Theme Setup"] = "主题安装"
L["This install process will help you learn some of the features in ElvUI has to offer and also prepare your user interface for usage."] = "此安装程序有助你了解 ElvUI 部份功能，并可协助你预先设定 UI。"
L["This is completely optional."] = "这是可选项。"
L["This part of the installation process sets up your chat windows names, positions and colors."] = "此安装步骤将会设定聊天框的名称、位置和颜色。"
L["This part of the installation process sets up your World of Warcraft default options it is recommended you should do this step for everything to behave properly."] = "此安装步骤将会设定 WOW 预设选项，建议你执行此步骤，以确保功能均可正常运作。"
L["This resolution doesn't require that you change settings for the UI to fit on your screen."] = "这个分辨率不需要你改动任何设置以适应你的屏幕。"
L["This resolution requires that you change some settings to get everything to fit on your screen."] = "这个分辨率需要你改变一些设置才能适应你的屏幕。"
L["This will change the layout of your unitframes and actionbars."] = "这将会改变你单位框架和动作条的构架。"
L["Trade"] = "拾取/交易"
L["Welcome to ElvUI version %s!"] = "欢迎使用 ElvUI 版本 %s!"
L["You are now finished with the installation process. If you are in need of technical support please visit us at https://github.com/ElvUI-WotLK/ElvUI"] = true;
L["You can always change fonts and colors of any element of ElvUI from the in-game configuration."] = "你可以在游戏内的设定选项内更改ElvUI的字体、颜色等设定."
L["You can now choose what layout you wish to use based on your combat role."] = "你现在可以根据你的战斗角色选择合适的布局。"
L["You may need to further alter these settings depending how low you resolution is."] = "根据你的分辨率你可能需要改动这些设置。"
L["Your current resolution is %s, this is considered a %s resolution."] = "你当前的分辨率是 %s, 这被认为是个 %s 分辨率。"

--Misc
L["ABOVE_THREAT_FORMAT"] = "%s: %.0f%% [%.0f%% 以上 |cff%02x%02x%02x%s|r]"
L["Bars"] = "条"
L["Calendar"] = "日历"
L["Can't Roll"] = "无法需求此装备"
L["Disband Group"] = "解散队伍"
L["Empty Slot"] = true;
L["Enable"] = "启用"
L["Experience"] = "经验/声望条"
L["Farm Mode"] = true;
L["Fishy Loot"] = "贪婪";
L["Left Click:"] = "鼠标左键："
L["Raid Menu"] = "团队选单"
L["Remaining:"] = "剩余:"
L["Rested:"] = "休息:"
L["Right Click:"] = "鼠标右键："
L["Show BG Texts"] = "显示战场资讯文字"
L["Toggle Chat Frame"] = "开关聊天框架"
L["Toggle Configuration"] = "设置开关"
L["XP:"] = "经验:"
L["You don't have permission to mark targets."] = "你没有标记目标的权限"

--Movers
L["Arena Frames"] = "竞技场框架"
L["Bag Mover (Grow Down)"] = true;
L["Bag Mover (Grow Up)"] = true;
L["Bag Mover"] = true;
L["Bags"] = "背包" --Also in DataTexts
L["Bank Mover (Grow Down)"] = true;
L["Bank Mover (Grow Up)"] = true;
L["Bar "] = "动作条 " --Also in ActionBars
L["BNet Frame"] = "战网提示资讯"
L["Boss Frames"] = "首领框架"
L["Classbar"] = "职业特有条"
L["Experience Bar"] = "经验条"
L["Focus Castbar"] = "焦点目标施法条"
L["Focus Frame"] = "专注目标框架"
L["FocusTarget Frame"] = "专注目标的目标框架"
L["GM Ticket Frame"] = "GM 对话框"
L["Left Chat"] = "左侧对话框"
L["Loot / Alert Frames"] = "拾取 / 提醒框"
L["Loot Frame"] = "拾取框架"
L["MA Frames"] = "主助理框"
L["Micro Bar"] = "微型系统菜单" --Also in ActionBars
L["Minimap"] = "小地图"
L["MirrorTimer"] = "镜像计时器"
L["MT Frames"] = "主坦克框"
L["Party Frames"] = "队伍框架"
L["Pet Bar"] = "宠物动作条" --Also in ActionBars
L["Pet Castbar"] = "宠物施法条"
L["Pet Frame"] = "宠物框架"
L["PetTarget Frame"] = "宠物目标框架"
L["Player Buffs"] = "玩家增益"
L["Player Castbar"] = "玩家施法条"
L["Player Debuffs"] = "玩家减益"
L["Player Frame"] = "玩家框架"
L["Player Powerbar"] = "玩家能量条"
L["Raid Frames"] = "团队框架"
L["Raid Pet Frames"] = "团队宠物框架"
L["Raid-40 Frames"] = "40人团队框架"
L["Reputation Bar"] = "声望条"
L["Right Chat"] = "右侧对话框"
L["Stance Bar"] = "姿态条" --Also in ActionBars
L["Target Castbar"] = "目标施法条"
L["Target Frame"] = "目标框架"
L["Target Powerbar"] = "目标能量条"
L["TargetTarget Frame"] = "目标的目标框架"
L["TargetTargetTarget Frame"] = "目标的目标的目标框架"
L["Time Manager Frame"] = true;
L["Tooltip"] = "鼠标提示"
L["Totems"] = true;
L["Vehicle Seat Frame"] = "载具座位框"
L["Watch Frame"] = true;
L["Weapons"] = true;
L["DESC_MOVERCONFIG"] = [=[解除框架移动锁定. 现在可以移动它们, 移好后请点击「锁定」.

Options:
  Shift + RightClick - Hides mover temporarily.
  Ctrl + RightClick - Resets mover position to default.
]=]

--Plugin Installer
L["ElvUI Plugin Installation"] = "ElvUI插件安装"
L["In Progress"] = "正在进行中"
L["List of installations in queue:"] = "即将安装的列表:"
L["Pending"] = "等待中"
L["Steps"] = "步骤"

--Prints
L[" |cff00ff00bound to |r"] = " |cff00ff00绑定到 |r"
L["%s frame(s) has a conflicting anchor point, please change either the buff or debuff anchor point so they are not attached to each other. Forcing the debuffs to be attached to the main unitframe until fixed."] = "%s 个框架锚点冲突，请移动buff或者debuff锚点让他们彼此不依附。暂时强制debuff依附到主框架。"
L["All keybindings cleared for |cff00ff00%s|r."] = "取消 |cff00ff00%s|r 所有绑定的快捷键."
L["Already Running.. Bailing Out!"] = "正在运行!"
L["Battleground datatexts temporarily hidden, to show type /bgstats or right click the 'C' icon near the minimap."] = "战场资讯暂时隐藏, 你可以通过输入 /bgstats 或右键点击小地图旁「C」按钮显示."
L["Battleground datatexts will now show again if you are inside a battleground."] = "当你处于战场时战场资讯将再次显示."
L["Binds Discarded"] = "取消绑定"
L["Binds Saved"] = "储存绑定"
L["Confused.. Try Again!"] = "请再试一次！"
L["No gray items to delete."] = "没有要删除的灰色物品"
L["The spell '%s' has been added to the Blacklist unitframe aura filter."] = "法术"%s"已经被添加到单位框架的光环过滤器中."
L["This setting caused a conflicting anchor point, where '%s' would be attached to itself. Please check your anchor points. Setting '%s' to be attached to '%s'."] = true;
L["Vendored gray items for:"] = "已出售灰色物品:"
L["You don't have enough money to repair."] = "没有足够的资金来修复."
L["You must be at a vendor."] = "你必需以商人为目标."
L["Your items have been repaired for: "] = "装备已修复: "
L["Your items have been repaired using guild bank funds for: "] = "物品已使用公会银行资金修复: "
L["|cFFE30000Lua error recieved. You can view the error message when you exit combat."] = "|cFFE30000LUA错误已接收, 你可以在脱离战斗后检查.|r"

--Static Popups
L["A setting you have changed will change an option for this character only. This setting that you have changed will be uneffected by changing user profiles. Changing this setting requires that you reload your User Interface."] = "你所做的改动只会影响到使用这个插件的本角色, 你需要重新加载界面才能使改动生效."
L["Are you sure you want to apply this font to all ElvUI elements?"] = true;
L["Are you sure you want to delete all your gray items?"] = "确定需要摧毁你的灰色物品?"
L["Are you sure you want to disband the group?"] = "确定要解散队伍?"
L["Are you sure you want to reset all the settings on this profile?"] = "确定需要重置这个配置文件中的所有设置?"
L["Are you sure you want to reset every mover back to it's default position?"] = "确定需要重置所有框架至默认位置?"
L["Because of the mass confusion caused by the new aura system I've implemented a new step to the installation process. This is optional. If you like how your auras are setup go to the last step and click finished to not be prompted again. If for some reason you are prompted repeatedly please restart your game."] = "由于大量的改动导致光环系统需要一个新的安装过程. 这是可选的, 最后一步将设置你的光环样式. 点击「完成」将不再提示. 如果由于某些原因反复提示, 请重新开启游戏."
L["Can't buy anymore slots!"] = "银行背包栏位已达最大值"
L["Disable Warning"] = "停用警告"
L["Discard"] = "取消"
L["Do you enjoy the new ElvUI?"] = "你喜欢新的ElvUI么？"
L["Do you swear not to post in technical support about something not working without first disabling the addon/module combination first?"] = true;
L["ElvUI is five or more revisions out of date. You can download the newest version from https://github.com/ElvUI-WotLK/ElvUI/"] = "ElvUI每天有5个或者更多的版本。你可以在 https://github.com/ElvUI-WotLK/ElvUI/ 下载到最新的版本"
L["ElvUI is out of date. You can download the newest version from https://github.com/ElvUI-WotLK/ElvUI/"] = true;
L["ElvUI needs to perform database optimizations please be patient."] = "ElvUI需要进行数据库优化，请耐性等待。"
L["Hover your mouse over any actionbutton or spellbook button to bind it. Press the escape key or right click to clear the current actionbutton's keybinding."] = "移动滑鼠到动作条或技能书按钮上绑定快捷键. 按ESC或滑鼠右键取消目前快捷键"
L["I Swear"] = "我承诺"
L["No, Revert Changes!"] = "不，撤销修改！"
L["Oh lord, you have got ElvUI and Tukui both enabled at the same time. Select an addon to disable."] = "你不能同时使用Elvui和Tukui，请选择一个禁用."
L["One or more of the changes you have made require a ReloadUI."] = "已变更一或多个设定，需重载界面."
L["One or more of the changes you have made will effect all characters using this addon. You will have to reload the user interface to see the changes you have made."] = "你所做的改动可能会影响到使用这个插件的所有角色，你需要重新加载界面才能使改动生效。"
L["Save"] = "储存"
L["The profile you tried to import already exists. Choose a new name or accept to overwrite the existing profile."] = "你尝试导入的配置文件已经存在。请选择一个新的名字或者确认覆盖存在的配置文件。"
L["Type /hellokitty to revert to old settings."] = "输入/hellokitty以撤销到原来的设定"
L["Using the healer layout it is highly recommended you download the addon Clique if you wish to have the click-to-heal function."] = true;
L["Yes, Keep Changes!"] = "是的，保存修改！"
L["You have changed the Thin Border Theme option. You will have to complete the installation process to remove any graphical bugs."] = true;
L["You have changed your UIScale, however you still have the AutoScale option enabled in ElvUI. Press accept if you would like to disable the Auto Scale option."] = "你改变了界面缩放比例，然而ElvUI的自动缩放选项是开启的。点击接受以关闭ElvUI的自动缩放。"
L["You have imported settings which may require a UI reload to take effect. Reload now?"] = "你导入的设置可能需要重载界面才能生效。确认重载？"
L["You must purchase a bank slot first!"] = "你必需购买一个银行背包栏位"

--Tooltip
L["Count"] = "计数"
L["Item Level:"] = "物品等级:"
L["Talent Specialization:"] = "天赋专精:"
L["Targeted By:"] = "同目标的有:"

--Tutorials
L["A raid marker feature is available by pressing Escape -> Keybinds scroll to the bottom under ElvUI and setting a keybind for the raid marker."] = "你可以通过按ESC键 -> 按键设置, 滚动到ElvUI设置下方设置一个快速标记的快捷键."
L["ElvUI has a dual spec feature which allows you to load different profiles based on your current spec on the fly. You can enable this from the profiles tab."] = "ElvUI可以根据你所使用的天赋自动套用不同的设置档. 你可以在配置文件中使用此功能."
L["For technical support visit us at https://github.com/ElvUI-WotLK/ElvUI"] = "如需技术支援请至 https://github.com/ElvUI-WotLK/ElvUI"
L["If you accidently remove a chat frame you can always go the in-game configuration menu, press install, go to the chat portion and reset them."] = "如果你不慎移除了对话框, 你可以重新安装一次重置他们."
L["If you are experiencing issues with ElvUI try disabling all your addons except ElvUI, remember ElvUI is a full UI replacement addon, you cannot run two addons that do the same thing."] = "如果你遇到问题, ElvUI会尝试禁用你除了ElvUI之外的插件. 请记住你不能用不同的插件实现同一功能."
L["The focus unit can be set by typing /focus when you are targeting the unit you want to focus. It is recommended you make a macro to do this."] = "你可以通过 /focus 命令设置焦点目标."
L["To move abilities on the actionbars by default hold shift + drag. You can change the modifier key from the actionbar options menu."] = "你可以通过按住Shift拖动技能条中的按键. 你可以在 Blizzard 的动作条设置中更改按键."
L["To setup which channels appear in which chat frame, right click the chat tab and go to settings."] = "你可以通过右键点击对话框标签栏设置你需要在对话框内显示的频道."
L["You can access copy chat and chat menu functions by mouse over the top right corner of chat panel and left/right click on the button that will appear."] = "你可以通过鼠标滑过对话框右上角点击复制图标打开对话复制窗口."
L["You can see someones average item level of their gear by holding shift and mousing over them. It should appear inside the tooltip."] = "你可以通过按住Shift并将鼠标滑过目标看到目标的装备等级, 这将显示在你的鼠标提示框内."
L["You can set your keybinds quickly by typing /kb."] = "你可以通过输入 /kb 快速绑定按键."
L["You can toggle the microbar by using your middle mouse button on the minimap you can also accomplish this by enabling the actual microbar located in the actionbar settings."] = "你可以通过鼠标中键点击小地图或在动作条设置内选择打开微型系统栏."
L["You can use the /resetui command to reset all of your movers. You can also use the command to reset a specific mover, /resetui <mover name>.\nExample: /resetui Player Frame"] = "使用 /resetui 命令可以重置你的所有框架位置. 你也可以通过命令 /resetui <框架名称> 单独重置某个框架.\n例如: /resetui Player Frame"

--UnitFrames
L["Dead"] = true;
L["Ghost"] = "鬼魂"
L["Offline"] = "离线"
