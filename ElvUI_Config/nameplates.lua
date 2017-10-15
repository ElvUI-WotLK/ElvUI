local E, L, V, P, G = unpack(ElvUI);
local NP = E:GetModule("NamePlates");

local next = next
local ipairs = ipairs
local tremove = tremove
local tinsert = tinsert
local tsort = table.sort
local tonumber = tonumber
local tconcat = table.concat
local format = string.format
local pairs, type, strsplit, match, gsub = pairs, type, strsplit, string.match, string.gsub

local selectedFilter;
local filters;

local ACD = LibStub("AceConfigDialog-3.0-ElvUI");

local positionValues = {
	TOPLEFT = "TOPLEFT",
	LEFT = "LEFT",
	BOTTOMLEFT = "BOTTOMLEFT",
	RIGHT = "RIGHT",
	TOPRIGHT = "TOPRIGHT",
	BOTTOMRIGHT = "BOTTOMRIGHT",
	CENTER = "CENTER",
	TOP = "TOP",
	BOTTOM = "BOTTOM"
};

local carryFilterFrom, carryFilterTo
local function filterValue(value)
	return gsub(value,"([%(%)%.%%%+%-%*%?%[%^%$])","%%%1")
end

local function filterMatch(s,v)
	local m1, m2, m3, m4 = "^"..v.."$", "^"..v..",", ","..v.."$", ","..v..","
	return (match(s, m1) and m1) or (match(s, m2) and m2) or (match(s, m3) and m3) or (match(s, m4) and v..",")
end

local function filterPriority(auraType, unit, value, remove, movehere)
	if not auraType or not value then return end
	local filter = E.db.nameplates.units[unit] and E.db.nameplates.units[unit][auraType] and E.db.nameplates.units[unit][auraType].filters and E.db.nameplates.units[unit][auraType].filters.priority
	if not filter then return end
	local found = filterMatch(filter, filterValue(value))
	if found and movehere then
		local tbl, sv, sm = {strsplit(",",filter)}
		for i in ipairs(tbl) do
			if tbl[i] == value then sv = i elseif tbl[i] == movehere then sm = i end
			if sv and sm then break end
		end
		tremove(tbl, sm);tinsert(tbl, sv, movehere);
		E.db.nameplates.units[unit][auraType].filters.priority = tconcat(tbl,",")
	elseif found and remove then
		E.db.nameplates.units[unit][auraType].filters.priority = gsub(filter, found, "")
	elseif not found and not remove then
		E.db.nameplates.units[unit][auraType].filters.priority = (filter == "" and value) or (filter..","..value)
	end
end

