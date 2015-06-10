local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

E.Options.args.skins = {
	type = "group",
	name = L["Skins"],
	childGroups = "tree",
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["SKINS_DESC"],
		},	
		embedRight = {
			order = 2,
			type = 'select',
			name = L['Embedded Addon'],
			desc = L['Select an addon to embed to the right chat window. This will resize the addon to fit perfectly into the chat window, it will also parent it to the chat window so hiding the chat window will also hide the addon.'],
			values = {
				[''] = ' ',
				['Recount'] = "Recount",
				['Omen'] = "Omen",
				["Skada"] = "Skada"
			},
			get = function(info) return E.db.skins[ info[#info] ] end,
			set = function(info, value) E.db.skins[ info[#info] ] = value; S:SetEmbedRight(value) end,
		},
		blizzard = {
			order = 100,
			type = 'group',
			name = 'Blizzard',
			get = function(info) return E.private.skins.blizzard[ info[#info] ] end,
			set = function(info, value) E.private.skins.blizzard[ info[#info] ] = value; E:StaticPopup_Show("CONFIG_RL") end,	
			guiInline = true,
			args = {
				enable = {
					name = L['Enable'],
					type = 'toggle',
					order = 1,				
				},
				achievement = {
					type = "toggle",
					name = L["Achievement Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				alertframes = {
					type = "toggle",
					name = L['Alert Frames'],
					desc = L["TOGGLESKIN_DESC"],
				},
				arena = {
					type = "toggle",
					name = L["Arena Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				arenaregistrar = {
					type = "toggle",
					name = L["Arena Registrar"],
					desc = L["TOGGLESKIN_DESC"],
				},
				auctionhouse = {
					type = "toggle",
					name = L["Auction Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				bags = {
					type = "toggle",
					name = L["Bags"],
					desc = L["TOGGLESKIN_DESC"],
				},
				barber = {
					type = "toggle",
					name = L["Barbershop Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				bgmap = {
					type = "toggle",
					name = L["BG Map"],
					desc = L["TOGGLESKIN_DESC"],
				},
				bgscore = {
					type = "toggle",
					name = L["BG Score"],
					desc = L["TOGGLESKIN_DESC"],
				},
				binding = {
					type = "toggle",
					name = L["KeyBinding Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				calendar = {
					type = "toggle",
					name = L["Calendar Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				character = {
					type = "toggle",
					name = L["Character Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				debug = {
					type = "toggle",
					name = L["Debug Tools"],
					desc = L["TOGGLESKIN_DESC"],
				},
				dressingroom = {
					type = "toggle",
					name = L["Dressing Room"],
					desc = L["TOGGLESKIN_DESC"],
				},
				friends = {
					type = "toggle",
					name = L["Friends"],
					desc = L["TOGGLESKIN_DESC"],
				},
				gbank = {
					type = "toggle",
					name = L["Guild Bank"],
					desc = L["TOGGLESKIN_DESC"],
				},
				gossip = {
					type = "toggle",
					name = L["Gossip Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				greeting = {
					type = "toggle",
					name = L["Greeting Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				guildregistrar = {
					type = "toggle",
					name = L["Guild Registrar"],
					desc = L["TOGGLESKIN_DESC"],
				},
				help = {
					type = "toggle",
					name = L["Help Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				inspect = {
					type = "toggle",
					name = L["Inspect Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				lfd = {
					type = "toggle",
					name = L["LFD Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				lfr = {
					type = "toggle",
					name = L["LFR Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				macro = {
					type = "toggle",
					name = L["Macro Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				mail = {
					type = "toggle",
					name = L["Mail Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				merchant = {
					type = "toggle",
					name = L["Merchant Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				misc = {
					type = "toggle",
					name = L["Misc Frames"],
					desc = L["TOGGLESKIN_DESC"],
				},
				petition = {
					type = "toggle",
					name = L["Petition Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				pvp = {
					type = "toggle",
					name = L["PvP Frames"],
					desc = L["TOGGLESKIN_DESC"],
				},
				quest = {
					type = "toggle",
					name = L["Quest Frames"],
					desc = L["TOGGLESKIN_DESC"],
				},
				raid = {
					type = "toggle",
					name = L["Raid Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				socket = {
					type = "toggle",
					name = L["Socket Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				spellbook = {
					type = "toggle",
					name = L["Spellbook"],
					desc = L["TOGGLESKIN_DESC"],
				},
				stable = {
					type = "toggle",
					name = L["Stable"],
					desc = L["TOGGLESKIN_DESC"],
				},
				tabard = {
					type = "toggle",
					name = L["Tabard Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				talent = {
					type = "toggle",
					name = L["Talent Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				taxi = {
					type = "toggle",
					name = L["Taxi Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				timemanager = {
					type = "toggle",
					name = L["Time Manager"],
					desc = L["TOGGLESKIN_DESC"],	
				},
				trade = {
					type = "toggle",
					name = L["Trade Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				tradeskill = {
					type = "toggle",
					name = L["TradeSkill Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				trainer = {
					type = "toggle",
					name = L["Trainer Frame"],
					desc = L["TOGGLESKIN_DESC"],
				},
				worldmap = {
					type = "toggle",
					name = L["World Map"],
					desc = L["TOGGLESKIN_DESC"],
				},
			},
		},
		addons = {
			order = 300,
			type = 'group',
			name = 'AddOns',
			get = function(info) return E.private.skins.addons[ info[#info] ] end,
			set = function(info, value) E.private.skins.addons[ info[#info] ] = value; E:StaticPopup_Show("CONFIG_RL") end,	
			guiInline = true,
			args = {
				enable = {
					name = L['Enable'],
					type = 'toggle',
					order = 1,				
				},
				recount = {
					type = "toggle",
					name = L["Recount"],
					desc = L["TOGGLESKIN_DESC"],
					disabled = function() if 'Recount' then return not IsAddOnLoaded('Recount') else return false end end,
				},
				dbm = {
					type = "toggle",
					name = L["DBM-Core"],
					desc = L["TOGGLESKIN_DESC"],
					disabled = function() if 'DBM-Core' then return not IsAddOnLoaded('DBM-Core') else return false end end,
				},
				auctionator = {
					type = "toggle",
					name = L["Auctionator"],
					desc = L["TOGGLESKIN_DESC"],
					disabled = function() if 'Auctionator' then return not IsAddOnLoaded('Auctionator') else return false end end,
				},
				omen = {
					type = "toggle",
					name = L["Omen"],
					desc = L["TOGGLESKIN_DESC"],
					disabled = function() if 'Omen' then return not IsAddOnLoaded('Omen') else return false end end,
				},
				sexycooldown = {
					type = "toggle",
					name = L["SexyCooldown"],
					desc = L["TOGGLESKIN_DESC"],
					disabled = function() if 'SexyCooldown' then return not IsAddOnLoaded('SexyCooldown') else return false end end,
				},
				skada = {
					type = "toggle",
					name = L["Skada"],
					desc = L["TOGGLESKIN_DESC"],
					disabled = function() if 'Skada' then return not IsAddOnLoaded('Skada') else return false end end,
				},
			},
		},
	},
}