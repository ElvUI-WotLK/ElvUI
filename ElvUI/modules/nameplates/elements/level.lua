local E, L, V, P, G = unpack(select(2, ...));
local mod = E:GetModule("NamePlates");
local LSM = LibStub("LibSharedMedia-3.0");

function mod:ConfigureElement_Level(frame)
	local level = frame.Level;

	level:ClearAllPoints();
	if(self.db.healthBar.enable or frame.isTarget) then
		level:SetJustifyH("RIGHT");
		level:SetPoint("BOTTOMRIGHT", frame.HealthBar, "TOPRIGHT", 0, E.Border*2);
	else
		level:SetPoint("LEFT", frame.Name, "RIGHT");
		level:SetJustifyH("LEFT");
	end
end

function mod:ConstructElement_Level(frame)
	return frame:CreateFontString(nil, "OVERLAY");
end