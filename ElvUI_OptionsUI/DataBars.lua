local E, _, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
local mod = E:GetModule("DataBars")

E.Options.args.databars = {
	type = "group",
	name = L["DataBars"],
	childGroups = "tab",
	get = function(info) return E.db.databars[info[#info]] end,
	set = function(info, value) E.db.databars[info[#info]] = value end,
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["DATABAR_DESC"]
		},
		spacer = {
			order = 2,
			type = "description",
			name = ""
		},
		experience = {
			order = 3,
			type = "group",
			name = L["XPBAR_LABEL"],
			get = function(info) return mod.db.experience[info[#info]] end,
			set = function(info, value) mod.db.experience[info[#info]] = value mod:ExperienceBar_UpdateDimensions() end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["XPBAR_LABEL"]
				},
				enable = {
					order = 2,
					type = "toggle",
					name = L["Enable"],
					set = function(info, value) mod.db.experience[info[#info]] = value mod:ExperienceBar_Toggle() end
				},
				mouseover = {
					order = 3,
					type = "toggle",
					name = L["Mouseover"]
				},
				hideAtMaxLevel = {
					order = 4,
					type = "toggle",
					name = L["Hide At Max Level"],
					set = function(info, value) mod.db.experience[info[#info]] = value mod:ExperienceBar_Update() end
				},
				hideInVehicle = {
					order = 5,
					type = "toggle",
					name = L["Hide In Vehicle"],
					set = function(info, value) mod.db.experience[info[#info]] = value mod:ExperienceBar_Update() end
				},
				hideInCombat = {
					order = 6,
					type = "toggle",
					name = L["Hide In Combat"],
					set = function(info, value) mod.db.experience[info[#info]] = value mod:ExperienceBar_Update() end
				},
				spacer = {
					order = 7,
					type = "description",
					name = " "
				},
				orientation = {
					order = 8,
					type = "select",
					name = L["Statusbar Fill Orientation"],
					desc = L["Direction the bar moves on gains/losses"],
					values = {
						["HORIZONTAL"] = L["Horizontal"],
						["VERTICAL"] = L["Vertical"]
					}
				},
				width = {
					order = 9,
					type = "range",
					name = L["Width"],
					min = 5, max = ceil(GetScreenWidth() or 800), step = 1
				},
				height = {
					order = 10,
					type = "range",
					name = L["Height"],
					min = 5, max = ceil(GetScreenHeight() or 800), step = 1
				},
				font = {
					order = 11,
					type = "select", dialogControl = "LSM30_Font",
					name = L["Font"],
					values = AceGUIWidgetLSMlists.font
				},
				textSize = {
					order = 12,
					type = "range",
					name = L["FONT_SIZE"],
					min = 6, max = 22, step = 1
				},
				fontOutline = {
					order = 13,
					type = "select",
					name = L["Font Outline"],
					values = C.Values.FontFlags
				},
				textFormat = {
					order = 14,
					type = "select",
					name = L["Text Format"],
					width = "double",
					values = {
						NONE = L["NONE"],
						CUR = L["Current"],
						REM = L["Remaining"],
						PERCENT = L["Percent"],
						CURMAX = L["Current - Max"],
						CURPERC = L["Current - Percent"],
						CURREM = L["Current - Remaining"],
						CURPERCREM = L["Current - Percent (Remaining)"],
					},
					set = function(info, value) mod.db.experience[info[#info]] = value mod:ExperienceBar_Update() end
				},
				questXP = {
					order = 15,
					type = "group",
					name = L["Quest XP"],
					guiInline = true,
					args = {
						color = {
							order = 1,
							type = "color",
							name = L["Quest XP Color"],
							get = function(info)
								local t = mod.db.experience.questXP.color
								return t.r, t.g, t.b, t.a, 102/255, 136/255, 255/255, 1
							end,
							set = function(info, r, g, b, a)
								local t = mod.db.experience.questXP.color
								t.r, t.g, t.b, t.a = r, g, b, a
								mod:ExperienceBar_Update()
							end
						},
						showBubbles = {
							order = 2,
							type = "toggle",
							name = L["Show Bubbles"],
							get = function(info) return mod.db.experience.questXP.showBubbles end,
							set = function(info, value) mod.db.experience.questXP.showBubbles = value mod:ExperienceBar_Update() end
						},
						questCurrentZoneOnly = {
							order = 3,
							type = "toggle",
							name = L["Quests in Current Zone Only"],
							get = function(info) return mod.db.experience.questXP.questCurrentZoneOnly end,
							set = function(info, value) mod.db.experience.questXP.questCurrentZoneOnly = value mod:ExperienceBar_Update() end
						},
						questCompletedOnly = {
							order = 4,
							type = "toggle",
							name = L["Completed Quests Only"],
							get = function(info) return mod.db.experience.questXP.questCompletedOnly end,
							set = function(info, value) mod.db.experience.questXP.questCompletedOnly = value mod:ExperienceBar_Update() end
						},
						tooltip = {
							order = 5,
							type = "toggle",
							name = L["Add Quest XP to Tooltip"],
							get = function(info) return mod.db.experience.questXP.tooltip end,
							set = function(info, value) mod.db.experience.questXP.tooltip = value mod:ExperienceBar_Update(value) end
						}
					}
				}
			}
		},
		petExperience = {
			order = 4,
			type = "group",
			name = L["Pet Experience"],
			get = function(info) return mod.db.petExperience[info[#info]] end,
			set = function(info, value) mod.db.petExperience[info[#info]] = value mod:UpdatePetExperienceDimensions() end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Pet Experience"]
				},
				enable = {
					order = 2,
					type = "toggle",
					name = L["Enable"],
					set = function(info, value) mod.db.petExperience[info[#info]] = value mod:EnableDisable_PetExperienceBar() end
				},
				mouseover = {
					order = 3,
					type = "toggle",
					name = L["Mouseover"]
				},
				hideAtMaxLevel = {
					order = 4,
					type = "toggle",
					name = L["Hide At Max Level"],
					set = function(info, value) mod.db.petExperience[info[#info]] = value mod:UpdatePetExperience() end
				},
				hideInVehicle = {
					order = 5,
					type = "toggle",
					name = L["Hide In Vehicle"],
					set = function(info, value) mod.db.petExperience[info[#info]] = value mod:UpdatePetExperience() end
				},
				hideInCombat = {
					order = 6,
					type = "toggle",
					name = L["Hide In Combat"],
					set = function(info, value) mod.db.petExperience[info[#info]] = value mod:UpdatePetExperience() end
				},
				spacer = {
					order = 7,
					type = "description",
					name = " "
				},
				orientation = {
					order = 8,
					type = "select",
					name = L["Statusbar Fill Orientation"],
					desc = L["Direction the bar moves on gains/losses"],
					values = {
						["HORIZONTAL"] = L["Horizontal"],
						["VERTICAL"] = L["Vertical"]
					}
				},
				width = {
					order = 9,
					type = "range",
					name = L["Width"],
					min = 5, max = ceil(GetScreenWidth() or 800), step = 1
				},
				height = {
					order = 10,
					type = "range",
					name = L["Height"],
					min = 5, max = ceil(GetScreenHeight() or 800), step = 1
				},
				font = {
					order = 11,
					type = "select", dialogControl = "LSM30_Font",
					name = L["Font"],
					values = AceGUIWidgetLSMlists.font
				},
				textSize = {
					order = 12,
					type = "range",
					name = L["FONT_SIZE"],
					min = 6, max = 22, step = 1
				},
				fontOutline = {
					order = 13,
					type = "select",
					name = L["Font Outline"],
					values = C.Values.FontFlags
				},
				textFormat = {
					order = 14,
					type = "select",
					name = L["Text Format"],
					width = "double",
					values = {
						NONE = L["NONE"],
						CUR = L["Current"],
						REM = L["Remaining"],
						PERCENT = L["Percent"],
						CURMAX = L["Current - Max"],
						CURPERC = L["Current - Percent"],
						CURREM = L["Current - Remaining"],
						CURPERCREM = L["Current - Percent (Remaining)"],
					},
					set = function(info, value) mod.db.petExperience[info[#info]] = value mod:UpdatePetExperience() end
				}
			}
		},
		reputation = {
			order = 5,
			type = "group",
			name = L["REPUTATION"],
			get = function(info) return mod.db.reputation[info[#info]] end,
			set = function(info, value) mod.db.reputation[info[#info]] = value mod:UpdateReputationDimensions() end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["REPUTATION"]
				},
				enable = {
					order = 2,
					type = "toggle",
					name = L["Enable"],
					set = function(info, value) mod.db.reputation[info[#info]] = value mod:EnableDisable_ReputationBar() end
				},
				mouseover = {
					order = 3,
					type = "toggle",
					name = L["Mouseover"]
				},
				hideInVehicle = {
					order = 4,
					type = "toggle",
					name = L["Hide In Vehicle"],
					set = function(info, value) mod.db.reputation[info[#info]] = value mod:UpdateReputation() end
				},
				hideInCombat = {
					order = 5,
					type = "toggle",
					name = L["Hide In Combat"],
					set = function(info, value) mod.db.reputation[info[#info]] = value mod:UpdateReputation() end
				},
				spacer = {
					order = 6,
					type = "description",
					name = " "
				},
				orientation = {
					order = 7,
					type = "select",
					name = L["Statusbar Fill Orientation"],
					desc = L["Direction the bar moves on gains/losses"],
					values = {
						["HORIZONTAL"] = L["Horizontal"],
						["VERTICAL"] = L["Vertical"]
					}
				},
				width = {
					order = 8,
					type = "range",
					name = L["Width"],
					min = 5, max = ceil(GetScreenWidth() or 800), step = 1
				},
				height = {
					order = 9,
					type = "range",
					name = L["Height"],
					min = 5, max = ceil(GetScreenHeight() or 800), step = 1
				},
				font = {
					order = 10,
					type = "select", dialogControl = "LSM30_Font",
					name = L["Font"],
					values = AceGUIWidgetLSMlists.font
				},
				textSize = {
					order = 11,
					type = "range",
					name = L["FONT_SIZE"],
					min = 6, max = 22, step = 1
				},
				fontOutline = {
					order = 12,
					type = "select",
					name = L["Font Outline"],
					values = C.Values.FontFlags
				},
				textFormat = {
					order = 13,
					type = "select",
					name = L["Text Format"],
					width = "double",
					values = {
						NONE = L["NONE"],
						CUR = L["Current"],
						REM = L["Remaining"],
						PERCENT = L["Percent"],
						CURMAX = L["Current - Max"],
						CURPERC = L["Current - Percent"],
						CURREM = L["Current - Remaining"],
						CURPERCREM = L["Current - Percent (Remaining)"],
					},
					set = function(info, value) mod.db.reputation[info[#info]] = value mod:UpdateReputation() end
				}
			}
		}
	}
}