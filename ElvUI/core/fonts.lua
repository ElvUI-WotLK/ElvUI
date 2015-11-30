local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local LSM = LibStub("LibSharedMedia-3.0")

local GetChatWindowInfo = GetChatWindowInfo;
local SetCVar = SetCVar;

local function SetFont(obj, font, size, style, r, g, b, sr, sg, sb, sox, soy)
	obj:SetFont(font, size, style)
	if sr and sg and sb then obj:SetShadowColor(sr, sg, sb) end
	if sox and soy then obj:SetShadowOffset(sox, soy) end
	if r and g and b then obj:SetTextColor(r, g, b)
	elseif r then obj:SetAlpha(r) end
end

function E:UpdateBlizzardFonts()	
	local NORMAL     = self["media"].normFont
	local COMBAT     = LSM:Fetch('font', self.private.general.dmgfont)
	local NUMBER     = self["media"].normFont
	local NAMEFONT	 = LSM:Fetch('font', self.private.general.namefont)
	local MONOCHROME = ''
	local _, editBoxFontSize, _, _, _, _, _, _, _, _ = GetChatWindowInfo(1)

	UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = 12
	CHAT_FONT_HEIGHTS = {10, 12, 13, 14, 15, 16, 17, 18, 19, 20}

	UNIT_NAME_FONT     = NAMEFONT
	NAMEPLATE_FONT     = NAMEFONT
	DAMAGE_TEXT_FONT   = COMBAT
	STANDARD_TEXT_FONT = NORMAL
	
	if self.db.general.font:lower():find('pixel') then
		MONOCHROME = 'MONOCHROME'
	end
	
	if self.eyefinity then
		-- damage are huge on eyefinity, so we disable it
		InterfaceOptionsCombatTextPanelTargetDamage:Hide()
		InterfaceOptionsCombatTextPanelPeriodicDamage:Hide()
		InterfaceOptionsCombatTextPanelPetDamage:Hide()
		InterfaceOptionsCombatTextPanelHealing:Hide()
		SetCVar("CombatLogPeriodicSpells",0)
		SetCVar("PetMeleeDamage",0)
		SetCVar("CombatDamage",0)
		SetCVar("CombatHealing",0)
		
		-- set an invisible font for xp, honor kill, etc
		local INVISIBLE = [=[Interface\Addons\ElvUI\media\fonts\Invisible.ttf]=]
		COMBAT = INVISIBLE
	end
	
	-- Base fonts
	SetFont(GameTooltipHeader,                  NORMAL, self.db.general.fontsize)
	SetFont(NumberFont_OutlineThick_Mono_Small, NUMBER, self.db.general.fontsize, "OUTLINE")
	SetFont(NumberFont_Outline_Huge,            NUMBER, 28, MONOCHROME.."THICKOUTLINE", 28)
	SetFont(NumberFont_Outline_Large,           NUMBER, 15, MONOCHROME.."OUTLINE")
	SetFont(NumberFont_Outline_Med,             NUMBER, self.db.general.fontsize, "OUTLINE")
	SetFont(NumberFont_Shadow_Med,              NORMAL, self.db.general.fontsize) --chat editbox uses this
	SetFont(NumberFont_Shadow_Small,            NORMAL, self.db.general.fontsize)
	SetFont(QuestFont,                          NORMAL, self.db.general.fontsize)
	SetFont(QuestFont_Large,                    NORMAL, 14)
	SetFont(SystemFont_Large,                   NORMAL, 15)
	SetFont(GameFontNormalMed3,					NORMAL, 15)
	SetFont(SystemFont_Shadow_Huge1,			NORMAL, 20, MONOCHROME.."OUTLINE") -- Raid Warning, Boss emote frame too
	SetFont(SystemFont_Med1,                    NORMAL, self.db.general.fontsize)
	SetFont(SystemFont_Med3,                    NORMAL, self.db.general.fontsize)
	SetFont(SystemFont_OutlineThick_Huge2,      NORMAL, 20, MONOCHROME.."THICKOUTLINE")
	SetFont(SystemFont_Outline_Small,           NUMBER, self.db.general.fontsize, "OUTLINE")
	SetFont(SystemFont_Shadow_Large,            NORMAL, 15)
	SetFont(SystemFont_Shadow_Med1,             NORMAL, self.db.general.fontsize)
	SetFont(SystemFont_Shadow_Med3,             NORMAL, self.db.general.fontsize)
	SetFont(SystemFont_Shadow_Outline_Huge2,    NORMAL, 20, MONOCHROME.."OUTLINE")
	SetFont(SystemFont_Shadow_Small,            NORMAL, self.db.general.fontsize)
	SetFont(SystemFont_Small,                   NORMAL, self.db.general.fontsize)
	SetFont(SystemFont_Tiny,                    NORMAL, self.db.general.fontsize)
	SetFont(Tooltip_Med,                        NORMAL, self.db.general.fontsize)
	SetFont(Tooltip_Small,                      NORMAL, self.db.general.fontsize)
	SetFont(FriendsFont_Normal,                 NORMAL, self.db.general.fontsize)
	SetFont(FriendsFont_Small,					NORMAL, self.db.general.fontsize)
	SetFont(FriendsFont_Large,					NORMAL, self.db.general.fontsize)
	SetFont(FriendsFont_UserText,				NORMAL, self.db.general.fontsize)
	SetFont(ZoneTextString,						NORMAL, 32, MONOCHROME.."OUTLINE")
	SetFont(SubZoneTextString,					NORMAL, 25, MONOCHROME.."OUTLINE")
	SetFont(PVPInfoTextString,					NORMAL, 22, MONOCHROME.."OUTLINE")
	SetFont(PVPArenaTextString,					NORMAL, 22, MONOCHROME.."OUTLINE")
	SetFont(CombatTextFont,                     COMBAT, 100, "OUTLINE") -- number here just increase the font quality.
end