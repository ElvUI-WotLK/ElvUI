local parent, ns = ...
local global = GetAddOnMetadata(parent, "X-oUF")
local _VERSION = GetAddOnMetadata(parent, "version")

local oUF = ns.oUF
local Private = oUF.Private

local upper, lower = string.upper, string.lower
local split = string.split
local tinsert, tremove = table.insert, table.remove

local UnitExists = UnitExists
local CreateFrame = CreateFrame
local UnitIsUnit = UnitIsUnit
local UnitIsPlayer = UnitIsPlayer
local UnitInRaid = UnitInRaid
local UnitInParty = UnitInParty

local argcheck = Private.argcheck

local print = Private.print
local error = Private.error

local styles, style = {}
local callback, objects, headers = {}, {}, {}

local elements = {}
local activeElements = {}

local enableTargetUpdate = function(object)
	object.onUpdateFrequency = object.onUpdateFrequency or .5
	object.__eventless = true

	local total = 0
	object:SetScript("OnUpdate", function(self, elapsed)
		if(not self.unit) then
			return
		elseif(total > self.onUpdateFrequency) then
			self:UpdateAllElements("OnUpdate")
			total = 0
		end

		total = total + elapsed
	end)
end
Private.enableTargetUpdate = enableTargetUpdate

local updateActiveUnit = function(self, event, unit)
	local realUnit, modUnit = SecureButton_GetUnit(self), SecureButton_GetModifiedUnit(self)

	if(realUnit == "playerpet") then
		realUnit = "pet"
	elseif(realUnit == "playertarget") then
		realUnit = "target"
	end

	if(modUnit == "pet" and realUnit ~= "pet") then
		modUnit = "vehicle"
	end

	if(not UnitExists(modUnit)) then
		if(modUnit ~= realUnit) then
			modUnit = realUnit
		else
			return
		end
	end

	if(Private.UpdateUnits(self, modUnit, realUnit)) then
		self:UpdateAllElements("RefreshUnit")

		return true
	end
end

local iterateChildren = function(...)
	for l = 1, select("#", ...) do
		local obj = select(l, ...)

		if(type(obj) == "table" and obj.isChild) then
			updateActiveUnit(obj, "iterateChildren")
		end
	end
end

local OnAttributeChanged = function(self, name, value)
	if(name == "unit" and value) then
		if(self.unit and self.unit == value) then
			return
		else
			if(self.hasChildren) then
				iterateChildren(self:GetChildren())
			end
		end
	end
end

local frame_metatable = {
	__index = CreateFrame("Button")
}
Private.frame_metatable = frame_metatable

for k, v in pairs{
	EnableElement = function(self, name, unit)
		argcheck(name, 2, "string")
		argcheck(unit, 3, "string", "nil")

		local element = elements[name]
		if(not element or self:IsElementEnabled(name) or not activeElements[self]) then return end

		if(element.enable(self, unit or self.unit)) then
			activeElements[self][name] = true

			if(element.update) then
				tinsert(self.__elements, element.update)
			end
		end
	end,

	DisableElement = function(self, name)
		argcheck(name, 2, "string")

		local enabled = self:IsElementEnabled(name)
		if(not enabled) then return end

		local update = elements[name].update
		for k, func in next, self.__elements do
			if(func == update) then
				tremove(self.__elements, k)
				break
			end
		end

		activeElements[self][name] = nil

		self:UpdateAllElements("DisableElement", name)

		return elements[name].disable(self)
	end,

	IsElementEnabled = function(self, name)
		argcheck(name, 2, "string")

		local element = elements[name]
		if(not element) then return end

		local active = activeElements[self]
		return active and active[name]
	end,

	Enable = RegisterUnitWatch,
	Disable = function(self)
		UnregisterUnitWatch(self)
		self:Hide()
	end,

	UpdateAllElements = function(self, event)
		local unit = self.unit
		if(not unit or not UnitExists(unit)) then return end

		assert(type(event) == "string", "Invalid argument 'event' in UpdateAllElements.")

		if(self.PreUpdate) then
			self:PreUpdate(event)
		end

		for _, func in next, self.__elements do
			func(self, event, unit)
		end

		if(self.PostUpdate) then
			self:PostUpdate(event)
		end
	end,

	UpdateElement = function(self, name)
		local unit = self.unit
		if(not unit or not UnitExists(unit)) then return end

		local element = elements[name]
		if(not element or not self:IsElementEnabled(name) or not activeElements[self]) then return end
		if(element.update) then
			element.update(self, "OnShow", unit)
		end
	end,
} do
	frame_metatable.__index[k] = v
