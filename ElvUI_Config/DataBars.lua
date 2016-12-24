local E, L, V, P, G = unpack(ElvUI);
local mod = E:GetModule("DataBars")

local databars = {};

E.Options.args.databars = {
	type = "group",
	name = L["DataBars"],
	childGroups = "tab",
	get = function(info) return E.db.databars[ info[#info] ]; end,
	set = function(info, value) E.db.databars[ info[#info] ] = value; end,
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
			name = XPBAR_LABEL,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					get = function(info) return mod.db.experience[ info[#info] ]; end,
					set = function(info, value) mod.db.experience[ info[#info] ] = value; mod:EnableDisable_ExperienceBar(); end
				},
				generalGroup = {
					order = 2,
					type = "group",
					guiInline = true,
					name = L["General"],
					get = function(info) return mod.db.experience[ info[#info] ]; end,
					set = function(info, value) mod.db.experience[ info[#info] ] = value; mod:UpdateExperienceDimensions(); end,
					disabled = function() return not mod.db.experience.enable end,
					args = {
						mouseover = {
							order = 1,
							type = "toggle",
							name = L["Mouseover"]
						},
						hideAtMaxLevel = {
							order = 2,
							type = "toggle",
							name = L["Hide At Max Level"],
							set = function(info, value) mod.db.experience[ info[#info] ] = value; mod:UpdateExperience(); end
						},
						hideInVehicle = {
							order = 3,
							type = "toggle",
							name = L["Hide In Vehicle"],
							set = function(info, value) mod.db.experience[ info[#info] ] = value; mod:UpdateExperience(); end
						},
						hideInCombat = {
							order = 4,
							type = "toggle",
							name = L["Hide in Combat"],
							set = function(info, value) mod.db.experience[ info[#info] ] = value; mod:UpdateExperience() end,
						},
						spacer = {
							order = 5,
							type = "description",
							name = ""
						},
						orientation = {
							order = 6,
							type = "select",
							name = L["Statusbar Fill Orientation"],
							desc = L["Direction the bar moves on gains/losses"],
							values = {
								["HORIZONTAL"] = L["Horizontal"],
								["VERTICAL"] = L["Vertical"]
							}
						},
						width = {
							order = 7,
							type = "range",
							name = L["Width"],
							min = 5, max = ceil(GetScreenWidth() or 800), step = 1
						},
						height = {
							order = 8,
							type = "range",
							name = L["Height"],
							min = 5, max = ceil(GetScreenHeight() or 800), step = 1
						}
					}
				},
				fontGroup = {
					order = 3,
					type = "group",
					guiInline = true,
					name = L["Font"],
					get = function(info) return mod.db.experience[ info[#info] ]; end,
					set = function(info, value) mod.db.experience[ info[#info] ] = value; mod:UpdateExperienceDimensions(); end,
					disabled = function() return not mod.db.experience.enable; end,
					args = {
						textFont = {
							order = 1,
							type = "select", dialogControl = "LSM30_Font",
							name = L["Font"],
							values = AceGUIWidgetLSMlists.font
						},
						textSize = {
							order = 2,
							type = "range",
							name = L["Font Size"],
							min = 6, max = 22, step = 1
						},
						textOutline = {
							order = 3,
							type = "select",
							name = L["Font Outline"],
							desc = L["Set the font outline."],
							values = {
								["NONE"] = L["None"],
								["OUTLINE"] = "OUTLINE",
								["MONOCHROME"] = "MONOCHROME",
								["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
								["THICKOUTLINE"] = "THICKOUTLINE"
							}
						},
						textFormat = {
							order = 4,
							type = "select",
							name = L["Text Format"],
							values = {
								NONE = NONE,
								PERCENT = L["Percent"],
								CUR = L["Current"],
								REM = L["Remaining"],
								CURMAX = L["Current - Max"],
								CURPERC = L["Current - Percent"],
								CURREM = L["Current - Remaining"]
							},
							set = function(info, value) mod.db.experience[ info[#info] ] = value; mod:UpdateExperience(); end
						}
					}
				}
			}
		},
		reputation = {
			order = 4,
			type = "group",
			name = REPUTATION,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					get = function(info) return mod.db.reputation[ info[#info] ]; end,
					set = function(info, value) mod.db.reputation[ info[#info] ] = value; mod:EnableDisable_ReputationBar(); end,
				},
				generalGroup = {
					order = 2,
					type = "group",
					guiInline = true,
					name = L["General"],
					get = function(info) return mod.db.reputation[ info[#info] ]; end,
					set = function(info, value) mod.db.reputation[ info[#info] ] = value; mod:UpdateReputationDimensions(); end,
					disabled = function() return not mod.db.reputation.enable end,
					args = {
						mouseover = {
							order = 1,
							type = "toggle",
							name = L["Mouseover"]
						},
						hideInVehicle = {
							order = 2,
							type = "toggle",
							name = L["Hide In Vehicle"],
							set = function(info, value) mod.db.reputation[ info[#info] ] = value; mod:UpdateReputation() end
						},
						hideInCombat = {
							order = 3,
							type = "toggle",
							name = L["Hide in Combat"],
							set = function(info, value) mod.db.reputation[ info[#info] ] = value; mod:UpdateReputation() end,
						},
						spacer = {
							order = 4,
							type = "description",
							name = ""
						},
						orientation = {
							order = 5,
							type = "select",
							name = L["Statusbar Fill Orientation"],
							desc = L["Direction the bar moves on gains/losses"],
							values = {
								["HORIZONTAL"] = L["Horizontal"],
								["VERTICAL"] = L["Vertical"]
							}
						},
						width = {
							order = 6,
							type = "range",
							name = L["Width"],
							min = 5, max = ceil(GetScreenWidth() or 800), step = 1
						},
						height = {
							order = 7,
							type = "range",
							name = L["Height"],
							min = 5, max = ceil(GetScreenHeight() or 800), step = 1
						}
					}
				},
				fontGroup = {
					order = 3,
					type = "group",
					guiInline = true,
					name = L["Font"],
					get = function(info) return mod.db.reputation[ info[#info] ]; end,
					set = function(info, value) mod.db.reputation[ info[#info] ] = value; mod:UpdateReputationDimensions(); end,
					disabled = function() return not mod.db.reputation.enable; end,
					args = {
						textFont = {
							order = 1,
							type = "select", dialogControl = "LSM30_Font",
							name = L["Font"],
							values = AceGUIWidgetLSMlists.font
						},
						textSize = {
							order = 2,
							type = "range",
							name = L["Font Size"],
							min = 6, max = 22, step = 1
						},
						textOutline = {
							order = 3,
							type = "select",
							name = L["Font Outline"],
							desc = L["Set the font outline."],
							values = {
								["NONE"] = L["None"],
								["OUTLINE"] = "OUTLINE",
								["MONOCHROME"] = "MONOCHROME",
								["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
								["THICKOUTLINE"] = "THICKOUTLINE"
							}
						},
						textFormat = {
							order = 4,
							type = "select",
							name = L["Text Format"],
							values = {
								NONE = NONE,
								CUR = L["Current"],
								REM = L["Remaining"],
								PERCENT = L["Percent"],
								CURMAX = L["Current - Max"],
								CURPERC = L["Current - Percent"],
								CURREM = L["Current - Remaining"]
							},
							set = function(info, value) mod.db.reputation[ info[#info] ] = value; mod:UpdateReputation(); end
						}
					}
				}
			}
		}
	}
};