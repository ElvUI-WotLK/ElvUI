local E, L, V, P, G = unpack(select(2, ...))
local UF = E:GetModule("UnitFrames")

function UF:Construct_ResurrectionIcon(frame)
	local tex = frame.RaisedElementParent.TextureParent:CreateTexture(nil, "OVERLAY")
	tex:SetTexture([[Interface\AddOns\ElvUI\media\textures\Raid-Icon-Rez]])
	tex:Point("CENTER", frame.Health, "CENTER")
	tex:Size(30)
	tex:SetDrawLayer("OVERLAY", 7)

	return tex
end

function UF:Configure_ResurrectionIcon(frame)
	local RI = frame.ResurrectIndicator
	local db = frame.db

	if frame.db.resurrect then
		if not frame:IsElementEnabled("ResurrectIndicator") then
			frame:EnableElement("ResurrectIndicator")
		end
		RI:Show()
		RI:Size(db.resurrectIcon.size)

		local attachPoint = self:GetObjectAnchorPoint(frame, db.resurrectIcon.attachToObject)
		RI:ClearAllPoints()
		RI:Point(db.resurrectIcon.attachTo, attachPoint, db.resurrectIcon.attachTo, db.resurrectIcon.xOffset, db.resurrectIcon.yOffset)
	else
		if frame:IsElementEnabled("ResurrectIndicator") then
			frame:DisableElement("ResurrectIndicator")
		end
		RI:Hide()
	end
end