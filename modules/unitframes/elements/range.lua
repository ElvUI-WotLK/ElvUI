local E, L, V, P, G = unpack(select(2, ...));
local UF = E:GetModule("UnitFrames");

function UF:Construct_Range(frame)
	return {insideAlpha = 1, outsideAlpha = E.db.unitframe.OORAlpha};
end

function UF:Configure_Range(frame)
	local range = frame.Range;
	if(frame.db.rangeCheck) then
		if(not frame:IsElementEnabled("Range")) then
			frame:EnableElement("Range");
		end

		range.outsideAlpha = E.db.unitframe.OORAlpha;
	else
		if(frame:IsElementEnabled("Range")) then
			frame:DisableElement("Range");
		end
	end
end