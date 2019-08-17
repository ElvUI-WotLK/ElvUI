local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule("UnitFrames")

--Lua functions
--WoW API / Variables

function UF:Construct_ResurrectionIcon(frame)
	local tex = frame.RaisedElementParent.TextureParent:CreateTexture(nil, "OVERLAY")
	tex:SetTexture([[Interface\AddOns\ElvUI\media\textures\Raid-Icon-Rez]])
	tex:Point("CENTER", frame.Health, "CENTER")
	tex:Size(30)
	tex:Hide()

	return tex
end

function UF:Configure_ResurrectionIcon(frame)
	local RI = frame.ResurrectIndicator
	local db = frame.db

	if db.resurrectIcon.enable then
		if not frame:IsElementEnabled("ResurrectIndicator") then
			frame:EnableElement("ResurrectIndicator")
		end
		RI:Size(db.resurrectIcon.size)

		local attachPoint = self:GetObjectAnchorPoint(frame, db.resurrectIcon.attachToObject)
		RI:ClearAllPoints()
		RI:Point(db.resurrectIcon.attachTo, attachPoint, db.resurrectIcon.attachTo, db.resurrectIcon.xOffset, db.resurrectIcon.yOffset)
	else
		if frame:IsElementEnabled("ResurrectIndicator") then
			frame:DisableElement("ResurrectIndicator")
		end
	end
end