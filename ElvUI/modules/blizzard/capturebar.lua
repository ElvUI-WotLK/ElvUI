local E, L, DF = unpack(select(2, ...));
local B = E:GetModule("Blizzard");

local _G = _G;

function B:WorldStateAlwaysUpFrame_Update()
	local captureBar;
	for i = 1, NUM_EXTENDED_UI_FRAMES do
		captureBar = _G["WorldStateCaptureBar" .. i];
		if(captureBar and captureBar:IsShown()) then
			captureBar:ClearAllPoints();
			captureBar:Point("TOP", E.UIParent, "TOP", 0, -170);
		end
	end
end

function B:PositionCaptureBar()
	self:SecureHook("WorldStateAlwaysUpFrame_Update");
end