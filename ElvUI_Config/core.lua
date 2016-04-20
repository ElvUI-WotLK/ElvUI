local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local D = E:GetModule("Distributor");
local AceGUI = LibStub("AceGUI-3.0");

local tsort, tinsert = table.sort, table.insert
local floor, ceil = math.floor, math.ceil
local DEFAULT_WIDTH = 890;
local DEFAULT_HEIGHT = 651;
local AC = LibStub("AceConfig-3.0-ElvUI")
local ACD = LibStub("AceConfigDialog-3.0-ElvUI")
local ACR = LibStub("AceConfigRegistry-3.0-ElvUI")

AC:RegisterOptionsTable("ElvUI", E.Options)
ACD:SetDefaultSize("ElvUI", DEFAULT_WIDTH, DEFAULT_HEIGHT)	

E.Options.args = {
	ElvUI_Header = {
		order = 1,
		type = "header",
		name = L["Version"]..format(": |cff99ff33%s|r",E.version),
		width = "full",		
	},
	LoginMessage = {
		order = 2,
		type = 'toggle',
		name = L['Login Message'],
		get = function(info) return E.db.general.loginmessage end,
		set = function(info, value) E.db.general.loginmessage = value end,
	},	
	ToggleTutorial = {
		order = 3,
		type = 'execute',
		name = L['Toggle Tutorials'],
		func = function() E:Tutorials(true); E:ToggleConfig()  end,
	},
	Install = {
		order = 4,
		type = 'execute',
		name = L['Install'],
		desc = L['Run the installation process.'],
		func = function() E:Install(); E:ToggleConfig() end,
	},	
	ToggleAnchors = {
		order = 5,
		type = "execute",
		name = L["Toggle Anchors"],
		desc = L["Unlock various elements of the UI to be repositioned."],
		func = function() E:ToggleConfigMode() end,
	},
	ResetAllMovers = {
		order = 6,
		type = "execute",
		name = L["Reset Anchors"],
		desc = L["Reset all frames to their original positions."],
		func = function() E:ResetUI() end,
	},	
}

