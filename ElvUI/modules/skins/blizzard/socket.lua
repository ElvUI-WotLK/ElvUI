local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

local _G = _G;
local format = format;

local GetNumSockets = GetNumSockets;
local GetSocketTypes = GetSocketTypes;

local function LoadSkin()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.socket ~= true) then return; end

	ItemSocketingFrame:StripTextures();
	ItemSocketingFrame:CreateBackdrop("Transparent");
	ItemSocketingFrame.backdrop:Point("TOPLEFT", 11, -12);
	ItemSocketingFrame.backdrop:Point("BOTTOMRIGHT", -4, 27);

	ItemSocketingFramePortrait:Kill();

	S:HandleCloseButton(ItemSocketingCloseButton);

	ItemSocketingScrollFrame:StripTextures();
	ItemSocketingScrollFrame:CreateBackdrop("Transparent");

	S:HandleScrollBar(ItemSocketingScrollFrameScrollBar, 2);

	for i = 1, MAX_NUM_SOCKETS do
		local button = _G[("ItemSocketingSocket%d"):format(i)];
		local button_bracket = _G[("ItemSocketingSocket%dBracketFrame"):format(i)];
		local button_bg = _G[("ItemSocketingSocket%dBackground"):format(i)];
		local button_icon = _G[("ItemSocketingSocket%dIconTexture"):format(i)];
		button:StripTextures();
		button:StyleButton(false);
		button:SetTemplate("Default", true);
		button_bracket:Kill();
		button_bg:Kill();
		button_icon:SetTexCoord(unpack(E.TexCoords));
		button_icon:SetInside();
	end

	hooksecurefunc("ItemSocketingFrame_Update", function()
		local numSockets = GetNumSockets();
		for i = 1, numSockets do
			local button = _G[("ItemSocketingSocket%d"):format(i)];
			local gemColor = GetSocketTypes(i);
			local color = GEM_TYPE_INFO[gemColor];
			button:SetBackdropColor(color.r, color.g, color.b, 0.15);
			button:SetBackdropBorderColor(color.r, color.g, color.b);
		end
	end);

	S:HandleButton(ItemSocketingSocketButton);
end

S:AddCallbackForAddon("Blizzard_ItemSocketingUI", "ItemSocket", LoadSkin);