local E, L, V, P, G = unpack(select(2, ...));
local mod = E:GetModule("NamePlates");
local LSM = LibStub("LibSharedMedia-3.0");

function mod:ConfigureElement_Level(frame)
	local level = frame.Level;
	level:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline);
end

function mod:ConstructElement_Level(frame)
	local level = frame:CreateFontString(nil, "OVERLAY");
	level:SetJustifyH("RIGHT");
	level:SetPoint("BOTTOMRIGHT", frame.HealthBar, "TOPRIGHT", 0, E.Border*2);
	return level;
end