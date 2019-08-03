local E, _, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
local AB = E:GetModule("ActionBars")
local group

local pairs = pairs
local SetCVar = SetCVar
local GameTooltip = GameTooltip

local points = {
	["TOPLEFT"] = "TOPLEFT",
	["TOPRIGHT"] = "TOPRIGHT",
	["BOTTOMLEFT"] = "BOTTOMLEFT",
	["BOTTOMRIGHT"] = "BOTTOMRIGHT"
}

local ACD = E.Libs.AceConfigDialog

local function BuildABConfig()
	group.general = {
		order = 1,
		type = "group",
		name = L["General Options"],
		childGroups = "tab",
		disabled = function() return not E.ActionBars.Initialized; end,
		args = {
			toggleKeybind = {
				order = 1,
				type = "execute",
				name = L["Keybind Mode"],
				func = function() AB:ActivateBindMode(); E:ToggleOptionsUI(); GameTooltip:Hide() end,
				disabled = function() return not E.private.actionbar.enable end,
			},
			spacer = {
				order = 2,
				type = "description",
				name = ""
			},
			macrotext = {
				order = 3,
				type = "toggle",
				name = L["Macro Text"],
				desc = L["Display macro names on action buttons."],
				disabled = function() return not E.private.actionbar.enable end,
			},
			hotkeytext = {
				order = 4,
				type = "toggle",
				name = L["Keybind Text"],
				desc = L["Display bind names on action buttons."],
				disabled = function() return not E.private.actionbar.enable end,
			},
			useRangeColorText = {
				order = 5,
				type = "toggle",
				name = L["Color Keybind Text"],
				desc = L["Color Keybind Text when Out of Range, instead of the button."]
			},
			keyDown = {
				order = 6,
				type = "toggle",
				name = L["Key Down"],
				desc = L["Action button keybinds will respond on key down, rather than on key up"],
				disabled = function() return not E.private.actionbar.enable end,
			},
			lockActionBars = {
				order = 7,
				type = "toggle",
				name = L["LOCK_ACTIONBAR_TEXT"],
				desc = L["If you unlock actionbars then trying to move a spell might instantly cast it if you cast spells on key press instead of key release."],
				set = function(info, value)
					E.db.actionbar[info[#info]] = value
					AB:UpdateButtonSettings()

					--Make it work for PetBar too
					SetCVar("lockActionBars", (value == true and 1 or 0))
					LOCK_ACTIONBAR = (value == true and "1" or "0")
				end
			},
			rightClickSelfCast = {
				order = 8,
				type = "toggle",
				name = L["RightClick Self-Cast"],
				set = function(info, value)
					E.db.actionbar.rightClickSelfCast = value;
					for _, bar in pairs(AB.handledBars) do
						AB:UpdateButtonConfig(bar, bar.bindButtons)
					end
				end,
			},
			desaturateOnCooldown = {
				order = 9,
				type = "toggle",
				name = L["Desaturate On Cooldown"],
				set = function(info, value)
					E.db.actionbar.desaturateOnCooldown = value;
					AB:ToggleDesaturation(value)
				end
			},
			movementModifier = {
				order = 10,
				type = "select",
				name = L["Pick Up Action Key"],
				desc = L["The button you must hold down in order to drag an ability to another action button."],
				disabled = function() return (not E.private.actionbar.enable or not E.db.actionbar.lockActionBars) end,
				values = {
					["NONE"] = L["NONE"],
					["SHIFT"] = L["SHIFT_KEY_TEXT"],
					["ALT"] = L["ALT_KEY_TEXT"],
					["CTRL"] = L["CTRL_KEY_TEXT"],
				}
			},
			globalFadeAlpha = {
				order = 11,
				type = "range",
				name = L["Global Fade Transparency"],
				desc = L["Transparency level when not in combat, no target exists, full health, not casting, and no focus target exists."],
				min = 0, max = 1, step = 0.01,
				isPercent = true,
				set = function(info, value) E.db.actionbar[info[#info]] = value AB.fadeParent:SetAlpha(1-value) end
			},
			colorGroup = {
				order = 20,
				type = "group",
				name = COLORS,
				guiInline = true,
				get = function(info)
					local t = E.db.actionbar[info[#info]]
					local d = P.actionbar[info[#info]]
					return t.r, t.g, t.b, t.a, d.r, d.g, d.b
				end,
				set = function(info, r, g, b)
					local t = E.db.actionbar[info[#info]]
					t.r, t.g, t.b = r, g, b
					AB:UpdateButtonSettings()
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
				order = 25,
				type = "group",
				guiInline = true,
				disabled = function() return not E.private.actionbar.enable end,
				name = L["Fonts"],
				args = {
					font = {
						order = 1,
						type = "select", dialogControl = "LSM30_Font",
						name = L["Font"],
						values = AceGUIWidgetLSMlists.font
					},
					fontSize = {
						order = 2,
						type = "range",
						name = L["FONT_SIZE"],
						min = 4, max = 32, step = 1
					},
					fontOutline = {
						order = 3,
						type = "select",
						name = L["Font Outline"],
						desc = L["Set the font outline."],
						values = C.Values.FontFlags
					},
					fontColor = {
						order = 4,
						type = "color",
						name = L["COLOR"],
						width = "full",
						get = function(info)
							local t = E.db.actionbar[info[#info]]
							local d = P.actionbar[info[#info]]
							return t.r, t.g, t.b, t.a, d.r, d.g, d.b
						end,
						set = function(info, r, g, b)
							local t = E.db.actionbar[info[#info]]
							t.r, t.g, t.b = r, g, b
							AB:UpdateButtonSettings()
						end,
					},
					textPosition = {
						order = 5,
						type = "group",
						name = L["Text Position"],
						guiInline = true,
						args = {
							countTextPosition = {
								order = 1,
								type = "select",
								name = L["Stack Text Position"],
								values = {
									["BOTTOMRIGHT"] = "BOTTOMRIGHT",
									["BOTTOMLEFT"] = "BOTTOMLEFT",
									["TOPRIGHT"] = "TOPRIGHT",
									["TOPLEFT"] = "TOPLEFT",
									["BOTTOM"] = "BOTTOM",
									["TOP"] = "TOP",
								},
							},
							countTextXOffset = {
								order = 2,
								type = "range",
								name = L["Stack Text X-Offset"],
								min = -10, max = 10, step = 1,
							},
							countTextYOffset = {
								order = 3,
								type = "range",
								name = L["Stack Text Y-Offset"],
								min = -10, max = 10, step = 1,
							},
							hotkeyTextPosition  = {
								order = 4,
								type = "select",
								name = L["Keybind Text Position"],
								values = {
									["BOTTOMRIGHT"] = "BOTTOMRIGHT",
									["BOTTOMLEFT"] = "BOTTOMLEFT",
									["TOPRIGHT"] = "TOPRIGHT",
									["TOPLEFT"] = "TOPLEFT",
									["BOTTOM"] = "BOTTOM",
									["TOP"] = "TOP",
								},
							},
							hotkeyTextXOffset = {
								order = 5,
								type = "range",
								name = L["Keybind Text X-Offset"],
								min = -10, max = 10, step = 1,
							},
							hotkeyTextYOffset = {
								order = 6,
								type = "range",
								name = L["Keybind Text Y-Offset"],
								min = -10, max = 10, step = 1,
							},
						},
					},
				},
			},
			lbf = {
				order = 30,
				type = "group",
				guiInline = true,
				name = L["LBF Support"],
				get = function(info) return E.private.actionbar.lbf[info[#info]] end,
				set = function(info, value) E.private.actionbar.lbf[info[#info]] = value E:StaticPopup_Show("PRIVATE_RL") end,
				disabled = function() return not E.private.actionbar.enable end,
				args = {
					enable = {
						order = 1,
						type = "toggle",
						name = L["Enable"],
						desc = L["Allow LBF to handle the skinning of this element."]
					},
				},
			},
		},
	}

	if E.myclass == "SHAMAN" then
		group["barTotem"] = {
			order = 2,
			type = "group",
			name = TUTORIAL_TITLE47,
			guiInline = false,
			disabled = function() return not E.ActionBars or not E.myclass == "SHAMAN" end,
			get = function(info) return E.db.actionbar.barTotem[info[#info]] end,
			set = function(info, value) E.db.actionbar.barTotem[info[#info]] = value; AB:PositionAndSizeBarTotem() end,
			args = {
				enabled = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					set = function(info, value) E.db.actionbar.barTotem[info[#info]] = value E:StaticPopup_Show("PRIVATE_RL") end
				},
				restorePosition = {
					order = 2,
					type = "execute",
					name = L["Restore Bar"],
					desc = L["Restore the actionbars default settings"],
					buttonElvUI = true,
					func = function() E:CopyTable(E.db.actionbar.barTotem, P.actionbar.barTotem); E:ResetMovers(TUTORIAL_TITLE47); AB:PositionAndSizeBarTotem() end,
					disabled = function() return not E.db.actionbar.barTotem.enabled end
				},
				mouseover = {
					order = 3,
					type = "toggle",
					name = L["Mouse Over"],
					desc = L["The frame is not shown unless you mouse over the frame."],
					disabled = function() return not E.db.actionbar.barTotem.enabled end
				},
				flyoutDirection = {
					order = 4,
					type = "select",
					name = L["Flyout Direction"],
					values = {
						["UP"] = L["Up"],
						["DOWN"] = L["Down"]
					},
					disabled = function() return not E.db.actionbar.barTotem.enabled end
				},
				buttonsize = {
					order = 5,
					type = "range",
					name = L["Button Size"],
					desc = L["The size of the action buttons."],
					min = 15, max = 60, step = 1,
					disabled = function() return not E.db.actionbar.barTotem.enabled end
				},
				buttonspacing = {
					order = 6,
					type = "range",
					name = L["Button Spacing"],
					desc = L["The spacing between buttons."],
					min = -3, max = 40, step = 1,
					disabled = function() return not E.db.actionbar.barTotem.enabled end
				},
				flyoutSpacing = {
					order = 7,
					type = "range",
					name = L["Flyout Spacing"],
					desc = L["The spacing between buttons."],
					min = -3, max = 40, step = 1,
					disabled = function() return not E.db.actionbar.barTotem.enabled end
				},
				alpha = {
					order = 8,
					type = "range",
					name = L["Alpha"],
					isPercent = true,
					min = 0, max = 1, step = 0.01,
					disabled = function() return not E.db.actionbar.barTotem.enabled end
				},
				visibility = {
					order = 9,
					type = "input",
					name = L["Visibility State"],
					desc = L["This works like a macro, you can run different situations to get the actionbar to show/hide differently.\n Example: '[combat] show;hide'"],
					width = "full",
					multiline = true,
					set = function(info, value)
						if value and value:match("[\n\r]") then
							value = value:gsub("[\n\r]","")
						end
						E.db.actionbar["barTotem"][info[#info]] = value
						AB:PositionAndSizeBarTotem()
					end,
					disabled = function() return not E.db.actionbar.barTotem.enabled end
				}
			}
		}
	end
	group.barPet = {
		order = 3,
		name = L["Pet Bar"],
		type = "group",
		guiInline = false,
		disabled = function() return not E.ActionBars.Initialized; end,
		get = function(info) return E.db.actionbar.barPet[info[#info]] end,
		set = function(info, value) E.db.actionbar.barPet[info[#info]] = value; AB:PositionAndSizeBarPet() end,
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["Enable"]
			},
			restorePosition = {
				order = 2,
				type = "execute",
				name = L["Restore Bar"],
				desc = L["Restore the actionbars default settings"],
				func = function() E:CopyTable(E.db.actionbar.barPet, P.actionbar.barPet); E:ResetMovers("Pet Bar"); AB:PositionAndSizeBarPet() end,
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
				order = 6,
				type = "toggle",
				name = L["Mouse Over"],
				desc = L["The frame is not shown unless you mouse over the frame."],
			},
			inheritGlobalFade = {
				order = 7,
				type = "toggle",
				name = L["Inherit Global Fade"],
				desc = L["Inherit the global fade, mousing over, targetting, setting focus, losing health, entering combat will set the remove transparency. Otherwise it will use the transparency level in the general actionbar settings for global fade alpha."],
			},
			buttons = {
				order = 8,
				type = "range",
				name = L["Buttons"],
				desc = L["The amount of buttons to display."],
				min = 1, max = NUM_PET_ACTION_SLOTS, step = 1,
			},
			buttonsPerRow = {
				order = 9,
				type = "range",
				name = L["Buttons Per Row"],
				desc = L["The amount of buttons to display per row."],
				min = 1, max = NUM_PET_ACTION_SLOTS, step = 1,
			},
			buttonsize = {
				order = 10,
				type = "range",
				name = L["Button Size"],
				desc = L["The size of the action buttons."],
				min = 15, max = 60, step = 1,
				disabled = function() return not E.private.actionbar.enable end,
			},
			buttonspacing = {
				order = 11,
				type = "range",
				name = L["Button Spacing"],
				desc = L["The spacing between buttons."],
				min = -3, max = 20, step = 1,
				disabled = function() return not E.private.actionbar.enable end,
			},
			backdropSpacing = {
				order = 12,
				type = "range",
				name = L["Backdrop Spacing"],
				desc = L["The spacing between the backdrop and the buttons."],
				min = 0, max = 10, step = 1,
				disabled = function() return not E.private.actionbar.enable end,
			},
			heightMult = {
				order = 13,
				type = "range",
				name = L["Height Multiplier"],
				desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
				min = 1, max = 5, step = 1,
			},
			widthMult = {
				order = 14,
				type = "range",
				name = L["Width Multiplier"],
				desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
				min = 1, max = 5, step = 1,
			},
			alpha = {
				order = 15,
				type = "range",
				isPercent = true,
				name = L["Alpha"],
				min = 0, max = 1, step = 0.01,
			},
			visibility = {
				order = 16,
				type = "input",
				name = L["Visibility State"],
				desc = L["This works like a macro, you can run different situations to get the actionbar to show/hide differently.\n Example: '[combat] show;hide'"],
				width = "full",
				multiline = true,
				set = function(info, value)
					if value and value:match("[\n\r]") then
						value = value:gsub("[\n\r]", "")
					end
					E.db.actionbar.barPet.visibility = value
					AB:UpdateButtonSettings()
				end,
				disabled = function() return not E.db.actionbar.barPet.enabled end
			}
		}
	}

	group.stanceBar = {
		order = 4,
		name = L["Stance Bar"],
		type = "group",
		guiInline = false,
		disabled = function() return not E.ActionBars.Initialized; end,
		get = function(info) return E.db.actionbar.stanceBar[info[#info]] end,
		set = function(info, value) E.db.actionbar.stanceBar[info[#info]] = value; AB:PositionAndSizeBarShapeShift() end,
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["Enable"]
			},
			restorePosition = {
				order = 2,
				type = "execute",
				name = L["Restore Bar"],
				desc = L["Restore the actionbars default settings"],
				func = function() E:CopyTable(E.db.actionbar.stanceBar, P.actionbar.stanceBar); E:ResetMovers("Stance Bar"); AB:PositionAndSizeBarShapeShift() end,
			},
			point = {
				order = 3,
				type = "select",
				name = L["Anchor Point"],
				desc = L["The first button anchors itself to this point on the bar."],
				values = {
					["TOPLEFT"] = "TOPLEFT",
					["TOPRIGHT"] = "TOPRIGHT",
					["BOTTOMLEFT"] = "BOTTOMLEFT",
					["BOTTOMRIGHT"] = "BOTTOMRIGHT",
					["BOTTOM"] = "BOTTOM",
					["TOP"] = "TOP",
				},
			},
			backdrop = {
				order = 4,
				type = "toggle",
				name = L["Backdrop"],
				desc = L["Toggles the display of the actionbars backdrop."],
			},
			mouseover = {
				order = 5,
				type = "toggle",
				name = L["Mouse Over"],
				desc = L["The frame is not shown unless you mouse over the frame."],

			},
			inheritGlobalFade = {
				order = 6,
				type = "toggle",
				name = L["Inherit Global Fade"],
				desc = L["Inherit the global fade, mousing over, targetting, setting focus, losing health, entering combat will set the remove transparency. Otherwise it will use the transparency level in the general actionbar settings for global fade alpha."],
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
				order = 9,
				type = "range",
				name = L["Button Size"],
				desc = L["The size of the action buttons."],
				min = 15, max = 60, step = 1,
				disabled = function() return not E.private.actionbar.enable end,
			},
			buttonspacing = {
				order = 10,
				type = "range",
				name = L["Button Spacing"],
				desc = L["The spacing between buttons."],
				min = -3, max = 20, step = 1,
				disabled = function() return not E.private.actionbar.enable end,
			},
			backdropSpacing = {
				order = 11,
				type = "range",
				name = L["Backdrop Spacing"],
				desc = L["The spacing between the backdrop and the buttons."],
				min = 0, max = 10, step = 1,
				disabled = function() return not E.private.actionbar.enable end,
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
				isPercent = true,
				name = L["Alpha"],
				min = 0, max = 1, step = 0.01,
			},
			style = {
				order = 15,
				type = "select",
				name = L["Style"],
				desc = L["This setting will be updated upon changing stances."],
				values = {
					["darkenInactive"] = L["Darken Inactive"],
					["classic"] = L["Classic"]
				},
			},
			visibility = {
				order = 16,
				type = "input",
				name = L["Visibility State"],
				desc = L["This works like a macro, you can run different situations to get the actionbar to show/hide differently.\n Example: '[combat] show;hide'"],
				width = "full",
				multiline = true,
				set = function(info, value)
					if value and value:match("[\n\r]") then
						value = value:gsub("[\n\r]", "")
					end
					E.db.actionbar.stanceBar.visibility = value;
					AB:UpdateButtonSettings()
				end,
			}
		}
	}

	group.microbar = {
		order = 5,
		type = "group",
		name = L["Micro Bar"],
		disabled = function() return not E.ActionBars.Initialized; end,
		get = function(info) return E.db.actionbar.microbar[info[#info]] end,
		set = function(info, value) E.db.actionbar.microbar[info[#info]] = value; AB:UpdateMicroPositionDimensions() end,
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["Enable"],
			},
			mouseover = {
				order = 2,
				type = "toggle",
				name = L["Mouse Over"],
				desc = L["The frame is not shown unless you mouse over the frame."],
			},
			alpha = {
				order = 3,
				type = "range",
				name = L["Alpha"],
				isPercent = true,
				desc = L["Change the alpha level of the frame."],
				min = 0, max = 1, step = 0.1,
			},
			spacer = {
				order = 4,
				type = "description",
				name = " ",
			},
			buttonSize = {
				order = 5,
				type = "range",
				name = L["Button Size"],
				desc = L["The size of the action buttons."],
				min = 15, max = 60, step = 1,
			},
			buttonSpacing = {
				order = 6,
				type = "range",
				name = L["Button Spacing"],
				desc = L["The spacing between buttons."],
				min = -1, max = 20, step = 1,
			},
			buttonsPerRow = {
				order = 7,
				type = "range",
				name = L["Buttons Per Row"],
				desc = L["The amount of buttons to display per row."],
				min = 1, max = 10, step = 1,
			},
			spacer2 = {
				order = 8,
				type = "description",
				name = " ",
			},
			visibility = {
				order = 9,
				type = "input",
				name = L["Visibility State"],
				desc = L["This works like a macro, you can run different situations to get the actionbar to show/hide differently.\n Example: '[combat] show;hide'"],
				width = "full",
				multiline = true,
				set = function(info, value)
					if value and value:match("[\n\r]") then
						value = value:gsub("[\n\r]","")
					end
					E.db.actionbar.microbar.visibility = value;
					AB:UpdateMicroPositionDimensions()
				end,
				disabled = function() return not E.db.actionbar.microbar.enabled end
			}
		}
	}

	for i = 1, 6 do
		local name = L["Bar "]..i
		group["bar"..i] = {
			order = 7 + i,
			name = name,
			type = "group",
			guiInline = false,
			disabled = function() return not E.ActionBars.Initialized; end,
			get = function(info) return E.db.actionbar["bar"..i][info[#info]] end,
			set = function(info, value) E.db.actionbar["bar"..i][info[#info]] = value; AB:PositionAndSizeBar("bar"..i) end,
			args = {
				enabled = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					set = function(info, value)
						E.db.actionbar["bar"..i][info[#info]] = value
						AB:PositionAndSizeBar("bar"..i)
					end
				},
				restorePosition = {
					order = 2,
					type = "execute",
					name = L["Restore Bar"],
					desc = L["Restore the actionbars default settings"],
					func = function() E:CopyTable(E.db.actionbar["bar"..i], P.actionbar["bar"..i]); E:ResetMovers("Bar "..i); AB:PositionAndSizeBar("bar"..i) end,
				},
				spacer = {
					order = 3,
					type = "description",
					name = " "
				},
				backdrop = {
					order = 4,
					type = "toggle",
					name = L["Backdrop"],
					desc = L["Toggles the display of the actionbars backdrop."],
				},
				showGrid = {
					order = 5,
					type = "toggle",
					name = L["Show Empty Buttons"],
					set = function(info, value) E.db.actionbar["bar"..i][info[#info]] = value; AB:UpdateButtonSettingsForBar("bar"..i) end,
				},
				mouseover = {
					order = 6,
					type = "toggle",
					name = L["Mouse Over"],
					desc = L["The frame is not shown unless you mouse over the frame."],
				},
				inheritGlobalFade = {
					order = 7,
					type = "toggle",
					name = L["Inherit Global Fade"],
					desc = L["Inherit the global fade, mousing over, targetting, setting focus, losing health, entering combat will set the remove transparency. Otherwise it will use the transparency level in the general actionbar settings for global fade alpha."],
				},
				point = {
					order = 8,
					type = "select",
					name = L["Anchor Point"],
					desc = L["The first button anchors itself to this point on the bar."],
					values = points,
				},
				buttons = {
					order = 9,
					type = "range",
					name = L["Buttons"],
					desc = L["The amount of buttons to display."],
					min = 1, max = NUM_ACTIONBAR_BUTTONS, step = 1,
				},
				buttonsPerRow = {
					order = 10,
					type = "range",
					name = L["Buttons Per Row"],
					desc = L["The amount of buttons to display per row."],
					min = 1, max = NUM_ACTIONBAR_BUTTONS, step = 1,
				},
				buttonsize = {
					order = 11,
					type = "range",
					name = L["Button Size"],
					desc = L["The size of the action buttons."],
					min = 15, max = 60, step = 1,
				},
				buttonspacing = {
					order = 12,
					type = "range",
					name = L["Button Spacing"],
					desc = L["The spacing between buttons."],
					min = -3, max = 20, step = 1,
					disabled = function() return not E.db.actionbar["bar"..i].enabled end
				},
				backdropSpacing = {
					order = 13,
					type = "range",
					name = L["Backdrop Spacing"],
					desc = L["The spacing between the backdrop and the buttons."],
					min = 0, max = 10, step = 1,
				},
				heightMult = {
					order = 14,
					type = "range",
					name = L["Height Multiplier"],
					desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
					min = 1, max = 5, step = 1,
				},
				widthMult = {
					order = 15,
					type = "range",
					name = L["Width Multiplier"],
					desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
					min = 1, max = 5, step = 1,
				},
				alpha = {
					order = 16,
					type = "range",
					name = L["Alpha"],
					isPercent = true,
					min = 0, max = 1, step = 0.01,
				},
				paging = {
					order = 17,
					type = "input",
					name = L["Action Paging"],
					desc = L["This works like a macro, you can run different situations to get the actionbar to page differently.\n Example: '[combat] 2;'"],
					width = "full",
					multiline = true,
					get = function(info) return E.db.actionbar["bar"..i].paging[E.myclass] end,
					set = function(info, value)
						if value and value:match("[\n\r]") then
							value = value:gsub("[\n\r]","")
						end

						if not E.db.actionbar["bar"..i].paging[E.myclass] then
							E.db.actionbar["bar"..i].paging[E.myclass] = {}
						end

						E.db.actionbar["bar"..i].paging[E.myclass] = value
						AB:UpdateButtonSettings()
					end,
				},
				visibility = {
					order = 18,
					type = "input",
					name = L["Visibility State"],
					desc = L["This works like a macro, you can run different situations to get the actionbar to show/hide differently.\n Example: '[combat] show;hide'"],
					width = "full",
					multiline = true,
					set = function(info, value)
						if value and value:match("[\n\r]") then
							value = value:gsub("[\n\r]","")
						end
						E.db.actionbar["bar"..i]["visibility"] = value
						AB:UpdateButtonSettings()
					end,
				}
			}
		}

		if i == 6 then
			group["bar"..i].args.enabled.set = function(info, value)
				E.db.actionbar["bar"..i].enabled = value
				AB:PositionAndSizeBar("bar6")

				--Update Bar 1 paging when Bar 6 is enabled/disabled
				AB:UpdateBar1Paging()
				AB:PositionAndSizeBar("bar1")
			end
		end
	end
end

E.Options.args.actionbar = {
	type = "group",
	name = L["ActionBars"],
	childGroups = "tree",
	get = function(info) return E.db.actionbar[info[#info]] end,
	set = function(info, value) E.db.actionbar[info[#info]] = value; AB:UpdateButtonSettings() end,
	args = {
		enable = {
			order = 1,
			type = "toggle",
			name = L["Enable"],
			get = function(info) return E.private.actionbar[info[#info]] end,
			set = function(info, value) E.private.actionbar[info[#info]] = value; E:StaticPopup_Show("PRIVATE_RL") end
		},
		intro = {
			order = 2,
			type = "description",
			name = L["ACTIONBARS_DESC"]
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
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "actionbar", "general") end,
			disabled = function() return not E.ActionBars.Initialized; end,
		},
		cooldownTextShortcut = {
			order = 6,
			type = "execute",
			name = L["Cooldowns"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "cooldown", "actionbar") end,
			disabled = function() return not E.ActionBars.Initialized; end,
		},
		petBarShortcut = {
			order = 6,
			type = "execute",
			name = L["Pet Bar"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "actionbar", "barPet") end,
			disabled = function() return not E.ActionBars.Initialized; end,
		},
		spacer2 = {
			order = 7,
			type = "description",
			name = " "
		},
		stanceBarShortcut = {
			order = 8,
			type = "execute",
			name = L["Stance Bar"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "actionbar", "stanceBar") end,
			disabled = function() return not E.ActionBars.Initialized; end,
		},
		microbarShortcut = {
			order = 9,
			type = "execute",
			name = L["Micro Bar"],
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "actionbar", "microbar") end,
			disabled = function() return not E.ActionBars.Initialized; end,
		},
		totemBarShortcut = {
			order = 10,
			type = "execute",
			name = TUTORIAL_TITLE47,
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "actionbar", "barTotem") end,
			disabled = function() return E.ActionBars.Initialized or E.myclass ~= "SHAMAN" end
		},
		spacer3 = {
			order = 11,
			type = "description",
			name = " ",
		},
		bar1Shortcut = {
			order = 12,
			type = "execute",
			name = L["Bar "]..1,
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "actionbar", "bar1") end,
			disabled = function() return not E.ActionBars.Initialized; end,
		},
		bar2Shortcut = {
			order = 13,
			type = "execute",
			name = L["Bar "]..2,
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "actionbar", "bar2") end,
			disabled = function() return not E.ActionBars.Initialized; end,
		},
		bar3Shortcut = {
			order = 14,
			type = "execute",
			name = L["Bar "]..3,
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "actionbar", "bar3") end,
			disabled = function() return not E.ActionBars.Initialized; end,
		},
		spacer4 = {
			order = 15,
			type = "description",
			name = " ",
		},
		bar4Shortcut = {
			order = 16,
			type = "execute",
			name = L["Bar "]..4,
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "actionbar", "bar4") end,
			disabled = function() return not E.ActionBars.Initialized; end,
		},
		bar5Shortcut = {
			order = 17,
			type = "execute",
			name = L["Bar "]..5,
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "actionbar", "bar5") end,
			disabled = function() return not E.ActionBars.Initialized; end,
		},
		bar6Shortcut = {
			order = 18,
			type = "execute",
			name = L["Bar "]..6,
			buttonElvUI = true,
			func = function() ACD:SelectGroup("ElvUI", "actionbar", "bar6") end,
			disabled = function() return not E.ActionBars.Initialized; end,
		}
	}
}
group = E.Options.args.actionbar.args
BuildABConfig()