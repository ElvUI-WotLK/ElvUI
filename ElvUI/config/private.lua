local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

--Locked Settings, These settings are stored for your character only regardless of profile options.

V["general"] = {
	["loot"] = true,
	["lootRoll"] = true,
	["normTex"] = "ElvUI Norm",
	["glossTex"] = "ElvUI Norm",
	["dmgfont"] = "Homespun",
	["namefont"] = "PT Sans Narrow",
	["chatBubbles"] = "backdrop",
	["chatBubbleFont"] = "PT Sans Narrow",
	["chatBubbleFontSize"] = 14,
	["pixelPerfect"] = true,
	["replaceBlizzFonts"] = true,
	["minimap"] = {
		["enable"] = true,
		["hideCalendar"] = true,
	},
	["classColorMentionsSpeech"] = true
}

V["bags"] = {
	["enable"] = true,
	["bagBar"] = false,
}

V["nameplate"] = {
	["enable"] = true,
}

V["auras"] = {
	["enable"] = true,
	["disableBlizzard"] = true,

	["lbf"] = {
		enable = false,
		skin = "Blizzard"
	},
}

V["chat"] = {
	["enable"] = true,
}

V["skins"] = {
	["animations"] = true,
	["ace3"] = {
		["enable"] = true,
	},
	["blizzard"] = {
		["enable"] = true,
		["achievement"] = true,
		["alertframes"] = true,
		["arena"] = true,
		["arenaregistrar"] = true,
		["auctionhouse"] = true,
		["bags"] = true,
		["barber"] = true,
		["bgmap"] = true,
		["bgscore"] = true,
		["binding"] = true,
		["calendar"] = true,
		["character"] = true,
		["debug"] = true,
		["dressingroom"] = true,
		["friends"] = true,
		["gbank"] = true,
		["glyph"] = true,
		["gmchat"] = true,
		["gossip"] = true,
		["greeting"] = true,
		["guildregistrar"] = true,
		["help"] = true,
		["inspect"] = true,
		["lfd"] = true,
		["lfr"] = true,
		["loot"] = true,
		["lootRoll"] = true,
		["macro"] = true,
		["mail"] = true,
		["merchant"] = true,
		["misc"] = true,
		["petition"] = true,
		["pvp"] = true,
		["quest"] = true,
		["raid"] = true,
		["socket"] = true,
		["spellbook"] = true,
		["stable"] = true,
		["tabard"] = true,
		["talent"] = true,
		["taxi"] = true,
		["timemanager"] = true,
		["trade"] = true,
		["tradeskill"] = true,
		["trainer"] = true,
		["tutorial"] = true,
		["worldmap"] = true,
		["mirrorTimers"] = true
	},
}

V["tooltip"] = {
	["enable"] = true,
}

V["unitframe"] = {
	["enable"] = true,
	["disabledBlizzardFrames"] = {
		["player"] = true,
		["target"] = true,
		["focus"] = true,
		["boss"] = true,
		["arena"] = true,
		["party"] = true
	}
}

V["actionbar"] = {
	["enable"] = true,
	["lbf"] = {
		enable = false,
		skin = "Blizzard"
	},
}

V["cooldown"] = {
	enable = true
}