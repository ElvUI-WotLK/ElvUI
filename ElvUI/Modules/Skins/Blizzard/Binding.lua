local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
--WoW API / Variables

S:AddCallbackForAddon("Blizzard_BindingUI", "Skin_Blizzard_BindingUI", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.binding then return end

	KeyBindingFrame:StripTextures()
	KeyBindingFrame:SetTemplate("Transparent")
	KeyBindingFrame:Size(596, 490)

	local bindingKey1, bindingKey2
	for i = 1, KEY_BINDINGS_DISPLAYED do
		bindingKey1 = _G["KeyBindingFrameBinding"..i.."Key1Button"]
		bindingKey2 = _G["KeyBindingFrameBinding"..i.."Key2Button"]

		S:HandleButton(bindingKey1)
		S:HandleButton(bindingKey2)
		bindingKey2:SetPoint("LEFT", bindingKey1, "RIGHT", 1, 0)
	end

	S:HandleScrollBar(KeyBindingFrameScrollFrameScrollBar)

	S:HandleCheckBox(KeyBindingFrameCharacterButton)

	S:HandleButton(KeyBindingFrameDefaultButton)
	S:HandleButton(KeyBindingFrameCancelButton)
	S:HandleButton(KeyBindingFrameOkayButton)
	S:HandleButton(KeyBindingFrameUnbindButton)

	KeyBindingFrameCharacterButton:Point("TOPLEFT", KeyBindingFrame, "TOPRIGHT", -204, -12)

	KeyBindingFrameScrollFrameScrollBar:Point("TOPLEFT", KeyBindingFrameScrollFrame, "TOPRIGHT", 8, -21)
	KeyBindingFrameScrollFrameScrollBar:Point("BOTTOMLEFT", KeyBindingFrameScrollFrame, "BOTTOMRIGHT", 8, 17)

	KeyBindingFrameDefaultButton:Point("BOTTOMLEFT", 8, 8)
	KeyBindingFrameCancelButton:Point("BOTTOMRIGHT", -8, 8)
	KeyBindingFrameOkayButton:Point("RIGHT", KeyBindingFrameCancelButton, "LEFT", -3, 0)
	KeyBindingFrameUnbindButton:Point("RIGHT", KeyBindingFrameOkayButton, "LEFT", -3, 0)
end)