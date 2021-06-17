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

	if frame.Health:IsShown() then
		level:SetJustifyH("RIGHT")
		level:SetPoint(E.InversePoints[self.db.units[frame.UnitType].level.position], self.db.units[frame.UnitType].level.parent == "Nameplate" and frame or frame[self.db.units[frame.UnitType].level.parent], self.db.units[frame.UnitType].level.position, self.db.units[frame.UnitType].level.xOffset, self.db.units[frame.UnitType].level.yOffset)
		level:SetParent(frame.Health)
		level:SetText(levelText)
	else
		if self.db.units[frame.UnitType].name.enable then
			level:SetPoint("LEFT", frame.Name, "RIGHT")
		else
			level:SetPoint("TOPLEFT", frame, "TOPRIGHT", -38, 0)
		end
		level:SetParent(frame)
		level:SetJustifyH("LEFT")
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