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

		local healthIsShown = (not frame.NameOnlyChanged and self.db.units[frame.UnitType].health.enable) or (frame.isTarget and not frame.NameOnlyChanged and self.db.alwaysShowTargetHealth)
		if not healthIsShown and (glowStyle ~= "style2" and glowStyle ~= "style6" and glowStyle ~= "style8") then
			glowStyle = "style2"
		end

		if glowStyle == "style3" or glowStyle == "style5" or glowStyle == "style6" then
			frame.TopIndicator:SetVertexColor(r, g, b)
			frame.TopIndicator:Show()
		else
			frame.TopIndicator:Hide()
		end

		if glowStyle == "style4" or glowStyle == "style7" or glowStyle == "style8" then
			frame.LeftIndicator:SetVertexColor(r, g, b)
			frame.RightIndicator:SetVertexColor(r, g, b)
			frame.LeftIndicator:Show()
			frame.RightIndicator:Show()
		else
			frame.LeftIndicator:Hide()
			frame.RightIndicator:Hide()
		end

		if glowStyle == "style1" or glowStyle == "style5" or glowStyle == "style7" then
			frame.Shadow:SetBackdropBorderColor(r, g, b)
			frame.Shadow:Show()
		else
			frame.Shadow:Hide()
		end

		if glowStyle == "style2" or glowStyle == "style6" or glowStyle == "style8" then
			frame.Spark:SetVertexColor(r, g, b)
			frame.Spark:Show()
		else
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

	if glowStyle ~= "none" then
		local healthIsShown = (not frame.NameOnlyChanged and self.db.units[frame.UnitType].health.enable) or (frame.isTarget and not frame.NameOnlyChanged and self.db.alwaysShowTargetHealth)
		local color = self.db.colors.glowColor

		if not healthIsShown and (glowStyle ~= "style2" and glowStyle ~= "style6" and glowStyle ~= "style8") then
			glowStyle = "style2"
		else
			if glowStyle == "style3" or glowStyle == "style5" or glowStyle == "style6" then
				frame.TopIndicator:SetPoint("BOTTOM", frame.Health, "TOP", 0, -6)

				frame.TopIndicator:SetVertexColor(color.r, color.g, color.b)
			end

			if glowStyle == "style4" or glowStyle == "style7" or glowStyle == "style8" then
				frame.LeftIndicator:SetPoint("LEFT", frame.Health, "RIGHT", -3, 0)
				frame.RightIndicator:SetPoint("RIGHT", frame.Health, "LEFT", 3, 0)

				frame.LeftIndicator:SetVertexColor(color.r, color.g, color.b)
				frame.RightIndicator:SetVertexColor(color.r, color.g, color.b)
			end

			if glowStyle == "style1" or glowStyle == "style5" or glowStyle == "style7" then
				frame.Shadow:SetOutside(frame.Health, E:Scale(E.PixelMode and 6 or 8), E:Scale(E.PixelMode and 6 or 8))

				frame.Shadow:SetBackdropBorderColor(color.r, color.g, color.b)
				frame.Shadow:SetAlpha(color.a)
			end
		end

		if glowStyle == "style2" or glowStyle == "style6" or glowStyle == "style8" then
			frame.Spark:ClearAllPoints()

			if healthIsShown then
				local size = E.Border + 14
				frame.Spark:SetPoint("TOPLEFT", frame.Health, -(size * 2), size)
				frame.Spark:SetPoint("BOTTOMRIGHT", frame.Health, (size * 2), -size)
			else
				frame.Spark:SetPoint("TOPLEFT", frame.Name, -20, 8)
				frame.Spark:SetPoint("BOTTOMRIGHT", frame.Name, 20, -8)
			end

			frame.Spark:SetVertexColor(color.r, color.g, color.b)
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