end

local secureDropdown
local InitializeSecureMenu = function(self)
	local unit = self.unit
	if(not unit) then return end

	local unitType = string.match(unit, "^([a-z]+)[0-9]+$") or unit

	local menu
	if(unitType == "party") then
		menu = "PARTY"
	elseif(unitType == "boss") then
		menu = "BOSS"
	elseif(unitType == "focus") then
		menu = "FOCUS"
	elseif(unitType == "arenapet" or unitType == "arena") then
		menu = "ARENAENEMY"
	elseif(UnitIsUnit(unit, "player")) then
		menu = "SELF"
	elseif(UnitIsUnit(unit, "vehicle")) then
		menu = "VEHICLE"
	elseif(UnitIsUnit(unit, "pet")) then
		menu = "PET"
	elseif(UnitIsPlayer(unit)) then
		if(UnitInRaid(unit)) then
			menu = "RAID_PLAYER"
		elseif(UnitInParty(unit)) then
			menu = "PARTY"
		else
			menu = "PLAYER"
		end
	elseif(UnitIsUnit(unit, "target")) then
		menu = "TARGET"
	end

	if(menu) then
		UnitPopup_ShowMenu(self, menu, unit)
	end
end

local togglemenu = function(self, unit)
	if(not secureDropdown) then
		secureDropdown = CreateFrame("Frame", "SecureTemplatesDropdown", nil, "UIDropDownMenuTemplate")
		secureDropdown:SetID(1)

		tinsert(UnitPopupFrames, secureDropdown:GetName())
		UIDropDownMenu_Initialize(secureDropdown, InitializeSecureMenu, "MENU")
	end

	if(secureDropdown.openedFor and secureDropdown.openedFor ~= self) then
		CloseDropDownMenus()
	end

	secureDropdown.unit = lower(unit)
	secureDropdown.openedFor = self

	ToggleDropDownMenu(1, nil, secureDropdown, "cursor")
end

local OnShow = function(self)
	if(not updateActiveUnit(self, "OnShow")) then
		return self:UpdateAllElements("OnShow")
	end
end

local UpdatePet = function(self, event, unit)
	local petUnit
	if(unit == "target") then
		return
	elseif(unit == "player") then
		petUnit = "pet"
	else
		petUnit = unit:gsub("^(%a+)(%d+)", "%1pet%2")
	end

	if(self.unit ~= petUnit) then return end
	if(not updateActiveUnit(self, event)) then
		return self:UpdateAllElements(event)
	end
end

