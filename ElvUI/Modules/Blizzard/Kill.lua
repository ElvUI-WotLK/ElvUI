local E, L = unpack(select(2, ...)); --Import: Engine, Locales
local B = E:GetModule("Blizzard")

function B:KillBlizzard()
	VideoOptionsResolutionPanelUseUIScale:Kill()
	VideoOptionsResolutionPanelUIScaleSlider:Kill()
end