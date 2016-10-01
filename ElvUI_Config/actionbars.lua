local E, L, V, P, G = unpack(ElvUI);
local AB = E:GetModule("ActionBars");
local group;

local points = {
	["TOPLEFT"] = "TOPLEFT",
	["TOPRIGHT"] = "TOPRIGHT",
	["BOTTOMLEFT"] = "BOTTOMLEFT",
	["BOTTOMRIGHT"] = "BOTTOMRIGHT",
}

local function BuildABConfig()
	for i = 1, 6 do
		local name = L["Bar "] .. i;
		group["bar" .. i] = {
			order = 200,
			name = name,
			type = "group",
			guiInline = false,
			disabled = function() return not E.private.actionbar.enable; end,
			get = function(info) return E.db.actionbar["bar" .. i][ info[#info] ]; end,
			set = function(info, value) E.db.actionbar["bar" .. i][ info[#info] ] = value; AB:PositionAndSizeBar("bar" .. i); end,
			args = {
				enabled = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					set = function(info, value)
						E.db.actionbar["bar" .. i][ info[#info] ] = value;
						AB:PositionAndSizeBar("bar" .. i);
					end
				},
				restorePosition = {
					order = 2,
					type = "execute",
					name = L["Restore Bar"],
					desc = L["Restore the actionbars default settings"],
					func = function() E:CopyTable(E.db.actionbar["bar" .. i], P.actionbar["bar" .. i]); E:ResetMovers(L["Bar " .. i]); AB:PositionAndSizeBar("bar" .. i); end
				},
				point = {
					order = 3,
					type = "select",
					name = L["Anchor Point"],
					desc = L["The first button anchors itself to this point on the bar."],
					values = points,
				},
				backdrop = {
					order = 4,
					type = "toggle",
					name = L["Backdrop"],
					desc = L["Toggles the display of the actionbars backdrop."],
				},
				showGrid = {
					type = "toggle",
					name = L["Show Empty Buttons"],
					order = 5,
					set = function(info, value) E.db.actionbar["bar" .. i][ info[#info] ] = value; AB:UpdateButtonSettingsForBar("bar"..i); end
				},
				mouseover = {
					order = 6,
					type = "toggle",
					name = L["Mouse Over"],
					desc = L["The frame is not shown unless you mouse over the frame."]
				},
				inheritGlobalFade = {
 					order = 7,
					type = "toggle",
					name = L["Inherit Global Fade"],
					desc = L["Inherit the global fade, mousing over, targetting, setting focus, losing health, entering combat will set the remove transparency. Otherwise it will use the transparency level in the general actionbar settings for global fade alpha."]
				},
				buttons = {
					order = 8,
					type = "range",
					name = L["Buttons"],
					desc = L["The amount of buttons to display."],
					min = 1, max = NUM_ACTIONBAR_BUTTONS, step = 1
				},
				buttonsPerRow = {
					order = 9,
					type = "range",
					name = L["Buttons Per Row"],
					desc = L["The amount of buttons to display per row."],
					min = 1, max = NUM_ACTIONBAR_BUTTONS, step = 1
				},
				buttonsize = {
					order = 10,
					type = "range",
					name = L["Button Size"],
					desc = L["The size of the action buttons."],
					min = 15, max = 60, step = 1,
					disabled = function() return not E.private.actionbar.enable; end
				},
				buttonspacing = {
					order = 11,
					type = "range",
					name = L["Button Spacing"],
					desc = L["The spacing between buttons."],
					min = -1, max = 10, step = 1,
					disabled = function() return not E.private.actionbar.enable end
				},
				backdropSpacing = {
					order = 12,
					type = "range",
					name = L["Backdrop Spacing"],
					desc = L["The spacing between the backdrop and the buttons."],
					min = 0, max = 10, step = 1,
					disabled = function() return not E.private.actionbar.enable; end
				},
				heightMult = {
					order = 13,
					type = "range",
					name = L["Height Multiplier"],
					desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
					min = 1, max = 5, step = 1
				},
				widthMult = {
					order = 14,
					type = "range",
					name = L["Width Multiplier"],
					desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
					min = 1, max = 5, step = 1
				},
				alpha = {
					order = 14,
					type = "range",
					name = L["Alpha"],
					isPercent = true,
					min = 0, max = 1, step = 0.01
				},
				paging = {
					order = 15,
					type = "input",
					name = L["Action Paging"],
					desc = L["This works like a macro, you can run different situations to get the actionbar to page differently.\n Example: '[combat] 2;'"],
					width = "full",
					multiline = true,
					get = function(info) return E.db.actionbar["bar" .. i]["paging"][E.myclass]; end,
					set = function(info, value)
						if(not E.db.actionbar["bar" .. i]["paging"][E.myclass]) then
							E.db.actionbar["bar" .. i]["paging"][E.myclass] = {};
						end

						E.db.actionbar["bar" .. i]["paging"][E.myclass] = value;
						AB:UpdateButtonSettings();
					end
				},
				visibility = {
					type = "input",
					order = 16,
					name = L["Visibility State"],
					desc = L["This works like a macro, you can run different situations to get the actionbar to show/hide differently.\n Example: '[combat] show;hide'"],
					width = "full",
					multiline = true,
					set = function(info, value)
						E.db.actionbar["bar" ..i]["visibility"] = value;
						AB:UpdateButtonSettings();
					end
				}
			}
		};

		if(i == 6) then
			group["bar" .. i].args.enabled.set = function(info, value)
				E.db.actionbar['bar'..i].enabled = value;
				AB:PositionAndSizeBar("bar6");

				AB:UpdateBar1Paging();
				AB:PositionAndSizeBar("bar1");
			end
		end
	end

	group["barPet"] = {
		order = 300,
		name = L["Pet Bar"],
		type = "group",
		guiInline = false,
		disabled = function() return not E.private.actionbar.enable end,
		get = function(info) return E.db.actionbar["barPet"][ info[#info] ] end,
		set = function(info, value) E.db.actionbar["barPet"][ info[#info] ] = value; AB:PositionAndSizeBarPet() end,
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["Enable"],
			},
			restorePosition = {
				order = 2,
				type = "execute",
				name = L["Restore Bar"],
				desc = L["Restore the actionbars default settings"],
				func = function() E:CopyTable(E.db.actionbar["barPet"], P.actionbar["barPet"]); E:ResetMovers(L["Pet Bar"]); AB:PositionAndSizeBarPet() end,
			},
			point = {
				order = 3,
				type = "select",
				name = L["Anchor Point"],
				desc = L["The first button anchors itself to this point on the bar."],
				values = points,
			},
			backdrop = {
				order = 4,
				type = "toggle",
				name = L["Backdrop"],
				desc = L["Toggles the display of the actionbars backdrop."],
			},
			mouseover = {
				order = 5,
				name = L["Mouse Over"],
				desc = L["The frame is not shown unless you mouse over the frame."],
				type = "toggle",
			},
			inheritGlobalFade = {
 				order = 6,
				type = "toggle",
				name = L["Inherit Global Fade"],
				desc = L["Inherit the global fade, mousing over, targetting, setting focus, losing health, entering combat will set the remove transparency. Otherwise it will use the transparency level in the general actionbar settings for global fade alpha."]
			},
			buttons = {
				order = 7,
				type = "range",
				name = L["Buttons"],
				desc = L["The amount of buttons to display."],
				min = 1, max = NUM_PET_ACTION_SLOTS, step = 1,
			},
			buttonsPerRow = {
				order = 8,
				type = "range",
				name = L["Buttons Per Row"],
				desc = L["The amount of buttons to display per row."],
				min = 1, max = NUM_PET_ACTION_SLOTS, step = 1,
			},
			buttonsize = {
				type = "range",
				name = L["Button Size"],
				desc = L["The size of the action buttons."],
				min = 15, max = 60, step = 1,
				order = 9,
			},
			buttonspacing = {
				type = "range",
				name = L["Button Spacing"],
				desc = L["The spacing between buttons."],
				min = -1, max = 10, step = 1,
				order = 10,
			},
			backdropSpacing = {
				order = 11,
				type = "range",
				name = L["Backdrop Spacing"],
				desc = L["The spacing between the backdrop and the buttons."],
				min = 0, max = 10, step = 1,
			},
			heightMult = {
				order = 12,
				type = "range",
				name = L["Height Multiplier"],
				desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
				min = 1, max = 5, step = 1,
			},
			widthMult = {
				order = 13,
				type = "range",
				name = L["Width Multiplier"],
				desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
				min = 1, max = 5, step = 1,
			},
			alpha = {
				order = 14,
				type = "range",
				name = L["Alpha"],
				isPercent = true,
				min = 0, max = 1, step = 0.01,
			},
			visibility = {
				type = "input",
				order = 15,
				name = L["Visibility State"],
				desc = L["This works like a macro, you can run different situations to get the actionbar to show/hide differently.\n Example: '[combat] show;hide'"],
				width = "full",
				multiline = true,
				set = function(info, value)
					E.db.actionbar["barPet"]["visibility"] = value;
					AB:UpdateButtonSettings()
				end,
			},
		},
	}
	group["stanceBar"] = {
		order = 400,
		name = L["Stance Bar"],
		type = "group",
		guiInline = false,
		disabled = function() return not E.private.actionbar.enable end,
		get = function(info) return E.db.actionbar["barShapeShift"][ info[#info] ] end,
		set = function(info, value) E.db.actionbar["barShapeShift"][ info[#info] ] = value; AB:PositionAndSizeBarShapeShift() end,
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["Enable"],
			},
			restorePosition = {
				order = 2,
				type = "execute",
				name = L["Restore Bar"],
				desc = L["Restore the actionbars default settings"],
				func = function() E:CopyTable(E.db.actionbar["barShapeShift"], P.actionbar["barShapeShift"]); E:ResetMovers(L["Stance Bar"]); AB:PositionAndSizeBarShapeShift() end,
			},
			point = {
				order = 3,
				type = "select",
				name = L["Anchor Point"],
				desc = L["The first button anchors itself to this point on the bar."],
				values = points,
			},
			backdrop = {
				order = 4,
				type = "toggle",
				name = L["Backdrop"],
				desc = L["Toggles the display of the actionbars backdrop."],
			},
			mouseover = {
				order = 5,
				name = L["Mouse Over"],
				desc = L["The frame is not shown unless you mouse over the frame."],
				type = "toggle",
			},
			inheritGlobalFade = {
 				order = 6,
				type = "toggle",
				name = L["Inherit Global Fade"],
				desc = L["Inherit the global fade, mousing over, targetting, setting focus, losing health, entering combat will set the remove transparency. Otherwise it will use the transparency level in the general actionbar settings for global fade alpha."]
			},
			buttons = {
				order = 7,
				type = "range",
				name = L["Buttons"],
				desc = L["The amount of buttons to display."],
				min = 1, max = NUM_PET_ACTION_SLOTS, step = 1,
			},
			buttonsPerRow = {
				order = 8,
				type = "range",
				name = L["Buttons Per Row"],
				desc = L["The amount of buttons to display per row."],
				min = 1, max = NUM_PET_ACTION_SLOTS, step = 1,
			},
			buttonsize = {
				type = "range",
				name = L["Button Size"],
				desc = L["The size of the action buttons."],
				min = 15, max = 60, step = 1,
				order = 9,
			},
			buttonspacing = {
				type = "range",
				name = L["Button Spacing"],
				desc = L["The spacing between buttons."],
				min = -1, max = 10, step = 1,
				order = 10,
			},
			backdropSpacing = {
				order = 11,
				type = "range",
				name = L["Backdrop Spacing"],
				desc = L["The spacing between the backdrop and the buttons."],
				min = 0, max = 10, step = 1,
			},
			heightMult = {
				order = 12,
				type = "range",
				name = L["Height Multiplier"],
				desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
				min = 1, max = 5, step = 1,
			},
			widthMult = {
				order = 13,
				type = "range",
				name = L["Width Multiplier"],
				desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
				min = 1, max = 5, step = 1,
			},
			alpha = {
				order = 14,
				type = "range",
				name = L["Alpha"],
				isPercent = true,
				min = 0, max = 1, step = 0.01,
			},
			style = {
				order = 15,
				type = "select",
				name = L["Style"],
				desc = L["This setting will be updated upon changing stances."],
				values = {
					["darkenInactive"] = L["Darken Inactive"],
					["classic"] = L["Classic"],
				},
			},
		},
	}

	if E.myclass == "SHAMAN" then
		group["barTotem"] = {
			order = 100,
			name = L["Totems"],
			type = "group",
			guiInline = false,
			disabled = function() return not E.private.actionbar.enable or not E.myclass == "SHAMAN" end,
			get = function(info) return E.db.actionbar["barTotem"][ info[#info] ] end,
			set = function(info, value) E.db.actionbar["barTotem"][ info[#info] ] = value; AB:AdjustTotemSettings(); AB:PositionAndSizeBarTotem(); end,
			args = {
				enabled = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
				},
				restorePosition = {
					order = 2,
					type = "execute",
					name = L["Restore Bar"],
					desc = L["Restore the actionbars default settings"],
					func = function() E:CopyTable(E.db.actionbar["barTotem"], P.actionbar["barTotem"]); E:ResetMovers(L["Totems"]); AB:AdjustTotemSettings() end,
				},
				mouseover = {
					order = 3,
					name = L["Mouse Over"],
					desc = L["The frame is not shown unless you mouse over the frame."],
					type = "toggle",
				},
				buttonsize = {
					type = "range",
					name = L["Button Size"],
					desc = L["The size of the action buttons."],
					min = 15, max = 60, step = 1,
					order = 4,
				},
				buttonspacing = {
					type = "range",
					name = L["Button Spacing"],
					desc = L["The spacing between buttons."],
					min = -1, max = 10, step = 1,
					order = 5,
				},
				inheritGlobalFade = {
					order = 6,
					type = "toggle",
					name = L["Inherit Global Fade"],
					desc = L["Inherit the global fade, mousing over, targetting, setting focus, losing health, entering combat will set the remove transparency. Otherwise it will use the transparency level in the general actionbar settings for global fade alpha."]
				},
				alpha = {
					order = 7,
					type = "range",
					name = L["Alpha"],
					isPercent = true,
					min = 0, max = 1, step = 0.01,
				},
			},
		}
	end
end

E.Options.args.actionbar = {
	type = "group",
	name = L["ActionBars"],
	childGroups = "tree",
	get = function(info) return E.db.actionbar[ info[#info] ] end,
	set = function(info, value) E.db.actionbar[ info[#info] ] = value; AB:UpdateButtonSettings() end,
	args = {
		enable = {
			order = 1,
			type = "toggle",
			name = L["Enable"],
			get = function(info) return E.private.actionbar[ info[#info] ] end,
			set = function(info, value) E.private.actionbar[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL") end
		},
		toggleKeybind = {
			order = 2,
			type = "execute",
			name = L["Keybind Mode"],
			func = function() AB:ActivateBindMode(); E:ToggleConfig(); GameTooltip:Hide(); end,
			disabled = function() return not E.private.actionbar.enable; end,
		},
		spacer = {
			order = 3,
			type = "description",
			name = ""
		},
		macrotext = {
			order = 4,
			type = "toggle",
			name = L["Macro Text"],
			desc = L["Display macro names on action buttons."],
			disabled = function() return not E.private.actionbar.enable; end
		},
		hotkeytext = {
			order = 5,
			type = "toggle",
			name = L["Keybind Text"],
			desc = L["Display bind names on action buttons."],
			disabled = function() return not E.private.actionbar.enable; end
		},
		keyDown = {
			order = 6,
			type = "toggle",
			name = L["Key Down"],
			desc = L["Action button keybinds will respond on key down, rather than on key up"],
			disabled = function() return not E.private.actionbar.enable; end
		},
		movementModifier = {
			order = 7,
			type = "select",
			name = L["Pick Up Action Key"],
			desc = L["The button you must hold down in order to drag an ability to another action button."],
			disabled = function() return not E.private.actionbar.enable; end,
			values = {
				["NONE"] = NONE,
				["SHIFT"] = SHIFT_KEY,
				["ALT"] = ALT_KEY,
				["CTRL"] = CTRL_KEY
			}
		},
		globalFadeAlpha = {
 			order = 8,
			type = "range",
			name = L["Global Fade Transparency"],
			desc = L["Transparency level when not in combat, no target exists, full health, not casting, and no focus target exists."],
			min = 0, max = 1, step = 0.01,
			isPercent = true,
			set = function(info, value) E.db.actionbar[ info[#info] ] = value; AB.fadeParent:SetAlpha(1-value); end,
		},
		colorGroup = {
			order = 9,
			type = "group",
			name = L["Colors"],
			guiInline = true,
			get = function(info)
				local t = E.db.actionbar[ info[#info] ]
				local d = P.actionbar[ info[#info] ]
				return t.r, t.g, t.b, t.a, d.r, d.g, d.b
			end,
			set = function(info, r, g, b)
				E.db.actionbar[ info[#info] ] = {}
				local t = E.db.actionbar[ info[#info] ]
				t.r, t.g, t.b = r, g, b
				tullaRange:Reset();
			end,
			args = {
				noRangeColor = {
					order = 1,
					type = "color",
					name = L["Out of Range"],
					desc = L["Color of the actionbutton when out of range."]
				},
				noPowerColor = {
					order = 2,
					type = "color",
					name = L["Out of Power"],
					desc = L["Color of the actionbutton when out of power (Mana, Rage)."]
				},
				usableColor = {
					order = 3,
					type = "color",
					name = L["Usable"],
					desc = L["Color of the actionbutton when usable."]
				},
				notUsableColor = {
					order = 4,
					type = "color",
					name = L["Not Usable"],
					desc = L["Color of the actionbutton when not usable."]
				}
			}
		},
		fontGroup = {
			order = 7,
			type = "group",
			guiInline = true,
			disabled = function() return not E.private.actionbar.enable end,
			name = L["Fonts"],
			args = {
				font = {
					type = "select", dialogControl = "LSM30_Font",
					order = 1,
					name = L["Font"],
					values = AceGUIWidgetLSMlists.font,
				},
				fontSize = {
					order = 2,
					name = L["Font Size"],
					type = "range",
					min = 6, max = 22, step = 1,
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
						["THICKOUTLINE"] = "THICKOUTLINE",
					},
				},
				fontColor = {
					order = 7,
					type = "color",
					name = COLOR,
					get = function(info)
						local t = E.db.actionbar[ info[#info] ];
						local d = P.actionbar[info[#info]];
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b;
					end,
					set = function(info, r, g, b)
						E.db.actionbar[ info[#info] ] = {};
						local t = E.db.actionbar[ info[#info] ];
						t.r, t.g, t.b = r, g, b;
						AB:UpdateButtonSettings();
					end
				}
			}
		},
		microbar = {
			type = "group",
			name = L["Micro Bar"],
			get = function(info) return E.db.actionbar.microbar[ info[#info] ] end,
			set = function(info, value) E.db.actionbar.microbar[ info[#info] ] = value; AB:UpdateMicroPositionDimensions() end,
			args = {
				enabled = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
				},
				restoreMicrobar = {
					type = "execute",
					name = L["Restore Defaults"],
					order = 2,
					func = function() E:CopyTable(E.db.actionbar["microbar"], P.actionbar["microbar"]); E:ResetMovers(L["Micro Bar"]); AB:UpdateMicroPositionDimensions(); end,
				},
				general = {
					order = 3,
					type = "group",
					name = L["General"],
					guiInline = true,
					disabled = function() return not E.db.actionbar.microbar.enabled end,
					args = {
						buttonsPerRow = {
							order = 1,
							type = "range",
							name = L["Buttons Per Row"],
							desc = L["The amount of buttons to display per row."],
							min = 1, max = 10, step = 1,
						},
						xOffset = {
							order = 2,
							type = "range",
							name = L["xOffset"],
							min = 0, max = 60, step = 1,
						},
						yOffset = {
							order = 3,
							type = "range",
							name = L["yOffset"],
							min = 0, max = 60, step = 1,
						},
						alpha = {
							order = 4,
							type = "range",
							name = L["Alpha"],
							desc = L["Change the alpha level of the frame."],
							min = 0, max = 1, step = 0.1,
						},
						mouseover = {
							order = 5,
							name = L["Mouse Over"],
							desc = L["The frame is not shown unless you mouse over the frame."],
							type = "toggle"
						}
					},
				},
			},
		},
	},
}
group = E.Options.args.actionbar.args
BuildABConfig()