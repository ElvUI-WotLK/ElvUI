local E, L, V, P, G, _ = unpack(ElvUI);
local A = E:GetModule('Auras')

local auraOptions = {
	size = {
		type = 'range',
		name = L['Size'],
		desc = L['Set the size of the individual auras.'],
		min = 16, max = 60, step = 2,
		order = 1,
	},				
	growthDirection = {
		type = 'select',
		order = 2,
		name = L['Growth Direction'],
		desc = L['The direction the auras will grow and then the direction they will grow after they reach the wrap after limit.'],
		values = {
			DOWN_RIGHT = format(L['%s and then %s'], L['Down'], L['Right']),
			DOWN_LEFT = format(L['%s and then %s'], L['Down'], L['Left']),
			UP_RIGHT = format(L['%s and then %s'], L['Up'], L['Right']),
			UP_LEFT = format(L['%s and then %s'], L['Up'], L['Left']),
			RIGHT_DOWN = format(L['%s and then %s'], L['Right'], L['Down']),
			RIGHT_UP = format(L['%s and then %s'], L['Right'], L['Up']),
			LEFT_DOWN = format(L['%s and then %s'], L['Left'], L['Down']),
			LEFT_UP = format(L['%s and then %s'], L['Left'], L['Up']),								
		},
	},
	wrapAfter = {
		type = 'range',
		order = 3,
		name = L['Wrap After'],
		desc = L['Begin a new row or column after this many auras.'],
		min = 1, max = 32, step = 1,
	},					
	maxWraps = {
		name = L['Max Wraps'],
		order = 4,
		desc = L['Limit the number of rows or columns.'],
		type = 'range',
		min = 1, max = 32, step = 1,
	},
	horizontalSpacing = {
		order = 5,
		type = 'range',
		name = L['Horizontal Spacing'],
		min = 0, max = 50, step = 1,		
	},
	verticalSpacing = {
		order = 6,
		type = 'range',
		name = L['Vertical Spacing'],
		min = 0, max = 50, step = 1,		
	},				
	sortMethod = {
		order = 7,
		name = L['Sort Method'],
		desc = L['Defines how the group is sorted.'],
		type = 'select',
		values = {
			['INDEX'] = L['Index'],
			['TIME'] = L['Time'],
			['NAME'] = L['Name'],
		},
	},
	sortDir = {
		order = 8,
		name = L['Sort Direction'],
		desc = L['Defines the sort order of the selected sort method.'],
		type = 'select',
		values = {
			['+'] = L['Ascending'],
			['-'] = L['Descending'],
		},				
	},				
	seperateOwn = {
		order = 9,
		name = L['Seperate'],
		desc = L['Indicate whether buffs you cast yourself should be separated before or after.'],
		type = 'select',
		values = {
			[-1] = L["Other's First"],
			[0] = L['No Sorting'],
			[1] = L['Your Auras First'],
		},
	},
	barPosition = {
		type = 'select',
		order = 10,
		name = L['Statusbar Position'],
		desc = L['Choose where you want the statusbar to be positioned. If you position it on the left or right side of the icon I advice you to increase Horizontal Spacing for Buffs and Debuffs'],
		values = {
			['TOP'] = L['Above Icons'],
			['BOTTOM'] = L['Below Icons'],
			['LEFT'] = L['Left Side of Icons'],
			['RIGHT'] = L['Right Side of Icons'],
		},
	},
	barSpacing = {
		order = 11,
		type = 'range',
		name = L['Statusbar Spacing'],
		desc = L['Additional spacing between icon and statusbar. If a negative value is chosen then the statusbar is shown inside the icon'],
		min = -25, max = 25, step = 1,
	},
	spacer1 = {
		type = 'description',
		order = 12,
		name = '',
	},
	barHeight = {
		type = 'range',
		order = 13,
		name = L['Statusbar Height'],
		desc = L['Height of the statusbar frame'],
		min = 5, max = 15, step = 1,
		-- disabled = function() return end,
	},
	barWidth = {
		type = 'range',
		order = 14,
		name = L['Statusbar Width'],
		desc = L['Width of the statusbar frame'],
		min = 5, max = 15, step = 1,
		-- disabled = function() return end,
	},
}

