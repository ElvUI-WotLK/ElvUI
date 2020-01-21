local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule("UnitFrames")

--Lua functions
--WoW API / Variables

function UF:Construct_Happiness(frame)
	local HappinessIndicator = CreateFrame("Statusbar", nil, frame)

	HappinessIndicator.backdrop = CreateFrame("Frame", nil, HappinessIndicator)
	UF.statusbars[HappinessIndicator] = true
	HappinessIndicator.backdrop:SetTemplate("Default", nil, nil, self.thinBorders, true)
	HappinessIndicator.backdrop:SetFrameLevel(HappinessIndicator:GetFrameLevel() - 1)
	HappinessIndicator:SetInside(HappinessIndicator.backdrop)
	HappinessIndicator:SetOrientation("VERTICAL")
	HappinessIndicator:SetMinMaxValues(0, 100)
	HappinessIndicator:SetFrameLevel(50)

	HappinessIndicator.bg = HappinessIndicator:CreateTexture(nil, "BORDER")
	HappinessIndicator.bg:SetAllPoints(HappinessIndicator)
	HappinessIndicator.bg:SetTexture(E.media.blankTex)
	HappinessIndicator.bg.multiplier = 0.3

	HappinessIndicator.Override = UF.HappinessOverride

	return HappinessIndicator
end

function UF:Configure_Happiness(frame)
	if not frame.VARIABLES_SET then return end

	local HappinessIndicator = frame.HappinessIndicator
	local db = frame.db

	frame.HAPPINESS_WIDTH = HappinessIndicator and frame.HAPPINESS_SHOWN and (db.happiness.width + (frame.BORDER*3)) or 0

	if db.happiness.enable then
		if not frame:IsElementEnabled("HappinessIndicator") then
			frame:EnableElement("HappinessIndicator")
		end

		HappinessIndicator.backdrop:ClearAllPoints()
		if db.power.enable and not frame.USE_MINI_POWERBAR and not frame.USE_INSET_POWERBAR and not frame.POWERBAR_DETACHED and not frame.USE_POWERBAR_OFFSET then
			if frame.ORIENTATION == "RIGHT" then
				HappinessIndicator.backdrop:Point("BOTTOMRIGHT", frame.Power, "BOTTOMLEFT", -frame.BORDER + (frame.BORDER - frame.SPACING*3), -frame.BORDER)
				HappinessIndicator.backdrop:Point("TOPLEFT", frame.Health, "TOPLEFT", -frame.HAPPINESS_WIDTH, frame.BORDER)
			else
				HappinessIndicator.backdrop:Point("BOTTOMLEFT", frame.Power, "BOTTOMRIGHT", frame.BORDER + (-frame.BORDER + frame.SPACING*3), -frame.BORDER)
				HappinessIndicator.backdrop:Point("TOPRIGHT", frame.Health, "TOPRIGHT", frame.HAPPINESS_WIDTH, frame.BORDER)
			end
		else
			if frame.ORIENTATION == "RIGHT" then
				HappinessIndicator.backdrop:Point("BOTTOMRIGHT", frame.Health, "BOTTOMLEFT", -frame.BORDER + (frame.BORDER - frame.SPACING*3), -frame.BORDER)
				HappinessIndicator.backdrop:Point("TOPLEFT", frame.Health, "TOPLEFT", -frame.HAPPINESS_WIDTH, frame.BORDER)
			else
				HappinessIndicator.backdrop:Point("BOTTOMLEFT", frame.Health, "BOTTOMRIGHT", frame.BORDER + (-frame.BORDER + frame.SPACING*3), -frame.BORDER)
				HappinessIndicator.backdrop:Point("TOPRIGHT", frame.Health, "TOPRIGHT", frame.HAPPINESS_WIDTH, frame.BORDER)
			end
		end
	else
		if frame:IsElementEnabled("HappinessIndicator") then
			frame:DisableElement("HappinessIndicator")
		end
	end
end

function UF:HappinessOverride(event, unit)
	if not unit or self.unit ~= unit then return end

	local db = self.db
	if not db then return end

	local element = self.HappinessIndicator

	if element.PreUpdate then
		element:PreUpdate()
	end

	local _, hunterPet = HasPetUI()
	local happiness, damagePercentage = GetPetHappiness()
	local value, r, g, b

	if hunterPet and happiness then
		if damagePercentage == 75 then
			value = 33
			r, g, b = 0.8, 0.2, 0.1
		elseif damagePercentage == 100 then
			value = 66
			r, g, b = 1, 1, 0
		elseif damagePercentage == 125 then
			value = 100
			r, g, b = 0, 0.8, 0
		end

		element:SetValue(value)
		element:SetStatusBarColor(r, g, b)
		element.bg:SetVertexColor(r, g, b, 0.15)

		if damagePercentage == 125 and db.happiness.autoHide then
			element:Hide()
		else
			element:Show()
		end
	else
		return element:Hide()
	end

	local isShown = element:IsShown()
	local stateChanged

	if (self.HAPPINESS_SHOWN and not isShown) or (not self.HAPPINESS_SHOWN and isShown) then
		stateChanged = true
	end

	self.HAPPINESS_SHOWN = isShown

	if stateChanged then
		UF:Configure_Happiness(self)
		UF:Configure_HealthBar(self)
		UF:Configure_Power(self)
		UF:Configure_InfoPanel(self, true)
	end

	if element.PostUpdate then
		return element:PostUpdate(unit, happiness, damagePercentage)
	end
end