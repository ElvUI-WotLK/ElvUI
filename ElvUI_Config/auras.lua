local E, L, V, P, G, _ = unpack(ElvUI);
local A = E:GetModule("Auras");

local function GetAuraOptions(headerName)
	local auraOptions = {
		header = {
			order = 1,
			type = "header",
			name = headerName
		},
		size = {
			order = 2,
			type = "range",
			name = L["Size"],
			desc = L["Set the size of the individual auras."],
			min = 16, max = 60, step = 2
		},
		durationFontSize = {
			order = 3,
			type = "range",
			name = L["Duration Font Size"],
			min = 4, max = 32, step = 1,
		},
		countFontSize = {
			order = 4,
			type = "range",
			name = L["Count Font Size"],
			min = 4, max = 32, step = 1,
		},
		growthDirection = {
			order = 5,
			type = "select",
			name = L["Growth Direction"],
			desc = L["The direction the auras will grow and then the direction they will grow after they reach the wrap after limit."],
			values = {
				DOWN_RIGHT = format(L["%s and then %s"], L["Down"], L["Right"]),
				DOWN_LEFT = format(L["%s and then %s"], L["Down"], L["Left"]),
				UP_RIGHT = format(L["%s and then %s"], L["Up"], L["Right"]),
				UP_LEFT = format(L["%s and then %s"], L["Up"], L["Left"]),
				RIGHT_DOWN = format(L["%s and then %s"], L["Right"], L["Down"]),
				RIGHT_UP = format(L["%s and then %s"], L["Right"], L["Up"]),
				LEFT_DOWN = format(L["%s and then %s"], L["Left"], L["Down"]),
				LEFT_UP = format(L["%s and then %s"], L["Left"], L["Up"])
			}
		},
		wrapAfter = {
			order = 6,
			type = "range",
			name = L["Wrap After"],
			desc = L["Begin a new row or column after this many auras."],
			min = 1, max = 32, step = 1
		},
		maxWraps = {
			order = 7,
			type = "range",
			name = L["Max Wraps"],
			desc = L["Limit the number of rows or columns."],
			min = 1, max = 32, step = 1
		},
		horizontalSpacing = {
			order = 8,
			type = "range",
			name = L["Horizontal Spacing"],
			min = 0, max = 50, step = 1
		},
		verticalSpacing = {
			order = 9,
			type = "range",
			name = L["Vertical Spacing"],
			min = 0, max = 50, step = 1
		},
		sortMethod = {
			order = 10,
			type = "select",
			name = L["Sort Method"],
			desc = L["Defines how the group is sorted."],
			values = {
				["INDEX"] = L["Index"],
				["TIME"] = L["Time"],
				["NAME"] = L["Name"]
			}
		},
		sortDir = {
			order = 11,
			type = "select",
			name = L["Sort Direction"],
			desc = L["Defines the sort order of the selected sort method."],
			values = {
				["+"] = L["Ascending"],
				["-"] = L["Descending"]
			}
		},
		seperateOwn = {
			order = 12,
			type = "select",
			name = L["Seperate"],
			desc = L["Indicate whether buffs you cast yourself should be separated before or after."],
			values = {
				[-1] = L["Other's First"],
				[0] = L["No Sorting"],
				[1] = L["Your Auras First"]
			}
		}
	};
	return auraOptions;
end

