local E, L = unpack(select(2, ...)); --Import: Engine, Locales
local B = E:GetModule("Blizzard")

--Lua functions
--WoW API / Variables

function B:KillBlizzard()
	VideoOptionsResolutionPanelUseUIScale:Kill()
	VideoOptionsResolutionPanelUIScaleSlider:Kill()
end