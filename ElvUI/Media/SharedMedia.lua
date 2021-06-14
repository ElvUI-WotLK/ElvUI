local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local LSM = E.Libs.LSM
local M = [[Interface\AddOns\ElvUI\Media\]]

function E:TextureString(texString, dataString)
	return "|T"..texString..(dataString or "").."|t"
end

E.Media = {
	Arrows = {
		Arrow0 = M..[[Arrows\Arrow0.tga]],
		Arrow1 = M..[[Arrows\Arrow1.tga]],
		Arrow2 = M..[[Arrows\Arrow2.tga]],
		Arrow3 = M..[[Arrows\Arrow3.tga]],
		Arrow4 = M..[[Arrows\Arrow4.tga]],
		Arrow5 = M..[[Arrows\Arrow5.tga]],
		Arrow6 = M..[[Arrows\Arrow6.tga]],
		Arrow7 = M..[[Arrows\Arrow7.tga]],
		Arrow8 = M..[[Arrows\Arrow8.tga]],
		Arrow9 = M..[[Arrows\Arrow9.tga]],
		Arrow10 = M..[[Arrows\Arrow10.tga]],
		Arrow11 = M..[[Arrows\Arrow11.tga]],
		Arrow12 = M..[[Arrows\Arrow12.tga]],
		Arrow13 = M..[[Arrows\Arrow13.tga]],
		Arrow14 = M..[[Arrows\Arrow14.tga]],
		Arrow15 = M..[[Arrows\Arrow15.tga]],
		Arrow16 = M..[[Arrows\Arrow16.tga]],
		Arrow17 = M..[[Arrows\Arrow17.tga]],
		Arrow18 = M..[[Arrows\Arrow18.tga]],
		Arrow19 = M..[[Arrows\Arrow19.tga]],
		Arrow20 = M..[[Arrows\Arrow20.tga]],
		Arrow21 = M..[[Arrows\Arrow21.tga]],
		Arrow22 = M..[[Arrows\Arrow22.tga]],
		Arrow23 = M..[[Arrows\Arrow23.tga]],
		Arrow24 = M..[[Arrows\Arrow24.tga]],
		Arrow25 = M..[[Arrows\Arrow25.tga]],
		Arrow26 = M..[[Arrows\Arrow26.tga]],
		Arrow27 = M..[[Arrows\Arrow27.tga]],
		Arrow28 = M..[[Arrows\Arrow28.tga]],
		Arrow29 = M..[[Arrows\Arrow29.tga]],
		Arrow30 = M..[[Arrows\Arrow30.tga]],
		Arrow31 = M..[[Arrows\Arrow31.tga]],
		Arrow32 = M..[[Arrows\Arrow32.tga]],
		Arrow33 = M..[[Arrows\Arrow33.tga]],
		Arrow34 = M..[[Arrows\Arrow34.tga]],
		Arrow35 = M..[[Arrows\Arrow35.tga]],
		Arrow36 = M..[[Arrows\Arrow36.tga]],
		Arrow37 = M..[[Arrows\Arrow37.tga]],
		Arrow38 = M..[[Arrows\Arrow38.tga]],
		Arrow39 = M..[[Arrows\Arrow39.tga]],
		Arrow40 = M..[[Arrows\Arrow40.tga]],
		Arrow41 = M..[[Arrows\Arrow41.tga]],
		Arrow42 = M..[[Arrows\Arrow42.tga]],
		Arrow43 = M..[[Arrows\Arrow43.tga]],
		Arrow44 = M..[[Arrows\Arrow44.tga]],
		Arrow45 = M..[[Arrows\Arrow45.tga]],
		Arrow46 = M..[[Arrows\Arrow46.tga]],
		Arrow47 = M..[[Arrows\Arrow47.tga]],
		Arrow48 = M..[[Arrows\Arrow48.tga]],
		Arrow49 = M..[[Arrows\Arrow49.tga]],
		Arrow50 = M..[[Arrows\Arrow50.tga]],
		Arrow51 = M..[[Arrows\Arrow51.tga]],
		Arrow52 = M..[[Arrows\Arrow52.tga]],
		Arrow53 = M..[[Arrows\Arrow53.tga]],
		Arrow54 = M..[[Arrows\Arrow54.tga]],
		Arrow55 = M..[[Arrows\Arrow55.tga]],
		Arrow56 = M..[[Arrows\Arrow56.tga]],
		Arrow57 = M..[[Arrows\Arrow57.tga]],
		Arrow58 = M..[[Arrows\Arrow58.tga]],
		Arrow59 = M..[[Arrows\Arrow59.tga]],
		Arrow60 = M..[[Arrows\Arrow60.tga]],
		Arrow61 = M..[[Arrows\Arrow61.tga]],
		Arrow62 = M..[[Arrows\Arrow62.tga]],
		Arrow63 = M..[[Arrows\Arrow63.tga]],
		Arrow64 = M..[[Arrows\Arrow64.tga]],
		Arrow65 = M..[[Arrows\Arrow65.tga]],
		Arrow66 = M..[[Arrows\Arrow66.tga]],
		Arrow67 = M..[[Arrows\Arrow67.tga]],
		Arrow68 = M..[[Arrows\Arrow68.tga]],
		Arrow69 = M..[[Arrows\Arrow69.tga]],
		Arrow70 = M..[[Arrows\Arrow70.tga]],
		Arrow71 = M..[[Arrows\Arrow71.tga]],
		Arrow72 = M..[[Arrows\Arrow72.tga]],
		ArrowRed = M..[[Arrows\ArrowRed.tga]],
		ArrowUp = M..[[Textures\ArrowUp.tga]],
		OldArrow2 = M..[[Arrows\OldArrow2.tga]],
		RLArrow = M..[[Arrows\RLArrow.tga]]
	},
	Fonts = {
		ActionMan = M..[[Fonts\ActionMan.ttf]],
		ContinuumMedium = M..[[Fonts\ContinuumMedium.ttf]],
		DieDieDie = M..[[Fonts\DieDieDie.ttf]],
		Expressway = M..[[Fonts\Expressway.ttf]],
		Homespun = M..[[Fonts\Homespun.ttf]],
		Invisible = M..[[Fonts\Invisible.ttf]],
		PTSansNarrow = M..[[Fonts\PTSansNarrow.ttf]]
	},
	Sounds = {
		AwwCrap = M..[[Sounds\AwwCrap.ogg]],
		BbqAss = M..[[Sounds\BbqAss.ogg]],
		DumbShit = M..[[Sounds\DumbShit.ogg]],
		HarlemShake = M..[[Sounds\HarlemShake.ogg]],
		HelloKitty = M..[[Sounds\HelloKitty.ogg]],
		MamaWeekends = M..[[Sounds\MamaWeekends.ogg]],
		RunFast = M..[[Sounds\RunFast.ogg]],
		ElvUIAska = M..[[Sounds\SndIncMsg.ogg]],
		StopRunningSlimeBall = M..[[Sounds\StopRunningSlimeBall.ogg]],
		Warning = M..[[Sounds\Warning.ogg]],
		Whisper = M..[[Sounds\Whisper.ogg]],
		YankieBangBang = M..[[Sounds\YankieBangBang.ogg]]
	},
	ChatEmojis = {
		Angry = M..[[ChatEmojis\Angry.tga]],
		Blush = M..[[ChatEmojis\Blush.tga]],
		BrokenHeart = M..[[ChatEmojis\BrokenHeart.tga]],
		CallMe = M..[[ChatEmojis\CallMe.tga]],
		Cry = M..[[ChatEmojis\Cry.tga]],
		Facepalm = M..[[ChatEmojis\Facepalm.tga]],
		Grin = M..[[ChatEmojis\Grin.tga]],
		Heart = M..[[ChatEmojis\Heart.tga]],
		HeartEyes = M..[[ChatEmojis\HeartEyes.tga]],
		Joy = M..[[ChatEmojis\Joy.tga]],
		Kappa = M..[[ChatEmojis\Kappa.tga]],
		Meaw = M..[[ChatEmojis\Meaw.tga]],
		MiddleFinger = M..[[ChatEmojis\MiddleFinger.tga]],
		Murloc = M..[[ChatEmojis\Murloc.tga]],
		OkHand = M..[[ChatEmojis\OkHand.tga]],
		OpenMouth = M..[[ChatEmojis\OpenMouth.tga]],
		Poop = M..[[ChatEmojis\Poop.tga]],
		Rage = M..[[ChatEmojis\Rage.tga]],
		SadKitty = M..[[ChatEmojis\SadKitty.tga]],
		Scream = M..[[ChatEmojis\Scream.tga]],
		ScreamCat = M..[[ChatEmojis\ScreamCat.tga]],
		SemiColon = M..[[ChatEmojis\SemiColon.tga]],
		SlightFrown = M..[[ChatEmojis\SlightFrown.tga]],
		Smile = M..[[ChatEmojis\Smile.tga]],
		Smirk = M..[[ChatEmojis\Smirk.tga]],
		Sob = M..[[ChatEmojis\Sob.tga]],
		StuckOutTongue = M..[[ChatEmojis\StuckOutTongue.tga]],
		StuckOutTongueClosedEyes = M..[[ChatEmojis\StuckOutTongueClosedEyes.tga]],
		Sunglasses = M..[[ChatEmojis\Sunglasses.tga]],
		Thinking = M..[[ChatEmojis\Thinking.tga]],
		ThumbsUp = M..[[ChatEmojis\ThumbsUp.tga]],
		Wink = M..[[ChatEmojis\Wink.tga]],
		ZZZ = M..[[ChatEmojis\ZZZ.tga]]
	},
	ChatLogos = {
		ElvRainbow = M..[[ChatLogos\ElvRainbow.tga]],
		ElvMelon = M..[[ChatLogos\ElvMelon.tga]],
		ElvBlue = M..[[ChatLogos\ElvBlue.tga]],
		ElvGreen = M..[[ChatLogos\ElvGreen.tga]],
		ElvOrange = M..[[ChatLogos\ElvOrange.tga]],
		ElvPink = M..[[ChatLogos\ElvPink.tga]],
		ElvPurple = M..[[ChatLogos\ElvPurple.tga]],
		ElvYellow = M..[[ChatLogos\ElvYellow.tga]],
		ElvRed = M..[[ChatLogos\ElvRed.tga]],
		Bathrobe = M..[[ChatLogos\Bathrobe.tga]],
		HelloKitty = M..[[ChatLogos\HelloKitty.tga]],
		Illuminati = M..[[ChatLogos\Illuminati.tga]],
		MrHankey = M..[[ChatLogos\MrHankey.tga]],
		Rainbow = M..[[ChatLogos\Rainbow.tga]],
		TyroneBiggums = M..[[ChatLogos\TyroneBiggums.tga]]
	},
	Textures = {
		AllianceLogo = M..[[Textures\Alliance-Logo.blp]],
		Arrow = M..[[Textures\Arrow.tga]],
		ArrowRight = M..[[Textures\ArrowRight.tga]],
		ArrowUp = M..[[Textures\ArrowUp.tga]],
		BagJunkIcon = M..[[Textures\BagJunkIcon.blp]],
		BagQuestIcon = M..[[Textures\BagQuestIcon.tga]],
		Black8x8 = M..[[Textures\Black8x8.tga]],
		White8x8 = [[Interface\BUTTONS\WHITE8X8]], -- not elvui
		Broom = M..[[Textures\Broom.blp]],
		ChatEmojis = M..[[Textures\ChatEmojis]],
		ChatLogos = M..[[Textures\ChatLogos]],
		Close = M..[[Textures\Close.tga]],
		Combat = M..[[Textures\Combat.tga]],
		Copy = M..[[Textures\Copy.tga]],
		Cross = M..[[Textures\Cross.tga]],
		DPS = M..[[Textures\DPS.tga]],
		ExitVehicle = M..[[Textures\ExitVehicle.tga]],
		GlowTex = M..[[Textures\GlowTex.tga]],
		Healer = M..[[Textures\Healer.tga]],
		HelloKitty = M..[[Textures\HelloKitty.tga]],
		HelloKittyChat = M..[[Textures\HelloKittyChat.tga]],
		Highlight = M..[[Textures\Highlight.tga]],
		HordeLogo = M..[[Textures\Horde-Logo.blp]],
		Leader = M..[[Textures\Leader.tga]],
		LevelUpTex = M..[[Textures\LevelUpTex.blp]],
		Logo = M..[[Textures\Logo.tga]],
		Mail = M..[[Textures\Mail.tga]],
		Melli = M..[[Textures\Melli.tga]],
		Minimalist = M..[[Textures\Minimalist.tga]],
		Minus = M..[[Textures\Minus.tga]],
		MinusButton = M..[[Textures\MinusButton.tga]],
		Nameplates = M..[[Textures\Nameplates.blp]],
		NormTex = M..[[Textures\NormTex.tga]],
		NormTex2 = M..[[Textures\NormTex2.tga]],
		Pause = M..[[Textures\Pause.tga]],
		Play = M..[[Textures\Play.tga]],
		Plus = M..[[Textures\Plus.tga]],
		PlusButton = M..[[Textures\PlusButton.tga]],
		PvPIcons = M..[[Textures\PVP-Icons.blp]],
		RaidIcons = M..[[Textures\RaidIcons.blp]],
		Reset = M..[[Textures\Reset.tga]],
		Resting = M..[[Textures\Resting.tga]],
		Resting1 = M..[[Textures\Resting1.tga]],
		RoleIcons = M..[[Textures\RoleIcons.tga]],
		SkullIcon = M..[[Textures\SkullIcon.tga]],
		Smooth = M..[[Textures\Smooth.tga]],
		Spark = M..[[Textures\Spark.tga]],
		StreamBackground = M..[[Textures\StreamBackground]],
		StreamCircle = M..[[Textures\StreamCircle]],
		StreamFrame = M..[[Textures\StreamFrame]],
		StreamSpark = M..[[Textures\StreamSpark]],
		Tank = M..[[Textures\Tank.tga]]
	}
}

