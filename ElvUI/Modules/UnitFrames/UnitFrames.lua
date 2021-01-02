local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule("UnitFrames")
local LSM = E.Libs.LSM
UF.LSM = E.Libs.LSM

--Lua functions
local _G = _G
local select, pairs, type, unpack, assert, tostring = select, pairs, type, unpack, assert, tostring
local tremove, tinsert = table.remove, table.insert
local find, gsub, format = string.find, string.gsub, string.format
--WoW API / Variables
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame
local IsAddOnLoaded = IsAddOnLoaded
local UnitFrame_OnEnter = UnitFrame_OnEnter
local UnitFrame_OnLeave = UnitFrame_OnLeave
local IsInInstance = IsInInstance
local InCombatLockdown = InCombatLockdown
local GetInstanceInfo = GetInstanceInfo
local UnregisterStateDriver = UnregisterStateDriver
local RegisterStateDriver = RegisterStateDriver
local MAX_BOSS_FRAMES = MAX_BOSS_FRAMES

local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

UF.headerstoload = {}
UF.unitgroupstoload = {}
UF.unitstoload = {}

UF.groupPrototype = {}
UF.headerPrototype = {}
UF.headers = {}
UF.groupunits = {}
UF.units = {}

UF.statusbars = {}
UF.fontstrings = {}
UF.badHeaderPoints = {
	["TOP"] = "BOTTOM",
	["LEFT"] = "RIGHT",
	["BOTTOM"] = "TOP",
	["RIGHT"] = "LEFT"
}

UF.headerFunctions = {}
UF.classMaxResourceBar = {
	["DEATHKNIGHT"] = 6,
	["DRUID"] = 1
}

UF.instanceMapIDs = {
	[444] = 10,
	[541] = 40,
	[513] = 15,
	[402] = 40,
	[462] = 15,
	[483] = 15,
}

UF.headerGroupBy = {
	["CLASS"] = function(header)
		header:SetAttribute("groupingOrder", "DEATHKNIGHT,DRUID,HUNTER,MAGE,PALADIN,PRIEST,ROGUE,SHAMAN,WARLOCK,WARRIOR")
		header:SetAttribute("sortMethod", "NAME")
		header:SetAttribute("groupBy", "CLASS")
	end,
	["MTMA"] = function(header)
		header:SetAttribute("groupingOrder", "MAINTANK,MAINASSIST,NONE")
		header:SetAttribute("sortMethod", "NAME")
		header:SetAttribute("groupBy", "ROLE")
	end,
	["NAME"] = function(header)
		header:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
		header:SetAttribute("sortMethod", "NAME")
		header:SetAttribute("groupBy", nil)
	end,
	["GROUP"] = function(header)
		header:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
		header:SetAttribute("sortMethod", "INDEX")
		header:SetAttribute("groupBy", "GROUP")
	end,
	["PETNAME"] = function(header)
		header:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
		header:SetAttribute("sortMethod", "NAME")
		header:SetAttribute("groupBy", nil)
		header:SetAttribute("filterOnPet", true) --This is the line that matters. Without this, it sorts based on the owners name
	end,
}

local POINT_COLUMN_ANCHOR_TO_DIRECTION = {
	["TOPTOP"] = "UP_RIGHT",
	["BOTTOMBOTTOM"] = "TOP_RIGHT",
	["LEFTLEFT"] = "RIGHT_UP",
	["RIGHTRIGHT"] = "LEFT_UP",
	["RIGHTTOP"] = "LEFT_DOWN",
	["LEFTTOP"] = "RIGHT_DOWN",
	["LEFTBOTTOM"] = "RIGHT_UP",
	["RIGHTBOTTOM"] = "LEFT_UP",
	["BOTTOMRIGHT"] = "UP_LEFT",
	["BOTTOMLEFT"] = "UP_RIGHT",
	["TOPRIGHT"] = "DOWN_LEFT",
	["TOPLEFT"] = "DOWN_RIGHT"
}

local DIRECTION_TO_POINT = {
	DOWN_RIGHT = "TOP",
	DOWN_LEFT = "TOP",
	UP_RIGHT = "BOTTOM",
	UP_LEFT = "BOTTOM",
	RIGHT_DOWN = "LEFT",
	RIGHT_UP = "LEFT",
	LEFT_DOWN = "RIGHT",
	LEFT_UP = "RIGHT",
	UP = "BOTTOM",
	DOWN = "TOP"
}

local DIRECTION_TO_GROUP_ANCHOR_POINT = {
	DOWN_RIGHT = "TOPLEFT",
	DOWN_LEFT = "TOPRIGHT",
	UP_RIGHT = "BOTTOMLEFT",
	UP_LEFT = "BOTTOMRIGHT",
	RIGHT_DOWN = "TOPLEFT",
	RIGHT_UP = "BOTTOMLEFT",
	LEFT_DOWN = "TOPRIGHT",
	LEFT_UP = "BOTTOMRIGHT",
	OUT_RIGHT_UP = "BOTTOM",
	OUT_LEFT_UP = "BOTTOM",
	OUT_RIGHT_DOWN = "TOP",
	OUT_LEFT_DOWN = "TOP",
	OUT_UP_RIGHT = "LEFT",
	OUT_UP_LEFT = "RIGHT",
	OUT_DOWN_RIGHT = "LEFT",
	OUT_DOWN_LEFT = "RIGHT"
}

local INVERTED_DIRECTION_TO_COLUMN_ANCHOR_POINT = {
	DOWN_RIGHT = "RIGHT",
	DOWN_LEFT = "LEFT",
	UP_RIGHT = "RIGHT",
	UP_LEFT = "LEFT",
	RIGHT_DOWN = "BOTTOM",
	RIGHT_UP = "TOP",
	LEFT_DOWN = "BOTTOM",
	LEFT_UP = "TOP",
	UP = "TOP",
	DOWN = "BOTTOM"
}

local DIRECTION_TO_COLUMN_ANCHOR_POINT = {
	DOWN_RIGHT = "LEFT",
	DOWN_LEFT = "RIGHT",
	UP_RIGHT = "LEFT",
	UP_LEFT = "RIGHT",
	RIGHT_DOWN = "TOP",
	RIGHT_UP = "BOTTOM",
	LEFT_DOWN = "TOP",
	LEFT_UP = "BOTTOM"
}

local DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER = {
	DOWN_RIGHT = 1,
	DOWN_LEFT = -1,
	UP_RIGHT = 1,
	UP_LEFT = -1,
	RIGHT_DOWN = 1,
	RIGHT_UP = 1,
	LEFT_DOWN = -1,
	LEFT_UP = -1
}

local DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER = {
	DOWN_RIGHT = -1,
	DOWN_LEFT = -1,
	UP_RIGHT = 1,
	UP_LEFT = 1,
	RIGHT_DOWN = -1,
	RIGHT_UP = 1,
	LEFT_DOWN = -1,
	LEFT_UP = 1
}

