local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins");

--Cache global variables
--Lua functions
local _G = _G
local unpack = unpack
--WoW API / Variables
local SpellBook_GetCurrentPage = SpellBook_GetCurrentPage
local BOOKTYPE_SPELL = BOOKTYPE_SPELL
local MAX_SKILLLINE_TABS = MAX_SKILLLINE_TABS

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.spellbook ~= true then return end

	SpellBookFrame:StripTextures(true)
	SpellBookFrame:CreateBackdrop("Transparent")
	SpellBookFrame.backdrop:Point("TOPLEFT", 10, -12)
	SpellBookFrame.backdrop:Point("BOTTOMRIGHT", -31, 75)

	SpellBookFrame:EnableMouseWheel(true)
	SpellBookFrame:SetScript("OnMouseWheel", function(_, value)
		--do nothing if not on an appropriate book type
		if SpellBookFrame.bookType ~= BOOKTYPE_SPELL then
			return
		end

		local currentPage, maxPages = SpellBook_GetCurrentPage()

		if value > 0 then
			if currentPage > 1 then
				SpellBookPrevPageButton_OnClick()
			end
		else 
			if currentPage < maxPages then
				SpellBookNextPageButton_OnClick()
			end
		end
	end)
	
	for i = 1, 3 do
		local tab = _G["SpellBookFrameTabButton"..i]

		tab:GetNormalTexture():SetTexture(nil)
		tab:GetDisabledTexture():SetTexture(nil)

		S:HandleTab(tab)

		tab.backdrop:Point("TOPLEFT", 14, E.PixelMode and -17 or -19)
		tab.backdrop:Point("BOTTOMRIGHT", -14, 19)
	end

	S:HandleNextPrevButton(SpellBookPrevPageButton)
	S:HandleNextPrevButton(SpellBookNextPageButton)

	S:HandleCloseButton(SpellBookCloseButton)

	S:HandleCheckBox(ShowAllSpellRanksCheckBox)

	for i = 1, SPELLS_PER_PAGE do
		local button = _G["SpellButton"..i]
		button:StripTextures()

		_G["SpellButton"..i.."AutoCastable"]:SetTexture("Interface\\Buttons\\UI-AutoCastableOverlay")
		_G["SpellButton"..i.."AutoCastable"]:SetOutside(button, 16, 16)

		button:CreateBackdrop("Default", true)

		_G["SpellButton"..i.."IconTexture"]:SetTexCoord(unpack(E.TexCoords))

		E:RegisterCooldown(_G["SpellButton"..i.."Cooldown"])
	end

	hooksecurefunc("SpellButton_UpdateButton", function(self)
		local name = self:GetName()
		_G[name.."SpellName"]:SetTextColor(1, 0.80, 0.10)
		_G[name.."SubSpellName"]:SetTextColor(1, 1, 1)
		_G[name.."Highlight"]:SetTexture(1, 1, 1, 0.3)
	end)

	for i = 1, MAX_SKILLLINE_TABS do
		local tab = _G["SpellBookSkillLineTab"..i]

		tab:StripTextures()
		tab:StyleButton(nil, true)
		tab:SetTemplate("Default", true)

		tab:GetNormalTexture():SetInside()
		tab:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
	end

	SpellBookPageText:SetTextColor(1, 1, 1)
end

S:AddCallback("Spellbook", LoadSkin)