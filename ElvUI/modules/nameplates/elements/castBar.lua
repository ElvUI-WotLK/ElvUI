local E, L, V, P, G = unpack(select(2, ...));
local mod = E:GetModule("NamePlates");

local unpack = unpack;

local CreateFrame = CreateFrame;

function mod:ConstructElement_CastBar(parent)
	local frame = CreateFrame("StatusBar", "$parentCastBar", parent);
	frame:SetPoint("TOPLEFT", parent.HealthBar, "BOTTOMLEFT", 0, -E.Border - E.Spacing*3);
	frame:SetPoint("TOPRIGHT", parent.HealthBar, "BOTTOMRIGHT", 0, -E.Border - E.Spacing*3);
	self:CreateBackdrop(frame);

	frame.Icon = CreateFrame("Frame", nil, frame);
	frame.Icon:SetPoint("TOPLEFT", parent.HealthBar, "TOPRIGHT", E.Border + E.Spacing*3, 0)
	frame.Icon:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", E.Border + E.Spacing*3, 0)
	frame.Icon.texture = frame.Icon:CreateTexture(nil, "BORDER");
	frame.Icon.texture:SetAllPoints();
	frame.Icon.texture:SetTexCoord(unpack(E.TexCoords));
	self:CreateBackdrop(frame.Icon);

	frame.Time = frame:CreateFontString(nil, "OVERLAY");
	frame.Time:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, -E.Border*3);
	frame.Time:SetJustifyH("RIGHT");
	frame.Time:SetJustifyV("TOP");
	frame.Time:SetWordWrap(false);

	frame.Spark = frame:CreateTexture(nil, "OVERLAY");
	frame.Spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]]);
	frame.Spark:SetBlendMode("ADD");
	frame.Spark:SetSize(15, 15);
	frame:Hide();
	return frame;
end