function UF:ConvertGroupDB(group)
	local db = self.db.units[group.groupName]
	if db.point and db.columnAnchorPoint then
		db.growthDirection = POINT_COLUMN_ANCHOR_TO_DIRECTION[db.point..db.columnAnchorPoint]
		db.point = nil
		db.columnAnchorPoint = nil
	end

	if db.growthDirection == "UP" then
		db.growthDirection = "UP_RIGHT"
	end

	if db.growthDirection == "DOWN" then
		db.growthDirection = "DOWN_RIGHT"
	end
end

function UF:Construct_UF(frame, unit)
	frame:SetScript("OnEnter", UnitFrame_OnEnter)
	frame:SetScript("OnLeave", UnitFrame_OnLeave)

	if self.thinBorders then
		frame.SPACING = 0
		frame.BORDER = E.mult
	else
		frame.BORDER = E.Border
		frame.SPACING = E.Spacing
	end

	frame.SHADOW_SPACING = 3
	frame.CLASSBAR_YOFFSET = 0 --placeholder
	frame.BOTTOM_OFFSET = 0 --placeholder

	frame.RaisedElementParent = CreateFrame("Frame", nil, frame)
	frame.RaisedElementParent.TextureParent = CreateFrame("Frame", nil, frame.RaisedElementParent)
	frame.RaisedElementParent:SetFrameLevel(frame:GetFrameLevel() + 125)

	if not self.groupunits[unit] then
		local stringTitle = E:StringTitle(unit)
		if find(stringTitle, "target") then
			stringTitle = gsub(stringTitle, "target", "Target")
		end
		self["Construct_"..stringTitle.."Frame"](self, frame, unit)
	else
		UF["Construct_"..E:StringTitle(self.groupunits[unit]).."Frames"](self, frame, unit)
	end

	self:Update_StatusBars()
	self:Update_FontStrings()

	return frame
end

function UF:GetObjectAnchorPoint(frame, point)
	if not frame[point] or point == "Frame" then
		return frame
	elseif frame[point] and not frame[point]:IsShown() then
		return frame.Health
	else
		return frame[point]
	end
end

function UF:GetPositionOffset(position, offset)
	if not offset then offset = 2 end
	local x, y = 0, 0
	if find(position, "LEFT") then
		x = offset
	elseif find(position, "RIGHT") then
		x = -offset
	end

	if find(position, "TOP") then
		y = -offset
	elseif find(position, "BOTTOM") then
		y = offset
	end

	return x, y
end

function UF:GetAuraOffset(p1, p2)
	local x, y = 0, 0
	if p1 == "RIGHT" and p2 == "LEFT" then
		x = -3
	elseif p1 == "LEFT" and p2 == "RIGHT" then
		x = 3
	end

	if find(p1, "TOP") and find(p2, "BOTTOM") then
		y = -1
	elseif find(p1, "BOTTOM") and find(p2, "TOP") then
		y = 1
	end

	return E:Scale(x), E:Scale(y)
end

function UF:GetAuraAnchorFrame(frame, attachTo, isConflict)
	if isConflict then
		E:Print(format(L["%s frame(s) has a conflicting anchor point, please change either the buff or debuff anchor point so they are not attached to each other. Forcing the debuffs to be attached to the main unitframe until fixed."], E:StringTitle(frame:GetName())))
	end

	if isConflict or attachTo == "FRAME" then
		return frame
	elseif attachTo == "TRINKET" then
		if select(2, IsInInstance()) == "arena" then
			return frame.Trinket
		end
	elseif attachTo == "BUFFS" then
		return frame.Buffs
	elseif attachTo == "DEBUFFS" then
		return frame.Debuffs
	elseif attachTo == "HEALTH" then
		return frame.Health
	elseif attachTo == "POWER" and frame.Power then
		return frame.Power
	else
		return frame
	end
end

function UF:ClearChildPoints(...)
	for i = 1, select("#", ...) do
		local child = select(i, ...)
		child:ClearAllPoints()
	end
end

