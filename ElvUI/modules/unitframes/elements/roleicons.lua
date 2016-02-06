local E, L, V, P, G = unpack(select(2, ...));
local UF = E:GetModule("UnitFrames");

local CreateFrame = CreateFrame;

function UF:Construct_RoleIcon(frame)
	local f = CreateFrame("Frame", nil, frame);
	
	local tex = f:CreateTexture(nil, "ARTWORK");
	tex:Size(17);
	tex:Point("BOTTOM", frame.Health, "BOTTOM", 0, 2);
	
	return tex;
end

function UF:Configure_RoleIcon(frame)
	local role = frame.LFDRole;
	if(frame.db.roleIcon.enable) then
		frame:EnableElement("LFDRole");
		
		local x, y = self:GetPositionOffset(frame.db.roleIcon.position, 1);
		role:ClearAllPoints();
		role:Point(frame.db.roleIcon.position, frame.Health, frame.db.roleIcon.position, x, y);
		role:Size(frame.db.roleIcon.size);
	else
		frame:DisableElement("LFDRole");
		role:Hide();
	end
end