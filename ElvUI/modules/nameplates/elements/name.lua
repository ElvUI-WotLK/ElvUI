local E, L, V, P, G = unpack(select(2, ...));
local mod = E:GetModule("NamePlates")
local LSM = LibStub("LibSharedMedia-3.0")

function mod:ConfigureElement_Name(frame)
	local name = frame.Name;

	name:SetJustifyH("LEFT");
	name:ClearAllPoints();
	if(self.db.healthBar.enable or frame.isTarget) then
		name:SetJustifyH("LEFT")
		name:SetPoint("BOTTOMLEFT", frame.HealthBar, "TOPLEFT", 0, E.Border*2);
		name:SetPoint("BOTTOMRIGHT", frame.Level, "BOTTOMLEFT");
	else
		name:SetJustifyH("CENTER");
		name:SetPoint("TOP", frame);
	end
end

function mod:ConstructElement_Name(frame)
	return frame:CreateFontString(nil, "OVERLAY");
end