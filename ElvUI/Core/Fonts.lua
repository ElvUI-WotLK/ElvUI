local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local LSM = E.Libs.LSM

--Lua functions
--WoW API / Variables
local SetCVar = SetCVar

local function SetFont(obj, font, size, style, sr, sg, sb, sa, sox, soy, r, g, b)
	if not obj then return end

	obj:SetFont(font, size, style)
	if sr and sg and sb then obj:SetShadowColor(sr, sg, sb, sa) end
	if sox and soy then obj:SetShadowOffset(sox, soy) end
	if r and g and b then obj:SetTextColor(r, g, b)
	elseif r then obj:SetAlpha(r) end
end

function E:UpdateBlizzardFonts()
	local NORMAL		= self.media.normFont
	local NUMBER		= self.media.normFont
	local COMBAT		= LSM:Fetch("font", self.private.general.dmgfont)
	local NAMEFONT		= LSM:Fetch("font", self.private.general.namefont)
	local MONOCHROME	= ""

	UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = 12
	CHAT_FONT_HEIGHTS = {6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20}

	if self.db.general.font == "Homespun" then
		MONOCHROME = "MONOCHROME"
	end

	if self.eyefinity then
		InterfaceOptionsCombatTextPanelTargetDamage:Hide()
		InterfaceOptionsCombatTextPanelPeriodicDamage:Hide()
		InterfaceOptionsCombatTextPanelPetDamage:Hide()
		InterfaceOptionsCombatTextPanelHealing:Hide()
		SetCVar("CombatLogPeriodicSpells", 0)
		SetCVar("PetMeleeDamage", 0)
		SetCVar("CombatDamage", 0)
		SetCVar("CombatHealing", 0)

		-- set an invisible font for xp, honor kill, etc
		COMBAT = E.Media.Fonts.Invisible
	end

	UNIT_NAME_FONT		= NAMEFONT
	NAMEPLATE_FONT		= NAMEFONT
	DAMAGE_TEXT_FONT	= COMBAT
	STANDARD_TEXT_FONT	= NORMAL

	if self.private.general.replaceBlizzFonts then
		SetFont(GameTooltipHeader,					NORMAL, self.db.general.fontSize)
		SetFont(NumberFont_OutlineThick_Mono_Small,	NUMBER, self.db.general.fontSize, "OUTLINE")
		SetFont(NumberFont_Outline_Huge,			NUMBER, 28, MONOCHROME.."THICKOUTLINE", 28)
		SetFont(NumberFont_Outline_Large,			NUMBER, 15, MONOCHROME.."OUTLINE")
		SetFont(NumberFont_Outline_Med,				NUMBER, self.db.general.fontSize, "OUTLINE")
		SetFont(NumberFont_Shadow_Med,				NORMAL, self.db.general.fontSize)
		SetFont(NumberFont_Shadow_Small,			NORMAL, self.db.general.fontSize)
		SetFont(ChatFontSmall,						NORMAL, self.db.general.fontSize)
		SetFont(QuestFontHighlight,					NORMAL, self.db.general.fontSize)
		SetFont(QuestFont,							NORMAL, self.db.general.fontSize)
		SetFont(QuestFont_Large,					NORMAL, 14)
		SetFont(QuestTitleFont,						NORMAL, self.db.general.fontSize + 8)
		SetFont(QuestTitleFontBlackShadow,			NORMAL, self.db.general.fontSize + 8)
		SetFont(SystemFont_Large,					NORMAL, 15)
		SetFont(GameFontNormalMed3,					NORMAL, 15)
		SetFont(SystemFont_Shadow_Huge1,			NORMAL, 20, MONOCHROME.."OUTLINE")
		SetFont(SystemFont_Med1,					NORMAL, self.db.general.fontSize)
		SetFont(SystemFont_Med3,					NORMAL, self.db.general.fontSize)
		SetFont(SystemFont_OutlineThick_Huge2,		NORMAL, 20, MONOCHROME.."THICKOUTLINE")
		SetFont(SystemFont_Outline_Small,			NUMBER, self.db.general.fontSize, "OUTLINE")
		SetFont(SystemFont_Shadow_Large,			NORMAL, 15)
		SetFont(SystemFont_Shadow_Med1,				NORMAL, self.db.general.fontSize)
		SetFont(SystemFont_Shadow_Med3,				NORMAL, self.db.general.fontSize)
		SetFont(SystemFont_Shadow_Outline_Huge2,	NORMAL, 20, MONOCHROME.."OUTLINE")
		SetFont(SystemFont_Shadow_Small,			NORMAL, self.db.general.fontSize)
		SetFont(SystemFont_Small,					NORMAL, self.db.general.fontSize)
		SetFont(SystemFont_Tiny,					NORMAL, self.db.general.fontSize)
		SetFont(Tooltip_Med,						NORMAL, self.db.general.fontSize)
		SetFont(Tooltip_Small,						NORMAL, self.db.general.fontSize)
		SetFont(FriendsFont_Normal,					NORMAL, self.db.general.fontSize)
		SetFont(FriendsFont_Small,					NORMAL, self.db.general.fontSize)
		SetFont(FriendsFont_Large,					NORMAL, self.db.general.fontSize)
		SetFont(FriendsFont_UserText,				NORMAL, self.db.general.fontSize)
		SetFont(SpellFont_Small,					NORMAL, self.db.general.fontSize*0.9)
		SetFont(ZoneTextString,						NORMAL, 32, MONOCHROME.."OUTLINE")
		SetFont(SubZoneTextString,					NORMAL, 25, MONOCHROME.."OUTLINE")
		SetFont(PVPInfoTextString,					NORMAL, 22, MONOCHROME.."OUTLINE")
		SetFont(PVPArenaTextString,					NORMAL, 22, MONOCHROME.."OUTLINE")
		SetFont(CombatTextFont,						COMBAT, 100, MONOCHROME.."OUTLINE")
		SetFont(SystemFont_OutlineThick_WTF,		NORMAL, 32, MONOCHROME.."OUTLINE")
		SetFont(SubZoneTextFont,					NORMAL, 24, MONOCHROME.."OUTLINE")
		SetFont(MailFont_Large,						NORMAL, 14)
		SetFont(InvoiceFont_Med,					NORMAL, 12)
		SetFont(InvoiceFont_Small,					NORMAL, self.db.general.fontSize)
		SetFont(AchievementFont_Small,				NORMAL, self.db.general.fontSize)
		SetFont(ReputationDetailFont,				NORMAL, self.db.general.fontSize)
	end
end