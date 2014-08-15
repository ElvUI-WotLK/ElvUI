local E, L, V, P, G = unpack(select(2, ...));
local B = E:NewModule('Blizzard', 'AceEvent-3.0', 'AceHook-3.0');

E.Blizzard = B;

function B:Initialize()
	self:AlertMovers();
	self:EnhanceColorPicker();
	self:KillBlizzard();
	self:PositionCaptureBar();
	self:PositionDurabilityFrame();
	self:PositionGMFrames();
	self:PositionVehicleFrame();
	self:MoveWatchFrame();	
end

E:RegisterModule(B:GetName());