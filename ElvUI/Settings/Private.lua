local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

--Locked Settings, These settings are stored for your character only regardless of profile options.

V.general = {
	loot = true,
	lootRoll = true,
	normTex = "ElvUI Norm",
	glossTex = "ElvUI Norm",
	dmgfont = "PT Sans Narrow",
	namefont = "PT Sans Narrow",
	chatBubbles = "backdrop",
	chatBubbleFont = "PT Sans Narrow",
	chatBubbleFontSize = 14,
	chatBubbleFontOutline = "NONE",
	chatBubbleName = false,
	pixelPerfect = true,
	replaceBlizzFonts = true,
	minimap = {
		enable = true,
		hideCalendar = true,
	},
	classColorMentionsSpeech = true,
	raidUtility = true
}

V.bags = {
	enable = true,
	bagBar = false
}

V.nameplates = {
	enable = true,
}

V.auras = {
	enable = true,
	disableBlizzard = true,

	lbf = {
		enable = false,
		skin = "Blizzard"
	}
}

V.chat = {
	enable = true
}

V.skins = {
	ace3 = {
		enable = true
	},
	checkBoxSkin = true,
	dropdownCheckBoxSkin = false,
	parchmentRemover = {
		enable = false,
	},
	blizzard = {
		enable = true,
		achievement = true,
		alertframes = true,
		arena = true,
		arenaregistrar = true,
		auctionhouse = true,
		bags = true,
		barber = true,
		bgmap = true,
		bgscore = true,
		binding = true,
		BlizzardOptions = true,
		calendar = true,
		character = true,
		debug = true,
		dressingroom = true,
		friends = true,
		gbank = true,
		glyph = true,
		gmchat = true,
		gossip = true,
		greeting = true,
		guildregistrar = true,
		help = true,
		inspect = true,
		lfd = true,
		lfr = true,
		loot = true,
		lootRoll = true,
		macro = true,
		mail = true,
		merchant = true,
		misc = true,
		petition = true,
		pvp = true,
		quest = true,
		raid = true,
		socket = true,
		spellbook = true,
		stable = true,
		tabard = true,
		talent = true,
		taxi = true,
		tooltip = true,
		timemanager = true,
		trade = true,
		tradeskill = true,
		trainer = true,
		tutorial = true,
		watchframe = true,
		worldmap = true,
		mirrorTimers = true,
		WorldStateFrame = true
	}
}

V.tooltip = {
	enable = true,
}

V.unitframe = {
	enable = true,
	disabledBlizzardFrames = {
		player = true,
		target = true,
		focus = true,
		boss = true,
		arena = true,
		party = true,
	}
}

V.actionbar = {
	enable = true,

	lbf = {
		enable = false,
		skin = "Blizzard",
	}
}

V.worldmap = {
	enable = true
}