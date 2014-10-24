local E, L, V, P, G = unpack(ElvUI); -- Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AB = E:GetModule('ActionBars')
local group

local points = {
	["TOPLEFT"] = "TOPLEFT",
	["TOPRIGHT"] = "TOPRIGHT",
	["BOTTOMLEFT"] = "BOTTOMLEFT",
	["BOTTOMRIGHT"] = "BOTTOMRIGHT",
}

local function BuildABConfig()
	for i=1, 5 do
		local name = L['Bar ']..i
		group['bar'..i] = { -- Панель 1,2,3,4,5
			order = i,
			name = name,
			type = 'group',
			order = 200,
			guiInline = false,
			disabled = function() return not E.private.actionbar.enable end,
			get = function(info) return E.db.actionbar['bar'..i][ info[#info] ] end,
			set = function(info, value) E.db.actionbar['bar'..i][ info[#info] ] = value; AB:PositionAndSizeBar() end,
			args = {
				enabled = { -- Включить
					order = 1,
					type = 'toggle',
					name = L['Enable'],
				},
				restorePosition = { -- Востановить панель
					order = 2,
					type = 'execute',
					name = L['Restore Bar'],
					desc = L['Restore the actionbars default settings'],
					func = function() E:CopyTable(E.db.actionbar['bar'..i], P.actionbar['bar'..i]); E:ResetMovers(L['Bar '..i]); AB:PositionAndSizeBar() end,
				},	
				point = { -- Точка фиксации
					order = 3,
					type = 'select',
					name = L['Anchor Point'],
					desc = L['The first button anchors itself to this point on the bar.'],
					values = points,
				},				
				backdrop = { -- Фон
					order = 4,
					type = "toggle",
					name = L['Backdrop'],
					desc = L['Toggles the display of the actionbars backdrop.'],
				},	
				mouseover = { -- При наведении
					order = 5,
					name = L['Mouse Over'],
					desc = L['The frame is not shown unless you mouse over the frame.'],
					type = "toggle",
				},
				buttons = { -- Кнопок
					order = 6,
					type = 'range',
					name = L['Buttons'],
					desc = L['The amount of buttons to display.'],
					min = 1, max = NUM_ACTIONBAR_BUTTONS, step = 1,				
				},
				buttonsPerRow = { -- Кнопок в ряду
					order = 7,
					type = 'range',
					name = L['Buttons Per Row'],
					desc = L['The amount of buttons to display per row.'],
					min = 1, max = NUM_ACTIONBAR_BUTTONS, step = 1,					
				},
				buttonsize = { -- Размер кнопок
					type = 'range',
					name = L['Button Size'],
					desc = L['The size of the action buttons.'],
					min = 15, max = 60, step = 1,
					order = 8,
				},
				buttonspacing = { -- Отступ кнопок
					type = 'range',
					name = L['Button Spacing'],
					desc = L['The spacing between buttons.'],
					min = 1, max = 10, step = 1,	
					order = 9,
				},	
				heightMult = { -- Множитель высоты
					order = 10,
					type = 'range',
					name = L['Height Multiplier'],
					desc = L['Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop.'],
					min = 1, max = 5, step = 1,					
				},
				widthMult = { -- Множитель ширины
					order = 11,
					type = 'range',
					name = L['Width Multiplier'],
					desc = L['Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop.'],
					min = 1, max = 5, step = 1,					
				},
				alpha = { -- Прозрачность
					order = 12,
					type = 'range',
					name = L['Alpha'],
					isPercent = true,
					min = 0, max = 1, step = 0.01,
				},
				paging = { -- Переключение панелий
					type = 'input',
					order = 13,
					name = L['Action Paging'],
					desc = L["This works like a macro, you can run different situations to get the actionbar to page differently.\n Example: '[combat] 2;'"],
					width = 'full',
					multiline = true,
					get = function(info) return E.db.actionbar['bar'..i]['paging'][E.myclass] end,
					set = function(info, value) 
						if not E.db.actionbar['bar'..i]['paging'][E.myclass] then
							E.db.actionbar['bar'..i]['paging'][E.myclass] = {}
						end
						
						E.db.actionbar['bar'..i]['paging'][E.myclass] = value
						AB:UpdateButtonSettings() 
					end,
				},
				visibility = { -- Статус отображения
					type = 'input',
					order = 14,
					name = L['Visibility State'],
					desc = L["This works like a macro, you can run different situations to get the actionbar to show/hide differently.\n Example: '[combat] show;hide'"],
					width = 'full',
					multiline = true,
					set = function(info, value) 						
						E.db.actionbar['bar'..i]['visibility'] = value; 
						AB:UpdateButtonSettings()
					end,
				},
			},
		}
	end

	group['barPet'] = { -- Панель питомца
		order = i,
		name = L['Pet Bar'],
		type = 'group',
		order = 300,
		guiInline = false,
		disabled = function() return not E.private.actionbar.enable end,
		get = function(info) return E.db.actionbar['barPet'][ info[#info] ] end,
		set = function(info, value) E.db.actionbar['barPet'][ info[#info] ] = value; AB:PositionAndSizeBarPet() end,
		args = {
			enabled = { -- Включить
				order = 1,
				type = 'toggle',
				name = L['Enable'],
			},
			restorePosition = { -- Востановить панель
				order = 2,
				type = 'execute',
				name = L['Restore Bar'],
				desc = L['Restore the actionbars default settings'],
				func = function() E:CopyTable(E.db.actionbar['barPet'], P.actionbar['barPet']); E:ResetMovers(L['Pet Bar']); AB:PositionAndSizeBarPet() end,
			},	
			point = { -- Точка фиксации
				order = 3,
				type = 'select',
				name = L['Anchor Point'],
				desc = L['The first button anchors itself to this point on the bar.'],
				values = points,
			},				
			backdrop = { -- Фон
				order = 4,
				type = "toggle",
				name = L['Backdrop'],
				desc = L['Toggles the display of the actionbars backdrop.'],
			},	
			mouseover = { -- При наведении
				order = 5,
				name = L['Mouse Over'],
				desc = L['The frame is not shown unless you mouse over the frame.'],
				type = "toggle",
			},
			buttons = { -- Кнопок
				order = 6,
				type = 'range',
				name = L['Buttons'],
				desc = L['The amount of buttons to display.'],
				min = 1, max = NUM_PET_ACTION_SLOTS, step = 1,				
			},
			buttonsPerRow = { -- Кнопок в ряду
				order = 7,
				type = 'range',
				name = L['Buttons Per Row'],
				desc = L['The amount of buttons to display per row.'],
				min = 1, max = NUM_PET_ACTION_SLOTS, step = 1,					
			},
			buttonsize = { -- Размер кнопок
				type = 'range',
				name = L['Button Size'],
				desc = L['The size of the action buttons.'],
				min = 15, max = 60, step = 1,
				order = 8,
			},
			buttonspacing = { -- Отступ кнопок
				type = 'range',
				name = L['Button Spacing'],
				desc = L['The spacing between buttons.'],
				min = 1, max = 10, step = 1,	
				order = 9,
			},	
			heightMult = { -- Множитель высоты
				order = 10,
				type = 'range',
				name = L['Height Multiplier'],
				desc = L['Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop.'],
				min = 1, max = 5, step = 1,					
			},
			widthMult = { -- Множитель ширины
				order = 11,
				type = 'range',
				name = L['Width Multiplier'],
				desc = L['Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop.'],
				min = 1, max = 5, step = 1,					
			},
			alpha = { -- Прозрачность
				order = 12,
				type = 'range',
				name = L['Alpha'],
				isPercent = true,
				min = 0, max = 1, step = 0.01,
			},
			visibility = { -- Статус отображения
				type = 'input',
				order = 13,
				name = L['Visibility State'],
				desc = L["This works like a macro, you can run different situations to get the actionbar to show/hide differently.\n Example: '[combat] show;hide'"],
				width = 'full',
				multiline = true,
				set = function(info, value) 						
					E.db.actionbar['barPet']['visibility'] = value; 
					AB:UpdateButtonSettings()
				end,
			},
		},
	}	
	group['stanceBar'] = { -- Панель стоек
		order = i,
		name = L['Stance Bar'],
		type = 'group',
		order = 400,
		guiInline = false,
		disabled = function() return not E.private.actionbar.enable end,
		get = function(info) return E.db.actionbar['barShapeShift'][ info[#info] ] end,
		set = function(info, value) E.db.actionbar['barShapeShift'][ info[#info] ] = value; AB:PositionAndSizeBarShapeShift() end,
		args = {
			enabled = { -- Включить
				order = 1,
				type = 'toggle',
				name = L['Enable'],
			},
			restorePosition = { -- Востановить панель
				order = 2,
				type = 'execute',
				name = L['Restore Bar'],
				desc = L['Restore the actionbars default settings'],
				func = function() E:CopyTable(E.db.actionbar['barShapeShift'], P.actionbar['barShapeShift']); E:ResetMovers(L['Stance Bar']); AB:PositionAndSizeBarShapeShift() end,
			},	
			point = { -- Точка фиксации
				order = 3,
				type = 'select',
				name = L['Anchor Point'],
				desc = L['The first button anchors itself to this point on the bar.'],
				values = points,
			},				
			backdrop = { -- Фон
				order = 4,
				type = "toggle",
				name = L['Backdrop'],
				desc = L['Toggles the display of the actionbars backdrop.'],
			},	
			mouseover = { -- При наведении
				order = 5,
				name = L['Mouse Over'],
				desc = L['The frame is not shown unless you mouse over the frame.'],
				type = "toggle",
			},
			buttons = { -- Кнопок
				order = 6,
				type = 'range',
				name = L['Buttons'],
				desc = L['The amount of buttons to display.'],
				min = 1, max = NUM_PET_ACTION_SLOTS, step = 1,				
			},
			buttonsPerRow = { -- Кнопок в ряду
				order = 7,
				type = 'range',
				name = L['Buttons Per Row'],
				desc = L['The amount of buttons to display per row.'],
				min = 1, max = NUM_PET_ACTION_SLOTS, step = 1,					
			},
			buttonsize = { -- Размер кнопок
				type = 'range',
				name = L['Button Size'],
				desc = L['The size of the action buttons.'],
				min = 15, max = 60, step = 1,
				order = 8,
			},
			buttonspacing = { -- Отступ кнопок
				type = 'range',
				name = L['Button Spacing'],
				desc = L['The spacing between buttons.'],
				min = 1, max = 10, step = 1,	
				order = 9,
			},	
			heightMult = { -- Множитель высоты
				order = 10,
				type = 'range',
				name = L['Height Multiplier'],
				desc = L['Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop.'],
				min = 1, max = 5, step = 1,					
			},
			widthMult = { -- Множитель ширины
				order = 11,
				type = 'range',
				name = L['Width Multiplier'],
				desc = L['Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop.'],
				min = 1, max = 5, step = 1,					
			},
			alpha = { -- Прозрачность
				order = 12,
				type = 'range',
				name = L['Alpha'],
				isPercent = true,
				min = 0, max = 1, step = 0.01,
			},
			style = {
				order = 13,
				type = 'select',
				name = L['Style'],
				desc = L["This setting will be updated upon changing stances."],
				values = {
					['darkenInactive'] = L['Darken Inactive'],
					['classic'] = L['Classic'],
				},
			},
		},
	}
	
	if E.myclass == "SHAMAN" then
		group['barTotem'] = {
			order = i,
			name = L['Totems'],
			type = 'group',
			order = 100,
			guiInline = false,
			disabled = function() return not E.private.actionbar.enable or not E.myclass == "SHAMAN" end,
			get = function(info) return E.db.actionbar['barTotem'][ info[#info] ] end,
			set = function(info, value) E.db.actionbar['barTotem'][ info[#info] ] = value; AB:AdjustTotemSettings() end,
			args = {
				enabled = {
					order = 1,
					type = 'toggle',
					name = L['Enable'],
				},
				restorePosition = {
					order = 2,
					type = 'execute',
					name = L['Restore Bar'],
					desc = L['Restore the actionbars default settings'],
					func = function() E:CopyTable(E.db.actionbar['barTotem'], P.actionbar['barTotem']); E:ResetMovers(L['Totems']); AB:AdjustTotemSettings() end,
				},			
				mouseover = {
					order = 3,
					name = L['Mouse Over'],
					desc = L['The frame is not shown unless you mouse over the frame.'],
					type = "toggle",
				},
			},
		}
	end
end

E.Options.args.actionbar = { -- Панели команд
	type = "group",
	name = L["ActionBars"],
	childGroups = "tree",
	get = function(info) return E.db.actionbar[ info[#info] ] end,
	set = function(info, value) E.db.actionbar[ info[#info] ] = value; AB:UpdateButtonSettings() end,
	args = {
		enable = { -- Включить
			order = 1,
			type = "toggle",
			name = L["Enable"],
			get = function(info) return E.private.actionbar[ info[#info] ] end,
			set = function(info, value) E.private.actionbar[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL") end
		},
		toggleKeybind = { -- Назначить клавиши
			order = 2,
			type = "execute",
			name = L["Keybind Mode"],
			func = function() AB:ActivateBindMode(); E:ToggleConfig(); GameTooltip:Hide(); end,
			disabled = function() return not E.private.actionbar.enable; end,
		},
		generalGroup = { -- Общие
			order = 3,
			type = 'group',
			guiInline = true,
			disabled = function() return not E.private.actionbar.enable end,
			name = L['General'],
			args = {
				macrotext = { -- Название макросов
					order = 1,
					type = "toggle",
					name = L['Macro Text'],
					desc = L['Display macro names on action buttons.'],
				},
				hotkeytext = { -- Текст клавиш
					order = 2,
					type = "toggle",
					name = L['Keybind Text'],
					desc = L['Display bind names on action buttons.'],
				},
			},
		},
		fontGroup = { -- Шрифты
			order = 4,
			type = 'group',
			guiInline = true,
			disabled = function() return not E.private.actionbar.enable end,
			name = L['Fonts'],
			args = {
				font = { -- Шрифт
					type = "select", dialogControl = 'LSM30_Font',
					order = 1,
					name = L["Font"],
					values = AceGUIWidgetLSMlists.font,
				},
				fontSize = { -- Размер шрифта
					order = 2,
					name = L["Font Size"],
					type = "range",
					min = 6, max = 22, step = 1,
				},	
				fontOutline = { -- Граница шрифта
					order = 3,
					name = L["Font Outline"],
					desc = L["Set the font outline."],
					type = "select",
					values = {
						['NONE'] = L['None'],
						['OUTLINE'] = 'OUTLINE',
						['MONOCHROME'] = (not E.isMacClient) and 'MONOCHROME' or nil,
						['MONOCHROMEOUTLINE'] = 'MONOCROMEOUTLINE',
						['THICKOUTLINE'] = 'THICKOUTLINE',
					},
				},	
			},
		},
		microbar = { -- Микроменю
			type = "group",
			name = L['Micro Bar'],
			get = function(info) return E.db.actionbar.microbar[ info[#info] ] end,
			set = function(info, value) E.db.actionbar.microbar[ info[#info] ] = value; AB:UpdateMicroPositionDimensions() end,
			args = {
				enabled = { -- Включить
					order = 1,
					type = "toggle",
					name = L["Enable"],
				},
				restoreMicrobar = { -- Востановить умолчания
					type = 'execute',
					name = L["Restore Defaults"],
					order = 2,
					func = function() E:CopyTable(E.db.actionbar['microbar'], P.actionbar['microbar']); E:ResetMovers(L['Micro Bar']); AB:UpdateMicroPositionDimensions(); end,
				},
				general = {
					order = 3,
					type = "group",
					name = L["General"],
					guiInline = true,
					disabled = function() return not E.db.actionbar.microbar.enabled end,
					args = {
						Height = { -- Высота
							order = 1,
							type = 'range',
							name = L['Height'],
							min = 58, max = 174, step = 1,					
						},
						Width = { -- Ширина
							order = 2,
							type = 'range',
							name = L['Width'],
							min = 28, max = 84, step = 1,					
						},
						Scale = { -- Масштаб
							order = 3,
							type = 'range',
							name = L['Scale'],
							min = 0.3, max = 5, step = 0.1,					
						},
						buttonsPerRow = { -- Кнопок в ряду
							order = 4,
							type = 'range',
							name = L['Buttons Per Row'],
							desc = L['The amount of buttons to display per row.'],
							min = 1, max = 10, step = 1,					
						},
						xOffset = { -- Отступ оп X
							order = 5,
							type = 'range',
							name = L['xOffset'],
							min = 0, max = 60, step = 1,					
						},
						yOffset = { -- Отступ оп Y
							order = 6,
							type = 'range',
							name = L['yOffset'],
							min = 0, max = 60, step = 1,					
						},
						alpha = { -- Прозрачность
							order = 7,
							type = 'range',
							name = L['Alpha'],
							desc = L['Change the alpha level of the frame.'],
							min = 0, max = 1, step = 0.1,					
						},
						mouseover = { -- При наведении
							order = 8,
							name = L['Mouse Over'],
							desc = L['The frame is not shown unless you mouse over the frame.'],
							type = "toggle",
						},
						animSpeed = { -- Скорость анимации при наведении
							order = 9,
							type = 'range',
							name = L['Speed of the animation when you hover'],
							disabled = function() return not E.db.actionbar.microbar.mouseover end,
							min = 0.1, max = 5, step = 0.05,	
						},
						Shake = { -- Анимация змея :D
							order = 10,
							type = "toggle",
							name = L['Animation snake :D'],
							disabled = function() return not E.db.actionbar.microbar.mouseover end,
						},
					},
				},
			},
		},
	},
}
group = E.Options.args.actionbar.args
BuildABConfig()