E.Options.args.general = {
	type = "group",
	name = L["General"],
	order = 1,
	childGroups = "select",
	get = function(info) return E.db.general[ info[#info] ] end,
	set = function(info, value) E.db.general[ info[#info] ] = value end,
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["ELVUI_DESC"],
		},			
		general = {
			order = 2,
			type = "group",
			name = L["General"],
			args = {
				pixelPerfect = {
					order = 1,
					name = L['Pixel Perfect'],
					desc = L['The Pixel Perfect option will change the overall apperance of your UI. Using Pixel Perfect is a slight performance increase over the traditional layout.'],
					type = 'toggle',
					get = function(info) return E.private.general.pixelPerfect end,
					set = function(info, value) E.private.general.pixelPerfect = value; E:StaticPopup_Show("PRIVATE_RL") end					
				},
				interruptAnnounce = {
					order = 2,
					name = L['Announce Interrupts'],
					desc = L['Announce when you interrupt a spell to the specified chat channel.'],
					type = 'select',
					values = {
						['NONE'] = NONE,
						['SAY'] = SAY,
						['PARTY'] = L["Party Only"],
						['RAID'] = L["Party / Raid"],
						['RAID_ONLY'] = L["Raid Only"],
					},
				},
				autoRepair = {
					order = 3,
					name = L['Auto Repair'],
					desc = L['Automatically repair using the following method when visiting a merchant.'],
					type = 'select',
					values = {
						['NONE'] = NONE,
						['GUILD'] = GUILD,
						['PLAYER'] = PLAYER,
					},				
				},
				mapAlpha = {
					order = 4,
					name = L["Map Alpha While Moving"],
					desc = L['Controls what the transparency of the worldmap will be set to when you are moving.'],
					type = 'range',
					isPercent = true,
					min = 0, max = 1, step = 0.01,
				},
				autoAcceptInvite = {
					order = 5,
					name = L['Accept Invites'],
					desc = L['Automatically accept invites from guild/friends.'],
					type = 'toggle',
				},
				vendorGrays = {
					order = 6,
					name = L['Vendor Grays'],
					desc = L['Automatically vendor gray items when visiting a vendor.'],
					type = 'toggle',				
				},				
				loot = {
					order = 7,
					type = "toggle",
					name = L['Loot'],
					desc = L['Enable/Disable the loot frame.'],
					get = function(info) return E.private.general.loot end,
					set = function(info, value) E.private.general.loot = value; E:StaticPopup_Show("PRIVATE_RL") end
				},
				autoRoll = {
					order = 8,
					name = L['Auto Greed/DE'],
					desc = L['Automatically select greed or disenchant (when available) on green quality items. This will only work if you are the max level.'],
					type = 'toggle',		
					disabled = function() return not E.private.general.lootRoll end
				},
				lootRoll = {
					order = 9,
					type = "toggle",
					name = L['Loot Roll'],
					desc = L['Enable/Disable the loot roll frame.'],
					get = function(info) return E.private.general.lootRoll end,
					set = function(info, value) E.private.general.lootRoll = value; E:StaticPopup_Show("PRIVATE_RL") end
				},
				autoScale = {
					order = 10,
					name = L["Auto Scale"],
					desc = L["Automatically scale the User Interface based on your screen resolution"],
					type = "toggle",	
					get = function(info) return E.global.general.autoScale end,
					set = function(info, value) E.global.general[ info[#info] ] = value; E:StaticPopup_Show("GLOBAL_RL") end
				},
				hideErrorFrame = {
					order = 11,
					name = L["Hide Error Text"],
					desc = L["Hides the red error text at the top of the screen while in combat."],
					type = "toggle"
				},
				eyefinity = {
					order = 12,
					name = L["Multi-Monitor Support"],
					desc = L["Attempt to support eyefinity/nvidia surround."],
					type = "toggle",
					get = function(info) return E.global.general.eyefinity end,
					set = function(info, value) E.global.general[ info[#info] ] = value; E:StaticPopup_Show("GLOBAL_RL") end
				},
				taintLog = {
					order = 13,
					type = "toggle",
					name = L["Log Taints"],
					desc = L["Send ADDON_ACTION_BLOCKED errors to the Lua Error frame. These errors are less important in most cases and will not effect your game performance. Also a lot of these errors cannot be fixed. Please only report these errors if you notice a Defect in gameplay."],
				},
				bottomPanel = {
					order = 14,
					type = 'toggle',
					name = L['Bottom Panel'],
					desc = L['Display a panel across the bottom of the screen. This is for cosmetic only.'],
					get = function(info) return E.db.general.bottomPanel end,
					set = function(info, value) E.db.general.bottomPanel = value; E:GetModule('Layout'):BottomPanelVisibility() end						
				},
				topPanel = {
					order = 15,
					type = 'toggle',
					name = L['Top Panel'],
					desc = L['Display a panel across the top of the screen. This is for cosmetic only.'],
					get = function(info) return E.db.general.topPanel end,
					set = function(info, value) E.db.general.topPanel = value; E:GetModule('Layout'):TopPanelVisibility() end						
				},
				afk = {
					order = 16,
					type = 'toggle',
					name = L['AFK Mode'],
					desc = L['When you go AFK display the AFK screen.'],
					get = function(info) return E.db.general.afk end,
					set = function(info, value) E.db.general.afk = value; E:GetModule('AFK'):Toggle() end
				},
				smallerWorldMap = {
					order = 17,
					type = "toggle",
					name = L["Smaller World Map"],
					desc = L["Make the world map smaller."],
					get = function(info) return E.global.general.smallerWorldMap; end,
					set = function(info, value) E.global.general.smallerWorldMap = value; E:StaticPopup_Show("GLOBAL_RL"); end
				},
				worldMapCoordinates = {
					order = 18,
 					type = "toggle",
					name = L["World Map Coordinates"],
					desc = L["Puts coordinates on the world map."],
					get = function(info) return E.global.general.worldMapCoordinates; end,
					set = function(info, value) E.global.general.worldMapCoordinates = value; E:StaticPopup_Show("GLOBAL_RL"); end
				},
				enhancedPvpMessages = {
					order = 19,
					type = "toggle",
					name = L["Enhanced PVP Messages"],
					desc = L["Display battleground messages in the middle of the screen."]
				},
				chatBubbles = {
					order = 30,
					type = "group",
					guiInline = true,
					name = L["Chat Bubbles"],
					args = {
						style = {
							order = 1,
							type = "select",
							name = L["Chat Bubbles Style"],
							desc = L["Skin the blizzard chat bubbles."],
							get = function(info) return E.private.general.chatBubbles; end,
							set = function(info, value) E.private.general.chatBubbles = value; E:StaticPopup_Show("PRIVATE_RL"); end,
							values = {
								['backdrop'] = L["Skin Backdrop"],
								['nobackdrop'] = L["Remove Backdrop"],
								['disabled'] = L["Disabled"]
							}
						},
						font = {
							order = 2,
							type = "select",
							name = L["Font"],
							dialogControl = 'LSM30_Font',
							values = AceGUIWidgetLSMlists.font,
							get = function(info) return E.private.general.chatBubbleFont; end,
							set = function(info, value) E.private.general.chatBubbleFont = value; E:StaticPopup_Show("PRIVATE_RL"); end,
						},
						fontSize = {
							order = 3,
							type = "range",
							name = L["Font Size"],
							get = function(info) return E.private.general.chatBubbleFontSize; end,
							set = function(info, value) E.private.general.chatBubbleFontSize = value; E:StaticPopup_Show("PRIVATE_RL"); end,
							min = 4, max = 20, step = 1,
						},
					},
				},
			},
		},
		minimap = { -- Мини-карта
			order = 3,
			get = function(info) return E.db.general.minimap[ info[#info] ] end,	
			name = MINIMAP_LABEL,
			type = "group",
			args = {
				enable = { -- Включить
					order = 1,
					type = "toggle",
					name = L["Enable"],
					desc = L['Enable/Disable the minimap. |cffFF0000Warning: This will prevent you from seeing the consolidated buffs bar, and prevent you from seeing the minimap datatexts.|r'],
					get = function(info) return E.private.general.minimap[ info[#info] ] end,
					set = function(info, value) E.private.general.minimap[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL") end,	
				},
				generalGruop = { -- Общие
					order = 2,
					type = "group",
					guiInline = true,
					name = L["General"],
					disabled = function() return not E.private.general.minimap.enable end,
					args = {
						size = { -- Размер
							order = 1,
							type = "range",
							name = L["Size"],
							desc = L['Adjust the size of the minimap.'],
							min = 120, max = 250, step = 1,
							set = function(info, value) E.db.general.minimap[ info[#info] ] = value; E:GetModule('Minimap'):UpdateSettings() end,
						},	
						locationText = { -- Текст локачии
							order = 2,
							type = 'select',
							name = L['Location Text'],
							desc = L['Change settings for the display of the location text that is on the minimap.'],
							get = function(info) return E.db.general.minimap.locationText end,
							set = function(info, value) E.db.general.minimap.locationText = value; E:GetModule('Minimap'):UpdateSettings() end,
							values = {
								['MOUSEOVER'] = L['Minimap Mouseover'],
								['SHOW'] = L['Always Display'],
								['HIDE'] = L['Hide'],
							},
						},
					},
				},
			},		
		},
		experience = { -- Индикатор опыта
			order = 4,
			get = function(info) return E.db.general.experience[ info[#info] ] end,
			set = function(info, value) E.db.general.experience[ info[#info] ] = value; E:GetModule('Misc'):UpdateExpRepDimensions() end,		
			type = "group",
			name = XPBAR_LABEL,
			args = {
				enable = { -- Включить
					order = 1,
					type = "toggle",
					name = L["Enable"],
					set = function(info, value) E.db.general.experience[ info[#info] ] = value; E:GetModule('Misc'):EnableDisable_ExperienceBar() end,
				},
				generalGroup = { -- Общие
					order = 2,
					type = "group",
					guiInline = true,
					name = L["General"],
					disabled = function() return not E.db.general.experience.enable end,
					args = {
						mouseover = { -- При наведении
							order = 1,
							type = "toggle",
							name = L['Mouseover'],
						},			
						width = { -- Ширина
							order = 2,
							type = "range",
							name = L["Width"],
							min = 5, max = ceil(GetScreenWidth() or 800), step = 1,
						},
						height = { -- Высота
							order = 3,
							type = "range",
							name = L["Height"],
							min = 5, max = ceil(GetScreenHeight() or 800), step = 1,
						},
						orientation = { -- Ориентация
							order = 4,
							type = "select",
							name = L['Orientation'],
							desc = L['Direction the bar moves on gains/losses'],
							values = {
								['HORIZONTAL'] = L['Horizontal'],
								['VERTICAL'] = L['Vertical']
							},
						},
						textFormat = { -- Формат текста
							order = 5,
							type = 'select',
							name = L["Text Format"],
							values = {
								NONE = NONE,
								PERCENT = L["Percent"],
								CURMAX = L["Current - Max"],
								CURPERC = L["Current - Percent"],
							},
							set = function(info, value) E.db.general.experience[ info[#info] ] = value; E:GetModule('Misc'):UpdateExperience() end,
						},	
					},
				},
				fontGroup = { -- Шрифт
					order = 3,
					type = "group",
					guiInline = true,
					name = L["Font"],
					disabled = function() return not E.db.general.experience.enable end,
					args = {
						textFont = { -- Шрифт
							type = 'select', dialogControl = 'LSM30_Font',
							order = 1,
							name = L['Font'],
							values = AceGUIWidgetLSMlists.font,
						},
						textSize = { -- Размер шрифта
							order = 2,
							name = L["Font Size"],
							type = "range",
							min = 6, max = 22, step = 1,
						},
						textOutline = { -- Граница шрифта
							order = 6,
							name = L['Font Outline'],
							desc = L['Set the font outline.'],
							type = 'select',
							values = {
								['NONE'] = L['None'],
								['OUTLINE'] = 'OUTLINE',
								['MONOCHROME'] = 'MONOCHROME',
								['MONOCHROMEOUTLINE'] = 'MONOCROMEOUTLINE',
								['THICKOUTLINE'] = 'THICKOUTLINE',
							},
						},
					},
				},
			},
		},
		reputation = { -- Репутация
			order = 5,
			get = function(info) return E.db.general.reputation[ info[#info] ] end,
			set = function(info, value) E.db.general.reputation[ info[#info] ] = value; E:GetModule('Misc'):UpdateExpRepDimensions() end,		
			type = "group",
			name = REPUTATION,
			args = {
				enable = { -- Включить
					order = 1,
					type = "toggle",
					name = L["Enable"],
					set = function(info, value) E.db.general.reputation[ info[#info] ] = value; E:GetModule('Misc'):EnableDisable_ReputationBar() end,
				},
				generalGroup = { -- Общие
					order = 2,
					type = "group",
					guiInline = true,
					name = L["General"],
					disabled = function() return not E.db.general.reputation.enable end,
					args = {
						mouseover = { -- При наведении
							order = 1,
							type = "toggle",
							name = L['Mouseover'],
						},
						width = { -- Ширина
							order = 2,
							type = "range",
							name = L["Width"],
							min = 5, max = ceil(GetScreenWidth() or 800), step = 1,
						},
						height = { -- Высота
							order = 3,
							type = "range",
							name = L["Height"],
							min = 5, max = ceil(GetScreenHeight() or 800), step = 1,
						},
						orientation = { -- Ориентация
							order = 4,
							type = "select",
							name = L['Orientation'],
							desc = L['Direction the bar moves on gains/losses'],
							values = {
								['HORIZONTAL'] = L['Horizontal'],
								['VERTICAL'] = L['Vertical']
							},
						},				
						textFormat = { -- Формат текста
							order = 7,
							type = 'select',
							name = L["Text Format"],
							values = {
								NONE = NONE,
								PERCENT = L["Percent"],
								CURMAX = L["Current - Max"],
								CURPERC = L["Current - Percent"],
							},
							set = function(info, value) E.db.general.reputation[ info[#info] ] = value; E:GetModule('Misc'):UpdateReputation() end,
						},
					},
				},
				fontGroup = { -- Шрифт
					order = 3,
					type = "group",
					guiInline = true,
					name = L["Font"],
					disabled = function() return not E.db.general.reputation.enable end,
					args = {
						textFont = { -- Шрифт
							type = 'select', dialogControl = 'LSM30_Font',
							order = 1,
							name = L['Font'],
							values = AceGUIWidgetLSMlists.font,
						},
						textSize = { -- Размер шрифта
							order = 2,
							name = L["Font Size"],
							type = "range",
							min = 6, max = 22, step = 1,
						},
						textOutline = { -- Граница шрифта
							order = 6,
							name = L['Font Outline'],
							desc = L['Set the font outline.'],
							type = 'select',
							values = {
								['NONE'] = L['None'],
								['OUTLINE'] = 'OUTLINE',
								['MONOCHROME'] = 'MONOCHROME',
								['MONOCHROMEOUTLINE'] = 'MONOCROMEOUTLINE',
								['THICKOUTLINE'] = 'THICKOUTLINE',
							},
						},
					},
				},
			},
		},
		threat = { -- Угроза
			order = 6,
			get = function(info) return E.db.general.threat[ info[#info] ] end,
			set = function(info, value) E.db.general.threat[ info[#info] ] = value; E:GetModule('Threat'):ToggleEnable()end,		
			type = "group",
			name = L['Threat'],
			args = {
				enable = { -- Включить
					order = 1,
					type = "toggle",
					name = L["Enable"],
				},
				generalGroup = { -- Общие
					order = 2,
					type = "group",
					guiInline = true,
					name = L["General"],
					disabled = function() return not E.db.general.threat.enable end,
					args = {
						position = { -- Позиция
							order = 1,
							type = 'select',
							name = L['Position'],
							desc = L['Adjust the position of the threat bar to either the left or right datatext panels.'],
							values = {
								['LEFTCHAT'] = L['Left Chat'],
								['RIGHTCHAT'] = L['Right Chat'],
							},
							set = function(info, value) E.db.general.threat[ info[#info] ] = value; E:GetModule('Threat'):UpdatePosition() end,
						},
					},
				},
				fontGroup = { -- Шрифт
					order = 3,
					type = "group",
					guiInline = true,
					name = L["Font"],
					disabled = function() return not E.db.general.threat.enable end,
					args = {
						textfont = { -- Шрифт
							type = "select", dialogControl = 'LSM30_Font',
							order = 4,
							name = L["Font"],
							values = AceGUIWidgetLSMlists.font,
							set = function(info, value) E.db.general.threat[ info[#info] ] = value; E:GetModule('Threat'):UpdatePosition() end,
						},
						textSize = { -- РАзмер шрифта
							order = 5,
							name = L["Font Size"],
							type = "range",
							min = 6, max = 22, step = 1,	
							set = function(info, value) E.db.general.threat[ info[#info] ] = value; E:GetModule('Threat'):UpdatePosition() end,
						},
						textOutline = { -- Граница шрифта
							order = 6,
							name = L["Font Outline"],
							desc = L["Set the font outline."],
							type = "select",
							values = {
								['NONE'] = L['None'],
								['OUTLINE'] = 'OUTLINE',
								['MONOCHROME'] = (not E.isMacClient) and 'MONOCHROME' or nil,
								['MONOCHROMEOUTLINE'] = 'MONOCROMEOUTLINE',
								['THICKOUTLINE'] = 'THICKOUTLINE',
							},
							set = function(info, value) E.db.general.threat[ info[#info] ] = value; E:GetModule('Threat'):UpdatePosition() end,
						},
					},
				},
			},
		},	
		totems = { -- Панель тотемов
			order = 7,
			type = "group",
			name = TUTORIAL_TITLE47,
			get = function(info) return E.db.general.totems[ info[#info] ] end,
			set = function(info, value) E.db.general.totems[ info[#info] ] = value; E:GetModule('Totems'):PositionAndSize() end,
			args = {
				enable = { -- Включить
					order = 1,
					type = "toggle",
					name = L["Enable"],
					set = function(info, value) E.db.general.totems[ info[#info] ] = value; E:GetModule('Totems'):ToggleEnable() end,
				},
				generalGroup = { -- Общие
					order = 2,
					type = "group",
					guiInline = true,
					name = L["General"],
					disabled = function() return not E.db.general.totems.enable end,
					args = {
						size = { -- Размер кнопок
							order = 1,
							type = 'range',
							name = L["Button Size"],
							desc = L['Set the size of your bag buttons.'],
							min = 24, max = 60, step = 1,
						},
						spacing = { -- Отступ кнопок
							order = 2,
							type = 'range',
							name = L['Button Spacing'],
							desc = L['The spacing between buttons.'],
							min = 1, max = 10, step = 1,
						},
						sortDirection = { -- Направление сортировки
							order = 3,
							type = 'select',
							name = L["Sort Direction"],
							desc = L['The direction that the bag frames will grow from the anchor.'],
							values = {
								['ASCENDING'] = L['Ascending'],
								['DESCENDING'] = L['Descending'],
							},
						},
						growthDirection = { -- НАправление панели
							order = 4,
							type = 'select',
							name = L['Bar Direction'],
							desc = L['The direction that the bag frames be (Horizontal or Vertical).'],
							values = {
								['VERTICAL'] = L['Vertical'],
								['HORIZONTAL'] = L['Horizontal'],
							},
						},
					},
				},
			},
		},
		cooldown = {
			type = "group",
			order = 10,
			name = L['Cooldown Text'],
			get = function(info)
				local t = E.db.cooldown[ info[#info] ]
				local d = P.cooldown[info[#info]]
				return t.r, t.g, t.b, t.a, d.r, d.g, d.b
			end,
			set = function(info, r, g, b)
				E.db.cooldown[ info[#info] ] = {}
				local t = E.db.cooldown[ info[#info] ]
				t.r, t.g, t.b = r, g, b
				E:UpdateCooldownSettings();
			end,	
			args = {
				enable = {
					type = "toggle",
					order = 1,
					name = L['Enable'],
					desc = L['Display cooldown text on anything with the cooldown spiril.'],
					get = function(info) return E.private.cooldown[ info[#info] ] end,
					set = function(info, value) E.private.cooldown[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL") end				
				},			
				threshold = {
					type = 'range',
					name = L['Low Threshold'],
					desc = L['Threshold before text turns red and is in decimal form. Set to -1 for it to never turn red'],
					min = -1, max = 20, step = 1,	
					order = 2,
					get = function(info) return E.db.cooldown[ info[#info] ] end,
					set = function(info, value)
						E.db.cooldown[ info[#info] ] = value
						E:UpdateCooldownSettings();
					end,				
				},
				restoreColors = {
					type = 'execute',
					name = L["Restore Defaults"],
					order = 3,
					func = function() 
						E.db.cooldown.expiringColor = P['cooldown'].expiringColor;
						E.db.cooldown.secondsColor = P['cooldown'].secondsColor;
						E.db.cooldown.minutesColor = P['cooldown'].minutesColor;
						E.db.cooldown.hoursColor = P['cooldown'].hoursColor;
						E.db.cooldown.daysColor = P['cooldown'].daysColor;
						E:UpdateCooldownSettings();
					end,
				},
				expiringColor = {
					type = 'color',
					order = 4,
					name = L['Expiring'],
					desc = L['Color when the text is about to expire'],					
				},
				secondsColor = {
					type = 'color',
					order = 5,
					name = L['Seconds'],
					desc = L['Color when the text is in the seconds format.'],			
				},
				minutesColor = {
					type = 'color',
					order = 6,
					name = L['Minutes'],
					desc = L['Color when the text is in the minutes format.'],		
				},
				hoursColor = {
					type = 'color',
					order = 7,
					name = L['Hours'],
					desc = L['Color when the text is in the hours format.'],				
				},	
				daysColor = {
					type = 'color',
					order = 8,
					name = L['Days'],
					desc = L['Color when the text is in the days format.'],			
				},				
			},
		},
		reminder = {
			type = 'group',
			order = 11,
			name = L['Reminder'],
			get = function(info) return E.db.general.reminder[ info[#info] ] end,
			set = function(info, value) E.db.general.reminder[ info[#info] ] = value; E:GetModule('ReminderBuffs'):UpdateSettings(); end,
			args = {
				enable = {
					order = 1,
					name = L['Enable'],
					desc = L['Display reminder bar on the minimap.'],
					type = 'toggle',
					set = function(info, value) E.db.general.reminder[ info[#info] ] = value; E:GetModule('Minimap'):UpdateSettings(); end
				},
				generalGroup = {
					order = 2,
					type = 'group',
					guiInline = true,
					name = L['General'],
					disabled = function() return not E.db.general.reminder.enable end,
					args = {
						durations = {
							order = 1,
							name = L['Remaining Time'],
							type = 'toggle'
						},
						reverse = {
							order = 2,
							name = L['Reverse highlight'],
							type = 'toggle'
						},
						position = {
							order = 3,
							type = "select",
							name = L["Position"],
							set = function(info, value) E.db.general.reminder[ info[#info] ] = value; E:GetModule("ReminderBuffs"):UpdatePosition(); end,
							values = {
								["LEFT"] = L["Left"],
								["RIGHT"] = L["Right"]
							},
						},
					},
				},
				fontGroup = {
					order = 3,
					type = 'group',
					guiInline = true,
					name = L['Font'],
					disabled = function() return not E.db.general.reminder.enable or not E.db.general.reminder.durations end,
					args = {
						font = {
							type = 'select', dialogControl = 'LSM30_Font',
							order = 1,
							name = L['Font'],
							values = AceGUIWidgetLSMlists.font
						},
						fontSize = {
							order = 2,
							name = L['Font Size'],
							type = 'range',
							min = 6, max = 22, step = 1
						},
						fontOutline = {
							order = 3,
							name = L['Font Outline'],
							desc = L['Set the font outline.'],
							type = 'select',
							values = {
								['NONE'] = L['None'],
								['OUTLINE'] = 'OUTLINE',
								['MONOCHROME'] = (not E.isMacClient) and 'MONOCHROME' or nil,
								['MONOCHROMEOUTLINE'] = 'MONOCROMEOUTLINE',
								['THICKOUTLINE'] = 'THICKOUTLINE'
							},
						},
					},
				},
			},
		},
		watchFrame = {
			order = 11,
			type = "group",
			name = L["Watch Frame"],
			get = function(info) return E.db.general[ info[#info] ]; end,
			set = function(info, value) E.db.general[ info[#info] ] = value; end,
			args = {
				watchFrameHeight = {
					order = 1,
					type = "range",
					name = L["Watch Frame Height"],
					desc = L["Height of the watch tracker. Increase size to be able to see more objectives."],
					min = 400, max = E.screenheight, step = 1,
					set = function(info, value) E.db.general.watchFrameHeight = value; E:GetModule('Blizzard'):WatchFrameHeight(); end
				}
			}
		}
	}
};

E.Options.args.media = {
	order = 2,
	type = "group",
	name = L["Media"],
	get = function(info) return E.db.general[ info[#info] ] end,
	set = function(info, value) E.db.general[ info[#info] ] = value end,	
	args = {
		fonts = {
			order = 1,
			type = "group",
			name = L["Fonts"],
			guiInline = true,
			args = {
				fontSize = {
					order = 1,
					name = L["Font Size"],
					desc = L["Set the font size for everything in UI. Note: This doesn't effect somethings that have their own seperate options (UnitFrame Font, Datatext Font, ect..)"],
					type = "range",
					min = 6, max = 22, step = 1,
					set = function(info, value) E.db.general[ info[#info] ] = value; E:UpdateMedia(); E:UpdateFontTemplates(); end,
				},	
				font = {
					type = "select", dialogControl = 'LSM30_Font',
					order = 2,
					name = L["Default Font"],
					desc = L["The font that the core of the UI will use."],
					values = AceGUIWidgetLSMlists.font,	
					set = function(info, value) E.db.general[ info[#info] ] = value; E:UpdateMedia(); E:UpdateFontTemplates(); end,
				},
				applyFontToAll = {
					order = 3,
					type = "execute",
					name = L["Apply Font To All"],
					desc = L["Applies the font and font size settings throughout the entire user interface. Note: Some font size settings will be skipped due to them having a smaller font size by default."],
					func = function()
						local font = E.db.general.font;
						local fontSize = E.db.general.fontSize;
						
						E.db.bags.itemLevelFont = font;
						E.db.bags.itemLevelFontSize = fontSize;
						E.db.bags.countFont = font;
						E.db.bags.countFontSize = fontSize;
						E.db.nameplate.font = font;
						--E.db.nameplate.fontSize = fontSize;
						E.db.nameplate.buffs.font = font;
						--E.db.nameplate.buffs.fontSize = fontSize;
						E.db.nameplate.debuffs.font = font;
						--E.db.nameplate.debuffs.fontSize = fontSize;
						E.db.auras.font = font;
						E.db.auras.fontSize = fontSize;
						E.db.general.reminder.font = font;
						--E.db.general.reminder.fontSize = fontSize;
						E.db.chat.font = font;
						E.db.chat.fontSize = fontSize;
						E.db.chat.tabFont = font;
						E.db.chat.tapFontSize = fontSize;
						E.db.datatexts.font = font;
						E.db.datatexts.fontSize = fontSize;
						E.db.tooltip.font = font;
						E.db.tooltip.fontSize = fontSize;
						E.db.tooltip.headerFontSize = fontSize;
						E.db.tooltip.textFontSize = fontSize;
						E.db.tooltip.smallTextFontSize = fontSize;
						E.db.tooltip.healthBar.font = font;
						--E.db.tooltip.healthbar.fontSize = fontSize;
						E.db.unitframe.font = font;
						--E.db.unitframe.fontSize = fontSize;
						--E.db.unitframe.units.party.rdebuffs.font = font;
						E.db.unitframe.units.raid.rdebuffs.font = font;
						E.db.unitframe.units.raid40.rdebuffs.font = font;
						
						E:UpdateAll(true);
					end
				},
				dmgfont = {
					type = "select", dialogControl = 'LSM30_Font',
					order = 4,
					name = L["CombatText Font"],
					desc = L["The font that combat text will use. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"],
					values = AceGUIWidgetLSMlists.font,
					get = function(info) return E.private.general[ info[#info] ] end,							
					set = function(info, value) E.private.general[ info[#info] ] = value; E:UpdateMedia(); E:UpdateFontTemplates(); E:StaticPopup_Show("PRIVATE_RL"); end,
				},
				namefont = {
					type = "select", dialogControl = 'LSM30_Font',
					order = 5,
					name = L["Name Font"],
					desc = L["The font that appears on the text above players heads. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"],
					values = AceGUIWidgetLSMlists.font,
					get = function(info) return E.private.general[ info[#info] ] end,							
					set = function(info, value) E.private.general[ info[#info] ] = value; E:UpdateMedia(); E:UpdateFontTemplates(); E:StaticPopup_Show("PRIVATE_RL"); end,
				},
				replaceBlizzFonts = {
					order = 6,
					type = "toggle",
					name = L["Replace Blizzard Fonts"],
					desc = L["Replaces the default Blizzard fonts on various panels and frames with the fonts chosen in the Media section of the ElvUI config. NOTE: Any font that inherits from the fonts ElvUI usually replaces will be affected as well if you disable this. Enabled by default."],
					get = function(info) return E.private.general[ info[#info] ]; end,
					set = function(info, value) E.private.general[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end
				},
			},
		},	
		textures = {
			order = 2,
			type = "group",
			name = L["Textures"],
			guiInline = true,
			args = {
				normTex = {
					type = "select", dialogControl = 'LSM30_Statusbar',
					order = 1,
					name = L["Primary Texture"],
					desc = L["The texture that will be used mainly for statusbars."],
					values = AceGUIWidgetLSMlists.statusbar,
					get = function(info) return E.private.general[ info[#info] ]; end,
					set = function(info, value)
						local previousValue = E.private.general[ info[#info] ];
						E.private.general[ info[#info] ] = value;
						
						if(E.db.unitframe.statusbar == previousValue) then
							E.db.unitframe.statusbar = value;
							E:UpdateAll(true);
						else
							E:UpdateMedia();
							E:UpdateStatusBars();
						end
					end
				},
				glossTex = {
					type = "select", dialogControl = 'LSM30_Statusbar',
					order = 2,
					name = L["Secondary Texture"],
					desc = L["This texture will get used on objects like chat windows and dropdown menus."],
					values = AceGUIWidgetLSMlists.statusbar,	
					get = function(info) return E.private.general[ info[#info] ]; end,
					set = function(info, value)
						E.private.general[ info[#info] ] = value;
						E:UpdateMedia();
						E:UpdateFrameTemplates();
					end
				},
				applyFontToAll = {
					order = 3,
					type = "execute",
					name = L["Apply Texture To All"],
					desc = L["Applies the primary texture to all statusbars."],
					func = function()
						local texture = E.private.general.normTex;
						E.db.unitframe.statusbar = texture;
						E:UpdateAll(true);
					end,
				},
			},
		},
		colors = {
			order = 3,
			type = "group",
			name = L["Colors"],
			guiInline = true,
			args = {
				bordercolor = {
					type = "color",
					order = 1,
					name = L["Border Color"],
					desc = L["Main border color of the UI. |cffFF0000This is disabled if you are using the pixel perfect theme.|r"],
					hasAlpha = false,
					get = function(info)
						local t = E.db.general[ info[#info] ]
						local d = P.general[info[#info]]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b
					end,
					set = function(info, r, g, b)
						E.db.general[ info[#info] ] = {}
						local t = E.db.general[ info[#info] ]
						t.r, t.g, t.b = r, g, b
						E:UpdateMedia()
						E:UpdateBorderColors()
					end,	
					disabled = function() return E.PixelMode end,
				},
				backdropcolor = {
					type = "color",
					order = 2,
					name = L["Backdrop Color"],
					desc = L["Main backdrop color of the UI."],
					hasAlpha = false,
					get = function(info)
						local t = E.db.general[ info[#info] ]
						local d = P.general[info[#info]]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b
					end,
					set = function(info, r, g, b)
						E.db.general[ info[#info] ] = {}
						local t = E.db.general[ info[#info] ]
						t.r, t.g, t.b = r, g, b
						E:UpdateMedia()
						E:UpdateBackdropColors()
					end,						
				},
				backdropfadecolor = {
					type = "color",
					order = 3,
					name = L["Backdrop Faded Color"],
					desc = L["Backdrop color of transparent frames"],
					hasAlpha = true,
					get = function(info)
						local t = E.db.general[ info[#info] ]
						local d = P.general[info[#info]]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
					end,
					set = function(info, r, g, b, a)
						E.db.general[ info[#info] ] = {}
						local t = E.db.general[ info[#info] ]	
						t.r, t.g, t.b, t.a = r, g, b, a
						E:UpdateMedia()
						E:UpdateBackdropColors()
					end,						
				},
				valuecolor = {
					type = "color",
					order = 4,
					name = L["Value Color"],
					desc = L["Color some texts use."],
					hasAlpha = false,
					get = function(info)
						local t = E.db.general[ info[#info] ]
						local d = P.general[info[#info]]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b
					end,
					set = function(info, r, g, b, a)
						E.db.general[ info[#info] ] = {}
						local t = E.db.general[ info[#info] ]	
						t.r, t.g, t.b, t.a = r, g, b, a
						E:UpdateMedia()
					end,						
				},
			},
		},
	},
}

local DONATOR_STRING = ""
local DEVELOPER_STRING = ""
local TESTER_STRING = ""
local LINE_BREAK = "\n"
local DONATORS = {
	"Dandruff",
	"Tobur/Tarilya",
	"Netu",
	"Alluren",
	"Thorgnir",
	"Emalal",
	"Bendmeova",
	"Curl",
	"Zarac",
	"Emmo",
	"Oz",
	"Hawké",
	"Aynya",
	"Tahira",
	"Karsten Lumbye Thomsen",
	"Thomas B. aka Pitschiqüü",
	"Sea Garnet",
	"Paul Storry",
	"Azagar",
	"Archury",
	"Donhorn",
	"Woodson Harmon",
	"Phoenyx",
	"Feat",
	"Konungr",
	"Leyrin",
	"Dragonsys",
	"Tkalec",
	"Paavi",
	"Giorgio",
	"Bearscantank",
	"Eidolic",
	"Cosmo",
	"Adorno",
	"Domoaligato",
	"Smorg",
	"Pyrokee"
}

local DEVELOPERS = {
	"Tukz",
	"Haste",
	"Nightcracker",
	"Omega1970",
	"Hydrazine"
}

local TESTERS = {
	"Tukui Community",
	"|cffF76ADBSarah|r - For Sarahing",
	"Affinity",
	"Modarch",
	"Bladesdruid",
	"Tirain",
	"Phima",
	"Veiled",
	"Blazeflack",
	"Repooc",
	"Darth Predator",
	'Alex',
	'Nidra',
	'Kurhyus',
	'BuG',
	'Yachanay',
	'Catok'
}

tsort(DONATORS, function(a,b) return a < b end) --Alphabetize
for _, donatorName in pairs(DONATORS) do
	tinsert(E.CreditsList, donatorName)
	DONATOR_STRING = DONATOR_STRING..LINE_BREAK..donatorName
end

tsort(DEVELOPERS, function(a,b) return a < b end) --Alphabetize
for _, devName in pairs(DEVELOPERS) do
	tinsert(E.CreditsList, devName)
	DEVELOPER_STRING = DEVELOPER_STRING..LINE_BREAK..devName
end

tsort(TESTERS, function(a,b) return a < b end) --Alphabetize
for _, testerName in pairs(TESTERS) do
	tinsert(E.CreditsList, testerName)
	TESTER_STRING = TESTER_STRING..LINE_BREAK..testerName
end

E.Options.args.credits = {
	type = "group",
	name = L["Credits"],
	order = -1,
	args = {
		text = {
			order = 1,
			type = "description",
			name = L['ELVUI_CREDITS']..'\n\n'..L['Coding:']..DEVELOPER_STRING..'\n\n'..L['Testing:']..TESTER_STRING..'\n\n'..L['Donations:']..DONATOR_STRING,
		},
	},
}

local profileTypeItems = {
	["profile"] = L["Profile"],
	["private"] = L["Private (Character Settings)"],
	["global"] = L["Global (Account Settings)"],
	["filtersNP"] = L["Filters (NamePlates)"],
	["filtersUF"] = L["Filters (UnitFrames)"],
	["filtersAll"] = L["Filters (All)"]
};

local profileTypeListOrder = {
	"profile",
	"private",
	"global",
	"filtersNP",
	"filtersUF",
	"filtersAll"
};

local exportTypeItems = {
	["text"] = L["Text"],
	["luaTable"] = L["Table"],
	["luaPlugin"] = L["Plugin"]
};

local exportTypeListOrder = {
	"text",
	"luaTable",
	"luaPlugin"
};

local exportString = "";
local function ExportImport_Open(mode)
	local frame = AceGUI:Create("Frame");
	frame:SetTitle("");
	frame:EnableResize(false);
	frame:SetWidth(800);
	frame:SetHeight(600);
	frame.frame:SetFrameStrata("FULLSCREEN_DIALOG");
	frame:SetLayout("flow");
	
	local box = AceGUI:Create("MultiLineEditBox");
	box:SetNumLines(30);
	box:DisableButton(true);
	box:SetWidth(800);
	box:SetLabel("");
	frame:AddChild(box);
	box.editBox.OnTextChangedOrig = box.editBox:GetScript("OnTextChanged");
	
	local label1 = AceGUI:Create("Label");
	local font = GameFontHighlightSmall:GetFont();
	label1:SetFont(font, 14);
	label1:SetText(" ");
	label1:SetWidth(800);
	frame:AddChild(label1);
	
	local label2 = AceGUI:Create("Label");
	local font = GameFontHighlightSmall:GetFont();
	label2:SetFont(font, 14);
	label2:SetText(" ")
	label2:SetWidth(800);
	frame:AddChild(label2);

	if(mode == "export") then
		frame:SetTitle(L["Export Profile"]);
		
		local profileTypeDropdown = AceGUI:Create("Dropdown");
		profileTypeDropdown:SetMultiselect(false);
		profileTypeDropdown:SetLabel(L["Choose What To Export"]);
		profileTypeDropdown:SetList(profileTypeItems, profileTypeListOrder);
		profileTypeDropdown:SetValue("profile");
		frame:AddChild(profileTypeDropdown);
		
		local exportFormatDropdown = AceGUI:Create("Dropdown");
		exportFormatDropdown:SetMultiselect(false);
		exportFormatDropdown:SetLabel(L["Choose Export Format"]);
		exportFormatDropdown:SetList(exportTypeItems, exportTypeListOrder);
		exportFormatDropdown:SetValue("text");
		exportFormatDropdown:SetWidth(150);
		frame:AddChild(exportFormatDropdown);
		
		local exportButton = AceGUI:Create("Button");
		exportButton:SetText(L["Export Now"]);
		exportButton:SetAutoWidth(true);
		local function OnClick(self)
			label1:SetText("");
			label2:SetText("");
			
			local profileType, exportFormat = profileTypeDropdown:GetValue(), exportFormatDropdown:GetValue();
			local profileKey, profileExport = D:ExportProfile(profileType, exportFormat);
			if(not profileKey or not profileExport) then
				label1:SetText(L["Error exporting profile!"]);
			else
				label1:SetText(format("%s: %s%s|r", L["Exported"], E.media.hexvaluecolor, profileTypeItems[profileType]));
				if(profileType == "profile") then
					label2:SetText(format("%s: %s%s|r", L["Profile Name"], E.media.hexvaluecolor, profileKey));
				end
			end
			box:SetText(profileExport);
			box.editBox:HighlightText();
			box:SetFocus();
			exportString = profileExport;
		end
		exportButton:SetCallback("OnClick", OnClick);
		frame:AddChild(exportButton);
		
		box.editBox:SetScript("OnChar", function() box:SetText(exportString); box.editBox:HighlightText(); end);
		box.editBox:SetScript("OnTextChanged", function(self, userInput)
			if(userInput) then
				box:SetText(exportString);
				box.editBox:HighlightText();
			end
		end);
	elseif(mode == "import") then
		frame:SetTitle(L["Import Profile"]);
		local importButton = AceGUI:Create("Button-ElvUI");
		importButton:SetDisabled(true);
		importButton:SetText(L["Import Now"]);
		importButton:SetAutoWidth(true);
		importButton:SetCallback("OnClick", function()
			label1:SetText("");
			label2:SetText("");
			
			local text;
			local success = D:ImportProfile(box:GetText());
			if(success) then
				text = L["Profile imported successfully!"];
			else
				text = L["Error decoding data. Import string may be corrupted!"];
			end
			label1:SetText(text);
		end)
		frame:AddChild(importButton);
		
		local decodeButton = AceGUI:Create("Button-ElvUI");
		decodeButton:SetDisabled(true);
		decodeButton:SetText(L["Decode Text"]);
		decodeButton:SetAutoWidth(true);
		decodeButton:SetCallback("OnClick", function()
			label1:SetText("");
			label2:SetText("");
			local decodedText;
			local profileType, profileKey, profileData = D:Decode(box:GetText());
			if(profileData) then
				decodedText = E:TableToLuaString(profileData);
			end
			local importText = D:CreateProfileExport(decodedText, profileType, profileKey);
			box:SetText(importText)
		end)
		frame:AddChild(decodeButton);

		local function OnTextChanged()
			local text = box:GetText();
			if(text == "") then
				label1:SetText("");
				label2:SetText("");
				importButton:SetDisabled(true);
				decodeButton:SetDisabled(true)
			else
				local stringType = D:GetImportStringType(text);
				if(stringType == "Base64") then
					decodeButton:SetDisabled(false);
				else
					decodeButton:SetDisabled(true);
				end
				
				local profileType, profileKey = D:Decode(text);
				if not profileType or (profileType and profileType == "profile" and not profileKey) then
					label1:SetText(L["Error decoding data. Import string may be corrupted!"]);
					label2:SetText("");
					importButton:SetDisabled(true);
					decodeButton:SetDisabled(true);
				else
					label1:SetText(format("%s: %s%s|r", L["Importing"], E.media.hexvaluecolor, profileTypeItems[profileType] or ""));
					if(profileType == "profile") then
						label2:SetText(format("%s: %s%s|r", L["Profile Name"], E.media.hexvaluecolor, profileKey));
					end
					importButton:SetDisabled(false);
				end
				
				box.scrollFrame:SetVerticalScroll(box.scrollFrame:GetVerticalScrollRange());
			end
		end
		
		box.editBox:SetFocus();
		box.editBox:SetScript("OnChar", nil);
		box.editBox:SetScript("OnTextChanged", OnTextChanged);
	end
	
	frame:SetCallback("OnClose", function(widget)
		box.editBox:SetScript("OnChar", nil);
		box.editBox:SetScript("OnTextChanged", box.editBox.OnTextChangedOrig);
		box.editBox.OnTextChangedOrig = nil;
		
		exportString = "";
		
		AceGUI:Release(widget);
		ACD:Open("ElvUI");
	end);
	
	--label1:SetText("");
	--label2:SetText("");
	
	ACD:Close("ElvUI");

	GameTooltip_Hide();
end

--Create Profiles Table
E.Options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(E.data);
AC:RegisterOptionsTable("ElvProfiles", E.Options.args.profiles)
E.Options.args.profiles.order = -10

LibStub('LibDualSpec-1.0'):EnhanceOptions(E.Options.args.profiles, E.data)

if not E.Options.args.profiles.plugins then
	E.Options.args.profiles.plugins = {}
end

E.Options.args.profiles.plugins["ElvUI"] = {
	desc = {
		name = L["This feature will allow you to transfer, settings to other characters."],
		type = 'description',
		order = 40.4,
	},
	distributeProfile = {
		name = L["Share Current Profile"],
		desc = L["Sends your current profile to your target."],
		type = 'execute',
		order = 40.5,
		func = function()
			if not UnitExists("target") or not UnitIsPlayer("target") or not UnitIsFriend("player", "target") or UnitIsUnit("player", "target") then
				E:Print(L["You must be targeting a player."])
				return
			end
			local name, server = UnitName("target")
			if name and (not server or server == "") then
				D:Distribute(name)
			elseif server then
				D:Distribute(name, true)
			end
		end,
	},
	distributeGlobal = {
		name = L["Share Filters"],
		desc = L["Sends your filter settings to your target."],
		type = 'execute',
		order = 40.6,
		func = function()
			if not UnitExists("target") or not UnitIsPlayer("target") or not UnitIsFriend("player", "target") or UnitIsUnit("player", "target") then
				E:Print(L["You must be targeting a player."])
				return
			end
			
			local name, server = UnitName("target")
			if name and (not server or server == "") then
				D:Distribute(name, false, true)
			elseif server then
				D:Distribute(name, true, true)
			end
		end,
	},
	spacer = {
		order = 40.7,
		type = "description",
		name = ""
	},
	exportProfile = {
		name = L["Export Profile"],
		type = "execute",
		order = 40.8,
		func = function() ExportImport_Open("export"); end
	},
	importProfile = {
		name = L["Import Profile"],
		type = "execute",
		order = 40.9,
		func = function() ExportImport_Open("import"); end
	}
};
