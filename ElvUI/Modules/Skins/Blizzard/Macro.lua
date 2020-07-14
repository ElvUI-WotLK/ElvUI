local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local unpack = unpack
--WoW API / Variables

S:AddCallbackForAddon("Blizzard_MacroUI", "Skin_Blizzard_MacroUI", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.macro then return end

	MacroFrame:StripTextures()
	MacroFrame:CreateBackdrop("Transparent")
	MacroFrame.backdrop:Point("TOPLEFT", 11, -12)
	MacroFrame.backdrop:Point("BOTTOMRIGHT", -32, 76)

	S:SetUIPanelWindowInfo(MacroFrame, "width")
	S:SetBackdropHitRect(MacroFrame)

	S:HandleCloseButton(MacroFrameCloseButton, MacroFrame.backdrop)

	MacroButtonScrollFrame:StripTextures()
	MacroButtonScrollFrame:CreateBackdrop("Transparent")

	S:HandleScrollBar(MacroButtonScrollFrameScrollBar)
	S:HandleScrollBar(MacroFrameScrollFrameScrollBar)

	MacroFrameSelectedMacroButton:StripTextures()
	MacroFrameSelectedMacroButton:StyleButton(nil, true)
	MacroFrameSelectedMacroButton:GetNormalTexture():SetTexture(nil)
	MacroFrameSelectedMacroButton:SetTemplate()

	MacroFrameSelectedMacroButtonIcon:SetTexCoord(unpack(E.TexCoords))
	MacroFrameSelectedMacroButtonIcon:SetInside()

	MacroFrameTextBackground:StripTextures()
	MacroFrameTextBackground:CreateBackdrop()
	MacroFrameTextBackground.backdrop:Point("TOPLEFT", 1, -3)
	MacroFrameTextBackground.backdrop:Point("BOTTOMRIGHT", -17, 3)

	S:HandleButton(MacroEditButton)
	S:HandleButton(MacroDeleteButton)
	S:HandleButton(MacroExitButton)
	S:HandleButton(MacroNewButton)

	for i = 1, 2 do
		local tab = _G["MacroFrameTab"..i]
		tab:StripTextures()
		S:HandleButton(tab)

		tab:Height(22)

		if i == 1 then
			tab:Point("TOPLEFT", 19, -50)
			tab:Width(125)
		elseif i == 2 then
			tab:Point("LEFT", MacroFrameTab1, "RIGHT", 3, 0)
			tab:Width(176)
		end

		tab.SetWidth = E.noop
	end

	for i = 1, MAX_ACCOUNT_MACROS do
		local button = _G["MacroButton"..i]
		local buttonIcon = _G["MacroButton"..i.."Icon"]

		if button then
			button:StripTextures()
			button:SetTemplate(nil, true)
			button:StyleButton(nil, true)

			buttonIcon:SetTexCoord(unpack(E.TexCoords))
			buttonIcon:SetInside()
		end
	end

	MacroButtonScrollFrame:Size(302, 142)
	MacroButtonScrollFrame:Point("TOPLEFT", 20, -76)

	MacroButtonScrollFrameScrollBar:Point("TOPLEFT", MacroButtonScrollFrame, "TOPRIGHT", 4, -18)
	MacroButtonScrollFrameScrollBar:Point("BOTTOMLEFT", MacroButtonScrollFrame, "BOTTOMRIGHT", 4, 18)

	MacroButton1:Point("TOPLEFT", 10, -7)

	MacroEditButton:Point("TOPLEFT", MacroFrameSelectedMacroBackground, "TOPLEFT", 60, -28)

	MacroFrameTextBackground:Point("TOPLEFT", 18, -290)

	MacroFrameText:Width(297)

	MacroFrameSelectedMacroBackground:Point("TOPLEFT", 16, -213)

	MacroFrameScrollFrame:Size(300, 81)
	MacroFrameScrollFrame:Point("TOPLEFT", MacroFrameSelectedMacroBackground, "BOTTOMLEFT", 5, -20)

	MacroFrameScrollFrameScrollBar:Point("TOPLEFT", MacroFrameScrollFrame, "TOPRIGHT", 5, -15)
	MacroFrameScrollFrameScrollBar:Point("BOTTOMLEFT", MacroFrameScrollFrame, "BOTTOMRIGHT", 5, 15)

	MacroFrameCharLimitText:Point("BOTTOM", -15, 113)

	MacroDeleteButton:Point("BOTTOMLEFT", 19, 84)
	MacroExitButton:Point("CENTER", MacroFrame, "TOPLEFT", 304, -417)
	MacroNewButton:Point("CENTER", MacroFrame, "TOPLEFT", 221, -417)

	-- Popup frame
	S:HandleIconSelectionFrame(MacroPopupFrame, NUM_MACRO_ICONS_SHOWN, "MacroPopupButton", "MacroPopup")

	S:SetBackdropHitRect(MacroPopupFrame)
	MacroPopupFrame:Point("TOPLEFT", MacroFrame, "TOPRIGHT", -43, 0)

	MacroPopupScrollFrame:SetTemplate("Transparent")

	S:HandleScrollBar(MacroPopupScrollFrameScrollBar)

	local text1, text2 = select(5, MacroPopupFrame:GetRegions())
	text1:Point("TOPLEFT", 24, -18)
	text2:Point("TOPLEFT", 24, -60)

	MacroPopupEditBox:Point("TOPLEFT", 61, -35)

	MacroPopupButton1:Point("TOPLEFT", 31, -82)

	MacroPopupScrollFrame:Size(247, 180)
	MacroPopupScrollFrame:Point("TOPRIGHT", -32, -76)

	MacroPopupScrollFrameScrollBar:Point("TOPLEFT", MacroPopupScrollFrame, "TOPRIGHT", 3, -19)
	MacroPopupScrollFrameScrollBar:Point("BOTTOMLEFT", MacroPopupScrollFrame, "BOTTOMRIGHT", 3, 19)

	MacroPopupOkayButton:Point("RIGHT", MacroPopupCancelButton, "LEFT", -3, 0)
end)