function UF:UpdateColors()
	local db = self.db.colors

	ElvUF.colors.tapped = E:SetColorTable(ElvUF.colors.tapped, db.tapped)
	ElvUF.colors.disconnected = E:SetColorTable(ElvUF.colors.disconnected, db.disconnected)
	ElvUF.colors.health = E:SetColorTable(ElvUF.colors.health, db.health)
	ElvUF.colors.power.MANA = E:SetColorTable(ElvUF.colors.power.MANA, db.power.MANA)
	ElvUF.colors.power.RAGE = E:SetColorTable(ElvUF.colors.power.RAGE, db.power.RAGE)
	ElvUF.colors.power.FOCUS = E:SetColorTable(ElvUF.colors.power.FOCUS, db.power.FOCUS)
	ElvUF.colors.power.ENERGY = E:SetColorTable(ElvUF.colors.power.ENERGY, db.power.ENERGY)
	ElvUF.colors.power.RUNIC_POWER = E:SetColorTable(ElvUF.colors.power.RUNIC_POWER, db.power.RUNIC_POWER)

	ElvUF.colors.threat[0] = E:SetColorTable(ElvUF.colors.threat[0], db.threat[0])
	ElvUF.colors.threat[1] = E:SetColorTable(ElvUF.colors.threat[1], db.threat[1])
	ElvUF.colors.threat[2] = E:SetColorTable(ElvUF.colors.threat[2], db.threat[2])
	ElvUF.colors.threat[3] = E:SetColorTable(ElvUF.colors.threat[3], db.threat[3])

	if not ElvUF.colors.ComboPoints then ElvUF.colors.ComboPoints = {} end
	ElvUF.colors.ComboPoints[1] = E:SetColorTable(ElvUF.colors.ComboPoints[1], db.classResources.comboPoints[1])
	ElvUF.colors.ComboPoints[2] = E:SetColorTable(ElvUF.colors.ComboPoints[2], db.classResources.comboPoints[2])
	ElvUF.colors.ComboPoints[3] = E:SetColorTable(ElvUF.colors.ComboPoints[3], db.classResources.comboPoints[3])
	ElvUF.colors.ComboPoints[4] = E:SetColorTable(ElvUF.colors.ComboPoints[4], db.classResources.comboPoints[4])
	ElvUF.colors.ComboPoints[5] = E:SetColorTable(ElvUF.colors.ComboPoints[5], db.classResources.comboPoints[5])

	-- Death Knight
	if not ElvUF.colors.runes then ElvUF.colors.runes = {} end
	if not ElvUF.colors.ClassBars then ElvUF.colors.ClassBars = {} end
	if not ElvUF.colors.ClassBars.DEATHKNIGHT then ElvUF.colors.ClassBars.DEATHKNIGHT = {} end
	ElvUF.colors.runes[1] = E:SetColorTable(ElvUF.colors.ClassBars.DEATHKNIGHT[1], db.classResources.DEATHKNIGHT[1])
	ElvUF.colors.runes[2] = E:SetColorTable(ElvUF.colors.ClassBars.DEATHKNIGHT[2], db.classResources.DEATHKNIGHT[2])
	ElvUF.colors.runes[3] = E:SetColorTable(ElvUF.colors.ClassBars.DEATHKNIGHT[3], db.classResources.DEATHKNIGHT[3])
	ElvUF.colors.runes[4] = E:SetColorTable(ElvUF.colors.ClassBars.DEATHKNIGHT[4], db.classResources.DEATHKNIGHT[4])

	-- these are just holders.. to maintain and update tables
	if not ElvUF.colors.reaction.good then ElvUF.colors.reaction.good = {} end
	if not ElvUF.colors.reaction.bad then ElvUF.colors.reaction.bad = {} end
	if not ElvUF.colors.reaction.neutral then ElvUF.colors.reaction.neutral = {} end
	ElvUF.colors.reaction.good = E:SetColorTable(ElvUF.colors.reaction.good, db.reaction.GOOD)
	ElvUF.colors.reaction.bad = E:SetColorTable(ElvUF.colors.reaction.bad, db.reaction.BAD)
	ElvUF.colors.reaction.neutral = E:SetColorTable(ElvUF.colors.reaction.neutral, db.reaction.NEUTRAL)

	if not ElvUF.colors.smoothHealth then ElvUF.colors.smoothHealth = {} end
	ElvUF.colors.smoothHealth = E:SetColorTable(ElvUF.colors.smoothHealth, db.health)

	if not ElvUF.colors.smooth then ElvUF.colors.smooth = {1, 0, 0,	1, 1, 0} end

	ElvUF.colors.reaction[1] = ElvUF.colors.reaction.bad
	ElvUF.colors.reaction[2] = ElvUF.colors.reaction.bad
	ElvUF.colors.reaction[3] = ElvUF.colors.reaction.bad
	ElvUF.colors.reaction[4] = ElvUF.colors.reaction.neutral
	ElvUF.colors.reaction[5] = ElvUF.colors.reaction.good
	ElvUF.colors.reaction[6] = ElvUF.colors.reaction.good
	ElvUF.colors.reaction[7] = ElvUF.colors.reaction.good
	ElvUF.colors.reaction[8] = ElvUF.colors.reaction.good
	ElvUF.colors.smooth[7] = ElvUF.colors.smoothHealth[1]
	ElvUF.colors.smooth[8] = ElvUF.colors.smoothHealth[2]
	ElvUF.colors.smooth[9] = ElvUF.colors.smoothHealth[3]

	ElvUF.colors.castColor = E:SetColorTable(ElvUF.colors.castColor, db.castColor)
	ElvUF.colors.castNoInterrupt = E:SetColorTable(ElvUF.colors.castNoInterrupt, db.castNoInterrupt)

	if not ElvUF.colors.DebuffHighlight then ElvUF.colors.DebuffHighlight = {} end
	ElvUF.colors.DebuffHighlight.Magic = E:SetColorTable(ElvUF.colors.DebuffHighlight.Magic, db.debuffHighlight.Magic)
	ElvUF.colors.DebuffHighlight.Curse = E:SetColorTable(ElvUF.colors.DebuffHighlight.Curse, db.debuffHighlight.Curse)
	ElvUF.colors.DebuffHighlight.Disease = E:SetColorTable(ElvUF.colors.DebuffHighlight.Disease, db.debuffHighlight.Disease)
	ElvUF.colors.DebuffHighlight.Poison = E:SetColorTable(ElvUF.colors.DebuffHighlight.Poison, db.debuffHighlight.Poison)
end

function UF:Update_StatusBars()
	local statusBarTexture = LSM:Fetch("statusbar", self.db.statusbar)
	for statusbar in pairs(UF.statusbars) do
		if statusbar then
			local useBlank = statusbar.isTransparent
			if statusbar.parent then useBlank = statusbar.parent.isTransparent end
			if statusbar:IsObjectType("StatusBar") then
				if not useBlank then
					statusbar:SetStatusBarTexture(statusBarTexture)
					if statusbar.texture then statusbar.texture = statusBarTexture end --Update .texture on oUF Power element
				end
			elseif statusbar:IsObjectType("Texture") then
				statusbar:SetTexture(statusBarTexture)
			end

			UF:Update_StatusBar(statusbar.bg or statusbar.BG, (not useBlank and statusBarTexture) or E.media.blankTex)
		end
	end
end

function UF:Update_StatusBar(statusbar, texture)
	if not statusbar then return end
	if not texture then texture = LSM:Fetch("statusbar", self.db.statusbar) end

	if statusbar:IsObjectType("StatusBar") then
		statusbar:SetStatusBarTexture(texture)
	elseif statusbar:IsObjectType("Texture") then
		statusbar:SetTexture(texture)
	end
end

