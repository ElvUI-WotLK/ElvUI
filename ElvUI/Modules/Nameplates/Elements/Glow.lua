local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule("NamePlates")
local LSM = E.Libs.LSM

--Lua functions
local ipairs = ipairs
--WoW API / Variables
local CreateFrame = CreateFrame

--[[
Target Glow Style Option Variables
	style1 - Border
	style2 - Background
	style3 - Top Arrow Only
	style4 - Side Arrows Only
	style5 - Border + Top Arrow
	style6 - Background + Top Arrow
	style7 - Border + Side Arrows
	style8 - Background + Side Arrows
]]

function NP:Update_Glow(frame)
	local showIndicator

	if frame.isTarget then
		showIndicator = 1
	elseif self.db.lowHealthThreshold > 0 then
		local health = frame.oldHealthBar:GetValue()
		local _, maxHealth = frame.oldHealthBar:GetMinMaxValues()
		local perc = health / maxHealth

		if health > 1 and perc <= self.db.lowHealthThreshold then
			if perc <= self.db.lowHealthThreshold / 2 then
				showIndicator = 2
			else
				showIndicator = 3
			end
		end
	end

	local glowStyle = self.db.units.TARGET.glowStyle
	local healthIsShown = frame.Health:IsShown()
	local nameExists = frame.Name:IsShown() and frame.Name:GetText() ~= nil

	if not healthIsShown and not frame.IconOnlyChanged and nameExists then
		if glowStyle == "style1" then
			glowStyle = "none"
		elseif glowStyle == "style5" then
			glowStyle = "style3"
		elseif glowStyle == "style7" then
			glowStyle = "style4"
		end
	end

	if showIndicator and glowStyle ~= "none" then
		local r, g, b

		if showIndicator == 1 then
			local color = self.db.colors.glowColor
			r, g, b = color.r, color.g, color.b
		elseif showIndicator == 2 then
			r, g, b = 1, 0, 0
		else
			r, g, b = 1, 1, 0
		end

		-- Indicators
		frame.TopIndicator:SetVertexColor(r, g, b)
		frame.LeftIndicator:SetVertexColor(r, g, b)
		frame.RightIndicator:SetVertexColor(r, g, b)

		if glowStyle == "style3" or glowStyle == "style5" or glowStyle == "style6" then
			frame.LeftIndicator:Hide()
			frame.RightIndicator:Hide()

			if healthIsShown or frame.IconOnlyChanged or nameExists then
				frame.TopIndicator:Show()
			end
		elseif glowStyle == "style4" or glowStyle == "style7" or glowStyle == "style8" then
			frame.TopIndicator:Hide()

			if healthIsShown or frame.IconOnlyChanged or nameExists then
				frame.LeftIndicator:Show()
				frame.RightIndicator:Show()
			end
		end

		-- Spark / Shadow
		frame.Shadow:SetBackdropBorderColor(r, g, b)
		frame.Spark:SetVertexColor(r, g, b)

		if glowStyle == "style1" or glowStyle == "style5" or glowStyle == "style7" then
			frame.Spark:Hide()

			if healthIsShown or frame.IconOnlyChanged then
				frame.Shadow:Show()
			end
		elseif glowStyle == "style2" or glowStyle == "style6" or glowStyle == "style8" then
			frame.Shadow:Hide()

			if healthIsShown or frame.IconOnlyChanged or nameExists then
				frame.Spark:Show()
			end
		elseif glowStyle == "style3" or glowStyle == "style4" then
			frame.Shadow:Hide()
			frame.Spark:Hide()
		end
	else
		frame.TopIndicator:Hide()
		frame.LeftIndicator:Hide()
		frame.RightIndicator:Hide()
		frame.Shadow:Hide()
		frame.Spark:Hide()
	end
end

