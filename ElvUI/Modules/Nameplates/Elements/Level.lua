local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule("NamePlates")
local LSM = E.Libs.LSM

--Lua functions
--WoW API / Variables

function NP:Update_Level(frame)
	if not self.db.units[frame.UnitType].level.enable then return end

	local levelText, r, g, b = self:UnitLevel(frame)

	local level = frame.Level
	level:ClearAllPoints()

	if self.db.units[frame.UnitType].health.enable or (frame.isTarget and self.db.alwaysShowTargetHealth) then
		level:SetJustifyH("RIGHT")
		level:SetPoint("BOTTOMRIGHT", frame.Health, "TOPRIGHT", 0, E.Border*2)
	else
		level:SetPoint("LEFT", frame.Name, "RIGHT")
		level:SetJustifyH("LEFT")
	end

	if self.db.units[frame.UnitType].health.enable or frame.isTarget then
		level:SetText(levelText)
	else
		level:SetFormattedText(" [%s]", levelText)
	end
	level:SetTextColor(r, g, b)
end

function NP:Configure_Level(frame)
	local db = self.db.units[frame.UnitType].level
	frame.Level:FontTemplate(LSM:Fetch("font", db.font), db.fontSize, db.fontOutline)
end

function NP:Construct_Level(frame)
	return frame:CreateFontString(nil, "OVERLAY")
end