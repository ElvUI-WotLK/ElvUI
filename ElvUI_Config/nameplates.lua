local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule("NamePlates")

local selectedFilter
local filters

local positionValues = {
	TOPLEFT = "TOPLEFT",
	LEFT = "LEFT",
	BOTTOMLEFT = "BOTTOMLEFT",
	RIGHT = "RIGHT",
	TOPRIGHT = "TOPRIGHT",
	BOTTOMRIGHT = "BOTTOMRIGHT",
	CENTER = "CENTER",
	TOP = "TOP",
	BOTTOM = "BOTTOM",
};

local function UpdateFilterGroup()
	if not selectedFilter or not E.global["nameplate"]["filter"][selectedFilter] then
		E.Options.args.nameplate.args.filters.args.filterGroup = nil
		return
	end
	
	E.Options.args.nameplate.args.filters.args.filterGroup = {
		type = "group",
		name = selectedFilter,
		guiInline = true,
		order = -10,
		get = function(info) return E.global["nameplate"]["filter"][selectedFilter][ info[#info] ] end,
		set = function(info, value) E.global["nameplate"]["filter"][selectedFilter][ info[#info] ] = value; NP:ForEachPlate("CheckFilter"); NP:UpdateAllPlates(); UpdateFilterGroup() end,		
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
					local t = E.global["nameplate"]["filter"][selectedFilter][ info[#info] ]
					if t then
						return t.r, t.g, t.b, t.a
					end
				end,
				set = function(info, r, g, b)
					E.global["nameplate"]["filter"][selectedFilter][ info[#info] ] = {}
					local t = E.global["nameplate"]["filter"][selectedFilter][ info[#info] ]
					if t then
						t.r, t.g, t.b = r, g, b
						UpdateFilterGroup()
						NP:ForEachPlate("CheckFilter")
						NP:UpdateAllPlates()
					end
				end,
			},
			customScale = {
				type = "range",
				name = L["Custom Scale"],
				desc = L["Set the scale of the nameplate."],
				min = 0.67, max = 2, step = 0.01,			
			},
		},	
	}
end

E.Options.args.nameplate = {
	type = "group",
	name = L["NamePlates"],
	childGroups = "select",
	get = function(info) return E.db.nameplate[ info[#info] ] end,
	set = function(info, value) E.db.nameplate[ info[#info] ] = value; NP:UpdateAllPlates() end,
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["NAMEPLATE_DESC"],
		},
		enable = {
			order = 2,
			type = "toggle",
			name = L["Enable"],
			get = function(info) return E.private.nameplate[ info[#info] ] end,
			set = function(info, value) E.private.nameplate[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL") end
		},
		general = {
			order = 1,
			type = "group",
			name = L["General"],
			disabled = function() return not E.NamePlates; end,
			args = {
				statusbar = {
					order = 0,
					type = "select",
					dialogControl = "LSM30_Statusbar",
					name = L["StatusBar Texture"],
					values = AceGUIWidgetLSMlists.statusbar
				},
				showEnemyCombat = {
					order = 1,
					type = "select",
					name = L["Enemy Combat Toggle"],
					desc = L["Control enemy nameplates toggling on or off when in combat."],
					values = {
						["DISABLED"] = L["Disabled"],
						["TOGGLE_ON"] = L["Toggle On While In Combat"],
						["TOGGLE_OFF"] = L["Toggle Off While In Combat"],
					},
					set = function(info, value) 
						E.db.nameplate[ info[#info] ] = value; 
						NP:PLAYER_REGEN_ENABLED()
					end,
				},
				showFriendlyCombat = {
					order = 2,
					type = "select",
					name = L["Friendly Combat Toggle"],
					desc = L["Control friendly nameplates toggling on or off when in combat."],
					values = {
						["DISABLED"] = L["Disabled"],
						["TOGGLE_ON"] = L["Toggle On While In Combat"],
						["TOGGLE_OFF"] = L["Toggle Off While In Combat"],
					},					
					set = function(info, value) E.db.nameplate[ info[#info] ] = value; NP:PLAYER_REGEN_ENABLED() end,
				}, 
				comboPoints = {
					type = "toggle",
					order = 3,
					name = L["Combo Points"],
					desc = L["Display combo points on nameplates."],
				},
				nonTargetAlpha = {
					type = "range",
					order = 4,
					name = L["Non-Target Alpha"],
					desc = L["Alpha of nameplates that are not your current target."],
					min = 0, max = 1, step = 0.01, isPercent = true,
				},
				targetAlpha = {
					type = "range",
					order = 5,
					name = L["Target Alpha"],
					desc = L["Alpha of current target nameplate."],
					min = 0, max = 1, step = 0.01, isPercent = true,
				},
				colorNameByValue = {
					type = "toggle",
					order = 6,
					name = L["Color Name By Health Value"],		
				},
				lowHealthThreshold = {
					order = 7,
					type = "range",
					name = L["Low Health Threshold"],
					desc = L["Make the unitframe glow yellow when it is below this percent of health, it will glow red when the health value is half of this value."],
					isPercent = true,
					min = 0, max = 1, step = 0.01
				},
				healthAnimationSpeed = {
 					order = 8,
					type = "range",
					name = L["Health Animation Speed"],
					min = 0, max = 1, step = 0.01
				},
				fontGroup = {
					order = 100,
					type = "group",
					guiInline = true,
					name = L["Fonts"],
					args = {
						showName = {
							type = "toggle",
							order = 1,
							name = L["Show Name"],
						},
						showLevel = {
							type = "toggle",
							order = 2,
							name = L["Show Level"],
						},
						wrapName = {
							type = "toggle",
							order = 3,
							name = L["Wrap Name"],
							desc = L["Wraps name instead of truncating it."],
						},
						font = {
							type = "select", dialogControl = "LSM30_Font",
							order = 4,
							name = L["Font"],
							values = AceGUIWidgetLSMlists.font,
						},
						fontSize = {
							order = 5,
							name = L["Font Size"],
							type = "range",
							min = 6, max = 22, step = 1,
						},	
						fontOutline = {
							order = 6,
							name = L["Font Outline"],
							desc = L["Set the font outline."],
							type = "select",
							values = {
								["NONE"] = L["None"],
								["OUTLINE"] = "OUTLINE",
								
								["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
								["THICKOUTLINE"] = "THICKOUTLINE",
							},
						},							
					},
				},
				castGroup = {
					order = 150,
					type = "group",
					name = L["Cast Bar"],
					guiInline = true,
					get = function(info)
						local t = E.db.nameplate[ info[#info] ];
						local d = P.nameplate[info[#info]];
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b;
					end,
					set = function(info, r, g, b)
						E.db.nameplate[ info[#info] ] = {};
						local t = E.db.nameplate[ info[#info] ];
						t.r, t.g, t.b = r, g, b;
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
					name = L["Reaction Coloring"],
					guiInline = true,
					get = function(info)
						local t = E.db.nameplate.reactions[ info[#info] ]
						local d = P.nameplate.reactions[info[#info]]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b
					end,
					set = function(info, r, g, b)
						E.db.nameplate.reactions[ info[#info] ] = {}
						local t = E.db.nameplate.reactions[ info[#info] ]
						t.r, t.g, t.b = r, g, b
						NP:UpdateAllPlates()
					end,				
					args = {
						friendlyNPC = {
							type = "color",
							order = 1,
							name = L["Friendly NPC"],
							hasAlpha = false,
						},
						friendlyPlayer = {
							name = L["Friendly Player"],
							order = 2,
							type = "color",
							hasAlpha = false,
						},
						neutral = {
							name = L["Neutral"],
							order = 3,
							type = "color",
							hasAlpha = false,
						},		
						enemy = {
							name = L["Enemy"],
							order = 4,
							type = "color",
							hasAlpha = false,
						},	
						tapped = {
							name = L["Tagged NPC"],
							order = 5,
							type = "color",
							hasAlpha = false,
						},
					},		
				},
			},
		},
		healthBar = {
			type = "group",
			order = 2,
			name = L["Health Bar"],
			disabled = function() return not E.NamePlates; end,
			get = function(info) return E.db.nameplate.healthBar[ info[#info] ] end,
			set = function(info, value) E.db.nameplate.healthBar[ info[#info] ] = value; NP:UpdateAllPlates() end,			
			args = {
				width = {
					type = "range",
					order = 1,
					name = L["Width"],
					desc = L["Controls the width of the nameplate"],
					type = "range",
					min = 50, max = 125, step = 1,		
				},	
				height = {
					type = "range",
					order = 2,
					name = L["Height"],
					desc = L["Controls the height of the nameplate"],
					type = "range",
					min = 4, max = 30, step = 1,					
				},
				colorByRaidIcon = {
					type = "toggle",
					order = 4,
					name = L["Color By Raid Icon"],
				},
				spacer = {
					order = 5,
					type = "description",
					name = "\n",
				},
				lowHPScale = {
					type = "group",
					order = 6,
					name = L["Scale if Low Health"],
					guiInline = true,
					get = function(info) return E.db.nameplate.healthBar.lowHPScale[ info[#info] ] end,
					set = function(info, value) E.db.nameplate.healthBar.lowHPScale[ info[#info] ] = value; NP:UpdateAllPlates() end,			
					args = {
						enable = {
							type = "toggle",
							name = L["Enable"],
							order = 1,
							desc = L["Adjust nameplate size on low health"],
						},
						width = {
							type = "range",
							order = 2,
							name = L["Low HP Width"],
							desc = L["Controls the width of the nameplate on low health"],
							type = "range",
							min = 50, max = 125, step = 1,		
						},	
						height = {
							type = "range",
							order = 3,
							name = L["Low HP Height"],
							desc = L["Controls the height of the nameplate on low health"],
							type = "range",
							min = 4, max = 30, step = 1,					
						},
						toFront = {
							type = "toggle",
							order = 4,
							name = L["Bring to front on low health"],
							desc = L["Bring nameplate to front on low health"],
						},
						changeColor = {
							type = "toggle",
							order = 5,
							name = L["Change color on low health"],
							desc = L["Change color on low health"],
						},
						color = {
							get = function(info)
								local t = E.db.nameplate.healthBar.lowHPScale.color
								local d = P.nameplate.healthBar.lowHPScale.color
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b
							end,
							set = function(info, r, g, b)
								E.db.nameplate.healthBar.lowHPScale.color = {}
								local t = E.db.nameplate.healthBar.lowHPScale.color
								t.r, t.g, t.b = r, g, b
								NP:UpdateAllPlates()
							end,				
							name = L["Color on low health"],
							order = 6,
							type = "color",
							hasAlpha = false,
						},
					},
				},
				fontGroup = {
					order = 5,
					type = "group",
					name = L["Fonts"],
					guiInline = true,
					get = function(info) return E.db.nameplate.healthBar.text[ info[#info] ] end,
					set = function(info, value) E.db.nameplate.healthBar.text[ info[#info] ] = value; NP:UpdateAllPlates() end,			
					args = {
						enable = {
							type = "toggle",
							name = L["Enable"],
							order = 1,
						},
						format = {
							type = "select",
							order = 2,
							name = L["Format"],
							values = {
								["CURRENT_MAX_PERCENT"] = L["Current - Max | Percent"],
								["CURRENT_PERCENT"] = L["Current - Percent"],
								["CURRENT_MAX"] = L["Current - Max"],
								["CURRENT"] = L["Current"],
								["PERCENT"] = L["Percent"],
								["DEFICIT"] = L["Deficit"],
							},
						},
					},
				}
			},
		},
		castBar = {
			type = "group",
			order = 3,
			name = L["Cast Bar"],
			disabled = function() return not E.NamePlates; end,
			get = function(info) return E.db.nameplate.castBar[ info[#info] ] end,
			set = function(info, value) E.db.nameplate.castBar[ info[#info] ] = value; NP:UpdateAllPlates() end,			
			args = {
				hideSpellName = {
					order = 1,
					name = L["Hide Spell Name"],
					type = "toggle",
				},
				hideTime = {
					order = 2,
					name = L["Hide Time"],
					type = "toggle",
				},
				height = {
					type = "range",
					order = 3,
					name = L["Height"],
					type = "range",
					min = 4, max = 30, step = 1,
				},
			},
		},
		targetIndicator = {
			type = "group",
			order = 4,
			name = L["Target Indicator"],
			get = function(info) return E.db.nameplate.targetIndicator[ info[#info] ] end,
			set = function(info, value) E.db.nameplate.targetIndicator[ info[#info] ] = value; WorldFrame.elapsed = 3; NP:UpdateAllPlates() end,				
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
				},
				width = {
					order = 2,
					name = L["Width"],
					type = "range",
					min = 0, max = 220, step = 1,
					disabled = function() return (NP.db.targetIndicator.style == "glow") end,
					set = function(info, value) E.db.nameplate.targetIndicator[ info[#info] ] = value; NP:SetTargetIndicatorDimensions() end,	
				},
				height = {
					order = 3,
					name = L["Height"],
					type = "range",
					min = 0, max = 220, step = 1,
					disabled = function() return (NP.db.targetIndicator.style == "glow") end,
					set = function(info, value) E.db.nameplate.targetIndicator[ info[#info] ] = value; NP:SetTargetIndicatorDimensions() end,	
				},			
				style = {
					order = 4,
					name = L["Style"],
					type = "select",
					values = {
						arrow = L["Vertical Arrow"],
						doubleArrow = L["Horrizontal Arrows"],
						doubleArrowInverted = L["Horrizontal Arrows (Inverted)"],
						glow = L["Glow"]
					},
					set = function(info, value) E.db.nameplate.targetIndicator[ info[#info] ] = value; NP:SetTargetIndicator(); NP:UpdateAllPlates() end,	
				},
				xOffset = {
					order = 5,
					name = L["X-Offset"],
					type = "range",
					min = -100, max = 100, step = 1,
					disabled = function() return (NP.db.targetIndicator.style ~= "doubleArrow" and NP.db.targetIndicator.style ~= "doubleArrowInverted") end
				},					
				yOffset = {
					order = 6,
					name = L["Y-Offset"],
					type = "range",
					min = -100, max = 100, step = 1,
					disabled = function() return (NP.db.targetIndicator.style ~= "arrow") end
				},
				colorMatchHealthBar = {
					order = 10,
					type = "toggle",
					name = L["Color By Healthbar"],
					desc = L["Match the color of the healthbar."],
					set = function(info, value) 
						E.db.nameplate.targetIndicator.colorMatchHealthBar = value; 
						if(not value) then
							local color = E.db.nameplate.targetIndicator.color
							NP:ColorTargetIndicator(color.r, color.g, color.b)
						else
							WorldFrame.elapsed = 3
						end
					end,
				},
				color = {
					type = "color",
					name = L["Color"],
					order = 11,
					disabled = function() return E.db.nameplate.targetIndicator.colorMatchHealthBar end,
					get = function(info)
						local t = E.db.nameplate.targetIndicator[ info[#info] ]
						local d = P.nameplate.targetIndicator[ info[#info] ]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b
					end,
					set = function(info, r, g, b)
						E.db.nameplate.targetIndicator[ info[#info] ] = {}
						local t = E.db.nameplate.targetIndicator[ info[#info] ]
						t.r, t.g, t.b = r, g, b
						NP:UpdateAllPlates()
					end,
				},
			},
		},
		raidIcon = {
			type = "group",
			order = 5,
			name = L["Raid Icon"],
			get = function(info) return E.db.nameplate.raidIcon[ info[#info] ] end,
			set = function(info, value) E.db.nameplate.raidIcon[ info[#info] ] = value; NP:UpdateAllPlates() end,	
			args = {
				size = {
					order = 2,
					type = "range",
					name = L["Size"],
					min = 10, max = 200, step = 1,
				},
				attachTo = {
					type = "select",
					order = 3,
					name = L["Attach To"],
					values = positionValues,
				},
				xOffset = {
					type = "range",
					order = 4,
					name = L["X-Offset"],
					min = -150, max = 150, step = 1,
				},
				yOffset = {
					type = "range",
					order = 5,
					name = L["Y-Offset"],
					min = -150, max = 150, step = 1,
				},
			},
		},
		buffs = {
			order = 4,
			type = "group",
			name = L["Buffs"],
			get = function(info) return E.db.nameplate.buffs[ info[#info] ]; end,
			set = function(info, value) E.db.nameplate.buffs[ info[#info] ] = value; NP:UpdateAllPlates(); end,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"]
				},
				numAuras = {
					order = 2,
					type = "range",
					name = L["# Displayed Auras"],
					desc = L["Controls how many auras are displayed, this will also affect the size of the auras."],
					min = 1, max = 8, step = 1
				},
				baseHeight = {
					order = 3,
					type = "range",
					name = L["Icon Base Height"],
					desc = L["Base Height for the Aura Icon"],
					min = 6, max = 60, step = 1
				},
				filtersGroup = {
					order = 4,
					type = "group",
					name = L["Filters"],
					guiInline = true,
					get = function(info) return E.db.nameplate.buffs.filters[ info[#info] ]; end,
					set = function(info, value) E.db.nameplate.buffs.filters[ info[#info] ] = value; NP:UpdateAllPlates(); end,
					args = {
						personal = {
							order = 1,
							type = "toggle",
							name = L["Personal Auras"]
						},
						maxDuration = {
							order = 2,
							type = "range",
							name = L["Maximum Duration"],
							min = 5, max = 3000, step = 1
						},
						filter = {
							order = 3,
							type = "select",
							name = L["Additional Filter"],
							values = function()
								filters = {};
								filters[""] = NONE;
								for filter in pairs(E.global["unitframe"]["aurafilters"]) do
									filters[filter] = filter;
								end
								return filters;
							end
						}
					}
				}
			}
		},
		debuffs = {
			order = 5,
			type = "group",
			name = L["Debuffs"],
			get = function(info) return E.db.nameplate.debuffs[ info[#info] ]; end,
			set = function(info, value) E.db.nameplate.debuffs[ info[#info] ] = value; NP:UpdateAllPlates(); end,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"]
				},
				numAuras = {
					order = 2,
					type = "range",
					name = L["# Displayed Auras"],
					desc = L["Controls how many auras are displayed, this will also affect the size of the auras."],
					min = 1, max = 8, step = 1
				},
				baseHeight = {
					order = 3,
					type = "range",
					name = L["Icon Base Height"],
					desc = L["Base Height for the Aura Icon"],
					min = 6, max = 60, step = 1
				},
				filtersGroup = {
					order = 4,
					type = "group",
					name = L["Filters"],
					guiInline = true,
					get = function(info) return E.db.nameplate.debuffs.filters[ info[#info] ]; end,
					set = function(info, value) E.db.nameplate.debuffs.filters[ info[#info] ] = value; NP:UpdateAllPlates(); end,
					args = {
						personal = {
							order = 1,
							type = "toggle",
							name = L["Personal Auras"]
						},
						maxDuration = {
							order = 2,
							type = "range",
							name = L["Maximum Duration"],
							min = 5, max = 3000, step = 1
						},
						filter = {
							order = 3,
							type = "select",
							name = L["Additional Filter"],
							values = function()
								filters = {};
								filters[""] = NONE;
								for filter in pairs(E.global["unitframe"]["aurafilters"]) do
									filters[filter] = filter;
								end
								return filters;
							end
						}
					}
				}
			}
		},
		threat = {
			order = 6,
			type = "group",
			name = L["Threat"],
			get = function(info)
				local t = E.db.nameplate.threat[ info[#info] ]
				local d = P.nameplate.threat[info[#info]]
				return t.r, t.g, t.b, t.a, d.r, d.g, d.b
			end,
			set = function(info, r, g, b)
				E.db.nameplate[ info[#info] ] = {}
				local t = E.db.nameplate.threat[ info[#info] ]
				t.r, t.g, t.b = r, g, b
			end,
			args = {
				useThreatColor = {
					order = 1,
					type = "toggle",
					name = L["Use Threat Color"],
					get = function(info) return E.db.nameplate.threat.useThreatColor; end,
					set = function(info, value) E.db.nameplate.threat.useThreatColor = value; end
				},
				goodColor = {
					order = 2,
					type = "color",
					name = L["Good"],
					hasAlpha = false
				},
				badColor = {
					order = 3,
					type = "color",
					name = L["Bad"],
					hasAlpha = false
				},
				goodTransition = {
					order = 4,
					type = "color",
					name = L["Good Transition"],
					hasAlpha = false
				},		
				badTransition = {
					order = 5,
					type = "color",
					name = L["Bad Transition"],
					hasAlpha = false
				},
				goodScale = {
					order = 6,
					type = "range",
					name = L["Good"],
					min = 0.5, max = 1.5, step = 0.01, isPercent = true,
					get = function(info) return E.db.nameplate.threat[ info[#info] ] end,
					set = function(info, value) E.db.nameplate.threat[ info[#info] ] = value; end
				},
				badScale = {
					order = 7,
					type = "range",
					name = L["Bad"],
					min = 0.5, max = 1.5, step = 0.01, isPercent = true,
					get = function(info) return E.db.nameplate.threat[ info[#info] ] end,
					set = function(info, value) E.db.nameplate.threat[ info[#info] ] = value; end
				}
			}
		},
		filters = {
			type = "group",
			order = 200,
			name = L["Filters"],
			disabled = function() return not E.NamePlates; end,
			args = {
				addname = {
					type = "input",
					order = 1,
					name = L["Add Name"],
					get = function(info) return "" end,
					set = function(info, value) 
						if E.global["nameplate"]["filter"][value] then
							E:Print(L["Filter already exists!"])
							return
						end
						
						E.global["nameplate"]["filter"][value] = {
							["enable"] = true,
							["hide"] = false,
							["customColor"] = false,
							["customScale"] = 1,
							["color"] = {r = 104/255, g = 138/255, b = 217/255},
						}
						UpdateFilterGroup()
						NP:UpdateAllPlates() 
					end,
				},
				deletename = {
					type = "input",
					order = 2,
					name = L["Remove Name"],
					get = function(info) return "" end,
					set = function(info, value) 
						if G["nameplate"]["filter"][value] then
							E.global["nameplate"]["filter"][value].enable = false;
							E:Print(L["You can't remove a default name from the filter, disabling the name."])
						else
							E.global["nameplate"]["filter"][value] = nil;
							E.Options.args.nameplate.args.filters.args.filterGroup = nil;
						end
						UpdateFilterGroup()
						NP:UpdateAllPlates();
					end,
				},
				selectFilter = {
					order = 3,
					type = "select",
					name = L["Select Filter"],
					get = function(info) return selectedFilter end,
					set = function(info, value) selectedFilter = value; UpdateFilterGroup() end,							
					values = function()
						filters = {}
						for filter in pairs(E.global["nameplate"]["filter"]) do
							filters[filter] = filter
						end
						return filters
					end,
				},
			},
		},
	},
};