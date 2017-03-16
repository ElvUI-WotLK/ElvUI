local E, L, V, P, G = unpack(select(2, ...))
local mod = E:GetModule("NamePlates")
local LSM = LibStub("LibSharedMedia-3.0")

function mod:UpdateElement_Name(frame)
	if not self.db.units[frame.UnitType].showName then return end

	frame.Name:SetText(frame.UnitName)

	local useClassColor = self.db.units[frame.UnitType].name and self.db.units[frame.UnitType].name.useClassColor
	if useClassColor and (frame.UnitType == "FRIENDLY_PLAYER" or frame.UnitType == "ENEMY_PLAYER") then
		local class = frame.UnitClass
		local color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
		if class and color then
			frame.Name:SetTextColor(color.r, color.g, color.b)
		else
			frame.Name:SetTextColor(self.db.reactions.friendlyPlayer.r, self.db.reactions.friendlyPlayer.g, self.db.reactions.friendlyPlayer.b)
		end
	elseif not self.db.units[frame.UnitType].healthbar.enable and not frame.isTarget then
		local reactionType = frame.UnitReaction

		local r, g, b
		if reactionType == 4 then
			r, g, b = self.db.reactions.neutral.r, self.db.reactions.neutral.g, self.db.reactions.neutral.b
		elseif reactionType > 4 then
			if frame.UnitType == "FRIENDLY_PLAYER" then
				r, g, b = mod.db.reactions.friendlyPlayer.r, mod.db.reactions.friendlyPlayer.g, mod.db.reactions.friendlyPlayer.b
			else
				r, g, b = mod.db.reactions.good.r, mod.db.reactions.good.g, mod.db.reactions.good.b
			end
		else
			r, g, b = self.db.reactions.bad.r, self.db.reactions.bad.g, self.db.reactions.bad.b
		end	

		frame.Name:SetTextColor(r, g, b)
	else
		frame.Name:SetTextColor(1, 1, 1)
	end
end

function mod:ConfigureElement_Name(frame)
	local name = frame.Name

	name:SetJustifyH("LEFT")
	name:SetJustifyV("BOTTOM")
	name:ClearAllPoints()
	if self.db.units[frame.UnitType].healthbar.enable or frame.isTarget then
		name:SetJustifyH("LEFT")
		name:SetPoint("BOTTOMLEFT", frame.HealthBar, "TOPLEFT", 0, E.Border*2)
		name:SetPoint("BOTTOMRIGHT", frame.Level, "BOTTOMLEFT")
	else
		name:SetJustifyH("CENTER")
		name:SetPoint("BOTTOM", frame, "CENTER", 0, 0)
	end

	name:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
end

function mod:ConstructElement_Name(frame)
	local name = frame:CreateFontString(nil, "OVERLAY")
	name:SetWordWrap(false)

	return name
end