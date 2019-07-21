local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

local function LoadSkin()
	if(E.private.skins.blizzard.enable ~= true
		or E.private.skins.blizzard.binding ~= true)
	then
		return;
	end

	KeyBindingFrame:CreateBackdrop("Transparent");
	KeyBindingFrame.backdrop:Point("TOPLEFT", 2, 0);
	KeyBindingFrame.backdrop:Point("BOTTOMRIGHT", -42, 12);

	KeyBindingFrame:StripTextures();

	local bindingKey1, bindingKey2;
	for i = 1, KEY_BINDINGS_DISPLAYED do
		bindingKey1 = _G["KeyBindingFrameBinding"..i.."Key1Button"];
		bindingKey2 = _G["KeyBindingFrameBinding"..i.."Key2Button"];

		S:HandleButton(bindingKey1);
		S:HandleButton(bindingKey2);
		bindingKey2:SetPoint("LEFT", bindingKey1, "RIGHT", 1, 0);
	end

	S:HandleScrollBar(KeyBindingFrameScrollFrameScrollBar);

	S:HandleCheckBox(KeyBindingFrameCharacterButton);

	S:HandleButton(KeyBindingFrameDefaultButton);
	S:HandleButton(KeyBindingFrameCancelButton);
	S:HandleButton(KeyBindingFrameOkayButton);
	KeyBindingFrameOkayButton:Point("RIGHT", KeyBindingFrameCancelButton, "LEFT", -3, 0);
	S:HandleButton(KeyBindingFrameUnbindButton);
	KeyBindingFrameUnbindButton:Point("RIGHT", KeyBindingFrameOkayButton, "LEFT", -3, 0);
end

S:AddCallbackForAddon("Blizzard_BindingUI", "Binding", LoadSkin);