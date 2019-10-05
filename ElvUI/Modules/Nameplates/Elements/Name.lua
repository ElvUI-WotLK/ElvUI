local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule("NamePlates")
local LSM = E.Libs.LSM

--Lua functions
--WoW API / Variables
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local UNKNOWN = UNKNOWN

function NP:UpdateElement_Name(frame, triggered)
	if not triggered then
		if not self.db.units[frame.UnitType].showName then return end
	end

	frame.Name:SetText(frame.UnitName or UNKNOWN)

	local r, g, b = 1, 1, 1
	local class = frame.UnitClass
	local reactionType = frame.UnitReaction

	local classColor, useClassColor
	if class then
		classColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
		useClassColor = self.db.units[frame.UnitType].name and self.db.units[frame.UnitType].name.useClassColor
	end

	if useClassColor and (frame.UnitType == "FRIENDLY_PLAYER" or frame.UnitType == "ENEMY_PLAYER") then
		r, g, b = classColor.r, classColor.g, classColor.b
	elseif triggered or (not self.db.units[frame.UnitType].healthbar.enable and not frame.isTarget) then
		if reactionType then
			if reactionType == 4 then
				r, g, b = self.db.reactions.neutral.r, self.db.reactions.neutral.g, self.db.reactions.neutral.b
			elseif reactionType > 4 then
				if frame.UnitType == "FRIENDLY_PLAYER" then
					r, g, b = NP.db.reactions.friendlyPlayer.r, NP.db.reactions.friendlyPlayer.g, NP.db.reactions.friendlyPlayer.b
				else
					r, g, b = NP.db.reactions.good.r, NP.db.reactions.good.g, NP.db.reactions.good.b
				end
			else
				r, g, b = self.db.reactions.bad.r, self.db.reactions.bad.g, self.db.reactions.bad.b
			end
		end
	end

	-- if for some reason the values failed just default to white
	if not (r and g and b) then
		r, g, b = 1, 1, 1
	end

	if triggered or (r ~= frame.Name.r or g ~= frame.Name.g or b ~= frame.Name.b) then
		frame.Name:SetTextColor(r, g, b)
		if not triggered then
			frame.Name.r, frame.Name.g, frame.Name.b = r, g, b
		end
	end

	if self.db.nameColoredGlow then
		frame.Name.NameOnlyGlow:SetVertexColor(r - 0.1, g - 0.1, b - 0.1, 1)
	else
		frame.Name.NameOnlyGlow:SetVertexColor(self.db.glowColor.r, self.db.glowColor.g, self.db.glowColor.b, self.db.glowColor.a)
	end
end

function NP:ConfigureElement_Name(frame)
	local name = frame.Name

	name:SetJustifyH("LEFT")
	name:SetJustifyV("BOTTOM")
	name:ClearAllPoints()
	if self.db.units[frame.UnitType].healthbar.enable or (self.db.alwaysShowTargetHealth and frame.isTarget) then
		name:SetJustifyH("LEFT")
		name:SetPoint("BOTTOMLEFT", frame.HealthBar, "TOPLEFT", 0, E.Border*2)
		name:SetPoint("BOTTOMRIGHT", frame.Level, "BOTTOMLEFT")
	else
		name:SetJustifyH("CENTER")
		name:SetPoint("TOP", frame)
	end

	name:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
end

function NP:ConstructElement_Name(frame)
	local name = frame:CreateFontString(nil, "OVERLAY")
	name:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
	name:SetWordWrap(false)

	local g = frame:CreateTexture(nil, "BACKGROUND")
	g:SetTexture(E.Media.Textures.Spark)
	g:Hide()
	g:SetPoint("TOPLEFT", name, -20, 8)
	g:SetPoint("BOTTOMRIGHT", name, 20, -8)

	name.NameOnlyGlow = g

	return name
end