local E, _, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
local CH = E:GetModule("Chat")
local Bags = E:GetModule("Bags")
local Layout = E:GetModule("Layout")

local _G = _G
local gsub, strlower = string.gsub, string.lower

local GameTooltip = _G["GameTooltip"]

E.Options.args.chat = {
	type = "group",
	name = L["Chat"],
	childGroups = "tab",
	get = function(info) return E.db.chat[info[#info]] end,
	set = function(info, value) E.db.chat[info[#info]] = value end,
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["CHAT_DESC"]
		},
		enable = {
			order = 2,
			type = "toggle",
			name = L["Enable"],
			get = function(info) return E.private.chat.enable end,
			set = function(info, value) E.private.chat.enable = value E:StaticPopup_Show("PRIVATE_RL") end
		},
		general = {
			order = 3,
			type = "group",
			name = L["General"],
			disabled = function() return not E.private.chat.enable end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["General"]
				},
				url = {
					order = 2,
					type = "toggle",
					name = L["URL Links"],
					desc = L["Attempt to create URL links inside the chat."]
				},
				shortChannels = {
					order = 3,
					type = "toggle",
					name = L["Short Channels"],
					desc = L["Shorten the channel names in chat."]
				},
				hyperlinkHover = {
					order = 4,
					type = "toggle",
					name = L["Hyperlink Hover"],
					desc = L["Display the hyperlink tooltip while hovering over a hyperlink."],
					set = function(info, value)
						E.db.chat[info[#info]] = value
						if value == true then
							CH:EnableHyperlink()
						else
							CH:DisableHyperlink()
						end
					end
				},
				sticky = {
					order = 5,
					type = "toggle",
					name = L["Sticky Chat"],
					desc = L["When opening the Chat Editbox to type a message having this option set means it will retain the last channel you spoke in. If this option is turned off opening the Chat Editbox should always default to the SAY channel."],
					set = function(info, value)
						E.db.chat[info[#info]] = value
					end
				},
				fade = {
					order = 6,
					type = "toggle",
					name = L["Fade Chat"],
					desc = L["Fade the chat text when there is no activity."],
					set = function(info, value)
						E.db.chat[info[#info]] = value
						CH:UpdateFading()
					end
				},
				emotionIcons = {
					order = 7,
					type = "toggle",
					name = L["Emotion Icons"],
					desc = L["Display emotion icons in chat."],
					set = function(info, value)
						E.db.chat[info[#info]] = value
					end
				},
				fadeUndockedTabs = {
					order = 8,
					type = "toggle",
					name = L["Fade Undocked Tabs"],
					desc = L["Fades the text on chat tabs that are not docked at the left or right chat panel."],
					set = function(self, value)
						E.db.chat.fadeUndockedTabs = value
						CH:UpdateChatTabs()
					end
				},
				fadeTabsNoBackdrop = {
					order = 9,
					type = "toggle",
					name = L["Fade Tabs No Backdrop"],
					desc = L["Fades the text on chat tabs that are docked in a panel where the backdrop is disabled."],
					set = function(self, value)
						E.db.chat.fadeTabsNoBackdrop = value
						CH:UpdateChatTabs()
					end
				},
				chatHistory = {
					order = 10,
					type = "toggle",
					name = L["Chat History"],
					desc = L["Log the main chat frames history. So when you reloadui or log in and out you see the history from your last session."]
				},
				useAltKey = {
					order = 11,
					type = "toggle",
					name = L["Use Alt Key"],
					desc = L["Require holding the Alt key down to move cursor or cycle through messages in the editbox."],
					set = function(self, value)
						E.db.chat.useAltKey = value
						CH:UpdateSettings()
					end
				},
				spacer = {
					order = 12,
					type = "description",
					name = " "
				},
				throttleInterval = {
					order = 13,
					type = "range",
					name = L["Spam Interval"],
					desc = L["Prevent the same messages from displaying in chat more than once within this set amount of seconds, set to zero to disable."],
					min = 0, max = 120, step = 1,
					set = function(info, value)
						E.db.chat[info[#info]] = value
						if value == 0 then
							CH:DisableChatThrottle()
						end
					end
				},
				scrollDownInterval = {
					order = 14,
					type = "range",
					name = L["Scroll Interval"],
					desc = L["Number of time in seconds to scroll down to the bottom of the chat window if you are not scrolled down completely."],
					min = 0, max = 120, step = 5,
					set = function(info, value)
						E.db.chat[info[#info]] = value
					end
				},
				numAllowedCombatRepeat = {
					order = 15,
					type = "range",
					name = L["Allowed Combat Repeat"],
					desc = L["Number of repeat characters while in combat before the chat editbox is automatically closed."],
					min = 3, max = 10, step = 1
				},
				numScrollMessages = {
					order = 16,
					type = "range",
					name = L["Scroll Messages"],
					desc = L["Number of messages you scroll for each step."],
					min = 1, max = 10, step = 1,
				},
				spacer2 = {
					order = 17,
					type = "description",
					name = " ",
				},
				timeStampFormat = {
					order = 18,
					type = "select",
					name = L["TIMESTAMPS_LABEL"],
					desc = L["OPTION_TOOLTIP_TIMESTAMPS"],
					values = {
						["NONE"] = L["NONE"],
						["%I:%M"] = "03:27",
						["%I:%M:%S"] = "03:27:32",
						["%I:%M %p"] = "03:27 PM",
						["%I:%M:%S %p"] = "03:27:32 PM",
						["%H:%M"] = "15:27",
						["%H:%M:%S"] =	"15:27:32"
					}
				},
				useCustomTimeColor = {
					order = 19,
					type = "toggle",
					name = L["Custom Timestamp Color"],
					disabled = function() return not E.db.chat.timeStampFormat == "NONE" end
				},
				customTimeColor = {
					order = 20,
					type = "color",
					hasAlpha = false,
					name = L["Timestamp Color"],
					disabled = function() return (not E.db.chat.timeStampFormat == "NONE" or not E.db.chat.useCustomTimeColor) end,
					get = function(info)
						local t = E.db.chat.customTimeColor
						local d = P.chat.customTimeColor
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b
					end,
					set = function(info, r, g, b)
						local t = E.db.chat.customTimeColor
						t.r, t.g, t.b = r, g, b
					end
				}
			}
		},
		alerts = {
			order = 4,
			type = "group",
			name = L["Alerts"],
			disabled = function() return not E.private.chat.enable end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Alerts"]
				},
				whisperSound = {
					order = 2,
					type = "select", dialogControl = "LSM30_Sound",
					name = L["Whisper Alert"],
					values = AceGUIWidgetLSMlists.sound,
				},
				keywordSound = {
					order = 3,
					type = "select", dialogControl = "LSM30_Sound",
					name = L["Keyword Alert"],
					values = AceGUIWidgetLSMlists.sound,
				},
				noAlertInCombat = {
					order = 4,
					type = "toggle",
					name = L["No Alert In Combat"]
				},
				keywords = {
					order = 5,
					type = "input",
					name = L["Keywords"],
					desc = L["List of words to color in chat if found in a message. If you wish to add multiple words you must seperate the word with a comma. To search for your current name you can use %MYNAME%.\n\nExample:\n%MYNAME%, ElvUI, RBGs, Tank"],
					width = "full",
					set = function(info, value) E.db.chat[info[#info]] = value CH:UpdateChatKeywords() end
				}
			}
		},
		panels = {
			order = 5,
			type = "group",
			name = L["Panels"],
			disabled = function() return not E.private.chat.enable end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Panels"]
				},
				lockPositions = {
					order = 2,
					type = "toggle",
					name = L["Lock Positions"],
					desc = L["Attempt to lock the left and right chat frame positions. Disabling this option will allow you to move the main chat frame anywhere you wish."],
					set = function(info, value)
						E.db.chat[ info[#info] ] = value
						if value == true then
							CH:PositionChat(true)
						end
					end
				},
				panelTabBackdrop = {
					order = 3,
					type = "toggle",
					name = L["Tab Panel"],
					desc = L["Toggle the chat tab panel backdrop."],
					set = function(info, value) E.db.chat.panelTabBackdrop = value Layout:ToggleChatPanels() end
				},
				panelTabTransparency = {
					order = 4,
					type = "toggle",
					name = L["Tab Panel Transparency"],
					set = function(info, value) E.db.chat.panelTabTransparency = value Layout:SetChatTabStyle() end,
					disabled = function() return not E.db.chat.panelTabBackdrop end
				},
				editBoxPosition = {
					order = 5,
					type = "select",
					name = L["Chat EditBox Position"],
					desc = L["Position of the Chat EditBox, if datatexts are disabled this will be forced to be above chat."],
					values = {
						["BELOW_CHAT"] = L["Below Chat"],
						["ABOVE_CHAT"] = L["Above Chat"]
					},
					set = function(info, value) E.db.chat[info[#info]] = value CH:UpdateAnchors() end
				},
				panelBackdrop = {
					order = 6,
					type = "select",
					name = L["Panel Backdrop"],
					desc = L["Toggle showing of the left and right chat panels."],
					set = function(info, value) E.db.chat.panelBackdrop = value Layout:ToggleChatPanels() CH:PositionChat(true) CH:UpdateAnchors() end,
					values = {
						["HIDEBOTH"] = L["Hide Both"],
						["SHOWBOTH"] = L["Show Both"],
						["LEFT"] = L["Left Only"],
						["RIGHT"] = L["Right Only"]
					}
				},
				separateSizes = {
					order = 7,
					type = "toggle",
					name = L["Separate Panel Sizes"],
					desc = L["Enable the use of separate size options for the right chat panel."],
					set = function(info, value)
						E.db.chat.separateSizes = value
						CH:PositionChat(true)
						Bags:Layout()
					end
				},
				spacer1 = {
					order = 8,
					type = "description",
					name = ""
				},
				panelHeight = {
					order = 9,
					type = "range",
					name = L["Panel Height"],
					desc = L["PANEL_DESC"],
					set = function(info, value) E.db.chat.panelHeight = value CH:PositionChat(true) end,
					min = 50, max = 600, step = 1
				},
				panelWidth = {
					order = 10,
					type = "range",
					name = L["Panel Width"],
					desc = L["PANEL_DESC"],
					set = function(info, value)
						E.db.chat.panelWidth = value
						CH:PositionChat(true)
						if not E.db.chat.separateSizes then
							Bags:Layout()
						end
						Bags:Layout(true)
					end,
					min = 50, max = 1000, step = 1
				},
				panelColor = {
					order = 11,
					type = "color",
					name = L["Backdrop Color"],
					hasAlpha = true,
					get = function(info)
						local t = E.db.chat.panelColor
						local d = P.chat.panelColor
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
					end,
					set = function(info, r, g, b, a)
						local t = E.db.chat.panelColor
						t.r, t.g, t.b, t.a = r, g, b, a
						CH:Panels_ColorUpdate()
					end,
				},
				spacer2 = {
					order = 12,
					type = "description",
					name = ""
				},
				panelHeightRight = {
					order = 13,
					type = "range",
					name = L["Right Panel Height"],
					desc = L["Adjust the height of your right chat panel."],
					disabled = function() return not E.db.chat.separateSizes end,
					hidden = function() return not E.db.chat.separateSizes end,
					set = function(info, value) E.db.chat.panelHeightRight = value CH:PositionChat(true) end,
					min = 50, max = 600, step = 1
				},
				panelWidthRight = {
					order = 14,
					type = "range",
					name = L["Right Panel Width"],
					desc = L["Adjust the width of your right chat panel."],
					disabled = function() return not E.db.chat.separateSizes end,
					hidden = function() return not E.db.chat.separateSizes end,
					set = function(info, value)
						E.db.chat.panelWidthRight = value
						CH:PositionChat(true)
						Bags:Layout()
					end,
					min = 50, max = 1000, step = 1
				},
				panelBackdropNameLeft = {
					order = 15,
					type = "input",
					width = "full",
					name = L["Panel Texture (Left)"],
					desc = L["Specify a filename located inside the World of Warcraft directory. Textures folder that you wish to have set as a panel background.\n\nPlease Note:\n-The image size recommended is 256x128\n-You must do a complete game restart after adding a file to the folder.\n-The file type must be tga format.\n\nExample: Interface\\AddOns\\ElvUI\\media\\textures\\copy\n\nOr for most users it would be easier to simply put a tga file into your WoW folder, then type the name of the file here."],
					set = function(info, value)
						E.db.chat[info[#info]] = value
						E:UpdateMedia()
					end
				},
				panelBackdropNameRight = {
					order = 16,
					type = "input",
					width = "full",
					name = L["Panel Texture (Right)"],
					desc = L["Specify a filename located inside the World of Warcraft directory. Textures folder that you wish to have set as a panel background.\n\nPlease Note:\n-The image size recommended is 256x128\n-You must do a complete game restart after adding a file to the folder.\n-The file type must be tga format.\n\nExample: Interface\\AddOns\\ElvUI\\media\\textures\\copy\n\nOr for most users it would be easier to simply put a tga file into your WoW folder, then type the name of the file here."],
					set = function(info, value)
						E.db.chat[info[#info]] = value
						E:UpdateMedia()
					end
				}
			}
		},
		fontGroup = {
			order = 6,
			type = "group",
			name = L["Fonts"],
			set = function(info, value) E.db.chat[info[#info]] = value CH:SetupChat() end,
			disabled = function() return not E.private.chat.enable end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Fonts"]
				},
				font = {
					order = 2,
					type = "select", dialogControl = "LSM30_Font",
					name = L["Font"],
					values = AceGUIWidgetLSMlists.font
				},
				fontOutline = {
					order = 3,
					type = "select",
					name = L["Font Outline"],
					desc = L["Set the font outline."],
					values = C.Values.FontFlags
				},
				spacer = {
					order = 4,
					type = "description",
					name = ""
				},
				tabFont = {
					order = 5,
					type = "select", dialogControl = "LSM30_Font",
					name = L["Tab Font"],
					values = AceGUIWidgetLSMlists.font
				},
				tabFontSize = {
					order = 6,
					type = "range",
					name = L["Tab Font Size"],
					min = 6, max = 22, step = 1
				},
				tabFontOutline = {
					order = 7,
					type = "select",
					name = L["Tab Font Outline"],
					desc = L["Set the font outline."],
					values = C.Values.FontFlags
				}
			}
		},
		classColorMentionGroup = {
			order = 7,
			type = "group",
			name = L["Class Color Mentions"],
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Class Color Mentions"]
				},
				classColorMentionsChat = {
					order = 2,
					type = "toggle",
					name = L["Chat"],
					desc = L["Use class color for the names of players when they are mentioned."],
					get = function(info) return E.db.chat.classColorMentionsChat end,
					set = function(info, value) E.db.chat.classColorMentionsChat = value end,
					disabled = function() return not E.private.chat.enable end
				},
				classColorMentionsSpeech = {
					order = 3,
					type = "toggle",
					name = L["Chat Bubbles"],
					desc = L["Use class color for the names of players when they are mentioned."],
					get = function(info) return E.private.general.classColorMentionsSpeech end,
					set = function(info, value) E.private.general.classColorMentionsSpeech = value E:StaticPopup_Show("PRIVATE_RL") end,
					disabled = function() return (E.private.general.chatBubbles == "disabled" or not E.private.chat.enable) end
				},
				classColorMentionExcludeName = {
					order = 4,
					type = "input",
					name = L["Exclude Name"],
					desc = L["Excluded names will not be class colored."],
					get = function(info) return "" end,
					set = function(info, value)
						if value == "" or gsub(value, "%s+", "") == "" then return end
						E.global.chat.classColorMentionExcludedNames[strlower(value)] = value
					end
				},
				classColorMentionExcludedNames = {
					order = 5,
					type = "multiselect",
					name = L["Excluded Names"],
					values = function() return E.global.chat.classColorMentionExcludedNames end,
					get = function(info, value)	return E.global.chat.classColorMentionExcludedNames[value] end,
					set = function(info, value)
						E.global.chat.classColorMentionExcludedNames[value] = nil
						GameTooltip:Hide()
					end
				}
			}
		}
	}
}