E.Options.args.auras = {
	type = 'group',
	name = BUFFOPTIONS_LABEL,
	childGroups = "select",
	get = function(info) return E.db.auras[ info[#info] ] end,
	set = function(info, value) E.db.auras[ info[#info] ] = value; A.BuffFrame:UpdateLayout(); A.DebuffFrame:UpdateLayout(); end,
	args = {
		intro = {
			order = 1,
			type = 'description',
			name = L['AURAS_DESC'],
		},
		enable = {
			order = 2,
			type = 'toggle',
			name = L['Enable'],
			get = function(info) return E.private.auras[ info[#info] ] end,
			set = function(info, value) 
				E.private.auras[ info[#info] ] = value; 
				E:StaticPopup_Show("PRIVATE_RL")
			end,		
		},	
		disableBlizzard = {
			order = 3,
			type = 'toggle',
			name = L['Disabled Blizzard'],
			get = function(info) return E.private.auras[ info[#info] ] end,
			set = function(info, value) 
				E.private.auras[ info[#info] ] = value; 
				E:StaticPopup_Show("PRIVATE_RL")
			end,		
		},			
		general = {
			order = 5,
			type = 'group',
			name = L['General'],
			args = {
				fadeThreshold = {
					type = 'range',
					name = L["Fade Threshold"],
					desc = L['Threshold before text changes red, goes into decimal form, and the icon will fade. Set to -1 to disable.'],
					min = -1, max = 30, step = 1,
					order = 1,
				},	
				font = {
					type = "select", dialogControl = 'LSM30_Font',
					order = 2,
					name = L["Font"],
					values = AceGUIWidgetLSMlists.font,
				},
				fontSize = {
					order = 3,
					name = L["Font Size"],
					type = "range",
					min = 6, max = 22, step = 1,
				},	
				fontOutline = {
					order = 4,
					name = L["Font Outline"],
					desc = L["Set the font outline."],
					type = "select",
					values = {
						['NONE'] = L['None'],
						['OUTLINE'] = 'OUTLINE',
						
						['MONOCHROMEOUTLINE'] = 'MONOCROMEOUTLINE',
						['THICKOUTLINE'] = 'THICKOUTLINE',
					},
				},	
				timeXOffset = {
					order = 5,
					name = L['Time xOffset'],
					type = 'range',
					min = -60, max = 60, step = 1,
				},		
				timeYOffset = {
					order = 6,
					name = L['Time yOffset'],
					type = 'range',
					min = -60, max = 60, step = 1,
				},	
				countXOffset = {
					order = 7,
					name = L['Count xOffset'],
					type = 'range',
					min = -60, max = 60, step = 1,
				},		
				countYOffset = {
					order = 8,
					name = L['Count yOffset'],
					type = 'range',
					min = -60, max = 60, step = 1,
				},															
			},
		},
		buffs = {
			order = 9,
			type = 'group',
			name = L['Buffs'],
			get = function(info) return E.db.auras.buffs[ info[#info] ] end,
			set = function(info, value) E.db.auras.buffs[ info[#info] ] = value; A.BuffFrame:UpdateLayout(); A.BuffFrame:Update() end,			
			args = auraOptions,
		},	
		debuffs = {
			order = 20,
			type = 'group',
			name = L['Debuffs'],
			get = function(info) return E.db.auras.debuffs[ info[#info] ] end,
			set = function(info, value) E.db.auras.debuffs[ info[#info] ] = value; A.DebuffFrame:UpdateLayout(); A.DebuffFrame:Update()  end,				
			args = auraOptions,
		},
	},
}