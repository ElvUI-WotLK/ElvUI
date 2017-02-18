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
			captureBar:SetPoint("TOP", WorldStateAlwaysUpFrame, "BOTTOM", 0, -50)
		end
	end

	WorldStateAlwaysUpFrame:ClearAllPoints()
	WorldStateAlwaysUpFrame:SetPoint("CENTER", pvpHolder, "CENTER", 0, 10)

	local alwaysUpShown = 1
	local frame = "AlwaysUpFrame"..alwaysUpShown
	local offset = 0

	for i = alwaysUpShown, NUM_ALWAYS_UP_UI_FRAMES do
		frame = _G["AlwaysUpFrame"..i]
		frameText = _G["AlwaysUpFrame"..i.."Text"]
		frameIcon = _G["AlwaysUpFrame"..i.."Icon"]
		frameIcon2 = _G["AlwaysUpFrame"..i.."DynamicIconButton"]

		frame:ClearAllPoints()
		frameText:ClearAllPoints()
		frameIcon:ClearAllPoints()
		frameIcon2:ClearAllPoints()

		frameText:SetPoint("CENTER", WorldStateAlwaysUpFrame, "CENTER", 0, offset)
		frameText:SetJustifyH("CENTER")
		frameIcon:SetPoint("CENTER", frameText, "LEFT", -7, -9)
		frameIcon:Size(38)
		frameIcon2:SetPoint("LEFT", frameText, "RIGHT", 5, 0)
		frameIcon2:Size(38)

		offset = offset - 25
	end
end

function B:PositionCaptureBar()
	self:SecureHook("WorldStateAlwaysUpFrame_Update");
	pvpHolder:SetSize(30, 70)
	pvpHolder:SetPoint("TOP", E.UIParent, "TOP", 0, -4)
	E:CreateMover(pvpHolder, "PvPMover", L["PvP"], nil, nil, nil, "ALL")
end