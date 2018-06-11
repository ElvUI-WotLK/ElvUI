local E, L, DF = unpack(select(2, ...))
local B = E:GetModule("Blizzard")

local _G = _G

local pvpHolder = CreateFrame("Frame", "PvPHolder", E.UIParent)

function B:WorldStateAlwaysUpFrame_Update()
	local captureBar
	for i = 1, NUM_EXTENDED_UI_FRAMES do
		captureBar = _G["WorldStateCaptureBar"..i]
		if captureBar and captureBar:IsShown() then
			captureBar:ClearAllPoints()
			captureBar:Point("TOP", pvpHolder, "BOTTOM", 0, -50)
		end
	end

	if AlwaysUpFrame1 then
		AlwaysUpFrame1:ClearAllPoints()
		AlwaysUpFrame1:Point("CENTER", pvpHolder, "CENTER", -25, 0)
	end
	if AlwaysUpFrame2 then
		AlwaysUpFrame2:Point("TOP", AlwaysUpFrame1, "BOTTOM", 0, -5)
	end
end

function B:PositionCaptureBar()
	self:SecureHook("WorldStateAlwaysUpFrame_Update")

	pvpHolder:Size(30, 70)
	pvpHolder:Point("TOP", E.UIParent, "TOP", 0, -4)

	E:CreateMover(pvpHolder, "PvPMover", L["PvP"], nil, nil, nil, "ALL")
end