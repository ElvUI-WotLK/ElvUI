local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
--WoW API / Variables

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.binding then return end

	KeyBindingFrame:StripTextures()
	KeyBindingFrame:CreateBackdrop("Transparent")
	KeyBindingFrame.backdrop:Point("TOPLEFT", 2, 0)
	KeyBindingFrame.backdrop:Point("BOTTOMRIGHT", -42, 13)

	S:SetBackdropHitRect(KeyBindingFrame)

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

	KeyBindingFrameOkayButton:Point("RIGHT", KeyBindingFrameCancelButton, "LEFT", -3, 0)
	KeyBindingFrameUnbindButton:Point("RIGHT", KeyBindingFrameOkayButton, "LEFT", -3, 0)
end

S:AddCallbackForAddon("Blizzard_BindingUI", "Skin_Blizzard_BindingUI", LoadSkin)