local E, L, V, P, G = unpack(select(2, ...))
local UF = E:GetModule("UnitFrames")

function UF:Construct_ResurrectionIcon(frame)
	local tex = frame.RaisedElementParent.TextureParent:CreateTexture(nil, "OVERLAY")
	tex:SetTexture([[Interface\AddOns\ElvUI\media\textures\Raid-Icon-Rez]])
	tex:Size(30, 25)
	tex:Point("CENTER", frame.Health.value, "CENTER")
	tex:Hide()

	return tex
end

function UF:Configure_ResurrectionIcon(frame)
	if frame.db.resurrect then
		if not frame:IsElementEnabled("ResurrectIndicator") then
			frame:EnableElement("ResurrectIndicator")
		end
	else
		if frame:IsElementEnabled("ResurrectIndicator") then
			frame:DisableElement("ResurrectIndicator")
		end
	end
end