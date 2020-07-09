local E, _, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local _, L = unpack(select(2, ...))

E.Options.args.skins = {
	type = "group",
	name = L["Skins"],
	childGroups = "tree",
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["SKINS_DESC"]
		},
		blizzardEnable = {
			order = 2,
			type = "toggle",
			name = L["Blizzard"],
			get = function(info) return E.private.skins.blizzard.enable end,
			set = function(info, value) E.private.skins.blizzard.enable = value E:StaticPopup_Show("PRIVATE_RL") end
		},
		ace3 = {
			order = 3,
			type = "toggle",
			name = "Ace3",
			get = function(info) return E.private.skins.ace3.enable end,
			set = function(info, value) E.private.skins.ace3.enable = value E:StaticPopup_Show("PRIVATE_RL") end
		},
		checkBoxSkin = {
			order = 4,
			type = "toggle",
			name = L["CheckBox Skin"],
			get = function(info) return E.private.skins.checkBoxSkin end,
			set = function(info, value) E.private.skins.checkBoxSkin = value E:StaticPopup_Show("PRIVATE_RL") end,
			disabled = function() return not E.private.skins.ace3.enable and not E.private.skins.blizzard.enable end
		},
		dropdownCheckBoxSkin = {
			order = 5,
			type = "toggle",
			name = L["Dropdown CheckBox Skin"],
			get = function(info) return E.private.skins.dropdownCheckBoxSkin end,
			set = function(info, value) E.private.skins.dropdownCheckBoxSkin = value E:StaticPopup_Show("PRIVATE_RL") end,
			disabled = function() return not E.private.skins.ace3.enable and not E.private.skins.blizzard.enable end
		},
		blizzard = {
			order = 100,
			type = "group",
			name = "Blizzard",
			get = function(info) return E.private.skins.blizzard[info[#info]] end,
			set = function(info, value) E.private.skins.blizzard[info[#info]] = value E:StaticPopup_Show("CONFIG_RL") end,
			disabled = function() return not E.private.skins.blizzard.enable end,
			guiInline = true,
			args = {
				achievement = {
					type = "toggle",
					name = L["ACHIEVEMENTS"],
					desc = L["TOGGLESKIN_DESC"]
				},
				alertframes = {
					type = "toggle",
					name = L["Alert Frames"],
					desc = L["TOGGLESKIN_DESC"]
				},
				arena = {
					type = "toggle",
					name = L["Arena Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				arenaregistrar = {
					type = "toggle",
					name = L["Arena Registrar"],
					desc = L["TOGGLESKIN_DESC"]
				},
				auctionhouse = {
					type = "toggle",
					name = L["AUCTIONS"],
					desc = L["TOGGLESKIN_DESC"]
				},
				bags = {
					type = "toggle",
					name = L["Bags"],
					desc = L["TOGGLESKIN_DESC"],
					disabled = function() return E.private.bags.enable end
				},
				barber = {
					type = "toggle",
					name = L["BARBERSHOP"],
					desc = L["TOGGLESKIN_DESC"]
				},
				bgmap = {
					type = "toggle",
					name = L["BG Map"],
					desc = L["TOGGLESKIN_DESC"]
				},
				bgscore = {
					type = "toggle",
					name = L["BG Score"],
					desc = L["TOGGLESKIN_DESC"]
				},
				binding = {
					type = "toggle",
					name = L["KEY_BINDINGS"],
					desc = L["TOGGLESKIN_DESC"]
				},
				BlizzardOptions = {
					type = "toggle",
					name = L["INTERFACE_OPTIONS"],
					desc = L["TOGGLESKIN_DESC"]
				},
				calendar = {
					type = "toggle",
					name = L["Calendar Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				character = {
					type = "toggle",
					name = L["Character Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				debug = {
					type = "toggle",
					name = L["Debug Tools"],
					desc = L["TOGGLESKIN_DESC"]
				},
				dressingroom = {
					type = "toggle",
					name = L["DRESSUP_FRAME"],
					desc = L["TOGGLESKIN_DESC"]
				},
				friends = {
					type = "toggle",
					name = L["FRIENDS"],
					desc = L["TOGGLESKIN_DESC"]
				},
				gbank = {
					type = "toggle",
					name = L["GUILD_BANK"],
					desc = L["TOGGLESKIN_DESC"]
				},
				gossip = {
					type = "toggle",
					name = L["Gossip Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				gmchat = {
					type = "toggle",
					name = L["GM Chat"],
					desc = L["TOGGLESKIN_DESC"]
				},
				guildregistrar = {
					type = "toggle",
					name = L["Guild Registrar"],
					desc = L["TOGGLESKIN_DESC"]
				},
				help = {
					type = "toggle",
					name = L["Help Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				inspect = {
					type = "toggle",
					name = L["INSPECT"],
					desc = L["TOGGLESKIN_DESC"]
				},
				lfd = {
					type = "toggle",
					name = L["LFD Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				lfr = {
					type = "toggle",
					name = L["LFR Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				loot = {
					type = "toggle",
					name = L["Loot Frames"],
					desc = L["TOGGLESKIN_DESC"],
					disabled = function() return E.private.general.loot end
				},
				lootRoll = {
					type = "toggle",
					name = L["Loot Roll"],
					desc = L["TOGGLESKIN_DESC"],
					disabled = function() return E.private.general.lootRoll end
				},
				macro = {
					type = "toggle",
					name = L["MACROS"],
					desc = L["TOGGLESKIN_DESC"]
				},
				mail = {
					type = "toggle",
					name = L["MAIL_LABEL"],
					desc = L["TOGGLESKIN_DESC"]
				},
				merchant = {
					type = "toggle",
					name = L["MERCHANT"],
					desc = L["TOGGLESKIN_DESC"]
				},
				misc = {
					type = "toggle",
					name = L["Misc Frames"],
					desc = L["TOGGLESKIN_DESC"]
				},
				mirrorTimers = {
					type = "toggle",
					name = L["Mirror Timers"],
					desc = L["TOGGLESKIN_DESC"]
				},
				petition = {
					type = "toggle",
					name = L["Petition Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				pvp = {
					type = "toggle",
					name = L["PvP Frames"],
					desc = L["TOGGLESKIN_DESC"]
				},
				quest = {
					type = "toggle",
					name = L["Quest Frames"],
					desc = L["TOGGLESKIN_DESC"]
				},
				raid = {
					type = "toggle",
					name = L["Raid Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				socket = {
					type = "toggle",
					name = L["Socket Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				spellbook = {
					type = "toggle",
					name = L["SPELLBOOK"],
					desc = L["TOGGLESKIN_DESC"]
				},
				stable = {
					type = "toggle",
					name = L["Stable"],
					desc = L["TOGGLESKIN_DESC"]
				},
				tabard = {
					type = "toggle",
					name = L["Tabard Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				talent = {
					type = "toggle",
					name = L["TALENTS"],
					desc = L["TOGGLESKIN_DESC"]
				},
				taxi = {
					type = "toggle",
					name = L["FLIGHT_MAP"],
					desc = L["TOGGLESKIN_DESC"]
				},
				timemanager = {
					type = "toggle",
					name = L["TIMEMANAGER_TITLE"],
					desc = L["TOGGLESKIN_DESC"]
				},
				tooltip = {
					type = "toggle",
					name = L["Tooltip"],
					desc = L["TOGGLESKIN_DESC"]
				},
				trade = {
					type = "toggle",
					name = L["TRADE"],
					desc = L["TOGGLESKIN_DESC"]
				},
				tradeskill = {
					type = "toggle",
					name = L["TRADESKILLS"],
					desc = L["TOGGLESKIN_DESC"]
				},
				trainer = {
					type = "toggle",
					name = L["Trainer Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				tutorial = {
					type = "toggle",
					name = L["Tutorial Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				watchframe = {
					type = "toggle",
					name = L["Watch Frame"],
					desc = L["TOGGLESKIN_DESC"]
				},
				worldmap = {
					type = "toggle",
					name = L["WORLD_MAP"],
					desc = L["TOGGLESKIN_DESC"]
				},
				WorldStateFrame = {
					type = "toggle",
					name = L["World State Frame"],
					desc = L["TOGGLESKIN_DESC"]
				}
			}
		}
	}
}