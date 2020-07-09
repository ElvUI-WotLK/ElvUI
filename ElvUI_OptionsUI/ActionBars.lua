local E, _, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
local AB = E:GetModule("ActionBars")
local group

local _G = _G
local pairs = pairs

local SetCVar = SetCVar
local GameTooltip = _G.GameTooltip

local points = {
	TOPLEFT = L["Top Left"],
	TOPRIGHT = L["Top Right"],
	BOTTOMLEFT = L["Bottom Left"],
	BOTTOMRIGHT = L["Bottom Right"]
}

local textPoints = {
	TOP = L["Top"],
	BOTTOM = L["Bottom"],
	TOPLEFT = L["Top Left"],
	TOPRIGHT = L["Top Right"],
	BOTTOMLEFT = L["Bottom Left"],
	BOTTOMRIGHT = L["Bottom Right"]
}

local ACD = E.Libs.AceConfigDialog

local function BuildABConfig()
	group.general = {
		order = 1,
		type = "group",
		name = L["General Options"],
		childGroups = "tab",
		disabled = function() return not E.ActionBars.Initialized end,
		args = {
			info = {
				order = 1,
				type = "header",
				name = L["General Options"]
			},
			toggleKeybind = {
				order = 2,
				type = "execute",
				name = L["Keybind Mode"],
				func = function() AB:ActivateBindMode() E:ToggleOptionsUI() GameTooltip:Hide() end,
				disabled = function() return not E.private.actionbar.enable end
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
				disabled = function() return not E.private.actionbar.enable end
			},
			hotkeytext = {
				order = 5,
				type = "toggle",
				name = L["Keybind Text"],
				desc = L["Display bind names on action buttons."],
				disabled = function() return not E.private.actionbar.enable end
			},
			useRangeColorText = {
				order = 6,
				type = "toggle",
				name = L["Color Keybind Text"],
				desc = L["Color Keybind Text when Out of Range, instead of the button."]
			},
			rightClickSelfCast = {
				order = 7,
				type = "toggle",
				name = L["RightClick Self-Cast"],
				set = function(info, value)
					E.db.actionbar.rightClickSelfCast = value
					for _, bar in pairs(AB.handledBars) do
						AB:UpdateButtonConfig(bar, bar.bindButtons)
					end
				end
			},
			keyDown = {
				order = 8,
				type = "toggle",
				name = L["Key Down"],
				desc = L["OPTION_TOOLTIP_ACTION_BUTTON_USE_KEY_DOWN"],
				disabled = function() return not E.private.actionbar.enable end
			},
			lockActionBars = {
				order = 9,
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
			desaturateOnCooldown = {
				order = 10,
				type = "toggle",
				name = L["Desaturate Cooldowns"],
				set = function(info, value)
					E.db.actionbar.desaturateOnCooldown = value
					AB:ToggleDesaturation(value)
				end
			},
			transparentBackdrops = {
				order = 11,
				type = "toggle",
				name = L["Transparent Backdrops"],
				set = function(info, value)
					E.db.actionbar.transparentBackdrops = value
					E:StaticPopup_Show("CONFIG_RL")
				end
			},
			transparentButtons = {
				order = 12,
				type = "toggle",
				name = L["Transparent Buttons"],
				set = function(info, value)
					E.db.actionbar.transparentButtons = value
					E:StaticPopup_Show("CONFIG_RL")
				end
			},
			movementModifier = {
				order = 13,
				type = "select",
				name = L["Pick Up Action Key"],
				desc = L["The button you must hold down in order to drag an ability to another action button."],
				disabled = function() return (not E.private.actionbar.enable or not E.db.actionbar.lockActionBars) end,
				values = {
					["NONE"] = L["NONE"],
					["SHIFT"] = L["SHIFT_KEY"],
					["ALT"] = L["ALT_KEY_TEXT"],
					["CTRL"] = L["CTRL_KEY"]
				}
			},
			globalFadeAlpha = {
				order = 14,
				type = "range",
				name = L["Global Fade Transparency"],
				desc = L["Transparency level when not in combat, no target exists, full health, not casting, and no focus target exists."],
				min = 0, max = 1, step = 0.01,
				isPercent = true,
				set = function(info, value) E.db.actionbar[info[#info]] = value AB.fadeParent:SetAlpha(1-value) end
			},
			equippedItem = {
				order = 15,
				type = "toggle",
				name = L["Equipped Item"],
				get = function(info) return E.db.actionbar[info[#info]] end,
				set = function(info, value) E.db.actionbar[info[#info]] = value AB:UpdateButtonSettings() end
			},
			equippedItemColor = {
				order = 16,
				type = "color",
				name = L["Equipped Item Color"],
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
				disabled = function() return not E.db.actionbar.equippedItem end
			},
			colorGroup = {
				order = 17,
				type = "group",
				name = L["COLORS"],
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
				order = 18,
				type = "group",
				name = L["Fonts"],
				guiInline = true,
				disabled = function() return not E.private.actionbar.enable end,
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
						end
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
								values = textPoints
							},
							countTextXOffset = {
								order = 2,
								type = "range",
								name = L["Stack Text X-Offset"],
								min = -10, max = 10, step = 1
							},
							countTextYOffset = {
								order = 3,
								type = "range",
								name = L["Stack Text Y-Offset"],
								min = -10, max = 10, step = 1
							},
							hotkeyTextPosition = {
								order = 4,
								type = "select",
								name = L["Keybind Text Position"],
								values = textPoints
							},
							hotkeyTextXOffset = {
								order = 5,
								type = "range",
								name = L["Keybind Text X-Offset"],
								min = -10, max = 10, step = 1
							},
							hotkeyTextYOffset = {
								order = 6,
								type = "range",
								name = L["Keybind Text Y-Offset"],
								min = -10, max = 10, step = 1
							}
						}
					}
				}
			},
			lbf = {
				order = 19,
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
					}
				}
			}
		}
	}
	if E.myclass == "SHAMAN" then
		group.barTotem = {
			order = 2,
			type = "group",
			name = L["TUTORIAL_TITLE47"],
			guiInline = false,
			disabled = function() return not E.ActionBars.Initialized or not E.myclass == "SHAMAN" end,
			get = function(info) return E.db.actionbar.barTotem[info[#info]] end,
			set = function(info, value) E.db.actionbar.barTotem[info[#info]] = value AB:PositionAndSizeBarTotem() end,
			args = {
				info = {
					order = 1,
					type = "header",
					name = L["TUTORIAL_TITLE47"]
				},
				enabled = {
					order = 2,
					type = "toggle",
					name = L["Enable"],
					set = function(info, value) E.db.actionbar.barTotem[info[#info]] = value E:StaticPopup_Show("PRIVATE_RL") end
				},
				restorePosition = {
					order = 3,
					type = "execute",
					name = L["Restore Bar"],
					desc = L["Restore the actionbars default settings"],
					func = function() E:CopyTable(E.db.actionbar.barTotem, P.actionbar.barTotem) E:ResetMovers(TUTORIAL_TITLE47) AB:PositionAndSizeBarTotem() end,
					disabled = function() return not E.db.actionbar.barTotem.enabled end
				},
				spacer = {
					order = 4,
					type = "description",
					name = " "
				},
				mouseover = {
					order = 5,
					type = "toggle",
					name = L["Mouse Over"],
					desc = L["The frame is not shown unless you mouse over the frame."],
					disabled = function() return not E.db.actionbar.barTotem.enabled end
				},
				flyoutDirection = {
					order = 6,
					type = "select",
					name = L["Flyout Direction"],
					values = {
						["UP"] = L["Up"],
						["DOWN"] = L["Down"]
					},
					disabled = function() return not E.db.actionbar.barTotem.enabled end
				},
				buttonsize = {
					order = 7,
					type = "range",
					name = L["Button Size"],
					desc = L["The size of the action buttons."],
					min = 15, max = 60, step = 1,
					disabled = function() return not E.db.actionbar.barTotem.enabled end
				},
				buttonspacing = {
					order = 8,
					type = "range",
					name = L["Button Spacing"],
					desc = L["The spacing between buttons."],
					min = -3, max = 40, step = 1,
					disabled = function() return not E.db.actionbar.barTotem.enabled end
				},
				flyoutSpacing = {
					order = 9,
					type = "range",
					name = L["Flyout Spacing"],
					desc = L["The spacing between buttons."],
					min = -3, max = 40, step = 1,
					disabled = function() return not E.db.actionbar.barTotem.enabled end
				},
				alpha = {
					order = 10,
					type = "range",
					name = L["Alpha"],
					isPercent = true,
					min = 0, max = 1, step = 0.01,
					disabled = function() return not E.db.actionbar.barTotem.enabled end
				},
				visibility = {
					order = 11,
					type = "input",
					name = L["Visibility State"],
					desc = L["This works like a macro, you can run different situations to get the actionbar to show/hide differently.\n Example: '[combat] show;hide'"],
					width = "full",
					multiline = true,
					set = function(info, value)
						if value and value:match("[\n\r]") then
							value = value:gsub("[\n\r]","")
						end
						E.db.actionbar.barTotem[info[#info]] = value
						AB:PositionAndSizeBarTotem()
					end,
					disabled = function() return not E.db.actionbar.barTotem.enabled end
				}
			}
		}
	end
	group.barPet = {
		order = 3,
		type = "group",
		name = L["Pet Bar"],
		guiInline = false,
		disabled = function() return not E.ActionBars.Initialized end,
		get = function(info) return E.db.actionbar.barPet[info[#info]] end,
		set = function(info, value) E.db.actionbar.barPet[info[#info]] = value AB:PositionAndSizeBarPet() end,
		args = {
			info = {
				order = 1,
				type = "header",
				name = L["Pet Bar"]
			},
			enabled = {
				order = 2,
				type = "toggle",
				name = L["Enable"]
			},
			restorePosition = {
				order = 3,
				type = "execute",
				name = L["Restore Bar"],
				desc = L["Restore the actionbars default settings"],
				func = function() E:CopyTable(E.db.actionbar.barPet, P.actionbar.barPet) E:ResetMovers("Pet Bar") AB:PositionAndSizeBarPet() end,
				disabled = function() return not E.db.actionbar.barPet.enabled end
			},
			spacer = {
				order = 4,
				type = "description",
				name = " "
			},
			backdrop = {
				order = 5,
				type = "toggle",
				name = L["Backdrop"],
				desc = L["Toggles the display of the actionbars backdrop."],
				disabled = function() return not E.db.actionbar.barPet.enabled end
			},
			mouseover = {
				order = 6,
				type = "toggle",
				name = L["Mouse Over"],
				desc = L["The frame is not shown unless you mouse over the frame."],
				disabled = function() return not E.db.actionbar.barPet.enabled end
			},
			inheritGlobalFade = {
				order = 7,
				type = "toggle",
				name = L["Inherit Global Fade"],
				desc = L["Inherit the global fade, mousing over, targetting, setting focus, losing health, entering combat will set the remove transparency. Otherwise it will use the transparency level in the general actionbar settings for global fade alpha."],
				disabled = function() return not E.db.actionbar.barPet.enabled end
			},
			point = {
				order = 8,
				type = "select",
				name = L["Anchor Point"],
				desc = L["The first button anchors itself to this point on the bar."],
				values = points,
				disabled = function() return not E.db.actionbar.barPet.enabled end
			},
			buttons = {
				order = 9,
				type = "range",
				name = L["Buttons"],
				desc = L["The amount of buttons to display."],
				min = 1, max = NUM_PET_ACTION_SLOTS, step = 1,
				disabled = function() return not E.db.actionbar.barPet.enabled end
			},
			buttonsPerRow = {
				order = 10,
				type = "range",
				name = L["Buttons Per Row"],
				desc = L["The amount of buttons to display per row."],
				min = 1, max = NUM_PET_ACTION_SLOTS, step = 1,
				disabled = function() return not E.db.actionbar.barPet.enabled end
			},
			buttonsize = {
				order = 11,
				type = "range",
				name = L["Button Size"],
				desc = L["The size of the action buttons."],
				min = 15, max = 60, step = 1,
				disabled = function() return not E.db.actionbar.barPet.enabled end
			},
			buttonspacing = {
				order = 12,
				type = "range",
				name = L["Button Spacing"],
				desc = L["The spacing between buttons."],
				min = -3, max = 20, step = 1,
				disabled = function() return not E.db.actionbar.barPet.enabled end
			},
			backdropSpacing = {
				order = 13,
				type = "range",
				name = L["Backdrop Spacing"],
				desc = L["The spacing between the backdrop and the buttons."],
				min = 0, max = 10, step = 1,
				disabled = function() return not E.db.actionbar.barPet.enabled end
			},
			heightMult = {
				order = 14,
				type = "range",
				name = L["Height Multiplier"],
				desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
				min = 1, max = 5, step = 1,
				disabled = function() return not E.db.actionbar.barPet.enabled end
			},
			widthMult = {
				order = 15,
				type = "range",
				name = L["Width Multiplier"],
				desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
				min = 1, max = 5, step = 1,
				disabled = function() return not E.db.actionbar.barPet.enabled end
			},
			alpha = {
				order = 16,
				type = "range",
				name = L["Alpha"],
				isPercent = true,
				min = 0, max = 1, step = 0.01,
				disabled = function() return not E.db.actionbar.barPet.enabled end
			},
			visibility = {
				order = 17,
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
		type = "group",
		name = L["Stance Bar"],
		guiInline = false,
		disabled = function() return not E.ActionBars.Initialized end,
		get = function(info) return E.db.actionbar.stanceBar[info[#info]] end,
		set = function(info, value) E.db.actionbar.stanceBar[info[#info]] = value AB:PositionAndSizeBarShapeShift() end,
		args = {
			info = {
				order = 1,
				type = "header",
				name = L["Stance Bar"]
			},
			enabled = {
				order = 2,
				type = "toggle",
				name = L["Enable"]
			},
			restorePosition = {
				order = 3,
				type = "execute",
				name = L["Restore Bar"],
				desc = L["Restore the actionbars default settings"],
				func = function() E:CopyTable(E.db.actionbar.stanceBar, P.actionbar.stanceBar) E:ResetMovers(L["Stance Bar"]) AB:PositionAndSizeBarShapeShift() end,
				disabled = function() return not E.db.actionbar.stanceBar.enabled end
			},
			spacer = {
				order = 4,
				type = "description",
				name = " "
			},
			backdrop = {
				order = 5,
				type = "toggle",
				name = L["Backdrop"],
				desc = L["Toggles the display of the actionbars backdrop."],
				disabled = function() return not E.db.actionbar.stanceBar.enabled end
			},
			mouseover = {
				order = 6,
				type = "toggle",
				name = L["Mouse Over"],
				desc = L["The frame is not shown unless you mouse over the frame."],
				disabled = function() return not E.db.actionbar.stanceBar.enabled end
			},
			inheritGlobalFade = {
				order = 8,
				type = "toggle",
				name = L["Inherit Global Fade"],
				desc = L["Inherit the global fade, mousing over, targetting, setting focus, losing health, entering combat will set the remove transparency. Otherwise it will use the transparency level in the general actionbar settings for global fade alpha."],
				disabled = function() return not E.db.actionbar.stanceBar.enabled end
			},
			point = {
				order = 9,
				type = "select",
				name = L["Anchor Point"],
				desc = L["The first button anchors itself to this point on the bar."],
				values = textPoints,
				disabled = function() return not E.db.actionbar.stanceBar.enabled end
			},
			buttons = {
				order = 10,
				type = "range",
				name = L["Buttons"],
				desc = L["The amount of buttons to display."],
				min = 1, max = NUM_PET_ACTION_SLOTS, step = 1,
				disabled = function() return not E.db.actionbar.stanceBar.enabled end
			},
			buttonsPerRow = {
				order = 11,
				type = "range",
				name = L["Buttons Per Row"],
				desc = L["The amount of buttons to display per row."],
				min = 1, max = NUM_PET_ACTION_SLOTS, step = 1,
				disabled = function() return not E.db.actionbar.stanceBar.enabled end
			},
			buttonsize = {
				order = 12,
				type = "range",
				name = L["Button Size"],
				desc = L["The size of the action buttons."],
				min = 15, max = 60, step = 1,
				disabled = function() return not E.db.actionbar.stanceBar.enabled end
			},
			buttonspacing = {
				order = 13,
				type = "range",
				name = L["Button Spacing"],
				desc = L["The spacing between buttons."],
				min = -1, max = 10, step = 1,
				disabled = function() return not E.db.actionbar.stanceBar.enabled end
			},
			backdropSpacing = {
				order = 14,
				type = "range",
				name = L["Backdrop Spacing"],
				desc = L["The spacing between the backdrop and the buttons."],
				min = 0, max = 10, step = 1,
				disabled = function() return not E.db.actionbar.stanceBar.enabled end
			},
			heightMult = {
				order = 15,
				type = "range",
				name = L["Height Multiplier"],
				desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
				min = 1, max = 5, step = 1,
				disabled = function() return not E.db.actionbar.stanceBar.enabled end
			},
			widthMult = {
				order = 16,
				type = "range",
				name = L["Width Multiplier"],
				desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
				min = 1, max = 5, step = 1,
				disabled = function() return not E.db.actionbar.stanceBar.enabled end
			},
			alpha = {
				order = 17,
				type = "range",
				name = L["Alpha"],
				isPercent = true,
				min = 0, max = 1, step = 0.01,
				disabled = function() return not E.db.actionbar.stanceBar.enabled end
			},
			style = {
				order = 18,
				type = "select",
				name = L["Style"],
				desc = L["This setting will be updated upon changing stances."],
				values = {
					["darkenInactive"] = L["Darken Inactive"],
					["classic"] = L["Classic"]
				},
				disabled = function() return not E.db.actionbar.stanceBar.enabled end
			},
			visibility = {
				order = 19,
				type = "input",
				name = L["Visibility State"],
				desc = L["This works like a macro, you can run different situations to get the actionbar to show/hide differently.\n Example: '[combat] show;hide'"],
				width = "full",
				multiline = true,
				set = function(info, value)
					if value and value:match("[\n\r]") then
						value = value:gsub("[\n\r]", "")
					end
					E.db.actionbar.stanceBar.visibility = value
					AB:UpdateButtonSettings()
				end
			}
		}
	}
	group.microbar = {
		order = 5,
		type = "group",
		name = L["Micro Bar"],
		disabled = function() return not E.ActionBars.Initialized end,
		get = function(info) return E.db.actionbar.microbar[info[#info]] end,
		set = function(info, value) E.db.actionbar.microbar[info[#info]] = value AB:UpdateMicroPositionDimensions() end,
		args = {
			info = {
				order = 1,
				type = "header",
				name = L["Micro Bar"]
			},
			enabled = {
				order = 2,
				type = "toggle",
				name = L["Enable"]
			},
			restoreMicrobar = {
				order = 3,
				type = "execute",
				name = L["Restore Bar"],
				desc = L["Restore the actionbars default settings"],
				func = function() E:CopyTable(E.db.actionbar.microbar, P.actionbar.microbar) E:ResetMovers(L["Micro Bar"]) AB:UpdateMicroPositionDimensions() end,
				disabled = function() return not E.db.actionbar.microbar.enabled end
			},
			spacer = {
				order = 4,
				type = "description",
				name = " "
			},
			mouseover = {
				order = 5,
				type = "toggle",
				name = L["Mouse Over"],
				desc = L["The frame is not shown unless you mouse over the frame."],
				disabled = function() return not E.db.actionbar.microbar.enabled end
			},
			buttonSize = {
				order = 6,
				type = "range",
				name = L["Button Size"],
				desc = L["The size of the action buttons."],
				min = 15, max = 60, step = 1,
				disabled = function() return not E.db.actionbar.microbar.enabled end
			},
			buttonSpacing = {
				order = 7,
				type = "range",
				name = L["Button Spacing"],
				desc = L["The spacing between buttons."],
				min = -1, max = 20, step = 1,
				disabled = function() return not E.db.actionbar.microbar.enabled end
			},
			buttonsPerRow = {
				order = 8,
				type = "range",
				name = L["Buttons Per Row"],
				desc = L["The amount of buttons to display per row."],
				min = 1, max = 10, step = 1,
				disabled = function() return not E.db.actionbar.microbar.enabled end
			},
			alpha = {
				order = 9,
				type = "range",
				name = L["Alpha"],
				isPercent = true,
				desc = L["Change the alpha level of the frame."],
				min = 0, max = 1, step = 0.1,
				disabled = function() return not E.db.actionbar.microbar.enabled end
			},
			visibility = {
				order = 10,
				type = "input",
				name = L["Visibility State"],
				desc = L["This works like a macro, you can run different situations to get the actionbar to show/hide differently.\n Example: '[combat] show;hide'"],
				width = "full",
				multiline = true,
				set = function(info, value)
					if value and value:match("[\n\r]") then
						value = value:gsub("[\n\r]","")
					end
					E.db.actionbar.microbar.visibility = value
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
			type = "group",
			name = name,
			guiInline = false,
			disabled = function() return not E.ActionBars.Initialized end,
			get = function(info) return E.db.actionbar["bar"..i][info[#info]] end,
			set = function(info, value) E.db.actionbar["bar"..i][info[#info]] = value AB:PositionAndSizeBar("bar"..i) end,
			args = {
				info = {
					order = 1,
					type = "header",
					name = name
				},
				enabled = {
					order = 2,
					type = "toggle",
					name = L["Enable"],
					set = function(info, value)
						E.db.actionbar["bar"..i][info[#info]] = value
						AB:PositionAndSizeBar("bar"..i)
					end
				},
				restorePosition = {
					order = 3,
					type = "execute",
					name = L["Restore Bar"],
					desc = L["Restore the actionbars default settings"],
					func = function() E:CopyTable(E.db.actionbar["bar"..i], P.actionbar["bar"..i]) E:ResetMovers("Bar "..i) AB:PositionAndSizeBar("bar"..i) end,
					disabled = function() return not E.db.actionbar["bar"..i].enabled end
				},
				spacer = {
					order = 4,
					type = "description",
					name = " "
				},
				backdrop = {
					order = 5,
					type = "toggle",
					name = L["Backdrop"],
					desc = L["Toggles the display of the actionbars backdrop."],
					disabled = function() return not E.db.actionbar["bar"..i].enabled end
				},
				showGrid = {
					order = 6,
					type = "toggle",
					name = L["Show Empty Buttons"],
					set = function(info, value) E.db.actionbar["bar"..i][info[#info]] = value AB:UpdateButtonSettingsForBar("bar"..i) end,
					disabled = function() return not E.db.actionbar["bar"..i].enabled end
				},
				mouseover = {
					order = 7,
					type = "toggle",
					name = L["Mouse Over"],
					desc = L["The frame is not shown unless you mouse over the frame."],
					disabled = function() return not E.db.actionbar["bar"..i].enabled end
				},
				inheritGlobalFade = {
					order = 8,
					type = "toggle",
					name = L["Inherit Global Fade"],
					desc = L["Inherit the global fade, mousing over, targetting, setting focus, losing health, entering combat will set the remove transparency. Otherwise it will use the transparency level in the general actionbar settings for global fade alpha."],
					disabled = function() return not E.db.actionbar["bar"..i].enabled end
				},
				point = {
					order = 9,
					type = "select",
					name = L["Anchor Point"],
					desc = L["The first button anchors itself to this point on the bar."],
					values = points,
					disabled = function() return not E.db.actionbar["bar"..i].enabled end
				},
				buttons = {
					order = 11,
					type = "range",
					name = L["Buttons"],
					desc = L["The amount of buttons to display."],
					min = 1, max = NUM_ACTIONBAR_BUTTONS, step = 1,
					disabled = function() return not E.db.actionbar["bar"..i].enabled end
				},
				buttonsPerRow = {
					order = 12,
					type = "range",
					name = L["Buttons Per Row"],
					desc = L["The amount of buttons to display per row."],
					min = 1, max = NUM_ACTIONBAR_BUTTONS, step = 1,
					disabled = function() return not E.db.actionbar["bar"..i].enabled end
				},
				buttonsize = {
					order = 13,
					type = "range",
					name = L["Button Size"],
					desc = L["The size of the action buttons."],
					min = 15, max = 60, step = 1,
					disabled = function() return not E.db.actionbar["bar"..i].enabled end
				},
				buttonspacing = {
					order = 14,
					type = "range",
					name = L["Button Spacing"],
					desc = L["The spacing between buttons."],
					min = -3, max = 20, step = 1,
					disabled = function() return not E.db.actionbar["bar"..i].enabled end
				},
				backdropSpacing = {
					order = 15,
					type = "range",
					name = L["Backdrop Spacing"],
					desc = L["The spacing between the backdrop and the buttons."],
					min = 0, max = 10, step = 1,
					disabled = function() return not E.db.actionbar["bar"..i].enabled end
				},
				heightMult = {
					order = 16,
					type = "range",
					name = L["Height Multiplier"],
					desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
					min = 1, max = 5, step = 1,
					disabled = function() return not E.db.actionbar["bar"..i].enabled end
				},
				widthMult = {
					order = 17,
					type = "range",
					name = L["Width Multiplier"],
					desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
					min = 1, max = 5, step = 1,
					disabled = function() return not E.db.actionbar["bar"..i].enabled end
				},
				alpha = {
					order = 18,
					type = "range",
					name = L["Alpha"],
					isPercent = true,
					min = 0, max = 1, step = 0.01,
					disabled = function() return not E.db.actionbar["bar"..i].enabled end
				},
				paging = {
					order = 19,
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
					disabled = function() return not E.db.actionbar["bar"..i].enabled end
				},
				visibility = {
					order = 20,
					type = "input",
					name = L["Visibility State"],
					desc = L["This works like a macro, you can run different situations to get the actionbar to show/hide differently.\n Example: '[combat] show;hide'"],
					width = "full",
					multiline = true,
					set = function(info, value)
						if value and value:match("[\n\r]") then
							value = value:gsub("[\n\r]","")
						end
						E.db.actionbar["bar"..i].visibility = value
						AB:UpdateButtonSettings()
					end,
					disabled = function() return not E.db.actionbar["bar"..i].enabled end
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

local shamanOrder = E.myclass ~= "SHAMAN" and 1 or 0
E.Options.args.actionbar = {
	type = "group",
	name = L["ActionBars"],
	childGroups = "tree",
	get = function(info) return E.db.actionbar[info[#info]] end,
	set = function(info, value) E.db.actionbar[info[#info]] = value AB:UpdateButtonSettings() end,
	args = {
		enable = {
			order = 1,
			type = "toggle",
			name = L["Enable"],
			get = function(info) return E.private.actionbar[info[#info]] end,
			set = function(info, value) E.private.actionbar[info[#info]] = value E:StaticPopup_Show("PRIVATE_RL") end
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
			func = function() ACD:SelectGroup("ElvUI", "actionbar", "general") end,
			disabled = function() return not E.ActionBars.Initialized end
		},
		cooldownTextShortcut = {
			order = 6,
			type = "execute",
			name = L["Cooldowns"],
			func = function() ACD:SelectGroup("ElvUI", "cooldown", "actionbar") end
		},
		petBarShortcut = {
			order = 7,
			type = "execute",
			name = L["Pet Bar"],
			func = function() ACD:SelectGroup("ElvUI", "actionbar", "barPet") end,
			disabled = function() return not E.ActionBars.Initialized end
		},
		stanceBarShortcut = {
			order = 8,
			type = "execute",
			name = L["Stance Bar"],
			func = function() ACD:SelectGroup("ElvUI", "actionbar", "stanceBar") end,
			disabled = function() return not E.ActionBars.Initialized end
		},
		spacer2 = {
			order = 9,
			type = "description",
			name = " "
		},
		totemBarShortcut = {
			order = E.myclass ~= "SHAMAN" and 21 or 10,
			type = "execute",
			name = L["TUTORIAL_TITLE47"],
			func = function() ACD:SelectGroup("ElvUI", "actionbar", "barTotem") end,
			disabled = function() return not E.ActionBars.Initialized end,
			hidden = E.myclass ~= "SHAMAN" and true or false
		},
		microbarShortcut = {
			order = 11 - shamanOrder,
			type = "execute",
			name = L["Micro Bar"],
			func = function() ACD:SelectGroup("ElvUI", "actionbar", "microbar") end,
			disabled = function() return not E.ActionBars.Initialized end
		},
		bar1Shortcut = {
			order = 13 - shamanOrder,
			type = "execute",
			name = L["Bar "]..1,
			func = function() ACD:SelectGroup("ElvUI", "actionbar", "bar1") end,
			disabled = function() return not E.ActionBars.Initialized end
		},
		bar2Shortcut = {
			order = 14 - (shamanOrder + shamanOrder),
			type = "execute",
			name = L["Bar "]..2,
			func = function() ACD:SelectGroup("ElvUI", "actionbar", "bar2") end,
			disabled = function() return not E.ActionBars.Initialized end
		},
		spacer3 = {
			order = 15,
			type = "description",
			name = " "
		},
		bar3Shortcut = {
			order = 16 - (shamanOrder + shamanOrder),
			type = "execute",
			name = L["Bar "]..3,
			func = function() ACD:SelectGroup("ElvUI", "actionbar", "bar3") end,
			disabled = function() return not E.ActionBars.Initialized end
		},
		bar4Shortcut = {
			order = 17 - shamanOrder,
			type = "execute",
			name = L["Bar "]..4,
			func = function() ACD:SelectGroup("ElvUI", "actionbar", "bar4") end,
			disabled = function() return not E.ActionBars.Initialized end
		},
		bar5Shortcut = {
			order = 18 - shamanOrder,
			type = "execute",
			name = L["Bar "]..5,
			func = function() ACD:SelectGroup("ElvUI", "actionbar", "bar5") end,
			disabled = function() return not E.ActionBars.Initialized end
		},
		bar6Shortcut = {
			order = 19 - shamanOrder,
			type = "execute",
			name = L["Bar "]..6,
			func = function() ACD:SelectGroup("ElvUI", "actionbar", "bar6") end,
			disabled = function() return not E.ActionBars.Initialized end
		}
	}
}
group = E.Options.args.actionbar.args
BuildABConfig()