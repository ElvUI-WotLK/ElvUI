local E, _, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
local NP = E:GetModule("NamePlates")
local ACD = E.Libs.AceConfigDialog

local next, ipairs, pairs, type, tonumber = next, ipairs, pairs, type, tonumber
local tremove, tinsert, tconcat = tremove, tinsert, table.concat
local format, match, gsub, strsplit = string.format, string.match, string.gsub, strsplit

local GetSpellInfo = GetSpellInfo

local positionValues = {
	BOTTOMLEFT = "BOTTOMLEFT",
	BOTTOMRIGHT = "BOTTOMRIGHT",
	LEFT = "LEFT",
	RIGHT = "RIGHT",
	TOPLEFT = "TOPLEFT",
	TOPRIGHT = "TOPRIGHT"
}

local raidTargetIcon = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%s:0|t %s"
local selectedNameplateFilter

local totemsColor = {
	["fire"] = "|cffff8f8f",
	["earth"] = "|cffffb31f",
	["water"] = "|cff2b76ff",
	["air"] = "|cffb8d1ff"
}

local carryFilterFrom, carryFilterTo

local function filterMatch(s,v)
	local m1, m2, m3, m4 = "^"..v.."$", "^"..v..",", ","..v.."$", ","..v..","
	return (match(s, m1) and m1) or (match(s, m2) and m2) or (match(s, m3) and m3) or (match(s, m4) and v..",")
end

local function filterPriority(auraType, unit, value, remove, movehere)
	if not auraType or not value then return end
	local filter = E.db.nameplates.units[unit] and E.db.nameplates.units[unit][auraType] and E.db.nameplates.units[unit][auraType].filters and E.db.nameplates.units[unit][auraType].filters.priority
	if not filter then return end
	local found = filterMatch(filter, E:EscapeString(value))
	if found and movehere then
		local tbl, sv, sm = {strsplit(",",filter)}
		for i in ipairs(tbl) do
			if tbl[i] == value then sv = i elseif tbl[i] == movehere then sm = i end
			if sv and sm then break end
		end
		tremove(tbl, sm)
		tinsert(tbl, sv, movehere)
		E.db.nameplates.units[unit][auraType].filters.priority = tconcat(tbl,",")
	elseif found and remove then
		E.db.nameplates.units[unit][auraType].filters.priority = gsub(filter, found, "")
	elseif not found and not remove then
		E.db.nameplates.units[unit][auraType].filters.priority = (filter == "" and value) or (filter..","..value)
	end
end