local initObject = function(unit, style, styleFunc, header, ...)
	local num = select("#", ...)
	for i = 1, num do
		local object = select(i, ...)
		local objectUnit = object.guessUnit or unit
		local suffix = object:GetAttribute("unitsuffix")

		object.__elements = {}
		object.style = style
		object = setmetatable(object, frame_metatable)

		tinsert(objects, object)

		object:RegisterEvent("PLAYER_ENTERING_WORLD", object.UpdateAllElements)

		if(suffix and objectUnit and not objectUnit:match(suffix)) then
			objectUnit = objectUnit .. suffix
		end

		if(not (suffix == "target" or objectUnit and objectUnit:match"target")) then
			object:RegisterEvent("UNIT_ENTERED_VEHICLE", updateActiveUnit)
			object:RegisterEvent("UNIT_EXITING_VEHICLE", updateActiveUnit)
			object:RegisterEvent("PLAYER_ENTERING_WORLD", updateActiveUnit)

			if(objectUnit ~= "player") then
				object:RegisterEvent("UNIT_PET", UpdatePet, true)
			end
		end

		if(not header) then
			object.menu = togglemenu
			object:SetAttribute("*type1", "target")
			object:SetAttribute("*type2", "menu")

		--	if(not (objectUnit:match"target" or suffix == "target")) then
			if(not (unit:match"target" or suffix == "target")) then
				object:SetAttribute("toggleForVehicle", true)
			end

			if(suffix == "target") then
				enableTargetUpdate(object)
			else
				oUF:HandleUnit(object)
			end
		else
			object:RegisterEvent("RAID_ROSTER_UPDATE", object.UpdateAllElements)

			if(num > 1) then
				if(object:GetParent() == header) then
					object.hasChildren = true
				else
					object.isChild = true
				end
			end

			if(suffix == "target") then
				enableTargetUpdate(object)
			end
		end

		Private.UpdateUnits(object, objectUnit)

		styleFunc(object, objectUnit, not header)

		object:SetScript("OnAttributeChanged", OnAttributeChanged)
		object:SetScript("OnShow", OnShow)

		activeElements[object] = {}
		for element in next, elements do
			object:EnableElement(element, objectUnit)
		end

		for _, func in next, callback do
			func(object)
		end

		_G.ClickCastFrames = ClickCastFrames or {}
		ClickCastFrames[object] = true
	end
end

local walkObject = function(object, unit)
	local parent = object:GetParent()
	local style = parent.style or style
	local styleFunc = styles[style]

	local header = parent.headerType and parent

	return initObject(unit, style, styleFunc, header, object, object:GetChildren())
end

function oUF:RegisterInitCallback(func)
	tinsert(callback, func)
end

function oUF:RegisterMetaFunction(name, func)
	argcheck(name, 2, "string")
	argcheck(func, 3, "function", "table")

	if(frame_metatable.__index[name]) then
		return
	end

	frame_metatable.__index[name] = func
end

function oUF:RegisterStyle(name, func)
	argcheck(name, 2, "string")
	argcheck(func, 3, "function", "table")

	if(styles[name]) then return error("Style [%s] already registered.", name) end
	if(not style) then style = name end

	styles[name] = func
end

function oUF:SetActiveStyle(name)
	argcheck(name, 2, "string")
	if(not styles[name]) then return error("Style [%s] does not exist.", name) end

	style = name
end

do
	local function iter(_, n)
		return (next(styles, n))
	end

	function oUF.IterateStyles()
		return iter, nil, nil
	end
end

local getCondition
do
	local conditions = {
		raid40 = "[@raid26,exists] show;",
		raid25 = "[@raid11,exists] show;",
		raid10 = "[@raid6,exists] show;",
		raid = "[group:raid] show;",
		party = "[group:party,nogroup:raid] show;",
		solo = "[@player,exists,nogroup:party] show;",
	}

	function getCondition(...)
		local cond = ""

		for i=1, select("#", ...) do
			local short = select(i, ...)

			local condition = conditions[short]
			if(condition) then
				cond = cond .. condition
			end
		end

		return cond .. "hide"
	end
end

local generateName = function(unit, ...)
	local name = "oUF_" .. style:gsub("[^%a%d_]+", "")

	local raid, party, groupFilter
	for i=1, select("#", ...), 2 do
		local att, val = select(i, ...)
		if(att == "showRaid") then
			raid = true
		elseif(att == "showParty") then
			party = true
		elseif(att == "groupFilter") then
			groupFilter = val
		end
	end

	local append
	if(raid) then
		if(groupFilter) then
			if(type(groupFilter) == "number" and groupFilter > 0) then
				append = groupFilter
			elseif(groupFilter:match("TANK")) then
				append = "MainTank"
			elseif(groupFilter:match("ASSIST")) then
				append = "MainAssist"
			else
				local _, count = groupFilter:gsub(",", "")
				if(count == 0) then
					append = groupFilter
				else
					append = "Raid"
				end
			end
		else
			append = "Raid"
		end
	elseif(party) then
		append = "Party"
	elseif(unit) then
		append = unit:gsub("^%l", upper)
	end

	if(append) then
		name = name .. append
	end

	local base = name
	local i = 2
	while(_G[name]) do
		name = base .. i
		i = i + 1
	end

	return name
