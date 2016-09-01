local E, L, V, P, G, _ = unpack(ElvUI);

E.Options.args.maps = {
	type = "group",
	name = L["Maps"],
	childGroups = "tab",
	args = {
		worldMap = {
			order = 1,
			type = "group",
			name = WORLD_MAP,
			args = {
				header = {
					order = 0,
					type = "header",
					name = WORLD_MAP
				},
				smallerWorldMap = {
					order = 1,
					type = "toggle",
					name = L["Smaller World Map"],
					desc = L["Make the world map smaller."],
					descStyle = "inline",
					get = function(info) return E.global.general.smallerWorldMap; end,
					set = function(info, value) E.global.general.smallerWorldMap = value; E:StaticPopup_Show("GLOBAL_RL"); end,
					width = "double"
				},
				mapAlphaWhenMoving = {
					order = 2,
					type = "range",
					name = L["Map Opacity When Moving"],
					isPercent = true,
					min = 0, max = 1, step = 0.01,
					get = function(info) return E.global.general.mapAlphaWhenMoving; end,
					set = function(info, value) E.global.general.mapAlphaWhenMoving = value; end
				},
				spacer  = {
					order = 3,
					type = "description",
					name = "\n"
				},
				worldMapCoordinatesEnable = {
					order = 4,
					type = "toggle",
					name = L["World Map Coordinates"],
					desc = L["Puts coordinates on the world map."],
					descStyle = "inline",
					get = function(info) return E.global.general.WorldMapCoordinates.enable; end,
					set = function(info, value) E.global.general.WorldMapCoordinates.enable = value; E:StaticPopup_Show("GLOBAL_RL"); end,
					width = "full"
				},
				position = {
					order = 5,
					type = "select",
					name = L["Position"],
					get = function(info) return E.global.general.WorldMapCoordinates.position; end,
					set = function(info, value) E.global.general.WorldMapCoordinates.position = value; E:GetModule("WorldMap"):PositionCoords(); end,
					disabled = function() return not E.global.general.WorldMapCoordinates.enable; end,
					values = {
						["TOP"] = "TOP",
						["TOPLEFT"] = "TOPLEFT",
						["TOPRIGHT"] = "TOPRIGHT",
						["BOTTOM"] = "BOTTOM",
						["BOTTOMLEFT"] = "BOTTOMLEFT",
						["BOTTOMRIGHT"] = "BOTTOMRIGHT"
					}
				},
				xOffset = {
					order = 6,
					type = "range",
					name = L["X-Offset"],
					get = function(info) return E.global.general.WorldMapCoordinates.xOffset; end,
					set = function(info, value) E.global.general.WorldMapCoordinates.xOffset = value; E:GetModule("WorldMap"):PositionCoords(); end,
					disabled = function() return not E.global.general.WorldMapCoordinates.enable; end,
					min = -200, max = 200, step = 1
				},
				yOffset = {
					order = 7,
					type = "range",
					name = L["Y-Offset"],
					get = function(info) return E.global.general.WorldMapCoordinates.yOffset end,
					set = function(info, value) E.global.general.WorldMapCoordinates.yOffset = value; E:GetModule("WorldMap"):PositionCoords(); end,
					disabled = function() return not E.global.general.WorldMapCoordinates.enable end,
					min = -200, max = 200, step = 1
				}
			}
		},
		minimap = {
			order = 2,
			type = "group",
			name = MINIMAP_LABEL,
			get = function(info) return E.db.general.minimap[ info[#info] ]; end,
			args = {
				header = {
					order = 0,
					type = "header",
					name = MINIMAP_LABEL
				},
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					desc = L["Enable/Disable the minimap. |cffFF0000Warning: This will prevent you from seeing the minimap datatexts.|r"],
					get = function(info) return E.private.general.minimap[ info[#info] ]; end,
					set = function(info, value) E.private.general.minimap[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end,
					width = "full"
				},
				size = {
					order = 2,
					type = "range",
					name = L["Size"],
					desc = L["Adjust the size of the minimap."],
					min = 120, max = 250, step = 1,
					get = function(info) return E.db.general.minimap[ info[#info] ]; end,
					set = function(info, value) E.db.general.minimap[ info[#info] ] = value; E:GetModule("Minimap"):UpdateSettings(); end,
					disabled = function() return not E.private.general.minimap.enable end
				},
				locationText = {
					order = 3,
					type = "select",
					name = L["Location Text"],
					desc = L["Change settings for the display of the location text that is on the minimap."],
					get = function(info) return E.db.general.minimap.locationText; end,
					set = function(info, value) E.db.general.minimap.locationText = value; E:GetModule("Minimap"):UpdateSettings(); E:GetModule("Minimap"):Update_ZoneText(); end,
					values = {
						["MOUSEOVER"] = L["Minimap Mouseover"],
						["SHOW"] = L["Always Display"],
						["HIDE"] = L["Hide"]
					},
					disabled = function() return not E.private.general.minimap.enable; end
				},
				spacer = {
					order = 4,
					type = "description",
					name = "\n"
				}
			}
		}
	}
};