LSM:Register("border", "ElvUI GlowBorder", E.Media.Textures.GlowTex)
LSM:Register("font", "Continuum Medium", E.Media.Fonts.ContinuumMedium)
LSM:Register("font", "Die Die Die!", E.Media.Fonts.DieDieDie, LSM.LOCALE_BIT_ruRU + LSM.LOCALE_BIT_western)
LSM:Register("font", "Action Man", E.Media.Fonts.ActionMan)
LSM:Register("font", "Expressway", E.Media.Fonts.Expressway, LSM.LOCALE_BIT_ruRU + LSM.LOCALE_BIT_western)
LSM:Register("font", "PT Sans Narrow", E.Media.Fonts.PTSansNarrow, LSM.LOCALE_BIT_ruRU + LSM.LOCALE_BIT_western)
LSM:Register("font", "Homespun", E.Media.Fonts.Homespun, LSM.LOCALE_BIT_ruRU + LSM.LOCALE_BIT_western)
LSM:Register("sound", "ElvUI Aska", E.Media.Sounds.SndIncMsg)
LSM:Register("sound", "Awww Crap", E.Media.Sounds.AwwCrap)
LSM:Register("sound", "BBQ Ass", E.Media.Sounds.BbqAss)
LSM:Register("sound", "Big Yankie Devil", E.Media.Sounds.YankieBangBang)
LSM:Register("sound", "Dumb Shit", E.Media.Sounds.DumbShit)
LSM:Register("sound", "Mama Weekends", E.Media.Sounds.MamaWeekends)
LSM:Register("sound", "Runaway Fast", E.Media.Sounds.RunFast)
LSM:Register("sound", "Stop Running", E.Media.Sounds.StopRunningSlimeBall)
LSM:Register("sound", "Warning", E.Media.Sounds.Warning)
LSM:Register("sound", "Whisper Alert", E.Media.Sounds.Whisper)
LSM:Register("statusbar", "Melli", E.Media.Textures.Melli)
LSM:Register("statusbar", "ElvUI Gloss", E.Media.Textures.NormTex)
LSM:Register("statusbar", "ElvUI Norm", E.Media.Textures.NormTex2)
LSM:Register("statusbar", "Minimalist", E.Media.Textures.Minimalist)
LSM:Register("statusbar", "ElvUI Blank", E.Media.Textures.White8x8)
LSM:Register("background", "ElvUI Blank", E.Media.Textures.White8x8)