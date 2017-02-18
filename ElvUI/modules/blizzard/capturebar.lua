local E, L, DF = unpack(select(2, ...));
local B = E:GetModule("Blizzard");

local _G = _G;

local pvpHolder = CreateFrame("Frame", "PvPHolder", E.UIParent)

function B:WorldStateAlwaysUpFrame_Update()
	local captureBar;
	for i = 1, NUM_EXTENDED_UI_FRAMES do
		captureBar = _G["WorldStateCaptureBar" .. i];
		if(captureBar and captureBar:IsShown()) then
			captureBar:ClearAllPoints();
			captureBar:Point("TOP", WorldStateAlwaysUpFrame, "BOTTOM", 0, -80)
		end
	end

	WorldStateAlwaysUpFrame:ClearAllPoints()
	WorldStateAlwaysUpFrame:Point("CENTER", pvpHolder, "CENTER", 0, 10)

	local offset = 0

	for i = 1, NUM_ALWAYS_UP_UI_FRAMES do
		local frameText = _G["AlwaysUpFrame"..i.."Text"]
		local frameIcon = _G["AlwaysUpFrame"..i.."Icon"]
		local frameIcon2 = _G["AlwaysUpFrame"..i.."DynamicIconButton"]

		frameText:ClearAllPoints()
		frameText:Point("CENTER", WorldStateAlwaysUpFrame, "CENTER", 0, offset)
		frameText:SetJustifyH("CENTER")

		frameIcon:ClearAllPoints()
		frameIcon:Point("CENTER", frameText, "LEFT", -7, -9)
		frameIcon:Size(38)

		frameIcon2:ClearAllPoints()
		frameIcon2:Point("LEFT", frameText, "RIGHT", 5, 0)
		frameIcon2:Size(38)

		offset = offset - 25
	end
end

function B:PositionCaptureBar()
	self:SecureHook("WorldStateAlwaysUpFrame_Update");

	pvpHolder:Size(30, 70)
	pvpHolder:Point("TOP", E.UIParent, "TOP", 0, -4)

	E:CreateMover(pvpHolder, "PvPMover", L["PvP"], nil, nil, nil, "ALL")
end