function NP:Configure_Glow(frame)
	local glowStyle = self.db.units.TARGET.glowStyle
	local healthIsShown = frame.Health:IsShown()
	local nameExists = frame.Name:IsShown() and frame.Name:GetText() ~= nil

	if not healthIsShown and not frame.IconOnlyChanged and nameExists then
		if glowStyle == "style1" then
			glowStyle = "none"
		elseif glowStyle == "style5" then
			glowStyle = "style3"
		elseif glowStyle == "style7" then
			glowStyle = "style4"
		end
	end

	if glowStyle ~= "none" then
		local color = self.db.colors.glowColor
		local arrowSize = NP.db.units.TARGET.arrowSize
		local arrowXOffset, arrowYOffset = NP.db.units.TARGET.arrowXOffset, NP.db.units.TARGET.arrowYOffset
		local r, g, b, a = color.r, color.g, color.b, color.a

		-- Indicators
		frame.LeftIndicator:SetTexture(E.Media.Arrows[NP.db.units.TARGET.arrow])
		frame.LeftIndicator:SetVertexColor(r, g, b)
		frame.LeftIndicator:SetSize(arrowSize, arrowSize)

		frame.RightIndicator:SetTexture(E.Media.Arrows[NP.db.units.TARGET.arrow])
		frame.RightIndicator:SetVertexColor(r, g, b)
		frame.RightIndicator:SetSize(arrowSize, arrowSize)

		frame.TopIndicator:SetTexture(E.Media.Arrows[NP.db.units.TARGET.arrow])
		frame.TopIndicator:SetVertexColor(r, g, b)
		frame.TopIndicator:SetSize(arrowSize, arrowSize)

		frame.TopIndicator:ClearAllPoints()
		frame.LeftIndicator:ClearAllPoints()
		frame.RightIndicator:ClearAllPoints()

		if glowStyle == "style3" or glowStyle == "style5" or glowStyle == "style6" then
			if frame.IconOnlyChanged then
				frame.TopIndicator:SetPoint("BOTTOM", frame.IconFrame, "TOP", arrowXOffset, arrowYOffset)
			else
				if healthIsShown then
					frame.TopIndicator:SetPoint("BOTTOM", frame.Health, "TOP", arrowXOffset, arrowYOffset)
				else
					frame.TopIndicator:SetPoint("BOTTOM", frame.Name, "TOP", arrowXOffset, arrowYOffset)
				end
			end
		elseif glowStyle == "style4" or glowStyle == "style7" or glowStyle == "style8" then
			if frame.IconOnlyChanged then
				frame.LeftIndicator:SetPoint("LEFT", frame.IconFrame, "RIGHT", arrowXOffset, arrowYOffset)
				frame.RightIndicator:SetPoint("RIGHT", frame.IconFrame, "LEFT", -arrowXOffset, arrowYOffset)
			else
				if healthIsShown then
					frame.LeftIndicator:SetPoint("LEFT", frame.Health, "RIGHT", arrowXOffset, arrowYOffset)
					frame.RightIndicator:SetPoint("RIGHT", frame.Health, "LEFT", -arrowXOffset, arrowYOffset)
				else
					frame.LeftIndicator:SetPoint("LEFT", frame.Name, "RIGHT", arrowXOffset, arrowYOffset)
					frame.RightIndicator:SetPoint("RIGHT", frame.Name, "LEFT", -arrowXOffset, arrowYOffset)
				end
			end
		end

		-- Spark / Shadow
		frame.Shadow:SetBackdropBorderColor(r, g, b)
		frame.Shadow:SetAlpha(a)

		frame.Spark:SetVertexColor(r, g, b, a)
		frame.Spark:ClearAllPoints()

		if glowStyle == "style1" or glowStyle == "style5" or glowStyle == "style7" then
			frame.Shadow:SetOutside(frame.IconOnlyChanged and frame.IconFrame or frame.Health, E:Scale(E.PixelMode and 6 or 8), E:Scale(E.PixelMode and 6 or 8))
		elseif glowStyle == "style2" or glowStyle == "style6" or glowStyle == "style8" then
			if healthIsShown then
				local size = E.Border + 14
				frame.Spark:SetPoint("TOPLEFT", frame.Health, -(size * 2), size)
				frame.Spark:SetPoint("BOTTOMRIGHT", frame.Health, (size * 2), -size)
			else
				frame.Spark:SetPoint("TOPLEFT", frame.IconOnlyChanged and frame.IconFrame or frame.Name, -20, 8)
				frame.Spark:SetPoint("BOTTOMRIGHT", frame.IconOnlyChanged and frame.IconFrame or frame.Name, 20, -8)
			end
		end
	end
end

local Textures = {"Spark", "TopIndicator", "LeftIndicator", "RightIndicator"}

function NP:Construct_Glow(frame)
	frame.Shadow = CreateFrame("Frame", "$parentGlow", frame)
	frame.Shadow:SetFrameLevel(frame.Health:GetFrameLevel() - 1)
	frame.Shadow:SetBackdrop({edgeFile = LSM:Fetch("border", "ElvUI GlowBorder"), edgeSize = E:Scale(6)})
	frame.Shadow:Hide()

	for _, object in ipairs(Textures) do
		frame[object] = frame:CreateTexture(nil, "BACKGROUND")
		frame[object]:Hide()
	end

	frame.Spark:SetTexture(E.Media.Textures.Spark)
	frame.TopIndicator:SetTexture(E.Media.Arrows[NP.db.units.TARGET.arrow])
	frame.TopIndicator:SetTexCoord(1, 1, 1, 0, 0, 1, 0, 0) -- Rotates texture 180 degress (Up arrow to face down)
	frame.LeftIndicator:SetTexture(E.Media.Arrows[NP.db.units.TARGET.arrow])
	frame.LeftIndicator:SetTexCoord(1, 0, 0, 0, 1, 1, 0, 1) -- Rotates texture 90 degrees clockwise (Up arrow to face right)
	frame.RightIndicator:SetTexture(E.Media.Arrows[NP.db.units.TARGET.arrow])
	frame.RightIndicator:SetTexCoord(1, 1, 0, 1, 1, 0, 0, 0) -- Flips texture horizontally (Right facing arrow to face left)
end