local function UpdateInstanceDifficulty()
	if E.global.nameplates.filters[selectedNameplateFilter].triggers.instanceType.party then
		E.Options.args.nameplate.args.filters.args.triggers.args.instanceType.args.dungeonDifficulty = {
			order = 10,
			type = "group",
			name = L["DUNGEON_DIFFICULTY"],
			desc = L["Check these to only have the filter active in certain difficulties. If none are checked, it is active in all difficulties."],
			guiInline = true,
			get = function(info) return E.global.nameplates.filters[selectedNameplateFilter].triggers.instanceDifficulty.dungeon[info[#info]] end,
			set = function(info, value)
				E.global.nameplates.filters[selectedNameplateFilter].triggers.instanceDifficulty.dungeon[info[#info]] = value
				UpdateInstanceDifficulty()
				NP:ConfigureAll()
			end,
			args = {
				normal = {
					order = 1,
					type = "toggle",
					name = L["PLAYER_DIFFICULTY1"]
				},
				heroic = {
					order = 2,
					type = "toggle",
					name = L["PLAYER_DIFFICULTY2"]
				}
			}
		}
	else
		E.Options.args.nameplate.args.filters.args.triggers.args.instanceType.args.dungeonDifficulty = nil
	end

	if E.global.nameplates.filters[selectedNameplateFilter].triggers.instanceType.raid then
		E.Options.args.nameplate.args.filters.args.triggers.args.instanceType.args.raidDifficulty = {
			order = 11,
			type = "group",
			name = L["Raid Difficulty"],
			desc = L["Check these to only have the filter active in certain difficulties. If none are checked, it is active in all difficulties."],
			guiInline = true,
			get = function(info) return E.global.nameplates.filters[selectedNameplateFilter].triggers.instanceDifficulty.raid[info[#info]] end,
			set = function(info, value)
				E.global.nameplates.filters[selectedNameplateFilter].triggers.instanceDifficulty.raid[info[#info]] = value
				UpdateInstanceDifficulty()
				NP:ConfigureAll()
			end,
			args = {
				normal = {
					order = 1,
					type = "toggle",
					name = L["PLAYER_DIFFICULTY1"]
				},
				heroic = {
					order = 2,
					type = "toggle",
					name = L["PLAYER_DIFFICULTY2"]
				}
			}
		}
	else
		E.Options.args.nameplate.args.filters.args.triggers.args.instanceType.args.raidDifficulty = nil
	end
end

local function UpdateStyleLists()
	if E.global.nameplates.filters[selectedNameplateFilter] and E.global.nameplates.filters[selectedNameplateFilter].triggers and E.global.nameplates.filters[selectedNameplateFilter].triggers.names then
		E.Options.args.nameplate.args.filters.args.triggers.args.names.args.names = {
			order = 50,
			type = "group",
			name = "",
			guiInline = true,
			args = {}
		}
		if next(E.global.nameplates.filters[selectedNameplateFilter].triggers.names) then
			for name in pairs(E.global.nameplates.filters[selectedNameplateFilter].triggers.names) do
				E.Options.args.nameplate.args.filters.args.triggers.args.names.args.names.args[name] = {
					order = -1,
					type = "toggle",
					name = name,
					get = function(info)
						return E.global.nameplates.filters[selectedNameplateFilter].triggers and E.global.nameplates.filters[selectedNameplateFilter].triggers.names and E.global.nameplates.filters[selectedNameplateFilter].triggers.names[name]
					end,
					set = function(info, value)
						E.global.nameplates.filters[selectedNameplateFilter].triggers.names[name] = value
						NP:ConfigureAll()
					end
				}
			end
		end
	end
	if E.global.nameplates.filters[selectedNameplateFilter] and E.global.nameplates.filters[selectedNameplateFilter].triggers.casting and E.global.nameplates.filters[selectedNameplateFilter].triggers.casting.spells then
		E.Options.args.nameplate.args.filters.args.triggers.args.casting.args.spells = {
			order = 50,
			type = "group",
			name = "",
			guiInline = true,
			args = {}
		}
		if next(E.global.nameplates.filters[selectedNameplateFilter].triggers.casting.spells) then
			local spell, spellName, notDisabled
			for name in pairs(E.global.nameplates.filters[selectedNameplateFilter].triggers.casting.spells) do
				spell = name
				if tonumber(spell) then
					spellName = GetSpellInfo(spell)
					notDisabled = (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					if spellName then
						if notDisabled then
							spell = format("|cFFffff00%s|r |cFFffffff(%d)|r", spellName, spell)
						else
							spell = format("%s (%d)", spellName, spell)
						end
					end
				end
				E.Options.args.nameplate.args.filters.args.triggers.args.casting.args.spells.args[name] = {
					order = -1,
					type = "toggle",
					name = spell,
					get = function(info)
						return E.global.nameplates.filters[selectedNameplateFilter].triggers and E.global.nameplates.filters[selectedNameplateFilter].triggers.casting.spells and E.global.nameplates.filters[selectedNameplateFilter].triggers.casting.spells[name]
					end,
					set = function(info, value)
						E.global.nameplates.filters[selectedNameplateFilter].triggers.casting.spells[name] = value
						NP:ConfigureAll()
					end
				}
			end
		end
	end

	if E.global.nameplates.filters[selectedNameplateFilter] and E.global.nameplates.filters[selectedNameplateFilter].triggers.cooldowns and E.global.nameplates.filters[selectedNameplateFilter].triggers.cooldowns.names then
		E.Options.args.nameplate.args.filters.args.triggers.args.cooldowns.args.names = {
			order = 50,
			type = "group",
			name = "",
			guiInline = true,
			args = {}
		}
		if next(E.global.nameplates.filters[selectedNameplateFilter].triggers.cooldowns.names) then
			local spell, spellName, notDisabled
			for name in pairs(E.global.nameplates.filters[selectedNameplateFilter].triggers.cooldowns.names) do
				spell = name
				if tonumber(spell) then
					spellName = GetSpellInfo(spell)
					notDisabled = (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					if spellName then
						if notDisabled then
							spell = format("|cFFffff00%s|r |cFFffffff(%d)|r", spellName, spell)
						else
							spell = format("%s (%d)", spellName, spell)
						end
					end
				end
				E.Options.args.nameplate.args.filters.args.triggers.args.cooldowns.args.names.args[name] = {
					order = -1,
					type = "select",
					name = spell,
					values = {
						["DISABLED"] = L["DISABLE"],
						["ONCD"] = L["On Cooldown"],
						["OFFCD"] = L["Off Cooldown"]
					},
					get = function(info)
						return E.global.nameplates.filters[selectedNameplateFilter].triggers and E.global.nameplates.filters[selectedNameplateFilter].triggers.cooldowns.names and E.global.nameplates.filters[selectedNameplateFilter].triggers.cooldowns.names[name]
					end,
					set = function(info, value)
						E.global.nameplates.filters[selectedNameplateFilter].triggers.cooldowns.names[name] = value
						NP:ConfigureAll()
					end
				}
			end
		end
	end

	if E.global.nameplates.filters[selectedNameplateFilter] and E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs and E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs.names then
		E.Options.args.nameplate.args.filters.args.triggers.args.buffs.args.names = {
			order = 50,
			type = "group",
			name = "",
			guiInline = true,
			args = {}
		}
		if next(E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs.names) then
			local spell, spellName, notDisabled
			for name in pairs(E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs.names) do
				spell = name
				if tonumber(spell) then
					spellName = GetSpellInfo(spell)
					notDisabled = (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					if spellName then
						if notDisabled then
							spell = format("|cFFffff00%s|r |cFFffffff(%d)|r", spellName, spell)
						else
							spell = format("%s (%d)", spellName, spell)
						end
					end
				end
				E.Options.args.nameplate.args.filters.args.triggers.args.buffs.args.names.args[name] = {
					order = -1,
					type = "toggle",
					name = spell,
					textWidth = true,
					get = function(info)
						return E.global.nameplates.filters[selectedNameplateFilter].triggers and E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs.names and E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs.names[name]
					end,
					set = function(info, value)
						E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs.names[name] = value
						NP:ConfigureAll()
					end
				}
			end
		end
	end

	if E.global.nameplates.filters[selectedNameplateFilter] and E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs and E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs.names then
		E.Options.args.nameplate.args.filters.args.triggers.args.debuffs.args.names = {
			order = 50,
			type = "group",
			name = "",
			guiInline = true,
			args = {}
		}
		if next(E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs.names) then
			local spell, spellName, notDisabled
			for name in pairs(E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs.names) do
				spell = name
				if tonumber(spell) then
					spellName = GetSpellInfo(spell)
					notDisabled = (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					if spellName then
						if notDisabled then
							spell = format("|cFFffff00%s|r |cFFffffff(%d)|r", spellName, spell)
						else
							spell = format("%s (%d)", spellName, spell)
						end
					end
				end
				E.Options.args.nameplate.args.filters.args.triggers.args.debuffs.args.names.args[name] = {
					textWidth = true,
					order = -1,
					type = "toggle",
					name = spell,
					get = function(info)
						return E.global.nameplates.filters[selectedNameplateFilter].triggers and E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs.names and E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs.names[name]
					end,
					set = function(info, value)
						E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs.names[name] = value
						NP:ConfigureAll()
					end
				}
			end
		end
	end

	if E.global.nameplates.filters[selectedNameplateFilter] and E.global.nameplates.filters[selectedNameplateFilter].triggers.totems then
		for totemSchool in pairs(G.nameplates.totemTypes) do
			local titemSchoolLoc, order

			if totemSchool == "fire" then
				titemSchoolLoc, order = BINDING_NAME_MULTICASTACTIONBUTTON10, 51
			elseif totemSchool == "earth" then
				titemSchoolLoc, order = BINDING_NAME_MULTICASTACTIONBUTTON1, 50
			elseif totemSchool == "water" then
				titemSchoolLoc, order = BINDING_NAME_MULTICASTACTIONBUTTON11, 52
			elseif totemSchool == "air" then
				titemSchoolLoc, order = BINDING_NAME_MULTICASTACTIONBUTTON12, 53
			elseif totemSchool == "other" then
				titemSchoolLoc, order = OTHER, 54
			end

			E.Options.args.nameplate.args.filters.args.triggers.args.totems.args[totemSchool] = {
				order = order,
				type = "group",
				name = (totemsColor[totemSchool] or "")..titemSchoolLoc,
				guiInline = true,
				disabled = function() return not E.global.nameplates.filters[selectedNameplateFilter].triggers.totems.enable end,
				args = {}
			}
		end

		for totem, data in pairs(NP.TriggerConditions.totems) do
			E.Options.args.nameplate.args.filters.args.triggers.args.totems.args[data[2]].args[totem] = {
				textWidth = true,
				order = -1,
				type = "toggle",
				name = data[1],
				get = function(info)
					return E.global.nameplates.filters[selectedNameplateFilter].triggers and E.global.nameplates.filters[selectedNameplateFilter].triggers.totems and E.global.nameplates.filters[selectedNameplateFilter].triggers.totems[totem]
				end,
				set = function(info, value)
					E.global.nameplates.filters[selectedNameplateFilter].triggers.totems[totem] = value
					NP:ConfigureAll()
				end
			}
		end
	end

	if E.global.nameplates.filters[selectedNameplateFilter] and E.global.nameplates.filters[selectedNameplateFilter].triggers.uniqueUnits then
		for unitType in pairs(G.nameplates.uniqueUnitTypes) do
			local name, order

			if unitType == "pvp" then
				name, order = "PvP", 50
			elseif unitType == "pve" then
				name, order = "PvE", 51
			end

			E.Options.args.nameplate.args.filters.args.triggers.args.uniqueUnits.args[unitType] = {
				order = order,
				type = "group",
				name = name,
				guiInline = true,
				disabled = function() return not E.global.nameplates.filters[selectedNameplateFilter].triggers.uniqueUnits.enable end,
				args = {}
			}
		end

		for unit, data in pairs(NP.TriggerConditions.uniqueUnits) do
			E.Options.args.nameplate.args.filters.args.triggers.args.uniqueUnits.args[data[2]].args[unit] = {
				textWidth = true,
				order = -1,
				type = "toggle",
				name = data[1],
				get = function(info)
					return E.global.nameplates.filters[selectedNameplateFilter].triggers and E.global.nameplates.filters[selectedNameplateFilter].triggers.uniqueUnits and E.global.nameplates.filters[selectedNameplateFilter].triggers.uniqueUnits[unit]
				end,
				set = function(info, value)
					E.global.nameplates.filters[selectedNameplateFilter].triggers.uniqueUnits[unit] = value
					NP:ConfigureAll()
				end
			}
		end
	end
end

local function UpdateFilterGroup()
	if not selectedNameplateFilter or not E.global.nameplates.filters[selectedNameplateFilter] then
		E.Options.args.nameplate.args.filters.args.header = nil
		E.Options.args.nameplate.args.filters.args.actions = nil
		E.Options.args.nameplate.args.filters.args.triggers = nil
	end
	if selectedNameplateFilter and E.global.nameplates.filters[selectedNameplateFilter] then
		E.Options.args.nameplate.args.filters.args.header = {
			order = 4,
			type = "header",
			name = selectedNameplateFilter
		}
		E.Options.args.nameplate.args.filters.args.triggers = {
			order = 5,
			type = "group",
			name = L["Triggers"],
			args = {
				enable = {
					order = 0,
					type = "toggle",
					name = L["Enable"],
					get = function(info)
						return (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
					set = function(info, value)
						if not E.db.nameplates then E.db.nameplates = {} end
						if not E.db.nameplates.filters then E.db.nameplates.filters = {} end
						if not E.db.nameplates.filters[selectedNameplateFilter] then E.db.nameplates.filters[selectedNameplateFilter] = {} end
						if not E.db.nameplates.filters[selectedNameplateFilter].triggers then E.db.nameplates.filters[selectedNameplateFilter].triggers = {} end
						E.db.nameplates.filters[selectedNameplateFilter].triggers.enable = value
						UpdateStyleLists() --we need this to recolor the spellid based on wether or not the filter is disabled
						NP:ConfigureAll()
					end
				},
				priority = {
					order = 1,
					type = "range",
					name = L["Filter Priority"],
					desc = L["Lower numbers mean a higher priority. Filters are processed in order from 1 to 100."],
					min = 1, max = 100, step = 1,
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					get = function(info)
						return E.global.nameplates.filters[selectedNameplateFilter].triggers.priority or 1
					end,
					set = function(info, value)
						E.global.nameplates.filters[selectedNameplateFilter].triggers.priority = value
						NP:ConfigureAll()
					end
				},
				resetFilter = {
					order = 2,
					type = "execute",
					name = L["Clear Filter"],
					desc = L["Return filter to its default state."],
					func = function()
						local filter = {}
						if G.nameplates.filters[selectedNameplateFilter] then
							filter = E:CopyTable(filter, G.nameplates.filters[selectedNameplateFilter])
						end
						NP:StyleFilterCopyDefaults(filter)
						E.global.nameplates.filters[selectedNameplateFilter] = filter
						UpdateStyleLists()
						UpdateInstanceDifficulty()
						NP:ConfigureAll()
					end
				},
				spacer1 = {
					order = 3,
					type = "description",
					name = ""
				},
				names = {
					order = 4,
					type = "group",
					name = L["NAME"],
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						addName = {
							order = 1,
							type = "input",
							name = L["Add Name"],
							desc = L["Add a Name to the list."],
							get = function(info) return "" end,
							set = function(info, value)
								if match(value, "^[%s%p]-$") then
									return
								end
								E.global.nameplates.filters[selectedNameplateFilter].triggers.names[value] = true
								UpdateFilterGroup()
								NP:ConfigureAll()
							end
						},
						removeName = {
							order = 2,
							type = "input",
							name = L["Remove Name"],
							desc = L["Remove a Name from the list."],
							get = function(info) return "" end,
							set = function(info, value)
								if match(value, "^[%s%p]-$") then
									return
								end
								E.global.nameplates.filters[selectedNameplateFilter].triggers.names[value] = nil
								UpdateFilterGroup()
								NP:ConfigureAll()
							end
						}
					}
				},
				targeting = {
					order = 5,
					type = "group",
					name = L["Targeting"],
					get = function(info)
						return E.global.nameplates.filters[selectedNameplateFilter].triggers[info[#info]]
					end,
					set = function(info, value)
						E.global.nameplates.filters[selectedNameplateFilter].triggers[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = function()
						return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter]
						and E.db.nameplates.filters[selectedNameplateFilter].triggers
						and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
					args = {
						isTarget = {
							order = 1,
							type = "toggle",
							name = L["Is Targeted"],
							desc = L["If enabled then the filter will only activate when you are targeting the unit."]
						},
						notTarget = {
							order = 2,
							type = "toggle",
							name = L["Not Targeted"],
							desc = L["If enabled then the filter will only activate when you are not targeting the unit."]
						},
						requireTarget = {
							order = 3,
							type = "toggle",
							name = L["Require Target"],
							desc = L["If enabled then the filter will only activate when you have a target."]
						},
					}
				},
				casting = {
					order = 6,
					type = "group",
					name = L["Casting"],
					get = function(info)
						return E.global.nameplates.filters[selectedNameplateFilter].triggers.casting[info[#info]]
					end,
					set = function(info, value)
						E.global.nameplates.filters[selectedNameplateFilter].triggers.casting[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = function()
						return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
							E.db.nameplates.filters[selectedNameplateFilter].triggers and
							E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
					args = {
						types = {
							name = "",
							type = "group",
							guiInline = true,
							order = 2,
							args = {
								isCasting = {
									type = "toggle",
									order = 1,
									name = L["Is Casting Anything"],
									desc = L["If enabled then the filter will activate if the unit is casting anything."]
								},
								notCasting = {
									type = "toggle",
									order = 2,
									name = L["Not Casting Anything"],
									desc = L["If enabled then the filter will activate if the unit is not casting anything."]
								},
								isChanneling = {
									type = "toggle",
									order = 3,
									customWidth = 200,
									name = L["Is Channeling Anything"],
									desc = L["If enabled then the filter will activate if the unit is channeling anything."]
								},
								notChanneling = {
									type = "toggle",
									order = 4,
									customWidth = 200,
									name = L["Not Channeling Anything"],
									desc = L["If enabled then the filter will activate if the unit is not channeling anything."]
								},
								spacer1 = {
									order = 5,
									type = "description",
									name = " ",
									width = "full"
								},
								interruptible = {
									type = "toggle",
									order = 6,
									name = L["Interruptible"],
									desc = L["If enabled then the filter will only activate if the unit is casting interruptible spells."]
								},
								notInterruptible = {
									type = "toggle",
									order = 7,
									name = L["Non-Interruptable"],
									desc = L["If enabled then the filter will only activate if the unit is casting not interruptible spells."]
								}
							}
						},
						addSpell = {
							order = 9,
							name = L["Add Spell ID or Name"],
							type = "input",
							get = function(info)
								return ""
							end,
							set = function(info, value)
								if match(value, "^[%s%p]-$") then return end

								E.global.nameplates.filters[selectedNameplateFilter].triggers.casting.spells[value] = true
								UpdateFilterGroup()
								NP:ConfigureAll()
							end
						},
						removeSpell = {
							order = 10,
							name = L["Remove Spell ID or Name"],
							desc = L["If the aura is listed with a number then you need to use that to remove it from the list."],
							type = "input",
							get = function(info)
								return ""
							end,
							set = function(info, value)
								if match(value, "^[%s%p]-$") then return end

								E.global.nameplates.filters[selectedNameplateFilter].triggers.casting.spells[value] = nil
								UpdateFilterGroup()
								NP:ConfigureAll()
							end
						},
						description1 = {
							order = 12,
							type = "description",
							name = L["You do not need to use 'Is Casting Anything' or 'Is Channeling Anything' for these spells to trigger."]
						},
						description2 = {
							order = 13,
							type = "description",
							name = L["If this list is empty, and if 'Interruptible' is checked, then the filter will activate on any type of cast that can be interrupted."]
						},
						notSpell = {
							type = "toggle",
							order = -2,
							name = L["Not Spell"],
							desc = L["If enabled then the filter will only activate if the unit is not casting or channeling one of the selected spells."]
						}
					}
				},
				combat = {
					order = 7,
					type = "group",
					name = L["COMBAT"],
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						inCombat = {
							order = 1,
							type = "toggle",
							name = L["Player in Combat"],
							desc = L["If enabled then the filter will only activate when you are in combat."],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.inCombat
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.inCombat = value
								NP:ConfigureAll()
							end
						},
						outOfCombat = {
							order = 2,
							type = "toggle",
							name = L["Player Out of Combat"],
							desc = L["If enabled then the filter will only activate when you are out of combat."],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.outOfCombat
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.outOfCombat = value
								NP:ConfigureAll()
							end
						}
					}
				},
				role = {
					order = 8,
					type = "group",
					name = L["ROLE"],
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						tank = {
							order = 1,
							type = "toggle",
							name = L["TANK"],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.role.tank
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.role.tank = value
								NP:ConfigureAll()
							end,
						},
						healer = {
							order = 2,
							type = "toggle",
							name = L["HEALER"],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.role.healer
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.role.healer = value
								NP:ConfigureAll()
							end
						},
						damager = {
							order = 3,
							type = "toggle",
							name = L["DAMAGER"],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.role.damager
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.role.damager = value
								NP:ConfigureAll()
							end
						}
					}
				},
				health = {
					order = 9,
					type = "group",
					name = L["Health Threshold"],
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						enable = {
							order = 1,
							type = "toggle",
							name = L["Enable"],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.healthThreshold
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.healthThreshold = value
								NP:ConfigureAll()
							end
						},
						usePlayer = {
							order = 2,
							type = "toggle",
							name = L["Player Health"],
							desc = L["Enabling this will check your health amount."],
							disabled = function() return not E.global.nameplates.filters[selectedNameplateFilter].triggers.healthThreshold end,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.healthUsePlayer
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.healthUsePlayer = value
								NP:ConfigureAll()
							end
						},
						spacer1 = {
							order = 3,
							type = "description",
							name = " "
						},
						underHealthThreshold = {
							order = 4,
							type = "range",
							name = L["Under Health Threshold"],
							desc = L["If this threshold is used then the health of the unit needs to be lower than this value in order for the filter to activate. Set to 0 to disable."],
							min = 0, max = 1, step = 0.01,
							isPercent = true,
							disabled = function() return not E.global.nameplates.filters[selectedNameplateFilter].triggers.healthThreshold end,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.underHealthThreshold or 0
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.underHealthThreshold = value
								NP:ConfigureAll()
							end
						},
						overHealthThreshold = {
							order = 5,
							type = "range",
							name = L["Over Health Threshold"],
							desc = L["If this threshold is used then the health of the unit needs to be higher than this value in order for the filter to activate. Set to 0 to disable."],
							min = 0, max = 1, step = 0.01,
							isPercent = true,
							disabled = function() return not E.global.nameplates.filters[selectedNameplateFilter].triggers.healthThreshold end,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.overHealthThreshold or 0
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.overHealthThreshold = value
								NP:ConfigureAll()
							end
						}
					}
				},
				power = {
					order = 10,
					type = "group",
					name = L["Power Threshold"],
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						powerThreshold = {
							order = 1,
							type = "toggle",
							name = L["Enable"],
							desc = L["Enabling this will check your power amount."],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.powerThreshold
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.powerThreshold = value
								NP:ConfigureAll()
							end
						},
						spacer1 = {
							order = 2,
							type = "description",
							name = " "
						},
						underPowerThreshold = {
							order = 3,
							type = "range",
							name = L["Under Power Threshold"],
							desc = L["If this threshold is used then the power of the unit needs to be lower than this value in order for the filter to activate. Set to 0 to disable."],
							min = 0, max = 1, step = 0.01,
							isPercent = true,
							disabled = function() return not E.global.nameplates.filters[selectedNameplateFilter].triggers.powerThreshold end,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.underPowerThreshold or 0
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.underPowerThreshold = value
								NP:ConfigureAll()
							end
						},
						overPowerThreshold = {
							order = 4,
							type = "range",
							name = L["Over Power Threshold"],
							desc = L["If this threshold is used then the power of the unit needs to be higher than this value in order for the filter to activate. Set to 0 to disable."],
							min = 0, max = 1, step = 0.01,
							isPercent = true,
							disabled = function() return not E.global.nameplates.filters[selectedNameplateFilter].triggers.powerThreshold end,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.overPowerThreshold or 0
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.overPowerThreshold = value
								NP:ConfigureAll()
							end
						}
					}
				},
				levels = {
					order = 11,
					type = "group",
					name = L["LEVEL"],
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						enable = {
							order = 1,
							type = "toggle",
							name = L["Enable"],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.level
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.level = value
								NP:ConfigureAll()
							end
						},
						matchLevel = {
							order = 2,
							type = "toggle",
							name = L["Match Player Level"],
							desc = L["If enabled then the filter will only activate if the level of the unit matches your own."],
							disabled = function() return not E.global.nameplates.filters[selectedNameplateFilter].triggers.level end,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.mylevel
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.mylevel = value
								NP:ConfigureAll()
							end
						},
						spacer1 = {
							order = 3,
							type = "description",
							name = L["LEVEL_BOSS"],
						},
						minLevel = {
							order = 4,
							type = "range",
							name = L["Minimum Level"],
							desc = L["If enabled then the filter will only activate if the level of the unit is equal to or higher than this value."],
							min = -1, max = MAX_PLAYER_LEVEL+3, step = 1,
							disabled = function() return not (E.global.nameplates.filters[selectedNameplateFilter].triggers.level and not E.global.nameplates.filters[selectedNameplateFilter].triggers.mylevel) end,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.minlevel or 0
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.minlevel = value
								NP:ConfigureAll()
							end
						},
						maxLevel = {
							order = 5,
							type = "range",
							name = L["Maximum Level"],
							desc = L["If enabled then the filter will only activate if the level of the unit is equal to or lower than this value."],
							min = -1, max = MAX_PLAYER_LEVEL+3, step = 1,
							disabled = function() return not (E.global.nameplates.filters[selectedNameplateFilter].triggers.level and not E.global.nameplates.filters[selectedNameplateFilter].triggers.mylevel) end,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.maxlevel or 0
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.maxlevel = value
								NP:ConfigureAll()
							end
						},
						currentLevel = {
							order = 6,
							type = "range",
							name = L["Current Level"],
							desc = L["If enabled then the filter will only activate if the level of the unit matches this value."],
							min = -1, max = MAX_PLAYER_LEVEL+3, step = 1,
							disabled = function() return not (E.global.nameplates.filters[selectedNameplateFilter].triggers.level and not E.global.nameplates.filters[selectedNameplateFilter].triggers.mylevel) end,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.curlevel or 0
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.curlevel = value
								NP:ConfigureAll()
							end
						}
					}
				},
				cooldowns = {
					order = 12,
					type = "group",
					name = L["Cooldowns"],
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						mustHaveAll = {
							order = 1,
							type = "toggle",
							name = L["Require All"],
							desc = L["If enabled then it will require all cooldowns to activate the filter. Otherwise it will only require any one of the cooldowns to activate it."],
							disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.cooldowns and E.global.nameplates.filters[selectedNameplateFilter].triggers.cooldowns.mustHaveAll
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.cooldowns.mustHaveAll = value
								NP:ConfigureAll()
							end
						},
						spacer1 = {
							order = 5,
							type = "description",
							name = " "
						},
						addCooldown = {
							order = 6,
							type = "input",
							name = L["Add Spell ID or Name"],
							get = function(info) return "" end,
							set = function(info, value)
								if match(value, "^[%s%p]-$") then
									return
								end
								E.global.nameplates.filters[selectedNameplateFilter].triggers.cooldowns.names[value] = "ONCD"
								UpdateFilterGroup()
								NP:ConfigureAll()
							end
						},
						removeCooldown = {
							order = 7,
							type = "input",
							name = L["Remove Spell ID or Name"],
							desc = L["If the aura is listed with a number then you need to use that to remove it from the list."],
							get = function(info) return "" end,
							set = function(info, value)
								if match(value, "^[%s%p]-$") then
									return
								end
								E.global.nameplates.filters[selectedNameplateFilter].triggers.cooldowns.names[value] = nil
								UpdateFilterGroup()
								NP:ConfigureAll()
							end
						}
					}
				},
				buffs = {
					order = 13,
					type = "group",
					name = L["Buffs"],
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						mustHaveAll = {
							order = 1,
							type = "toggle",
							name = L["Require All"],
							desc = L["If enabled then it will require all auras to activate the filter. Otherwise it will only require any one of the auras to activate it."],
							disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs and E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs.mustHaveAll
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs.mustHaveAll = value
								NP:ConfigureAll()
							end
						},
						missing = {
							order = 2,
							type = "toggle",
							name = L["Missing"],
							desc = L["If enabled then it checks if auras are missing instead of being present on the unit."],
							disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs and E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs.missing
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs.missing = value
								NP:ConfigureAll()
							end
						},
						minTimeLeft = {
							order = 3,
							type = "range",
							name = L["Minimum Time Left"],
							desc = L["Apply this filter if a buff has remaining time greater than this. Set to zero to disable."],
							min = 0, max = 10800, step = 1,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs and E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs.minTimeLeft
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs.minTimeLeft = value
								NP:ConfigureAll()
							end
						},
						maxTimeLeft = {
							order = 4,
							type = "range",
							name = L["Maximum Time Left"],
							desc = L["Apply this filter if a buff has remaining time less than this. Set to zero to disable."],
							min = 0, max = 10800, step = 1,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs and E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs.maxTimeLeft
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs.maxTimeLeft = value
								NP:ConfigureAll()
							end
						},
						spacer1 = {
							order = 5,
							type = "description",
							name = " "
						},
						addBuff = {
							order = 6,
							type = "input",
							name = L["Add Spell ID or Name"],
							get = function(info) return "" end,
							set = function(info, value)
								if match(value, "^[%s%p]-$") then
									return
								end
								E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs.names[value] = true
								UpdateFilterGroup()
								NP:ConfigureAll()
							end
						},
						removeBuff = {
							order = 7,
							type = "input",
							name = L["Remove Spell ID or Name"],
							desc = L["If the aura is listed with a number then you need to use that to remove it from the list."],
							get = function(info) return "" end,
							set = function(info, value)
								if match(value, "^[%s%p]-$") then
									return
								end
								E.global.nameplates.filters[selectedNameplateFilter].triggers.buffs.names[value] = nil
								UpdateFilterGroup()
								NP:ConfigureAll()
							end
						}
					}
				},
				debuffs = {
					order = 14,
					type = "group",
					name = L["Debuffs"],
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						mustHaveAll = {
							order = 1,
							name = L["Require All"],
							desc = L["If enabled then it will require all auras to activate the filter. Otherwise it will only require any one of the auras to activate it."],
							type = "toggle",
							disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs and E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs.mustHaveAll
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs.mustHaveAll = value
								NP:ConfigureAll()
							end
						},
						missing = {
							order = 2,
							type = "toggle",
							name = L["Missing"],
							desc = L["If enabled then it checks if auras are missing instead of being present on the unit."],
							disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs and E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs.missing
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs.missing = value
								NP:ConfigureAll()
							end
						},
						minTimeLeft = {
							order = 3,
							type = "range",
							name = L["Minimum Time Left"],
							desc = L["Apply this filter if a debuff has remaining time greater than this. Set to zero to disable."],
							min = 0, max = 10800, step = 1,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs and E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs.minTimeLeft
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs.minTimeLeft = value
								NP:ConfigureAll()
							end
						},
						maxTimeLeft = {
							order = 4,
							type = "range",
							name = L["Maximum Time Left"],
							desc = L["Apply this filter if a debuff has remaining time less than this. Set to zero to disable."],
							min = 0, max = 10800, step = 1,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs and E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs.maxTimeLeft
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs.maxTimeLeft = value
								NP:ConfigureAll()
							end
						},
						spacer1 = {
							order = 5,
							type = "description",
							name = " "
						},
						addDebuff = {
							order = 6,
							type = "input",
							name = L["Add Spell ID or Name"],
							get = function(info) return "" end,
							set = function(info, value)
								if match(value, "^[%s%p]-$") then
									return
								end
								E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs.names[value] = true
								UpdateFilterGroup()
								NP:ConfigureAll()
							end
						},
						removeDebuff = {
							order = 7,
							type = "input",
							name = L["Remove Spell ID or Name"],
							desc = L["If the aura is listed with a number then you need to use that to remove it from the list."],
							get = function(info) return "" end,
							set = function(info, value)
								if match(value, "^[%s%p]-$") then
									return
								end
								E.global.nameplates.filters[selectedNameplateFilter].triggers.debuffs.names[value] = nil
								UpdateFilterGroup()
								NP:ConfigureAll()
							end
						}
					}
				},
				nameplateType = {
					order = 15,
					type = "group",
					name = L["Unit Type"],
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						enable = {
							order = 0,
							type = "toggle",
							name = L["Enable"],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.nameplateType and E.global.nameplates.filters[selectedNameplateFilter].triggers.nameplateType.enable
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.nameplateType.enable = value
								NP:ConfigureAll()
							end
						},
						types = {
							order = 1,
							type = "group",
							name = "",
							guiInline = true,
							disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) or not E.global.nameplates.filters[selectedNameplateFilter].triggers.nameplateType.enable end,
							args = {
								friendlyPlayer = {
									order = 1,
									type = "toggle",
									name = L["FRIENDLY_PLAYER"],
									get = function(info)
										return E.global.nameplates.filters[selectedNameplateFilter].triggers.nameplateType.friendlyPlayer
									end,
									set = function(info, value)
										E.global.nameplates.filters[selectedNameplateFilter].triggers.nameplateType.friendlyPlayer = value
										NP:ConfigureAll()
									end
								},
								friendlyNPC = {
									order = 2,
									type = "toggle",
									name = L["FRIENDLY_NPC"],
									get = function(info)
										return E.global.nameplates.filters[selectedNameplateFilter].triggers.nameplateType.friendlyNPC
									end,
									set = function(info, value)
										E.global.nameplates.filters[selectedNameplateFilter].triggers.nameplateType.friendlyNPC = value
										NP:ConfigureAll()
									end
								},
								enemyPlayer = {
									order = 3,
									type = "toggle",
									name = L["ENEMY_PLAYER"],
									get = function(info)
										return E.global.nameplates.filters[selectedNameplateFilter].triggers.nameplateType.enemyPlayer
									end,
									set = function(info, value)
										E.global.nameplates.filters[selectedNameplateFilter].triggers.nameplateType.enemyPlayer = value
										NP:ConfigureAll()
									end
								},
								enemyNPC = {
									order = 4,
									type = "toggle",
									name = L["ENEMY_NPC"],
									get = function(info)
										return E.global.nameplates.filters[selectedNameplateFilter].triggers.nameplateType.enemyNPC
									end,
									set = function(info, value)
										E.global.nameplates.filters[selectedNameplateFilter].triggers.nameplateType.enemyNPC = value
										NP:ConfigureAll()
									end
								}
							}
						}
					}
				},
				reactionType = {
					order = 16,
					type = "group",
					name = L["Reaction Type"],
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						enable = {
							order = 0,
							type = "toggle",
							name = L["Enable"],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.reactionType and E.global.nameplates.filters[selectedNameplateFilter].triggers.reactionType.enable
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.reactionType.enable = value
								NP:ConfigureAll()
							end
						},
						types = {
							order = 1,
							type = "group",
							name = "",
							guiInline = true,
							disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) or not E.global.nameplates.filters[selectedNameplateFilter].triggers.reactionType.enable end,
							args = {
								hostile = {
									order = 1,
									type = "toggle",
									name = L["FACTION_STANDING_LABEL2"],
									get = function(info)
										return E.global.nameplates.filters[selectedNameplateFilter].triggers.reactionType.hostile
									end,
									set = function(info, value)
										E.global.nameplates.filters[selectedNameplateFilter].triggers.reactionType.hostile = value
										NP:ConfigureAll()
									end
								},
								neutral = {
									order = 2,
									type = "toggle",
									name = L["FACTION_STANDING_LABEL4"],
									get = function(info)
										return E.global.nameplates.filters[selectedNameplateFilter].triggers.reactionType.neutral
									end,
									set = function(info, value)
										E.global.nameplates.filters[selectedNameplateFilter].triggers.reactionType.neutral = value
										NP:ConfigureAll()
									end
								},
								friendly = {
									order = 3,
									type = "toggle",
									name = L["FACTION_STANDING_LABEL5"],
									get = function(info)
										return E.global.nameplates.filters[selectedNameplateFilter].triggers.reactionType.friendly
									end,
									set = function(info, value)
										E.global.nameplates.filters[selectedNameplateFilter].triggers.reactionType.friendly = value
										NP:ConfigureAll()
									end
								}
							}
						}
					}
				},
				instanceType = {
					order = 17,
					type = "group",
					name = L["Instance Type"],
					disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
					args = {
						none = {
							order = 1,
							type = "toggle",
							name = L["NONE"],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.instanceType.none
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.instanceType.none = value
								NP:ConfigureAll()
							end
						},
						sanctuary = {
							order = 1,
							type = "toggle",
							name = L["Sanctuary"],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.instanceType.sanctuary
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.instanceType.sanctuary = value
								NP:ConfigureAll()
							end
						},
						party = {
							order = 2,
							type = "toggle",
							name = L["DUNGEONS"],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.instanceType.party
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.instanceType.party = value
								UpdateInstanceDifficulty()
								NP:ConfigureAll()
							end
						},
						raid = {
							order = 3,
							type = "toggle",
							name = L["RAID"],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.instanceType.raid
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.instanceType.raid = value
								UpdateInstanceDifficulty()
								NP:ConfigureAll()
							end
						},
						arena = {
							order = 4,
							type = "toggle",
							name = L["ARENA"],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.instanceType.arena
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.instanceType.arena = value
								NP:ConfigureAll()
							end
						},
						pvp = {
							order = 5,
							type = "toggle",
							name = L["BATTLEFIELDS"],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.instanceType.pvp
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.instanceType.pvp = value
								NP:ConfigureAll()
							end
						}
					}
				},
				raidTarget = {
					order = 27,
					type = "group",
					name = L["BINDING_HEADER_RAID_TARGET"],
					get = function(info)
						return E.global.nameplates.filters[selectedNameplateFilter].triggers.raidTarget[info[#info]]
					end,
					set = function(info, value)
						E.global.nameplates.filters[selectedNameplateFilter].triggers.raidTarget[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = function()
						return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
							E.db.nameplates.filters[selectedNameplateFilter].triggers and
							E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
					args = {
						types = {
							name = "",
							type = "group",
							guiInline = true,
							order = 2,
							args = {
								star = {
									type = "toggle",
									order = 1,
									name = format(raidTargetIcon, 1, L["RAID_TARGET_1"])
								},
								circle = {
									type = "toggle",
									order = 2,
									name = format(raidTargetIcon, 2, L["RAID_TARGET_2"])
								},
								diamond = {
									type = "toggle",
									order = 3,
									name = format(raidTargetIcon, 3, L["RAID_TARGET_3"])
								},
								triangle = {
									type = "toggle",
									order = 4,
									name = format(raidTargetIcon, 4, L["RAID_TARGET_4"])
								},
								moon = {
									type = "toggle",
									order = 5,
									name = format(raidTargetIcon, 5, L["RAID_TARGET_5"])
								},
								square = {
									type = "toggle",
									order = 6,
									name = format(raidTargetIcon, 6, L["RAID_TARGET_6"])
								},
								cross = {
									type = "toggle",
									order = 7,
									name = format(raidTargetIcon, 7, L["RAID_TARGET_7"])
								},
								skull = {
									type = "toggle",
									order = 8,
									name = format(raidTargetIcon, 8, L["RAID_TARGET_8"])
								}
							}
						}
					}
				},
				totems = {
					order = 28,
					type = "group",
					name = L["Totem"],
					get = function(info)
						return E.global.nameplates.filters[selectedNameplateFilter].triggers.totems[info[#info]]
					end,
					set = function(info, value)
						E.global.nameplates.filters[selectedNameplateFilter].triggers.totems[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = function()
						return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
							E.db.nameplates.filters[selectedNameplateFilter].triggers and
							E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
					args = {
						enable = {
							order = 0,
							type = "toggle",
							name = L["Enable"],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.totems and E.global.nameplates.filters[selectedNameplateFilter].triggers.totems.enable
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.totems.enable = value
								NP:ConfigureAll()
							end
						}
					}
				},
				uniqueUnits = {
					order = 28,
					type = "group",
					name = L["Unique Units"],
					get = function(info)
						return E.global.nameplates.filters[selectedNameplateFilter].triggers.uniqueUnits[info[#info]]
					end,
					set = function(info, value)
						E.global.nameplates.filters[selectedNameplateFilter].triggers.uniqueUnits[info[#info]] = value
						NP:ConfigureAll()
					end,
					disabled = function()
						return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and
							E.db.nameplates.filters[selectedNameplateFilter].triggers and
							E.db.nameplates.filters[selectedNameplateFilter].triggers.enable)
					end,
					args = {
						enable = {
							order = 0,
							type = "toggle",
							name = L["Enable"],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].triggers.uniqueUnits and E.global.nameplates.filters[selectedNameplateFilter].triggers.uniqueUnits.enable
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].triggers.uniqueUnits.enable = value
								NP:ConfigureAll()
							end
						}
					}
				}
			}
		}
		E.Options.args.nameplate.args.filters.args.actions = {
			order = 6,
			type = "group",
			name = L["Actions"],
			disabled = function() return not (E.db.nameplates and E.db.nameplates.filters and E.db.nameplates.filters[selectedNameplateFilter] and E.db.nameplates.filters[selectedNameplateFilter].triggers and E.db.nameplates.filters[selectedNameplateFilter].triggers.enable) end,
			args = {
				hide = {
					order = 1,
					type = "toggle",
					name = L["Hide Frame"],
					get = function(info)
						return E.global.nameplates.filters[selectedNameplateFilter].actions.hide
					end,
					set = function(info, value)
						E.global.nameplates.filters[selectedNameplateFilter].actions.hide = value
						NP:ConfigureAll()
					end
				},
				nameOnly = {
					order = 2,
					type = "toggle",
					name = L["Name Only"],
					get = function(info)
						return E.global.nameplates.filters[selectedNameplateFilter].actions.nameOnly
					end,
					set = function(info, value)
						E.global.nameplates.filters[selectedNameplateFilter].actions.nameOnly = value
						NP:ConfigureAll()
					end,
					disabled = function() return E.global.nameplates.filters[selectedNameplateFilter].actions.hide end
				},
				icon = {
					order = 3,
					type = "toggle",
					name = L["Icon"],
					get = function(info)
						return E.global.nameplates.filters[selectedNameplateFilter].actions.icon
					end,
					set = function(info, value)
						E.global.nameplates.filters[selectedNameplateFilter].actions.icon = value
						NP:ConfigureAll()
					end,
					disabled = function()
						return E.global.nameplates.filters[selectedNameplateFilter].actions.hide or not (E.global.nameplates.filters[selectedNameplateFilter].triggers.totems.enable or E.global.nameplates.filters[selectedNameplateFilter].triggers.uniqueUnits.enable)
					end
				},
				iconOnly = {
					order = 3,
					type = "toggle",
					name = L["Icon Only"],
					get = function(info)
						return E.global.nameplates.filters[selectedNameplateFilter].actions.iconOnly
					end,
					set = function(info, value)
						E.global.nameplates.filters[selectedNameplateFilter].actions.iconOnly = value
						NP:ConfigureAll()
					end,
					disabled = function()
						return E.global.nameplates.filters[selectedNameplateFilter].actions.hide or not (E.global.nameplates.filters[selectedNameplateFilter].triggers.totems.enable or E.global.nameplates.filters[selectedNameplateFilter].triggers.uniqueUnits.enable)
					end
				},
				spacer1 = {
					order = 4,
					type = "description",
					name = " "
				},
				scale = {
					order = 5,
					type = "range",
					name = L["Scale"],
					disabled = function() return E.global.nameplates.filters[selectedNameplateFilter].actions.hide end,
					get = function(info)
						return E.global.nameplates.filters[selectedNameplateFilter].actions.scale or 1
					end,
					set = function(info, value)
						E.global.nameplates.filters[selectedNameplateFilter].actions.scale = value
						NP:ConfigureAll()
					end,
					min = 0.35, max = 1.5, step = 0.01
				},
				alpha = {
					order = 6,
					type = "range",
					name = L["Alpha"],
					disabled = function() return E.global.nameplates.filters[selectedNameplateFilter].actions.hide end,
					get = function(info)
						return E.global.nameplates.filters[selectedNameplateFilter].actions.alpha or -1
					end,
					set = function(info, value)
						E.global.nameplates.filters[selectedNameplateFilter].actions.alpha = value
						NP:ConfigureAll()
					end,
					min = -1, max = 100, step = 1
				},
				frameLevel = {
					order = 7,
					name = L["Frame Level"],
					desc = L["NAMEPLATE_FRAMELEVEL_DESC"],
					type = "range",
					min = 0, max = 10, step = 1,
					disabled = function() return E.global.nameplates.filters[selectedNameplateFilter].actions.hide end,
					get = function(info) return E.global.nameplates.filters[selectedNameplateFilter].actions.frameLevel or 0 end,
					set = function(info, value)
						E.global.nameplates.filters[selectedNameplateFilter].actions.frameLevel = value
						NP:ConfigureAll()
					end,
				},
				color = {
					order = 10,
					type = "group",
					name = L["COLOR"],
					guiInline = true,
					disabled = function() return E.global.nameplates.filters[selectedNameplateFilter].actions.hide end,
					args = {
						health = {
							order = 1,
							type = "toggle",
							name = L["HEALTH"],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].actions.color.health
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].actions.color.health = value
								NP:ConfigureAll()
							end
						},
						healthColor = {
							order = 2,
							type = "color",
							name = L["Health Color"],
							hasAlpha = true,
							disabled = function() return not E.global.nameplates.filters[selectedNameplateFilter].actions.color.health end,
							get = function(info)
								local t = E.global.nameplates.filters[selectedNameplateFilter].actions.color.healthColor
								return t.r, t.g, t.b, t.a, 136/255, 255/255, 102/255, 1
							end,
							set = function(info, r, g, b, a)
								local t = E.global.nameplates.filters[selectedNameplateFilter].actions.color.healthColor
								t.r, t.g, t.b, t.a = r, g, b, a
								NP:ConfigureAll()
							end
						},
						spacer1 = {
							order = 3,
							type = "description",
							name = " ",
						},
						border = {
							order = 4,
							type = "toggle",
							name = L["Border"],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].actions.color.border
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].actions.color.border = value
								NP:ConfigureAll()
							end
						},
						borderColor = {
							order = 5,
							type = "color",
							name = L["Border Color"],
							hasAlpha = true,
							disabled = function() return not E.global.nameplates.filters[selectedNameplateFilter].actions.color.border end,
							get = function(info)
								local t = E.global.nameplates.filters[selectedNameplateFilter].actions.color.borderColor
								return t.r, t.g, t.b, t.a, 0, 0, 0, 1
							end,
							set = function(info, r, g, b, a)
								local t = E.global.nameplates.filters[selectedNameplateFilter].actions.color.borderColor
								t.r, t.g, t.b, t.a = r, g, b, a
								NP:ConfigureAll()
							end
						},
						spacer2 = {
							order = 6,
							type = "description",
							name = " "
						},
						name = {
							order = 7,
							type = "toggle",
							name = L["NAME"],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].actions.color.name
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].actions.color.name = value
								NP:ConfigureAll()
							end
						},
						nameColor = {
							order = 8,
							type = "color",
							name = L["Name Color"],
							hasAlpha = true,
							disabled = function() return not E.global.nameplates.filters[selectedNameplateFilter].actions.color.name end,
							get = function(info)
								local t = E.global.nameplates.filters[selectedNameplateFilter].actions.color.nameColor
								return t.r, t.g, t.b, t.a, 200/255, 200/255, 200/255, 1
							end,
							set = function(info, r, g, b, a)
								local t = E.global.nameplates.filters[selectedNameplateFilter].actions.color.nameColor
								t.r, t.g, t.b, t.a = r, g, b, a
								NP:ConfigureAll()
							end
						}
					}
				},
				texture = {
					order = 20,
					type = "group",
					name = L["Texture"],
					guiInline = true,
					disabled = function() return E.global.nameplates.filters[selectedNameplateFilter].actions.hide end,
					args = {
						enable = {
							order = 1,
							type = "toggle",
							name = L["Enable"],
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].actions.texture.enable
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].actions.texture.enable = value
								NP:ConfigureAll()
							end
						},
						texture = {
							order = 2,
							type = "select",
							dialogControl = "LSM30_Statusbar",
							name = L["Texture"],
							values = AceGUIWidgetLSMlists.statusbar,
							disabled = function() return not E.global.nameplates.filters[selectedNameplateFilter].actions.texture.enable end,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].actions.texture.texture
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].actions.texture.texture = value
								NP:ConfigureAll()
							end
						}
					}
				},
				flashing = {
					order = 30,
					type = "group",
					name = L["Flash"],
					guiInline = true,
					disabled = function() return E.global.nameplates.filters[selectedNameplateFilter].actions.hide end,
					args = {
						enable = {
							name = L["Enable"],
							order = 1,
							type = "toggle",
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].actions.flash.enable
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].actions.flash.enable = value
								NP:ConfigureAll()
							end
						},
						speed = {
							order = 2,
							type = "range",
							name = L["SPEED"],
							disabled = function() return E.global.nameplates.filters[selectedNameplateFilter].actions.hide end,
							get = function(info)
								return E.global.nameplates.filters[selectedNameplateFilter].actions.flash.speed or 4
							end,
							set = function(info, value)
								E.global.nameplates.filters[selectedNameplateFilter].actions.flash.speed = value
								NP:ConfigureAll()
							end,
							min = 1, max = 10, step = 1
						},
						color = {
							order = 3,
							type = "color",
							name = L["COLOR"],
							hasAlpha = true,
							disabled = function() return E.global.nameplates.filters[selectedNameplateFilter].actions.hide end,
							get = function(info)
								local t = E.global.nameplates.filters[selectedNameplateFilter].actions.flash.color
								return t.r, t.g, t.b, t.a, 104/255, 138/255, 217/255, 1
							end,
							set = function(info, r, g, b, a)
								local t = E.global.nameplates.filters[selectedNameplateFilter].actions.flash.color
								t.r, t.g, t.b, t.a = r, g, b, a
								NP:ConfigureAll()
							end
						}
					}
				}
			}
		}

		UpdateInstanceDifficulty()
		UpdateStyleLists()
	end