E.Options.args.auras = {
	type = "group",
	name = BUFFOPTIONS_LABEL,
	childGroups = "tab",
	get = function(info) return E.db.auras[ info[#info] ]; end,
	set = function(info, value) E.db.auras[ info[#info] ] = value; A:UpdateHeader(ElvUIPlayerBuffs); A:UpdateHeader(ElvUIPlayerDebuffs); end,
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["AURAS_DESC"]
		},
		enable = {
			order = 2,
			type = "toggle",
			name = L["Enable"],
			get = function(info) return E.private.auras[ info[#info] ]; end,
			set = function(info, value)
				E.private.auras[ info[#info] ] = value;
				E:StaticPopup_Show("PRIVATE_RL");
			end,
		},
		disableBlizzard = {
			order = 3,
			type = "toggle",
			name = L["Disabled Blizzard"],
			get = function(info) return E.private.auras[ info[#info] ] end,
			set = function(info, value)
				E.private.auras[ info[#info] ] = value;
				E:StaticPopup_Show("PRIVATE_RL");
			end
		},
		general = {
			order = 4,
			type = "group",
			name = L["General"],
			args = {
				header = {
					order = 0,
					type = "header",
					name = L["General"]
				},
				fadeThreshold = {
					order = 1,
					type = "range",
					name = L["Fade Threshold"],
					desc = L["Threshold before the icon will fade out and back in. Set to -1 to disable."],
					min = -1, max = 30, step = 1
				},
				font = {
					order = 2,
					type = "select", dialogControl = "LSM30_Font",
					name = L["Font"],
					values = AceGUIWidgetLSMlists.font
				},
				fontOutline = {
					order = 4,
					name = L["Font Outline"],
					desc = L["Set the font outline."],
					type = "select",
					values = {
						["NONE"] = L["None"],
						["OUTLINE"] = "OUTLINE",

						["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
						["THICKOUTLINE"] = "THICKOUTLINE"
					}
				},
				timeXOffset = {
					order = 5,
					type = "range",
					name = L["Time xOffset"],
					min = -60, max = 60, step = 1
				},
				timeYOffset = {
					order = 6,
					type = "range",
					name = L["Time yOffset"],
					min = -60, max = 60, step = 1
				},
				countXOffset = {
					order = 7,
					type = "range",
					name = L["Count xOffset"],
					min = -60, max = 60, step = 1
				},
				countYOffset = {
					order = 8,
					name = L["Count yOffset"],
					type = "range",
					min = -60, max = 60, step = 1
				},
				lbf = {
					order = 9,
					type = "group",
					guiInline = true,
					name = L["LBF Support"],
					get = function(info) return E.private.auras.lbf[info[#info]]; end,
					set = function(info, value) E.private.auras.lbf[info[#info]] = value; E:StaticPopup_Show("PRIVATE_RL"); end,
					disabled = function() return not E.private.auras.enable; end,
					args = {
						enable = {
							order = 1,
							type = "toggle",
							name = L["Enable"],
							desc = L["Allow LBF to handle the skinning of this element."]
						}
					}
				}
			}
		},
		cooldownGroup = {
			order = 5,
			type = "group",
			name = L["Cooldown Override"],
			get = function(info)
				local t = E.db.auras.cooldown[ info[#info] ]
				local d = P.auras.cooldown[ info[#info] ]
				return t.r, t.g, t.b, t.a, d.r, d.g, d.b
			end,
			set = function(info, r, g, b)
				local t = E.db.auras.cooldown[ info[#info] ]
				t.r, t.g, t.b = r, g, b
				E:UpdateCooldownSettings("auras")
			end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Cooldown Override"]
				},
				override = {
					order = 2,
					type = "toggle",
					name = L["Use Override"],
					desc = L["This will override the global cooldown settings."],
					get = function(info) return E.db.auras.cooldown[ info[#info] ] end,
					set = function(info, value) E.db.auras.cooldown[ info[#info] ] = value end
				},
				threshold = {
					order = 3,
					type = "range",
					name = L["Low Threshold"],
					desc = L["Threshold before text turns red and is in decimal form. Set to -1 for it to never turn red"],
					min = -1, max = 20, step = 1,
					disabled = function() return not E.db.auras.cooldown.override end,
					get = function(info) return E.db.auras.cooldown[ info[#info] ] end,
					set = function(info, value)
						E.db.auras.cooldown[ info[#info] ] = value
						E:UpdateCooldownSettings("auras")
					end
				},
				expiringColor = {
					order = 4,
					type = "color",
					name = L["Expiring"],
					desc = L["Color when the text is about to expire"],
					disabled = function() return not E.db.auras.cooldown.override end
				},
				secondsColor = {
					order = 5,
					type = "color",
					name = L["Seconds"],
					desc = L["Color when the text is in the seconds format."],
					disabled = function() return not E.db.auras.cooldown.override end
				},
				minutesColor = {
					order = 6,
					type = "color",
					name = L["Minutes"],
					desc = L["Color when the text is in the minutes format."],
					disabled = function() return not E.db.auras.cooldown.override end
				},
				hoursColor = {
					order = 7,
					type = "color",
					name = L["Hours"],
					desc = L["Color when the text is in the hours format."],
					disabled = function() return not E.db.auras.cooldown.override end
				},
				daysColor = {
					order = 8,
					type = "color",
					name = L["Days"],
					desc = L["Color when the text is in the days format."],
					disabled = function() return not E.db.auras.cooldown.override end
				}
			}
		},
		buffs = {
			order = 6,
			type = "group",
			name = L["Buffs"],
			get = function(info) return E.db.auras.buffs[ info[#info] ]; end,
			set = function(info, value) E.db.auras.buffs[ info[#info] ] = value; A:UpdateHeader(ElvUIPlayerBuffs); end,
			args = GetAuraOptions(L["Buffs"])
		},
		debuffs = {
			order = 7,
			type = "group",
			name = L["Debuffs"],
			get = function(info) return E.db.auras.debuffs[ info[#info] ]; end,
			set = function(info, value) E.db.auras.debuffs[ info[#info] ] = value; A:UpdateHeader(ElvUIPlayerDebuffs); end,
			args = GetAuraOptions(L["Debuffs"])
		},
		reminder = {
			order = 8,
			type = "group",
			name = L["Reminder"],
			get = function(info) return E.db.general.reminder[ info[#info] ] end,
			set = function(info, value) E.db.general.reminder[ info[#info] ] = value; E:GetModule("ReminderBuffs"):UpdateSettings(); end,
			disabled = function() return not E.private.general.minimap.enable end,
			args = {
				header = {
					order = 0,
					type = "header",
					name = L["Reminder"]
				},
				enable = {
					order = 1,
					name = L["Enable"],
					desc = L["Display reminder bar on the minimap."],
					type = "toggle",
					set = function(info, value) E.db.general.reminder[ info[#info] ] = value; E:GetModule("Minimap"):UpdateSettings(); end
				},
				generalGroup = {
					order = 2,
					type = "group",
					guiInline = true,
					name = L["General"],
					disabled = function() return not E.db.general.reminder.enable end,
					args = {
						durations = {
							order = 1,
							name = L["Remaining Time"],
							type = "toggle"
						},
						reverse = {
							order = 2,
							name = L["Reverse Style"],
							desc = L["When enabled active buff icons will light up instead of becoming darker, while inactive buff icons will become darker instead of being lit up."],
							type = "toggle"
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
					type = "group",
					guiInline = true,
					name = L["Font"],
					disabled = function() return not E.db.general.reminder.enable or not E.db.general.reminder.durations end,
					args = {
						font = {
							type = "select", dialogControl = "LSM30_Font",
							order = 1,
							name = L["Font"],
							values = AceGUIWidgetLSMlists.font
						},
						fontSize = {
							order = 2,
							name = L["Font Size"],
							type = "range",
							min = 6, max = 22, step = 1
						},
						fontOutline = {
							order = 3,
							name = L["Font Outline"],
							desc = L["Set the font outline."],
							type = "select",
							values = {
								["NONE"] = L["None"],
								["OUTLINE"] = "OUTLINE",
								["MONOCHROME"] = (not E.isMacClient) and "MONOCHROME" or nil,
								["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
								["THICKOUTLINE"] = "THICKOUTLINE"
							},
						},
					},
				},
			},
		},
	}
};