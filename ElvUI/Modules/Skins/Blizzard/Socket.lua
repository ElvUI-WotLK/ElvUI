local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
--WoW API / Variables
local GetNumSockets = GetNumSockets
local GetSocketTypes = GetSocketTypes

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.socket then return end

	ItemSocketingFrame:StripTextures()
	ItemSocketingFrame:CreateBackdrop("Transparent")
	ItemSocketingFrame.backdrop:Point("TOPLEFT", 11, -12)
	ItemSocketingFrame.backdrop:Point("BOTTOMRIGHT", -2, 31)

	S:SetUIPanelWindowInfo(ItemSocketingFrame, "width")

	ItemSocketingFramePortrait:Kill()

	S:HandleCloseButton(ItemSocketingCloseButton, ItemSocketingFrame.backdrop)

	ItemSocketingScrollFrame:StripTextures()
	ItemSocketingScrollFrame:CreateBackdrop("Transparent")
	ItemSocketingScrollFrame.backdrop:Point("BOTTOMRIGHT", 3, -1)

	S:HandleScrollBar(ItemSocketingScrollFrameScrollBar, 2)

	S:HandleButton(ItemSocketingSocketButton)

	for i = 1, MAX_NUM_SOCKETS do
		local button = _G["ItemSocketingSocket"..i]
		local bracket = _G["ItemSocketingSocket"..i.."BracketFrame"]
		local bg = _G["ItemSocketingSocket"..i.."Background"]
		local icon = _G["ItemSocketingSocket"..i.."IconTexture"]

		button:StripTextures()
		button:StyleButton(false)
		button:SetTemplate("Default", true)

		bracket:Kill()
		bg:Kill()

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()
	end

	local GEM_TYPE_INFO = GEM_TYPE_INFO

	hooksecurefunc("ItemSocketingFrame_Update", function()
		for i = 1, GetNumSockets() do
			local button = _G["ItemSocketingSocket"..i]
			local color = GEM_TYPE_INFO[GetSocketTypes(i)]
			button:SetBackdropColor(color.r, color.g, color.b, 0.15)
			button:SetBackdropBorderColor(color.r, color.g, color.b)

			if i == 1 then
				local p1, a, p2, x = button:GetPoint()
				button:Point(p1, a, p2, x, 71)
			end
		end
	end)

	ItemSocketingSocketButton:Point("BOTTOMRIGHT", -10, 39)
end

S:AddCallbackForAddon("Blizzard_ItemSocketingUI", "Skin_Blizzard_ItemSocketingUI", LoadSkin)