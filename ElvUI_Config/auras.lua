local E, L, V, P, G, _ = unpack(ElvUI);
local A = E:GetModule('Auras')

E.Options.args.auras = { -- Ауры
	type = 'group',
	name = L['Auras'],
	childGroups = 'select',
	get = function(info) return E.db.auras[ info[#info] ] end,
	set = function(info, value) E.db.auras[ info[#info] ] = value; end,
	args = {
		intro = { -- Настройка иконок эффектов, находящихся у миникарты.
			order = 1,
			type = 'description',
			name = L['AURAS_DESC'],
		},
		enable = { -- Включить
			order = 2,
			type = 'toggle',
			name = L['Enable'],
			get = function(info) return E.private.auras[ info[#info] ] end,
			set = function(info, value) E.private.auras[ info[#info] ] = value; E:StaticPopup_Show('PRIVATE_RL') end
		},
		general = { -- Общие
			order = 3,
			type = 'group',
			name = L['General'],
			guiInline = true,
			get = function(info) return E.db.auras[ info[#info] ] end,
			set = function(info, value) E.db.auras[ info[#info] ] = value; A:UpdateSettings(); end,
			args = {
				Size = { -- Размер
					order = 1,
					type = 'range',
					name = L['Size'],
					desc = L['Set the size of the individual auras.'],
					min = 20, max = 60, step = 1,
				},
				perRow = { -- Размер ряда
					order = 2,
					type = 'range',
					name = L['Wrap After'],
					desc = L['Begin a new row or column after this many auras.'],
					min = 2, max = 25, step = 1,
				},
				spacing = { -- Отступ аур
					order = 3,
					type = 'range',
					name = L['Auras Spacing'],
					desc = L['The spacing between auras.'],
					min = 0, max = 30, step = 1,
				},
				fadeThreshold = { -- Значение мерцания
					order = 4,
					type = 'range',
					name = L['Fade Threshold'],
					desc = L['Threshold before text changes red, goes into decimal form, and the icon will fade. Set to -1 to disable.'],
					min = -1, max = 30, step = 1,
				},
			},
		},
		font = { -- Шрифт
			order = 4,
			type = 'group',
			name = L['Font'],
			guiInline = true,
			get = function(info) return E.db.auras[ info[#info] ] end,
			set = function(info, value) E.db.auras[ info[#info] ] = value; A:UpdateSettings(); end,
			args = {
				font = { -- Шрифт
					type = 'select', dialogControl = 'LSM30_Font',
					order = 4,
					name = L['Font'],
					values = AceGUIWidgetLSMlists.font,
				},
				fontSize = { -- Размер шрифта
					order = 5,
					name = L['Font Size'],
					type = 'range',
					min = 6, max = 22, step = 1,
				},	
				fontOutline = { -- Граница шрифта
					order = 6,
					name = L['Font Outline'],
					desc = L['Set the font outline.'],
					type = 'select',
					values = {
						['NONE'] = L['None'],
						['OUTLINE'] = 'OUTLINE',
						['MONOCHROME'] = 'MONOCHROME',
						['MONOCHROMEOUTLINE'] = 'MONOCROMEOUTLINE',
						['THICKOUTLINE'] = 'THICKOUTLINE',
					},
				},
			},
		},
	},
}