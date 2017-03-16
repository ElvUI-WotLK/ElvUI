local E, L, V, P, G = unpack(select(2, ...))
local mod = E:GetModule("NamePlates")
local LSM = LibStub("LibSharedMedia-3.0")

local CreateFrame = CreateFrame

function mod:UpdateElement_Glow(frame)
	if not frame.HealthBar:IsShown() then return end

	local r, g, b, shouldShow
	if frame.isTarget and self.db.useTargetGlow then
		r, g, b = 1, 1, 1
		shouldShow = true
	else
		local health = frame.oldHealthBar:GetValue()
		local _, maxHealth = frame.oldHealthBar:GetMinMaxValues()
		local perc = health / maxHealth
		if perc <= self.db.lowHealthThreshold then
			if perc <= self.db.lowHealthThreshold / 2 then
				r, g, b = 1, 0, 0
			else
				r, g, b = 1, 1, 0
			end

			shouldShow = true
		end
	end

	if shouldShow then
		frame.Glow:Show()
		if r ~= frame.Glow.r or g ~= frame.Glow.g or b ~= frame.Glow.b then
			frame.Glow:SetBackdropBorderColor(r, g, b)
			frame.Glow.r, frame.Glow.g, frame.Glow.b = r, g, b
		end
	elseif frame.Glow:IsShown() then
		frame.Glow:Hide()
	end
end

function mod:ConfigureElement_Glow(frame)

end

function mod:ConstructElement_Glow(frame)
	local f = CreateFrame("Frame", nil, frame)
	f:SetFrameLevel(frame.HealthBar:GetFrameLevel() - 1)
	f:SetOutside(frame.HealthBar, 3, 3)
	f:SetBackdrop({
		edgeFile = LSM:Fetch("border", "ElvUI GlowBorder"), edgeSize = E:Scale(3),
		insets = {left = E:Scale(5), right = E:Scale(5), top = E:Scale(5), bottom = E:Scale(5)}
	})

	f:SetScale(E.PixelMode and 1.5 or 2)
	f:Hide()
	return f
end