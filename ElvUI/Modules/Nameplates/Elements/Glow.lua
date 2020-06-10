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

	if not healthIsShown then
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

			if healthIsShown then
				frame.TopIndicator:Show()
			end
		elseif glowStyle == "style4" or glowStyle == "style7" or glowStyle == "style8" then
			frame.TopIndicator:Hide()

			if healthIsShown then
				frame.LeftIndicator:Show()
				frame.RightIndicator:Show()
			end
		end

		-- Spark / Shadow
		frame.Shadow:SetBackdropBorderColor(r, g, b)
		frame.Spark:SetVertexColor(r, g, b)

		if glowStyle == "style1" or glowStyle == "style5" or glowStyle == "style7" then
			frame.Spark:Hide()
			frame.Shadow:Show()
		elseif glowStyle == "style2" or glowStyle == "style6" or glowStyle == "style8" then
			frame.Shadow:Hide()
			frame.Spark:Show()
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

	if not healthIsShown then
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
		local r, g, b, a = color.r, color.g, color.b, color.a

		-- Indicators
		frame.LeftIndicator:SetVertexColor(r, g, b)
		frame.RightIndicator:SetVertexColor(r, g, b)
		frame.TopIndicator:SetVertexColor(r, g, b)

		frame.TopIndicator:ClearAllPoints()
		frame.LeftIndicator:ClearAllPoints()
		frame.RightIndicator:ClearAllPoints()

		if glowStyle == "style3" or glowStyle == "style5" or glowStyle == "style6" then
			if healthIsShown then
				frame.TopIndicator:SetPoint("BOTTOM", frame.Health, "TOP", 0, 6)
			else
				frame.TopIndicator:SetPoint("BOTTOM", frame.Name, "TOP", 0, 8)
			end
		elseif glowStyle == "style4" or glowStyle == "style7" or glowStyle == "style8" then
			if healthIsShown then
				frame.LeftIndicator:SetPoint("LEFT", frame.Health, "RIGHT", -3, 0)
				frame.RightIndicator:SetPoint("RIGHT", frame.Health, "LEFT", 3, 0)
			else
				frame.LeftIndicator:SetPoint("LEFT", frame.Name, "RIGHT", 20, 0)
				frame.RightIndicator:SetPoint("RIGHT", frame.Name, "LEFT", -20, 0)
			end
		end

		-- Spark / Shadow
		frame.Shadow:SetBackdropBorderColor(r, g, b)
		frame.Shadow:SetAlpha(a)

		frame.Spark:SetVertexColor(r, g, b, a)
		frame.Spark:ClearAllPoints()

		if glowStyle == "style1" or glowStyle == "style5" or glowStyle == "style7" then
			frame.Shadow:SetOutside(frame.Health, E:Scale(E.PixelMode and 6 or 8), E:Scale(E.PixelMode and 6 or 8))
		elseif glowStyle == "style2" or glowStyle == "style6" or glowStyle == "style8" then
			if healthIsShown then
				local size = E.Border + 14
				frame.Spark:SetPoint("TOPLEFT", frame.Health, -(size * 2), size)
				frame.Spark:SetPoint("BOTTOMRIGHT", frame.Health, (size * 2), -size)
			else
				local nameIsShown = frame.Name:IsShown()
				frame.Spark:SetPoint("TOPLEFT", nameIsShown and frame.Name or frame.IconFrame, -20, 8)
				frame.Spark:SetPoint("BOTTOMRIGHT", nameIsShown and frame.Name or frame.IconFrame, 20, -8)
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
	frame.TopIndicator:SetTexture(E.Media.Textures.ArrowUp)
	frame.TopIndicator:SetRotation(3.14)
	frame.LeftIndicator:SetTexture(E.Media.Textures.ArrowUp)
	frame.LeftIndicator:SetRotation(1.57)
	frame.RightIndicator:SetTexture(E.Media.Textures.ArrowUp)
	frame.RightIndicator:SetRotation(-1.57)
end