end

local ORDER = 100
local function GetUnitSettings(unit, name)
	local copyValues = {}
	for x, y in pairs(NP.db.units) do
		if type(y) == "table" and x ~= unit then
			copyValues[x] = L[x]
		end
	end
	local group = {
		order = ORDER,
		type = "group",
		name = name,
		childGroups = "tab",
		get = function(info) return E.db.nameplates.units[unit][info[#info]] end,
		set = function(info, value) E.db.nameplates.units[unit][info[#info]] = value NP:ConfigureAll() end,
		disabled = function() return not E.NamePlates.Initialized end,
		args = {
			showTestFrame = {
				order = -10,
				name = L["Show/Hide Test Frame"],
				type = "execute",
				func = function(info)
					NP:TogleTestFrame(unit)
				end
			},
			copySettings = {
				order = -9,
				type = "select",
				name = L["Copy Settings From"],
				desc = L["Copy settings from another unit."],
				values = copyValues,
				get = function() return "" end,
				set = function(info, value)
					NP:CopySettings(value, unit)
					NP:ConfigureAll()
				end
			},
			defaultSettings = {
				order = -8,
				type = "execute",
				name = L["Default Settings"],
				desc = L["Set Settings to Default"],
				func = function(info)
					NP:ResetSettings(unit)
					NP:ConfigureAll()
				end
			},
			healthGroup = {
				order = 1,
				type = "group",
				name = L["HEALTH"],
				get = function(info) return E.db.nameplates.units[unit].health[info[#info]] end,
				set = function(info, value) E.db.nameplates.units[unit].health[info[#info]] = value NP:ConfigureAll() end,
				args = {
					header = {
						order = 1,
						type = "header",
						name = L["HEALTH"]
					},
					enable = {
						order = 2,
						type = "toggle",
						name = L["Enable"]
					},
					height = {
						order = 3,
						type = "range",
						name = L["Height"],
						min = 4, max = 20, step = 1
					},
					width = {
						order = 4,
						type = "range",
						name = L["Width"],
						min = 50, max = 200, step = 1
					},
					textGroup = {
						order = 5,
						type = "group",
						name = L["Text"],
						guiInline = true,
						get = function(info)
							return E.db.nameplates.units[unit].health.text[info[#info]]
						end,
						set = function(info, value)
							E.db.nameplates.units[unit].health.text[info[#info]] = value
							NP:ConfigureAll()
						end,
						args = {
							enable = {
								order = 1,
								type = "toggle",
								name = L["Enable"]
							},
							format = {
								order = 2,
								type = "select",
								name = L["Format"],
								values = {
									["CURRENT"] = L["Current"],
									["CURRENT_MAX"] = L["Current / Max"],
									["CURRENT_PERCENT"] = L["Current - Percent"],
									["CURRENT_MAX_PERCENT"] = L["Current - Max | Percent"],
									["PERCENT"] = L["Percent"],
									["DEFICIT"] = L["Deficit"]
								}
							},
							position = {
								order = 3,
								type = "select",
								name = L["Position"],
								values = {
									["CENTER"] = "CENTER",
									["TOPLEFT"] = "TOPLEFT",
									["BOTTOMLEFT"] = "BOTTOMLEFT",
									["TOPRIGHT"] = "TOPRIGHT",
									["BOTTOMRIGHT"] = "BOTTOMRIGHT"
								}
							},
							parent = {
								order = 4,
								type = "select",
								name = L["Parent"],
								values = {
									["Nameplate"] = L["Nameplate"],
									["Health"] = L["Health"]
								}
							},
							xOffset = {
								order = 5,
								type = "range",
								name = L["X-Offset"],
								min = -100, max = 100, step = 1
							},
							yOffset = {
								order = 6,
								type = "range",
								name = L["Y-Offset"],
								min = -100, max = 100, step = 1
							},
							fontGroup = {
								type = "group",
								order = 7,
								name = L["Fonts"],
								guiInline = true,
								get = function(info)
									return E.db.nameplates.units[unit].health.text[info[#info]]
								end,
								set = function(info, value)
									E.db.nameplates.units[unit].health.text[info[#info]] = value
									NP:ConfigureAll()
								end,
								args = {
									font = {
										order = 1,
										type = "select",
										name = L["Font"],
										dialogControl = "LSM30_Font",
										values = AceGUIWidgetLSMlists.font
									},
									fontSize = {
										order = 2,
										name = L["FONT_SIZE"],
										type = "range",
										min = 4, max = 32, step = 1
									},
									fontOutline = {
										order = 3,
										type = "select",
										name = L["Font Outline"],
										desc = L["Set the font outline."],
										values = C.Values.FontFlags
									}
								}
							}
						}
					}
				}
			},
			castGroup = {
				order = 2,
				type = "group",
				name = L["Cast Bar"],
				get = function(info) return E.db.nameplates.units[unit].castbar[info[#info]] end,
				set = function(info, value) E.db.nameplates.units[unit].castbar[info[#info]] = value; NP:ConfigureAll() end,
				args = {
					header = {
						order = 0,
						type = "header",
						name = L["Cast Bar"]
					},
					enable = {
						order = 1,
						type = "toggle",
						name = L["Enable"]
					},
					timeToHold = {
						order = 2,
						type = "range",
						name = L["Time To Hold"],
						desc = L["How many seconds the castbar should stay visible after the cast failed or was interrupted."],
						min = 0, max = 4, step = 0.1
					},
					width = {
						order = 3,
						type = "range",
						name = L["Width"],
						min = 50, max = 250, step = 1
					},
					height = {
						order = 4,
						type = "range",
						name = L["Height"],
						min = 4, max = 20, step = 1
					},
					xOffset = {
						order = 5,
						type = "range",
						name = L["X-Offset"],
						min = -100, max = 100, step = 1
					},
					yOffset = {
						order = 6,
						type = "range",
						name = L["Y-Offset"],
						min = -100, max = 100, step = 1
					},
					textGroup = {
						order = 7,
						type = "group",
						name = L["Text"],
						get = function(info)
							return E.db.nameplates.units[unit].castbar[info[#info]]
						end,
						set = function(info, value)
							E.db.nameplates.units[unit].castbar[info[#info]] = value
							NP:ConfigureAll()
						end,
						guiInline = true,
						args = {
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
							textPosition = {
								order = 3,
								type = "select",
								name = L["Text Position"],
								values = {
									["ONBAR"] = L["Cast Bar"],
									["ABOVE"] = L["Above"],
									["BELOW"] = L["Below"]
								}
							},
							castTimeFormat = {
								order = 4,
								type = "select",
								name = L["Cast Time Format"],
								values = {
									["CURRENT"] = L["Current"],
									["CURRENTMAX"] = L["Current / Max"],
									["REMAINING"] = L["Remaining"],
									["REMAININGMAX"] = L["Remaining / Max"]
								}
							},
							channelTimeFormat = {
								order = 5,
								type = "select",
								name = L["Channel Time Format"],
								values = {
									["CURRENT"] = L["Current"],
									["CURRENTMAX"] = L["Current / Max"],
									["REMAINING"] = L["Remaining"],
									["REMAININGMAX"] = L["Remaining / Max"]
								}
							}
						}
					},
					iconGroup = {
						order = 8,
						name = L["Icon"],
						type = "group",
						get = function(info)
							return E.db.nameplates.units[unit].castbar[info[#info]]
						end,
						set = function(info, value)
							E.db.nameplates.units[unit].castbar[info[#info]] = value
							NP:ConfigureAll()
						end,
						guiInline = true,
						args = {
							showIcon = {
								order = 11,
								type = "toggle",
								name = L["Show Icon"]
							},
							iconPosition = {
								order = 12,
								type = "select",
								name = L["Icon Position"],
								values = {
									["LEFT"] = L["Left"],
									["RIGHT"] = L["Right"]
								}
							},
							iconSize = {
								order = 13,
								name = L["Icon Size"],
								type = "range",
								min = 4, max = 40, step = 1
							},
							iconOffsetX = {
								order = 14,
								name = L["X-Offset"],
								type = "range",
								min = -100, max = 100, step = 1
							},
							iconOffsetY = {
								order = 15,
								name = L["Y-Offset"],
								type = "range",
								min = -100, max = 100, step = 1
							}
						}
					},
					fontGroup = {
						type = "group",
						order = 30,
						name = L["Font"],
						guiInline = true,
						get = function(info)
							return E.db.nameplates.units[unit].castbar[info[#info]]
						end,
						set = function(info, value)
							E.db.nameplates.units[unit].castbar[info[#info]] = value
							NP:ConfigureAll()
						end,
						args = {
							font = {
								order = 1,
								type = "select",
								name = L["Font"],
								dialogControl = "LSM30_Font",
								values = AceGUIWidgetLSMlists.font
							},
							fontSize = {
								order = 2,
								name = L["FONT_SIZE"],
								type = "range",
								min = 4, max = 60, step = 1
							},
							fontOutline = {
								order = 3,
								type = "select",
								name = L["Font Outline"],
								desc = L["Set the font outline."],
								values = C.Values.FontFlags
							}
						}
					}
				}
			},
			buffsGroup = {
				order = 3,
				type = "group",
				name = L["Buffs"],
				get = function(info)
					return E.db.nameplates.units[unit].buffs[info[#info]]
				end,
				set = function(info, value)
					E.db.nameplates.units[unit].buffs[info[#info]] = value
					NP:ConfigureAll()
				end,
				args = {
					header = {
						order = 0,
						type = "header",
						name = L["Buffs"]
					},
					enable = {
						order = 1,
						type = "toggle",
						name = L["Enable"]
					},
					perrow = {
						order = 2,
						type = "range",
						name = L["Per Row"],
						min = 1, max = 20, step = 1,
					},
					numrows = {
						order = 3,
						type = "range",
						name = L["Num Rows"],
						min = 1, max = 10, step = 1
					},
					size = {
						order = 4,
						type = "range",
						name = L["Icon Size"],
						min = 6, max = 60, step = 1
					},
					spacing = {
						order = 5,
						type = "range",
						name = L["Spacing"],
						min = 0, max = 60, step = 1
					},
					xOffset = {
						order = 6,
						type = "range",
						name = L["X-Offset"],
						min = -100, max = 100, step = 1
					},
					yOffset = {
						order = 7,
						type = "range",
						name = L["Y-Offset"],
						min = -100, max = 100, step = 1
					},
					anchorPoint = {
						order = 8,
						type = "select",
						name = L["Anchor Point"],
						desc = L["What point to anchor to the frame you set to attach to."],
						values = positionValues
					},
					attachTo = {
						order = 9,
						type = "select",
						name = L["Attach To"],
						values = {
							["FRAME"] = L["Nameplate"]
						}
					},
					growthX = {
						order = 10,
						type = "select",
						name = L["Growth X-Direction"],
						values = {
							["LEFT"] = L["Left"],
							["RIGHT"] = L["Right"]
						}
					},
					growthY = {
						order = 11,
						type = "select",
						name = L["Growth Y-Direction"],
						values = {
							["UP"] = L["Up"],
							["DOWN"] = L["Down"]
						}
					},
					cooldownOrientation = {
						order = 12,
						type = "select",
						name = L["Cooldown Orientation"],
						values = {
							["VERTICAL"] = L["Vertical"],
							["HORIZONTAL"] = L["Horizontal"]
						}
					},
					reverseCooldown = {
						order = 13,
						type = "toggle",
						name = L["Reverse Cooldown"],
					},
					stacks = {
						order = 14,
						type = "group",
						name = L["Stack Counter"],
						guiInline = true,
						get = function(info, value)
							return E.db.nameplates.units[unit].buffs[info[#info]]
						end,
						set = function(info, value)
							E.db.nameplates.units[unit].buffs[info[#info]] = value
							NP:ConfigureAll()
						end,
						args = {
							countFont = {
								order = 1,
								type = "select",
								name = L["Font"],
								dialogControl = "LSM30_Font",
								values = AceGUIWidgetLSMlists.font
							},
							countFontSize = {
								order = 2,
								name = L["FONT_SIZE"],
								type = "range",
								min = 4, max = 20, step = 1 -- max 20 cause otherwise it looks weird
							},
							countFontOutline = {
								order = 3,
								type = "select",
								name = L["Font Outline"],
								desc = L["Set the font outline."],
								values = C.Values.FontFlags
							},
							countPosition = {
								order = 4,
								type = "select",
								name = L["Position"],
								values = {
									["TOP"] = "TOP",
									["LEFT"] = "LEFT",
									["BOTTOM"] = "BOTTOM",
									["CENTER"] = "CENTER",
									["TOPLEFT"] = "TOPLEFT",
									["BOTTOMLEFT"] = "BOTTOMLEFT",
									["BOTTOMRIGHT"] = "BOTTOMRIGHT",
									["RIGHT"] = "RIGHT",
									["TOPRIGHT"] = "TOPRIGHT"
								}
							},
							countXOffset = {
								order = 5,
								name = L["X-Offset"],
								type = "range",
								min = -100, max = 100, step = 1
							},
							countYOffset = {
								order = 6,
								name = L["Y-Offset"],
								type = "range",
								min = -100, max = 100, step = 1
							}
						}
					},
					duration = {
						order = 15,
						type = "group",
						name = L["Duration"],
						guiInline = true,
						get = function(info)
							return E.db.nameplates.units[unit].buffs[info[#info]]
						end,
						set = function(info, value)
							E.db.nameplates.units[unit].buffs[info[#info]] = value
							NP:ConfigureAll()
						end,
						args = {
							durationFont = {
								order = 1,
								type = "select",
								name = L["Font"],
								dialogControl = "LSM30_Font",
								values = AceGUIWidgetLSMlists.font
							},
							durationFontSize = {
								order = 2,
								type = "range",
								name = L["FONT_SIZE"],
								min = 4, max = 20, step = 1 -- max 20 cause otherwise it looks weird
							},
							durationFontOutline = {
								order = 3,
								type = "select",
								name = L["Font Outline"],
								desc = L["Set the font outline."],
								values = C.Values.FontFlags
							},
							durationPosition = {
								order = 4,
								type = "select",
								name = L["Position"],
								values = {
									["TOP"] = "TOP",
									["LEFT"] = "LEFT",
									["BOTTOM"] = "BOTTOM",
									["CENTER"] = "CENTER",
									["TOPLEFT"] = "TOPLEFT",
									["BOTTOMLEFT"] = "BOTTOMLEFT",
									["BOTTOMRIGHT"] = "BOTTOMRIGHT",
									["RIGHT"] = "RIGHT",
									["TOPRIGHT"] = "TOPRIGHT"
								}
							},
							durationXOffset = {
								order = 5,
								name = L["X-Offset"],
								type = "range",
								min = -100, max = 100, step = 1
							},
							durationYOffset = {
								order = 6,
								name = L["Y-Offset"],
								type = "range",
								min = -100, max = 100, step = 1
							}
						}
					},
					filtersGroup = {
						order = 16,
						name = L["FILTERS"],
						type = "group",
						guiInline = true,
						get = function(info)
							return E.db.nameplates.units[unit].buffs.filters[info[#info]]
						end,
						set = function(info, value)
							E.db.nameplates.units[unit].buffs.filters[info[#info]] = value
							NP:ConfigureAll()
						end,
						args = {
							minDuration = {
								order = 1,
								type = "range",
								name = L["Minimum Duration"],
								desc = L["Don't display auras that are shorter than this duration (in seconds). Set to zero to disable."],
								min = 0, max = 10800, step = 1
							},
							maxDuration = {
								order = 2,
								type = "range",
								name = L["Maximum Duration"],
								desc = L["Don't display auras that are longer than this duration (in seconds). Set to zero to disable."],
								min = 0, max = 10800, step = 1
							},
							jumpToFilter = {
								order = 3,
								type = "execute",
								name = L["Filters Page"],
								desc = L["Shortcut to global filters."],
								func = function()
									ACD:SelectGroup("ElvUI", "filters")
								end
							},
							spacer1 = {
								order = 4,
								type = "description",
								name = " "
							},
							specialFilters = {
								order = 5,
								type = "select",
								sortByValue = true,
								name = L["Add Special Filter"],
								desc = L["These filters don't use a list of spells like the regular filters. Instead they use the WoW API and some code logic to determine if an aura should be allowed or blocked."],
								values = function()
									local filters = {}
									local list = E.global.nameplates.specialFilters
									if not (list and next(list)) then return filters end

									for filter in pairs(list) do
										filters[filter] = L[filter]
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
									local list = E.global.unitframe.aurafilters
									if not (list and next(list)) then return filters end

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
								type = "execute",
								name = L["Reset Priority"],
								desc = L["Reset filter priority to the default state."],
								func = function()
									E.db.nameplates.units[unit].buffs.filters.priority = P.nameplates.units[unit].buffs.filters.priority
									NP:ConfigureAll()
								end
							},
							filterPriority = {
								order = 8,
								type = "multiselect",
								name = L["Filter Priority"],
								dragdrop = true,
								dragOnLeave = E.noop, --keep this here
								dragOnEnter = function(info)
									carryFilterTo = info.obj.value
								end,
								dragOnMouseDown = function(info)
									carryFilterFrom, carryFilterTo = info.obj.value, nil
								end,
								dragOnMouseUp = function(info)
									filterPriority("buffs", unit, carryFilterTo, nil, carryFilterFrom) --add it in the new spot
									carryFilterFrom, carryFilterTo = nil, nil
								end,
								dragOnClick = function(info)
									filterPriority("buffs", unit, carryFilterFrom, true)
								end,
								stateSwitchGetText = function(_, text)
									local SF, localized = E.global.unitframe.specialFilters[text], L[text]
									local blockText = SF and localized and text:match("^block") and localized:gsub("^%[.-]%s?", "")
									return (blockText and format("|cFF999999%s|r %s", L["BLOCK"], blockText)) or localized or text
								end,
								stateSwitchOnClick = function()
									filterPriority("buffs", unit, carryFilterFrom, nil, nil, true)
								end,
								values = function()
									local str = E.db.nameplates.units[unit].buffs.filters.priority
									if str == "" then return {} end
									return {strsplit(",", str)}
								end,
								get = function(_, value)
									local str = E.db.nameplates.units[unit].buffs.filters.priority
									if str == "" then return end
									local tbl = {strsplit(",", str)}
									return tbl[value]
								end,
								set = function()
									NP:ConfigureAll()
								end
							},
							spacer3 = {
								order = 9,
								type = "description",
								name = L["Use drag and drop to rearrange filter priority or right click to remove a filter."] ..
									"\n" ..
										L["Use Shift+LeftClick to toggle between friendly or enemy or normal state. Normal state will allow the filter to be checked on all units. Friendly state is for friendly units only and enemy state is for enemy units."]
							}
						}
					}
				}
			},
			debuffsGroup = {
				order = 4,
				type = "group",
				name = L["Debuffs"],
				get = function(info)
					return E.db.nameplates.units[unit].debuffs[info[#info]]
				end,
				set = function(info, value)
					E.db.nameplates.units[unit].debuffs[info[#info]] = value
					NP:ConfigureAll()
				end,
				args = {
					header = {
						order = 0,
						type = "header",
						name = L["Debuffs"]
					},
					enable = {
						order = 1,
						type = "toggle",
						name = L["Enable"]
					},
					perrow = {
						order = 2,
						type = "range",
						name = L["Per Row"],
						min = 1, max = 20, step = 1,
					},
					numrows = {
						order = 3,
						type = "range",
						name = L["Num Rows"],
						min = 1, max = 10, step = 1
					},
					size = {
						order = 4,
						type = "range",
						name = L["Icon Size"],
						min = 6, max = 60, step = 1
					},
					spacing = {
						order = 5,
						type = "range",
						name = L["Spacing"],
						min = 0, max = 60, step = 1
					},
					xOffset = {
						order = 6,
						type = "range",
						name = L["X-Offset"],
						min = -100, max = 100, step = 1
					},
					yOffset = {
						order = 7,
						type = "range",
						name = L["Y-Offset"],
						min = -100, max = 100, step = 1
					},
					anchorPoint = {
						order = 8,
						type = "select",
						name = L["Anchor Point"],
						desc = L["What point to anchor to the frame you set to attach to."],
						values = positionValues
					},
					attachTo = {
						order = 9,
						type = "select",
						name = L["Attach To"],
						values = {
							["FRAME"] = L["Nameplate"],
							["BUFFS"] = L["Buffs"],
						}
					},
					growthX = {
						order = 10,
						type = "select",
						name = L["Growth X-Direction"],
						values = {
							["LEFT"] = L["Left"],
							["RIGHT"] = L["Right"]
						}
					},
					growthY = {
						order = 11,
						type = "select",
						name = L["Growth Y-Direction"],
						values = {
							["UP"] = L["Up"],
							["DOWN"] = L["Down"]
						}
					},
					cooldownOrientation = {
						order = 12,
						type = "select",
						name = L["Cooldown Orientation"],
						values = {
							["VERTICAL"] = L["Vertical"],
							["HORIZONTAL"] = L["Horizontal"]
						}
					},
					reverseCooldown = {
						order = 13,
						type = "toggle",
						name = L["Reverse Cooldown"],
					},
					stacks = {
						order = 14,
						type = "group",
						name = L["Stack Counter"],
						guiInline = true,
						get = function(info, value)
							return E.db.nameplates.units[unit].debuffs[info[#info]]
						end,
						set = function(info, value)
							E.db.nameplates.units[unit].debuffs[info[#info]] = value
							NP:ConfigureAll()
						end,
						args = {
							countFont = {
								order = 1,
								type = "select",
								name = L["Font"],
								dialogControl = "LSM30_Font",
								values = AceGUIWidgetLSMlists.font
							},
							countFontSize = {
								order = 2,
								type = "range",
								name = L["FONT_SIZE"],
								min = 4, max = 20, step = 1 -- max 20 cause otherwise it looks weird
							},
							countFontOutline = {
								order = 3,
								type = "select",
								name = L["Font Outline"],
								desc = L["Set the font outline."],
								values = C.Values.FontFlags
							},
							countPosition = {
								order = 4,
								type = "select",
								name = L["Position"],
								values = {
									["TOP"] = "TOP",
									["LEFT"] = "LEFT",
									["BOTTOM"] = "BOTTOM",
									["CENTER"] = "CENTER",
									["TOPLEFT"] = "TOPLEFT",
									["BOTTOMLEFT"] = "BOTTOMLEFT",
									["BOTTOMRIGHT"] = "BOTTOMRIGHT",
									["RIGHT"] = "RIGHT",
									["TOPRIGHT"] = "TOPRIGHT"
								}
							},
							countXOffset = {
								order = 5,
								name = L["X-Offset"],
								type = "range",
								min = -100, max = 100, step = 1
							},
							countYOffset = {
								order = 6,
								name = L["Y-Offset"],
								type = "range",
								min = -100, max = 100, step = 1
							}
						}
					},
					duration = {
						order = 15,
						type = "group",
						name = L["Duration"],
						guiInline = true,
						get = function(info)
							return E.db.nameplates.units[unit].debuffs[info[#info]]
						end,
						set = function(info, value)
							E.db.nameplates.units[unit].debuffs[info[#info]] = value
							NP:ConfigureAll()
						end,
						args = {
							durationFont = {
								order = 1,
								type = "select",
								name = L["Font"],
								dialogControl = "LSM30_Font",
								values = AceGUIWidgetLSMlists.font
							},
							durationFontSize = {
								order = 2,
								type = "range",
								name = L["FONT_SIZE"],
								min = 4, max = 20, step = 1 -- max 20 cause otherwise it looks weird
							},
							durationFontOutline = {
								order = 3,
								type = "select",
								name = L["Font Outline"],
								desc = L["Set the font outline."],
								values = C.Values.FontFlags
							},
							durationPosition = {
								order = 4,
								type = "select",
								name = L["Position"],
								values = {
									["TOP"] = "TOP",
									["LEFT"] = "LEFT",
									["BOTTOM"] = "BOTTOM",
									["CENTER"] = "CENTER",
									["TOPLEFT"] = "TOPLEFT",
									["BOTTOMLEFT"] = "BOTTOMLEFT",
									["BOTTOMRIGHT"] = "BOTTOMRIGHT",
									["RIGHT"] = "RIGHT",
									["TOPRIGHT"] = "TOPRIGHT"
								}
							},
							durationXOffset = {
								order = 5,
								name = L["X-Offset"],
								type = "range",
								min = -100, max = 100, step = 1
							},
							durationYOffset = {
								order = 6,
								name = L["Y-Offset"],
								type = "range",
								min = -100, max = 100, step = 1
							}
						}
					},
					filtersGroup = {
						order = 16,
						type = "group",
						name = L["FILTERS"],
						get = function(info)
							return E.db.nameplates.units[unit].debuffs.filters[info[#info]]
						end,
						set = function(info, value)
							E.db.nameplates.units[unit].debuffs.filters[info[#info]] = value
							NP:ConfigureAll()
						end,
						guiInline = true,
						args = {
							minDuration = {
								order = 1,
								type = "range",
								name = L["Minimum Duration"],
								desc = L["Don't display auras that are shorter than this duration (in seconds). Set to zero to disable."],
								min = 0, max = 10800, step = 1
							},
							maxDuration = {
								order = 2,
								type = "range",
								name = L["Maximum Duration"],
								desc = L["Don't display auras that are longer than this duration (in seconds). Set to zero to disable."],
								min = 0, max = 10800, step = 1
							},
							jumpToFilter = {
								order = 3,
								type = "execute",
								name = L["Filters Page"],
								desc = L["Shortcut to global filters."],
								func = function()
									ACD:SelectGroup("ElvUI", "filters")
								end
							},
							spacer1 = {
								order = 4,
								type = "description",
								name = " "
							},
							specialFilters = {
								order = 5,
								type = "select",
								sortByValue = true,
								name = L["Add Special Filter"],
								desc = L["These filters don't use a list of spells like the regular filters. Instead they use the WoW API and some code logic to determine if an aura should be allowed or blocked."],
								values = function()
									local filters = {}
									local list = E.global.nameplates.specialFilters
									if not (list and next(list)) then return filters end

									for filter in pairs(list) do
										filters[filter] = L[filter]
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
									local list = E.global.unitframe.aurafilters
									if not (list and next(list)) then return filters end

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
								type = "execute",
								name = L["Reset Priority"],
								desc = L["Reset filter priority to the default state."],
								func = function()
									E.db.nameplates.units[unit].debuffs.filters.priority = P.nameplates.units[unit].debuffs.filters.priority
									NP:ConfigureAll()
								end
							},
							filterPriority = {
								order = 8,
								type = "multiselect",
								name = L["Filter Priority"],
								dragdrop = true,
								dragOnLeave = E.noop, --keep this here
								dragOnEnter = function(info)
									carryFilterTo = info.obj.value
								end,
								dragOnMouseDown = function(info)
									carryFilterFrom, carryFilterTo = info.obj.value, nil
								end,
								dragOnMouseUp = function(info)
									filterPriority("debuffs", unit, carryFilterTo, nil, carryFilterFrom) --add it in the new spot
									carryFilterFrom, carryFilterTo = nil, nil
								end,
								dragOnClick = function(info)
									filterPriority("debuffs", unit, carryFilterFrom, true)
								end,
								stateSwitchGetText = function(_, text)
									local SF, localized = E.global.unitframe.specialFilters[text], L[text]
									local blockText = SF and localized and text:match("^block") and localized:gsub("^%[.-]%s?", "")
									return (blockText and format("|cFF999999%s|r %s", L["BLOCK"], blockText)) or localized or text
								end,
								stateSwitchOnClick = function(info)
									filterPriority("debuffs", unit, carryFilterFrom, nil, nil, true)
								end,
								values = function()
									local str = E.db.nameplates.units[unit].debuffs.filters.priority
									if str == "" then return {} end
									return {strsplit(",", str)}
								end,
								get = function(info, value)
									local str = E.db.nameplates.units[unit].debuffs.filters.priority
									if str == "" then return end
									local tbl = {strsplit(",", str)}
									return tbl[value]
								end,
								set = function(info)
									NP:ConfigureAll()
								end
							},
							spacer3 = {
								order = 9,
								type = "description",
								name = L["Use drag and drop to rearrange filter priority or right click to remove a filter."] ..
									"\n" ..
										L["Use Shift+LeftClick to toggle between friendly or enemy or normal state. Normal state will allow the filter to be checked on all units. Friendly state is for friendly units only and enemy state is for enemy units."]
							}
						}
					}
				}
			},
			levelGroup = {
				order = 5,
				name = L["LEVEL"],
				type = "group",
				get = function(info)
					return E.db.nameplates.units[unit].level[info[#info]]
				end,
				set = function(info, value)
					E.db.nameplates.units[unit].level[info[#info]] = value
					NP:ConfigureAll()
				end,
				args = {
					header = {
						order = 0,
						type = "header",
						name = L["LEVEL"]
					},
					enable = {
						order = 1,
						type = "toggle",
						name = L["Enable"]
					},
					fontGroup = {
						type = "group",
						order = 2,
						name = L["Fonts"],
						guiInline = true,
						get = function(info)
							return E.db.nameplates.units[unit].level[info[#info]]
						end,
						set = function(info, value)
							E.db.nameplates.units[unit].level[info[#info]] = value
							NP:ConfigureAll()
						end,
						args = {
							font = {
								order = 1,
								type = "select",
								name = L["Font"],
								dialogControl = "LSM30_Font",
								values = AceGUIWidgetLSMlists.font
							},
							fontSize = {
								order = 2,
								name = L["FONT_SIZE"],
								type = "range",
								min = 4, max = 32, step = 1
							},
							fontOutline = {
								order = 3,
								type = "select",
								name = L["Font Outline"],
								desc = L["Set the font outline."],
								values = C.Values.FontFlags
							}
						}
					}
				}
			},
			nameGroup = {
				order = 6,
				type = "group",
				name = L["Name"],
				get = function(info)
					return E.db.nameplates.units[unit].name[info[#info]]
				end,
				set = function(info, value)
					E.db.nameplates.units[unit].name[info[#info]] = value
					NP:ConfigureAll()
				end,
				args = {
					header = {
						order = 0,
						type = "header",
						name = L["Name"]
					},
					enable = {
						order = 1,
						type = "toggle",
						name = L["Enable"]
					},
					abbrev = {
						order = 2,
						type = "toggle",
						name = L["Abbreviation"]
					},
					fontGroup = {
						type = "group",
						order = 7,
						name = L["Fonts"],
						guiInline = true,
						get = function(info)
							return E.db.nameplates.units[unit].name[info[#info]]
						end,
						set = function(info, value)
							E.db.nameplates.units[unit].name[info[#info]] = value
							NP:ConfigureAll()
						end,
						args = {
							font = {
								order = 1,
								type = "select",
								name = L["Font"],
								dialogControl = "LSM30_Font",
								values = AceGUIWidgetLSMlists.font
							},
							fontSize = {
								order = 2,
								name = L["FONT_SIZE"],
								type = "range",
								min = 4, max = 32, step = 1
							},
							fontOutline = {
								order = 3,
								type = "select",
								name = L["Font Outline"],
								desc = L["Set the font outline."],
								values = C.Values.FontFlags
							}
						}
					}
				}
			},
			raidTargetIndicator = {
				order = 7,
				name = L["Raid Icon"],
				type = "group",
				get = function(info)
					return E.db.nameplates.units[unit].raidTargetIndicator[info[#info]]
				end,
				set = function(info, value)
					E.db.nameplates.units[unit].raidTargetIndicator[info[#info]] = value
					NP:ConfigureAll()
				end,
				args = {
					header = {
						order = 0,
						type = "header",
						name = L["Raid Icon"]
					},
					size = {
						order = 1,
						type = "range",
						name = L["Size"],
						min = 12, max = 64, step = 1
					},
					position = {
						order = 2,
						type = "select",
						name = L["Icon Position"],
						values = {
							["LEFT"] = L["Left"],
							["RIGHT"] = L["Right"],
							["TOP"] = L["Top"],
							["BOTTOM"] = L["Bottom"],
							["CENTER"] = L["Center"]
						}
					},
					xOffset = {
						order = 3,
						name = L["X-Offset"],
						type = "range",
						min = -100, max = 100, step = 1
					},
					yOffset = {
						order = 4,
						name = L["Y-Offset"],
						type = "range",
						min = -100, max = 100, step = 1
					}
				}
			}
		}
	}

	if unit == "FRIENDLY_PLAYER" or unit == "ENEMY_PLAYER" then
		if unit == "ENEMY_PLAYER" then
			group.args.markHealers = {
				order = 7,
				type = "group",
				name = L["Healer Icon"],
				get = function(info) return E.db.nameplates.units.ENEMY_PLAYER[info[#info]] end,
				set = function(info, value) E.db.nameplates.units.ENEMY_PLAYER[info[#info]] = value NP:PLAYER_ENTERING_WORLD() NP:ConfigureAll() end,
				args = {
					header = {
						order = 1,
						type = "header",
						name = L["Healer Icon"]
					},
					markHealers = {
						order = 2,
						type = "toggle",
						name = L["Enable"],
						desc = L["Display a healer icon over known healers inside battlegrounds or arenas."]
					}
				}
			}
		end
		group.args.healthGroup.args.useClassColor = {
			order = 4.5,
			type = "toggle",
			name = L["Use Class Color"]
		}
		group.args.nameGroup.args.useClassColor = {
			order = 3,
			type = "toggle",
			name = L["Use Class Color"]
		}
	elseif unit == "ENEMY_NPC" or unit == "FRIENDLY_NPC" then
		group.args.eliteIcon = {
			order = 7,
			type = "group",
			name = L["Elite Icon"],
			get = function(info) return E.db.nameplates.units[unit].eliteIcon[info[#info]] end,
			set = function(info, value) E.db.nameplates.units[unit].eliteIcon[info[#info]] = value NP:ConfigureAll() end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Elite Icon"]
				},
				enable = {
					order = 2,
					type = "toggle",
					name = L["Enable"]
				},
				position = {
					order = 3,
					type = "select",
					name = L["Position"],
					values = {
						["LEFT"] = L["Left"],
						["RIGHT"] = L["Right"],
						["TOP"] = L["Top"],
						["BOTTOM"] = L["Bottom"],
						["CENTER"] = L["Center"]
					},
					disabled = function() return not E.db.nameplates.units[unit].eliteIcon.enable end
				},
				spacer = {
					order = 4,
					type = "description",
					name = " "
				},
				size = {
					order = 5,
					type = "range",
					name = L["Size"],
					min = 12, max = 42, step = 1,
					disabled = function() return not E.db.nameplates.units[unit].eliteIcon.enable end
				},
				xOffset = {
					order = 6,
					type = "range",
					name = L["X-Offset"],
					min = -100, max = 100, step = 1,
					disabled = function() return not E.db.nameplates.units[unit].eliteIcon.enable end
				},
				yOffset = {
					order = 7,
					type = "range",
					name = L["Y-Offset"],
					min = -100, max = 100, step = 1,
					disabled = function() return not E.db.nameplates.units[unit].eliteIcon.enable end
				}
			}
		}
		group.args.iconFrame = {
			order = 8,
			type = "group",
			name = L["Icon Frame"],
			get = function(info) return E.db.nameplates.units[unit].iconFrame[info[#info]] end,
			set = function(info, value) E.db.nameplates.units[unit].iconFrame[info[#info]] = value NP:ConfigureAll() end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Icon Frame"]
				},
				enable = {
					order = 2,
					type = "toggle",
					name = L["Enable"]
				},
				size = {
					order = 3,
					type = "range",
					name = L["Size"],
					min = 8, max = 48, step = 1,
				},
				position = {
					order = 4,
					type = "select",
					name = L["Position"],
					values = {
						["CENTER"] = "CENTER",
						["TOPLEFT"] = "TOPLEFT",
						["BOTTOMLEFT"] = "BOTTOMLEFT",
						["TOPRIGHT"] = "TOPRIGHT",
						["BOTTOMRIGHT"] = "BOTTOMRIGHT"
					}
				},
				parent = {
					order = 5,
					type = "select",
					name = L["Parent"],
					values = {
						["Nameplate"] = L["Nameplate"],
						["Health"] = L["Health"]
					}
				},
				xOffset = {
					order = 6,
					name = L["X-Offset"],
					type = "range",
					min = -100, max = 100, step = 1
				},
				yOffset = {
					order = 7,
					name = L["Y-Offset"],
					type = "range",
					min = -100, max = 100, step = 1
				}
			}
		}
	end

	ORDER = ORDER + 2
	return group
end

E.Options.args.nameplate = {
	type = "group",
	name = L["NamePlates"],
	childGroups = "tree",
	get = function(info) return E.db.nameplates[info[#info]] end,
	set = function(info, value) E.db.nameplates[info[#info]] = value NP:ConfigureAll() end,
	args = {
		enable = {
			order = 1,
			type = "toggle",
			name = L["Enable"],
			get = function(info) return E.private.nameplates[info[#info]] end,
			set = function(info, value) E.private.nameplates[info[#info]] = value E:StaticPopup_Show("PRIVATE_RL") end
		},
		intro = {
			order = 2,
			type = "description",
			name = L["NAMEPLATE_DESC"]
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
			name = L["General"],
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "generalGroup", "general") end,
			disabled = function() return not E.NamePlates.Initialized end
		},
		fontsShortcut = {
			order = 6,
			type = "execute",
			name = L["Fonts"],
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "generalGroup", "fontGroup") end,
			disabled = function() return not E.NamePlates.Initialized end
		},
		cooldownShortcut = {
			order = 7,
			type = "execute",
			name = L["Cooldowns"],
			func = function() ACD:SelectGroup("ElvUI", "cooldown", "nameplates") end,
			disabled = function() return not E.NamePlates.Initialized end
		},
		threatShortcut = {
			order = 8,
			type = "execute",
			name = L["Threat"],
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "generalGroup", "threatGroup") end,
			disabled = function() return not E.NamePlates.Initialized end
		},
		spacer2 = {
			order = 9,
			type = "description",
			name = " "
		},
		castBarShortcut = {
			order = 10,
			type = "execute",
			name = L["Cast Bar"],
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "generalGroup", "castGroup") end,
			disabled = function() return not E.NamePlates.Initialized end
		},
		reactionShortcut = {
			order = 12,
			type = "execute",
			name = L["Reaction Colors"],
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "generalGroup", "reactions") end,
			disabled = function() return not E.NamePlates.Initialized end
		},
		cutawayHealthShortcut = {
			order = 13,
			type = "execute",
			name = L["Cutaway Bars"],
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "generalGroup", "cutawayHealth") end,
			disabled = function() return not E.NamePlates.Initialized end
		},
		spacer3 = {
			order = 14,
			type = "description",
			name = " "
		},
		friendlyPlayerShortcut = {
			order = 15,
			type = "execute",
			name = L["FRIENDLY_PLAYER"],
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "friendlyPlayerGroup") end,
			disabled = function() return not E.NamePlates.Initialized end
		},
		friendlyNPCShortcut = {
			order = 16,
			type = "execute",
			name = L["FRIENDLY_NPC"],
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "friendlyNPCGroup") end,
			disabled = function() return not E.NamePlates.Initialized end
		},
		enemyPlayerShortcut = {
			order = 17,
			type = "execute",
			name = L["ENEMY_PLAYER"],
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "enemyPlayerGroup") end,
			disabled = function() return not E.NamePlates.Initialized end
		},
		enemyNPCShortcut = {
			order = 18,
			type = "execute",
			name = L["ENEMY_NPC"],
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "enemyNPCGroup") end,
			disabled = function() return not E.NamePlates.Initialized end
		},
		spacer4 = {
			order = 19,
			type = "description",
			name = " "
		},
		filtersShortcut = {
			order = 20,
			type = "execute",
			name = L["Style Filter"],
			func = function() ACD:SelectGroup("ElvUI", "nameplate", "filters") end,
			disabled = function() return not E.NamePlates.Initialized end
		},
		generalGroup = {
			order = 21,
			type = "group",
			name = L["General Options"],
			childGroups = "tab",
			disabled = function() return not E.NamePlates.Initialized end,
			args = {
				general = {
					order = 1,
					type = "group",
					name = L["General"],
					get = function(info)
						return E.db.nameplates[info[#info]]
					end,
					set = function(info, value)
						E.db.nameplates[info[#info]] = value
						NP:ConfigureAll()
					end,
					args = {
						header = {
							order = 1,
							type = "header",
							name = L["General"]
						},
						statusbar = {
							order = 2,
							type = "select",
							dialogControl = "LSM30_Statusbar",
							name = L["StatusBar Texture"],
							values = AceGUIWidgetLSMlists.statusbar
						},
						motionType = {
							order = 3,
							type = "select",
							name = L["UNIT_NAMEPLATES_TYPES"],
							desc = L["Set to either stack nameplates vertically or allow them to overlap."],
							values = {
								["STACKED"] = L["UNIT_NAMEPLATES_TYPE_2"],
								["OVERLAP"] = L["UNIT_NAMEPLATES_TYPE_1"]
							}
						},
						lowHealthThreshold = {
							order = 4,
							name = L["Low Health Threshold"],
							desc = L["Make the unitframe glow yellow when it is below this percent of health, it will glow red when the health value is half of this value."],
							type = "range",
							isPercent = true,
							min = 0, max = 1, step = 0.01
						},
						showEnemyCombat = {
							order = 5,
							type = "select",
							name = L["Enemy Combat Toggle"],
							desc = L["Control enemy nameplates toggling on or off when in combat."],
							values = {
								["DISABLED"] = L["DISABLE"],
								["TOGGLE_ON"] = L["Toggle On While In Combat"],
								["TOGGLE_OFF"] = L["Toggle Off While In Combat"]
							},
							set = function(info, value)
								E.db.nameplates[info[#info]] = value
								NP:PLAYER_REGEN_ENABLED()
							end
						},
						showFriendlyCombat = {
							order = 6,
							type = "select",
							name = L["Friendly Combat Toggle"],
							desc = L["Control friendly nameplates toggling on or off when in combat."],
							values = {
								["DISABLED"] = L["DISABLE"],
								["TOGGLE_ON"] = L["Toggle On While In Combat"],
								["TOGGLE_OFF"] = L["Toggle Off While In Combat"]
							},
							set = function(info, value)
								E.db.nameplates[info[#info]] = value
								NP:PLAYER_REGEN_ENABLED()
							end
						},
						resetFilters = {
							order = 7,
							type = "execute",
							name = L["Reset Aura Filters"],
							func = function(info, value)
								E:StaticPopup_Show("RESET_NP_AF") --reset nameplate aurafilters
							end
						},
						fadeIn = {
							order = 8,
							type = "toggle",
							name = L["Alpha Fading"]
						},
						smoothbars = {
							order = 9,
							type = "toggle",
							name = L["Smooth Bars"],
							desc = L["Bars will transition smoothly."],
							set = function(info, value)
								E.db.nameplates[info[#info]] = value
								NP:ConfigureAll()
							end
						},
						highlight = {
							order = 10,
							type = "toggle",
							name = L["Hover Highlight"]
						},
						nameColoredGlow = {
							order = 11,
							type = "toggle",
							name = L["Name Colored Glow"],
							desc = L["Use the Name Color of the unit for the Name Glow."],
							disabled = function() return not E.db.nameplates.highlight end
						},
						clickThrough = {
							order = 51,
							type = "group",
							childGroups = "tabs",
							name = L["Click Through"],
							get = function(info)
								return E.db.nameplates.clickThrough[info[#info]]
							end,
							set = function(info, value)
								E.db.nameplates.clickThrough[info[#info]] = value
								NP:ConfigureAll()
							end,
							args = {
								friendly = {
									order = 2,
									type = "toggle",
									name = L["Friendly"],
								},
								enemy = {
									order = 3,
									type = "toggle",
									name = L["Enemy"]
								}
							}
						},
						clickableRange = {
							order = 52,
							type = "group",
							childGroups = "tabs",
							name = L["Clickable Size"],
							args = {
								friendly = {
									order = 1,
									type = "group",
									guiInline = true,
									name = L["Friendly"],
									get = function(info)
										return E.db.nameplates.plateSize[info[#info]]
									end,
									set = function(info, value)
										E.db.nameplates.plateSize[info[#info]] = value
										NP:ConfigureAll()
									end,
									args = {
										friendlyWidth = {
											order = 1,
											type = "range",
											name = L["Clickable Width / Width"],
											desc = L["Change the width and controls how big of an area on the screen will accept clicks to target unit."],
											min = 50,
											max = 250,
											step = 1
										},
										friendlyHeight = {
											order = 2,
											type = "range",
											name = L["Clickable Height"],
											desc = L["Controls how big of an area on the screen will accept clicks to target unit."],
											min = 10,
											max = 75,
											step = 1
										}
									}
								},
								enemy = {
									order = 2,
									type = "group",
									guiInline = true,
									name = L["Enemy"],
									get = function(info)
										return E.db.nameplates.plateSize[info[#info]]
									end,
									set = function(info, value)
										E.db.nameplates.plateSize[info[#info]] = value
										NP:ConfigureAll()
									end,
									args = {
										enemyWidth = {
											order = 1,
											type = "range",
											name = L["Clickable Width / Width"],
											desc = L["Change the width and controls how big of an area on the screen will accept clicks to target unit."],
											min = 50,
											max = 250,
											step = 1
										},
										enemyHeight = {
											order = 2,
											type = "range",
											name = L["Clickable Height"],
											desc = L["Controls how big of an area on the screen will accept clicks to target unit."],
											min = 10,
											max = 75,
											step = 1
										}
									}
								}
							}
						}
					}
				},
				colorsGroup = {
					order = 2,
					type = "group",
					name = L["COLORS"],
					args = {
						general = {
							order = 1,
							type = "group",
							name = L["General"],
							guiInline = true,
							get = function(info)
								local t = E.db.nameplates.colors[info[#info]]
								local d = P.nameplates.colors[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
							end,
							set = function(info, r, g, b, a)
								local t = E.db.nameplates.colors[info[#info]]
								t.r, t.g, t.b, t.a = r, g, b, a
								NP:ConfigureAll()
							end,
							args = {
								glowColor = {
									name = L["Target Indicator Color"],
									type = "color",
									order = 5,
									hasAlpha = true
								}
							}
						},
						threat = {
							order = 2,
							type = "group",
							name = L["Threat"],
							guiInline = true,
							get = function(info)
								local t = E.db.nameplates.colors.threat[info[#info]]
								local d = P.nameplates.colors.threat[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
							end,
							set = function(info, r, g, b, a)
								local t = E.db.nameplates.colors.threat[info[#info]]
								t.r, t.g, t.b, t.a = r, g, b, a
								NP:ConfigureAll()
							end,
							args = {
								goodColor = {
									type = "color",
									order = 1,
									name = L["Good Color"],
									hasAlpha = false,
									disabled = function()
										return not E.db.nameplates.threat.useThreatColor
									end
								},
								goodTransition = {
									type = "color",
									order = 2,
									name = L["Good Transition Color"],
									hasAlpha = false,
									disabled = function()
										return not E.db.nameplates.threat.useThreatColor
									end
								},
								badTransition = {
									name = L["Bad Transition Color"],
									order = 3,
									type = "color",
									hasAlpha = false,
									disabled = function()
										return not E.db.nameplates.threat.useThreatColor
									end
								},
								badColor = {
									name = L["Bad Color"],
									order = 4,
									type = "color",
									hasAlpha = false,
									disabled = function()
										return not E.db.nameplates.threat.useThreatColor
									end
								},
							}
						},
						castGroup = {
							order = 3,
							type = "group",
							name = L["Cast Bar"],
							guiInline = true,
							get = function(info)
								local t = E.db.nameplates.colors[info[#info]]
								local d = P.nameplates.colors[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b
							end,
							set = function(info, r, g, b)
								local t = E.db.nameplates.colors[info[#info]]
								t.r, t.g, t.b = r, g, b
								NP:ConfigureAll()
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
								},
								castInterruptedColor = {
									order = 3,
									type = "color",
									name = L["INTERRUPTED"],
									hasAlpha = false
								},
								castbarDesaturate = {
									order = 4,
									type = "toggle",
									name = L["Desaturated Icon"],
									desc = L["Show the castbar icon desaturated if a spell is not interruptible."],
									get = function(info)
										return E.db.nameplates.colors[info[#info]]
									end,
									set = function(info, value)
										E.db.nameplates.colors[info[#info]] = value
										NP:ConfigureAll()
									end
								}
							}
						},
						reactions = {
							order = 4,
							type = "group",
							name = L["Reaction Colors"],
							guiInline = true,
							get = function(info)
								local t = E.db.nameplates.colors.reactions[info[#info]]
								local d = P.nameplates.colors.reactions[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b
							end,
							set = function(info, r, g, b)
								local t = E.db.nameplates.colors.reactions[info[#info]]
								t.r, t.g, t.b = r, g, b
								NP:ConfigureAll()
							end,
							args = {
								friendlyPlayer = {
									order = 1,
									type = "color",
									name = L["FRIENDLY_PLAYER"],
									hasAlpha = false
								},
								bad = {
									order = 2,
									type = "color",
									name = L["ENEMY"],
									hasAlpha = false
								},
								neutral = {
									order = 3,
									type = "color",
									name = L["Neutral"],
									hasAlpha = false
								},
								good = {
									order = 4,
									type = "color",
									name = L["FRIENDLY_NPC"],
									hasAlpha = false
								}
							}
						},
						comboPoints = {
							order = 5,
							type = "group",
							name = L["COMBO_POINTS"],
							guiInline = true,
							args = {}
						},
					}
				},
				threatGroup = {
					order = 5,
					type = "group",
					name = L["Threat"],
					get = function(info)
						local t = E.db.nameplates.threat[info[#info]]
						local d = P.nameplates.threat[info[#info]]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b
					end,
					set = function(info, r, g, b)
						local t = E.db.nameplates.threat[info[#info]]
						t.r, t.g, t.b = r, g, b
					end,
					args = {
						header = {
							order = 1,
							type = "header",
							name = L["Threat"]
						},
						useThreatColor = {
							order = 2,
							type = "toggle",
							name = L["Use Threat Color"],
							get = function(info) return E.db.nameplates.threat.useThreatColor end,
							set = function(info, value) E.db.nameplates.threat.useThreatColor = value end
						},
						goodScale = {
							order = 3,
							type = "range",
							name = L["Good Scale"],
							get = function(info) return E.db.nameplates.threat[info[#info]] end,
							set = function(info, value) E.db.nameplates.threat[info[#info]] = value end,
							min = 0.3, max = 2, step = 0.01,
							isPercent = true
						},
						badScale = {
							order = 4,
							type = "range",
							name = L["Bad Scale"],
							get = function(info) return E.db.nameplates.threat[info[#info]] end,
							set = function(info, value) E.db.nameplates.threat[info[#info]] = value end,
							min = 0.3, max = 2, step = 0.01,
							isPercent = true
						},
					}
				},
				cutawayHealth = {
					order = 9,
					type = "group",
					name = L["Cutaway Bars"],
					args = {
						header = {
							order = 1,
							type = "header",
							name = L["Cutaway Bars"]
						},
						enabled = {
							order = 2,
							type = "toggle",
							name = L["Enable"],
							get = function(info) return E.db.nameplates.cutawayHealth end,
							set = function(info, value) E.db.nameplates.cutawayHealth = value end,
						},
						healthLength = {
							order = 3,
							type = "range",
							name = L["Health Length"],
							desc = L["How much time before the cutaway health starts to fade."],
							min = 0.1, max = 1, step = 0.1,
							get = function(info) return E.db.nameplates.cutawayHealthLength end,
							set = function(info, value) E.db.nameplates.cutawayHealthLength = value end,
							disabled = function() return not E.db.nameplates.cutawayHealth end
						},
						healthFadeOutTime = {
							order = 4,
							type = "range",
							name = L["Fade Out"],
							desc = L["How long the cutaway health will take to fade out."],
							min = 0.1, max = 1, step = 0.1,
							get = function(info) return E.db.nameplates.cutawayHealthFadeOutTime end,
							set = function(info, value) E.db.nameplates.cutawayHealthFadeOutTime = value end,
							disabled = function() return not E.db.nameplates.cutawayHealth end
						}
					}
				}
			}
		},
		friendlyPlayerGroup = GetUnitSettings("FRIENDLY_PLAYER", L["FRIENDLY_PLAYER"]),
		friendlyNPCGroup = GetUnitSettings("FRIENDLY_NPC", L["FRIENDLY_NPC"]),
		enemyPlayerGroup = GetUnitSettings("ENEMY_PLAYER", L["ENEMY_PLAYER"]),
		enemyNPCGroup = GetUnitSettings("ENEMY_NPC", L["ENEMY_NPC"]),
		targetGroup = {
			order = 200,
			type = "group",
			name = L["TARGET"],
			get = function(info)
				return E.db.nameplates.units.TARGET[info[#info]]
			end,
			set = function(info, value)
				E.db.nameplates.units.TARGET[info[#info]] = value
				NP:ConfigureAll()
			end,
			disabled = function()
				return not E.NamePlates.Initialized
			end,
			args = {
				useTargetScale = {
					order = 1,
					type = "toggle",
					name = L["Use Target Scale"],
					desc = L["Enable/Disable the scaling of targetted nameplates."],
					get = function(info) return E.db.nameplates.useTargetScale end,
					set = function(info, value)
						E.db.nameplates.useTargetScale = value
						NP:ConfigureAll()
					end
				},
				targetScale = {
					order = 2,
					type = "range",
					isPercent = true,
					name = L["Target Scale"],
					desc = L["Scale of the nameplate that is targetted."],
					min = 0.3, max = 2, step = 0.01,
					get = function(info) return E.db.nameplates.targetScale end,
					set = function(info, value)
						E.db.nameplates.targetScale = value
						NP:ConfigureAll()
					end,
					disabled = function() return E.db.nameplates.useTargetScale ~= true end
				},
				nonTargetTransparency = {
					order = 3,
					type = "range",
					isPercent = true,
					name = L["Non-Target Alpha"],
					min = 0, max = 1, step = 0.01,
					get = function(info) return E.db.nameplates.nonTargetTransparency end,
					set = function(info, value)
						E.db.nameplates.nonTargetTransparency = value
						NP:ConfigureAll()
					end
				},
				spacer1 = {
					order = 4,
					type = "description",
					name = " "
				},
				glowStyle = {
					order = 5,
					type = "select",
					name = L["Target/Low Health Indicator"],
					customWidth = 225,
					values = {
						["none"] = L["NONE"],
						["style1"] = L["Border Glow"],
						["style2"] = L["Background Glow"],
						["style3"] = L["Top Arrow"],
						["style4"] = L["Side Arrows"],
						["style5"] = L["Border Glow"].." + "..L["Top Arrow"],
						["style6"] = L["Background Glow"].." + "..L["Top Arrow"],
						["style7"] = L["Border Glow"].." + "..L["Side Arrows"],
						["style8"] = L["Background Glow"].." + "..L["Side Arrows"]
					}
				},
				alwaysShowTargetHealth = {
					order = 7,
					type = "toggle",
					name = L["Always Show Target Health"],
					get = function(info) return E.db.nameplates.alwaysShowTargetHealth end,
					set = function(info, value)
						E.db.nameplates.alwaysShowTargetHealth = value
						NP:ConfigureAll()
					end,
					customWidth = 200
				},
				comboPointsGroup = {
					order = 8,
					type = "group",
					name = L["COMBO_POINTS"],
					guiInline = true,
					get = function(info)
						return E.db.nameplates.units.TARGET.comboPoints[info[#info]]
					end,
					set = function(info, value)
						E.db.nameplates.units.TARGET.comboPoints[info[#info]] = value
						NP:ConfigureAll()
					end,
					args = {
						enable = {
							order = 1,
							type = "toggle",
							name = L["Enable"]
						},
						width = {
							order = 2,
							type = "range",
							name = L["Width"],
							min = 4, max = 30, step = 1,
							disabled = function() return not E.db.nameplates.units.TARGET.comboPoints.enable end
						},
						height = {
							order = 3,
							type = "range",
							name = L["Height"],
							min = 4, max = 30, step = 1,
							disabled = function() return not E.db.nameplates.units.TARGET.comboPoints.enable end
						},
						spacing = {
							order = 4,
							type = "range",
							name = L["Spacing"],
							min = 3, max = 20, step = 1,
							disabled = function() return not E.db.nameplates.units.TARGET.comboPoints.enable end
						},
						xOffset = {
							order = 5,
							type = "range",
							name = L["X-Offset"],
							min = -100, max = 100, step = 1,
							disabled = function() return not E.db.nameplates.units.TARGET.comboPoints.enable end
						},
						yOffset = {
							order = 6,
							type = "range",
							name = L["Y-Offset"],
							min = -100, max = 100, step = 1,
							disabled = function() return not E.db.nameplates.units.TARGET.comboPoints.enable end
						}
					}
				}
			}
		},
		filters = {
			order = -99,
			type = "group",
			name = L["Style Filter"],
			childGroups = "tab",
			disabled = function() return not E.NamePlates.Initialized end,
			args = {
				addFilter = {
					order = 1,
					type = "input",
					name = L["Create Filter"],
					get = function(info) return "" end,
					set = function(info, value)
						if match(value, "^[%s%p]-$") then
							return
						end
						if E.global.nameplates.filters[value] then
							E:Print(L["Filter already exists!"])
							return
						end
						local filter = {}
						NP:StyleFilterCopyDefaults(filter)
						E.global.nameplates.filters[value] = filter
						UpdateFilterGroup()
						NP:ConfigureAll()
					end
				},
				selectFilter = {
					order = 2,
					type = "select",
					sortByValue = true,
					name = L["Select Filter"],
					get = function(info) return selectedNameplateFilter end,
					set = function(info, value) selectedNameplateFilter = value UpdateFilterGroup() end,
					values = function()
						local filters, priority, name = {}
						local list = E.global.nameplates.filters
						local profile = E.db.nameplates.filters
						if not list then return end
						for filter, content in pairs(list) do
							priority = (content.triggers and content.triggers.priority) or "?"
							name = (content.triggers and profile[filter] and profile[filter].triggers and profile[filter].triggers.enable and filter) or (content.triggers and format("|cFF666666%s|r", filter)) or filter
							filters[filter] = format("|cFFffff00(%s)|r %s", priority, name)
						end
						return filters
					end
				},
				removeFilter = {
					order = 3,
					type = "execute",
					name = L["Delete Filter"],
					desc = L["Delete a created filter, you cannot delete pre-existing filters, only custom ones."],
					func = function()
						for profile in pairs(E.data.profiles) do
							if E.data.profiles[profile].nameplates and E.data.profiles[profile].nameplates.filters and E.data.profiles[profile].nameplates.filters[selectedNameplateFilter] then
								E.data.profiles[profile].nameplates.filters[selectedNameplateFilter] = nil
							end
						end
						E.global.nameplates.filters[selectedNameplateFilter] = nil
						selectedNameplateFilter = nil
						UpdateFilterGroup()
						NP:ConfigureAll()
					end,
					disabled = function() return G.nameplates.filters[selectedNameplateFilter] end,
					hidden = function() return selectedNameplateFilter == nil end
				}
			}
		}
	}
}

for i = 1, 5 do
	E.Options.args.nameplate.args.generalGroup.args.colorsGroup.args.comboPoints.args["COMBO_POINTS" .. i] = {
		type = "color",
		order = i,
		name = L["COMBO_POINTS"] .. " #" .. i,
		get = function(info)
			local t = E.db.nameplates.colors.comboPoints[i]
			local d = P.nameplates.colors.comboPoints[i]
			return t.r, t.g, t.b, t.a, d.r, d.g, d.b
		end,
		set = function(info, r, g, b)
			local t = E.db.nameplates.colors.comboPoints[i]
			t.r, t.g, t.b = r, g, b
			NP:ConfigureAll()
		end
	}
end