function UF:Update_FontString(object)
	object:FontTemplate(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
end

function UF:Update_FontStrings()
	local stringFont = LSM:Fetch("font", self.db.font)
	for font in pairs(UF.fontstrings) do
		font:FontTemplate(stringFont, self.db.fontSize, self.db.fontOutline)
	end
end

function UF:Construct_Fader()
	return {UpdateRange = UF.UpdateRange}
end

function UF:Configure_Fader(frame)
	if frame.db and frame.db.enable and (frame.db.fader and frame.db.fader.enable) then
		if not frame:IsElementEnabled("Fader") then
			frame:EnableElement("Fader")
		end

		frame.Fader:SetOption("Hover", frame.db.fader.hover)
		frame.Fader:SetOption("Combat", frame.db.fader.combat)
		frame.Fader:SetOption("PlayerTarget", frame.db.fader.playertarget)
		frame.Fader:SetOption("Focus", frame.db.fader.focus)
		frame.Fader:SetOption("Health", frame.db.fader.health)
		frame.Fader:SetOption("Power", frame.db.fader.power)
		frame.Fader:SetOption("Vehicle", frame.db.fader.vehicle)
		frame.Fader:SetOption("Casting", frame.db.fader.casting)
		frame.Fader:SetOption("MinAlpha", frame.db.fader.minAlpha)
		frame.Fader:SetOption("MaxAlpha", frame.db.fader.maxAlpha)

		if frame ~= ElvUF_Player then
			frame.Fader:SetOption("Range", frame.db.fader.range)
			frame.Fader:SetOption("UnitTarget", frame.db.fader.unittarget)
		end

		frame.Fader:SetOption("Smooth", (frame.db.fader.smooth > 0 and frame.db.fader.smooth) or nil)
		frame.Fader:SetOption("Delay", (frame.db.fader.delay > 0 and frame.db.fader.delay) or nil)

		frame.Fader:ClearTimers()
		frame.Fader.configTimer = E:ScheduleTimer(frame.Fader.ForceUpdate, 0.25, frame.Fader, true)
	elseif frame:IsElementEnabled("Fader") then
		frame:DisableElement("Fader")
		E:UIFrameFadeIn(frame, 1, frame:GetAlpha(), 1)
	end
end

function UF:Configure_FontString(obj)
	UF.fontstrings[obj] = true
	obj:FontTemplate() --This is temporary.
end

function UF:Update_AllFrames()
	if InCombatLockdown() then self:RegisterEvent("PLAYER_REGEN_ENABLED") return end
	if E.private.unitframe.enable ~= true then return end

	self:UpdateColors()
	self:Update_FontStrings()
	self:Update_StatusBars()

	for unit in pairs(self.units) do
		if self.db.units[unit].enable then
			self[unit]:Update()
			self[unit]:Enable()
			E:EnableMover(self[unit].mover:GetName())
		else
			self[unit]:Update()
			self[unit]:Disable()
			E:DisableMover(self[unit].mover:GetName())
		end
	end

	for unit, group in pairs(self.groupunits) do
		if self.db.units[group].enable then
			self[unit]:Enable()
			self[unit]:Update()
			E:EnableMover(self[unit].mover:GetName())
		else
			self[unit]:Disable()
			E:DisableMover(self[unit].mover:GetName())
		end
	end

	UF:UpdateAllHeaders()
end

function UF:CreateAndUpdateUFGroup(group, numGroup)
	if InCombatLockdown() then self:RegisterEvent("PLAYER_REGEN_ENABLED") return end

	for i = 1, numGroup do
		local unit = group..i
		local frameName = E:StringTitle(unit)
		frameName = gsub(frameName, "t(arget)", "T%1")
		local frame = self[unit]

		if not frame then
			self.groupunits[unit] = group
			frame = ElvUF:Spawn(unit, "ElvUF_"..frameName)
			frame.index = i
			frame:SetParent(ElvUF_Parent)
			frame:SetID(i)
			self[unit] = frame
		end

		frameName = E:StringTitle(group)
		frameName = gsub(frameName, "t(arget)", "T%1")
		frame.Update = function()
			UF["Update_"..E:StringTitle(frameName).."Frames"](self, frame, self.db.units[group])
		end

		if self.db.units[group].enable then
			frame:Enable()
			frame.Update()

			if frame.isForced then
				self:ForceShow(frame)
			end
			E:EnableMover(frame.mover:GetName())
		else
			frame:Disable()

			-- for some reason the boss/arena 'uncheck disable' doesnt fire this, we need to so putting it here.
			if group == "boss" or group == "arena" then
				UF:Configure_Fader(frame)
			end

			E:DisableMover(frame.mover:GetName())
		end
	end
end

function UF:HeaderUpdateSpecificElement(group, elementName)
	assert(self[group], "Invalid group specified.")
	for i = 1, self[group]:GetNumChildren() do
		local frame = select(i, self[group]:GetChildren())
		if frame and frame.Health then
			frame:UpdateElement(elementName)
		end
	end
end

function UF.groupPrototype:GetAttribute(name)
	return self.groups[1]:GetAttribute(name)
end

function UF.groupPrototype:Configure_Groups(frame)
	local db = UF.db.units[frame.groupName]

	local point
	local width, height, newCols, newRows = 0, 0, 0, 0
	local direction = db.growthDirection
	local xMult, yMult = DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER[direction], DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[direction]
	local UNIT_HEIGHT = db.infoPanel and db.infoPanel.enable and (db.height + db.infoPanel.height) or db.height
	local groupSpacing = db.groupSpacing

	local numGroups = frame.numGroups
	for i = 1, numGroups do
		local group = frame.groups[i]

		point = DIRECTION_TO_POINT[direction]

		if group then
			group:Hide()

			UF:ConvertGroupDB(group)
			if point == "LEFT" or point == "RIGHT" then
				group:SetAttribute("xOffset", db.horizontalSpacing * DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER[direction])
				group:SetAttribute("yOffset", 0)
				group:SetAttribute("columnSpacing", db.verticalSpacing)
			else
				group:SetAttribute("xOffset", 0)
				group:SetAttribute("yOffset", db.verticalSpacing * DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[direction])
				group:SetAttribute("columnSpacing", db.horizontalSpacing)
			end

			--[[if not group.isForced then
				if not group.initialized then
					group:SetAttribute("startingIndex", db.raidWideSorting and (-min(numGroups * (db.groupsPerRowCol * 5), MAX_RAID_MEMBERS) + 1) or -4)
					group:Show()
					group.initialized = true
				end
				group:SetAttribute("startingIndex", 1)
			end]]

			group:ClearAllPoints()
			if db.raidWideSorting and db.invertGroupingOrder then
				group:SetAttribute("columnAnchorPoint", INVERTED_DIRECTION_TO_COLUMN_ANCHOR_POINT[direction])
			else
				group:SetAttribute("columnAnchorPoint", DIRECTION_TO_COLUMN_ANCHOR_POINT[direction])
			end

			group:ClearChildPoints()
			group:SetAttribute("point", point)

			if not group.isForced then
				group:SetAttribute("maxColumns", db.raidWideSorting and numGroups or 1)
				group:SetAttribute("unitsPerColumn", db.raidWideSorting and (db.groupsPerRowCol * 5) or 5)
				if UF.headerGroupBy[db.groupBy] then
					UF.headerGroupBy[db.groupBy](group)
				else
					UF.headerGroupBy["GROUP"](group)
				end
				group:SetAttribute("sortDir", db.sortDir)
				group:SetAttribute("showPlayer", db.showPlayer)
			end

			if i == 1 and db.raidWideSorting then
				group:SetAttribute("groupFilter", "1,2,3,4,5,6,7,8")
			else
				group:SetAttribute("groupFilter", tostring(i))
			end

		--	group:Show()
		end

		--MATH!! WOOT
		point = DIRECTION_TO_GROUP_ANCHOR_POINT[direction]
		if db.raidWideSorting and db.startFromCenter then
			point = DIRECTION_TO_GROUP_ANCHOR_POINT["OUT_"..direction]
		end
		if (i - 1) % db.groupsPerRowCol == 0 then
			if DIRECTION_TO_POINT[direction] == "LEFT" or DIRECTION_TO_POINT[direction] == "RIGHT" then
				if group then
					group:Point(point, frame, point, 0, height * yMult)
				end
				height = height + UNIT_HEIGHT + db.verticalSpacing + groupSpacing
				newRows = newRows + 1
			else
				if group then
					group:Point(point, frame, point, width * xMult, 0)
				end
				width = width + db.width + db.horizontalSpacing + groupSpacing

				newCols = newCols + 1
			end
		else
			if DIRECTION_TO_POINT[direction] == "LEFT" or DIRECTION_TO_POINT[direction] == "RIGHT" then
				if newRows == 1 then
					if group then
						group:Point(point, frame, point, width * xMult, 0)
					end
					width = width + ((db.width + db.horizontalSpacing) * 5) + groupSpacing
					newCols = newCols + 1
				elseif group then
					group:Point(point, frame, point, ((((db.width + db.horizontalSpacing) * 5) * ((i - 1) % db.groupsPerRowCol)) + ((i - 1) % db.groupsPerRowCol)*groupSpacing) * xMult, (((UNIT_HEIGHT + db.verticalSpacing+groupSpacing) * (newRows - 1))) * yMult)
				end
			else
				if newCols == 1 then
					if group then
						group:Point(point, frame, point, 0, height * yMult)
					end
					height = height + ((UNIT_HEIGHT + db.verticalSpacing) * 5) + groupSpacing
					newRows = newRows + 1
				elseif group then
					group:Point(point, frame, point, (((db.width + db.horizontalSpacing +groupSpacing) * (newCols - 1))) * xMult, ((((UNIT_HEIGHT + db.verticalSpacing) * 5) * ((i-1) % db.groupsPerRowCol))+((i-1) % db.groupsPerRowCol)*groupSpacing) * yMult)
				end
			end
		end

		if height == 0 then
			height = height + ((UNIT_HEIGHT + db.verticalSpacing) * 5) + groupSpacing
		elseif width == 0 then
			width = width + ((db.width + db.horizontalSpacing) * 5) + groupSpacing
		end
	end

	if not frame.isInstanceForced then
		frame.dirtyWidth = width - db.horizontalSpacing -groupSpacing
		frame.dirtyHeight = height - db.verticalSpacing -groupSpacing
	end

	if frame.mover then
		frame.mover.positionOverride = DIRECTION_TO_GROUP_ANCHOR_POINT[direction]
		E:UpdatePositionOverride(frame.mover:GetName())
		frame:GetScript("OnSizeChanged")(frame) --Mover size is not updated if frame is hidden, so call an update manually
	end

	frame:Size(width - db.horizontalSpacing -groupSpacing, height - db.verticalSpacing - groupSpacing)
end

function UF.groupPrototype:Update(frame)
	local group = frame.groupName

	UF[group].db = UF.db.units[group]
	for i = 1, #frame.groups do
		frame.groups[i].db = UF.db.units[group]
		frame.groups[i]:Update()
	end
end

function UF.groupPrototype:AdjustVisibility(frame)
--	if not frame.isForced then
		local numGroups = frame.numGroups
		for i = 1, #frame.groups do
			local group = frame.groups[i]
			if (i <= numGroups) and ((frame.db.raidWideSorting and i <= 1) or not frame.db.raidWideSorting) then
				group:Show()
			else
				if group.forceShow then
					group:Hide()
					UF:UnshowChildUnits(group, group:GetChildren())
					group:SetAttribute("startingIndex", 1)
				else
					group:Reset(frame.groupName)
				end
			end
		end
--	end
end

function UF.headerPrototype:ClearChildPoints()
	for i = 1, self:GetNumChildren() do
		local child = select(i, self:GetChildren())
		child:ClearAllPoints()
	end
end

function UF.headerPrototype:Update()
	local group = self.groupName
	local db = UF.db.units[group]
	UF["Update_"..E:StringTitle(group).."Header"](UF, self, db)

	local i = 1
	local child = self:GetAttribute("child"..i)

	while child do
		UF["Update_"..E:StringTitle(group).."Frames"](UF, child, db)

		if _G[child:GetName().."Pet"] then
			UF["Update_"..E:StringTitle(group).."Frames"](UF, _G[child:GetName().."Pet"], db)
		end

		if _G[child:GetName().."Target"] then
			UF["Update_"..E:StringTitle(group).."Frames"](UF, _G[child:GetName().."Target"], db)
		end

		i = i + 1
		child = self:GetAttribute("child"..i)
	end
end

function UF.headerPrototype:Reset(group)
	self:Hide()

	self:SetAttribute("showPlayer", true)

	self:SetAttribute("showSolo", true)
	self:SetAttribute("showParty", true)
	self:SetAttribute("showRaid", group ~= "party" and true or false)

	self:SetAttribute("columnSpacing", nil)
	self:SetAttribute("columnAnchorPoint", nil)
	self:SetAttribute("groupBy", nil)
	self:SetAttribute("groupFilter", nil)
	self:SetAttribute("groupingOrder", nil)
	self:SetAttribute("maxColumns", nil)
	self:SetAttribute("nameList", nil)
	self:SetAttribute("point", nil)
	self:SetAttribute("sortDir", nil)
	self:SetAttribute("sortMethod", "NAME")
	self:SetAttribute("startingIndex", nil)
	self:SetAttribute("strictFiltering", nil)
	self:SetAttribute("unitsPerColumn", nil)
	self:SetAttribute("xOffset", nil)
	self:SetAttribute("yOffset", nil)
end

function UF:CreateHeader(parent, groupFilter, overrideName, template, groupName, headerTemplate)
	local group = parent.groupName or groupName
	ElvUF:SetActiveStyle("ElvUF_"..E:StringTitle(group))
	local header = ElvUF:SpawnHeader(overrideName, headerTemplate, nil,
			"groupFilter", groupFilter,
			"showParty", true,
			"showRaid", group ~= "party" and true or false,
			"showSolo", true,
			template and "template", template)

	header.groupName = group
	header:SetParent(parent)
	--header:Show()

	for k, v in pairs(self.headerPrototype) do
		header[k] = v
	end

	return header
end

function UF:CreateAndUpdateHeaderGroup(group, groupFilter, template, headerUpdate, headerTemplate)
	if InCombatLockdown() then self:RegisterEvent("PLAYER_REGEN_ENABLED") return end
	local db = self.db.units[group]
	local raidFilter = UF.db.smartRaidFilter
	local numGroups = db.numGroups
	if raidFilter and numGroups and (self[group] and not self[group].blockVisibilityChanges) then
		local _, instanceType, _, _, maxPlayers = GetInstanceInfo()
		if instanceType == "raid" or instanceType == "pvp" then
			local mapID = GetCurrentMapAreaID()
			if UF.instanceMapIDs[mapID] then
				maxPlayers = UF.instanceMapIDs[mapID]
			end

			if maxPlayers > 0 then
				numGroups = E:Round(maxPlayers/5)
			end
		end
	end

	if not self[group] then
		local stringTitle = E:StringTitle(group)
		ElvUF:RegisterStyle("ElvUF_"..stringTitle, UF["Construct_"..stringTitle.."Frames"])
		ElvUF:SetActiveStyle("ElvUF_"..stringTitle)

		if db.numGroups then
			self[group] = CreateFrame("Frame", "ElvUF_"..stringTitle, ElvUF_Parent, "SecureHandlerStateTemplate")
			self[group]:Hide()
			self[group].groups = {}
			self[group].groupName = group
			self[group].template = self[group].template or template
			self[group].headerTemplate = self[group].headerTemplate or headerTemplate
			if not UF.headerFunctions[group] then UF.headerFunctions[group] = {} end
			for k, v in pairs(self.groupPrototype) do
				UF.headerFunctions[group][k] = v
			end
		else
			self[group] = self:CreateHeader(ElvUF_Parent, groupFilter, "ElvUF_"..E:StringTitle(group), template, group, headerTemplate)
		end

		self[group].db = db
		self.headers[group] = self[group]
		--self[group]:Show()
	end

	self[group].numGroups = numGroups
	if numGroups then
		if db.raidWideSorting then
			if not self[group].groups[1] then
				self[group].groups[1] = self:CreateHeader(self[group], nil, "ElvUF_"..E:StringTitle(self[group].groupName).."Group1", template or self[group].template, nil, headerTemplate or self[group].headerTemplate)
			end
		else
			while numGroups > #self[group].groups do
				local index = tostring(#self[group].groups + 1)
				tinsert(self[group].groups, self:CreateHeader(self[group], index, "ElvUF_"..E:StringTitle(self[group].groupName).."Group"..index, template or self[group].template, nil, headerTemplate or self[group].headerTemplate))
			end
		end

	--	UF.headerFunctions[group]:AdjustVisibility(self[group])

		if headerUpdate or not self[group].mover then
			UF.headerFunctions[group]:Configure_Groups(self[group])
			if not self[group].isForced and not self[group].blockVisibilityChanges then
				RegisterStateDriver(self[group], "visibility", db.visibility)
			end

			if not self[group].mover then
				UF.headerFunctions[group]:Update(self[group])
			end
		else
			UF.headerFunctions[group]:Configure_Groups(self[group])
			UF.headerFunctions[group]:Update(self[group])
		end

		UF.headerFunctions[group]:AdjustVisibility(self[group])

		if db.enable then
			if self[group].mover then
				E:EnableMover(self[group].mover:GetName())
			end
		else
			UnregisterStateDriver(self[group], "visibility")
			self[group]:Hide()
			if self[group].mover then
				E:DisableMover(self[group].mover:GetName())
			end
			return
		end
	else
		self[group].db = db

		if not UF.headerFunctions[group] then UF.headerFunctions[group] = {} end
		UF.headerFunctions[group].Update = function()
		--	local db = UF.db.units[group]
			if db.enable ~= true then
				UnregisterStateDriver(UF[group], "visibility")
				UF[group]:Hide()
				if UF[group].mover then
					E:DisableMover(UF[group].mover:GetName())
				end
				return
			end
			UF["Update_"..E:StringTitle(group).."Header"](UF, UF[group], db)

			for i = 1, UF[group]:GetNumChildren() do
				local child = select(i, UF[group]:GetChildren())
				UF["Update_"..E:StringTitle(group).."Frames"](UF, child, UF.db.units[group])

				if _G[child:GetName().."Target"] then
					UF["Update_"..E:StringTitle(group).."Frames"](UF, _G[child:GetName().."Target"], UF.db.units[group])
				end

				if _G[child:GetName().."Pet"] then
					UF["Update_"..E:StringTitle(group).."Frames"](UF, _G[child:GetName().."Pet"], UF.db.units[group])
				end
			end

			E:EnableMover(UF[group].mover:GetName())
		end

		if headerUpdate then
			UF["Update_"..E:StringTitle(group).."Header"](self, self[group], db)
		else
			UF.headerFunctions[group]:Update(self[group])
		end
	end
end

function UF:PLAYER_REGEN_ENABLED()
	self:Update_AllFrames()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
end

function UF:CreateAndUpdateUF(unit)
	assert(unit, "No unit provided to create or update.")
	if InCombatLockdown() then self:RegisterEvent("PLAYER_REGEN_ENABLED") return end

	local frameName = E:StringTitle(unit)
	frameName = gsub(frameName, "t(arget)", "T%1")
	if not self[unit] then
		self[unit] = ElvUF:Spawn(unit, "ElvUF_"..frameName)
		self.units[unit] = unit
	end

	self[unit].Update = function()
		UF["Update_"..frameName.."Frame"](self, self[unit], self.db.units[unit])
	end

	if self[unit]:GetParent() ~= ElvUF_Parent then
		self[unit]:SetParent(ElvUF_Parent)
	end

	if self.db.units[unit].enable then
		self[unit]:Enable()
		self[unit].Update()
		E:EnableMover(self[unit].mover:GetName())
	else
		self[unit].Update()
		self[unit]:Disable()
		E:DisableMover(self[unit].mover:GetName())
	end
end

function UF:LoadUnits()
	for _, unit in pairs(self.unitstoload) do
		self:CreateAndUpdateUF(unit)
	end
	self.unitstoload = nil

	for group, groupOptions in pairs(self.unitgroupstoload) do
		local numGroup, template = unpack(groupOptions)
		self:CreateAndUpdateUFGroup(group, numGroup, template)
	end
	self.unitgroupstoload = nil

	for group, groupOptions in pairs(self.headerstoload) do
		local groupFilter, template, headerTemplate
		if type(groupOptions) == "table" then
			groupFilter, template, headerTemplate = unpack(groupOptions)
		end

		self:CreateAndUpdateHeaderGroup(group, groupFilter, template, nil, headerTemplate)
	end
	self.headerstoload = nil
end

function UF:RegisterRaidDebuffIndicator()
	local ORD = ns.oUF_RaidDebuffs or oUF_RaidDebuffs
	if ORD then
		ORD:ResetDebuffData()

		local _, instanceType = GetInstanceInfo()
		if instanceType == "party" or instanceType == "raid" then
			local instance = E.global.unitframe.raidDebuffIndicator.instanceFilter
			local instanceSpells = ((E.global.unitframe.aurafilters[instance] and E.global.unitframe.aurafilters[instance].spells) or E.global.unitframe.aurafilters.RaidDebuffs.spells)
			ORD:RegisterDebuffs(instanceSpells)
		else
			local other = E.global.unitframe.raidDebuffIndicator.otherFilter
			local otherSpells = ((E.global.unitframe.aurafilters[other] and E.global.unitframe.aurafilters[other].spells) or E.global.unitframe.aurafilters.CCDebuffs.spells)
			ORD:RegisterDebuffs(otherSpells)
		end
	end
end

function UF:UpdateAllHeaders(event)
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateAllHeaders")
		return
	end

	if event == "PLAYER_REGEN_ENABLED" then
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end

	if E.private.unitframe.disabledBlizzardFrames.party then
		ElvUF:DisableBlizzard("party")
	end

	self:RegisterRaidDebuffIndicator()

	local smartRaidFilterEnabled = self.db.smartRaidFilter
	for group, header in pairs(self.headers) do
		UF.headerFunctions[group]:Update(header)

		local shouldUpdateHeader
		if header.numGroups == nil or smartRaidFilterEnabled then
			shouldUpdateHeader = false
		elseif header.numGroups ~= nil and not smartRaidFilterEnabled then
			shouldUpdateHeader = true
		end
		self:CreateAndUpdateHeaderGroup(group, nil, nil, shouldUpdateHeader)

		if group == "party" or group == "raid" or group == "raid40" then
			--Update BuffIndicators on profile change as they might be using profile specific data
			self:UpdateAuraWatchFromHeader(group)
		end
	end
end

local hiddenParent = CreateFrame("Frame")
hiddenParent:SetAllPoints()
hiddenParent:Hide()
local HandleFrame = function(baseName)
	local frame
	if type(baseName) == "string" then
		frame = _G[baseName]
	else
		frame = baseName
	end

	if frame then
		frame:UnregisterAllEvents()
		frame:Hide()

		-- Keep frame hidden without causing taint
		frame:SetParent(hiddenParent)

		local health = frame.healthbar
		if health then
			health:UnregisterAllEvents()
		end

		local power = frame.manabar
		if power then
			power:UnregisterAllEvents()
		end

		local spell = frame.spellbar
		if spell then
			spell:UnregisterAllEvents()
		end
	end
end

function ElvUF:DisableBlizzard(unit)
	if (not unit) or InCombatLockdown() then return end

	if (unit == "player") and E.private.unitframe.disabledBlizzardFrames.player then
		HandleFrame(PlayerFrame)

		-- For the damn vehicle support:
		PlayerFrame:RegisterEvent("UNIT_ENTERING_VEHICLE")
		PlayerFrame:RegisterEvent("UNIT_ENTERED_VEHICLE")
		PlayerFrame:RegisterEvent("UNIT_EXITING_VEHICLE")
		PlayerFrame:RegisterEvent("UNIT_EXITED_VEHICLE")

		RuneFrame:SetParent(PlayerFrame)
	elseif (unit == "pet") and E.private.unitframe.disabledBlizzardFrames.player then
		HandleFrame(PetFrame)
	elseif (unit == "target") and E.private.unitframe.disabledBlizzardFrames.target then
		HandleFrame(TargetFrame)
		HandleFrame(ComboFrame)
	elseif (unit == "focus") and E.private.unitframe.disabledBlizzardFrames.focus then
		HandleFrame(FocusFrame)
		HandleFrame(FocusFrameToT)
	elseif (unit == "targettarget") and E.private.unitframe.disabledBlizzardFrames.target then
		HandleFrame(TargetFrameToT)
	elseif (unit:match"(boss)%d?$" == "boss") and E.private.unitframe.disabledBlizzardFrames.boss then
		local id = unit:match"boss(%d)"

		if id then
			HandleFrame("Boss"..id.."TargetFrame")
		else
			for i = 1, MAX_BOSS_FRAMES do
				HandleFrame(format("Boss%dTargetFrame", i))
			end
		end
	elseif (unit:match"(party)%d?$" == "party") and E.private.unitframe.disabledBlizzardFrames.party then
		local id = unit:match"party(%d)"

		if id then
			HandleFrame("PartyMemberFrame"..id)
		else
			for i = 1, 4 do
				HandleFrame(format("PartyMemberFrame%d", i))
			end
		end
		HandleFrame(PartyMemberBackground)
	elseif (unit:match"(arena)%d?$" == "arena") and E.private.unitframe.disabledBlizzardFrames.arena then
		local id = unit:match"arena(%d)"

		if id then
			HandleFrame("ArenaEnemyFrame"..id)
			HandleFrame("ArenaEnemyFrame"..id.."PetFrame")
		else
			for i = 1, 5 do
				HandleFrame(format("ArenaEnemyFrame%d", i))
				HandleFrame(format("ArenaEnemyFrame%dPetFrame", i))
			end
		end
	end
end

function UF:ADDON_LOADED(_, addon)
	if addon ~= "Blizzard_ArenaUI" then return end

	ElvUF:DisableBlizzard("arena")
	self:UnregisterEvent("ADDON_LOADED")
end

do
	local hasEnteredWorld = false
	function UF:PLAYER_ENTERING_WORLD()
		if not hasEnteredWorld then
			--We only want to run Update_AllFrames once when we first log in or /reload
			UF:Update_AllFrames()
			hasEnteredWorld = true
		else
			local _, instanceType = IsInInstance()
			if instanceType ~= "none" then
				--We need to update headers when we zone into an instance
				UF:UpdateAllHeaders()
			end
		end
	end
end

function UF:UnitFrameThreatIndicator_Initialize(_, unitFrame)
	unitFrame:UnregisterAllEvents() --Arena Taint Fix
end

function UF:ResetUnitSettings(unit)
	E:CopyTable(self.db.units[unit], P.unitframe.units[unit])

	if self.db.units[unit].buffs and self.db.units[unit].buffs.sizeOverride then
		self.db.units[unit].buffs.sizeOverride = P.unitframe.units[unit].buffs.sizeOverride or 0
	end

	if self.db.units[unit].debuffs and self.db.units[unit].debuffs.sizeOverride then
		self.db.units[unit].debuffs.sizeOverride = P.unitframe.units[unit].debuffs.sizeOverride or 0
	end

	self:Update_AllFrames()
end

function UF:ToggleForceShowGroupFrames(unitGroup, numGroup)
	for i = 1, numGroup do
		if self[unitGroup..i] and not self[unitGroup..i].isForced then
			UF:ForceShow(self[unitGroup..i])
		elseif self[unitGroup..i] then
			UF:UnforceShow(self[unitGroup..i])
		end
	end
end

local ignoreSettings = {
	["position"] = true,
	["priority"] = true
}

local ignoreSettingsGroup = {
	["visibility"] = true
}

local allowPass = {
	["sizeOverride"] = true
}

function UF:MergeUnitSettings(fromUnit, toUnit, isGroupUnit)
	local db = self.db.units
	local filter = ignoreSettings
	if isGroupUnit then
		filter = ignoreSettingsGroup
	end
	if fromUnit ~= toUnit then
		for option, value in pairs(db[fromUnit]) do
			if type(value) ~= "table" and not filter[option] then
				if db[toUnit][option] ~= nil then
					db[toUnit][option] = value
				end
			elseif not filter[option] then
				if type(value) == "table" then
					for opt, val in pairs(db[fromUnit][option]) do
						--local val = db[fromUnit][option][opt]
						if type(val) ~= "table" and not filter[opt] then
							if db[toUnit][option] ~= nil and (db[toUnit][option][opt] ~= nil or allowPass[opt]) then
								db[toUnit][option][opt] = val
							end
						elseif not filter[opt] then
							if type(val) == "table" then
								for o, v in pairs(db[fromUnit][option][opt]) do
									if not filter[o] then
										if db[toUnit][option] ~= nil and db[toUnit][option][opt] ~= nil and db[toUnit][option][opt][o] ~= nil then
											db[toUnit][option][opt][o] = v
										end
									end
								end
							end
						end
					end
				end
			end
		end
	else
		E:Print(L["You cannot copy settings from the same unit."])
	end

	self:Update_AllFrames()
end

function UF:UpdateBackdropTextureColor(r, g, b)
	local m = 0.35
	local n = self.isTransparent and (m * 2) or m

	if self.invertColors then
		local nn = n;n=m;m=nn
	end

	if self.isTransparent then
		if self.backdrop then
			local _, _, _, a = self.backdrop:GetBackdropColor()
			self.backdrop:SetBackdropColor(r * n, g * n, b * n, a)
		else
			local parent = self:GetParent()
			if parent and parent.template then
				local _, _, _, a = parent:GetBackdropColor()
				parent:SetBackdropColor(r * n, g * n, b * n, a)
			end
		end
	end

	local bg = self.bg or self.BG
	if bg and bg:IsObjectType("Texture") and not bg.multiplier then
		if self.custom_backdrop then
			bg:SetVertexColor(self.custom_backdrop.r, self.custom_backdrop.g, self.custom_backdrop.b)
		else
			bg:SetVertexColor(r * m, g * m, b * m)
		end
	end
end

function UF:UpdatePredictionStatusBar(prediction, parent)
	if not (prediction and parent) then return end
	local texture = (not parent.isTransparent and parent:GetStatusBarTexture():GetTexture()) or E.media.blankTex

	UF:Update_StatusBar(prediction.myBar, texture)
	UF:Update_StatusBar(prediction.otherBar, texture)
end

function UF:SetStatusBarBackdropPoints(statusBar, statusBarTex, backdropTex, statusBarOrientation)
	backdropTex:ClearAllPoints()
	if statusBarOrientation == "VERTICAL" then
		backdropTex:SetPoint("TOPLEFT", statusBar)
		backdropTex:SetPoint("BOTTOMRIGHT", statusBarTex, "TOPRIGHT")
	else
		backdropTex:SetPoint("TOPRIGHT", statusBar)
		backdropTex:SetPoint("BOTTOMLEFT", statusBarTex, "BOTTOMRIGHT")
	end
end

function UF:ToggleTransparentStatusBar(isTransparent, statusBar, backdropTex, adjustBackdropPoints, invertColors)
	statusBar.isTransparent = isTransparent
	statusBar.invertColors = invertColors
	statusBar.backdropTex = backdropTex

	local statusBarTex = statusBar:GetStatusBarTexture()
	local statusBarOrientation = statusBar:GetOrientation()

	if not statusBar.hookedColor then
		hooksecurefunc(statusBar, "SetStatusBarColor", UF.UpdateBackdropTextureColor)
		statusBar.hookedColor = true
	end

	if isTransparent then
		if statusBar.backdrop then
			statusBar.backdrop:SetTemplate("Transparent", nil, nil, nil, true)
		elseif statusBar:GetParent().template then
			statusBar:GetParent():SetTemplate("Transparent", nil, nil, nil, true)
		end

		statusBar:SetStatusBarTexture("")
		UF:Update_StatusBar(statusBar.bg or statusBar.BG, E.media.blankTex)

		if statusBar.texture then statusBar.texture = statusBar:GetStatusBarTexture() end --Needed for Power element

		UF:SetStatusBarBackdropPoints(statusBar, statusBarTex, backdropTex, statusBarOrientation)
	else
		if statusBar.backdrop then
			statusBar.backdrop:SetTemplate(nil, nil, nil, not statusBar.PostCastStart and self.thinBorders, true)
		elseif statusBar:GetParent().template then
			statusBar:GetParent():SetTemplate(nil, nil, nil, self.thinBorders, true)
		end

		local texture = LSM:Fetch("statusbar", self.db.statusbar)
		statusBar:SetStatusBarTexture(texture)
		UF:Update_StatusBar(statusBar.bg or statusBar.BG, texture)

		if statusBar.texture then statusBar.texture = statusBar:GetStatusBarTexture() end

		if adjustBackdropPoints then
			backdropTex:ClearAllPoints()
			backdropTex:SetAllPoints(statusBar)
		end
	end
end

function UF:Initialize()
	self.db = E.db.unitframe
	self.thinBorders = self.db.thinBorders or E.PixelMode
	if E.private.unitframe.enable ~= true then return end
	self.Initialized = true

	local ElvUF_Parent = CreateFrame("Frame", "ElvUF_Parent", E.UIParent, "SecureHandlerStateTemplate")
	ElvUF_Parent:SetFrameStrata("LOW")

	self:UpdateColors()
	ElvUF:RegisterStyle("ElvUF", function(frame, unit)
		self:Construct_UF(frame, unit)
	end)

	self:LoadUnits()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")

	for k in pairs(UnitPopupMenus) do
		for x, y in pairs(UnitPopupMenus[k]) do
			if y == "SET_FOCUS" or y == "CLEAR_FOCUS" or y == "LOCK_FOCUS_FRAME" or y == "UNLOCK_FOCUS_FRAME" or (E.myclass == "HUNTER" and y == "PET_DISMISS") then
				tremove(UnitPopupMenus[k], x)
			end
		end
	end

	if E.private.unitframe.disabledBlizzardFrames.arena and E.private.unitframe.disabledBlizzardFrames.focus and E.private.unitframe.disabledBlizzardFrames.party then
		InterfaceOptionsFrameCategoriesButton10:SetScale(0.0001)
	end

	if E.private.unitframe.disabledBlizzardFrames.player then
		InterfaceOptionsStatusTextPanelPlayer:SetScale(0.0001)
		InterfaceOptionsStatusTextPanelPlayer:SetAlpha(0)
		InterfaceOptionsStatusTextPanelPet:SetScale(0.0001)
		InterfaceOptionsStatusTextPanelPet:SetAlpha(0)
	end

	if E.private.unitframe.disabledBlizzardFrames.target then
		InterfaceOptionsStatusTextPanelTarget:SetScale(0.0001)
		InterfaceOptionsStatusTextPanelTarget:SetAlpha(0)
		InterfaceOptionsCombatPanelEnemyCastBarsOnPortrait:SetAlpha(0)
		InterfaceOptionsCombatPanelEnemyCastBarsOnPortrait:EnableMouse(false)
		InterfaceOptionsCombatPanelEnemyCastBarsOnNameplates:ClearAllPoints()
		InterfaceOptionsCombatPanelEnemyCastBarsOnNameplates:Point(InterfaceOptionsCombatPanelEnemyCastBarsOnPortrait:GetPoint())
		InterfaceOptionsCombatPanelTargetOfTarget:SetScale(0.0001)
		InterfaceOptionsCombatPanelTargetOfTarget:SetAlpha(0)
		InterfaceOptionsDisplayPanelShowAggroPercentage:SetScale(0.0001)
		InterfaceOptionsDisplayPanelShowAggroPercentage:SetAlpha(0)
	end

	if E.private.unitframe.disabledBlizzardFrames.party then
		InterfaceOptionsStatusTextPanelParty:SetScale(0.0001)
		InterfaceOptionsStatusTextPanelParty:SetAlpha(0)
		InterfaceOptionsFrameCategoriesButton11:SetScale(0.0001)
	end

	if E.private.unitframe.disabledBlizzardFrames.arena then
		self:SecureHook("UnitFrameThreatIndicator_Initialize")

		if not IsAddOnLoaded("Blizzard_ArenaUI") then
			self:RegisterEvent("ADDON_LOADED")
		else
			ElvUF:DisableBlizzard("arena")
		end
	end

	local ORD = ns.oUF_RaidDebuffs or oUF_RaidDebuffs
	if ORD then
		ORD.ShowDispellableDebuff = true
		ORD.FilterDispellableDebuff = true
		ORD.MatchBySpellName = true
	end

	self:UpdateRangeCheckSpells()
	self:RegisterEvent("LEARNED_SPELL_IN_TAB", "UpdateRangeCheckSpells")
end

local function InitializeCallback()
	UF:Initialize()
end

E:RegisterInitialModule(UF:GetName(), InitializeCallback)