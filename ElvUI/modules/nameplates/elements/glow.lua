local E, L, V, P, G = unpack(select(2, ...))
local mod = E:GetModule("NamePlates")
local LSM = LibStub("LibSharedMedia-3.0")

local CreateFrame = CreateFrame

function mod:UpdateElement_Glow(frame)
	if frame.TopArrow:IsShown() then frame.TopArrow:Hide() end
	if frame.LeftArrow:IsShown() then frame.LeftArrow:Hide() end
	if frame.RightArrow:IsShown() then frame.RightArrow:Hide() end
	if frame.Glow2:IsShown() then frame.Glow2:Hide() end
	if frame.Glow:IsShown() then frame.Glow:Hide() end
	if not frame.HealthBar:IsShown() then return end

	local scale, shouldShow, r, g, b, a = 1, 0
	if frame.isTarget and self.db.targetGlow ~= "none" then
		r, g, b, a = self.db.glowColor.r, self.db.glowColor.g, self.db.glowColor.b, self.db.glowColor.a
		shouldShow = 1
	elseif self.db.lowHealthThreshold > 0 then
		local health = frame.oldHealthBar:GetValue()
		local _, maxHealth = frame.oldHealthBar:GetMinMaxValues()
		local perc = health / maxHealth
		if perc <= self.db.lowHealthThreshold then
			if perc <= self.db.lowHealthThreshold / 2 then
				r, g, b, a = 1, 0, 0, 1
			else
				r, g, b, a = 1, 1, 0, 1
			end

			shouldShow = 2
		end
	end

	--[[
		style1:"Border",
		style2:"Background",
		style3:"Top Arrow Only",
		style4:"Side Arrows Only",
		style5:"Border + Top Arrow",
		style6:"Background + Top Arrow",
		style7:"Border + Side Arrows",
		style8:"Background + Side Arrows"
	]]
	if shouldShow ~= 0 then
		if self.db.targetGlow == "style1" or self.db.targetGlow == "style5" or self.db.targetGlow == "style7" then -- original glow
			frame.Glow:Show()
		end
		if self.db.targetGlow == "style2" or self.db.targetGlow == "style6" or self.db.targetGlow == "style8" then -- new background glow
			frame.Glow2:Show()
			if self.db.useTargetScale then
				if self.db.targetScale >= 0.75 then
					scale = self.db.targetScale
				else
					scale = 0.75
				end
			end
			local size = (E.Border*10)*scale;
			frame.Glow2:SetPoint("TOPLEFT", frame.HealthBar, "TOPLEFT", -E:Scale(size*2), E:Scale(size))
			frame.Glow2:SetPoint("BOTTOMRIGHT", frame.HealthBar, "BOTTOMRIGHT", E:Scale(size*2), -E:Scale(size))
		end
		if shouldShow ~= 2 and (self.db.targetGlow == "style3" or self.db.targetGlow == "style5" or self.db.targetGlow == "style6") then -- top arrow
			frame.TopArrow:SetPoint("BOTTOM", frame.HealthBar, "TOP", 0, E:Scale(E.Border*2))
			frame.TopArrow:Show()
		end
		if shouldShow ~= 2 and (self.db.targetGlow == "style4" or self.db.targetGlow == "style7" or self.db.targetGlow == "style8") then -- side arrows
			frame.RightArrow:SetPoint("RIGHT", frame.HealthBar, "LEFT", E:Scale(E.Border*2), 0)
			frame.LeftArrow:SetPoint("LEFT", frame.HealthBar, "RIGHT", -E:Scale(E.Border*2), 0)
			frame.RightArrow:Show()
			frame.LeftArrow:Show()
		end
		if r ~= frame.Glow.r or g ~= frame.Glow.g or b ~= frame.Glow.b or a ~= frame.Glow.a then
			frame.Glow:SetBackdropBorderColor(r, g, b, a);
			frame.Glow2:SetVertexColor(r, g, b, a);
			frame.TopArrow:SetVertexColor(r, g, b, a);
			frame.LeftArrow:SetVertexColor(r, g, b, a);
			frame.RightArrow:SetVertexColor(r, g, b, a);
			frame.Glow.r, frame.Glow.g, frame.Glow.b, frame.Glow.a = r, g, b, a;
		end
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

	local glow = frame:CreateTexture(nil, "BACKGROUND")
	glow:SetTexture([[Interface\AddOns\ElvUI\media\textures\spark.tga]])
	glow:Hide()
	frame.Glow2 = glow

	local top = frame:CreateTexture(nil, "BACKGROUND")
	top:SetTexture([[Interface\AddOns\ElvUI\media\textures\nameplateTargetIndicator.tga]])
	top:Size(45)
	top:Hide()
	frame.TopArrow = top

	local left = frame:CreateTexture(nil, "BACKGROUND")
	left:SetTexture([[Interface\AddOns\ElvUI\media\textures\nameplateTargetIndicatorLeft.tga]])
	left:Size(45)
	left:Hide()
	frame.LeftArrow = left

	local right = frame:CreateTexture(nil, "BACKGROUND")
	right:SetTexture([[Interface\AddOns\ElvUI\media\textures\nameplateTargetIndicatorRight.tga]])
	right:Size(45)
	right:Hide()
	frame.RightArrow = right

	return f
end