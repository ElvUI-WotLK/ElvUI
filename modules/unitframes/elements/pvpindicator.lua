local E, L, V, P, G = unpack(select(2, ...));
local UF = E:GetModule("UnitFrames");

function UF:Construct_PvPIndicator(frame)
	local pvp = frame.RaisedElementParent:CreateFontString(nil, "OVERLAY");
	UF:Configure_FontString(pvp);

	return pvp;
end

function UF:Configure_PVPIndicator(frame)
	local pvp = frame.PvPText;
	local x, y = self:GetPositionOffset(frame.db.pvp.position);
	pvp:ClearAllPoints();
	pvp:Point(frame.db.pvp.position, frame.Health, frame.db.pvp.position, x, y);

	frame:Tag(pvp, frame.db.pvp.text_format);
end