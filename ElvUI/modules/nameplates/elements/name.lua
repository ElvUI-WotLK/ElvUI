local E, L, V, P, G = unpack(select(2, ...));
local mod = E:GetModule("NamePlates");
local LSM = LibStub("LibSharedMedia-3.0");

function mod:ConfigureElement_Name(frame)
	local name = frame.Name;
	name:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline);
end

function mod:ConstructElement_Name(frame)
	local name = frame:CreateFontString(nil, "OVERLAY");
	name:SetJustifyH("LEFT");
	name:SetJustifyV("BOTTOM");
	name:SetPoint("BOTTOMLEFT", frame.HealthBar, "TOPLEFT", 0, E.Border*2);
	name:SetPoint("BOTTOMRIGHT", frame.Level, "BOTTOMLEFT");
	name:SetWordWrap(false);
	return name;
end