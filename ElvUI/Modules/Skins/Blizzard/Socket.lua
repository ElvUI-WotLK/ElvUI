local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local format = string.format
--WoW API / Variables
local GetNumSockets = GetNumSockets
local GetSocketTypes = GetSocketTypes

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.socket then return end

	ItemSocketingFrame:StripTextures()
	ItemSocketingFrame:CreateBackdrop("Transparent")
	ItemSocketingFrame.backdrop:Point("TOPLEFT", 11, -12)
	ItemSocketingFrame.backdrop:Point("BOTTOMRIGHT", -4, 27)

	ItemSocketingFramePortrait:Kill()

	S:HandleCloseButton(ItemSocketingCloseButton)

	ItemSocketingScrollFrame:StripTextures()
	ItemSocketingScrollFrame:CreateBackdrop("Transparent")

	S:HandleScrollBar(ItemSocketingScrollFrameScrollBar, 2)

	for i = 1, MAX_NUM_SOCKETS do
		local button = _G[format("ItemSocketingSocket%d", i)]
		local button_bracket = _G[format("ItemSocketingSocket%dBracketFrame", i)]
		local button_bg = _G[format("ItemSocketingSocket%dBackground", i)]
		local button_icon = _G[format("ItemSocketingSocket%dIconTexture", i)]
		button:StripTextures()
		button:StyleButton(false)
		button:SetTemplate("Default", true)
		button_bracket:Kill()
		button_bg:Kill()
		button_icon:SetTexCoord(unpack(E.TexCoords))
		button_icon:SetInside()
	end

	local GEM_TYPE_INFO = GEM_TYPE_INFO

	hooksecurefunc("ItemSocketingFrame_Update", function()
		for i = 1, GetNumSockets() do
			local button = _G[format("ItemSocketingSocket%d", i)]
			local color = GEM_TYPE_INFO[GetSocketTypes(i)]
			button:SetBackdropColor(color.r, color.g, color.b, 0.15)
			button:SetBackdropBorderColor(color.r, color.g, color.b)
		end
	end)

	S:HandleButton(ItemSocketingSocketButton)
end

S:AddCallbackForAddon("Blizzard_ItemSocketingUI", "Skin_Blizzard_ItemSocketingUI", LoadSkin)