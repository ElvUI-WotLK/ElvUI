local E, L, V, P, G = unpack(ElvUI);
local UF = E:GetModule('UnitFrames');

local _, ns = ...;
local ElvUF = ns.oUF;

local tinsert = table.insert;
local twipe = table.wipe;

local RAID_CLASS_COLORS = RAID_CLASS_COLORS;
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS;

local ACD = LibStub("AceConfigDialog-3.0-ElvUI");
local fillValues = {
	["fill"] = L["Filled"],
	["spaced"] = L["Spaced"],
	["inset"] = L["Inset"]
};

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

local threatValues = {
	["GLOW"] = L["Glow"],
	["BORDERS"] = L["Borders"],
	["HEALTHBORDER"] = L["Health Border"],
	["INFOPANELBORDER"] = L["InfoPanel Border"],
	["ICONTOPLEFT"] = L["Icon: TOPLEFT"],
	["ICONTOPRIGHT"] = L["Icon: TOPRIGHT"],
	["ICONBOTTOMLEFT"] = L["Icon: BOTTOMLEFT"],
	["ICONBOTTOMRIGHT"] = L["Icon: BOTTOMRIGHT"],
	["ICONLEFT"] = L["Icon: LEFT"],
	["ICONRIGHT"] = L["Icon: RIGHT"],
	["ICONTOP"] = L["Icon: TOP"],
	["ICONBOTTOM"] = L["Icon: BOTTOM"],
	["NONE"] = NONE
};

local petAnchors = {
	TOPLEFT = "TOPLEFT",
	LEFT = "LEFT",
	BOTTOMLEFT = "BOTTOMLEFT",
	RIGHT = "RIGHT",
	TOPRIGHT = "TOPRIGHT",
	BOTTOMRIGHT = "BOTTOMRIGHT",
	TOP = "TOP",
	BOTTOM = "BOTTOM"
};

local auraBarsSortValues = {
	["TIME_REMAINING"] = L["Time Remaining"],
	["TIME_REMAINING_REVERSE"] = L["Time Remaining Reverse"],
	["TIME_DURATION"] = L["Duration"],
	["TIME_DURATION_REVERSE"] = L["Duration Reverse"],
	["NAME"] = NAME,
	["NONE"] = NONE
};

local auraSortValues = {
	["TIME_REMAINING"] = L["Time Remaining"],
	["DURATION"] = L["Duration"],
	["NAME"] = NAME,
	["INDEX"] = L["Index"],
	["PLAYER"] = PLAYER
};

local auraSortMethodValues = {
	["ASCENDING"] = L["Ascending"],
	["DESCENDING"] = L["Descending"]
};

local CUSTOMTEXT_CONFIGS = {};

