local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule("UnitFrames")

function UF:Construct_Happiness(frame)
	local HappinessIndicator = CreateFrame("Statusbar", nil, frame)

	UF["statusbars"][HappinessIndicator] = true
	HappinessIndicator:CreateBackdrop("Default", nil, nil, self.thinBorders, true)
	HappinessIndicator:SetOrientation("VERTICAL")
	HappinessIndicator:SetMinMaxValues(0, 100)

	HappinessIndicator.Override = UF.UpdateOverride

	return HappinessIndicator
end

function UF:Configure_Happiness(frame)
	if not frame.VARIABLES_SET then return end

	local HappinessIndicator = frame.HappinessIndicator
	local db = frame.db

	frame.HAPPINESS_WIDTH = HappinessIndicator and frame.HAPPINESS_SHOWN and (db.happiness.width + (frame.BORDER*2)) or 0;

	if db.happiness.enable then
		if not frame:IsElementEnabled("HappinessIndicator") then
			frame:EnableElement("HappinessIndicator")
		end

		HappinessIndicator:ClearAllPoints()
		if db.power.enable and not frame.USE_MINI_POWERBAR and not frame.USE_INSET_POWERBAR and not frame.POWERBAR_DETACHED and not frame.USE_POWERBAR_OFFSET then
			if frame.ORIENTATION == "RIGHT" then
				HappinessIndicator:Point("BOTTOMRIGHT", frame.Power, "BOTTOMLEFT", -frame.BORDER*2 + (frame.BORDER - frame.SPACING*3), 0)
				HappinessIndicator:Point("TOPLEFT", frame.Health, "TOPLEFT", -frame.HAPPINESS_WIDTH, 0)
			else
				HappinessIndicator:Point("BOTTOMLEFT", frame.Power, "BOTTOMRIGHT", frame.BORDER*2 + (-frame.BORDER + frame.SPACING*3), 0)
				HappinessIndicator:Point("TOPRIGHT", frame.Health, "TOPRIGHT", frame.HAPPINESS_WIDTH, 0)
			end
		else
			if frame.ORIENTATION == "RIGHT" then
				HappinessIndicator:Point("BOTTOMRIGHT", frame.Health, "BOTTOMLEFT", -frame.BORDER*2 + (frame.BORDER - frame.SPACING*3), 0)
				HappinessIndicator:Point("TOPLEFT", frame.Health, "TOPLEFT", -frame.HAPPINESS_WIDTH, 0)
			else
				HappinessIndicator:Point("BOTTOMLEFT", frame.Health, "BOTTOMRIGHT", frame.BORDER*2 + (-frame.BORDER + frame.SPACING*3), 0)
				HappinessIndicator:Point("TOPRIGHT", frame.Health, "TOPRIGHT", frame.HAPPINESS_WIDTH, 0)
			end
		end
	elseif frame:IsElementEnabled("HappinessIndicator") then
		frame:DisableElement("HappinessIndicator")
	end
end

function UF:UpdateOverride(event, unit)
	if not unit or self.unit ~= unit then return end

	local element = self.HappinessIndicator

	if element.PreUpdate then
		element:PreUpdate()
	end

	local _, hunterPet = HasPetUI()
	local happiness, damagePercentage = GetPetHappiness()

	if hunterPet and happiness then
		if damagePercentage == 75 then
			element:SetStatusBarColor(0.8, 0.2, 0.1)
			element:SetValue(33)
		elseif damagePercentage == 100 then
			element:SetStatusBarColor(1, 1, 0)
			element:SetValue(66)
		elseif damagePercentage == 125 then
			element:SetStatusBarColor(0, 0.8, 0)
			element:SetValue(100)
		end

		if damagePercentage == 125 and self.db.happiness.autoHide then
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