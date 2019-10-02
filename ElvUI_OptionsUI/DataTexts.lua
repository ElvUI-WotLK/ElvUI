local E, _, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
local DT = E:GetModule("DataTexts")
local Layout = E:GetModule("Layout")
local Chat = E:GetModule("Chat")
local Minimap = E:GetModule("Minimap")

local _G = _G
local pairs = pairs

local HideLeftChat = HideLeftChat
local HideRightChat = HideRightChat

local datatexts = {}

function DT:PanelLayoutOptions()
	for name, data in pairs(DT.RegisteredDataTexts) do
		datatexts[name] = data.localizedName or L[name]
	end
	datatexts[""] = L["NONE"]

	local order
	local table = E.Options.args.datatexts.args.panels.args
	for pointLoc, tab in pairs(P.datatexts.panels) do
		if not _G[pointLoc] then table[pointLoc] = nil return end
		if type(tab) == "table" then
			if pointLoc:find("Chat") then
				order = 15
			else
				order = 20
			end
			table[pointLoc] = {
				order = order,
				type = "group",
				name = L[pointLoc] or pointLoc,
				args = {}
			}
			for option in pairs(tab) do
				table[pointLoc].args[option] = {
					type = "select",
					name = L[option] or option:upper(),
					values = datatexts,
					get = function(info) return E.db.datatexts.panels[pointLoc][info[#info]] end,
					set = function(info, value) E.db.datatexts.panels[pointLoc][info[#info]] = value DT:LoadDataTexts() end
				}
			end
		elseif type(tab) == "string" then
			table.smallPanels.args[pointLoc] = {
				type = "select",
				name = L[pointLoc] or pointLoc,
				values = datatexts,
				get = function(info) return E.db.datatexts.panels[pointLoc] end,
				set = function(info, value) E.db.datatexts.panels[pointLoc] = value DT:LoadDataTexts() end
			}
		end
	end
end

E.Options.args.datatexts = {
	type = "group",
	name = L["DataTexts"],
	childGroups = "tab",
	get = function(info) return E.db.datatexts[info[#info]] end,
	set = function(info, value) E.db.datatexts[info[#info]] = value DT:LoadDataTexts() end,
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["DATATEXT_DESC"]
		},
		spacer = {
			order = 2,
			type = "description",
			name = ""
		},
		general = {
			order = 3,
			type = "group",
			name = L["General"],
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["General"]
				},
				generalGroup = {
					order = 2,
					type = "group",
					guiInline = true,
					name = L["General"],
					args = {
						battleground = {
							order = 1,
							type = "toggle",
							name = L["Battleground Texts"],
							desc = L["When inside a battleground display personal scoreboard information on the main datatext bars."]
						},
						panelTransparency = {
							order = 2,
							name = L["Panel Transparency"],
							type = "toggle",
							set = function(info, value)
								E.db.datatexts[info[#info]] = value
								Layout:SetDataPanelStyle()
							end
						},
						panelBackdrop = {
							order = 3,
							type = "toggle",
							name = L["Backdrop"],
							set = function(info, value)
								E.db.datatexts[info[#info]] = value
								Layout:SetDataPanelStyle()
							end
						},
						noCombatClick = {
							order = 4,
							type = "toggle",
							name = L["Block Combat Click"],
							desc = L["Blocks all click events while in combat."]
						},
						noCombatHover = {
							order = 5,
							type = "toggle",
							name = L["Block Combat Hover"],
							desc = L["Blocks datatext tooltip from showing in combat."]
						},
						goldFormat = {
							order = 6,
							type = "select",
							name = L["Gold Format"],
							desc = L["The display format of the money text that is shown in the gold datatext and its tooltip."],
							values = {
								["SMART"] = L["Smart"],
								["FULL"] = L["Full"],
								["SHORT"] = L["SHORT"],
								["SHORTINT"] = L["Short (Whole Numbers)"],
								["CONDENSED"] = L["Condensed"],
								["BLIZZARD"] = L["Blizzard Style"]
							}
						},
						goldCoins = {
							order = 7,
							type = "toggle",
							name = L["Show Coins"],
							desc = L["Use coin icons instead of colored text."]
						}
					}
				},
				fontGroup = {
					order = 3,
					type = "group",
					guiInline = true,
					name = L["Fonts"],
					args = {
						font = {
							order = 1,
							type = "select", dialogControl = "LSM30_Font",
							name = L["Font"],
							values = AceGUIWidgetLSMlists.font
						},
						fontSize = {
							order = 2,
							type = "range",
							name = L["FONT_SIZE"],
							min = 4, max = 22, step = 1
						},
						fontOutline = {
							order = 3,
							type = "select",
							name = L["Font Outline"],
							desc = L["Set the font outline."],
							values = C.Values.FontFlags
						},
						wordWrap = {
							order = 4,
							type = "toggle",
							name = L["Word Wrap"]
						}
					}
				}
			}
		},
		panels = {
			type = "group",
			name = L["Panels"],
			order = 4,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Panels"]
				},
				leftChatPanel = {
					order = 2,
					type = "toggle",
					name = L["Datatext Panel (Left)"],
					desc = L["Display data panels below the chat, used for datatexts."],
					set = function(info, value)
						E.db.datatexts[info[#info]] = value
						if E.db.LeftChatPanelFaded then
							E.db.LeftChatPanelFaded = true
							HideLeftChat()
						end
						Chat:UpdateAnchors()
						Layout:ToggleChatPanels()
					end
				},
				rightChatPanel = {
					order = 3,
					type = "toggle",
					name = L["Datatext Panel (Right)"],
					desc = L["Display data panels below the chat, used for datatexts."],
					set = function(info, value)
						E.db.datatexts[info[#info]] = value
						if E.db.RightChatPanelFaded then
							E.db.RightChatPanelFaded = true
							HideRightChat()
						end
						Chat:UpdateAnchors()
						Layout:ToggleChatPanels()
					end
				},
				minimapPanels = {
					order = 4,
					type = "toggle",
					name = L["Minimap Panels"],
					desc = L["Display minimap panels below the minimap, used for datatexts."],
					set = function(info, value)
						E.db.datatexts[info[#info]] = value
						Minimap:UpdateSettings()
					end
				},
				minimapTop = {
					order = 5,
					type = "toggle",
					name = L["TopMiniPanel"],
					set = function(info, value)
						E.db.datatexts[info[#info]] = value
						Minimap:UpdateSettings()
					end
				},
				minimapTopLeft = {
					order = 6,
					type = "toggle",
					name = L["TopLeftMiniPanel"],
					set = function(info, value)
						E.db.datatexts[info[#info]] = value
						Minimap:UpdateSettings()
					end
				},
				minimapTopRight = {
					order = 7,
					type = "toggle",
					name = L["TopRightMiniPanel"],
					set = function(info, value)
						E.db.datatexts[info[#info]] = value
						Minimap:UpdateSettings()
					end
				},
				minimapBottom = {
					order = 8,
					type = "toggle",
					name = L["BottomMiniPanel"],
					set = function(info, value)
						E.db.datatexts[info[#info]] = value
						Minimap:UpdateSettings()
					end
				},
				minimapBottomLeft = {
					order = 9,
					type = "toggle",
					name = L["BottomLeftMiniPanel"],
					set = function(info, value)
						E.db.datatexts[info[#info]] = value
						Minimap:UpdateSettings()
					end
				},
				minimapBottomRight = {
					order = 10,
					type = "toggle",
					name = L["BottomRightMiniPanel"],
					set = function(info, value)
						E.db.datatexts[info[#info]] = value
						Minimap:UpdateSettings()
					end
				},
				spacer = {
					order = 11,
					type = "description",
					name = "\n"
				},
				smallPanels = {
					order = 12,
					type = "group",
					name = L["Small Panels"],
					args = {}
				}
			}
		},
		time = {
			order = 5,
			type = "group",
			name = L["Time"],
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Time"],
				},
				timeFormat = {
					order = 2,
					type = "select",
					name = L["Time Format"],
					values = {
						[""] = L["NONE"],
						["%I:%M"] = "03:27",
						["%I:%M:%S"] = "03:27:32",
						["%I:%M %p"] = "03:27 PM",
						["%I:%M:%S %p"] = "03:27:32 PM",
						["%H:%M"] = "15:27",
						["%H:%M:%S"] = "15:27:32"
					}
				},
				dateFormat = {
					order = 3,
					type = "select",
					name = L["Date Format"],
					values = {
						[""] = L["NONE"],
						["%d/%m/%y "] = "DD/MM/YY",
						["%m/%d/%y "] = "MM/DD/YY",
						["%y/%m/%d "] = "YY/MM/DD",
						["%d.%m.%y "] = "DD.MM.YY",
						["%m.%d.%y "] = "MM.DD.YY",
						["%y.%m.%d "] = "YY.MM.DD"
					}
				},
				realmTime = {
					order = 4,
					type = "toggle",
					name = L["Realm Time"],
					desc = L["Displayed server time."]
				}
			}
		},
		friends = {
			order = 6,
			type = "group",
			name = L["FRIENDS"],
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["FRIENDS"]
				},
				description = {
					order = 2,
					type = "description",
					name = L["Hide specific sections in the datatext tooltip."]
				},
				hideGroup = {
					order = 3,
					type = "group",
					guiInline = true,
					name = L["HIDE"],
					args = {
						hideAFK = {
							order = 1,
							type = "toggle",
							name = L["AFK"],
							get = function(info) return E.db.datatexts.friends.hideAFK end,
							set = function(info, value) E.db.datatexts.friends.hideAFK = value DT:LoadDataTexts() end
						},
						hideDND = {
							order = 2,
							type = "toggle",
							name = L["DND"],
							get = function(info) return E.db.datatexts.friends.hideDND end,
							set = function(info, value) E.db.datatexts.friends.hideDND = value DT:LoadDataTexts() end
						}
					}
				}
			}
		}
	}
}

DT:PanelLayoutOptions()