local function GetOptionsTable_InformationPanel(updateFunc, groupName, numUnits)
	local config = {
		order = 4000,
		type = "group",
		name = L["Information Panel"],
		get = function(info) return E.db.unitframe.units[groupName]["infoPanel"][ info[#info] ] end,
		set = function(info, value) E.db.unitframe.units[groupName]["infoPanel"][ info[#info] ] = value; updateFunc(UF, groupName, numUnits); end,
		args = {
			enable = {
				order = 1,
				type = "toggle",
				name = L["Enable"]
			},
			transparent = {
				order = 2,
				type = "toggle",
				name = L["Transparent"]
			},
			height = {
				order = 3,
				type = "range",
				name = L["Height"],
				min = 4, max = 30, step = 1
			}
		}
	};

	return config;
end

local function GetOptionsTable_Health(isGroupFrame, updateFunc, groupName, numUnits)
	local config = {
		order = 100,
		type = "group",
		name = L["Health"],
		get = function(info) return E.db.unitframe.units[groupName]["health"][ info[#info] ]; end,
		set = function(info, value) E.db.unitframe.units[groupName]["health"][ info[#info] ] = value; updateFunc(UF, groupName, numUnits); end,
		args = {
			position = {
				type = "select",
				order = 1,
				name = L["Text Position"],
				values = positionValues
			},
			xOffset = {
				order = 2,
				type = "range",
				name = L["Text xOffset"],
				desc = L["Offset position for text."],
				min = -300, max = 300, step = 1
			},
			yOffset = {
				order = 3,
				type = "range",
				name = L["Text yOffset"],
				desc = L["Offset position for text."],
				min = -300, max = 300, step = 1
			},
			attachTextTo = {
				order = 4,
				type = "select",
				name = L["Attach Text To"],
				values = {
					["Health"] = L["Health"],
					["Power"] = L["Power"],
					["InfoPanel"] = L["Information Bar"],
					["Frame"] = L["Frame"]
				}
			},
			configureButton = {
				order = 6,
				name = L["Coloring"],
				type = "execute",
				func = function() ACD:SelectGroup("ElvUI", "unitframe", "general", "allColorsGroup", "healthGroup"); end,
			},
			text_format = {
				order = 100,
				name = L["Text Format"],
				type = "input",
				width = "full",
				desc = L["TEXT_FORMAT_DESC"]
			}
		}
	};

	if isGroupFrame then
		config.args.frequentUpdates = {
			type = "toggle",
			order = 4,
			name = L["Frequent Updates"],
			desc = L["Rapidly update the health, uses more memory and cpu. Only recommended for healing."]
		};

		config.args.orientation = {
			type = "select",
			order = 5,
			name = L["Orientation"],
			desc = L["Direction the health bar moves when gaining/losing health."],
			values = {
				["HORIZONTAL"] = L["Horizontal"],
				["VERTICAL"] = L["Vertical"]
			}
		};
	end

	return config;
end

local function GetOptionsTable_Power(hasDetatchOption, updateFunc, groupName, numUnits, hasStrataLevel)
	local config = {
		order = 200,
		type = "group",
		name = L["Power"],
		get = function(info) return E.db.unitframe.units[groupName]["power"][ info[#info] ]; end,
		set = function(info, value) E.db.unitframe.units[groupName]["power"][ info[#info] ] = value; updateFunc(UF, groupName, numUnits); end,
		args = {
			enable = {
				type = "toggle",
				order = 1,
				name = L["Enable"]
			},
			text_format = {
				order = 100,
				name = L["Text Format"],
				type = "input",
				width = "full",
				desc = L["TEXT_FORMAT_DESC"]
			},
			width = {
				type = "select",
				order = 2,
				name = L["Style"],
				values = fillValues,
				set = function(info, value)
					E.db.unitframe.units[groupName]["power"][ info[#info] ] = value;

					local frameName = E:StringTitle(groupName);
					frameName = "ElvUF_" .. frameName;
					frameName = frameName:gsub("t(arget)", "T%1");

					if(numUnits) then
						for i = 1, numUnits do
							if(_G[frameName .. i]) then
								local v = _G[frameName .. i].Power:GetValue();
								local min, max = _G[frameName .. i].Power:GetMinMaxValues();
								_G[frameName..i].Power:SetMinMaxValues(min, max + 500);
								_G[frameName..i].Power:SetValue(1);
								_G[frameName..i].Power:SetValue(0);
							end
						end
					else
						if(_G[frameName] and _G[frameName].Power) then
							local v = _G[frameName].Power:GetValue();
							local min, max = _G[frameName].Power:GetMinMaxValues();
							_G[frameName].Power:SetMinMaxValues(min, max + 500)	;
							_G[frameName].Power:SetValue(1);
							_G[frameName].Power:SetValue(0);
						else
							for i = 1, _G[frameName]:GetNumChildren() do
								local child = select(i, _G[frameName]:GetChildren());
								if(child and child.Power) then
									local v = child.Power:GetValue();
									local min, max = child.Power:GetMinMaxValues();
									child.Power:SetMinMaxValues(min, max + 500);
									child.Power:SetValue(1);
									child.Power:SetValue(0);
								end
							end
						end
					end

					updateFunc(UF, groupName, numUnits);
				end,
			},
			height = {
				type = "range",
				name = L["Height"],
				order = 3,
				min = ((E.db.unitframe.thinBorders or E.PixelMode) and 3 or 7), max = 50, step = 1
			},
			offset = {
				type = "range",
				name = L["Offset"],
				desc = L["Offset of the powerbar to the healthbar, set to 0 to disable."],
				order = 4,
				min = 0, max = 20, step = 1
			},
			configureButton = {
				order = 5,
				name = L["Coloring"],
				desc = L["This opens the UnitFrames Color settings. These settings affect all unitframes."],
				type = "execute",
				func = function() ACD:SelectGroup("ElvUI", "unitframe", "general", "allColorsGroup", "powerGroup"); end,
			},
			position = {
				type = "select",
				order = 6,
				name = L["Text Position"],
				values = positionValues
			},
			xOffset = {
				order = 7,
				type = "range",
				name = L["Text xOffset"],
				desc = L["Offset position for text."],
				min = -300, max = 300, step = 1
			},
			yOffset = {
				order = 8,
				type = "range",
				name = L["Text yOffset"],
				desc = L["Offset position for text."],
				min = -300, max = 300, step = 1
			},
			attachTextTo = {
				order = 9,
				type = "select",
				name = L["Attach Text To"],
				values = {
					["Health"] = L["Health"],
					["Power"] = L["Power"],
					["InfoPanel"] = L["Information Bar"],
					["Frame"] = L["Frame"]
				}
			}
		}
	};

	if(hasDetatchOption) then
		config.args.detachFromFrame = {
			type = "toggle",
			order = 11,
			name = L["Detach From Frame"]
		};
		config.args.detachedWidth = {
			type = "range",
			order = 12,
			name = L["Detached Width"],
			disabled = function() return not E.db.unitframe.units[groupName].power.detachFromFrame; end,
			min = 15, max = 800, step = 1
		};
		config.args.parent = {
			type = "select",
			order = 11,
			name = L["Parent"],
			desc = L["Choose UIPARENT to prevent it from hiding with the unitframe."],
			disabled = function() return not E.db.unitframe.units[groupName].power.detachFromFrame; end,
			values = {
				["FRAME"] = "FRAME",
				["UIPARENT"] = "UIPARENT"
			}
		};
	end

	if(hasStrataLevel) then
		config.args.strataAndLevel = {
			order = 101,
			type = "group",
			name = L["Strata and Level"],
			get = function(info) return E.db.unitframe.units[groupName]["power"]["strataAndLevel"][ info[#info] ]; end,
			set = function(info, value) E.db.unitframe.units[groupName]["power"]["strataAndLevel"][ info[#info] ] = value; updateFunc(UF, groupName, numUnits); end,
			guiInline = true,
			args = {
				useCustomStrata = {
					order = 1,
					type = "toggle",
					name = L["Use Custom Strata"]
				},
				frameStrata = {
					order = 2,
					type = "select",
					name = L["Frame Strata"],
					values = {
						["BACKGROUND"] = "BACKGROUND",
						["LOW"] = "LOW",
						["MEDIUM"] = "MEDIUM",
						["HIGH"] = "HIGH",
						["DIALOG"] = "DIALOG",
						["TOOLTIP"] = "TOOLTIP"
					}
				},
				spacer = {
					order = 3,
					type = "description",
					name = ""
				},
				useCustomLevel = {
					order = 4,
					type = "toggle",
					name = L["Use Custom Level"]
				},
				frameLevel = {
					order = 5,
					type = "range",
					name = L["Frame Level"],
					min = 2, max = 128, step = 1
				}
			}
		};
	end

	return config;
end

local function GetOptionsTable_Name(updateFunc, groupName, numUnits)
	local config = {
		order = 300,
		type = "group",
		name = L["Name"],
		get = function(info) return E.db.unitframe.units[groupName]["name"][ info[#info] ]; end,
		set = function(info, value) E.db.unitframe.units[groupName]["name"][ info[#info] ] = value; updateFunc(UF, groupName, numUnits); end,
		args = {
			position = {
				type = "select",
				order = 1,
				name = L["Text Position"],
				values = positionValues
			},
			xOffset = {
				order = 2,
				type = "range",
				name = L["Text xOffset"],
				desc = L["Offset position for text."],
				min = -300, max = 300, step = 1
			},
			yOffset = {
				order = 3,
				type = "range",
				name = L["Text yOffset"],
				desc = L["Offset position for text."],
				min = -300, max = 300, step = 1
			},
			attachTextTo = {
				order = 4,
				type = "select",
				name = L["Attach Text To"],
				values = {
					["Health"] = L["Health"],
					["Power"] = L["Power"],
					["InfoPanel"] = L["Information Bar"],
					["Frame"] = L["Frame"]
				}
			},
			text_format = {
				order = 100,
				name = L["Text Format"],
				type = "input",
				width = "full",
				desc = L["TEXT_FORMAT_DESC"]
			}
		}
	};

	return config;
end

local function GetOptionsTable_Portrait(updateFunc, groupName, numUnits)
	local config = {
		order = 400,
		type = "group",
		name = L["Portrait"],
		get = function(info) return E.db.unitframe.units[groupName]["portrait"][ info[#info] ]; end,
		set = function(info, value) E.db.unitframe.units[groupName]["portrait"][ info[#info] ] = value; updateFunc(UF, groupName, numUnits); end,
		args = {
			enable = {
				type = "toggle",
				order = 1,
				name = L["Enable"]
			},
			width = {
				type = "range",
				order = 2,
				name = L["Width"],
				min = 1, max = 150, step = 1,
				disabled = function() return not E.db.unitframe.units[groupName]["portrait"]["enable"] or E.db.unitframe.units[groupName]["portrait"]["overlay"]; end,
			},
			overlay = {
				type = "toggle",
				name = L["Overlay"],
				desc = L["Overlay the healthbar"],
				order = 3,
				disabled = function() return not E.db.unitframe.units[groupName]["portrait"]["enable"]; end,
			},
			style = {
				type = "select",
				name = L["Style"],
				desc = L["Select the display method of the portrait."],
				order = 4,
				values = {
					["2D"] = L["2D"],
					["3D"] = L["3D"]
				},
				disabled = function() return not E.db.unitframe.units[groupName]["portrait"]["enable"] end
			}
		}
	};

	return config
end

local function GetOptionsTable_Auras(friendlyUnitOnly, auraType, isGroupFrame, updateFunc, groupName, numUnits)
	local config = {
		order = auraType == "buffs" and 500 or 600,
		type = "group",
		name = auraType == "buffs" and L["Buffs"] or L["Debuffs"],
		get = function(info) return E.db.unitframe.units[groupName][auraType][ info[#info] ]; end,
		set = function(info, value) E.db.unitframe.units[groupName][auraType][ info[#info] ] = value; updateFunc(UF, groupName, numUnits); end,
		args = {
			enable = {
				type = "toggle",
				order = 1,
				name = L["Enable"]
			},
			perrow = {
				type = "range",
				order = 2,
				name = L["Per Row"],
				min = 1, max = 20, step = 1,
			},
			numrows = {
				type = "range",
				order = 3,
				name = L["Num Rows"],
				min = 1, max = 10, step = 1
			},
			sizeOverride = {
				type = "range",
				order = 4,
				name = L["Size Override"],
				desc = L["If not set to 0 then override the size of the aura icon to this."],
				min = 0, max = 60, step = 1
			},
			xOffset = {
				order = 5,
				type = "range",
				name = L["xOffset"],
				min = -300, max = 300, step = 1
			},
			yOffset = {
				order = 6,
				type = "range",
				name = L["yOffset"],
				min = -300, max = 300, step = 1
			},
			spacing = {
				order = 7,
				type = "range",
				name = L["Spacing"],
				min = 0, max = 40, step = 1
			},
			anchorPoint = {
				type = "select",
				order = 9,
				name = L["Anchor Point"],
				desc = L["What point to anchor to the frame you set to attach to."],
				values = positionValues
			},
			fontSize = {
				order = 10,
				name = L["Font Size"],
				type = "range",
				min = 6, max = 22, step = 1
			},
			clickThrough = {
				order = 11,
				name = L["Click Through"],
				desc = L["Ignore mouse events."],
				type = "toggle"
			},
			sortMethod = {
				order = 12,
				name = L["Sort By"],
				desc = L["Method to sort by."],
				type = "select",
				values = auraSortValues
			},
			sortDirection = {
				order = 13,
				name = L["Sort Direction"],
				desc = L["Ascending or Descending order."],
				type = "select",
				values = auraSortMethodValues
			},
			filters = {
				name = L["Filters"],
				guiInline = true,
				type = "group",
				order = 100,
				args = {}
			}
		}
	};

	if(auraType == "buffs") then
		config.args.attachTo = {
			type = "select",
			order = 8,
			name = L["Attach To"],
			desc = L["What to attach the buff anchor frame to."],
			values = {
				["FRAME"] = L["Frame"],
				["DEBUFFS"] = L["Debuffs"],
				["HEALTH"] = L["Health"],
				["POWER"] = L["Power"]
			}
		};
	else
		config.args.attachTo = {
			type = "select",
			order = 8,
			name = L["Attach To"],
			desc = L["What to attach the debuff anchor frame to."],
			values = {
				["FRAME"] = L["Frame"],
				["BUFFS"] = L["Buffs"],
				["HEALTH"] = L["Health"],
				["POWER"] = L["Power"]
			}
		};
	end

	if(isGroupFrame) then
		config.args.countFontSize = {
			order = 10,
			name = L["Count Font Size"],
			type = "range",
			min = 6, max = 22, step = 1
		};
	end

	if(friendlyUnitOnly) then
		config.args.filters.args.playerOnly = {
			order = 14,
			type = "toggle",
			name = L["Block Non-Personal Auras"],
			desc = L["Don't display auras that are not yours."]
		};
		config.args.filters.args.useBlacklist = {
			order = 15,
			type = "toggle",
			name = L["Block Blacklisted Auras"],
			desc = L["Don't display any auras found on the 'Blacklist' filter."]
		};
		config.args.filters.args.useWhitelist = {
			order = 16,
			type = "toggle",
			name = L["Allow Whitelisted Auras"],
			desc = L["If no other filter options are being used then it will block anything not on the 'Whitelist' filter, otherwise it will simply add auras on the whitelist in addition to any other filter settings."]
		};
		config.args.filters.args.noDuration = {
			order = 17,
			type = "toggle",
			name = L["Block Auras Without Duration"],
			desc = L["Don't display auras that have no duration."]
		};
		config.args.filters.args.onlyDispellable = {
			order = 18,
			type = "toggle",
			name = L["Block Non-Dispellable Auras"],
			desc = L["Don't display auras that cannot be purged or dispelled by your class."]
		};

		if(auraType == "buffs") then
			config.args.filters.args.noConsolidated = {
				order = 18,
				type = "toggle",
				name = L["Block Raid Buffs"],
				desc = L["Don't display raid buffs such as Blessing of Kings or Mark of the Wild."]
			};
		end

		config.args.filters.args.useFilter = {
			order = 19,
			name = L["Additional Filter"],
			desc = L["Select an additional filter to use. If the selected filter is a whitelist and no other filters are being used (with the exception of Block Non-Personal Auras) then it will block anything not on the whitelist, otherwise it will simply add auras on the whitelist in addition to any other filter settings."],
			type = "select",
			values = function()
				filters = {};
				filters[""] = NONE;
				for filter in pairs(E.global.unitframe["aurafilters"]) do
					filters[filter] = filter;
				end
				return filters;
			end
		};
	else
		config.args.filters.args.playerOnly = {
			order = 14,
			guiInline = true,
			type = "group",
			name = L["Block Non-Personal Auras"],
			args = {
				friendly = {
					order = 1,
					type = "toggle",
					name = L["Friendly"],
					desc = L["If the unit is friendly to you."].." "..L["Don't display auras that are not yours."],
					get = function(info) return E.db.unitframe.units[groupName][auraType].playerOnly.friendly; end,
					set = function(info, value) E.db.unitframe.units[groupName][auraType].playerOnly.friendly = value; updateFunc(UF, groupName, numUnits); end
				},
				enemy = {
					order = 2,
					type = "toggle",
					name = L["Enemy"],
					desc = L["If the unit is an enemy to you."].." "..L["Don't display auras that are not yours."],
					get = function(info) return E.db.unitframe.units[groupName][auraType].playerOnly.enemy; end,
					set = function(info, value) E.db.unitframe.units[groupName][auraType].playerOnly.enemy = value; updateFunc(UF, groupName, numUnits); end
				}
			}
		};
		config.args.filters.args.useBlacklist = {
			order = 15,
			guiInline = true,
			type = "group",
			name = L["Block Blacklisted Auras"],
			args = {
				friendly = {
					order = 1,
					type = "toggle",
					name = L["Friendly"],
					desc = L["If the unit is friendly to you."].." "..L["Don't display any auras found on the 'Blacklist' filter."],
					get = function(info) return E.db.unitframe.units[groupName][auraType].useBlacklist.friendly; end,
					set = function(info, value) E.db.unitframe.units[groupName][auraType].useBlacklist.friendly = value; updateFunc(UF, groupName, numUnits); end
				},
				enemy = {
					order = 2,
					type = "toggle",
					name = L["Enemy"],
					desc = L["If the unit is an enemy to you."].." "..L["Don't display any auras found on the 'Blacklist' filter."],
					get = function(info) return E.db.unitframe.units[groupName][auraType].useBlacklist.enemy; end,
					set = function(info, value) E.db.unitframe.units[groupName][auraType].useBlacklist.enemy = value; updateFunc(UF, groupName, numUnits); end
				}
			}
		};
		config.args.filters.args.useWhitelist = {
			order = 16,
			guiInline = true,
			type = "group",
			name = L["Allow Whitelisted Auras"],
			args = {
				friendly = {
					order = 1,
					type = "toggle",
					name = L["Friendly"],
					desc = L["If the unit is friendly to you."].." "..L["If no other filter options are being used then it will block anything not on the 'Whitelist' filter, otherwise it will simply add auras on the whitelist in addition to any other filter settings."],
					get = function(info) return E.db.unitframe.units[groupName][auraType].useWhitelist.friendly; end,
					set = function(info, value) E.db.unitframe.units[groupName][auraType].useWhitelist.friendly = value; updateFunc(UF, groupName, numUnits); end
				},
				enemy = {
					order = 2,
					type = "toggle",
					name = L["Enemy"],
					desc = L["If the unit is an enemy to you."].." "..L["If no other filter options are being used then it will block anything not on the 'Whitelist' filter, otherwise it will simply add auras on the whitelist in addition to any other filter settings."],
					get = function(info) return E.db.unitframe.units[groupName][auraType].useWhitelist.enemy; end,
					set = function(info, value) E.db.unitframe.units[groupName][auraType].useWhitelist.enemy = value; updateFunc(UF, groupName, numUnits); end
				}
			}
		};
		config.args.filters.args.noDuration = {
			order = 17,
			guiInline = true,
			type = "group",
			name = L["Block Auras Without Duration"],
			args = {
				friendly = {
					order = 1,
					type = "toggle",
					name = L["Friendly"],
					desc = L["If the unit is friendly to you."].." "..L["Don't display auras that have no duration."],
					get = function(info) return E.db.unitframe.units[groupName][auraType].noDuration.friendly; end,
					set = function(info, value) E.db.unitframe.units[groupName][auraType].noDuration.friendly = value; updateFunc(UF, groupName, numUnits); end
				},
				enemy = {
					order = 2,
					type = "toggle",
					name = L["Enemy"],
					desc = L["If the unit is an enemy to you."].." "..L["Don't display auras that have no duration."],
					get = function(info) return E.db.unitframe.units[groupName][auraType].noDuration.enemy; end,
					set = function(info, value) E.db.unitframe.units[groupName][auraType].noDuration.enemy = value; updateFunc(UF, groupName, numUnits); end
				}
			}
		};
		config.args.filters.args.onlyDispellable = {
			order = 18,
			guiInline = true,
			type = "group",
			name = L["Block Non-Dispellable Auras"],
			args = {
				friendly = {
					order = 1,
					type = "toggle",
					name = L["Friendly"],
					desc = L["If the unit is friendly to you."].." "..L["Don't display auras that cannot be purged or dispelled by your class."],
					get = function(info) return E.db.unitframe.units[groupName][auraType].onlyDispellable.friendly; end,
					set = function(info, value) E.db.unitframe.units[groupName][auraType].onlyDispellable.friendly = value; updateFunc(UF, groupName, numUnits); end
				},
				enemy = {
					order = 2,
					type = "toggle",
					name = L["Enemy"],
					desc = L["If the unit is an enemy to you."].." "..L["Don't display auras that cannot be purged or dispelled by your class."],
					get = function(info) return E.db.unitframe.units[groupName][auraType].onlyDispellable.enemy; end,
					set = function(info, value) E.db.unitframe.units[groupName][auraType].onlyDispellable.enemy = value; updateFunc(UF, groupName, numUnits); end
				}
			}
		};
		if(auraType == "buffs") then
			config.args.filters.args.noConsolidated = {
				order = 18,
				guiInline = true,
				type = "group",
				name = L["Block Raid Buffs"],
				args = {
					friendly = {
						order = 1,
						type = "toggle",
						name = L["Friendly"],
						desc = L["If the unit is friendly to you."].." "..L["Don't display raid buffs such as Blessing of Kings or Mark of the Wild."],
						get = function(info) return E.db.unitframe.units[groupName][auraType].noConsolidated.friendly; end,
						set = function(info, value) E.db.unitframe.units[groupName][auraType].noConsolidated.friendly = value; updateFunc(UF, groupName, numUnits); end
					},
					enemy = {
						order = 2,
						type = "toggle",
						name = L["Enemy"],
						desc = L["If the unit is an enemy to you."].." "..L["Don't display raid buffs such as Blessing of Kings or Mark of the Wild."],
						get = function(info) return E.db.unitframe.units[groupName][auraType].noConsolidated.enemy; end,
						set = function(info, value) E.db.unitframe.units[groupName][auraType].noConsolidated.enemy = value; updateFunc(UF, groupName, numUnits); end
					}
				}
			};
		end

		config.args.filters.args.useFilter = {
			order = 19,
			name = L["Additional Filter"],
			desc = L["Select an additional filter to use. If the selected filter is a whitelist and no other filters are being used (with the exception of Block Non-Personal Auras) then it will block anything not on the whitelist, otherwise it will simply add auras on the whitelist in addition to any other filter settings."],
			type = "select",
			values = function()
				filters = {};
				filters[""] = NONE;
				for filter in pairs(E.global.unitframe["aurafilters"]) do
					filters[filter] = filter;
				end
				return filters;
			end
		};
	end

	return config;
end

local function GetOptionsTable_Castbar(hasTicks, updateFunc, groupName, numUnits)
	local config = {
		order = 700,
		type = "group",
		name = L["Castbar"],
		get = function(info) return E.db.unitframe.units[groupName]["castbar"][ info[#info] ]; end,
		set = function(info, value) E.db.unitframe.units[groupName]["castbar"][ info[#info] ] = value; updateFunc(UF, groupName, numUnits); end,
		args = {
			matchsize = {
				order = 1,
				type = "execute",
				name = L["Match Frame Width"],
				func = function() E.db.unitframe.units[groupName]["castbar"]["width"] = E.db.unitframe.units[groupName]["width"]; updateFunc(UF, groupName, numUnits); end,
			},
			forceshow = {
				order = 2,
				name = L["Show"] .. " / " .. HIDE,
				func = function()
					local frameName = E:StringTitle(groupName);
					frameName = "ElvUF_"..frameName;
					frameName = frameName:gsub("t(arget)", "T%1");

					if(numUnits) then
						for i = 1, numUnits do
							local castbar = _G[frameName .. i].Castbar;
							if(not castbar.oldHide) then
								castbar.oldHide = castbar.Hide;
								castbar.Hide = castbar.Show;
								castbar:SetAlpha(1);
								castbar:Show();
							else
								castbar.Hide = castbar.oldHide;
								castbar.oldHide = nil;
								castbar:Hide();
							end
						end
					else
						local castbar = _G[frameName].Castbar;
						if(not castbar.oldHide) then
							castbar.oldHide = castbar.Hide;
							castbar.Hide = castbar.Show;
							castbar:SetAlpha(1);
							castbar:Show();
						else
							castbar.Hide = castbar.oldHide;
							castbar.oldHide = nil;
							castbar:Hide();
						end
					end
				end,
				type = "execute"
			},
			configureButton = {
				order = 3,
				name = L["Coloring"],
				type = "execute",
				desc = L["This opens the UnitFrames Color settings. These settings affect all unitframes."],
				func = function() ACD:SelectGroup("ElvUI", "unitframe", "general", "allColorsGroup", "castBars") end
			},
			enable = {
				order = 4,
				type = "toggle",
				name = L["Enable"],
			},
			width = {
				order = 5,
				name = L["Width"],
				type = "range",
				min = 50, max = 600, step = 1
			},
			height = {
				order = 6,
				name = L["Height"],
				type = "range",
				min = 10, max = 85, step = 1
			},
			latency = {
				order = 7,
				name = L["Latency"],
				type = "toggle"
			},
			format = {
				order = 8,
				type = "select",
				name = L["Format"],
				values = {
					["CURRENTMAX"] = L["Current / Max"],
					["CURRENT"] = L["Current"],
					["REMAINING"] = L["Remaining"]
				}
			},
			spark = {
				order = 9,
				type = "toggle",
				name = L["Spark"],
				desc = L["Display a spark texture at the end of the castbar statusbar to help show the differance between castbar and backdrop."]
			},
			insideInfoPanel = {
				order = 10,
				type = "toggle",
				name = L["Inside Information Panel"],
				desc = L["Display the castbar inside the information panel, the icon will be displayed outside the main unitframe."],
				disabled = function() return not E.db.unitframe.units[groupName].infoPanel or not E.db.unitframe.units[groupName].infoPanel.enable; end
			},
			iconSettings = {
				order = 13,
				type = "group",
				name = L["Icon"],
				guiInline = true,
				get = function(info) return E.db.unitframe.units[groupName]["castbar"][ info[#info] ]; end,
				set = function(info, value) E.db.unitframe.units[groupName]["castbar"][ info[#info] ] = value; updateFunc(UF, groupName, numUnits); end,
				args = {
					icon = {
						order = 1,
						type = "toggle",
						name = L["Enable"]
					},
					iconAttached = {
						order = 2,
						type = "toggle",
						name = L["Icon Inside Castbar"],
						desc = L["Display the castbar icon inside the castbar."],
					},
					iconSize = {
						order = 3,
						type = "range",
						name = L["Icon Size"],
						desc = L["This dictates the size of the icon when it is not attached to the castbar."],
						min = 8, max = 150, step = 1,
						disabled = function() return E.db.unitframe.units[groupName].castbar.iconAttached; end
					},
					iconAttachedTo = {
						order = 4,
						type = "select",
						name = L["Attach To"],
						disabled = function() return E.db.unitframe.units[groupName].castbar.iconAttached; end,
						values = {
							["Frame"] = L["Frame"],
							["Castbar"] = L["Castbar"]
						}
					},
					iconPosition = {
						order = 5,
						type = "select",
						name = L["Position"],
						values = positionValues,
						disabled = function() return E.db.unitframe.units[groupName].castbar.iconAttached; end
					},
					iconXOffset = {
						order = 5,
						type = "range",
						name = L["xOffset"],
						min = -300, max = 300, step = 1,
						disabled = function() return E.db.unitframe.units[groupName].castbar.iconAttached; end
					},
					iconYOffset = {
						order = 6,
						type = "range",
						name = L["yOffset"],
						min = -300, max = 300, step = 1,
						disabled = function() return E.db.unitframe.units[groupName].castbar.iconAttached; end
					}
				}
			}
		}
	};

	if(hasTicks) then
		config.args.ticks = {
			order = 11,
			type = "toggle",
			name = L["Ticks"],
			desc = L["Display tick marks on the castbar for channelled spells. This will adjust automatically for spells like Drain Soul and add additional ticks based on haste."]
		};
		config.args.displayTarget = {
			order = 12,
			type = "toggle",
			name = L["Display Target"],
			desc = L["Display the target of your current cast. Useful for mouseover casts."]
		};
	end

	return config;
end

local filters;
local function GetOptionsTable_AuraBars(friendlyOnly, updateFunc, groupName)
	local config = {
		order = 800,
		type = "group",
		name = L["Aura Bars"],
		get = function(info) return E.db.unitframe.units[groupName]["aurabar"][ info[#info] ]; end,
		set = function(info, value) E.db.unitframe.units[groupName]["aurabar"][ info[#info] ] = value; updateFunc(UF, groupName); end,
		args = {
			enable = {
				type = "toggle",
				order = 1,
				name = L["Enable"]
			},
			configureButton1 = {
				order = 2,
				name = L["Coloring"],
				desc = L["This opens the UnitFrames Color settings. These settings affect all unitframes."],
				type = "execute",
				func = function() ACD:SelectGroup("ElvUI", "unitframe", "general", "allColorsGroup", "auraBars") end
			},
			configureButton2 = {
				order = 3,
				name = L["Coloring (Specific)"],
				type = "execute",
				func = function() E:SetToFilterConfig("AuraBar Colors") end
			},
			anchorPoint = {
				type = "select",
				order = 4,
				name = L["Anchor Point"],
				desc = L["What point to anchor to the frame you set to attach to."],
				values = {
					["ABOVE"] = L["Above"],
					["BELOW"] = L["Below"]
				}
			},
			attachTo = {
				type = "select",
				order = 5,
				name = L["Attach To"],
				desc = L["The object you want to attach to."],
				values = {
					["FRAME"] = L["Frame"],
					["DEBUFFS"] = L["Debuffs"],
					["BUFFS"] = L["Buffs"],
					["POWER"] = L["Power"]
				}
			},
			height = {
				type = "range",
				order = 6,
				name = L["Height"],
				min = 6, max = 40, step = 1
			},
			maxBars = {
				type = "range",
				order = 7,
				name = L["Max Bars"],
				min = 1, max = 40, step = 1
			},
			sort = {
				type = "select",
				order = 8,
				name = L["Sort Method"],
				values = auraBarsSortValues
			},
			friendlyAuraType = {
				type = "select",
				order = 17,
				name = L["Friendly Aura Type"],
				desc = L["Set the type of auras to show when a unit is friendly."],
				values = {
					["HARMFUL"] = L["Debuffs"],
					["HELPFUL"] = L["Buffs"],
					["BOTH"] = L["Both"]
				}
			},
			enemyAuraType = {
				type = "select",
				order = 18,
				name = L["Enemy Aura Type"],
				desc = L["Set the type of auras to show when a unit is a foe."],
				values = {
					["HARMFUL"] = L["Debuffs"],
					["HELPFUL"] = L["Buffs"],
					["BOTH"] = L["Both"]
				}
			},
			uniformThreshold = {
				order = 19,
				type = "range",
				name = L["Uniform Threshold"],
				desc = L["Seconds remaining on the aura duration before the bar starts moving. Set to 0 to disable."],
				min = 0, max = 3600, step = 1
			},
			filters = {
				name = L["Filters"],
				guiInline = true,
				type = "group",
				order = 100,
				args = {}
			}
		}
	};

	if(groupName == "target") then
		config.args.attachTo.values["PLAYER_AURABARS"] = L["Player Frame Aura Bars"];
	end

	if(friendlyOnly) then
		config.args.filters.args.playerOnly = {
			order = 10,
			type = "toggle",
			name = L["Block Non-Personal Auras"],
			desc = L["Don't display auras that are not yours."]
		};
		config.args.filters.args.useBlacklist = {
			order = 11,
			type = "toggle",
			name = L["Block Blacklisted Auras"],
			desc = L["Don't display any auras found on the 'Blacklist' filter."],
		};
		config.args.filters.args.useWhitelist = {
			order = 12,
			type = "toggle",
			name = L["Allow Whitelisted Auras"],
			desc = L["If no other filter options are being used then it will block anything not on the 'Whitelist' filter, otherwise it will simply add auras on the whitelist in addition to any other filter settings."]
		};
		config.args.filters.args.noDuration = {
			order = 13,
			type = "toggle",
			name = L["Block Auras Without Duration"],
			desc = L["Don't display auras that have no duration."]
		};
		config.args.filters.args.onlyDispellable = {
			order = 14,
			type = "toggle",
			name = L["Block Non-Dispellable Auras"],
			desc = L["Don't display auras that cannot be purged or dispelled by your class."]
		};
		config.args.filters.args.noConsolidated = {
			order = 15,
			type = "toggle",
			name = L["Block Raid Buffs"],
			desc = L["Don't display raid buffs such as Blessing of Kings or Mark of the Wild."]
		};
		config.args.filters.args.useFilter = {
			order = 16,
			name = L["Additional Filter"],
			desc = L["Select an additional filter to use. If the selected filter is a whitelist and no other filters are being used (with the exception of Block Non-Personal Auras) then it will block anything not on the whitelist, otherwise it will simply add auras on the whitelist in addition to any other filter settings."],
			type = "select",
			values = function()
				filters = {};
				filters[""] = NONE;
				for filter in pairs(E.global.unitframe["aurafilters"]) do
					filters[filter] = filter;
				end
				return filters;
			end
		};
	else
		config.args.filters.args.playerOnly = {
			order = 10,
			guiInline = true,
			type = "group",
			name = L["Block Non-Personal Auras"],
			args = {
				friendly = {
					order = 1,
					type = "toggle",
					name = L["Friendly"],
					desc = L["If the unit is friendly to you."] .. " " .. L["Don't display auras that are not yours."],
					get = function(info) return E.db.unitframe.units[groupName]["aurabar"].playerOnly.friendly; end,
					set = function(info, value) E.db.unitframe.units[groupName]["aurabar"].playerOnly.friendly = value; updateFunc(UF, groupName); end
				},
				enemy = {
					order = 2,
					type = "toggle",
					name = L["Enemy"],
					desc = L["If the unit is an enemy to you."] .. " " .. L["Don't display auras that are not yours."],
					get = function(info) return E.db.unitframe.units[groupName]["aurabar"].playerOnly.enemy; end,
					set = function(info, value) E.db.unitframe.units[groupName]["aurabar"].playerOnly.enemy = value; updateFunc(UF, groupName); end
				}
			}
		};
		config.args.filters.args.useBlacklist = {
			order = 11,
			guiInline = true,
			type = "group",
			name = L["Block Blacklisted Auras"],
			args = {
				friendly = {
					order = 1,
					type = "toggle",
					name = L["Friendly"],
					desc = L["If the unit is friendly to you."] .. " " .. L["Don't display any auras found on the 'Blacklist' filter."],
					get = function(info) return E.db.unitframe.units[groupName]["aurabar"].useBlacklist.friendly; end,
					set = function(info, value) E.db.unitframe.units[groupName]["aurabar"].useBlacklist.friendly = value; updateFunc(UF, groupName); end
				},
				enemy = {
					order = 2,
					type = "toggle",
					name = L["Enemy"],
					desc = L["If the unit is an enemy to you."] .. " " .. L["Don't display any auras found on the 'Blacklist' filter."],
					get = function(info) return E.db.unitframe.units[groupName]["aurabar"].useBlacklist.enemy; end,
					set = function(info, value) E.db.unitframe.units[groupName]["aurabar"].useBlacklist.enemy = value; updateFunc(UF, groupName); end
				}
			}
		};
		config.args.filters.args.useWhitelist = {
			order = 12,
			guiInline = true,
			type = "group",
			name = L["Allow Whitelisted Auras"],
			args = {
				friendly = {
					order = 1,
					type = "toggle",
					name = L["Friendly"],
					desc = L["If the unit is friendly to you."] .. " " .. L["If no other filter options are being used then it will block anything not on the 'Whitelist' filter, otherwise it will simply add auras on the whitelist in addition to any other filter settings."],
					get = function(info) return E.db.unitframe.units[groupName]["aurabar"].useWhitelist.friendly; end,
					set = function(info, value) E.db.unitframe.units[groupName]["aurabar"].useWhitelist.friendly = value; updateFunc(UF, groupName); end,
				},
				enemy = {
					order = 2,
					type = "toggle",
					name = L["Enemy"],
					desc = L["If the unit is an enemy to you."] .. " " .. L["If no other filter options are being used then it will block anything not on the 'Whitelist' filter, otherwise it will simply add auras on the whitelist in addition to any other filter settings."],
					get = function(info) return E.db.unitframe.units[groupName]["aurabar"].useWhitelist.enemy; end,
					set = function(info, value) E.db.unitframe.units[groupName]["aurabar"].useWhitelist.enemy = value; updateFunc(UF, groupName); end
				}
			}
		};
		config.args.filters.args.noDuration = {
			order = 13,
			guiInline = true,
			type = "group",
			name = L["Block Auras Without Duration"],
			args = {
				friendly = {
					order = 1,
					type = "toggle",
					name = L["Friendly"],
					desc = L["If the unit is friendly to you."] .. " " .. L["Don't display auras that have no duration."],
					get = function(info) return E.db.unitframe.units[groupName]["aurabar"].noDuration.friendly; end,
					set = function(info, value) E.db.unitframe.units[groupName]["aurabar"].noDuration.friendly = value; updateFunc(UF, groupName); end
				},
				enemy = {
					order = 2,
					type = "toggle",
					name = L["Enemy"],
					desc = L["If the unit is an enemy to you."] .. " " .. L["Don't display auras that have no duration."],
					get = function(info) return E.db.unitframe.units[groupName]["aurabar"].noDuration.enemy; end,
					set = function(info, value) E.db.unitframe.units[groupName]["aurabar"].noDuration.enemy = value; updateFunc(UF, groupName); end
				}
			}
		};
		config.args.filters.args.onlyDispellable = {
			order = 14,
			guiInline = true,
			type = "group",
			name = L["Block Non-Dispellable Auras"],
			args = {
				friendly = {
					order = 1,
					type = "toggle",
					name = L["Friendly"],
					desc = L["If the unit is friendly to you."] .. " " .. L["Don't display auras that cannot be purged or dispelled by your class."],
					get = function(info) return E.db.unitframe.units[groupName]["aurabar"].onlyDispellable.friendly; end,
					set = function(info, value) E.db.unitframe.units[groupName]["aurabar"].onlyDispellable.friendly = value; updateFunc(UF, groupName); end
				},
				enemy = {
					order = 2,
					type = "toggle",
					name = L["Enemy"],
					desc = L["If the unit is an enemy to you."] .. " " .. L["Don't display auras that cannot be purged or dispelled by your class."],
					get = function(info) return E.db.unitframe.units[groupName]["aurabar"].onlyDispellable.enemy; end,
					set = function(info, value) E.db.unitframe.units[groupName]["aurabar"].onlyDispellable.enemy = value; updateFunc(UF, groupName); end
				}
			}
		};
		config.args.filters.args.noConsolidated = {
			order = 15,
			guiInline = true,
			type = "group",
			name = L["Block Raid Buffs"],
			args = {
				friendly = {
					order = 1,
					type = "toggle",
					name = L["Friendly"],
					desc = L["If the unit is friendly to you."] .. " " .. L["Don't display raid buffs such as Blessing of Kings or Mark of the Wild."],
					get = function(info) return E.db.unitframe.units[groupName]["aurabar"].noConsolidated.friendly; end,
					set = function(info, value) E.db.unitframe.units[groupName]["aurabar"].noConsolidated.friendly = value; updateFunc(UF, groupName); end
				},
				enemy = {
					order = 2,
					type = "toggle",
					name = L["Enemy"],
					desc = L["If the unit is an enemy to you."] .. " " .. L["Don't display raid buffs such as Blessing of Kings or Mark of the Wild."],
					get = function(info) return E.db.unitframe.units[groupName]["aurabar"].noConsolidated.enemy; end,
					set = function(info, value) E.db.unitframe.units[groupName]["aurabar"].noConsolidated.enemy = value; updateFunc(UF, groupName); end
				}
			}
		};
		config.args.filters.args.useFilter = {
			order = 16,
			name = L["Additional Filter"],
			desc = L["Select an additional filter to use. If the selected filter is a whitelist and no other filters are being used (with the exception of Block Non-Personal Auras) then it will block anything not on the whitelist, otherwise it will simply add auras on the whitelist in addition to any other filter settings."],
			type = "select",
			values = function()
				filters = {};
				filters[""] = NONE;
				for filter in pairs(E.global.unitframe["aurafilters"]) do
					filters[filter] = filter;
				end
				return filters;
			end
		};
	end

	config.args.filters.args.maxDuration = {
		order = 17,
		type = "range",
		name = L["Maximum Duration"],
		desc = L["Don't display auras that are longer than this duration (in seconds). Set to zero to disable."],
		min = 0, max = 3600, step = 1
	};

	return config;
end

local function GetOptionsTable_RaidIcon(updateFunc, groupName, numUnits)
	local config = {
		order = 1000,
		type = "group",
		name = L["Raid Icon"],
		get = function(info) return E.db.unitframe.units[groupName]["raidicon"][ info[#info] ]; end,
		set = function(info, value) E.db.unitframe.units[groupName]["raidicon"][ info[#info] ] = value; updateFunc(UF, groupName, numUnits); end,
		args = {
			enable = {
				order = 1,
				type = "toggle",
				name = L["Enable"],
			},
			attachTo = {
				order = 2,
				type = "select",
				name = L["Position"],
				values = positionValues,
				disabled = function() return not E.db.unitframe.units[groupName]["raidicon"]["enable"]; end
			},
			attachToObject = {
				order = 3,
				type = "select",
				name = L["Attach To"],
				values = {
					["Health"] = L["Health"],
					["Power"] = L["Power"],
					["InfoPanel"] = L["Information Bar"],
					["Frame"] = L["Frame"]
				}
			},
			size = {
				order = 4,
				type = "range",
				name = L["Size"],
				min = 8, max = 60, step = 1,
				disabled = function() return not E.db.unitframe.units[groupName]["raidicon"]["enable"]; end
			},
			xOffset = {
				order = 5,
				type = "range",
				name = L["xOffset"],
				min = -300, max = 300, step = 1,
				disabled = function() return not E.db.unitframe.units[groupName]["raidicon"]["enable"]; end
			},
			yOffset = {
				order = 6,
				type = "range",
				name = L["yOffset"],
				min = -300, max = 300, step = 1,
				disabled = function() return not E.db.unitframe.units[groupName]["raidicon"]["enable"]; end
			}
		}
	};

	return config;
end

local function GetOptionsTable_RaidDebuff(updateFunc, groupName)
	local config = {
		order = 800,
		type = "group",
		name = L["RaidDebuff Indicator"],
		get = function(info) return E.db.unitframe.units[groupName]["rdebuffs"][ info[#info] ]; end,
		set = function(info, value) E.db.unitframe.units[groupName]["rdebuffs"][ info[#info] ] = value; updateFunc(UF, groupName); end,
		args = {
			enable = {
				order = 1,
				type = "toggle",
				name = L["Enable"]
			},
			showDispellableDebuff = {
				order = 2,
				type = "toggle",
				name = L["Show Dispellable Debuffs"]
			},
			size = {
				order = 3,
				type = "range",
				name = L["Size"],
				min = 8, max = 35, step = 1
			},
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
				min = 7, max = 22, step = 1
			},
			fontOutline = {
				order = 6,
				type = "select",
				name = L["Font Outline"],
				values = {
					["NONE"] = L["None"],
					["OUTLINE"] = "OUTLINE",
					["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
					["THICKOUTLINE"] = "THICKOUTLINE"
				}
			},
			xOffset = {
				order = 7,
				type = "range",
				name = L["xOffset"],
				min = -300, max = 300, step = 1
			},
			yOffset = {
				order = 8,
				type = "range",
				name = L["yOffset"],
				min = -300, max = 300, step = 1
			},
			configureButton = {
				order = 9,
				type = "execute",
				name = L["Configure Auras"],
				func = function() E:SetToFilterConfig("RaidDebuffs"); end
			},
			duration = {
				order = 11,
				type = "group",
				guiInline = true,
				name = L["Duration Text"],
				get = function(info) return E.db.unitframe.units[groupName]["rdebuffs"]["duration"][ info[#info] ]; end,
				set = function(info, value) E.db.unitframe.units[groupName]["rdebuffs"]["duration"][ info[#info] ] = value; updateFunc(UF, groupName); end,
				args = {
					position = {
						order = 1,
						type = "select",
						name = L["Position"],
						values = {
							["TOP"] = "TOP",
							["LEFT"] = "LEFT",
							["RIGHT"] = "RIGHT",
							["BOTTOM"] = "BOTTOM",
							["CENTER"] = "CENTER",
							["TOPLEFT"] = "TOPLEFT",
							["TOPRIGHT"] = "TOPRIGHT",
							["BOTTOMLEFT"] = "BOTTOMLEFT",
							["BOTTOMRIGHT"] = "BOTTOMRIGHT"
						}
					},
					xOffset = {
						order = 2,
						type = "range",
						name = L["xOffset"],
						min = -10, max = 10, step = 1
					},
					yOffset = {
						order = 3,
						type = "range",
						name = L["yOffset"],
						min = -10, max = 10, step = 1
					},
					color = {
						order = 4,
						type = "color",
						name = L["Color"],
						get = function(info)
							local c = E.db.unitframe.units.raid.rdebuffs.duration.color;
							local d = P.unitframe.units.raid.rdebuffs.duration.color;
							return c.r, c.g, c.b, c.a, d.r, d.g, d.b;
						end,
						set = function(info, r, g, b)
							E.db.unitframe.units.raid.rdebuffs.duration.color = {};
							local c = E.db.unitframe.units.raid.rdebuffs.duration.color;
							c.r, c.g, c.b = r, g, b;
							UF:CreateAndUpdateHeaderGroup("raid");
						end
					}
				}
			},
			stack = {
				order = 11,
				type = "group",
				guiInline = true,
				name = L["Stack Counter"],
				get = function(info) return E.db.unitframe.units[groupName]["rdebuffs"]["stack"][ info[#info] ]; end,
				set = function(info, value) E.db.unitframe.units[groupName]["rdebuffs"]["stack"][ info[#info] ] = value; updateFunc(UF, groupName); end,
				args = {
					position = {
						order = 1,
						type = "select",
						name = L["Position"],
						values = {
							["TOP"] = "TOP",
							["LEFT"] = "LEFT",
							["RIGHT"] = "RIGHT",
							["BOTTOM"] = "BOTTOM",
							["CENTER"] = "CENTER",
							["TOPLEFT"] = "TOPLEFT",
							["TOPRIGHT"] = "TOPRIGHT",
							["BOTTOMLEFT"] = "BOTTOMLEFT",
							["BOTTOMRIGHT"] = "BOTTOMRIGHT"
						}
					},
					xOffset = {
						order = 2,
						type = "range",
						name = L["xOffset"],
						min = -10, max = 10, step = 1
					},
					yOffset = {
						order = 3,
						type = "range",
						name = L["yOffset"],
						min = -10, max = 10, step = 1
					},
					color = {
						order = 4,
						type = "color",
						name = L["Color"],
						get = function(info)
							local c = E.db.unitframe.units[groupName].rdebuffs.stack.color;
							local d = P.unitframe.units[groupName].rdebuffs.stack.color;
							return c.r, c.g, c.b, c.a, d.r, d.g, d.b;
						end,
						set = function(info, r, g, b)
							E.db.unitframe.units[groupName].rdebuffs.stack.color = {};
							local c = E.db.unitframe.units[groupName].rdebuffs.stack.color;
							c.r, c.g, c.b = r, g, b;
							updateFunc(UF, groupName);
						end
					}
				}
			}
		}
	};

	return config;
end

function UF:CreateCustomTextGroup(unit, objectName)
	if(not E.Options.args.unitframe.args[unit]) then
		return;
	elseif(E.Options.args.unitframe.args[unit].args[objectName]) then
		E.Options.args.unitframe.args[unit].args[objectName].hidden = false;
		tinsert(CUSTOMTEXT_CONFIGS, E.Options.args.unitframe.args[unit].args[objectName]);
		return;
	end

	E.Options.args.unitframe.args[unit].args[objectName] = {
		order = -1,
		type = "group",
		name = objectName,
		get = function(info) return E.db.unitframe.units[unit].customTexts[objectName][ info[#info] ] end,
		set = function(info, value)
			E.db.unitframe.units[unit].customTexts[objectName][ info[#info] ] = value;

			if(unit == "party" or unit:find("raid")) then
				UF:CreateAndUpdateHeaderGroup(unit);
			elseif(unit == "boss") then
				UF:CreateAndUpdateUFGroup("boss", MAX_BOSS_FRAMES);
			elseif(unit == "arena") then
				UF:CreateAndUpdateUFGroup("arena", 5);
			else
				UF:CreateAndUpdateUF(unit);
			end
		end,
		args = {
			delete = {
				type = "execute",
				order = 1,
				name = DELETE,
				func = function()
					E.Options.args.unitframe.args[unit].args[objectName] = nil;
					E.db.unitframe.units[unit].customTexts[objectName] = nil;

					if(unit == "boss" or unit == "arena") then
						for i = 1, 5 do
							if(UF[unit .. i]) then
								UF[unit .. i]:Tag(UF[unit .. i]["customTexts"][objectName], "");
								UF[unit .. i]["customTexts"][objectName]:Hide();
							end
						end
					elseif(unit == "party" or unit:find("raid")) then
						for i = 1, UF[unit]:GetNumChildren() do
							local child = select(i, UF[unit]:GetChildren());
							if(child.Tag) then
								child:Tag(child["customTexts"][objectName], "");
								child["customTexts"][objectName]:Hide();
							else
								for x = 1, child:GetNumChildren() do
									local c2 = select(x, child:GetChildren());
									if(c2.Tag) then
										c2:Tag(c2["customTexts"][objectName], "");
										c2["customTexts"][objectName]:Hide();
									end
								end
							end
						end
					elseif(UF[unit]) then
						UF[unit]:Tag(UF[unit]["customTexts"][objectName], "");
						UF[unit]["customTexts"][objectName]:Hide();
					end
				end
			},
			font = {
				type = "select", dialogControl = "LSM30_Font",
				order = 2,
				name = L["Font"],
				values = AceGUIWidgetLSMlists.font
			},
			size = {
				order = 3,
				name = L["Font Size"],
				type = "range",
				min = 6, max = 32, step = 1
			},
			fontOutline = {
				order = 4,
				name = L["Font Outline"],
				desc = L["Set the font outline."],
				type = "select",
				values = {
					["NONE"] = L["None"],
					["OUTLINE"] = "OUTLINE",
					["MONOCHROME"] = (not E.isMacClient) and "MONOCHROME" or nil,
					["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
					["THICKOUTLINE"] = "THICKOUTLINE"
				}
			},
			justifyH = {
				order = 5,
				type = "select",
				name = L["JustifyH"],
				desc = L["Sets the font instance's horizontal text alignment style."],
				values = {
					["CENTER"] = L["Center"],
					["LEFT"] = L["Left"],
					["RIGHT"] = L["Right"]
				}
			},
			xOffset = {
				order = 6,
				type = "range",
				name = L["xOffset"],
				min = -400, max = 400, step = 1
			},
			yOffset = {
				order = 7,
				type = "range",
				name = L["yOffset"],
				min = -400, max = 400, step = 1
			},
			attachTextTo = {
				order = 8,
				type = "select",
				name = L["Attach Text To"],
				values = {
					["Health"] = L["Health"],
					["Power"] = L["Power"],
					["InfoPanel"] = L["Information Bar"],
					["Frame"] = L["Frame"]
				}
			},
			text_format = {
				order = 100,
				name = L["Text Format"],
				type = "input",
				width = "full",
				desc = L["TEXT_FORMAT_DESC"]
			}
		}
	};

	tinsert(CUSTOMTEXT_CONFIGS, E.Options.args.unitframe.args[unit].args[objectName]);
end

local function GetOptionsTable_CustomText(updateFunc, groupName, numUnits, orderOverride)
	local config = {
		order = orderOverride or 50,
		name = L["Custom Texts"],
		type = "input",
		width = "full",
		desc = L["Create a custom fontstring. Once you enter a name you will be able to select it from the elements dropdown list."],
		get = function() return "" end,
		set = function(info, textName)
			for object, _ in pairs(E.db.unitframe.units[groupName]) do
				if(object:lower() == textName:lower()) then
					E:Print(L["The name you have selected is already in use by another element."]);
					return;
				end
			end

			if(not E.db.unitframe.units[groupName].customTexts) then
				E.db.unitframe.units[groupName].customTexts = {};
			end

			local frameName = "ElvUF_" .. E:StringTitle(groupName)
			if(E.db.unitframe.units[groupName].customTexts[textName] or (_G[frameName] and _G[frameName]["customTexts"] and _G[frameName]["customTexts"][textName] or _G[frameName .. "Group1UnitButton1"] and _G[frameName .. "Group1UnitButton1"]["customTexts"] and _G[frameName .. "Group1UnitButton1"][textName])) then
				E:Print(L["The name you have selected is already in use by another element."]);
				return;
			end

			E.db.unitframe.units[groupName].customTexts[textName] = {
				["text_format"] = "",
				["size"] = E.db.unitframe.fontSize,
				["font"] = E.db.unitframe.font,
				["xOffset"] = 0,
				["yOffset"] = 0,
				["justifyH"] = "CENTER",
				["fontOutline"] = E.db.unitframe.fontOutline,
				["attachTextTo"] = "HEALTH"
			};

			UF:CreateCustomTextGroup(groupName, textName);
			updateFunc(UF, groupName, numUnits);
		end
	};

	return config;
end

local function GetOptionsTable_GPS(groupName)
	local config = {
		order = 3000,
		type = "group",
		name = L["GPS Arrow"],
		get = function(info) return E.db.unitframe.units[groupName]["GPSArrow"][ info[#info] ]; end,
		set = function(info, value) E.db.unitframe.units[groupName]["GPSArrow"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup(groupName); end,
		args = {
			enable = {
				order = 1,
				type = "toggle",
				name = L["Enable"]
			},
			onMouseOver = {
				order = 2,
				type = "toggle",
				name = L["Mouseover"],
				desc = L["Only show when you are mousing over a frame."]
			},
			outOfRange = {
				order = 3,
				type = "toggle",
				name = L["Out of Range"],
				desc = L["Only show when the unit is not in range."]
			},
			size = {
				order = 4,
				type = "range",
				name = L["Size"],
				min = 8, max = 60, step = 1
			},
			xOffset = {
				order = 5,
				type = "range",
				name = L["xOffset"],
				min = -300, max = 300, step = 1
			},
			yOffset = {
				order = 6,
				type = "range",
				name = L["yOffset"],
				min = -300, max = 300, step = 1
			}
		}
	};

	return config;
end

local function GetOptionsTableForNonGroup_GPS(unit)
	local config = {
		order = 3000,
		type = "group",
		name = L["GPS Arrow"],
		get = function(info) return E.db.unitframe.units[unit]["GPSArrow"][ info[#info] ] end,
		set = function(info, value) E.db.unitframe.units[unit]["GPSArrow"][ info[#info] ] = value; UF:CreateAndUpdateUF(unit); end,
		args = {
			enable = {
				order = 1,
				type = "toggle",
				name = L["Enable"],
			},
			onMouseOver = {
				order = 2,
				type = "toggle",
				name = L["Mouseover"],
				desc = L["Only show when you are mousing over a frame."]
			},
			outOfRange = {
				order = 3,
				type = "toggle",
				name = L["Out of Range"],
				desc = L["Only show when the unit is not in range."]
			},
			size = {
				order = 4,
				type = "range",
				name = L["Size"],
				min = 8, max = 60, step = 1
			},
			xOffset = {
				order = 5,
				type = "range",
				name = L["xOffset"],
				min = -300, max = 300, step = 1
			},
			yOffset = {
				order = 6,
				type = "range",
				name = L["yOffset"],
				min = -300, max = 300, step = 1
			}
		}
	};

	return config;
end

E.Options.args.unitframe = {
	type = "group",
	name = L["UnitFrames"],
	childGroups = "tree",
	get = function(info) return E.db.unitframe[ info[#info] ]; end,
	set = function(info, value) E.db.unitframe[ info[#info] ] = value; end,
	args = {
		enable = {
			order = 1,
			type = "toggle",
			name = L["Enable"],
			get = function(info) return E.private.unitframe.enable; end,
			set = function(info, value) E.private.unitframe.enable = value; E:StaticPopup_Show("PRIVATE_RL"); end
		},
		general = {
			order = 200,
			type = "group",
			name = L["General"],
			guiInline = true,
			disabled = function() return not E.private.unitframe.enable end,
			set = function(info, value) E.db.unitframe[ info[#info] ] = value; UF:Update_AllFrames(); end,
			args = {
				disabledBlizzardFrames = {
					order = 1,
					type = "group",
					guiInline = true,
					name = L["Disabled Blizzard Frames"],
					get = function(info) return E.private.unitframe.disabledBlizzardFrames[ info[#info] ]; end,
					set = function(info, value) E.private["unitframe"].disabledBlizzardFrames[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end,
					args = {
						player = {
							order = 1,
							type = "toggle",
							name = L["Player Frame"],
							desc = L["Disables the player and pet unitframes."]
						},
						target = {
							order = 2,
							type = "toggle",
							name = L["Target Frame"],
							desc = L["Disables the target and target of target unitframes."]
						},
						focus = {
							order = 3,
							type = "toggle",
							name = L["Focus Frame"],
							desc = L["Disables the focus and target of focus unitframes."]
						},
						boss = {
							order = 4,
							type = "toggle",
							name = L["Boss Frames"]
						},
						arena = {
							order = 5,
							type = "toggle",
							name = L["Arena Frames"]
						},
						party = {
							order = 6,
							type = "toggle",
							name = L["Party Frames"]
						}
					}
				},
				generalGroup = {
					order = 2,
					type = "group",
					guiInline = true,
					name = L["General"],
					args = {
						thinBorders = {
							order = 1,
							type = "toggle",
							name = L["Thin Borders"],
							desc = L["Use thin borders on certain unitframe elements."],
							disabled = function() return E.private.general.pixelPerfect end,
							set = function(info, value) E.db.unitframe[ info[#info] ] = value; E:StaticPopup_Show("CONFIG_RL"); end,
						},
						OORAlpha = {
							order = 2,
							name = L["OOR Alpha"],
							desc = L["The alpha to set units that are out of range to."],
							type = "range",
							min = 0, max = 1, step = 0.01
						},
						debuffHighlighting = {
							order = 3,
							name = L["Debuff Highlighting"],
							desc = L["Color the unit healthbar if there is a debuff that can be dispelled by you."],
							type = "select",
							values = {
								["NONE"] = NONE,
								["GLOW"] = L["Glow"],
								["FILL"] = L["Fill"]
							}
						},
						smartRaidFilter = {
							order = 4,
							name = L["Smart Raid Filter"],
							desc = L["Override any custom visibility setting in certain situations, EX: Only show groups 1 and 2 inside a 10 man instance."],
							type = "toggle",
							set = function(info, value) E.db.unitframe[ info[#info] ] = value; UF:UpdateAllHeaders(); end
						},
						targetOnMouseDown = {
							order = 5,
							name = L["Target On Mouse-Down"],
							desc = L["Target units on mouse down rather than mouse up. \n\n|cffFF0000Warning: If you are using the addon 'Clique' you may have to adjust your clique settings when changing this."],
							type = "toggle"
						},
						auraBlacklistModifier = {
							order = 6,
							type = "select",
							name = L["Blacklist Modifier"],
							desc = L["You need to hold this modifier down in order to blacklist an aura by right-clicking the icon. Set to None to disable the blacklist functionality."],
							values = {
								["NONE"] = NONE,
								["SHIFT"] = SHIFT_KEY,
								["ALT"] = ALT_KEY,
								["CTRL"] = CTRL_KEY
							}
						}
					}
				},
				barGroup = {
					order = 3,
					type = "group",
					guiInline = true,
					name = L["Bars"],
					args = {
						smoothbars = {
							type = "toggle",
							order = 2,
							name = L["Smooth Bars"],
							desc = L["Bars will transition smoothly."],
							set = function(info, value) E.db.unitframe[ info[#info] ] = value; UF:Update_AllFrames(); end
						},
						smoothSpeed = {
							type = "range",
							order = 3,
							name = L["Animation Speed"],
							desc = L["Speed in seconds"],
							min = 0.1, max = 3, step = 0.01,
							set = function(info, value) E.db.unitframe[ info[#info] ] = value; UF:Update_AllFrames(); end
						},
						statusbar = {
							type = "select", dialogControl = "LSM30_Statusbar",
							order = 4,
							name = L["StatusBar Texture"],
							desc = L["Main statusbar texture."],
							values = AceGUIWidgetLSMlists.statusbar,
							set = function(info, value) E.db.unitframe[ info[#info] ] = value; UF:Update_StatusBars(); end
						}
					}
				},
				fontGroup = {
					order = 4,
					type = "group",
					guiInline = true,
					name = L["Fonts"],
					args = {
						font = {
							type = "select", dialogControl = "LSM30_Font",
							order = 1,
							name = L["Default Font"],
							desc = L["The font that the unitframes will use."],
							values = AceGUIWidgetLSMlists.font,
							set = function(info, value) E.db.unitframe[ info[#info] ] = value; UF:Update_FontStrings(); end
						},
						fontSize = {
							order = 2,
							name = L["Font Size"],
							desc = L["Set the font size for unitframes."],
							type = "range",
							min = 6, max = 22, step = 1,
							set = function(info, value) E.db.unitframe[ info[#info] ] = value; UF:Update_FontStrings(); end,
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
							set = function(info, value) E.db.unitframe[ info[#info] ] = value; UF:Update_FontStrings(); end
						}
					}
				},
				allColorsGroup = {
					order = 5,
					type = "group",
					guiInline = true,
					name = L["Colors"],
					get = function(info) return E.db.unitframe.colors[ info[#info] ]; end,
					set = function(info, value) E.db.unitframe.colors[ info[#info] ] = value; UF:Update_AllFrames(); end,
					args = {
						healthGroup = {
							order = 7,
							type = "group",
							guiInline = true,
							name = HEALTH,
							get = function(info)
								local t = E.db.unitframe.colors[ info[#info] ];
								local d = P.unitframe.colors[ info[#info] ];
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b;
							end,
							set = function(info, r, g, b)
								E.db.general[ info[#info] ] = {};
								local t = E.db.unitframe.colors[ info[#info] ];
								t.r, t.g, t.b = r, g, b;
								UF:Update_AllFrames();
							end,
							args = {
								healthclass = {
									order = 1,
									type = "toggle",
									name = L["Class Health"],
									desc = L["Color health by classcolor or reaction."],
									get = function(info) return E.db.unitframe.colors[ info[#info] ]; end,
									set = function(info, value) E.db.unitframe.colors[ info[#info] ] = value; UF:Update_AllFrames(); end
								},
								forcehealthreaction = {
									order = 2,
									type = "toggle",
									name = L["Force Reaction Color"],
									desc = L["Forces reaction color instead of class color on units controlled by players."],
									get = function(info) return E.db.unitframe.colors[ info[#info] ]; end,
									set = function(info, value) E.db.unitframe.colors[ info[#info] ] = value; UF:Update_AllFrames(); end,
									disabled = function() return not E.db.unitframe.colors.healthclass end
								},
								colorhealthbyvalue = {
									order = 3,
									type = "toggle",
									name = L["Health By Value"],
									desc = L["Color health by amount remaining."],
									get = function(info) return E.db.unitframe.colors[ info[#info] ] end,
									set = function(info, value) E.db.unitframe.colors[ info[#info] ] = value; UF:Update_AllFrames(); end
								},
								customhealthbackdrop = {
									order = 4,
									type = "toggle",
									name = L["Custom Health Backdrop"],
									desc = L["Use the custom health backdrop color instead of a multiple of the main health color."],
									get = function(info) return E.db.unitframe.colors[ info[#info] ] end,
									set = function(info, value) E.db.unitframe.colors[ info[#info] ] = value; UF:Update_AllFrames(); end
								},
								classbackdrop = {
									order = 5,
									type = "toggle",
									name = L["Class Backdrop"],
									desc = L["Color the health backdrop by class or reaction."],
									get = function(info) return E.db.unitframe.colors[ info[#info] ] end,
									set = function(info, value) E.db.unitframe.colors[ info[#info] ] = value; UF:Update_AllFrames(); end
								},
								transparentHealth = {
									order = 6,
									type = "toggle",
									name = L["Transparent"],
									desc = L["Make textures transparent."],
									get = function(info) return E.db.unitframe.colors[ info[#info] ] end,
									set = function(info, value) E.db.unitframe.colors[ info[#info] ] = value; UF:Update_AllFrames(); end
								},
								useDeadBackdrop = {
									order = 7,
									type = "toggle",
									name = L["Use Dead Backdrop"],
									get = function(info) return E.db.unitframe.colors[ info[#info] ] end,
									set = function(info, value) E.db.unitframe.colors[ info[#info] ] = value; UF:Update_AllFrames(); end
								},
								health = {
									order = 10,
									type = "color",
									name = L["Health"]
								},
								health_backdrop = {
									order = 11,
									type = "color",
									name = L["Health Backdrop"]
								},
								tapped = {
									order = 12,
									type = "color",
									name = L["Tapped"]
								},
								disconnected = {
									order = 13,
									type = "color",
									name = L["Disconnected"]
								},
								health_backdrop_dead = {
									order = 14,
									type = "color",
									name = L["Custom Dead Backdrop"],
									desc = L["Use this backdrop color for units that are dead or ghosts."]
								}
							}
						},
						powerGroup = {
							order = 8,
							type = "group",
							guiInline = true,
							name = L["Powers"],
							get = function(info)
								local t = E.db.unitframe.colors.power[ info[#info] ];
								local d = P.unitframe.colors.power[ info[#info] ];
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b;
							end,
							set = function(info, r, g, b)
								E.db.general[ info[#info] ] = {};
								local t = E.db.unitframe.colors.power[ info[#info] ];
								t.r, t.g, t.b = r, g, b;
								UF:Update_AllFrames();
							end,
							args = {
								powerclass = {
									order = 1,
									type = "toggle",
									name = L["Class Power"],
									desc = L["Color power by classcolor or reaction."],
									get = function(info) return E.db.unitframe.colors[ info[#info] ]; end,
									set = function(info, value) E.db.unitframe.colors[ info[#info] ] = value; UF:Update_AllFrames(); end
								},
								transparentPower = {
									order = 2,
									type = "toggle",
									name = L["Transparent"],
									desc = L["Make textures transparent."],
									get = function(info) return E.db.unitframe.colors[ info[#info] ]; end,
									set = function(info, value) E.db.unitframe.colors[ info[#info] ] = value; UF:Update_AllFrames(); end
								},
								MANA = {
									order = 3,
									name = MANA,
									type = "color"
								},
								RAGE = {
									order = 4,
									name = RAGE,
									type = "color"
								},
								FOCUS = {
									order = 5,
									name = FOCUS,
									type = "color"
								},
								ENERGY = {
									order = 6,
									name = ENERGY,
									type = "color",
								},
								RUNIC_POWER = {
									order = 7,
									name = RUNIC_POWER,
									type = "color"
								}
							}
						},
						reactionGroup = {
							order = 9,
							type = "group",
							guiInline = true,
							name = L["Reactions"],
							get = function(info)
								local t = E.db.unitframe.colors.reaction[ info[#info] ];
								local d = P.unitframe.colors.reaction[ info[#info] ];
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b;
							end,
							set = function(info, r, g, b)
								E.db.general[ info[#info] ] = {};
								local t = E.db.unitframe.colors.reaction[ info[#info] ];
								t.r, t.g, t.b = r, g, b;
								UF:Update_AllFrames();
							end,
							args = {
								BAD = {
									order = 1,
									name = L["Bad"],
									type = "color"
								},
								NEUTRAL = {
									order = 2,
									name = L["Neutral"],
									type = "color"
								},
								GOOD = {
									order = 3,
									name = L["Good"],
									type = "color"
								}
							}
						},
						castBars = {
							order = 9,
							type = "group",
							guiInline = true,
							name = L["Castbar"],
							get = function(info)
								local t = E.db.unitframe.colors[ info[#info] ];
								local d = P.unitframe.colors[ info[#info] ];
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b;
							end,
							set = function(info, r, g, b)
								E.db.general[ info[#info] ] = {}
								local t = E.db.unitframe.colors[ info[#info] ];
								t.r, t.g, t.b = r, g, b;
								UF:Update_AllFrames();
							end,
							args = {
								castClassColor = {
									order = 1,
									type = "toggle",
									name = L["Class Castbars"],
									desc = L["Color castbars by the class or reaction type of the unit."],
									get = function(info) return E.db.unitframe.colors[ info[#info] ] end,
									set = function(info, value) E.db.unitframe.colors[ info[#info] ] = value; UF:Update_AllFrames(); end
								},
								transparentCastbar = {
									order = 2,
									type = "toggle",
									name = L["Transparent"],
									desc = L["Make textures transparent."],
									get = function(info) return E.db.unitframe.colors[ info[#info] ] end,
									set = function(info, value) E.db.unitframe.colors[ info[#info] ] = value; UF:Update_AllFrames(); end
								},
								castColor = {
									order = 3,
									name = L["Interruptable"],
									type = "color"
								},
								castNoInterrupt = {
									order = 4,
									name = L["Non-Interruptable"],
									type = "color"
								},
								castCompleteColor = {
									order = 5,
									name = L["Complete"],
									type = "color"
								},
								castFailColor = {
									order = 6,
									name = L["Fail"],
									type = "color"
								}
							}
						},
						auraBars = {
							order = 9,
							type = "group",
							guiInline = true,
							name = L["Aura Bars"],
							args = {
								transparentAurabars = {
									order = 1,
									type = "toggle",
									name = L["Transparent"],
									desc = L["Make textures transparent."],
									get = function(info) return E.db.unitframe.colors[ info[#info] ]; end,
									set = function(info, value) E.db.unitframe.colors[ info[#info] ] = value; UF:Update_AllFrames(); end,
								},
								auraBarByType = {
									order = 2,
									name = L["By Type"],
									desc = L["Color aurabar debuffs by type."],
									type = "toggle"
								},
								auraBarTurtle = {
									order = 3,
									name = L["Color Turtle Buffs"],
									desc = L["Color all buffs that reduce the unit's incoming damage."],
									type = "toggle"
								},
								BUFFS = {
									order = 10,
									name = L["Buffs"],
									type = "color",
									get = function(info)
										local t = E.db.unitframe.colors.auraBarBuff;
										local d = P.unitframe.colors.auraBarBuff;
										return t.r, t.g, t.b, t.a, d.r, d.g, d.b;
 									end,
									set = function(info, r, g, b)
										if E:CheckClassColor(r, g, b) then
											local classColor = E.myclass == "PRIEST" and E.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass]);
											r = classColor.r;
											g = classColor.g;
											b = classColor.b;
										end

										local t = E.db.unitframe.colors.auraBarBuff;
										t.r, t.g, t.b = r, g, b;

										UF:Update_AllFrames();
									end
								},
								DEBUFFS = {
									order = 11,
									name = L["Debuffs"],
									type = "color",
									get = function(info)
										local t = E.db.unitframe.colors.auraBarDebuff;
										local d = P.unitframe.colors.auraBarDebuff;
										return t.r, t.g, t.b, t.a, d.r, d.g, d.b;
									end,
									set = function(info, r, g, b)
										E.db.general[ info[#info] ] = {};
										local t = E.db.unitframe.colors.auraBarDebuff;
										t.r, t.g, t.b = r, g, b;
										UF:Update_AllFrames();
									end
								},
								auraBarTurtleColor = {
									order = 12,
									name = L["Turtle Color"],
									type = "color",
									get = function(info)
										local t = E.db.unitframe.colors.auraBarTurtleColor;
										local d = P.unitframe.colors.auraBarTurtleColor;
										return t.r, t.g, t.b, t.a, d.r, d.g, d.b;
									end,
									set = function(info, r, g, b)
										E.db.general[ info[#info] ] = {};
										local t = E.db.unitframe.colors.auraBarTurtleColor;
										t.r, t.g, t.b = r, g, b;
										UF:Update_AllFrames();
									end
								}
							}
						},
						healPrediction = {
							order = 12,
							name = L["Heal Prediction"],
							type = "group",
							get = function(info)
								local t = E.db.unitframe.colors.healPrediction[ info[#info] ];
								local d = P.unitframe.colors.healPrediction[ info[#info] ];
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a;
							end,
							set = function(info, r, g, b, a)
								local t = E.db.unitframe.colors.healPrediction[ info[#info] ];
								t.r, t.g, t.b, t.a = r, g, b, a;
								UF:Update_AllFrames();
							end,
							args = {
								personal = {
									order = 1,
									name = L["Personal"],
									type = "color",
									hasAlpha = true,
								},
								others = {
									order = 2,
									name = L["Others"],
									type = "color",
									hasAlpha = true,
								}
							}
						}
					}
				}
			}
		}
	}
};

E.Options.args.unitframe.args.player = {
	name = L["Player Frame"],
	type = "group",
	order = 300,
	childGroups = "select",
	get = function(info) return E.db.unitframe.units["player"][ info[#info] ]; end,
	set = function(info, value) E.db.unitframe.units["player"][ info[#info] ] = value; UF:CreateAndUpdateUF("player"); end,
	disabled = function() return not E.private.unitframe.enable end,
	args = {
		copyFrom = {
			type = "select",
			order = 1,
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = UF["units"],
			set = function(info, value) UF:MergeUnitSettings(value, "player"); end
		},
		resetSettings = {
			type = "execute",
			order = 2,
			name = L["Restore Defaults"],
			func = function(info, value) UF:ResetUnitSettings("player"); E:ResetMovers(L["Player Frame"]); end
		},
		showAuras = {
			order = 3,
			type = "execute",
			name = L["Show Auras"],
			func = function()
				local frame = ElvUF_Player;
				if(frame.forceShowAuras) then
					frame.forceShowAuras = nil;
				else
					frame.forceShowAuras = true;
				end

				UF:CreateAndUpdateUF("player");
			end
		},
		enable = {
			type = "toggle",
			order = 4,
			name = L["Enable"]
		},
		width = {
			order = 5,
			name = L["Width"],
			type = "range",
			min = 50, max = 500, step = 1,
			set = function(info, value)
				if(E.db.unitframe.units["player"].castbar.width == E.db.unitframe.units["player"][ info[#info] ]) then
					E.db.unitframe.units["player"].castbar.width = value;
				end

				E.db.unitframe.units["player"][ info[#info] ] = value;
				UF:CreateAndUpdateUF("player");
			end
		},
		height = {
			order = 6,
			name = L["Height"],
			type = "range",
			min = 10, max = 250, step = 1
		},
		combatfade = {
			order = 7,
			name = L["Combat Fade"],
			desc = L["Fade the unitframe when out of combat, not casting, no target exists."],
			type = "toggle",
			set = function(info, value)
				E.db.unitframe.units["player"][ info[#info] ] = value;
				UF:CreateAndUpdateUF("player");

				if(value == true) then
					ElvUF_Pet:SetParent(ElvUF_Player);
				else
					ElvUF_Pet:SetParent(ElvUF_Parent) ;
				end
			end
		},
		healPrediction = {
			order = 8,
			type = "toggle",
			name = L["Heal Prediction"],
			desc = L["Show a incomming heal prediction bar on the unitframe. Also display a slightly different colored bar for incoming overheals."]
		},
		hideonnpc = {
			type = "toggle",
			order = 9,
			name = L["Text Toggle On NPC"],
			desc = L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."],
			get = function(info) return E.db.unitframe.units["player"]["power"].hideonnpc end,
			set = function(info, value) E.db.unitframe.units["player"]["power"].hideonnpc = value; UF:CreateAndUpdateUF("player") end
		},
		restIcon = {
			order = 10,
			type = "toggle",
			name = L["Rest Icon"],
			desc = L["Display the rested icon on the unitframe."]
		},
		combatIcon = {
			order = 11,
			type = "toggle",
			name = L["Combat Icon"],
			desc = L["Display the combat icon on the unitframe."]
		},
		threatStyle = {
			order = 12,
			type = "select",
			name = L["Threat Display Mode"],
			values = threatValues,
		},
		smartAuraPosition = {
			order = 13,
			type = "select",
			name = L["Smart Aura Position"],
			desc = L["Will show Buffs in the Debuff position when there are no Debuffs active, or vice versa."],
			values = {
				["DISABLED"] = L["Disabled"],
				["BUFFS_ON_DEBUFFS"] = L["Position Buffs on Debuffs"],
				["DEBUFFS_ON_BUFFS"] = L["Position Debuffs on Buffs"],
			},
		},
		orientation = {
			order = 14,
			type = "select",
			name = L["Frame Orientation"],
			desc = L["Set the orientation of the UnitFrame. If set to automatic it will adjust based on where the frame is located on the screen."],
			values = {
				--["AUTOMATIC"] = L["Automatic"], not sure if i will use this yet
				["LEFT"] = L["Left"],
				["MIDDLE"] = L["Middle"],
				["RIGHT"] = L["Right"]
			}
		},
		colorOverride = {
			order = 15,
			name = L["Class Color Override"],
			desc = L["Override the default class color setting."],
			type = "select",
			values = {
				["USE_DEFAULT"] = L["Use Default"],
				["FORCE_ON"] = L["Force On"],
				["FORCE_OFF"] = L["Force Off"]
			}
		},
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, "player"),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, "player"),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, "player"),
		power = GetOptionsTable_Power(true, UF.CreateAndUpdateUF, "player", nil, true),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUF, "player"),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, "player"),
		buffs = GetOptionsTable_Auras(true, "buffs", false, UF.CreateAndUpdateUF, "player"),
		debuffs = GetOptionsTable_Auras(true, "debuffs", false, UF.CreateAndUpdateUF, "player"),
		castbar = GetOptionsTable_Castbar(true, UF.CreateAndUpdateUF, "player"),
		aurabar = GetOptionsTable_AuraBars(true, UF.CreateAndUpdateUF, "player"),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateUF, "player"),
		classbar = {
			order = 750,
			type = "group",
			name = L["Classbar"],
			get = function(info) return E.db.unitframe.units["player"]["classbar"][ info[#info] ]; end,
			set = function(info, value) E.db.unitframe.units["player"]["classbar"][ info[#info] ] = value; UF:CreateAndUpdateUF("player"); end,
			args = {
				enable = {
					type = "toggle",
					order = 1,
					name = L["Enable"]
				},
				height = {
					type = "range",
					order = 2,
					name = L["Height"],
					min = ((E.db.unitframe.thinBorders or E.PixelMode) and 3 or 7),
					max = (E.db.unitframe.units['player']['classbar'].detachFromFrame and 300 or 30),
					step = 1,
				},
				fill = {
					type = "select",
					order = 3,
					name = L["Fill"],
					values = {
						["fill"] = L["Filled"],
						["spaced"] = L["Spaced"]
					}
				},
				autoHide = {
					order = 4,
					type = 'toggle',
					name = L["Auto-Hide"],
				},
				detachFromFrame = {
					type = "toggle",
					order = 5,
					name = L["Detach From Frame"],
					set = function(info, value)
						if value == true then
							E.Options.args.unitframe.args.player.args.classbar.args.height.max = 300
						else
							E.Options.args.unitframe.args.player.args.classbar.args.height.max = 30
						end
						E.db.unitframe.units['player']['classbar'][ info[#info] ] = value;
						UF:CreateAndUpdateUF('player')
					end,
				},
				verticalOrientation = {
					order = 6,
					type = "toggle",
					name = L["Vertical Orientation"],
					disabled = function() return not E.db.unitframe.units['player']['classbar'].detachFromFrame end,
 				},
				detachedWidth = {
					type = "range",
					order = 7,
					name = L["Detached Width"],
					disabled = function() return not E.db.unitframe.units["player"]["classbar"].detachFromFrame; end,
					min = ((E.db.unitframe.thinBorders or E.PixelMode) and 3 or 7), max = 800, step = 1,
				},
				parent = {
					type = "select",
					order = 8,
					name = L["Parent"],
					desc = L["Choose UIPARENT to prevent it from hiding with the unitframe."],
					disabled = function() return not E.db.unitframe.units["player"]["classbar"].detachFromFrame; end,
					values = {
						["FRAME"] = "FRAME",
						["UIPARENT"] = "UIPARENT"
					},
				},
				strataAndLevel = {
					order = 20,
					type = "group",
					name = L["Strata and Level"],
					get = function(info) return E.db.unitframe.units['player']['classbar']["strataAndLevel"][ info[#info] ] end,
					set = function(info, value) E.db.unitframe.units['player']['classbar']["strataAndLevel"][ info[#info] ] = value; UF:CreateAndUpdateUF('player') end,
					guiInline = true,
					disabled = function() return not E.db.unitframe.units['player']['classbar'].detachFromFrame end,
					hidden = function() return not E.db.unitframe.units['player']['classbar'].detachFromFrame end,
					args = {
						useCustomStrata = {
							order = 1,
							type = "toggle",
							name = L["Use Custom Strata"],
						},
						frameStrata = {
							order = 2,
							type = "select",
							name = L["Frame Strata"],
							values = {
								["BACKGROUND"] = "BACKGROUND",
								["LOW"] = "LOW",
								["MEDIUM"] = "MEDIUM",
								["HIGH"] = "HIGH",
								["DIALOG"] = "DIALOG",
								["TOOLTIP"] = "TOOLTIP",
							},
						},
						spacer = {
							order = 3,
							type = "description",
							name = "",
						},
						useCustomLevel = {
							order = 4,
							type = "toggle",
							name = L["Use Custom Level"],
						},
						frameLevel = {
							order = 5,
							type = "range",
							name = L["Frame Level"],
							min = 2, max = 128, step = 1,
						},
					},
				},
			},
		},
		pvp = {
			order = 850,
			type = "group",
			name = PVP,
			get = function(info) return E.db.unitframe.units["player"]["pvp"][ info[#info] ]; end,
			set = function(info, value) E.db.unitframe.units["player"]["pvp"][ info[#info] ] = value; UF:CreateAndUpdateUF("player"); end,
			args = {
				position = {
					type = "select",
					order = 2,
					name = L["Position"],
					values = positionValues
				},
				text_format = {
					order = 100,
					name = L["Text Format"],
					type = "input",
					width = "full",
					desc = L["TEXT_FORMAT_DESC"]
				}
			}
		}
	}
};

E.Options.args.unitframe.args.target = {
	name = L["Target Frame"],
	type = "group",
	order = 400,
	childGroups = "select",
	get = function(info) return E.db.unitframe.units["target"][ info[#info] ]; end,
	set = function(info, value) E.db.unitframe.units["target"][ info[#info] ] = value; UF:CreateAndUpdateUF("target"); end,
	disabled = function() return not E.private.unitframe.enable; end,
	args = {
		copyFrom = {
			type = "select",
			order = 1,
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = UF["units"],
			set = function(info, value) UF:MergeUnitSettings(value, "target"); end
		},
		resetSettings = {
			type = "execute",
			order = 2,
			name = L["Restore Defaults"],
			func = function(info, value) UF:ResetUnitSettings("target"); E:ResetMovers(L["Target Frame"]); end
		},
		showAuras = {
			order = 3,
			type = "execute",
			name = L["Show Auras"],
			func = function()
				local frame = ElvUF_Target;
				if(frame.forceShowAuras) then
					frame.forceShowAuras = nil;
				else
					frame.forceShowAuras = true;
				end

				UF:CreateAndUpdateUF("target");
			end
		},
		enable = {
			order = 4,
			type = "toggle",
			name = L["Enable"]
		},
		width = {
			order = 5,
			name = L["Width"],
			type = "range",
			min = 50, max = 500, step = 1,
			set = function(info, value)
				if E.db.unitframe.units["target"].castbar.width == E.db.unitframe.units["target"][ info[#info] ] then
					E.db.unitframe.units["target"].castbar.width = value;
				end

				E.db.unitframe.units["target"][ info[#info] ] = value;
				UF:CreateAndUpdateUF("target");
			end
		},
		height = {
			order = 6,
			name = L["Height"],
			type = "range",
			min = 10, max = 250, step = 1
		},
		rangeCheck = {
			order = 7,
			type = "toggle",
			name = L["Range Check"],
			desc = L["Check if you are in range to cast spells on this specific unit."]
		},
		healPrediction = {
			order = 8,
			type = "toggle",
			name = L["Heal Prediction"],
			desc = L["Show a incomming heal prediction bar on the unitframe. Also display a slightly different colored bar for incoming overheals."]
		},
		hideonnpc = {
			order = 9,
			type = "toggle",
			name = L["Text Toggle On NPC"],
			desc = L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."],
			get = function(info) return E.db.unitframe.units["target"]["power"].hideonnpc; end,
			set = function(info, value) E.db.unitframe.units["target"]["power"].hideonnpc = value; UF:CreateAndUpdateUF("target"); end
		},
		middleClickFocus = {
			order = 10,
			type = "toggle",
			name = L["Middle Click - Set Focus"],
			desc = L["Middle clicking the unit frame will cause your focus to match the unit."],
			disabled = function() return IsAddOnLoaded("Clique"); end
		},
		threatStyle = {
			type = "select",
			order = 11,
			name = L["Threat Display Mode"],
			values = threatValues
		},
		smartAuraPosition = {
			order = 12,
			type = "select",
			name = L["Smart Aura Position"],
			desc = L["Will show Buffs in the Debuff position when there are no Debuffs active, or vice versa."],
			values = {
				["DISABLED"] = L["Disabled"],
				["BUFFS_ON_DEBUFFS"] = L["Position Buffs on Debuffs"],
				["DEBUFFS_ON_BUFFS"] = L["Position Debuffs on Buffs"]
			}
		},
		orientation = {
			order = 13,
			type = "select",
			name = L["Frame Orientation"],
			desc = L["Set the orientation of the UnitFrame. If set to automatic it will adjust based on where the frame is located on the screen."],
			values = {
				--["AUTOMATIC"] = L["Automatic"], not sure if i will use this yet
				["LEFT"] = L["Left"],
				["MIDDLE"] = L["Middle"],
				["RIGHT"] = L["Right"]
			}
		},
		colorOverride = {
			order = 14,
			name = L["Class Color Override"],
			desc = L["Override the default class color setting."],
			type = "select",
			values = {
				["USE_DEFAULT"] = L["Use Default"],
				["FORCE_ON"] = L["Force On"],
				["FORCE_OFF"] = L["Force Off"]
			}
		},
		combobar = {
			order = 850,
			type = "group",
			name = L["Combobar"],
			get = function(info) return E.db.unitframe.units["target"]["combobar"][ info[#info] ]; end,
			set = function(info, value) E.db.unitframe.units["target"]["combobar"][ info[#info] ] = value; UF:CreateAndUpdateUF("target"); end,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"]
				},
				height = {
					order = 2,
					type = "range",
					name = L["Height"],
					min = ((E.db.unitframe.thinBorders or E.PixelMode) and 3 or 7), max = 15, step = 1
				},
				fill = {
					order = 3,
					type = "select",
					name = L["Fill"],
					values = {
						["fill"] = L["Filled"],
						["spaced"] = L["Spaced"],
					},
				},
				autoHide = {
					order = 4,
					type = "toggle",
					name = L["Auto-Hide"]
				},
				detachFromFrame = {
					order = 5,
					type = "toggle",
					name = L["Detach From Frame"]
				},
				detachedWidth = {
					order = 6,
					type = "range",
					name = L["Detached Width"],
					disabled = function() return not E.db.unitframe.units["target"]["combobar"].detachFromFrame; end,
					min = 15, max = 450, step = 1
				}
			}
		},
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, "target"),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, "target"),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, "target"),
		power = GetOptionsTable_Power(true, UF.CreateAndUpdateUF, "target", nil, true),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUF, "target"),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, "target"),
		buffs = GetOptionsTable_Auras(false, "buffs", false, UF.CreateAndUpdateUF, "target"),
		debuffs = GetOptionsTable_Auras(false, "debuffs", false, UF.CreateAndUpdateUF, "target"),
		castbar = GetOptionsTable_Castbar(false, UF.CreateAndUpdateUF, "target"),
		aurabar = GetOptionsTable_AuraBars(false, UF.CreateAndUpdateUF, "target"),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateUF, "target"),
		GPSArrow = GetOptionsTableForNonGroup_GPS("target")
	}
};

E.Options.args.unitframe.args.targettarget = {
	name = L["TargetTarget Frame"],
	type = "group",
	order = 500,
	childGroups = "select",
	get = function(info) return E.db.unitframe.units["targettarget"][ info[#info] ]; end,
	set = function(info, value) E.db.unitframe.units["targettarget"][ info[#info] ] = value; UF:CreateAndUpdateUF("targettarget"); end,
	disabled = function() return not E.private.unitframe.enable end,
	args = {
		copyFrom = {
			order = 1,
			type = "select",
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = UF["units"],
			set = function(info, value) UF:MergeUnitSettings(value, "targettarget"); end,
		},
		resetSettings = {
			order = 2,
			type = "execute",
			name = L["Restore Defaults"],
			func = function(info, value) UF:ResetUnitSettings("targettarget"); E:ResetMovers(L["TargetTarget Frame"]) end,
		},
		showAuras = {
			order = 3,
			type = "execute",
			name = L["Show Auras"],
			func = function()
				local frame = ElvUF_TargetTarget;
				if(frame.forceShowAuras) then
					frame.forceShowAuras = nil;
				else
					frame.forceShowAuras = true;
				end

				UF:CreateAndUpdateUF("targettarget");
			end,
		},
		enable = {
			order = 4,
			type = "toggle",
			name = L["Enable"]
		},
		width = {
			order = 5,
			type = "range",
			name = L["Width"],
			min = 50, max = 500, step = 1
		},
		height = {
			order = 6,
			type = "range",
			name = L["Height"],
			min = 10, max = 250, step = 1
		},
		rangeCheck = {
			order = 7,
			type = "toggle",
			name = L["Range Check"],
			desc = L["Check if you are in range to cast spells on this specific unit."]
		},
		hideonnpc = {
			type = "toggle",
			order = 8,
			name = L["Text Toggle On NPC"],
			desc = L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."],
			get = function(info) return E.db.unitframe.units["targettarget"]["power"].hideonnpc end,
			set = function(info, value) E.db.unitframe.units["targettarget"]["power"].hideonnpc = value; UF:CreateAndUpdateUF("targettarget"); end
		},
		threatStyle = {
			order = 9,
			type = "select",
			name = L["Threat Display Mode"],
			values = threatValues
		},
		smartAuraPosition = {
			order = 10,
			type = "select",
			name = L["Smart Aura Position"],
			desc = L["Will show Buffs in the Debuff position when there are no Debuffs active, or vice versa."],
			values = {
				["DISABLED"] = L["Disabled"],
				["BUFFS_ON_DEBUFFS"] = L["Position Buffs on Debuffs"],
				["DEBUFFS_ON_BUFFS"] = L["Position Debuffs on Buffs"]
			}
		},
		orientation = {
			order = 11,
			type = "select",
			name = L["Frame Orientation"],
			desc = L["Set the orientation of the UnitFrame. If set to automatic it will adjust based on where the frame is located on the screen."],
			values = {
				--["AUTOMATIC"] = L["Automatic"], not sure if i will use this yet
				["LEFT"] = L["Left"],
				["MIDDLE"] = L["Middle"],
				["RIGHT"] = L["Right"]
			}
		},
		colorOverride = {
			order = 12,
			name = L["Class Color Override"],
			desc = L["Override the default class color setting."],
			type = "select",
			values = {
				["USE_DEFAULT"] = L["Use Default"],
				["FORCE_ON"] = L["Force On"],
				["FORCE_OFF"] = L["Force Off"]
			}
		},
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, "targettarget"),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, "targettarget"),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, "targettarget"),
		power = GetOptionsTable_Power(nil, UF.CreateAndUpdateUF, "targettarget"),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUF, "targettarget"),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, "targettarget"),
		buffs = GetOptionsTable_Auras(false, "buffs", false, UF.CreateAndUpdateUF, "targettarget"),
		debuffs = GetOptionsTable_Auras(false, "debuffs", false, UF.CreateAndUpdateUF, "targettarget"),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateUF, "targettarget")
	}
};

E.Options.args.unitframe.args.targettargettarget = {
	name = L["TargetTargetTarget Frame"],
	type = "group",
	order = 550,
	childGroups = "select",
	get = function(info) return E.db.unitframe.units["targettargettarget"][ info[#info] ]; end,
	set = function(info, value) E.db.unitframe.units["targettargettarget"][ info[#info] ] = value; UF:CreateAndUpdateUF("targettargettarget"); end,
	disabled = function() return not E.private.unitframe.enable end,
	args = {
		copyFrom = {
			order = 1,
			type = "select",
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = UF["units"],
			set = function(info, value) UF:MergeUnitSettings(value, "targettargettarget"); end
		},
		resetSettings = {
			type = "execute",
			order = 2,
			name = L["Restore Defaults"],
			func = function(info, value) UF:ResetUnitSettings("targettargettarget"); E:ResetMovers(L["TargetTargetTarget Frame"]); end
		},
		showAuras = {
			order = 3,
			type = "execute",
			name = L["Show Auras"],
			func = function()
				local frame = ElvUF_TargetTargetTarget;
				if(frame.forceShowAuras) then
					frame.forceShowAuras = nil;
				else
					frame.forceShowAuras = true;
				end

				UF:CreateAndUpdateUF("targettargettarget");
			end
		},
		enable = {
			order = 4,
			type = "toggle",
			name = L["Enable"]
		},
		width = {
			order = 5,
			type = "range",
			name = L["Width"],
			min = 50, max = 500, step = 1
		},
		height = {
			order = 6,
			type = "range",
			name = L["Height"],
			min = 10, max = 250, step = 1
		},
		rangeCheck = {
			order = 7,
			type = "toggle",
			name = L["Range Check"],
			desc = L["Check if you are in range to cast spells on this specific unit."]
		},
		hideonnpc = {
			order = 8,
			type = "toggle",
			name = L["Text Toggle On NPC"],
			desc = L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."],
			get = function(info) return E.db.unitframe.units["targettargettarget"]["power"].hideonnpc end,
			set = function(info, value) E.db.unitframe.units["targettargettarget"]["power"].hideonnpc = value; UF:CreateAndUpdateUF("targettargettarget"); end
		},
		threatStyle = {
			order = 9,
			type = "select",
			name = L["Threat Display Mode"],
			values = threatValues
		},
		smartAuraPosition = {
			order = 10,
			type = "select",
			name = L["Smart Aura Position"],
			desc = L["Will show Buffs in the Debuff position when there are no Debuffs active, or vice versa."],
			values = {
				["DISABLED"] = L["Disabled"],
				["BUFFS_ON_DEBUFFS"] = L["Position Buffs on Debuffs"],
				["DEBUFFS_ON_BUFFS"] = L["Position Debuffs on Buffs"]
			}
		},
		orientation = {
			order = 11,
			type = "select",
			name = L["Frame Orientation"],
			desc = L["Set the orientation of the UnitFrame. If set to automatic it will adjust based on where the frame is located on the screen."],
			values = {
				--["AUTOMATIC"] = L["Automatic"], not sure if i will use this yet
				["LEFT"] = L["Left"],
				["MIDDLE"] = L["Middle"],
				["RIGHT"] = L["Right"]
			}
		},
		colorOverride = {
			order = 12,
			name = L["Class Color Override"],
			desc = L["Override the default class color setting."],
			type = "select",
			values = {
				["USE_DEFAULT"] = L["Use Default"],
				["FORCE_ON"] = L["Force On"],
				["FORCE_OFF"] = L["Force Off"]
			}
		},
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, "targettargettarget"),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, "targettargettarget"),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, "targettargettarget"),
		power = GetOptionsTable_Power(nil, UF.CreateAndUpdateUF, "targettargettarget"),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUF, "targettargettarget"),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, "targettargettarget"),
		buffs = GetOptionsTable_Auras(false, "buffs", false, UF.CreateAndUpdateUF, "targettargettarget"),
		debuffs = GetOptionsTable_Auras(false, "debuffs", false, UF.CreateAndUpdateUF, "targettargettarget"),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateUF, "targettargettarget")
	}
};

E.Options.args.unitframe.args.focus = {
	name = L["Focus Frame"],
	type = "group",
	order = 600,
	childGroups = "select",
	get = function(info) return E.db.unitframe.units["focus"][ info[#info] ]; end,
	set = function(info, value) E.db.unitframe.units["focus"][ info[#info] ] = value; UF:CreateAndUpdateUF("focus"); end,
	disabled = function() return not E.private.unitframe.enable end,
	args = {
		copyFrom = {
			order = 1,
			type = "select",
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = UF["units"],
			set = function(info, value) UF:MergeUnitSettings(value, "focus"); end
		},
		resetSettings = {
			order = 2,
			type = "execute",
			name = L["Restore Defaults"],
			func = function(info, value) UF:ResetUnitSettings("focus"); E:ResetMovers(L["Focus Frame"]); end
		},
		showAuras = {
			order = 3,
			type = "execute",
			name = L["Show Auras"],
			func = function()
				local frame = ElvUF_Focus;
				if(frame.forceShowAuras) then
					frame.forceShowAuras = nil;
				else
					frame.forceShowAuras = true;
				end

				UF:CreateAndUpdateUF("focus");
			end,
		},
		enable = {
			order = 4,
			type = "toggle",
			name = L["Enable"]
		},
		width = {
			order = 5,
			type = "range",
			name = L["Width"],
			min = 50, max = 500, step = 1
		},
		height = {
			order = 6,
			type = "range",
			name = L["Height"],
			min = 10, max = 250, step = 1
		},
		rangeCheck = {
			order = 7,
			type = "toggle",
			name = L["Range Check"],
			desc = L["Check if you are in range to cast spells on this specific unit."]
		},
		healPrediction = {
			order = 8,
			type = "toggle",
			name = L["Heal Prediction"],
			desc = L["Show a incomming heal prediction bar on the unitframe. Also display a slightly different colored bar for incoming overheals."]
		},
		hideonnpc = {
			order = 9,
			type = "toggle",
			name = L["Text Toggle On NPC"],
			desc = L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."],
			get = function(info) return E.db.unitframe.units["focus"]["power"].hideonnpc end,
			set = function(info, value) E.db.unitframe.units["focus"]["power"].hideonnpc = value; UF:CreateAndUpdateUF("focus"); end,
		},
		threatStyle = {
			order = 10,
			type = "select",
			name = L["Threat Display Mode"],
			values = threatValues
		},
		smartAuraPosition = {
			order = 11,
			type = "select",
			name = L["Smart Aura Position"],
			desc = L["Will show Buffs in the Debuff position when there are no Debuffs active, or vice versa."],
			values = {
				["DISABLED"] = L["Disabled"],
				["BUFFS_ON_DEBUFFS"] = L["Position Buffs on Debuffs"],
				["DEBUFFS_ON_BUFFS"] = L["Position Debuffs on Buffs"]
			}
		},
		orientation = {
			order = 12,
			type = "select",
			name = L["Frame Orientation"],
			desc = L["Set the orientation of the UnitFrame. If set to automatic it will adjust based on where the frame is located on the screen."],
			values = {
				--["AUTOMATIC"] = L["Automatic"], not sure if i will use this yet
				["LEFT"] = L["Left"],
				["MIDDLE"] = L["Middle"],
				["RIGHT"] = L["Right"],
			},
		},
		colorOverride = {
			order = 12,
			name = L["Class Color Override"],
			desc = L["Override the default class color setting."],
			type = "select",
			values = {
				["USE_DEFAULT"] = L["Use Default"],
				["FORCE_ON"] = L["Force On"],
				["FORCE_OFF"] = L["Force Off"]
			}
		},
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, "focus"),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, "focus"),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, "focus"),
		power = GetOptionsTable_Power(nil, UF.CreateAndUpdateUF, "focus"),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUF, "focus"),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, "focus"),
		buffs = GetOptionsTable_Auras(false, "buffs", false, UF.CreateAndUpdateUF, "focus"),
		debuffs = GetOptionsTable_Auras(false, "debuffs", false, UF.CreateAndUpdateUF, "focus"),
		castbar = GetOptionsTable_Castbar(false, UF.CreateAndUpdateUF, "focus"),
		aurabar = GetOptionsTable_AuraBars(false, UF.CreateAndUpdateUF, "focus"),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateUF, "focus"),
		GPSArrow = GetOptionsTableForNonGroup_GPS("focus")
	}
};

E.Options.args.unitframe.args.focustarget = {
	name = L["FocusTarget Frame"],
	type = "group",
	order = 700,
	childGroups = "select",
	get = function(info) return E.db.unitframe.units["focustarget"][ info[#info] ]; end,
	set = function(info, value) E.db.unitframe.units["focustarget"][ info[#info] ] = value; UF:CreateAndUpdateUF("focustarget"); end,
	disabled = function() return not E.private.unitframe.enable end,
	args = {
		copyFrom = {
			order = 1,
			type = "select",
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = UF["units"],
			set = function(info, value) UF:MergeUnitSettings(value, "focustarget"); end
		},
		resetSettings = {
			order = 2,
			type = "execute",
			name = L["Restore Defaults"],
			func = function(info, value) UF:ResetUnitSettings("focustarget"); E:ResetMovers(L["FocusTarget Frame"]); end
		},
		showAuras = {
			order = 3,
			type = "execute",
			name = L["Show Auras"],
			func = function()
				local frame = ElvUF_FocusTarget;
				if(frame.forceShowAuras) then
					frame.forceShowAuras = nil;
				else
					frame.forceShowAuras = true;
				end

				UF:CreateAndUpdateUF("focustarget");
			end
		},
		enable = {
			order = 4,
			type = "toggle",
			name = L["Enable"],
		},
		width = {
			order = 5,
			type = "range",
			name = L["Width"],
			min = 50, max = 500, step = 1
		},
		height = {
			order = 6,
			type = "range",
			name = L["Height"],
			min = 10, max = 250, step = 1
		},
		rangeCheck = {
			order = 7,
			type = "toggle",
			name = L["Range Check"],
			desc = L["Check if you are in range to cast spells on this specific unit."]
		},
		hideonnpc = {
			order = 8,
			type = "toggle",
			name = L["Text Toggle On NPC"],
			desc = L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."],
			get = function(info) return E.db.unitframe.units["focustarget"]["power"].hideonnpc end,
			set = function(info, value) E.db.unitframe.units["focustarget"]["power"].hideonnpc = value; UF:CreateAndUpdateUF("focustarget"); end
		},
		threatStyle = {
			type = "select",
			order = 9,
			name = L["Threat Display Mode"],
			values = threatValues
		},
		smartAuraPosition = {
			order = 10,
			type = "select",
			name = L["Smart Aura Position"],
			desc = L["Will show Buffs in the Debuff position when there are no Debuffs active, or vice versa."],
			values = {
				["DISABLED"] = L["Disabled"],
				["BUFFS_ON_DEBUFFS"] = L["Position Buffs on Debuffs"],
				["DEBUFFS_ON_BUFFS"] = L["Position Debuffs on Buffs"]
			}
		},
		orientation = {
			order = 11,
			type = "select",
			name = L["Frame Orientation"],
			desc = L["Set the orientation of the UnitFrame. If set to automatic it will adjust based on where the frame is located on the screen."],
			values = {
				--["AUTOMATIC"] = L["Automatic"], not sure if i will use this yet
				["LEFT"] = L["Left"],
				["MIDDLE"] = L["Middle"],
				["RIGHT"] = L["Right"]
			}
		},
		colorOverride = {
			order = 12,
			name = L["Class Color Override"],
			desc = L["Override the default class color setting."],
			type = "select",
			values = {
				["USE_DEFAULT"] = L["Use Default"],
				["FORCE_ON"] = L["Force On"],
				["FORCE_OFF"] = L["Force Off"]
			}
		},
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, "focustarget"),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, "focustarget"),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, "focustarget"),
		power = GetOptionsTable_Power(false, UF.CreateAndUpdateUF, "focustarget"),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUF, "focustarget"),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, "focustarget"),
		buffs = GetOptionsTable_Auras(false, "buffs", false, UF.CreateAndUpdateUF, "focustarget"),
		debuffs = GetOptionsTable_Auras(false, "debuffs", false, UF.CreateAndUpdateUF, "focustarget"),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateUF, "focustarget")
	}
};

E.Options.args.unitframe.args.pet = {
	name = L["Pet Frame"],
	type = "group",
	order = 800,
	childGroups = "select",
	get = function(info) return E.db.unitframe.units["pet"][ info[#info] ] end,
	set = function(info, value) E.db.unitframe.units["pet"][ info[#info] ] = value; UF:CreateAndUpdateUF("pet"); end,
	disabled = function() return not E.private.unitframe.enable end,
	args = {
		copyFrom = {
			type = "select",
			order = 1,
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = UF["units"],
			set = function(info, value) UF:MergeUnitSettings(value, "pet"); end
		},
		resetSettings = {
			type = "execute",
			order = 2,
			name = L["Restore Defaults"],
			func = function(info, value) UF:ResetUnitSettings("pet"); E:ResetMovers(L["Pet Frame"]); end
		},
		showAuras = {
			order = 3,
			type = "execute",
			name = L["Show Auras"],
			func = function()
				local frame = ElvUF_Pet;
				if(frame.forceShowAuras) then
					frame.forceShowAuras = nil;
				else
					frame.forceShowAuras = true;
				end

				UF:CreateAndUpdateUF("pet");
			end,
		},
		enable = {
			order = 4,
			type = "toggle",
			name = L["Enable"]
		},
		width = {
			order = 5,
			type = "range",
			name = L["Width"],
			min = 50, max = 500, step = 1
		},
		height = {
			order = 6,
			type = "range",
			name = L["Height"],
			min = 10, max = 250, step = 1
		},
		rangeCheck = {
			order = 7,
			type = "toggle",
			name = L["Range Check"],
			desc = L["Check if you are in range to cast spells on this specific unit."]
		},
		healPrediction = {
			order = 8,
			type = "toggle",
			name = L["Heal Prediction"],
			desc = L["Show a incomming heal prediction bar on the unitframe. Also display a slightly different colored bar for incoming overheals."]
		},
		hideonnpc = {
			order = 9,
			type = "toggle",
			name = L["Text Toggle On NPC"],
			desc = L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."],
			get = function(info) return E.db.unitframe.units["pet"]["power"].hideonnpc end,
			set = function(info, value) E.db.unitframe.units["pet"]["power"].hideonnpc = value; UF:CreateAndUpdateUF("pet"); end
		},
		threatStyle = {
			order = 10,
			type = "select",
			name = L["Threat Display Mode"],
			values = threatValues
		},
		smartAuraPosition = {
			order = 11,
			type = "select",
			name = L["Smart Aura Position"],
			desc = L["Will show Buffs in the Debuff position when there are no Debuffs active, or vice versa."],
			values = {
				["DISABLED"] = L["Disabled"],
				["BUFFS_ON_DEBUFFS"] = L["Position Buffs on Debuffs"],
				["DEBUFFS_ON_BUFFS"] = L["Position Debuffs on Buffs"]
			}
		},
		orientation = {
			order = 12,
			type = "select",
			name = L["Frame Orientation"],
			desc = L["Set the orientation of the UnitFrame. If set to automatic it will adjust based on where the frame is located on the screen."],
			values = {
				--["AUTOMATIC"] = L["Automatic"], not sure if i will use this yet
				["LEFT"] = L["Left"],
				["MIDDLE"] = L["Middle"],
				["RIGHT"] = L["Right"]
			}
		},
		colorOverride = {
			order = 13,
			name = L["Class Color Override"],
			desc = L["Override the default class color setting."],
			type = "select",
			values = {
				["USE_DEFAULT"] = L["Use Default"],
				["FORCE_ON"] = L["Force On"],
				["FORCE_OFF"] = L["Force Off"]
			}
		},
		buffIndicator = {
			order = 600,
			type = "group",
			name = L["Buff Indicator"],
			get = function(info) return E.db.unitframe.units["pet"]["buffIndicator"][ info[#info] ]; end,
			set = function(info, value) E.db.unitframe.units["pet"]["buffIndicator"][ info[#info] ] = value; UF:CreateAndUpdateUF("pet"); end,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"]
				},
				size = {
					order = 2,
					type = "range",
					name = L["Size"],
					desc = L["Size of the indicator icon."],
					min = 4, max = 50, step = 1
				},
				fontSize = {
					order = 3,
					type = "range",
					name = L["Font Size"],
					min = 7, max = 22, step = 1
				}
			}
		},
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, "pet"),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, "pet"),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, "pet"),
		power = GetOptionsTable_Power(false, UF.CreateAndUpdateUF, "pet"),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUF, "pet"),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, "pet"),
		buffs = GetOptionsTable_Auras(true, "buffs", false, UF.CreateAndUpdateUF, "pet"),
		debuffs = GetOptionsTable_Auras(true, "debuffs", false, UF.CreateAndUpdateUF, "pet"),
		castbar = GetOptionsTable_Castbar(false, UF.CreateAndUpdateUF, "pet")
	}
};

E.Options.args.unitframe.args.pettarget = {
	name = L["PetTarget Frame"],
	type = "group",
	order = 900,
	childGroups = "select",
	get = function(info) return E.db.unitframe.units["pettarget"][ info[#info] ]; end,
	set = function(info, value) E.db.unitframe.units["pettarget"][ info[#info] ] = value; UF:CreateAndUpdateUF("pettarget"); end,
	disabled = function() return not E.private.unitframe.enable end,
	args = {
		copyFrom = {
			type = "select",
			order = 1,
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = UF["units"],
			set = function(info, value) UF:MergeUnitSettings(value, "pettarget"); end
		},
		resetSettings = {
			order = 2,
			type = "execute",
			name = L["Restore Defaults"],
			func = function(info, value) UF:ResetUnitSettings("pettarget"); E:ResetMovers(L["PetTarget Frame"]); end
		},
		showAuras = {
			order = 3,
			type = "execute",
			name = L["Show Auras"],
			func = function()
				local frame = ElvUF_PetTarget;
				if(frame.forceShowAuras) then
					frame.forceShowAuras = nil;
				else
					frame.forceShowAuras = true;
				end

				UF:CreateAndUpdateUF("pettarget");
			end,
		},
		enable = {
			order = 4,
			type = "toggle",
			name = L["Enable"]
		},
		width = {
			order = 5,
			type = "range",
			name = L["Width"],
			min = 50, max = 500, step = 1
		},
		height = {
			order = 6,
			type = "range",
			name = L["Height"],
			min = 10, max = 250, step = 1
		},
		rangeCheck = {
			order = 7,
			type = "toggle",
			name = L["Range Check"],
			desc = L["Check if you are in range to cast spells on this specific unit."]
		},
		hideonnpc = {
			order = 9,
			type = "toggle",
			name = L["Text Toggle On NPC"],
			desc = L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."],
			get = function(info) return E.db.unitframe.units["pettarget"]["power"].hideonnpc end,
			set = function(info, value) E.db.unitframe.units["pettarget"]["power"].hideonnpc = value; UF:CreateAndUpdateUF("pettarget"); end
		},
		threatStyle = {
			order = 10,
			type = "select",
			name = L["Threat Display Mode"],
			values = threatValues
		},
		smartAuraPosition = {
			order = 11,
			type = "select",
			name = L["Smart Aura Position"],
			desc = L["Will show Buffs in the Debuff position when there are no Debuffs active, or vice versa."],
			values = {
				["DISABLED"] = L["Disabled"],
				["BUFFS_ON_DEBUFFS"] = L["Position Buffs on Debuffs"],
				["DEBUFFS_ON_BUFFS"] = L["Position Debuffs on Buffs"]
			}
		},
		orientation = {
			order = 12,
			type = "select",
			name = L["Frame Orientation"],
			desc = L["Set the orientation of the UnitFrame. If set to automatic it will adjust based on where the frame is located on the screen."],
			values = {
				--["AUTOMATIC"] = L["Automatic"], not sure if i will use this yet
				["LEFT"] = L["Left"],
				["MIDDLE"] = L["Middle"],
				["RIGHT"] = L["Right"]
			}
		},
		colorOverride = {
			order = 13,
			name = L["Class Color Override"],
			desc = L["Override the default class color setting."],
			type = "select",
			values = {
				["USE_DEFAULT"] = L["Use Default"],
				["FORCE_ON"] = L["Force On"],
				["FORCE_OFF"] = L["Force Off"]
			}
		},
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUF, "pettarget"),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUF, "pettarget"),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUF, "pettarget"),
		power = GetOptionsTable_Power(false, UF.CreateAndUpdateUF, "pettarget"),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUF, "pettarget"),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUF, "pettarget"),
		buffs = GetOptionsTable_Auras(false, "buffs", false, UF.CreateAndUpdateUF, "pettarget"),
		debuffs = GetOptionsTable_Auras(false, "debuffs", false, UF.CreateAndUpdateUF, "pettarget")
	}
};

E.Options.args.unitframe.args.boss = {
	name = L["Boss Frames"],
	type = "group",
	order = 1000,
	childGroups = "select",
	get = function(info) return E.db.unitframe.units["boss"][ info[#info] ]; end,
	set = function(info, value) E.db.unitframe.units["boss"][ info[#info] ] = value; UF:CreateAndUpdateUFGroup("boss", MAX_BOSS_FRAMES); end,
	disabled = function() return not E.private.unitframe.enable end,
	args = {
		copyFrom = {
			order = 1,
			type = "select",
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = {
				["boss"] = "boss",
				["arena"] = "arena"
			},
			set = function(info, value) UF:MergeUnitSettings(value, "boss"); end
		},
		resetSettings = {
			order = 2,
			type = "execute",
			name = L["Restore Defaults"],
			func = function(info, value) UF:ResetUnitSettings("boss"); E:ResetMovers(L["Boss Frames"]); end,
		},
		displayFrames = {
			order = 3,
			type = "execute",
			name = L["Display Frames"],
			desc = L["Force the frames to show, they will act as if they are the player frame."],
			func = function() UF:ToggleForceShowGroupFrames("boss", 4) end
		},
		enable = {
			order = 4,
			type = "toggle",
			name = L["Enable"]
		},
		width = {
			order = 5,
			type = "range",
			name = L["Width"],
			min = 50, max = 500, step = 1,
			set = function(info, value)
				if(E.db.unitframe.units["boss"].castbar.width == E.db.unitframe.units["boss"][ info[#info] ]) then
					E.db.unitframe.units["boss"].castbar.width = value;
				end

				E.db.unitframe.units["boss"][ info[#info] ] = value;
				UF:CreateAndUpdateUFGroup("boss", MAX_BOSS_FRAMES);
			end
		},
		height = {
			order = 6,
			type = "range",
			name = L["Height"],
			min = 10, max = 250, step = 1
		},
		rangeCheck = {
			order = 7,
			type = "toggle",
			name = L["Range Check"],
			desc = L["Check if you are in range to cast spells on this specific unit."]
		},
		hideonnpc = {
			order = 8,
			type = "toggle",
			name = L["Text Toggle On NPC"],
			desc = L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."],
			get = function(info) return E.db.unitframe.units["boss"]["power"].hideonnpc end,
			set = function(info, value) E.db.unitframe.units["boss"]["power"].hideonnpc = value; UF:CreateAndUpdateUFGroup("boss", MAX_BOSS_FRAMES); end
		},
		growthDirection = {
			order = 9,
			type = "select",
			name = L["Growth Direction"],
			values = {
				["UP"] = L["Bottom to Top"],
				["DOWN"] = L["Top to Bottom"],
				["LEFT"] = L["Right to Left"],
				["RIGHT"] = L["Left to Right"]
			}
		},
		spacing = {
			order = 10,
			type = "range",
			name = L["Spacing"],
			min = 0, max = 400, step = 1
		},
		threatStyle = {
			order = 11,
			type = "select",
			name = L["Threat Display Mode"],
			values = threatValues
		},
		smartAuraPosition = {
			order = 12,
			type = "select",
			name = L["Smart Aura Position"],
			desc = L["Will show Buffs in the Debuff position when there are no Debuffs active, or vice versa."],
			values = {
				["DISABLED"] = L["Disabled"],
				["BUFFS_ON_DEBUFFS"] = L["Position Buffs on Debuffs"],
				["DEBUFFS_ON_BUFFS"] = L["Position Debuffs on Buffs"]
			}
		},
		orientation = {
			order = 13,
			type = "select",
			name = L["Frame Orientation"],
			desc = L["Set the orientation of the UnitFrame. If set to automatic it will adjust based on where the frame is located on the screen."],
			values = {
				--["AUTOMATIC"] = L["Automatic"], not sure if i will use this yet
				["LEFT"] = L["Left"],
				["MIDDLE"] = L["Middle"],
				["RIGHT"] = L["Right"]
			}
		},
		colorOverride = {
			order = 15,
			name = L["Class Color Override"],
			desc = L["Override the default class color setting."],
			type = "select",
			values = {
				["USE_DEFAULT"] = L["Use Default"],
				["FORCE_ON"] = L["Force On"],
				["FORCE_OFF"] = L["Force Off"]
			}
		},
		targetGlow = {
			order = 16,
			type = "toggle",
			name = L["Target Glow"],
			desc = L["Show target glow indicator from this group of frames."],
		},
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUFGroup, "boss", MAX_BOSS_FRAMES),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUFGroup, "boss", MAX_BOSS_FRAMES),
		power = GetOptionsTable_Power(false, UF.CreateAndUpdateUFGroup, "boss", MAX_BOSS_FRAMES),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUFGroup, "boss", MAX_BOSS_FRAMES),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUFGroup, "boss", MAX_BOSS_FRAMES),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUFGroup, "boss", MAX_BOSS_FRAMES),
		buffs = GetOptionsTable_Auras(false, "buffs", false, UF.CreateAndUpdateUFGroup, "boss", MAX_BOSS_FRAMES),
		debuffs = GetOptionsTable_Auras(false, "debuffs", false, UF.CreateAndUpdateUFGroup, "boss", MAX_BOSS_FRAMES),
		castbar = GetOptionsTable_Castbar(false, UF.CreateAndUpdateUFGroup, "boss", MAX_BOSS_FRAMES),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateUFGroup, "boss", MAX_BOSS_FRAMES)
	}
};

E.Options.args.unitframe.args.arena = {
	name = L["Arena Frames"],
	type = "group",
	order = 1100,
	childGroups = "select",
	get = function(info) return E.db.unitframe.units["arena"][ info[#info] ]; end,
	set = function(info, value) E.db.unitframe.units["arena"][ info[#info] ] = value; UF:CreateAndUpdateUFGroup("arena", 5); end,
	disabled = function() return not E.private.unitframe.enable end,
	args = {
		copyFrom = {
			order = 1,
			type = "select",
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = {
				["boss"] = "boss",
				["arena"] = "arena"
			},
			set = function(info, value) UF:MergeUnitSettings(value, "arena"); end
		},
		resetSettings = {
			order = 2,
			type = "execute",
			name = L["Restore Defaults"],
			func = function(info, value) UF:ResetUnitSettings("arena"); E:ResetMovers(L["Arena Frames"]); end
		},
		displayFrames = {
			order = 3,
			type = "execute",
			name = L["Display Frames"],
			desc = L["Force the frames to show, they will act as if they are the player frame."],
			func = function() UF:ToggleForceShowGroupFrames("arena", 5); end
		},
		enable = {
			order = 4,
			type = "toggle",
			name = L["Enable"]
		},
		width = {
			order = 5,
			type = "range",
			name = L["Width"],
			min = 50, max = 500, step = 1,
			set = function(info, value)
				if(E.db.unitframe.units["arena"].castbar.width == E.db.unitframe.units["arena"][ info[#info] ]) then
					E.db.unitframe.units["arena"].castbar.width = value;
				end

				E.db.unitframe.units["arena"][ info[#info] ] = value;
				UF:CreateAndUpdateUFGroup("arena", 5);
			end
		},
		height = {
			order = 6,
			type = "range",
			name = L["Height"],
			min = 10, max = 250, step = 1
		},
		rangeCheck = {
			order = 7,
			type = "toggle",
			name = L["Range Check"],
			desc = L["Check if you are in range to cast spells on this specific unit."]
		},
		healPrediction = {
			order = 8,
			type = "toggle",
			name = L["Heal Prediction"],
			desc = L["Show a incomming heal prediction bar on the unitframe. Also display a slightly different colored bar for incoming overheals."]
		},
		hideonnpc = {
			order = 9,
			type = "toggle",
			name = L["Text Toggle On NPC"],
			desc = L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."],
			get = function(info) return E.db.unitframe.units["arena"]["power"].hideonnpc end,
			set = function(info, value) E.db.unitframe.units["arena"]["power"].hideonnpc = value; UF:CreateAndUpdateUFGroup("arena", 5) end
		},
		growthDirection = {
			order = 10,
			name = L["Growth Direction"],
			type = "select",
			values = {
				["UP"] = L["Bottom to Top"],
				["DOWN"] = L["Top to Bottom"],
				["LEFT"] = L["Right to Left"],
				["RIGHT"] = L["Left to Right"]
			}
		},
		spacing = {
 			order = 11,
			type = "range",
			name = L["Spacing"],
			min = 0, max = 400, step = 1
		},
		colorOverride = {
			order = 12,
			name = L["Class Color Override"],
			desc = L["Override the default class color setting."],
			type = "select",
			values = {
				["USE_DEFAULT"] = L["Use Default"],
				["FORCE_ON"] = L["Force On"],
				["FORCE_OFF"] = L["Force Off"]
			}
		},
		smartAuraPosition = {
			order = 13,
			type = "select",
			name = L["Smart Aura Position"],
			desc = L["Will show Buffs in the Debuff position when there are no Debuffs active, or vice versa."],
			values = {
				["DISABLED"] = L["Disabled"],
				["BUFFS_ON_DEBUFFS"] = L["Position Buffs on Debuffs"],
				["DEBUFFS_ON_BUFFS"] = L["Position Debuffs on Buffs"]
			}
		},
		orientation = {
			order = 14,
			type = "select",
			name = L["Frame Orientation"],
			desc = L["Set the orientation of the UnitFrame. If set to automatic it will adjust based on where the frame is located on the screen."],
			values = {
				--["AUTOMATIC"] = L["Automatic"], not sure if i will use this yet
				["LEFT"] = L["Left"],
				--["MIDDLE"] = L["Middle"], --no way to handle this with trinket
				["RIGHT"] = L["Right"]
			}
		},
		targetGlow = {
			order = 15,
			type = "toggle",
			name = L["Target Glow"],
			desc = L["Show target glow indicator from this group of frames."],
		},
		pvpTrinket = {
			order = 750,
			type = "group",
			name = L["PVP Trinket"],
			get = function(info) return E.db.unitframe.units["arena"]["pvpTrinket"][ info[#info] ]; end,
			set = function(info, value) E.db.unitframe.units["arena"]["pvpTrinket"][ info[#info] ] = value; UF:CreateAndUpdateUFGroup("arena", 5); end,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"]
				},
				position = {
					type = "select",
					order = 2,
					name = L["Position"],
					values = {
						["LEFT"] = L["Left"],
						["RIGHT"] = L["Right"]
					}
				},
				size = {
					order = 3,
					type = "range",
					name = L["Size"],
					min = 10, max = 60, step = 1
				},
				xOffset = {
					order = 4,
					type = "range",
					name = L["xOffset"],
					min = -60, max = 60, step = 1
				},
				yOffset = {
					order = 5,
					type = "range",
					name = L["yOffset"],
					min = -60, max = 60, step = 1
				}
			}
		},
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateUFGroup, "arena", 5),
		health = GetOptionsTable_Health(false, UF.CreateAndUpdateUFGroup, "arena", 5),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateUFGroup, "arena", 5),
		power = GetOptionsTable_Power(false, UF.CreateAndUpdateUFGroup, "arena", 5),
		name = GetOptionsTable_Name(UF.CreateAndUpdateUFGroup, "arena", 5),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateUFGroup, "arena", 5),
		buffs = GetOptionsTable_Auras(false, "buffs", false, UF.CreateAndUpdateUFGroup, "arena", 5),
		debuffs = GetOptionsTable_Auras(false, "debuffs", false, UF.CreateAndUpdateUFGroup, "arena", 5),
		castbar = GetOptionsTable_Castbar(false, UF.CreateAndUpdateUFGroup, "arena", 5)
	}
};

E.Options.args.unitframe.args.party = {
	name = L["Party Frames"],
	type = "group",
	order = 1200,
	childGroups = "select",
	get = function(info) return E.db.unitframe.units["party"][ info[#info] ]; end,
	set = function(info, value) E.db.unitframe.units["party"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("party"); end,
	disabled = function() return not E.private.unitframe.enable end,
	args = {
		configureToggle = {
			type = "execute",
			order = 1,
			name = L["Display Frames"],
			func = function()
				UF:HeaderConfig(ElvUF_Party, ElvUF_Party.forceShow ~= true or nil);
			end,
		},
		resetSettings = {
			order = 2,
			type = "execute",
			name = L["Restore Defaults"],
			func = function(info, value) UF:ResetUnitSettings("party"); E:ResetMovers(L["Party Frames"]) end,
			disabled = function() return not _G["ElvUF_Party"].isForced == false; end,
		},
		copyFrom = {
			order = 3,
			type = "select",
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = {
				["raid"] = L["Raid Frames"],
				["raid40"] = L["Raid-40 Frames"]
			},
			set = function(info, value) UF:MergeUnitSettings(value, "party", true); end
		},
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateHeaderGroup, "party", nil, 4),
		general = {
			order = 5,
			type = "group",
			name = L["General"],
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"]
				},
				hideonnpc = {
					order = 2,
					type = "toggle",
					name = L["Text Toggle On NPC"],
					desc = L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."],
					get = function(info) return E.db.unitframe.units["party"]["power"].hideonnpc end,
					set = function(info, value) E.db.unitframe.units["party"]["power"].hideonnpc = value; UF:CreateAndUpdateHeaderGroup("party"); end
				},
				rangeCheck = {
					order = 3,
					type = "toggle",
					name = L["Range Check"],
					desc = L["Check if you are in range to cast spells on this specific unit."]
				},
				healPrediction = {
					order = 4,
					type = "toggle",
					name = L["Heal Prediction"],
					desc = L["Show a incomming heal prediction bar on the unitframe. Also display a slightly different colored bar for incoming overheals."]
				},
				threatStyle = {
					order = 5,
					type = "select",
					name = L["Threat Display Mode"],
					values = threatValues
				},
				colorOverride = {
					order = 6,
					name = L["Class Color Override"],
					desc = L["Override the default class color setting."],
					type = "select",
					values = {
						["USE_DEFAULT"] = L["Use Default"],
						["FORCE_ON"] = L["Force On"],
						["FORCE_OFF"] = L["Force Off"]
					}
				},
				orientation = {
					order = 7,
					type = "select",
					name = L["Frame Orientation"],
					desc = L["Set the orientation of the UnitFrame. If set to automatic it will adjust based on where the frame is located on the screen."],
					values = {
						--["AUTOMATIC"] = L["Automatic"], not sure if i will use this yet
						["LEFT"] = L["Left"],
						["MIDDLE"] = L["Middle"],
						["RIGHT"] = L["Right"]
					}
				},
				targetGlow = {
					order = 8,
					type = "toggle",
					name = L["Target Glow"],
					desc = L["Show target glow indicator from this group of frames."],
				},
				positionsGroup = {
					order = 100,
					name = L["Size and Positions"],
					type = "group",
					guiInline = true,
					set = function(info, value) E.db.unitframe.units["party"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("party", nil, nil, true); end,
					args = {
						width = {
							order = 1,
							type = "range",
							name = L["Width"],
							min = 10, max = 500, step = 1,
							set = function(info, value) E.db.unitframe.units["party"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("party"); end
						},
						height = {
							order = 2,
							type = "range",
							name = L["Height"],
							min = 10, max = 500, step = 1,
							set = function(info, value) E.db.unitframe.units["party"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("party"); end
						},
						spacer = {
							order = 3,
							type = "description",
							name = "",
							width = "full"
						},
						growthDirection = {
							order = 4,
							name = L["Growth Direction"],
							desc = L["Growth direction from the first unitframe."],
							type = "select",
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
						numGroups = {
							order = 5,
							type = "range",
							name = L["Number of Groups"],
							min = 1, max = 8, step = 1,
							set = function(info, value)
								E.db.unitframe.units["party"][ info[#info] ] = value;
								UF:CreateAndUpdateHeaderGroup("party");
								if(ElvUF_Party.isForced) then
									UF:HeaderConfig(ElvUF_Party);
									UF:HeaderConfig(ElvUF_Party, true);
								end
							end
						},
						groupsPerRowCol = {
							order = 6,
							type = "range",
							name = L["Groups Per Row/Column"],
							min = 1, max = 8, step = 1,
							set = function(info, value)
								E.db.unitframe.units["party"][ info[#info] ] = value;
								UF:CreateAndUpdateHeaderGroup("party");
								if(ElvUF_Party.isForced) then
									UF:HeaderConfig(ElvUF_Party);
									UF:HeaderConfig(ElvUF_Party, true);
								end
							end
						},
						horizontalSpacing = {
							order = 7,
							type = "range",
							name = L["Horizontal Spacing"],
							min = -1, max = 50, step = 1
						},
						verticalSpacing = {
							order = 8,
							type = "range",
							name = L["Vertical Spacing"],
							min = -1, max = 50, step = 1
						}
					}
				},
				visibilityGroup = {
					order = 200,
					name = L["Visibility"],
					type = "group",
					guiInline = true,
					set = function(info, value) E.db.unitframe.units["party"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("party", nil, nil, true); end,
					args = {
						showPlayer = {
							order = 1,
							type = "toggle",
							name = L["Display Player"],
							desc = L["When true, the header includes the player when not in a raid."],
						},
						visibility = {
							order = 2,
							type = "input",
							name = L["Visibility"],
							desc = L["The following macro must be true in order for the group to be shown, in addition to any filter that may already be set."],
							width = "full"
						}
					}
				},
				sortingGroup = {
					order = 300,
					type = "group",
					guiInline = true,
					name = L["Grouping & Sorting"],
					set = function(info, value) E.db.unitframe.units["party"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("party", nil, nil, true); end,
					args = {
						groupBy = {
							order = 1,
							name = L["Group By"],
							desc = L["Set the order that the group will sort."],
							type = "select",
							values = {
								["CLASS"] = CLASS,
								["NAME"] = NAME,
								["MTMA"] = L["Main Tanks / Main Assist"],
								["GROUP"] = GROUP
							}
						},
						sortDir = {
							order = 2,
							name = L["Sort Direction"],
							desc = L["Defines the sort order of the selected sort method."],
							type = "select",
							values = {
								["ASC"] = L["Ascending"],
								["DESC"] = L["Descending"]
							}
						},
						spacer = {
							order = 3,
							type = "description",
							width = "full",
							name = " "
						},
						raidWideSorting = {
							order = 4,
							name = L["Raid-Wide Sorting"],
							desc = L["Enabling this allows raid-wide sorting however you will not be able to distinguish between groups."],
							type = "toggle"
						},
						invertGroupingOrder = {
							order = 5,
							name = L["Invert Grouping Order"],
							desc = L["Enabling this inverts the grouping order when the raid is not full, this will reverse the direction it starts from."],
							disabled = function() return not E.db.unitframe.units["party"].raidWideSorting end,
							type = "toggle"
						},
						startFromCenter = {
							order = 6,
							name = L["Start Near Center"],
							desc = L["The initial group will start near the center and grow out."],
							disabled = function() return not E.db.unitframe.units["party"].raidWideSorting end,
							type = "toggle"
						}
					}
				}
			}
		},
		buffIndicator = {
			order = 600,
			type = "group",
			name = L["Buff Indicator"],
			get = function(info) return E.db.unitframe.units["party"]["buffIndicator"][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units["party"]["buffIndicator"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("party") end,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"]
				},
				size = {
					order = 3,
					type = "range",
					name = L["Size"],
					desc = L["Size of the indicator icon."],
					min = 4, max = 50, step = 1
				},
				fontSize = {
					order = 4,
					type = "range",
					name = L["Font Size"],
					min = 7, max = 22, step = 1
				},
				profileSpecific = {
					order = 5,
					type = "toggle",
					name = L["Profile Specific"],
					desc = L["Use the profile specific filter 'Buff Indicator (Profile)' instead of the global filter 'Buff Indicator'."]
				},
				configureButton = {
					order = 6,
					type = "execute",
					name = L["Configure Auras"],
					func = function()
						if(E.db.unitframe.units["party"]["buffIndicator"].profileSpecific) then
							E:SetToFilterConfig("Buff Indicator (Profile)");
						else
							E:SetToFilterConfig("Buff Indicator");
						end
					end
				}
			}
		},
		roleIcon = {
			order = 700,
			type = "group",
			name = L["Role Icon"],
			get = function(info) return E.db.unitframe.units["party"]["roleIcon"][ info[#info] ]; end,
			set = function(info, value) E.db.unitframe.units["party"]["roleIcon"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("party"); end,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"]
				},
				position = {
					type = "select",
					order = 2,
					name = L["Position"],
					values = positionValues
				},
				attachTo = {
					order = 3,
					type = "select",
					name = L["Attach To"],
					values = {
						["Health"] = L["Health"],
						["Power"] = L["Power"],
						["InfoPanel"] = L["Information Bar"],
						["Frame"] = L["Frame"]
					}
				},
				xOffset = {
					order = 4,
					type = "range",
					name = L["xOffset"],
					min = -300, max = 300, step = 1
				},
				yOffset = {
					order = 5,
					type = "range",
					name = L["yOffset"],
					min = -300, max = 300, step = 1
				},
				size = {
					order = 6,
					type = "range",
					name = L["Size"],
					min = 4, max = 100, step = 1
				}
			}
		},
		raidRoleIcons = {
			order = 750,
			type = "group",
			name = L["RL / ML Icons"],
			get = function(info) return E.db.unitframe.units["party"]["raidRoleIcons"][ info[#info] ]; end,
			set = function(info, value) E.db.unitframe.units["party"]["raidRoleIcons"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("party"); end,
			args = {
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
						["TOPLEFT"] = "TOPLEFT",
						["TOPRIGHT"] = "TOPRIGHT"
					}
				}
			}
		},
		health = GetOptionsTable_Health(true, UF.CreateAndUpdateHeaderGroup, "party"),
		power = GetOptionsTable_Power(false, UF.CreateAndUpdateHeaderGroup, "party"),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateHeaderGroup, "party"),
		name = GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, "party"),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateHeaderGroup, "party"),
		buffs = GetOptionsTable_Auras(true, "buffs", true, UF.CreateAndUpdateHeaderGroup, "party"),
		debuffs = GetOptionsTable_Auras(true, "debuffs", true, UF.CreateAndUpdateHeaderGroup, "party"),
		rdebuffs = GetOptionsTable_RaidDebuff(UF.CreateAndUpdateHeaderGroup, "party"),
		petsGroup = {
			order = 850,
			type = "group",
			name = L["Party Pets"],
			get = function(info) return E.db.unitframe.units["party"]["petsGroup"][ info[#info] ]; end,
			set = function(info, value) E.db.unitframe.units["party"]["petsGroup"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("party"); end,
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
					min = 10, max = 500, step = 1
				},
				height = {
					order = 3,
					type = "range",
					name = L["Height"],
					min = 10, max = 250, step = 1
				},
				anchorPoint = {
					order = 5,
					type = "select",
					name = L["Anchor Point"],
					desc = L["What point to anchor to the frame you set to attach to."],
					values = petAnchors
				},
				xOffset = {
					order = 6,
					type = "range",
					name = L["xOffset"],
					desc = L["An X offset (in pixels) to be used when anchoring new frames."],
					min = -500, max = 500, step = 1
				},
				yOffset = {
					order = 7,
					type = "range",
					name = L["yOffset"],
					desc = L["An Y offset (in pixels) to be used when anchoring new frames."],
					min = -500, max = 500, step = 1
				},
				name = {
					order = 8,
					type = "group",
					guiInline = true,
					get = function(info) return E.db.unitframe.units["party"]["petsGroup"]["name"][ info[#info] ]; end,
					set = function(info, value) E.db.unitframe.units["party"]["petsGroup"]["name"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("party"); end,
					name = L["Name"],
					args = {
						position = {
							order = 1,
							type = "select",
							name = L["Text Position"],
							values = positionValues
						},
						xOffset = {
							order = 2,
							type = "range",
							name = L["Text xOffset"],
							desc = L["Offset position for text."],
							min = -300, max = 300, step = 1
						},
						yOffset = {
							order = 3,
							type = "range",
							name = L["Text yOffset"],
							desc = L["Offset position for text."],
							min = -300, max = 300, step = 1
						},
						text_format = {
							order = 100,
							type = "input",
							name = L["Text Format"],
							width = "full",
							desc = L["TEXT_FORMAT_DESC"]
						}
					}
				}
			}
		},
		targetsGroup = {
			order = 900,
			type = "group",
			name = L["Party Targets"],
			get = function(info) return E.db.unitframe.units["party"]["targetsGroup"][ info[#info] ]; end,
			set = function(info, value) E.db.unitframe.units["party"]["targetsGroup"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("party"); end,
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
					min = 10, max = 500, step = 1
				},
				height = {
					order = 3,
					type = "range",
					name = L["Height"],
					min = 10, max = 250, step = 1
				},
				anchorPoint = {
					order = 5,
					type = "select",
					name = L["Anchor Point"],
					desc = L["What point to anchor to the frame you set to attach to."],
					values = petAnchors
				},
				xOffset = {
					order = 6,
					type = "range",
					name = L["xOffset"],
					desc = L["An X offset (in pixels) to be used when anchoring new frames."],
					min = -500, max = 500, step = 1
				},
				yOffset = {
					order = 7,
					type = "range",
					name = L["yOffset"],
					desc = L["An Y offset (in pixels) to be used when anchoring new frames."],
					min = -500, max = 500, step = 1
				},
				name = {
					order = 8,
					type = "group",
					guiInline = true,
					get = function(info) return E.db.unitframe.units["party"]["targetsGroup"]["name"][ info[#info] ]; end,
					set = function(info, value) E.db.unitframe.units["party"]["targetsGroup"]["name"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("party"); end,
					name = L["Name"],
					args = {
						position = {
							order = 1,
							type = "select",
							name = L["Text Position"],
							values = positionValues
						},
						xOffset = {
							order = 2,
							type = "range",
							name = L["Text xOffset"],
							desc = L["Offset position for text."],
							min = -300, max = 300, step = 1
						},
						yOffset = {
							order = 3,
							type = "range",
							name = L["Text yOffset"],
							desc = L["Offset position for text."],
							min = -300, max = 300, step = 1
						},
						text_format = {
							order = 100,
							type = "input",
							name = L["Text Format"],
							width = "full",
							desc = L["TEXT_FORMAT_DESC"]
						}
					}
				}
			}
		},
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateHeaderGroup, "party"),
		GPSArrow = GetOptionsTable_GPS("party")
	}
};

E.Options.args.unitframe.args["raid"] = {
	name = L["Raid Frames"],
	type = "group",
	order = 1300,
	childGroups = "select",
	get = function(info) return E.db.unitframe.units["raid"][ info[#info] ] end,
	set = function(info, value) E.db.unitframe.units["raid"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("raid"); end,
	args = {
		configureToggle = {
			order = 1,
			type = "execute",
			name = L["Display Frames"],
			func = function()
				UF:HeaderConfig(_G["ElvUF_Raid"], _G["ElvUF_Raid"].forceShow ~= true or nil);
			end
		},
		resetSettings = {
			order = 2,
			type = "execute",
			name = L["Restore Defaults"],
			func = function(info, value) UF:ResetUnitSettings("raid"); E:ResetMovers("Raid Frames"); end,
		},
		copyFrom = {
			order = 3,
			type = "select",
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = {
				["party"] = L["Party Frames"],
				["raid40"] = L["Raid40 Frames"]
			},
			set = function(info, value) UF:MergeUnitSettings(value, "raid", true); end
		},
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateHeaderGroup, "raid", nil, 4),
		general = {
			order = 5,
			type = "group",
			name = L["General"],
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"]
				},
				hideonnpc = {
					type = "toggle",
					order = 2,
					name = L["Text Toggle On NPC"],
					desc = L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."],
					get = function(info) return E.db.unitframe.units["raid"]["power"].hideonnpc end,
					set = function(info, value) E.db.unitframe.units["raid"]["power"].hideonnpc = value; UF:CreateAndUpdateHeaderGroup("raid"); end
				},
				rangeCheck = {
					order = 3,
					type = "toggle",
					name = L["Range Check"],
					desc = L["Check if you are in range to cast spells on this specific unit."]
				},
				healPrediction = {
					order = 4,
					type = "toggle",
					name = L["Heal Prediction"],
					desc = L["Show a incomming heal prediction bar on the unitframe. Also display a slightly different colored bar for incoming overheals."]
				},
				threatStyle = {
					order = 5,
					type = "select",
					name = L["Threat Display Mode"],
					values = threatValues
				},
				colorOverride = {
					order = 6,
					type = "select",
					name = L["Class Color Override"],
					desc = L["Override the default class color setting."],
					values = {
						["USE_DEFAULT"] = L["Use Default"],
						["FORCE_ON"] = L["Force On"],
						["FORCE_OFF"] = L["Force Off"]
					}
				},
				orientation = {
					order = 7,
					type = "select",
					name = L["Frame Orientation"],
					desc = L["Set the orientation of the UnitFrame. If set to automatic it will adjust based on where the frame is located on the screen."],
					values = {
						--["AUTOMATIC"] = L["Automatic"], not sure if i will use this yet
						["LEFT"] = L["Left"],
						["MIDDLE"] = L["Middle"],
						["RIGHT"] = L["Right"],
					}
				},
				targetGlow = {
					order = 8,
					type = "toggle",
					name = L["Target Glow"],
					desc = L["Show target glow indicator from this group of frames."],
				},
				positionsGroup = {
					order = 100,
					name = L["Size and Positions"],
					type = "group",
					guiInline = true,
					set = function(info, value) E.db.unitframe.units["raid"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("raid", nil, nil, true); end,
					args = {
						width = {
							order = 1,
							type = "range",
							name = L["Width"],
							min = 10, max = 500, step = 1,
							set = function(info, value) E.db.unitframe.units["raid"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("raid"); end
						},
						height = {
							order = 2,
							name = L["Height"],
							type = "range",
							min = 10, max = 500, step = 1,
							set = function(info, value) E.db.unitframe.units["raid"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("raid") end,
						},
						spacer = {
							order = 3,
							type = "description",
							name = "",
							width = "full"
						},
						growthDirection = {
							order = 4,
							name = L["Growth Direction"],
							desc = L["Growth direction from the first unitframe."],
							type = "select",
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
						numGroups = {
							order = 7,
							type = "range",
							name = L["Number of Groups"],
							min = 1, max = 8, step = 1,
							set = function(info, value)
								E.db.unitframe.units["raid"][ info[#info] ] = value;
								UF:CreateAndUpdateHeaderGroup("raid");
								if(_G["ElvUF_Raid"].isForced) then
									UF:HeaderConfig(_G["ElvUF_Raid"]);
									UF:HeaderConfig(_G["ElvUF_Raid"], true);
								end
							end,
						},
						groupsPerRowCol = {
							order = 8,
							type = "range",
							name = L["Groups Per Row/Column"],
							min = 1, max = 8, step = 1,
							set = function(info, value)
								E.db.unitframe.units["raid"][ info[#info] ] = value;
								UF:CreateAndUpdateHeaderGroup("raid");
								if(_G["ElvUF_Raid"].isForced) then
									UF:HeaderConfig(_G["ElvUF_Raid"]);
									UF:HeaderConfig(_G["ElvUF_Raid"], true);
								end
							end
						},
						horizontalSpacing = {
							order = 9,
							type = "range",
							name = L["Horizontal Spacing"],
							min = -1, max = 50, step = 1
						},
						verticalSpacing = {
							order = 10,
							type = "range",
							name = L["Vertical Spacing"],
							min = -1, max = 50, step = 1
						}
					}
				},
				visibilityGroup = {
					order = 200,
					name = L["Visibility"],
					type = "group",
					guiInline = true,
					set = function(info, value) E.db.unitframe.units["raid"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("raid", nil, nil, true); end,
					args = {
						showPlayer = {
							order = 1,
							type = "toggle",
							name = L["Display Player"],
							desc = L["When true, the header includes the player when not in a raid."],
						},
						visibility = {
							order = 2,
							type = "input",
							name = L["Visibility"],
							desc = L["The following macro must be true in order for the group to be shown, in addition to any filter that may already be set."],
							width = "full"
						}
					}
				},
				sortingGroup = {
					order = 300,
					type = "group",
					guiInline = true,
					name = L["Grouping & Sorting"],
					set = function(info, value) E.db.unitframe.units["raid"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("raid", nil, nil, true); end,
					args = {
						groupBy = {
							order = 1,
							name = L["Group By"],
							desc = L["Set the order that the group will sort."],
							type = "select",
							values = {
								["CLASS"] = CLASS,
								["ROLE"] = ROLE,
								["NAME"] = NAME,
								["MTMA"] = L["Main Tanks / Main Assist"],
								["GROUP"] = GROUP
							}
						},
						sortDir = {
							order = 2,
							name = L["Sort Direction"],
							desc = L["Defines the sort order of the selected sort method."],
							type = "select",
							values = {
								["ASC"] = L["Ascending"],
								["DESC"] = L["Descending"]
							}
						},
						spacer = {
							order = 3,
							type = "description",
							width = "full",
							name = " "
						},
						raidWideSorting = {
							order = 4,
							type = "toggle",
							name = L["Raid-Wide Sorting"],
							desc = L["Enabling this allows raid-wide sorting however you will not be able to distinguish between groups."]
						},
						invertGroupingOrder = {
							order = 5,
							type = "toggle",
							name = L["Invert Grouping Order"],
							desc = L["Enabling this inverts the grouping order when the raid is not full, this will reverse the direction it starts from."],
							disabled = function() return not E.db.unitframe.units["raid"].raidWideSorting; end
						},
						startFromCenter = {
							order = 6,
							type = "toggle",
							name = L["Start Near Center"],
							desc = L["The initial group will start near the center and grow out."],
							disabled = function() return not E.db.unitframe.units["raid"].raidWideSorting; end
						}
					}
				}
			}
		},
		health = GetOptionsTable_Health(true, UF.CreateAndUpdateHeaderGroup, "raid"),
		power = GetOptionsTable_Power(false, UF.CreateAndUpdateHeaderGroup, "raid"),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateHeaderGroup, "raid"),
		name = GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, "raid"),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateHeaderGroup, "raid"),
		buffs = GetOptionsTable_Auras(true, "buffs", true, UF.CreateAndUpdateHeaderGroup, "raid"),
		debuffs = GetOptionsTable_Auras(true, "debuffs", true, UF.CreateAndUpdateHeaderGroup, "raid"),
		buffIndicator = {
			order = 600,
			type = "group",
			name = L["Buff Indicator"],
			get = function(info) return E.db.unitframe.units["raid"]["buffIndicator"][ info[#info] ]; end,
			set = function(info, value) E.db.unitframe.units["raid"]["buffIndicator"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("raid"); end,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"]
				},
				size = {
					order = 3,
					type = "range",
					name = L["Size"],
					desc = L["Size of the indicator icon."],
					min = 4, max = 50, step = 1
				},
				fontSize = {
					order = 4,
					type = "range",
					name = L["Font Size"],
					min = 7, max = 22, step = 1
				},
				profileSpecific = {
					order = 5,
					type = "toggle",
					name = L["Profile Specific"],
					desc = L["Use the profile specific filter 'Buff Indicator (Profile)' instead of the global filter 'Buff Indicator'."]
				},
				configureButton = {
					order = 6,
					type = "execute",
					name = L["Configure Auras"],
					func = function()
						if(E.db.unitframe.units["raid"]["buffIndicator"].profileSpecific) then
							E:SetToFilterConfig("Buff Indicator (Profile)");
						else
							E:SetToFilterConfig("Buff Indicator");
						end
					end
				}
			}
		},
		roleIcon = {
			order = 700,
			type = "group",
			name = L["Role Icon"],
			get = function(info) return E.db.unitframe.units["raid"]["roleIcon"][ info[#info] ]; end,
			set = function(info, value) E.db.unitframe.units["raid"]["roleIcon"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("raid"); end,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"]
				},
				position = {
					order = 2,
					type = "select",
					name = L["Position"],
					values = positionValues
				},
				attachTo = {
					order = 3,
					type = "select",
					name = L["Attach To"],
					values = {
						["Health"] = L["Health"],
						["Power"] = L["Power"],
						["InfoPanel"] = L["Information Bar"],
						["Frame"] = L["Frame"]
					}
				},
				xOffset = {
					order = 4,
					type = "range",
					name = L["xOffset"],
					min = -300, max = 300, step = 1
				},
				yOffset = {
					order = 5,
					type = "range",
					name = L["yOffset"],
					min = -300, max = 300, step = 1
				},
				size = {
					order = 6,
					type = "range",
					name = L["Size"],
					min = 4, max = 100, step = 1
				}
			}
		},
		raidRoleIcons = {
			order = 750,
			type = "group",
			name = L["RL / ML Icons"],
			get = function(info) return E.db.unitframe.units["raid"]["raidRoleIcons"][ info[#info] ]; end,
			set = function(info, value) E.db.unitframe.units["raid"]["raidRoleIcons"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("raid"); end,
			args = {
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
						["TOPLEFT"] = "TOPLEFT",
						["TOPRIGHT"] = "TOPRIGHT"
					}
				},
				size = {
					order = 3,
					type = "range",
					name = L["Size"],
					min = 4, max = 100, step = 1
				},
			},
		},
		rdebuffs = GetOptionsTable_RaidDebuff(UF.CreateAndUpdateHeaderGroup, "raid"),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateHeaderGroup, "raid"),
		GPSArrow = GetOptionsTable_GPS("raid")
	}
};

E.Options.args.unitframe.args["raid40"] = {
	name = L["Raid-40 Frames"],
	type = "group",
	order = 1350,
	childGroups = "select",
	get = function(info) return E.db.unitframe.units["raid40"][ info[#info] ]; end,
	set = function(info, value) E.db.unitframe.units["raid40"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("raid40"); end,
	args = {
		configureToggle = {
			order = 1,
			type = "execute",
			name = L["Display Frames"],
			func = function()
				UF:HeaderConfig(_G["ElvUF_Raid40"], _G["ElvUF_Raid40"].forceShow ~= true or nil);
			end
		},
		resetSettings = {
			order = 2,
			type = "execute",
			name = L["Restore Defaults"],
			func = function(info, value) UF:ResetUnitSettings("raid40"); E:ResetMovers("Raid Frames"); end
		},
		copyFrom = {
			order = 3,
			type = "select",
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = {
				["party"] = L["Party Frames"],
				["raid"] = L["Raid Frames"]
			},
			set = function(info, value) UF:MergeUnitSettings(value, "raid40", true); end
		},
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateHeaderGroup, "raid40", nil, 4),
		general = {
			order = 5,
			type = "group",
			name = L["General"],
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"]
				},
				hideonnpc = {
					order = 2,
					type = "toggle",
					name = L["Text Toggle On NPC"],
					desc = L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."],
					get = function(info) return E.db.unitframe.units["raid40"]["power"].hideonnpc; end,
					set = function(info, value) E.db.unitframe.units["raid40"]["power"].hideonnpc = value; UF:CreateAndUpdateHeaderGroup("raid40"); end
				},
				rangeCheck = {
					order = 3,
					type = "toggle",
					name = L["Range Check"],
					desc = L["Check if you are in range to cast spells on this specific unit."]
				},
				healPrediction = {
					order = 4,
					type = "toggle",
					name = L["Heal Prediction"],
					desc = L["Show a incomming heal prediction bar on the unitframe. Also display a slightly different colored bar for incoming overheals."]
				},
				threatStyle = {
					order = 5,
					type = "select",
					name = L["Threat Display Mode"],
					values = threatValues
				},
				colorOverride = {
					order = 6,
					type = "select",
					name = L["Class Color Override"],
					desc = L["Override the default class color setting."],
					values = {
						["USE_DEFAULT"] = L["Use Default"],
						["FORCE_ON"] = L["Force On"],
						["FORCE_OFF"] = L["Force Off"]
					}
				},
				orientation = {
					order = 7,
					type = "select",
					name = L["Frame Orientation"],
					desc = L["Set the orientation of the UnitFrame. If set to automatic it will adjust based on where the frame is located on the screen."],
					values = {
						--["AUTOMATIC"] = L["Automatic"], not sure if i will use this yet
						["LEFT"] = L["Left"],
						["MIDDLE"] = L["Middle"],
						["RIGHT"] = L["Right"]
					}
				},
				targetGlow = {
					order = 8,
					type = "toggle",
					name = L["Target Glow"],
					desc = L["Show target glow indicator from this group of frames."],
				},
				positionsGroup = {
					order = 100,
					name = L["Size and Positions"],
					type = "group",
					guiInline = true,
					set = function(info, value) E.db.unitframe.units["raid40"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("raid40", nil, nil, true); end,
					args = {
						width = {
							order = 1,
							type = "range",
							name = L["Width"],
							min = 10, max = 500, step = 1,
							set = function(info, value) E.db.unitframe.units["raid40"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("raid40"); end
						},
						height = {
							order = 2,
							type = "range",
							name = L["Height"],
							min = 10, max = 500, step = 1,
							set = function(info, value) E.db.unitframe.units["raid40"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("raid40") end
						},
						spacer = {
							order = 3,
							type = "description",
							name = "",
							width = "full"
						},
						growthDirection = {
							order = 4,
							type = "select",
							name = L["Growth Direction"],
							desc = L["Growth direction from the first unitframe."],
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
						numGroups = {
							order = 7,
							type = "range",
							name = L["Number of Groups"],
							min = 1, max = 8, step = 1,
							set = function(info, value)
								E.db.unitframe.units["raid40"][ info[#info] ] = value;
								UF:CreateAndUpdateHeaderGroup("raid40");
								if(_G["ElvUF_Raid"].isForced) then
									UF:HeaderConfig(_G["ElvUF_Raid40"]);
									UF:HeaderConfig(_G["ElvUF_Raid40"], true);
								end
							end
						},
						groupsPerRowCol = {
							order = 8,
							type = "range",
							name = L["Groups Per Row/Column"],
							min = 1, max = 8, step = 1,
							set = function(info, value)
								E.db.unitframe.units["raid40"][ info[#info] ] = value;
								UF:CreateAndUpdateHeaderGroup("raid40");
								if(_G["ElvUF_Raid"].isForced) then
									UF:HeaderConfig(_G["ElvUF_Raid40"]);
									UF:HeaderConfig(_G["ElvUF_Raid40"], true);
								end
							end
						},
						horizontalSpacing = {
							order = 9,
							type = "range",
							name = L["Horizontal Spacing"],
							min = -1, max = 50, step = 1
						},
						verticalSpacing = {
							order = 10,
							type = "range",
							name = L["Vertical Spacing"],
							min = -1, max = 50, step = 1
						}
					}
				},
				visibilityGroup = {
					order = 200,
					name = L["Visibility"],
					type = "group",
					guiInline = true,
					set = function(info, value) E.db.unitframe.units["raid40"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("raid40", nil, nil, true); end,
					args = {
						showPlayer = {
							order = 1,
							type = "toggle",
							name = L["Display Player"],
							desc = L["When true, the header includes the player when not in a raid."]
						},
						visibility = {
							order = 2,
							type = "input",
							name = L["Visibility"],
							desc = L["The following macro must be true in order for the group to be shown, in addition to any filter that may already be set."],
							width = "full"
						}
					}
				},
				sortingGroup = {
					order = 300,
					type = "group",
					guiInline = true,
					name = L["Grouping & Sorting"],
					set = function(info, value) E.db.unitframe.units["raid40"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("raid40", nil, nil, true); end,
					args = {
						groupBy = {
							order = 1,
							type = "select",
							name = L["Group By"],
							desc = L["Set the order that the group will sort."],
							values = {
								["CLASS"] = CLASS,
								["ROLE"] = ROLE,
								["NAME"] = NAME,
								["MTMA"] = L["Main Tanks / Main Assist"],
								["GROUP"] = GROUP
							}
						},
						sortDir = {
							order = 2,
							type = "select",
							name = L["Sort Direction"],
							desc = L["Defines the sort order of the selected sort method."],
							values = {
								["ASC"] = L["Ascending"],
								["DESC"] = L["Descending"]
							}
						},
						spacer = {
							order = 3,
							type = "description",
							width = "full",
							name = " "
						},
						raidWideSorting = {
							order = 4,
							type = "toggle",
							name = L["Raid-Wide Sorting"],
							desc = L["Enabling this allows raid-wide sorting however you will not be able to distinguish between groups."]
						},
						invertGroupingOrder = {
							order = 5,
							type = "toggle",
							name = L["Invert Grouping Order"],
							desc = L["Enabling this inverts the grouping order when the raid is not full, this will reverse the direction it starts from."],
							disabled = function() return not E.db.unitframe.units["raid40"].raidWideSorting; end
						},
						startFromCenter = {
							order = 6,
							type = "toggle",
							name = L["Start Near Center"],
							desc = L["The initial group will start near the center and grow out."],
							disabled = function() return not E.db.unitframe.units["raid40"].raidWideSorting; end
						}
					}
				}
			}
		},
		health = GetOptionsTable_Health(true, UF.CreateAndUpdateHeaderGroup, "raid40"),
		power = GetOptionsTable_Power(false, UF.CreateAndUpdateHeaderGroup, "raid40"),
		infoPanel = GetOptionsTable_InformationPanel(UF.CreateAndUpdateHeaderGroup, "raid40"),
		name = GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, "raid40"),
		portrait = GetOptionsTable_Portrait(UF.CreateAndUpdateHeaderGroup, "raid40"),
		buffs = GetOptionsTable_Auras(true, "buffs", true, UF.CreateAndUpdateHeaderGroup, "raid40"),
		debuffs = GetOptionsTable_Auras(true, "debuffs", true, UF.CreateAndUpdateHeaderGroup, "raid40"),
		buffIndicator = {
			order = 600,
			type = "group",
			name = L["Buff Indicator"],
			get = function(info) return E.db.unitframe.units["raid40"]["buffIndicator"][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units["raid40"]["buffIndicator"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("raid40") end,
			args = {
				enable = {
					type = "toggle",
					name = L["Enable"],
					order = 1,
				},
				size = {
					type = "range",
					name = L["Size"],
					desc = L["Size of the indicator icon."],
					order = 3,
					min = 4, max = 50, step = 1,
				},
				fontSize = {
					type = "range",
					name = L["Font Size"],
					order = 4,
					min = 7, max = 22, step = 1,
				},
				profileSpecific = {
					order = 5,
					type = "toggle",
					name = L["Profile Specific"],
					desc = L["Use the profile specific filter 'Buff Indicator (Profile)' instead of the global filter 'Buff Indicator'."]
				},
				configureButton = {
					order = 6,
					type = "execute",
					name = L["Configure Auras"],
					func = function()
						if(E.db.unitframe.units["raid40"]["buffIndicator"].profileSpecific) then
							E:SetToFilterConfig("Buff Indicator (Profile)");
						else
							E:SetToFilterConfig("Buff Indicator");
						end
					end
				}
			}
		},
		roleIcon = {
			order = 700,
			type = "group",
			name = L["Role Icon"],
			get = function(info) return E.db.unitframe.units["raid40"]["roleIcon"][ info[#info] ]; end,
			set = function(info, value) E.db.unitframe.units["raid40"]["roleIcon"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("raid40"); end,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"]
				},
				position = {
					order = 2,
					type = "select",
					name = L["Position"],
					values = positionValues
				},
				attachTo = {
					order = 3,
					type = "select",
					name = L["Attach To"],
					values = {
						["Health"] = L["Health"],
						["Power"] = L["Power"],
						["InfoPanel"] = L["Information Bar"],
						["Frame"] = L["Frame"]
					}
				},
				xOffset = {
					order = 4,
					type = "range",
					name = L["xOffset"],
					min = -300, max = 300, step = 1
				},
				yOffset = {
					order = 5,
					type = "range",
					name = L["yOffset"],
					min = -300, max = 300, step = 1
				},
				size = {
					order = 6,
					type = "range",
					name = L["Size"],
					min = 4, max = 100, step = 1
				}
			}
		},
		raidRoleIcons = {
			order = 750,
			type = "group",
			name = L["RL / ML Icons"],
			get = function(info) return E.db.unitframe.units["raid40"]["raidRoleIcons"][ info[#info] ]; end,
			set = function(info, value) E.db.unitframe.units["raid40"]["raidRoleIcons"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("raid40"); end,
			args = {
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
						["TOPLEFT"] = "TOPLEFT",
						["TOPRIGHT"] = "TOPRIGHT",
					}
				}
			}
		},
		rdebuffs = GetOptionsTable_RaidDebuff(UF.CreateAndUpdateHeaderGroup, "raid40"),
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateHeaderGroup, "raid40"),
		GPSArrow = GetOptionsTable_GPS("raid40")
	}
};

E.Options.args.unitframe.args.raidpet = {
	order = 1400,
	type = "group",
	name = L["Raid Pet Frames"],
	childGroups = "select",
	get = function(info) return E.db.unitframe.units["raidpet"][ info[#info] ]; end,
	set = function(info, value) E.db.unitframe.units["raidpet"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("raidpet"); end,
	disabled = function() return not E.private.unitframe.enable end,
	args = {
		configureToggle = {
			order = 1,
			type = "execute",
			name = L["Display Frames"],
			func = function()
				UF:HeaderConfig(ElvUF_Raidpet, ElvUF_Raidpet.forceShow ~= true or nil);
			end
		},
		resetSettings = {
			order = 2,
			type = "execute",
			name = L["Restore Defaults"],
			func = function(info, value) UF:ResetUnitSettings("raidpet"); E:ResetMovers(L["Raid Pet Frames"]); UF:CreateAndUpdateHeaderGroup("raidpet", nil, nil, true); end,
			disabled = function() return not _G["ElvUF_Raidpet"].isForced == false; end
		},
		copyFrom = {
			type = "select",
			order = 3,
			name = L["Copy From"],
			desc = L["Select a unit to copy settings from."],
			values = {
				["party"] = L["Party Frames"],
				["raid10"] = L["Raid-10 Frames"],
				["raid25"] = L["Raid-25 Frames"],
				["raid40"] = L["Raid-40 Frames"],
			},
			set = function(info, value) UF:MergeUnitSettings(value, "raidpet", true); end,
		},
		customText = GetOptionsTable_CustomText(UF.CreateAndUpdateHeaderGroup, "raidpet", nil, 4),
		general = {
			order = 5,
			type = "group",
			name = L["General"],
			args = {
				enable = {
					type = "toggle",
					order = 1,
					name = L["Enable"],
				},
				rangeCheck = {
					order = 3,
					name = L["Range Check"],
					desc = L["Check if you are in range to cast spells on this specific unit."],
					type = "toggle",
				},
				healPrediction = {
					order = 8,
					type = "toggle",
					name = L["Heal Prediction"],
					desc = L["Show a incomming heal prediction bar on the unitframe. Also display a slightly different colored bar for incoming overheals."]
				},
				threatStyle = {
					type = "select",
					order = 5,
					name = L["Threat Display Mode"],
					values = threatValues,
				},
				colorOverride = {
					order = 6,
					name = L["Class Color Override"],
					desc = L["Override the default class color setting."],
					type = "select",
					values = {
						["USE_DEFAULT"] = L["Use Default"],
						["FORCE_ON"] = L["Force On"],
						["FORCE_OFF"] = L["Force Off"],
					},
				},
				orientation = {
					order = 7,
					type = "select",
					name = L["Frame Orientation"],
					desc = L["Set the orientation of the UnitFrame. If set to automatic it will adjust based on where the frame is located on the screen."],
					values = {
						--["AUTOMATIC"] = L["Automatic"], not sure if i will use this yet
						["LEFT"] = L["Left"],
						["MIDDLE"] = L["Middle"],
						["RIGHT"] = L["Right"],
					},
				},
				targetGlow = {
					order = 8,
					type = "toggle",
					name = L["Target Glow"],
					desc = L["Show target glow indicator from this group of frames."],
				},
				positionsGroup = {
					order = 100,
					name = L["Size and Positions"],
					type = "group",
					guiInline = true,
					set = function(info, value) E.db.unitframe.units["raidpet"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("raidpet", nil, nil, true) end,
					args = {
						width = {
							order = 1,
							name = L["Width"],
							type = "range",
							min = 10, max = 500, step = 1,
							set = function(info, value) E.db.unitframe.units["raidpet"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("raidpet") end,
						},
						height = {
							order = 2,
							name = L["Height"],
							type = "range",
							min = 10, max = 500, step = 1,
							set = function(info, value) E.db.unitframe.units["raidpet"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("raidpet") end,
						},
						spacer = {
							order = 3,
							name = "",
							type = "description",
							width = "full",
						},
						growthDirection = {
							order = 4,
							name = L["Growth Direction"],
							desc = L["Growth direction from the first unitframe."],
							type = "select",
							values = {
								DOWN_RIGHT = format(L["%s and then %s"], L["Down"], L["Right"]),
								DOWN_LEFT = format(L["%s and then %s"], L["Down"], L["Left"]),
								UP_RIGHT = format(L["%s and then %s"], L["Up"], L["Right"]),
								UP_LEFT = format(L["%s and then %s"], L["Up"], L["Left"]),
								RIGHT_DOWN = format(L["%s and then %s"], L["Right"], L["Down"]),
								RIGHT_UP = format(L["%s and then %s"], L["Right"], L["Up"]),
								LEFT_DOWN = format(L["%s and then %s"], L["Left"], L["Down"]),
								LEFT_UP = format(L["%s and then %s"], L["Left"], L["Up"]),
							},
						},
						numGroups = {
							order = 7,
							type = "range",
							name = L["Number of Groups"],
							min = 1, max = 8, step = 1,
								set = function(info, value)
									E.db.unitframe.units["raidpet"][ info[#info] ] = value;
									UF:CreateAndUpdateHeaderGroup("raidpet")
									if ElvUF_Raidpet.isForced then
										UF:HeaderConfig(ElvUF_Raidpet)
										UF:HeaderConfig(ElvUF_Raidpet, true)
									end
								end,
						},
						groupsPerRowCol = {
							order = 8,
							type = "range",
							name = L["Groups Per Row/Column"],
							min = 1, max = 8, step = 1,
							set = function(info, value)
								E.db.unitframe.units["raidpet"][ info[#info] ] = value;
								UF:CreateAndUpdateHeaderGroup("raidpet")
								if ElvUF_Raidpet.isForced then
									UF:HeaderConfig(ElvUF_Raidpet)
									UF:HeaderConfig(ElvUF_Raidpet, true)
								end
							end,
						},
						horizontalSpacing = {
							order = 9,
							type = "range",
							name = L["Horizontal Spacing"],
							min = -1, max = 50, step = 1,
						},
						verticalSpacing = {
							order = 10,
							type = "range",
							name = L["Vertical Spacing"],
							min = -1, max = 50, step = 1,
						},
					},
				},
				visibilityGroup = {
					order = 200,
					name = L["Visibility"],
					type = "group",
					guiInline = true,
					set = function(info, value) E.db.unitframe.units["raidpet"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("raidpet", nil, nil, true) end,
					args = {
						visibility = {
							order = 2,
							type = "input",
							name = L["Visibility"],
							desc = L["The following macro must be true in order for the group to be shown, in addition to any filter that may already be set."],
							width = "full",
						},
					},
				},
				sortingGroup = {
					order = 300,
					type = "group",
					guiInline = true,
					name = L["Grouping & Sorting"],
					set = function(info, value) E.db.unitframe.units["raidpet"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("raidpet", nil, nil, true) end,
					args = {
						groupBy = {
							order = 1,
							name = L["Group By"],
							desc = L["Set the order that the group will sort."],
							type = "select",
							values = {
								["NAME"] = L["Owners Name"],
								["PETNAME"] = L["Pet Name"],
								["GROUP"] = GROUP,
							},
						},
						sortDir = {
							order = 2,
							name = L["Sort Direction"],
							desc = L["Defines the sort order of the selected sort method."],
							type = "select",
							values = {
								["ASC"] = L["Ascending"],
								["DESC"] = L["Descending"]
							},
						},
						spacer = {
							order = 3,
							type = "description",
							width = "full",
							name = " "
						},
						raidWideSorting = {
							order = 4,
							name = L["Raid-Wide Sorting"],
							desc = L["Enabling this allows raid-wide sorting however you will not be able to distinguish between groups."],
							type = "toggle",
						},
						invertGroupingOrder = {
							order = 5,
							name = L["Invert Grouping Order"],
							desc = L["Enabling this inverts the grouping order when the raid is not full, this will reverse the direction it starts from."],
							disabled = function() return not E.db.unitframe.units["raidpet"].raidWideSorting end,
							type = "toggle",
						},
						startFromCenter = {
							order = 6,
							name = L["Start Near Center"],
							desc = L["The initial group will start near the center and grow out."],
							disabled = function() return not E.db.unitframe.units["raidpet"].raidWideSorting end,
							type = "toggle",
						},
					},
				},
			},
		},
		health = GetOptionsTable_Health(true, UF.CreateAndUpdateHeaderGroup, "raidpet"),
		name = GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, "raidpet"),
		buffs = GetOptionsTable_Auras(true, "buffs", true, UF.CreateAndUpdateHeaderGroup, "raidpet"),
		debuffs = GetOptionsTable_Auras(true, "debuffs", true, UF.CreateAndUpdateHeaderGroup, "raidpet"),
		buffIndicator = {
			order = 600,
			type = "group",
			name = L["Buff Indicator"],
			get = function(info) return E.db.unitframe.units["raidpet"]["buffIndicator"][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units["raidpet"]["buffIndicator"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("raidpet") end,
			args = {
				enable = {
					type = "toggle",
					name = L["Enable"],
					order = 1,
				},
				size = {
					type = "range",
					name = L["Size"],
					desc = L["Size of the indicator icon."],
					order = 3,
					min = 4, max = 50, step = 1,
				},
				fontSize = {
					type = "range",
					name = L["Font Size"],
					order = 4,
					min = 7, max = 22, step = 1,
				},
				configureButton = {
					type = "execute",
					name = L["Configure Auras"],
					func = function() E:SetToFilterConfig("Buff Indicator") end,
					order = 5
				},
			},
		},
		rdebuffs = {
			order = 700,
			type = "group",
			name = L["RaidDebuff Indicator"],
			get = function(info) return E.db.unitframe.units["raidpet"]["rdebuffs"][ info[#info] ]; end,
			set = function(info, value) E.db.unitframe.units["raidpet"]["rdebuffs"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("raidpet"); end,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"]
				},
				size = {
					order = 2,
					type = "range",
					name = L["Size"],
					min = 8, max = 35, step = 1
				},
				font = {
					order = 3,
					type = "select", dialogControl = "LSM30_Font",
					name = L["Font"],
					values = AceGUIWidgetLSMlists.font
				},
				fontSize = {
					order = 4,
					type = "range",
					name = L["Font Size"],
					min = 7, max = 22, step = 1
				},
				fontOutline = {
					order = 5,
					type = "select",
					name = L["Font Outline"],
					values = {
						["NONE"] = L["None"],
						["OUTLINE"] = "OUTLINE",
						["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
						["THICKOUTLINE"] = "THICKOUTLINE"
					}
				},
				xOffset = {
					order = 6,
					type = "range",
					name = L["xOffset"],
					min = -300, max = 300, step = 1
				},
				yOffset = {
					order = 7,
					type = "range",
					name = L["yOffset"],
					min = -300, max = 300, step = 1
				},
				configureButton = {
					order = 8,
					type = "execute",
					name = L["Configure Auras"],
					func = function() E:SetToFilterConfig("RaidDebuffs"); end
				},
				duration = {
					order = 11,
					type = "group",
					guiInline = true,
					name = L["Duration Text"],
					get = function(info) return E.db.unitframe.units["raidpet"]["rdebuffs"]["duration"][ info[#info] ]; end,
					set = function(info, value) E.db.unitframe.units["raidpet"]["rdebuffs"]["duration"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("raidpet"); end,
					args = {
						position = {
							order = 1,
							type = "select",
							name = L["Position"],
							values = {
								["TOP"] = "TOP",
								["LEFT"] = "LEFT",
								["RIGHT"] = "RIGHT",
								["BOTTOM"] = "BOTTOM",
								["CENTER"] = "CENTER",
								["TOPLEFT"] = "TOPLEFT",
								["TOPRIGHT"] = "TOPRIGHT",
								["BOTTOMLEFT"] = "BOTTOMLEFT",
								["BOTTOMRIGHT"] = "BOTTOMRIGHT"
							}
						},
						xOffset = {
							order = 2,
							type = "range",
							name = L["xOffset"],
							min = -10, max = 10, step = 1
						},
						yOffset = {
							order = 3,
							type = "range",
							name = L["yOffset"],
							min = -10, max = 10, step = 1
						},
						color = {
							order = 4,
							type = "color",
							name = L["Color"],
							get = function(info)
								local c = E.db.unitframe.units.raidpet.rdebuffs.duration.color;
								local d = P.unitframe.units.raidpet.rdebuffs.duration.color;
								return c.r, c.g, c.b, c.a, d.r, d.g, d.b;
							end,
							set = function(info, r, g, b)
								E.db.unitframe.units.raidpet.rdebuffs.duration.color = {};
								local c = E.db.unitframe.units.raidpet.rdebuffs.duration.color;
								c.r, c.g, c.b = r, g, b;
								UF:CreateAndUpdateHeaderGroup("raidpet");
							end
						}
					}
				},
				stack = {
					order = 11,
					type = "group",
					guiInline = true,
					name = L["Stack Counter"],
					get = function(info) return E.db.unitframe.units["raidpet"]["rdebuffs"]["stack"][ info[#info] ]; end,
					set = function(info, value) E.db.unitframe.units["raidpet"]["rdebuffs"]["stack"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("raidpet"); end,
					args = {
						position = {
							order = 1,
							type = "select",
							name = L["Position"],
							values = {
								["TOP"] = "TOP",
								["LEFT"] = "LEFT",
								["RIGHT"] = "RIGHT",
								["BOTTOM"] = "BOTTOM",
								["CENTER"] = "CENTER",
								["TOPLEFT"] = "TOPLEFT",
								["TOPRIGHT"] = "TOPRIGHT",
								["BOTTOMLEFT"] = "BOTTOMLEFT",
								["BOTTOMRIGHT"] = "BOTTOMRIGHT"
							}
						},
						xOffset = {
							order = 2,
							type = "range",
							name = L["xOffset"],
							min = -10, max = 10, step = 1
						},
						yOffset = {
							order = 3,
							type = "range",
							name = L["yOffset"],
							min = -10, max = 10, step = 1
						},
						color = {
							order = 4,
							type = "color",
							name = L["Color"],
							get = function(info)
								local c = E.db.unitframe.units.raidpet.rdebuffs.stack.color;
								local d = P.unitframe.units.raidpet.rdebuffs.stack.color;
								return c.r, c.g, c.b, c.a, d.r, d.g, d.b;
							end,
							set = function(info, r, g, b)
								E.db.unitframe.units.raidpet.rdebuffs.stack.color = {};
								local c = E.db.unitframe.units.raidpet.rdebuffs.stack.color;
								c.r, c.g, c.b = r, g, b;
								UF:CreateAndUpdateHeaderGroup("raidpet");
							end
						}
					}
				}
			}
		},
		raidicon = GetOptionsTable_RaidIcon(UF.CreateAndUpdateHeaderGroup, "raidpet"),
	},
}

E.Options.args.unitframe.args.tank = { -- Танки
	name = L["Tank Frames"],
	type = "group",
	order = 1500,
	childGroups = "select",
	get = function(info) return E.db.unitframe.units["tank"][ info[#info] ] end,
	set = function(info, value) E.db.unitframe.units["tank"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("tank") end,
	args = {
		resetSettings = {
			type = "execute",
			order = 1,
			name = L["Restore Defaults"],
			func = function(info, value) UF:ResetUnitSettings("tank") end,
		},
		general = {
			order = 2,
			type = "group",
			name = L["General"],
			guiInline = true,
			args = {
				enable = {
					type = "toggle",
					order = 1,
					name = L["Enable"],
				},
				width = {
					order = 2,
					name = L["Width"],
					type = "range",
					min = 50, max = 500, step = 1,
				},
				height = {
					order = 3,
					name = L["Height"],
					type = "range",
					min = 10, max = 250, step = 1,
				},
				verticalSpacing = {
					order = 4,
					type = "range",
					name = L["Vertical Spacing"],
					min = 0, max = 100, step = 1,
				},
				disableDebuffHighlight = {
					order = 5,
					type = "toggle",
					name = L["Disable Debuff Highlight"],
					desc = L["Forces Debuff Highlight to be disabled for these frames"],
					disabled = function() return E.db.unitframe.debuffHighlighting == "NONE" end,
				},
				orientation = {
					order = 6,
					type = "select",
					name = L["Frame Orientation"],
					desc = L["Set the orientation of the UnitFrame. If set to automatic it will adjust based on where the frame is located on the screen."],
					values = {
						--["AUTOMATIC"] = L["Automatic"], not sure if i will use this yet
						["LEFT"] = L["Left"],
						["MIDDLE"] = L["Middle"],
						["RIGHT"] = L["Right"],
					},
				},
				colorOverride = {
					order = 7,
					name = L["Class Color Override"],
					desc = L["Override the default class color setting."],
					type = "select",
					values = {
						["USE_DEFAULT"] = L["Use Default"],
						["FORCE_ON"] = L["Force On"],
						["FORCE_OFF"] = L["Force Off"]
					}
				},
			},
		},
		targetsGroup = {
			order = 4,
			type = "group",
			name = L["Tank Target"],
			get = function(info) return E.db.unitframe.units["tank"]["targetsGroup"][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units["tank"]["targetsGroup"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("tank") end,
			args = {
				enable = {
					type = "toggle",
					name = L["Enable"],
					order = 1,
				},
				width = {
					order = 2,
					name = L["Width"],
					type = "range",
					min = 10, max = 500, step = 1,
				},
				height = {
					order = 3,
					name = L["Height"],
					type = "range",
					min = 10, max = 250, step = 1,
				},
				anchorPoint = {
					type = "select",
					order = 5,
					name = L["Anchor Point"],
					desc = L["What point to anchor to the frame you set to attach to."],
					values = petAnchors,
				},
				xOffset = {
					order = 6,
					type = "range",
					name = L["xOffset"],
					desc = L["An X offset (in pixels) to be used when anchoring new frames."],
					min = -500, max = 500, step = 1,
				},
				yOffset = {
					order = 7,
					type = "range",
					name = L["yOffset"],
					desc = L["An Y offset (in pixels) to be used when anchoring new frames."],
					min = -500, max = 500, step = 1,
				},
				colorOverride = {
					order = 8,
					name = L["Class Color Override"],
					desc = L["Override the default class color setting."],
					type = "select",
					values = {
						["USE_DEFAULT"] = L["Use Default"],
						["FORCE_ON"] = L["Force On"],
						["FORCE_OFF"] = L["Force Off"]
					}
				},
			},
		},
		buffs = GetOptionsTable_Auras(true, "buffs", true, UF.CreateAndUpdateHeaderGroup, "tank"),
		debuffs = GetOptionsTable_Auras(true, "debuffs", true, UF.CreateAndUpdateHeaderGroup, "tank"),
		buffIndicator = {
			order = 800,
			type = "group",
			name = L["Buff Indicator"],
			get = function(info) return E.db.unitframe.units["tank"]["buffIndicator"][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units["tank"]["buffIndicator"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("tank") end,
			args = {
				enable = {
					type = "toggle",
					name = L["Enable"],
					order = 1,
				},
				size = {
					type = "range",
					name = L["Size"],
					desc = L["Size of the indicator icon."],
					order = 3,
					min = 4, max = 50, step = 1,
				},
				fontSize = {
					type = "range",
					name = L["Font Size"],
					order = 4,
					min = 7, max = 22, step = 1,
				},
				profileSpecific = {
					type = "toggle",
					name = L["Profile Specific"],
					desc = L["Use the profile specific filter 'Buff Indicator (Profile)' instead of the global filter 'Buff Indicator'."],
					order = 5,
				},
				configureButton = {
					type = "execute",
					name = L["Configure Auras"],
					func = function()
						if E.db.unitframe.units["tank"]["buffIndicator"].profileSpecific then
							E:SetToFilterConfig("Buff Indicator (Profile)")
						else
							E:SetToFilterConfig("Buff Indicator")
						end
					end,
					order = 6
				},
			},
		},
	},
}

E.Options.args.unitframe.args.assist = { -- Помощники
	name = L["Assist Frames"],
	type = "group",
	order = 1600,
	childGroups = "select",
	get = function(info) return E.db.unitframe.units["assist"][ info[#info] ] end,
	set = function(info, value) E.db.unitframe.units["assist"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("assist") end,
	args = {
		resetSettings = {
			type = "execute",
			order = 2,
			name = L["Restore Defaults"],
			func = function(info, value) UF:ResetUnitSettings("assist"); end,
		},
		general = {
			order = 2,
			type = "group",
			name = L["General"],
			guiInline = true,
			args = {
				enable = {
					type = "toggle",
					order = 1,
					name = L["Enable"],
				},
				width = {
					order = 2,
					name = L["Width"],
					type = "range",
					min = 50, max = 500, step = 1,
				},
				height = {
					order = 3,
					name = L["Height"],
					type = "range",
					min = 10, max = 250, step = 1,
				},
				verticalSpacing = {
					order = 4,
					type = "range",
					name = L["Vertical Spacing"],
					min = 0, max = 100, step = 1,
				},
				disableDebuffHighlight = {
					order = 5,
					type = "toggle",
					name = L["Disable Debuff Highlight"],
					desc = L["Forces Debuff Highlight to be disabled for these frames"],
					disabled = function() return E.db.unitframe.debuffHighlighting == "NONE"; end,
				},
				orientation = {
					order = 6,
					type = "select",
					name = L["Frame Orientation"],
					desc = L["Set the orientation of the UnitFrame. If set to automatic it will adjust based on where the frame is located on the screen."],
					values = {
						--["AUTOMATIC"] = L["Automatic"], not sure if i will use this yet
						["LEFT"] = L["Left"],
						["MIDDLE"] = L["Middle"],
						["RIGHT"] = L["Right"],
					},
				},
				colorOverride = {
					order = 7,
					name = L["Class Color Override"],
					desc = L["Override the default class color setting."],
					type = "select",
					values = {
						["USE_DEFAULT"] = L["Use Default"],
						["FORCE_ON"] = L["Force On"],
						["FORCE_OFF"] = L["Force Off"]
					}
				},
			},
		},
		targetsGroup = {
			order = 4,
			type = "group",
			name = L["Assist Target"],
			get = function(info) return E.db.unitframe.units["assist"]["targetsGroup"][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units["assist"]["targetsGroup"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("assist") end,
			args = {
				enable = {
					type = "toggle",
					name = L["Enable"],
					order = 1,
				},
				width = {
					order = 2,
					name = L["Width"],
					type = "range",
					min = 10, max = 500, step = 1,
				},
				height = {
					order = 3,
					name = L["Height"],
					type = "range",
					min = 10, max = 250, step = 1,
				},
				anchorPoint = {
					type = "select",
					order = 5,
					name = L["Anchor Point"],
					desc = L["What point to anchor to the frame you set to attach to."],
					values = petAnchors,
				},
				xOffset = {
					order = 6,
					type = "range",
					name = L["xOffset"],
					desc = L["An X offset (in pixels) to be used when anchoring new frames."],
					min = -500, max = 500, step = 1,
				},
				yOffset = {
					order = 7,
					type = "range",
					name = L["yOffset"],
					desc = L["An Y offset (in pixels) to be used when anchoring new frames."],
					min = -500, max = 500, step = 1,
				},
				colorOverride = {
					order = 8,
					name = L["Class Color Override"],
					desc = L["Override the default class color setting."],
					type = "select",
					values = {
						["USE_DEFAULT"] = L["Use Default"],
						["FORCE_ON"] = L["Force On"],
						["FORCE_OFF"] = L["Force Off"]
					}
				},
			},
		},
		buffs = GetOptionsTable_Auras(true, "buffs", true, UF.CreateAndUpdateHeaderGroup, "assist"),
		debuffs = GetOptionsTable_Auras(true, "debuffs", true, UF.CreateAndUpdateHeaderGroup, "assist"),
		buffIndicator = {
			order = 800,
			type = "group",
			name = L["Buff Indicator"],
			get = function(info) return E.db.unitframe.units["assist"]["buffIndicator"][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units["assist"]["buffIndicator"][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup("assist") end,
			args = {
				enable = {
					type = "toggle",
					name = L["Enable"],
					order = 1,
				},
				size = {
					type = "range",
					name = L["Size"],
					desc = L["Size of the indicator icon."],
					order = 3,
					min = 4, max = 50, step = 1,
				},
				fontSize = {
					type = "range",
					name = L["Font Size"],
					order = 4,
					min = 7, max = 22, step = 1,
				},
				profileSpecific = {
					type = "toggle",
					name = L["Profile Specific"],
					desc = L["Use the profile specific filter 'Buff Indicator (Profile)' instead of the global filter 'Buff Indicator'."],
					order = 5,
				},
				configureButton = {
					type = "execute",
					name = L["Configure Auras"],
					func = function()
						if E.db.unitframe.units["assist"]["buffIndicator"].profileSpecific then
							E:SetToFilterConfig("Buff Indicator (Profile)")
						else
							E:SetToFilterConfig("Buff Indicator")
						end
					end,
					order = 6
				},
			},
		},
	},
}

--MORE COLORING STUFF YAY
E.Options.args.unitframe.args.general.args.allColorsGroup.args.classResourceGroup = {
	order = -10,
	type = 'group',
	guiInline = true,
	name = L['Class Resources'],
	get = function(info)
		local t = E.db.unitframe.colors.classResources[ info[#info] ];
		local d = P.unitframe.colors.classResources[ info[#info] ]
		return t.r, t.g, t.b, t.a, d.r, d.g, d.b
	end,
	set = function(info, r, g, b)
		E.db.unitframe.colors.classResources[ info[#info] ] = {};
		local t = E.db.unitframe.colors.classResources[ info[#info] ];
		t.r, t.g, t.b = r, g, b;
		UF:Update_AllFrames();
	end,
	args = {};
};

E.Options.args.unitframe.args.general.args.allColorsGroup.args.classResourceGroup.args.spacer = {
	order = 2,
	name = ' ',
	type = 'description',
	width = 'full'
};

for i = 1, 5 do
	E.Options.args.unitframe.args.general.args.allColorsGroup.args.classResourceGroup.args['combo'..i] = {
		order = i + 2,
		type = 'color',
		name = L['Combo Point']..' #'..i,
		get = function(info)
			local t = E.db.unitframe.colors.classResources.comboPoints[i];
			local d = P.unitframe.colors.classResources.comboPoints[i]
			return t.r, t.g, t.b, t.a, d.r, d.g, d.b
		end,
		set = function(info, r, g, b)
			E.db.unitframe.colors.classResources.comboPoints[i] = {};
			local t = E.db.unitframe.colors.classResources.comboPoints[i];
			t.r, t.g, t.b = r, g, b;
			UF:Update_AllFrames();
		end,
	};
end


if(P.unitframe.colors.classResources[E.myclass]) then
	E.Options.args.unitframe.args.general.args.allColorsGroup.args.classResourceGroup.args.spacer2 = {
		order = 10,
		name = ' ',
		type = 'description',
		width = 'full'
	};

	local ORDER = 20
	if(E.myclass == 'DEATHKNIGHT') then
		local names = {
			[1] = L['Blood'],
			[2] = L['Unholy'],
			[3] = L['Frost'],
			[4] = L['Death']
		};
		for i = 1, 4 do
			E.Options.args.unitframe.args.general.args.allColorsGroup.args.classResourceGroup.args['resource'..i] = {
				type = 'color',
				name = names[i],
				order = ORDER + i,
				get = function(info)
					local t = E.db.unitframe.colors.classResources.DEATHKNIGHT[i];
					local d = P.unitframe.colors.classResources.DEATHKNIGHT[i]
					return t.r, t.g, t.b, t.a, d.r, d.g, d.b
				end,
				set = function(info, r, g, b)
					E.db.unitframe.colors.classResources.DEATHKNIGHT[i] = {};
					local t = E.db.unitframe.colors.classResources.DEATHKNIGHT[i];
					t.r, t.g, t.b = r, g, b;
					UF:Update_AllFrames();
				end,
			};
		end
	end
end

function E:RefreshCustomTextsConfigs()
	for _, customText in pairs(CUSTOMTEXT_CONFIGS) do
		customText.hidden = true;
	end
	twipe(CUSTOMTEXT_CONFIGS);

	for unit, _ in pairs(E.db.unitframe.units) do
		if(E.db.unitframe.units[unit].customTexts) then
			for objectName, _ in pairs(E.db.unitframe.units[unit].customTexts) do
				UF:CreateCustomTextGroup(unit, objectName);
			end
		end
	end
end
E:RefreshCustomTextsConfigs();