end

do
	local styleProxy = function(self, frame)
		return walkObject(_G[frame])
	end

	local initialConfigFunction = function(self)
		local header = self:GetParent()
		for i = 1, select("#", self), 1 do
			local frame = select(i, self)
			local unit
			if(not frame.onlyProcessChildren) then
				local groupFilter = header:GetAttribute("groupFilter")

				if(type(groupFilter) == "string" and groupFilter:match("MAIN[AT]")) then
					local role = groupFilter:match("MAIN([AT])")
					if(role == "T") then
						unit = "maintank"
					else
						unit = "mainassist"
					end
				elseif(header:GetAttribute("showRaid")) then
					unit = "raid"
				elseif(header:GetAttribute("showParty")) then
					unit = "party"
				end

				local headerType = header.headerType
				local suffix = frame:GetAttribute("unitsuffix")
				if(unit and suffix) then
					if(headerType == "pet" and suffix == "target") then
						unit = unit .. headerType .. suffix
					else
						unit = unit .. suffix
					end
				elseif(unit and headerType == "pet") then
					unit = unit .. headerType
				end

				frame.menu = togglemenu
				frame:SetAttribute("type1", "target")
				frame:SetAttribute("type2", "menu")
				frame:SetAttribute("toggleForVehicle", true)
				frame.guessUnit = unit
			end
		end

		header:styleFunction(self:GetName())
	end

	function oUF:SpawnHeader(overrideName, template, visibility, ...)
		if(not style) then return error("Unable to create frame. No styles have been registered.") end

		template = (template or "SecureGroupHeaderTemplate")

		local isPetHeader = template:match("PetHeader")
		local name = overrideName or generateName(nil, ...)
		local header = CreateFrame("Frame", name, UIParent, template)

		header:SetAttribute("template", "oUF_ClickCastUnitTemplate")
		for i = 1, select("#", ...), 2 do
			local att, val = select(i, ...)
			if(not att) then break end
			header:SetAttribute(att, val)
		end

		header.style = style
		header.styleFunction = styleProxy
		header.initialConfigFunction = initialConfigFunction
		header.headerType = isPetHeader and "pet" or "group"

		if(header:GetAttribute("showParty")) then
			self:DisableBlizzard("party")
		end

		if(visibility) then
			local type, list = split(" ", visibility, 2)
			if(list and type == "custom") then
				RegisterStateDriver(header, "visibility", list)
				header.visibility = list
			else
				local condition = getCondition(split(",", visibility))
				RegisterStateDriver(header, "visibility", condition)
				header.visibility = condition
			end
		end

		return header
	end
end

function oUF:Spawn(unit, overrideName, overrideTemplate)
	argcheck(unit, 2, "string")
	if(not style) then return error("Unable to create frame. No styles have been registered.") end

	unit = unit:lower()

	local name = overrideName or generateName(unit)
	local object = CreateFrame("Button", name, UIParent, overrideTemplate or "SecureUnitButtonTemplate")
	Private.UpdateUnits(object, unit)

	self:DisableBlizzard(unit)
	walkObject(object, unit)

	object:SetAttribute("unit", unit)
	RegisterUnitWatch(object)

	return object
end

function oUF:AddElement(name, update, enable, disable)
	argcheck(name, 2, "string")
	argcheck(update, 3, "function", "nil")
	argcheck(enable, 4, "function", "nil")
	argcheck(disable, 5, "function", "nil")

	if(elements[name]) then return error("Element [%s] is already registered.", name) end
	elements[name] = {
		update = update,
		enable = enable,
		disable = disable,
	}
end

oUF.version = _VERSION
oUF.objects = objects
oUF.headers = headers

if(global) then
	if(parent ~= "oUF" and global == "oUF") then
		error("%s is doing it wrong and setting its global to oUF.", parent)
	else
		_G[global] = oUF
	end
end