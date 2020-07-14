local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
--WoW API / Variables
local GetNumSockets = GetNumSockets
local GetSocketTypes = GetSocketTypes

S:AddCallbackForAddon("Blizzard_ItemSocketingUI", "Skin_Blizzard_ItemSocketingUI", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.socket then return end

	ITEM_SOCKETING_DESCRIPTION_MIN_WIDTH = 278

	ItemSocketingFrame:StripTextures()
	ItemSocketingFrame:CreateBackdrop("Transparent")
	ItemSocketingFrame.backdrop:Point("TOPLEFT", 11, -12)
	ItemSocketingFrame.backdrop:Point("BOTTOMRIGHT", -2, 31)

	S:SetUIPanelWindowInfo(ItemSocketingFrame, "width")
	S:SetBackdropHitRect(ItemSocketingFrame)

	ItemSocketingFramePortrait:Kill()

	S:HandleCloseButton(ItemSocketingCloseButton, ItemSocketingFrame.backdrop)

	ItemSocketingScrollFrame:Height(269)
	ItemSocketingScrollFrame:Point("TOPLEFT", 20, -77)
	ItemSocketingScrollFrame:StripTextures()
	ItemSocketingScrollFrame:CreateBackdrop("Transparent")
	ItemSocketingScrollFrame.backdrop:Point("BOTTOMRIGHT", 3, -2)

	S:HandleScrollBar(ItemSocketingScrollFrameScrollBar)

	ItemSocketingScrollFrameScrollBar:Point("TOPLEFT", ItemSocketingScrollFrame, "TOPRIGHT", 6, -18)
	ItemSocketingScrollFrameScrollBar:Point("BOTTOMLEFT", ItemSocketingScrollFrame, "BOTTOMRIGHT", 6, 17)

	S:HandleButton(ItemSocketingSocketButton)
	ItemSocketingSocketButton:Point("BOTTOMRIGHT", -10, 39)

	for i = 1, MAX_NUM_SOCKETS do
		local button = _G["ItemSocketingSocket"..i]
		local bracket = _G["ItemSocketingSocket"..i.."BracketFrame"]
		local bg = _G["ItemSocketingSocket"..i.."Background"]
		local icon = _G["ItemSocketingSocket"..i.."IconTexture"]
		local shine = _G["ItemSocketingSocket"..i.."Shine"]

		button:StripTextures()
		button:StyleButton(false)
		button:SetTemplate("Default", true)

		bracket:Kill()
		bg:Kill()

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()

		shine:Point("CENTER")
		shine:Size(40)
	end

	local GEM_TYPE_INFO = GEM_TYPE_INFO

	hooksecurefunc("ItemSocketingFrame_Update", function()
		local numSockets = GetNumSockets()

		for i = 1, numSockets do
			local button = _G["ItemSocketingSocket"..i]
			local color = GEM_TYPE_INFO[GetSocketTypes(i)]
			button:SetBackdropColor(color.r, color.g, color.b, 0.15)
			button:SetBackdropBorderColor(color.r, color.g, color.b)
		end

		if numSockets == 3 then
			ItemSocketingSocket1:SetPoint("BOTTOM", -80, 70)
		elseif numSockets == 2 then
			ItemSocketingSocket1:SetPoint("BOTTOM", -36, 70)
		else
			ItemSocketingSocket1:SetPoint("BOTTOM", 0, 70)
		end
	end)

	hooksecurefunc(ItemSocketingScrollFrame, "SetWidth", function(self, width)
		if width == 269 then
			self:Width(300)
		elseif width == 297 then
			self:Width(321)
		end
	end)
end)