local function UpdateFilterGroup()
	if not selectedFilter or not E.global["nameplates"]["filter"][selectedFilter] then
		E.Options.args.nameplate.args.generalGroup.args.filters.args.filterGroup = nil
		return
	end

	E.Options.args.nameplate.args.generalGroup.args.filters.args.filterGroup = {
		type = "group",
		name = selectedFilter,
		guiInline = true,
		order = -10,
		get = function(info) return E.global["nameplates"]["filter"][selectedFilter][ info[#info] ] end,
		set = function(info, value) E.global["nameplates"]["filter"][selectedFilter][ info[#info] ] = value; NP:ForEachPlate("CheckFilter"); NP:ConfigureAll(); UpdateFilterGroup() end,
		args = {
			enable = {
				type = "toggle",
				order = 1,
				name = L["Enable"],
				desc = L["Use this filter."],
			},
			hide = {
				type = "toggle",
				order = 2,
				name = L["Hide"],
				desc = L["Prevent any nameplate with this unit name from showing."],
			},
			customColor = {
				type = "toggle",
				order = 3,
				name = L["Custom Color"],
				desc = L["Disable threat coloring for this plate and use the custom color."],
			},
			color = {
				type = "color",
				order = 4,
				name = L["Color"],
				get = function(info)
					local t = E.global["nameplates"]["filter"][selectedFilter][ info[#info] ]
					if t then
						return t.r, t.g, t.b, t.a
					end
				end,
				set = function(info, r, g, b)
					E.global["nameplates"]["filter"][selectedFilter][ info[#info] ] = {}
					local t = E.global["nameplates"]["filter"][selectedFilter][ info[#info] ]
					if t then
						t.r, t.g, t.b = r, g, b
						UpdateFilterGroup()
						NP:ForEachPlate("CheckFilter")
						NP:ConfigureAll()
					end
				end
			},
			customScale = {
				type = "range",
				name = L["Custom Scale"],
				desc = L["Set the scale of the nameplate."],
				min = 0.67, max = 2, step = 0.01
			}
		}
	}
end

local ORDER = 100;
local function GetUnitSettings(unit, name)
	local copyValues = {};
	for x, y in pairs(NP.db.units) do
		if(type(y) == "table" and x ~= unit) then
			copyValues[x] = L[x];
		end
	end
	local group = {
		order = ORDER,
		type = "group",
		name = name,
		childGroups = "tab",
		get = function(info) return E.db.nameplates.units[unit][ info[#info] ]; end,
		set = function(info, value) E.db.nameplates.units[unit][ info[#info] ] = value; NP:ConfigureAll(); end,
		args = {
			copySettings = {
				order = -10,
				type = "select",
				name = L["Copy Settings From"],
				desc = L["Copy settings from another unit."],
				values = copyValues,
				get = function() return ""; end,
				set = function(info, value)
					NP:CopySettings(value, unit);
					NP:ConfigureAll();
				end
			},
			defaultSettings = {
				order = -9,
				type = "execute",
				name = L["Default Settings"],
				desc = L["Set Settings to Default"],
				func = function(info, value)
					NP:ResetSettings(unit);
					NP:ConfigureAll();
				end
			},
			healthGroup = {
				order = 1,
				name = L["Health"],
				type = "group",
				get = function(info) return E.db.nameplates.units[unit].healthbar[ info[#info] ]; end,
				set = function(info, value) E.db.nameplates.units[unit].healthbar[ info[#info] ] = value; NP:ConfigureAll(); end,
				args = {
					header = {
						order = 0,
						type = "header",
						name = L["Health"]
					},
					enable = {
						order = 1,
						type = "toggle",
						name = L["Enable"]
					},
					height = {
						order = 2,
						type = "range",
						name = L["Height"],
						min = 4, max = 20, step = 1
					},
					width = {
						order = 3,
						type = "range",
						name = L["Width"],
						min = 50, max = 200, step = 1
					},
					textGroup = {
						order = 100,
						type = "group",
						name = L["Text"],
						guiInline = true,
						get = function(info) return E.db.nameplates.units[unit].healthbar.text[ info[#info] ]; end,
						set = function(info, value) E.db.nameplates.units[unit].healthbar.text[ info[#info] ] = value; NP:ConfigureAll(); end,
						args = {
							enable = {
								order = 1,
								type = "toggle",
								name = L["Enable"]
							},
							format = {
								order = 2,
								name = L["Format"],
								type = "select",
								values = {
									["CURRENT"] = L["Current"],
									["CURRENT_MAX"] = L["Current / Max"],
									["CURRENT_PERCENT"] = L["Current - Percent"],
									["CURRENT_MAX_PERCENT"] = L["Current - Max | Percent"],
									["PERCENT"] = L["Percent"],
									["DEFICIT"] = L["Deficit"]
								}
							}
						}
					}
				}
			},
			castGroup = {
				order = 3,
				name = L["Cast Bar"],
				type = "group",
				get = function(info) return E.db.nameplates.units[unit].castbar[ info[#info] ]; end,
				set = function(info, value) E.db.nameplates.units[unit].castbar[ info[#info] ] = value; NP:ConfigureAll(); end,
				args = {
					header = {
						order = 0,
						type = "header",
						name = L["Cast Bar"]
					},
					hideSpellName = {
						order = 1,
						type = "toggle",
						name = L["Hide Spell Name"]
					},
					hideTime = {
						order = 2,
						type = "toggle",
						name = L["Hide Time"]
					},
					height = {
						order = 3,
						type = "range",
						name = L["Height"],
						min = 4, max = 20, step = 1
					},
					offset = {
						order = 4,
						type = "range",
						name = L["Offset"],
						min = 0, max = 30, step = 1
					},
					castTimeFormat = {
						order = 5,
						type = "select",
						name = L["Cast Time Format"],
						values = {
							["CURRENT"] = L["Current"],
							["CURRENT_MAX"] = L["Current / Max"],
							["REMAINING"] = L["Remaining"]
						}
					},
					channelTimeFormat = {
						order = 6,
						type = "select",
						name = L["Channel Time Format"],
						values = {
							["CURRENT"] = L["Current"],
							["CURRENT_MAX"] = L["Current / Max"],
							["REMAINING"] = L["Remaining"]
						}
					}
				}
			},
			buffsGroup = {
				order = 4,
				name = L["Buffs"],
				type = "group",
				get = function(info) return E.db.nameplates.units[unit].buffs.filters[ info[#info] ] end,
				set = function(info, value) E.db.nameplates.units[unit].buffs.filters[ info[#info] ] = value; NP:ConfigureAll() end,
				disabled = function() return not E.db.nameplates.units[unit].healthbar.enable end,
				args = {
					header = {
						order = 0,
						type = "header",
						name = L["Buffs"],
					},
					enable = {
						order = 1,
						name = L["Enable"],
						type = "toggle",
						get = function(info) return E.db.nameplates.units[unit].buffs[ info[#info] ] end,
						set = function(info, value) E.db.nameplates.units[unit].buffs[ info[#info] ] = value; NP:ConfigureAll() end,
					},
					numAuras = {
						order = 2,
						name = L["# Displayed Auras"],
						desc = L["Controls how many auras are displayed, this will also affect the size of the auras."],
						type = "range",
						min = 1, max = 8, step = 1,
						get = function(info) return E.db.nameplates.units[unit].buffs[ info[#info] ] end,
						set = function(info, value) E.db.nameplates.units[unit].buffs[ info[#info] ] = value; NP:ConfigureAll() end,
					},
					baseHeight = {
						order = 3,
						name = L["Icon Base Height"],
						desc = L["Base Height for the Aura Icon"],
						type = "range",
						min = 6, max = 60, step = 1,
						get = function(info) return E.db.nameplates.units[unit].buffs[ info[#info] ] end,
						set = function(info, value) E.db.nameplates.units[unit].buffs[ info[#info] ] = value; NP:ConfigureAll() end,
					},
					filtersGroup = {
						name = FILTERS,
						order = 4,
						type = "group",
						guiInline = true,
						args = {
							minDuration = {
								order = 1,
								type = "range",
								name = L["Minimum Duration"],
								desc = L["Don't display auras that are shorter than this duration (in seconds). Set to zero to disable."],
								min = 0, max = 10800, step = 1,
							},
							maxDuration = {
								order = 2,
								type = "range",
								name = L["Maximum Duration"],
								desc = L["Don't display auras that are longer than this duration (in seconds). Set to zero to disable."],
								min = 0, max = 10800, step = 1,
							},
							jumpToFilter = {
								order = 3,
								name = L["Filters Page"],
								desc = L["Shortcut to global filters."],
								type = "execute",
								func = function() ACD:SelectGroup("ElvUI", "filters") end,
							},
							spacer1 = {
								order = 4,
								type = "description",
								name = " ",
							},
							specialFilters = {
								order = 5,
								type = "select",
								name = L["Add Special Filter"],
								desc = L["These filters don't use a list of spells like the regular filters. Instead they use the WoW API and some code logic to determine if an aura should be allowed or blocked."],
								values = function()
									local filters = {}
									local list = E.global.nameplates["specialFilters"]
									if not list then return end
									for filter in pairs(list) do
										filters[filter] = filter
									end
									return filters
								end,
								set = function(info, value)
									filterPriority("buffs", unit, value)
									NP:ConfigureAll()
								end
							},
							filter = {
								order = 6,
								type = "select",
								name = L["Add Regular Filter"],
								desc = L["These filters use a list of spells to determine if an aura should be allowed or blocked. The content of these filters can be modified in the 'Filters' section of the config."],
								values = function()
									local filters = {}
									local list = E.global.unitframe["aurafilters"]
									if not list then return end
									for filter in pairs(list) do
										filters[filter] = filter
									end
									return filters
								end,
								set = function(info, value)
									filterPriority("buffs", unit, value)
									NP:ConfigureAll()
								end
							},
							resetPriority = {
								order = 7,
								name = L["Reset Priority"],
								desc = L["Reset filter priority to the default state."],
								type = "execute",
								func = function()
									E.db.nameplates.units[unit].buffs.filters.priority = P.nameplates.units[unit].buffs.filters.priority
									NP:ConfigureAll()
								end,
							},
							filterPriority = {
								order = 8,
								name = L["Filter Priority"],
								type = "multiselect",
								dragdrop = true,
								dragOnLeave = function() end, --keep this here
								dragOnEnter = function(info, value)
									carryFilterTo = info.obj.value
								end,
								dragOnMouseDown = function(info, value)
									carryFilterFrom, carryFilterTo = info.obj.value, nil
								end,
								dragOnMouseUp = function(info, value)
									filterPriority("buffs", unit, carryFilterTo, nil, carryFilterFrom) --add it in the new spot
									carryFilterFrom, carryFilterTo = nil, nil
								end,
								dragOnClick = function(info, value)
									filterPriority("buffs", unit, carryFilterFrom, true)
								end,
								values = function()
									local str = E.db.nameplates.units[unit].buffs.filters.priority
									if str == "" then return nil end
									return {strsplit(",",str)}
								end,
								get = function(info, value)
									local str = E.db.nameplates.units[unit].buffs.filters.priority
									if str == "" then return nil end
									local tbl = {strsplit(",",str)}
									return tbl[value]
								end,
								set = function(info, value)
									NP:ConfigureAll()
								end
							},
							spacer3 = {
								order = 9,
								type = "description",
								name = L["Use drag and drop to rearrange filter priority or right click to remove a filter."],
							},
						},
					},
				},
			},
			debuffsGroup = {
				order = 5,
				name = L["Debuffs"],
				type = "group",
				get = function(info) return E.db.nameplates.units[unit].debuffs.filters[ info[#info] ] end,
				set = function(info, value) E.db.nameplates.units[unit].debuffs.filters[ info[#info] ] = value; NP:ConfigureAll() end,
				disabled = function() return not E.db.nameplates.units[unit].healthbar.enable end,
				args = {
					header = {
						order = 0,
						type = "header",
						name = L["Debuffs"],
					},
					enable = {
						order = 1,
						name = L["Enable"],
						type = "toggle",
						get = function(info) return E.db.nameplates.units[unit].debuffs[ info[#info] ] end,
						set = function(info, value) E.db.nameplates.units[unit].debuffs[ info[#info] ] = value; NP:ConfigureAll() end,
					},
					numAuras = {
						order = 2,
						name = L["# Displayed Auras"],
						desc = L["Controls how many auras are displayed, this will also affect the size of the auras."],
						type = "range",
						min = 1, max = 8, step = 1,
						get = function(info) return E.db.nameplates.units[unit].debuffs[ info[#info] ] end,
						set = function(info, value) E.db.nameplates.units[unit].debuffs[ info[#info] ] = value; NP:ConfigureAll() end,
					},
					baseHeight = {
						order = 3,
						name = L["Icon Base Height"],
						desc = L["Base Height for the Aura Icon"],
						type = "range",
						min = 6, max = 60, step = 1,
						get = function(info) return E.db.nameplates.units[unit].debuffs[ info[#info] ] end,
						set = function(info, value) E.db.nameplates.units[unit].debuffs[ info[#info] ] = value; NP:ConfigureAll() end,
					},
					filtersGroup = {
						name = FILTERS,
						order = 4,
						type = "group",
						guiInline = true,
						args = {
							minDuration = {
								order = 1,
								type = "range",
								name = L["Minimum Duration"],
								desc = L["Don't display auras that are shorter than this duration (in seconds). Set to zero to disable."],
								min = 0, max = 10800, step = 1,
							},
							maxDuration = {
								order = 2,
								type = "range",
								name = L["Maximum Duration"],
								desc = L["Don't display auras that are longer than this duration (in seconds). Set to zero to disable."],
								min = 0, max = 10800, step = 1,
							},
							jumpToFilter = {
								order = 3,
								name = L["Filters Page"],
								desc = L["Shortcut to global filters."],
								type = "execute",
								func = function() ACD:SelectGroup("ElvUI", "filters") end,
							},
							spacer1 = {
								order = 4,
								type = "description",
								name = " ",
							},
							specialFilters = {
								order = 5,
								type = "select",
								name = L["Add Special Filter"],
								desc = L["These filters don't use a list of spells like the regular filters. Instead they use the WoW API and some code logic to determine if an aura should be allowed or blocked."],
								values = function()
									local filters = {}
									local list = E.global.nameplates["specialFilters"]
									if not list then return end
									for filter in pairs(list) do
										filters[filter] = filter
									end
									return filters
								end,
								set = function(info, value)
									filterPriority("debuffs", unit, value)
									NP:ConfigureAll()
								end
							},
							filter = {
								order = 6,
								type = "select",
								name = L["Add Regular Filter"],
								desc = L["These filters use a list of spells to determine if an aura should be allowed or blocked. The content of these filters can be modified in the 'Filters' section of the config."],
								values = function()
									local filters = {}
									local list = E.global.unitframe["aurafilters"]
									if not list then return end
									for filter in pairs(list) do
										filters[filter] = filter
									end
									return filters
								end,
								set = function(info, value)
									filterPriority("debuffs", unit, value)
									NP:ConfigureAll()
								end
							},
							resetPriority = {
								order = 7,
								name = L["Reset Priority"],
								desc = L["Reset filter priority to the default state."],
								type = "execute",
								func = function()
									E.db.nameplates.units[unit].debuffs.filters.priority = P.nameplates.units[unit].debuffs.filters.priority
									NP:ConfigureAll()
								end,
							},
							filterPriority = {
								order = 8,
								dragdrop = true,
								type = "multiselect",
								name = L["Filter Priority"],
								dragOnLeave = function() end, --keep this here
								dragOnEnter = function(info, value)
									carryFilterTo = info.obj.value
								end,
								dragOnMouseDown = function(info, value)
									carryFilterFrom, carryFilterTo = info.obj.value, nil
								end,
								dragOnMouseUp = function(info, value)
									filterPriority("debuffs", unit, carryFilterTo, nil, carryFilterFrom) --add it in the new spot
									carryFilterFrom, carryFilterTo = nil, nil
								end,
								dragOnClick = function(info, value)
									filterPriority("debuffs", unit, carryFilterFrom, true)
								end,
								values = function()
									local str = E.db.nameplates.units[unit].debuffs.filters.priority
									if str == "" then return nil end
									return {strsplit(",",str)}
								end,
								get = function(info, value)
									local str = E.db.nameplates.units[unit].debuffs.filters.priority
									if str == "" then return nil end
									local tbl = {strsplit(",",str)}
									return tbl[value]
								end,
								set = function(info, value)
									NP:ConfigureAll()
								end
							},
							spacer3 = {
								order = 9,
								type = "description",
								name = L["Use drag and drop to rearrange filter priority or right click to remove a filter."],
							},
						},
					},
				},
			},
			levelGroup = {
				order = 6,
				name = LEVEL,
				type = "group",
				args = {
					header = {
						order = 0,
						type = "header",
						name = LEVEL
					},
					enable = {
						order = 1,
						name = L["Enable"],
						type = "toggle",
						get = function(info) return E.db.nameplates.units[unit].showLevel; end,
						set = function(info, value) E.db.nameplates.units[unit].showLevel = value; NP:ConfigureAll(); end
					}
				}
			},
			nameGroup = {
				order = 7,
				name = L["Name"],
				type = "group",
				get = function(info) return E.db.nameplates.units[unit].name[ info[#info] ]; end,
				set = function(info, value) E.db.nameplates.units[unit].name[ info[#info] ] = value; NP:ConfigureAll(); end,
				args = {
					header = {
						order = 0,
						type = "header",
						name = L["Name"]
					},
					enable = {
						order = 1,
						name = L["Enable"],
						type = "toggle",
						get = function(info) return E.db.nameplates.units[unit].showName; end,
						set = function(info, value) E.db.nameplates.units[unit].showName = value; NP:ConfigureAll(); end
					}
				}
			}
		}
	};

	if(unit == "FRIENDLY_PLAYER" or unit == "ENEMY_PLAYER") then
		group.args.healthGroup.args.useClassColor = {
			order = 4,
			type = "toggle",
			name = L["Use Class Color"]
		};
		group.args.nameGroup.args.useClassColor = {
			order = 3,
			type = "toggle",
			name = L["Use Class Color"]
		};
	elseif(unit == "ENEMY_NPC" or unit == "FRIENDLY_NPC") then
		group.args.eliteIcon = {
			order = 10,
			name = L["Elite Icon"],
			type = "group",
			get = function(info) return E.db.nameplates.units[unit].eliteIcon[ info[#info] ]; end,
			set = function(info, value) E.db.nameplates.units[unit].eliteIcon[ info[#info] ] = value; NP:ConfigureAll(); end,
			args = {
				header = {
					order = 0,
					type = "header",
					name = L["Elite Icon"]
				},
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"]
				},
				position = {
					order = 2,
					type = "select",
					name = L["Position"],
					values = {
						["LEFT"] = L["Left"],
						["RIGHT"] = L["Right"],
						["TOP"] = L["Top"],
						["BOTTOM"] = L["Bottom"],
						["CENTER"] = L["Center"]
					}
				},
				size = {
					order = 3,
					type = "range",
					name = L["Size"],
					min = 12, max = 42, step = 1
				},
				xOffset = {
					order = 4,
					type = "range",
					name = L["X-Offset"],
					min = -100, max = 100, step = 1
				},
				yOffset = {
					order = 5,
					type = "range",
					name = L["Y-Offset"],
					min = -100, max = 100, step = 1
				}
			}
		};
	end

	ORDER = ORDER + 100;
	return group;
end

E.Options.args.nameplate = {
	type = "group",
	name = L["NamePlates"],
	childGroups = "tree",
	get = function(info) return E.db.nameplates[ info[#info] ] end,
	set = function(info, value) E.db.nameplates[ info[#info] ] = value; NP:ConfigureAll(); end,
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["NAMEPLATE_DESC"]
		},
		enable = {
			order = 2,
			type = "toggle",
			name = L["Enable"],
			get = function(info) return E.private.nameplates[ info[#info] ]; end,
			set = function(info, value) E.private.nameplates[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end
		},
		header = {
			order = 3,
			type = "header",
			name = L["Shortcuts"]
		},
		spacer1 = {
			order = 4,
			type = "description",
			name = " "
		},
		generalShortcut = {
			order = 5,
			type = "execute",
			name = L["General Options"],
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "generalGroup"); end
		},
		friendlyPlayerShortcut = {
			order = 6,
			type = "execute",
			name = L["Friendly Player Frames"],
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "friendlyPlayerGroup"); end
		},
		enemyPlayerShortcut = {
			order = 7,
			type = "execute",
			name = L["Enemy Player Frames"],
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "enemyPlayerGroup"); end
		},
		friendlyNPCShortcut = {
			order = 8,
			type = "execute",
			name = L["Friendly NPC Frames"],
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "friendlyNPCGroup"); end
		},
		enemyNPCShortcut = {
			order = 9,
			type = "execute",
			name = L["Enemy NPC Frames"],
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "enemyNPCGroup"); end
		},
		generalGroup = {
			order = 20,
			type = "group",
			name = L["General Options"],
			childGroups = "tab",
			disabled = function() return not E.NamePlates; end,
			args = {
				general = {
					order = 1,
					type = "group",
					name = L["General"],
					args = {
						statusbar = {
							order = 0,
							type = "select",
							dialogControl = "LSM30_Statusbar",
							name = L["StatusBar Texture"],
							values = AceGUIWidgetLSMlists.statusbar,
						},
						motionType = {
							type = "select",
							order = 1,
							name = L["Nameplate Motion Type"],
							desc = L["Set to either stack nameplates vertically or allow them to overlap."],
							values = {
								["STACKED"] = L["Stacking Nameplates"],
								["OVERLAP"] = L["Overlapping Nameplates"],
							},
						},
						useTargetGlow = {
							order = 2,
							type = "toggle",
							name = L["Use Target Glow"],
						},
						useTargetScale = {
							order = 3,
							type = "toggle",
							name = L["Use Target Scale"],
							desc = L["Enable/Disable the scaling of targetted nameplates."],
						},
						targetScale = {
							order = 4,
							type = "range",
							name = L["Target Scale"],
							desc = L["Scale of the nameplate that is targetted."],
							min = 0.3, max = 2, step = 0.01,
							isPercent = true,
							disabled = function() return E.db.nameplates.useTargetScale ~= true end,
						},
						nonTargetTransparency = {
							name = L["Non-Target Transparency"],
							desc = L["Set the transparency level of nameplates that are not the target nameplate."],
							type = "range",
							min = 0, max = 1, step = 0.01,
							isPercent = true,
							order = 8,
						},
						lowHealthThreshold = {
							order = 9,
							name = L["Low Health Threshold"],
							desc = L["Make the unitframe glow yellow when it is below this percent of health, it will glow red when the health value is half of this value."],
							type = "range",
							isPercent = true,
							min = 0, max = 1, step = 0.01,
						},
						showEnemyCombat = {
							order = 10,
							type = "select",
							name = L["Enemy Combat Toggle"],
							desc = L["Control enemy nameplates toggling on or off when in combat."],
							values = {
								["DISABLED"] = L["Disabled"],
								["TOGGLE_ON"] = L["Toggle On While In Combat"],
								["TOGGLE_OFF"] = L["Toggle Off While In Combat"],
							},
							set = function(info, value)
								E.db.nameplates[ info[#info] ] = value;
								NP:PLAYER_REGEN_ENABLED();
							end,
						},
						showFriendlyCombat = {
							order = 11,
							type = "select",
							name = L["Friendly Combat Toggle"],
							desc = L["Control friendly nameplates toggling on or off when in combat."],
							values = {
								["DISABLED"] = L["Disabled"],
								["TOGGLE_ON"] = L["Toggle On While In Combat"],
								["TOGGLE_OFF"] = L["Toggle Off While In Combat"],
							},
							set = function(info, value)
								E.db.nameplates[ info[#info] ] = value;
								NP:PLAYER_REGEN_ENABLED();
							end
						}
					}
				},
				fontGroup = {
					order = 100,
					type = "group",
					name = L["Fonts"],
					args = {
						font = {
							order = 4,
							type = "select", dialogControl = "LSM30_Font",
							name = L["Font"],
							values = AceGUIWidgetLSMlists.font
						},
						fontSize = {
							order = 5,
							type = "range",
							name = L["Font Size"],
							min = 4, max = 34, step = 1,
						},
						fontOutline = {
							order = 6,
							type = "select",
							name = L["Font Outline"],
							desc = L["Set the font outline."],
							values = {
								["NONE"] = L["None"],
								["OUTLINE"] = "OUTLINE",
								["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
								["THICKOUTLINE"] = "THICKOUTLINE"
							}
						}
					}
				},
				threatGroup = {
					order = 150,
					type = "group",
					name = L["Threat"],
					get = function(info)
						local t = E.db.nameplates.threat[ info[#info] ];
						local d = P.nameplates.threat[info[#info]];
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b;
					end,
					set = function(info, r, g, b)
						local t = E.db.nameplates.threat[ info[#info] ];
						t.r, t.g, t.b = r, g, b;
					end,
					args = {
						useThreatColor = {
							order = 1,
							type = "toggle",
							name = L["Use Threat Color"],
							get = function(info) return E.db.nameplates.threat.useThreatColor; end,
							set = function(info, value) E.db.nameplates.threat.useThreatColor = value; end
						},
						goodColor = {
							order = 2,
							type = "color",
							name = L["Good Color"],
							hasAlpha = false,
							disabled = function() return not E.db.nameplates.threat.useThreatColor; end
						},
						badColor = {
							order = 3,
							type = "color",
							name = L["Bad Color"],
							hasAlpha = false,
							disabled = function() return not E.db.nameplates.threat.useThreatColor; end
						},
						goodTransition = {
							order = 4,
							type = "color",
							name = L["Good Transition Color"],
							hasAlpha = false,
							disabled = function() return not E.db.nameplates.threat.useThreatColor; end
						},
						badTransition = {
							order = 5,
							type = "color",
							name = L["Bad Transition Color"],
							hasAlpha = false,
							disabled = function() return not E.db.nameplates.threat.useThreatColor; end
						},
						beingTankedByTank = {
							order = 6,
							type = "toggle",
							name = L["Color Tanked"],
							desc = L["Use Tanked Color when a nameplate is being effectively tanked by another tank."],
							get = function(info) return E.db.nameplates.threat[ info[#info] ]; end,
							set = function(info, value) E.db.nameplates.threat[ info[#info] ] = value; end,
							disabled = function() return not E.db.nameplates.threat.useThreatColor; end
						},
						beingTankedByTankColor = {
							order = 7,
							type = "color",
							name = L["Tanked Color"],
							hasAlpha = false,
							disabled = function() return (not E.db.nameplates.threat.beingTankedByTank or not E.db.nameplates.threat.useThreatColor); end
						},
						goodScale = {
							order = 8,
							type = "range",
							name = L["Good Scale"],
							get = function(info) return E.db.nameplates.threat[ info[#info] ]; end,
							set = function(info, value) E.db.nameplates.threat[ info[#info] ] = value; end,
							min = 0.3, max = 2, step = 0.01,
							isPercent = true
						},
						badScale = {
							order = 9,
							type = "range",
							name = L["Bad Scale"],
							get = function(info) return E.db.nameplates.threat[ info[#info] ]; end,
							set = function(info, value) E.db.nameplates.threat[ info[#info] ] = value; end,
							min = 0.3, max = 2, step = 0.01,
							isPercent = true
						}
					}
				},
				castGroup = {
					order = 175,
					type = "group",
					name = L["Cast Bar"],
					get = function(info)
						local t = E.db.nameplates[ info[#info] ];
						local d = P.nameplates[info[#info]];
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b;
					end,
					set = function(info, r, g, b)
						local t = E.db.nameplates[ info[#info] ];
						t.r, t.g, t.b = r, g, b;
						NP:ForEachPlate("ConfigureElement_CastBar");
					end,
					args = {
						castColor = {
							order = 1,
							type = "color",
							name = L["Cast Color"],
							hasAlpha = false
						},
						castNoInterruptColor = {
							order = 2,
							type = "color",
							name = L["Cast No Interrupt Color"],
							hasAlpha = false
						}
					}
				},
				reactions = {
					order = 200,
					type = "group",
					name = L["Reaction Colors"],
					get = function(info)
						local t = E.db.nameplates.reactions[ info[#info] ];
						local d = P.nameplates.reactions[info[#info]];
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b;
					end,
					set = function(info, r, g, b)
						local t = E.db.nameplates.reactions[ info[#info] ];
						t.r, t.g, t.b = r, g, b;
						NP:ConfigureAll();
					end,
					args = {
						bad = {
							order = 1,
							type = "color",
							name = L["Enemy"],
							hasAlpha = false
						},
						neutral = {
							order = 2,
							type = "color",
							name = L["Neutral"],
							hasAlpha = false
						},
						good = {
							order = 3,
							type = "color",
							name = L["Friendly NPC"],
							hasAlpha = false
						},
						tapped = {
							order = 4,
							type = "color",
							name = L["Tagged NPC"],
							hasAlpha = false
						},
						friendlyPlayer = {
							order = 5,
							type = "color",
							name = L["Friendly Player"],
							hasAlpha = false
						}
					}
				},
				filters = {
					order = 300,
					type = "group",
					name = L["Filters"],
					args = {
						addname = {
							order = 2,
							type = "input",
							name = L["Add Name"],
							get = function(info) return "" end,
							set = function(info, value)
								if E.global["nameplates"]["filter"][value] then
									E:Print(L["Filter already exists!"])
									return
								end

								E.global["nameplates"]["filter"][value] = {
									["enable"] = true,
									["hide"] = false,
									["customColor"] = false,
									["customScale"] = 1,
									["color"] = {r = 104/255, g = 138/255, b = 217/255}
								}
								UpdateFilterGroup()
								NP:ConfigureAll()
							end
						},
						deletename = {
							order = 3,
							type = "input",
							name = L["Remove Name"],
							get = function(info) return "" end,
							set = function(info, value)
								if G["nameplates"]["filter"][value] then
									E.global["nameplates"]["filter"][value].enable = false;
									E:Print(L["You can't remove a default name from the filter, disabling the name."])
								else
									E.global["nameplates"]["filter"][value] = nil;
									E.Options.args.nameplates.args.filters.args.filterGroup = nil;
								end
								UpdateFilterGroup()
								NP:ConfigureAll();
							end
						},
						selectFilter = {
							order = 3,
							type = "select",
							name = L["Select Filter"],
							get = function(info) return selectedFilter end,
							set = function(info, value) selectedFilter = value; UpdateFilterGroup() end,
							values = function()
								filters = {}
								for filter in pairs(E.global["nameplates"]["filter"]) do
									filters[filter] = filter
								end
								return filters
							end
						}
					}
				}
			}
		},
		friendlyPlayerGroup = GetUnitSettings("FRIENDLY_PLAYER", L["Friendly Player Frames"]),
		enemyPlayerGroup = GetUnitSettings("ENEMY_PLAYER", L["Enemy Player Frames"]),
		friendlyNPCGroup = GetUnitSettings("FRIENDLY_NPC", L["Friendly NPC Frames"]),
		enemyNPCGroup = GetUnitSettings("ENEMY_NPC", L["Enemy NPC Frames"])
	}
};