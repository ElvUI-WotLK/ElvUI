local E, _, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
local Misc = E:GetModule("Misc")
local Layout = E:GetModule("Layout")
local Totems = E:GetModule("Totems")
local Blizzard = E:GetModule("Blizzard")
local Threat = E:GetModule("Threat")
local AFK = E:GetModule("AFK")

local _G = _G

local FCF_GetNumActiveChatFrames = FCF_GetNumActiveChatFrames

local function GetChatWindowInfo()
	local ChatTabInfo = {}
	for i = 1, FCF_GetNumActiveChatFrames() do
		if i ~= 2 then
			ChatTabInfo["ChatFrame"..i] = _G["ChatFrame"..i.."Tab"]:GetText()
		end
	end

	return ChatTabInfo
end

E.Options.args.general = {
	order = 1,
	type = "group",
	name = L["General"],
	childGroups = "tab",
	get = function(info) return E.db.general[info[#info]] end,
	set = function(info, value) E.db.general[info[#info]] = value end,
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["ELVUI_DESC"]
		},
		general = {
			order = 2,
			type = "group",
			name = L["General"],
			args = {
				generalHeader = {
					order = 1,
					type = "header",
					name = L["General"]
				},
				messageRedirect = {
					order = 2,
					type = "select",
					name = L["Chat Output"],
					desc = L["This selects the Chat Frame to use as the output of ElvUI messages."],
					values = GetChatWindowInfo()
				},
				AutoScale = {
					order = 3,
					type = "execute",
					name = L["Auto Scale"],
					func = function()
						E.global.general.UIScale = E:PixelBestSize()
						E:StaticPopup_Show("UISCALE_CHANGE")
					end
				},
				UIScale = {
					order = 4,
					type = "range",
					name = L["UI_SCALE"],
					min = 0.1, max = 1.25, step = 0.0000000000000001,
					softMin = 0.40, softMax = 1.15, bigStep = 0.01,
					get = function(info) return E.global.general.UIScale end,
					set = function(info, value)
						E.global.general.UIScale = value
						E:StaticPopup_Show("UISCALE_CHANGE")
					end
				},
				ignoreScalePopup = {
					order = 5,
					type = "toggle",
					name = L["Ignore UI Scale Popup"],
					desc = L["This will prevent the UI Scale Popup from being shown when changing the game window size."],
					get = function(info) return E.global.general.ignoreScalePopup end,
					set = function(info, value) E.global.general.ignoreScalePopup = value end
				},
				pixelPerfect = {
					order = 6,
					type = "toggle",
					name = L["Thin Border Theme"],
					desc = L["The Thin Border Theme option will change the overall apperance of your UI. Using Thin Border Theme is a slight performance increase over the traditional layout."],
					get = function(info) return E.private.general.pixelPerfect end,
					set = function(info, value) E.private.general.pixelPerfect = value E:StaticPopup_Show("PRIVATE_RL") end
				},
				eyefinity = {
					order = 7,
					type = "toggle",
					name = L["Multi-Monitor Support"],
					desc = L["Attempt to support eyefinity/nvidia surround."],
					get = function(info) return E.global.general.eyefinity end,
					set = function(info, value) E.global.general.eyefinity = value E:StaticPopup_Show("GLOBAL_RL") end
				},
				taintLog = {
					order = 8,
					type = "toggle",
					name = L["Log Taints"],
					desc = L["Send ADDON_ACTION_BLOCKED errors to the Lua Error frame. These errors are less important in most cases and will not effect your game performance. Also a lot of these errors cannot be fixed. Please only report these errors if you notice a Defect in gameplay."]
				},
				bottomPanel = {
					order = 9,
					type = "toggle",
					name = L["Bottom Panel"],
					desc = L["Display a panel across the bottom of the screen. This is for cosmetic only."],
					set = function(info, value) E.db.general.bottomPanel = value Layout:BottomPanelVisibility() end
				},
				topPanel = {
					order = 10,
					type = "toggle",
					name = L["Top Panel"],
					desc = L["Display a panel across the top of the screen. This is for cosmetic only."],
					set = function(info, value) E.db.general.topPanel = value Layout:TopPanelVisibility() end
				},
				afk = {
					order = 11,
					type = "toggle",
					name = L["AFK Mode"],
					desc = L["When you go AFK display the AFK screen."],
					set = function(info, value) E.db.general.afk = value AFK:Toggle() end
				},
				decimalLength = {
					order = 12,
					type = "range",
					name = L["Decimal Length"],
					desc = L["Controls the amount of decimals used in values displayed on elements like NamePlates and UnitFrames."],
					min = 0, max = 4, step = 1,
					set = function(info, value)
						E.db.general.decimalLength = value
						E:BuildPrefixValues()
						E:StaticPopup_Show("CONFIG_RL")
					end
				},
				numberPrefixStyle = {
					order = 13,
					type = "select",
					name = L["Unit Prefix Style"],
					desc = L["The unit prefixes you want to use when values are shortened in ElvUI. This is mostly used on UnitFrames."],
					set = function(info, value)
						E.db.general.numberPrefixStyle = value
						E:BuildPrefixValues()
						E:StaticPopup_Show("CONFIG_RL")
					end,
					values = {
						["CHINESE"] = "Chinese (W, Y)",
						["ENGLISH"] = "English (K, M, B)",
						["GERMAN"] = "German (Tsd, Mio, Mrd)",
						["KOREAN"] = "Korean (천, 만, 억)",
						["METRIC"] = "Metric (k, M, G)"
					}
				},
				smoothingAmount = {
					order = 14,
					type = "range",
					isPercent = true,
					name = L["Smoothing Amount"],
					desc = L["Controls the speed at which smoothed bars will be updated."],
					min = 0.1, max = 0.8, softMax = 0.75, softMin = 0.25, step = 0.01,
					set = function(info, value)
						E.db.general.smoothingAmount = value
						E:SetSmoothingAmount(value)
					end
				},
				locale = {
					order = 15,
					type = "select",
					name = L["LANGUAGE"],
					get = function(info) return E.global.general.locale end,
					set = function(info, value)
						E.global.general.locale = value
						E:StaticPopup_Show("CONFIG_RL")
					end,
					values = {
						["deDE"] = "Deutsch",
						["enUS"] = "English",
						["esMX"] = "Español",
						["frFR"] = "Français",
						["ptBR"] = "Português",
						["ruRU"] = "Русский",
						["zhCN"] = "简体中文",
						["zhTW"] = "正體中文",
						["koKR"] = "한국어"
					}
				}
			}
		},
		media = {
			order = 3,
			type = "group",
			name = L["Media"],
			get = function(info) return E.db.general[info[#info]] end,
			set = function(info, value) E.db.general[info[#info]] = value end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Media"]
				},
				fontGroup = {
					order = 2,
					type = "group",
					name = L["Font"],
					guiInline = true,
					args = {
						font = {
							order = 1,
							type = "select", dialogControl = "LSM30_Font",
							name = L["Default Font"],
							desc = L["The font that the core of the UI will use."],
							values = AceGUIWidgetLSMlists.font,
							set = function(info, value) E.db.general[info[#info]] = value E:UpdateMedia() E:UpdateFontTemplates() end
						},
						fontSize = {
							order = 2,
							type = "range",
							name = L["FONT_SIZE"],
							desc = L["Set the font size for everything in UI. Note: This doesn't effect somethings that have their own seperate options (UnitFrame Font, Datatext Font, ect..)"],
							min = 4, max = 32, step = 1,
							set = function(info, value) E.db.general[info[#info]] = value E:UpdateMedia() E:UpdateFontTemplates() end
						},
						fontStyle = {
							order = 3,
							type = "select",
							name = L["Font Outline"],
							values = C.Values.FontFlags,
							set = function(info, value) E.db.general[info[#info]] = value E:UpdateMedia() E:UpdateFontTemplates() end
						},
						applyFontToAll = {
							order = 4,
							type = "execute",
							name = L["Apply Font To All"],
							desc = L["Applies the font and font size settings throughout the entire user interface. Note: Some font size settings will be skipped due to them having a smaller font size by default."],
							func = function() E:StaticPopup_Show("APPLY_FONT_WARNING") end
						},
						dmgfont = {
							order = 5,
							type = "select", dialogControl = "LSM30_Font",
							name = L["CombatText Font"],
							desc = L["The font that combat text will use. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"],
							values = AceGUIWidgetLSMlists.font,
							get = function(info) return E.private.general[info[#info]] end,
							set = function(info, value) E.private.general[info[#info]] = value E:UpdateMedia() E:UpdateFontTemplates() E:StaticPopup_Show("PRIVATE_RL") end
						},
						namefont = {
							order = 6,
							type = "select", dialogControl = "LSM30_Font",
							name = L["Name Font"],
							desc = L["The font that appears on the text above players heads. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"],
							values = AceGUIWidgetLSMlists.font,
							get = function(info) return E.private.general[info[#info]] end,
							set = function(info, value) E.private.general[info[#info]] = value E:UpdateMedia() E:UpdateFontTemplates() E:StaticPopup_Show("PRIVATE_RL") end
						},
						replaceBlizzFonts = {
							order = 7,
							type = "toggle",
							name = L["Replace Blizzard Fonts"],
							desc = L["Replaces the default Blizzard fonts on various panels and frames with the fonts chosen in the Media section of the ElvUI Options. NOTE: Any font that inherits from the fonts ElvUI usually replaces will be affected as well if you disable this. Enabled by default."],
							get = function(info) return E.private.general[info[#info]] end,
							set = function(info, value) E.private.general[info[#info]] = value E:StaticPopup_Show("PRIVATE_RL") end
						}
					}
				},
				textureGroup = {
					order = 3,
					type = "group",
					name = L["Textures"],
					guiInline = true,
					get = function(info) return E.private.general[info[#info]] end,
					args = {
						normTex = {
							order = 1,
							type = "select", dialogControl = "LSM30_Statusbar",
							name = L["Primary Texture"],
							desc = L["The texture that will be used mainly for statusbars."],
							values = AceGUIWidgetLSMlists.statusbar,
							set = function(info, value)
								local previousValue = E.private.general[info[#info]]
								E.private.general[info[#info]] = value

								if E.db.unitframe.statusbar == previousValue then
									E.db.unitframe.statusbar = value
									E:UpdateAll(true)
								else
									E:UpdateMedia()
									E:UpdateStatusBars()
								end
							end
						},
						glossTex = {
							order = 2,
							type = "select", dialogControl = "LSM30_Statusbar",
							name = L["Secondary Texture"],
							desc = L["This texture will get used on objects like chat windows and dropdown menus."],
							values = AceGUIWidgetLSMlists.statusbar,
							set = function(info, value)
								E.private.general[info[#info]] = value
								E:UpdateMedia()
								E:UpdateFrameTemplates()
							end
						},
						applyTextureToAll = {
							order = 3,
							type = "execute",
							name = L["Apply Texture To All"],
							desc = L["Applies the primary texture to all statusbars."],
							func = function()
								local texture = E.private.general.normTex
								E.db.unitframe.statusbar = texture
								E.db.nameplates.statusbar = texture
								E:UpdateAll(true)
							end
						}
					}
				},
				colorsGroup = {
					order = 4,
					type = "group",
					name = L["COLORS"],
					guiInline = true,
					get = function(info)
						local t = E.db.general[info[#info]]
						local d = P.general[info[#info]]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
					end,
					set = function(info, r, g, b, a)
						local setting = info[#info]
						local t = E.db.general[setting]
						t.r, t.g, t.b, t.a = r, g, b, a
						E:UpdateMedia()
						if setting == "bordercolor" then
							E:UpdateBorderColors()
						elseif setting == "backdropcolor" or setting == "backdropfadecolor" then
							E:UpdateBackdropColors()
						end
					end,
					args = {
						bordercolor = {
							order = 1,
							type = "color",
							name = L["Border Color"],
							desc = L["Main border color of the UI."],
							hasAlpha = false,
						},
						backdropcolor = {
							order = 2,
							type = "color",
							name = L["Backdrop Color"],
							desc = L["Main backdrop color of the UI."],
							hasAlpha = false,
						},
						backdropfadecolor = {
							order = 3,
							type = "color",
							name = L["Backdrop Faded Color"],
							desc = L["Backdrop color of transparent frames"],
							hasAlpha = true,
						},
						valuecolor = {
							order = 4,
							type = "color",
							name = L["Value Color"],
							desc = L["Color some texts use."],
							hasAlpha = false,
						},
						cropIcon = {
							order = 5,
							type = "toggle",
							tristate = true,
							name = L["Crop Icons"],
							desc = L["This is for Customized Icons in your Interface/Icons folder."],
							get = function(info)
								local value = E.db.general[info[#info]]
								if value == 2 then return true
								elseif value == 1 then return nil
								else return false end
							end,
							set = function(info, value)
								E.db.general[info[#info]] = (value and 2) or (value == nil and 1) or 0
								E:StaticPopup_Show("PRIVATE_RL")
							end
						}
					}
				}
			}
		},
		totems = {
			order = 4,
			type = "group",
			name = L["Class Totems"],
			get = function(info) return E.db.general.totems[info[#info]] end,
			set = function(info, value) E.db.general.totems[info[#info]] = value Totems:PositionAndSize() end,
			hidden = function() return E.myclass ~= "SHAMAN" end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = TUTORIAL_TITLE47
				},
				enable = {
					order = 2,
					type = "toggle",
					name = L["Enable"],
					set = function(info, value) E.db.general.totems[info[#info]] = value Totems:ToggleEnable() end
				},
				size = {
					order = 3,
					type = "range",
					name = L["Button Size"],
					min = 24, max = 60, step = 1,
					disabled = function() return not E.db.general.totems.enable end
				},
				spacing = {
					order = 4,
					type = "range",
					name = L["Button Spacing"],
					min = 1, max = 10, step = 1,
					disabled = function() return not E.db.general.totems.enable end
				},
				sortDirection = {
					order = 5,
					type = "select",
					name = L["Sort Direction"],
					values = {
						["ASCENDING"] = L["Ascending"],
						["DESCENDING"] = L["Descending"]
					},
					disabled = function() return not E.db.general.totems.enable end
				},
				growthDirection = {
					order = 6,
					type = "select",
					name = L["Bar Direction"],
					values = {
						["VERTICAL"] = L["Vertical"],
						["HORIZONTAL"] = L["Horizontal"]
					},
					disabled = function() return not E.db.general.totems.enable end
				}
			}
		},
		chatBubblesGroup = {
			order = 5,
			type = "group",
			name = L["Chat Bubbles"],
			get = function(info) return E.private.general[info[#info]] end,
			set = function(info, value) E.private.general[info[#info]] = value E:StaticPopup_Show("PRIVATE_RL") end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Chat Bubbles"]
				},
				chatBubbles = {
					order = 2,
					type = "select",
					name = L["Chat Bubbles Style"],
					desc = L["Skin the blizzard chat bubbles."],
					values = {
						["backdrop"] = L["Skin Backdrop"],
						["nobackdrop"] = L["Remove Backdrop"],
						["backdrop_noborder"] = L["Skin Backdrop (No Borders)"],
						["disabled"] = L["DISABLE"]
					}
				},
				chatBubbleFont = {
					order = 3,
					type = "select",
					name = L["Font"],
					dialogControl = "LSM30_Font",
					values = AceGUIWidgetLSMlists.font,
					disabled = function() return E.private.general.chatBubbles == "disabled" end
				},
				chatBubbleFontSize = {
					order = 4,
					type = "range",
					name = L["FONT_SIZE"],
					min = 4, max = 32, step = 1,
					disabled = function() return E.private.general.chatBubbles == "disabled" end
				},
				chatBubbleFontOutline = {
					order = 5,
					type = "select",
					name = L["Font Outline"],
					disabled = function() return E.private.general.chatBubbles == "disabled" end,
					values = C.Values.FontFlags
				},
				chatBubbleName = {
					order = 6,
					type = "toggle",
					name = L["Chat Bubble Names"],
					desc = L["Display the name of the unit on the chat bubble."],
					disabled = function() return E.private.general.chatBubbles == "disabled" or E.private.general.chatBubbles == "nobackdrop" end
				}
			}
		},
		objectiveFrameGroup = {
			order = 6,
			type = "group",
			name = L["Objective Frame"],
			get = function(info) return E.db.general[info[#info]] end,
			args = {
				objectiveFrameHeader = {
					order = 1,
					type = "header",
					name = L["Objective Frame"],
				},
				watchFrameAutoHide = {
					order = 2,
					type = "toggle",
					name = L["Auto Hide"],
					desc = L["Automatically hide the objetive frame during boss or arena fights."],
					set = function(info, value) E.db.general.watchFrameAutoHide = value; Blizzard:SetObjectiveFrameAutoHide() end,
				},
				watchFrameHeight = {
					order = 3,
					type = "range",
					name = L["Objective Frame Height"],
					desc = L["Height of the objective tracker. Increase size to be able to see more objectives."],
					min = 400, max = E.screenheight, step = 1,
					set = function(info, value) E.db.general.watchFrameHeight = value; Blizzard:SetWatchFrameHeight() end,
				},
			},
		},
		threatGroup = {
			order = 7,
			type = "group",
			name = L["Threat"],
			get = function(info) return E.db.general.threat[info[#info]] end,
			args = {
				threatHeader = {
					order = 1,
					type = "header",
					name = L["Threat"]
				},
				enable = {
					order = 2,
					type = "toggle",
					name = L["Enable"],
					set = function(info, value) E.db.general.threat.enable = value Threat:ToggleEnable()end
				},
				position = {
					order = 3,
					type = "select",
					name = L["Position"],
					desc = L["Adjust the position of the threat bar to either the left or right datatext panels."],
					values = {
						["LEFTCHAT"] = L["Left Chat"],
						["RIGHTCHAT"] = L["Right Chat"]
					},
					set = function(info, value) E.db.general.threat.position = value Threat:UpdatePosition() end,
					disabled = function() return not E.db.general.threat.enable end
				},
				spacer = {
					order = 4,
					type = "description",
					name = ""
				},
				textSize = {
					order = 5,
					type = "range",
					name = L["FONT_SIZE"],
					min = 6, max = 22, step = 1,
					set = function(info, value) E.db.general.threat.textSize = value Threat:UpdatePosition() end,
					disabled = function() return not E.db.general.threat.enable end
				},
				textOutline = {
					order = 6,
					type = "select",
					name = L["Font Outline"],
					values = C.Values.FontFlags,
					set = function(info, value) E.db.general.threat.textOutline = value Threat:UpdatePosition() end,
					disabled = function() return not E.db.general.threat.enable end
				}
			}
		},
		blizzUIImprovements = {
			order = 8,
			type = "group",
			name = L["BlizzUI Improvements"],
			get = function(info) return E.db.general[info[#info]] end,
			set = function(info, value) E.db.general[info[#info]] = value end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["BlizzUI Improvements"]
				},
				loot = {
					order = 2,
					type = "toggle",
					name = L["LOOT"],
					desc = L["Enable/Disable the loot frame."],
					get = function(info) return E.private.general[info[#info]] end,
					set = function(info, value)
						E.private.general[info[#info]] = value
						E:StaticPopup_Show("PRIVATE_RL")
					end
				},
				lootRoll = {
					order = 3,
					type = "toggle",
					name = L["Loot Roll"],
					desc = L["Enable/Disable the loot roll frame."],
					get = function(info) return E.private.general[info[#info]] end,
					set = function(info, value)
						E.private.general[info[#info]] = value
						E:StaticPopup_Show("PRIVATE_RL")
					end
				},
				hideErrorFrame = {
					order = 4,
					type = "toggle",
					name = L["Hide Error Text"],
					desc = L["Hides the red error text at the top of the screen while in combat."],
					set = function(info, value)
						E.db.general[info[#info]] = value
						Misc:ToggleErrorHandling()
					end
				},
				enhancedPvpMessages = {
					order = 5,
					type = "toggle",
					name = L["Enhanced PVP Messages"],
					desc = L["Display battleground messages in the middle of the screen."],
				},
				raidUtility = {
					order = 7,
					type = "toggle",
					name = L["RAID_CONTROL"],
					desc = L["Enables the ElvUI Raid Control panel."],
					get = function(info) return E.private.general[info[#info]] end,
					set = function(info, value)
						E.private.general[info[#info]] = value
						E:StaticPopup_Show("PRIVATE_RL")
					end
				},
				vehicleSeatIndicatorSize = {
					order = 8,
					type = "range",
					name = L["Vehicle Seat Indicator Size"],
					min = 64, max = 128, step = 4,
					set = function(info, value)
						E.db.general[info[#info]] = value
						Blizzard:UpdateVehicleFrame()
					end
				}
			}
		},
		misc = {
			order = 9,
			type = "group",
			name = L["MISCELLANEOUS"],
			get = function(info) return E.db.general[info[#info]] end,
			set = function(info, value) E.db.general[info[#info]] = value end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["MISCELLANEOUS"]
				},
				interruptAnnounce = {
					order = 2,
					type = "select",
					name = L["Announce Interrupts"],
					desc = L["Announce when you interrupt a spell to the specified chat channel."],
					values = {
						["NONE"] = L["NONE"],
						["SAY"] = L["SAY"],
						["PARTY"] = L["Party Only"],
						["RAID"] = L["Party / Raid"],
						["RAID_ONLY"] = L["Raid Only"],
						["EMOTE"] = L["EMOTE"]
					},
					set = function(info, value)
						E.db.general[info[#info]] = value
						Misc:ToggleInterruptAnnounce()
					end
				},
				autoRepair = {
					order = 3,
					type = "select",
					name = L["Auto Repair"],
					desc = L["Automatically repair using the following method when visiting a merchant."],
					values = {
						["NONE"] = L["NONE"],
						["GUILD"] = L["GUILD"],
						["PLAYER"] = L["PLAYER"]
					}
				},
				autoAcceptInvite = {
					order = 4,
					type = "toggle",
					name = L["Accept Invites"],
					desc = L["Automatically accept invites from guild/friends."]
				},
				autoRoll = {
					order = 5,
					type = "toggle",
					name = L["Auto Greed/DE"],
					desc = L["Automatically select greed or disenchant (when available) on green quality items. This will only work if you are the max level."],
					disabled = function() return not E.private.general.lootRoll end
				}
			}
		}
	}
}