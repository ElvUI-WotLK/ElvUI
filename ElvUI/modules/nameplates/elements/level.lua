local E, L, V, P, G = unpack(select(2, ...));
local mod = E:GetModule("NamePlates");
local LSM = LibStub("LibSharedMedia-3.0");

function mod:ConfigureElement_Level(frame)
	local level = frame.level;

	level:ClearAllPoints();

	if(self.db.healthBar.enable or frame.isTarget) then
		level:SetJustifyH("RIGHT");
		level:SetPoint("BOTTOMRIGHT", frame.healthBar, "TOPRIGHT", 0, E.Border*2);
	else
		level:SetPoint("LEFT", frame.name, "RIGHT");
		level:SetJustifyH("LEFT");
	end
	level:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline);
end

function mod:ConstructElement_Level(frame)
	return frame:CreateFontString(nil, "OVERLAY");
end