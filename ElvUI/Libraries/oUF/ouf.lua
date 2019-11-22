local parent, ns = ...
local global = GetAddOnMetadata(parent, 'X-oUF')
local _VERSION = '@project-version@'
if(_VERSION:find('project%-version')) then
	_VERSION = 'devel'
end

local oUF = ns.oUF
local Private = oUF.Private

local argcheck = Private.argcheck
local error = Private.error
local print = Private.print
local unitExists = Private.unitExists

local styles, style = {}
local callback, objects, headers = {}, {}, {}

local elements = {}
local activeElements = {}

-- updating of "invalid" units.
local function enableTargetUpdate(object)
	object.onUpdateFrequency = object.onUpdateFrequency or .5
	object.__eventless = true

	local total = 0
	object:SetScript('OnUpdate', function(self, elapsed)
		if(not self.unit) then
			return
		elseif(total > self.onUpdateFrequency) then
			self:UpdateAllElements('OnUpdate')
			total = 0
		end

		total = total + elapsed
	end)
end
Private.enableTargetUpdate = enableTargetUpdate

local function updateActiveUnit(self, event, unit)
	-- Calculate units to work with
	local realUnit, modUnit = SecureButton_GetUnit(self), SecureButton_GetModifiedUnit(self)

	-- _GetUnit() doesn't rewrite playerpet -> pet like _GetModifiedUnit does.
	if(realUnit == 'playerpet') then
		realUnit = 'pet'
	elseif(realUnit == 'playertarget') then
		realUnit = 'target'
	end

	if(modUnit == 'pet' and realUnit ~= 'pet') then
		modUnit = 'vehicle'
	end

	if(not UnitExists(modUnit)) then
		if(modUnit ~= realUnit) then
			modUnit = realUnit
		else
			return
		end
	end

	-- Change the active unit and run a full update.
	if(Private.UpdateUnits(self, modUnit, realUnit)) then
		self:UpdateAllElements('RefreshUnit')

		return true
	end
end

local function iterateChildren(...)
	for i = 1, select('#', ...) do
		local obj = select(i, ...)

		if(type(obj) == 'table' and obj.isChild) then
			updateActiveUnit(obj, 'iterateChildren')
		end
	end
end

local function onAttributeChanged(self, name, value)
	if(name == 'unit' and value) then
		if(self.hasChildren) then
			iterateChildren(self:GetChildren())
		end

		if(not self.onlyProcessChildren) then
			updateActiveUnit(self, 'OnAttributeChanged')
		end
--[[
		if(self.unit and self.unit == value) then
			return
		else
			if(self.hasChildren) then
				iterateChildren(self:GetChildren())
			end
		end
]]
	end
end

local frame_metatable = {
	__index = CreateFrame('Button')
}
Private.frame_metatable = frame_metatable

for k, v in next, {
	UpdateElement = function(self, name)
		local unit = self.unit
		if(not unit or not UnitExists(unit)) then return end

		local element = elements[name]
		if(not element or not self:IsElementEnabled(name) or not activeElements[self]) then return end
		if(element.update) then
			element.update(self, 'OnShow', unit)
		end
	end,

	--[[ frame:EnableElement(name, unit)
	Used to activate an element for the given unit frame.

	* self - unit frame for which the element should be enabled
	* name - name of the element to be enabled (string)
	* unit - unit to be passed to the element's Enable function. Defaults to the frame's unit (string?)
	--]]
	EnableElement = function(self, name, unit)
		argcheck(name, 2, 'string')
		argcheck(unit, 3, 'string', 'nil')

		local element = elements[name]
		if(not element or self:IsElementEnabled(name)) then return end

		if(element.enable(self, unit or self.unit)) then
			activeElements[self][name] = true

			if(element.update) then
				table.insert(self.__elements, element.update)
			end
		end
	end,

	--[[ frame:DisableElement(name)
	Used to deactivate an element for the given unit frame.

	* self - unit frame for which the element should be disabled
	* name - name of the element to be disabled (string)
	--]]
	DisableElement = function(self, name)
		argcheck(name, 2, 'string')

		local enabled = self:IsElementEnabled(name)
		if(not enabled) then return end

		local update = elements[name].update
		for k, func in next, self.__elements do
			if(func == update) then
				table.remove(self.__elements, k)
				break
			end
		end

		activeElements[self][name] = nil

		-- We need to run a new update cycle in-case we knocked ourself out of sync.
		-- The main reason we do this is to make sure the full update is completed
		-- if an element for some reason removes itself _during_ the update
		-- progress.
		self:UpdateAllElements('DisableElement')

		return elements[name].disable(self)
	end,

	--[[ frame:IsElementEnabled(name)
	Used to check if an element is enabled on the given frame.

	* self - unit frame
	* name - name of the element (string)
	--]]
	IsElementEnabled = function(self, name)
		argcheck(name, 2, 'string')

		local element = elements[name]
		if(not element) then return end

		local active = activeElements[self]
		return active and active[name]
	end,

	--[[ frame:Enable(asState)
	Used to toggle the visibility of a unit frame based on the existence of its unit. This is a reference to
	`RegisterUnitWatch`.

	* self    - unit frame
	* asState - if true, the frame's "state-unitexists" attribute will be set to a boolean value denoting whether the
	            unit exists; if false, the frame will be shown if its unit exists, and hidden if it does not (boolean)
	--]]
	Enable = RegisterUnitWatch,
	--[[ frame:Disable()
	Used to UnregisterUnitWatch for the given frame and hide it.

	* self - unit frame
	--]]
	Disable = function(self)
		UnregisterUnitWatch(self)
		self:Hide()
	end,
	--[[ frame:IsEnabled()
	Used to check if a unit frame is registered with the unit existence monitor. This is a reference to
	`UnitWatchRegistered`.

	* self - unit frame
	--]]
	IsEnabled = UnitWatchRegistered,
	--[[ frame:UpdateAllElements(event)
	Used to update all enabled elements on the given frame.

	* self  - unit frame
	* event - event name to pass to the elements' update functions (string)
	--]]
	UpdateAllElements = function(self, event)
		local unit = self.unit
		if(not unitExists(unit)) then return end

		assert(type(event) == 'string', "Invalid argument 'event' in UpdateAllElements.")

		if(self.PreUpdate) then
			--[[ Callback: frame:PreUpdate(event)
			Fired before the frame is updated.

			* self  - the unit frame
			* event - the event triggering the update (string)
			--]]
			self:PreUpdate(event)
		end

		for _, func in next, self.__elements do
			func(self, event, unit)
		end

		if(self.PostUpdate) then
			--[[ Callback: frame:PostUpdate(event)
			Fired after the frame is updated.

			* self  - the unit frame
			* event - the event triggering the update (string)
			--]]
			self:PostUpdate(event)
		end
	end,
} do
	frame_metatable.__index[k] = v
end

local secureDropdown
local function InitializeSecureMenu(self)
	local unit = self.unit
	if(not unit) then return end

	local unitType = string.match(unit, '^([a-z]+)[0-9]+$') or unit

	local menu
	if(unitType == 'party') then
		menu = 'PARTY'
	elseif(unitType == 'boss') then
		menu = 'BOSS'
	elseif(unitType == 'focus') then
		menu = 'FOCUS'
	elseif(unitType == 'arenapet' or unitType == 'arena') then
		menu = 'ARENAENEMY'
	elseif(UnitIsUnit(unit, 'player')) then
		menu = 'SELF'
	elseif(UnitIsUnit(unit, 'vehicle')) then
		menu = 'VEHICLE'
	elseif(UnitIsUnit(unit, 'pet')) then
		menu = 'PET'
	elseif(UnitIsPlayer(unit)) then
		if(UnitInRaid(unit)) then
			menu = 'RAID_PLAYER'
		elseif(UnitInParty(unit)) then
			menu = 'PARTY'
		else
			menu = 'PLAYER'
		end
	elseif(UnitIsUnit(unit, 'target')) then
		menu = 'TARGET'
	end

	if(menu) then
		UnitPopup_ShowMenu(self, menu, unit)
	end
end

local function togglemenu(self, unit)
	if(not secureDropdown) then
		secureDropdown = CreateFrame('Frame', 'SecureTemplatesDropdown', nil, 'UIDropDownMenuTemplate')
		secureDropdown:SetID(1)

		table.insert(UnitPopupFrames, secureDropdown:GetName())
		UIDropDownMenu_Initialize(secureDropdown, InitializeSecureMenu, 'MENU')
	end

	if(secureDropdown.openedFor and secureDropdown.openedFor ~= self) then
		CloseDropDownMenus()
	end

	secureDropdown.unit = string.lower(unit)
	secureDropdown.openedFor = self

	ToggleDropDownMenu(1, nil, secureDropdown, 'cursor')
end

local function onShow(self)
	if(not updateActiveUnit(self, 'OnShow')) then
		return self:UpdateAllElements('OnShow')
	end
end

local function updatePet(self, event, unit)
	local petUnit
	if(unit == 'target') then
		return
	elseif(unit == 'player') then
		petUnit = 'pet'
	else
		-- Convert raid26 -> raidpet26
		petUnit = unit:gsub('^(%a+)(%d+)', '%1pet%2')
	end

	if(self.unit ~= petUnit) then return end
	if(not updateActiveUnit(self, event)) then
		return self:UpdateAllElements(event)
	end
end

local function updateRaid(self, event)
	local unitGUID = UnitGUID(self.unit)
	if(unitGUID and unitGUID ~= self.unitGUID) then
		self.unitGUID = unitGUID

		self:UpdateAllElements(event)
	end
end

local function initObject(unit, style, styleFunc, header, ...)
	local num = select('#', ...)
	for i = 1, num do
		local object = select(i, ...)
		local objectUnit = object.guessUnit or unit
		local suffix = object:GetAttribute('unitsuffix')

		object.__elements = {}
		object.style = style
		object = setmetatable(object, frame_metatable)

		-- Expose the frame through oUF.objects.
		table.insert(objects, object)

		-- We have to force update the frames when PEW fires.
		object:RegisterEvent('PLAYER_ENTERING_WORLD', object.UpdateAllElements)

		-- Handle the case where someone has modified the unitsuffix attribute in
		-- oUF-initialConfigFunction.
		if(suffix and objectUnit and not objectUnit:match(suffix)) then
			objectUnit = objectUnit .. suffix
		end

		if(not (suffix == 'target' or objectUnit and objectUnit:match('target'))) then
			object:RegisterEvent('UNIT_ENTERING_VEHICLE', updateActiveUnit)
			object:RegisterEvent('UNIT_ENTERED_VEHICLE', updateActiveUnit)
			object:RegisterEvent('UNIT_EXITING_VEHICLE', updateActiveUnit)
			object:RegisterEvent('PLAYER_ENTERING_WORLD', updateActiveUnit)

			-- We don't need to register UNIT_PET for the player unit. We register it
			-- mainly because UNIT_EXITED_VEHICLE and UNIT_ENTERED_VEHICLE doesn't always
			-- have pet information when they fire for party and raid units.
			if(objectUnit ~= 'player') then
				object:RegisterEvent('UNIT_PET', updatePet, true)
			end
		end

		if(not header) then
			-- No header means it's a frame created through :Spawn().
			object.menu = togglemenu
			object:SetAttribute('*type1', 'target')
			object:SetAttribute('*type2', 'menu')

			-- No need to enable this for *target frames.
			if(not (unit:match('target') or suffix == 'target')) then
				object:SetAttribute('toggleForVehicle', true)
			end

			-- Other boss and target units are handled by :HandleUnit().
			if(suffix == 'target') then
				enableTargetUpdate(object)
			else
				oUF:HandleUnit(object)
			end
		else
			-- update the frame when its prev unit is replaced with a new one
			-- updateRaid relies on UnitGUID to detect the unit change
			object:RegisterEvent('RAID_ROSTER_UPDATE', updateRaid)

			if(num > 1) then
				if(object:GetParent() == header) then
					object.hasChildren = true
				else
					object.isChild = true
				end
			end

			if(suffix == 'target') then
				enableTargetUpdate(object)
			end
		end

		activeElements[object] = {} -- ElvUI: styleFunc on headers break before this is set when they try to enable elements before it's set.

		Private.UpdateUnits(object, objectUnit)

		styleFunc(object, objectUnit, not header)

		object:HookScript('OnAttributeChanged', onAttributeChanged)
		object:SetScript('OnShow', onShow)

		for element in next, elements do
			object:EnableElement(element, objectUnit)
		end

		for _, func in next, callback do
			func(object)
		end

		-- ElvUI block
		if object.PostCreate then
			object:PostCreate(object)
		end
		-- end block

		-- Make Clique kinda happy
		_G.ClickCastFrames = ClickCastFrames or {}
		ClickCastFrames[object] = true
	end
end

local function walkObject(object, unit)
	local parent = object:GetParent()
	local style = parent.style or style
	local styleFunc = styles[style]

	local header = parent.headerType and parent

	-- Check if we should leave the main frame blank.
	if(object.onlyProcessChildren) then
		object.hasChildren = true
		object:HookScript('OnAttributeChanged', onAttributeChanged)
		return initObject(unit, style, styleFunc, header, object:GetChildren())
	end

	return initObject(unit, style, styleFunc, header, object, object:GetChildren())
end

--[[ oUF:RegisterInitCallback(func)
Used to add a function to a table to be executed upon unit frame/header initialization.

* self - the global oUF object
* func - function to be added
--]]
function oUF:RegisterInitCallback(func)
	table.insert(callback, func)
end

--[[ oUF:RegisterMetaFunction(name, func)
Used to make a (table of) function(s) available to all unit frames.

* self - the global oUF object
* name - unique name of the function (string)
* func - function or a table of functions (function or table)
--]]
function oUF:RegisterMetaFunction(name, func)
	argcheck(name, 2, 'string')
	argcheck(func, 3, 'function', 'table')

	if(frame_metatable.__index[name]) then
		return
	end

	frame_metatable.__index[name] = func
end

--[[ oUF:RegisterStyle(name, func)
Used to register a style with oUF. This will also set the active style if it hasn't been set yet.

* self - the global oUF object
* name - name of the style
* func - function(s) defining the style (function or table)
--]]
function oUF:RegisterStyle(name, func)
	argcheck(name, 2, 'string')
	argcheck(func, 3, 'function', 'table')

	if(styles[name]) then return error('Style [%s] already registered.', name) end
	if(not style) then style = name end

	styles[name] = func
end

--[[ oUF:SetActiveStyle(name)
Used to set the active style.

* self - the global oUF object
* name - name of the style (string)
--]]
function oUF:SetActiveStyle(name)
	argcheck(name, 2, 'string')
	if(not styles[name]) then return error('Style [%s] does not exist.', name) end

	style = name
end

do
	local function iter(_, n)
		-- don't expose the style functions.
		return (next(styles, n))
	end

	--[[ oUF:IterateStyles()
	Returns an iterator over all registered styles.

	* self - the global oUF object
	--]]
	function oUF.IterateStyles()
		return iter, nil, nil
	end
end

local getCondition
do
	local conditions = {
		raid40 = '[@raid26,exists] show;',
		raid25 = '[@raid11,exists] show;',
		raid10 = '[@raid6,exists] show;',
		raid = '[group:raid] show;',
		party = '[group:party,nogroup:raid] show;',
		solo = '[@player,exists,nogroup:party] show;',
	}

	function getCondition(...)
		local cond = ''

		for i = 1, select('#', ...) do
			local short = select(i, ...)

			local condition = conditions[short]
			if(condition) then
				cond = cond .. condition
			end
		end

		return cond .. 'hide'
	end
end

local function generateName(unit, ...)
	local name = 'oUF_' .. style:gsub('^oUF_?', ''):gsub('[^%a%d_]+', '')

	local raid, party, groupFilter, unitsuffix
	for i = 1, select('#', ...), 2 do
		local att, val = select(i, ...)
		if(att == 'showRaid') then
			raid = val ~= false and val ~= nil
		elseif(att == 'showParty') then
			party = val ~= false and val ~= nil
		elseif(att == 'groupFilter') then
			groupFilter = val
		end
	end

	local append
	if(raid) then
		if(groupFilter) then
			if(type(groupFilter) == 'number' and groupFilter > 0) then
				append = 'Raid' .. groupFilter
			elseif(groupFilter:match('MAINTANK')) then
				append = 'MainTank'
			elseif(groupFilter:match('MAINASSIST')) then
				append = 'MainAssist'
			else
				local _, count = groupFilter:gsub(',', '')
				if(count == 0) then
					append = 'Raid' .. groupFilter
				else
					append = 'Raid'
				end
			end
		else
			append = 'Raid'
		end
	elseif(party) then
		append = 'Party'
	elseif(unit) then
		append = unit:gsub('^%l', string.upper)
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
	local function styleProxy(self, frame, ...)
		return walkObject(_G[frame])
	end

	-- There has to be an easier way to do this.
	local initialConfigFunction = function(self)
		local header = self:GetParent()
		for i = 1, select('#', self), 1 do
			local frame = select(i, self)
			local unit
			-- There's no need to do anything on frames with onlyProcessChildren
			if(not frame.onlyProcessChildren) then
				-- Attempt to guess what the header is set to spawn.
				local groupFilter = header:GetAttribute('groupFilter')

				if(type(groupFilter) == 'string' and groupFilter:match('MAIN[AT]')) then
					local role = groupFilter:match('MAIN([AT])')
					if(role == 'T') then
						unit = 'maintank'
					else
						unit = 'mainassist'
					end
				elseif(header:GetAttribute('showRaid')) then
					unit = 'raid'
				elseif(header:GetAttribute('showParty')) then
					unit = 'party'
				end

				local headerType = header.headerType
				local suffix = frame:GetAttribute('unitsuffix')
				if(unit and suffix) then
					if(headerType == 'pet' and suffix == 'target') then
						unit = unit .. headerType .. suffix
					else
						unit = unit .. suffix
					end
				elseif(unit and headerType == 'pet') then
					unit = unit .. headerType
				end

				frame.menu = togglemenu
				frame:SetAttribute('*type1', 'target')
				frame:SetAttribute('*type2', 'menu')
				frame:SetAttribute('toggleForVehicle', true)
				frame.guessUnit = unit
			end
		end

		header:styleFunction(self:GetName())
	end

	--[[ oUF:SpawnHeader(overrideName, template, visibility, ...)
	Used to create a group header and apply the currently active style to it.

	* self         - the global oUF object
	* overrideName - unique global name to be used for the header. Defaults to an auto-generated name based on the name
	                 of the active style and other arguments passed to `:SpawnHeader` (string?)
	* template     - name of a template to be used for creating the header. Defaults to `'SecureGroupHeaderTemplate'`
	                 (string?)
	* visibility   - macro conditional(s) which define when to display the header (string).
	* ...          - further argument pairs. Consult [Group Headers](http://wowprogramming.com/docs/secure_template/Group_Headers)
	                 for possible values.

	In addition to the standard group headers, oUF implements some of its own attributes. These can be supplied by the
	layout, but are optional.

	* oUF-initialConfigFunction - can contain code that will be securely run at the end of the initial secure
	                              configuration (string?)
	* oUF-onlyProcessChildren   - can be used to force headers to only process children (boolean?)
	--]]
	function oUF:SpawnHeader(overrideName, template, visibility, ...)
		if(not style) then return error('Unable to create frame. No styles have been registered.') end

		template = (template or 'SecureGroupHeaderTemplate')

		local isPetHeader = template:match('PetHeader')
		local name = overrideName or generateName(nil, ...)
		local header = CreateFrame('Frame', name, UIParent, template)
		header:Hide()

		header:SetAttribute('template', 'oUF_ClickCastUnitTemplate')
		for i = 1, select('#', ...), 2 do
			local att, val = select(i, ...)
			if(not att) then break end
			header:SetAttribute(att, val)
		end

		header.style = style
		header.styleFunction = styleProxy
		header.visibility = visibility

		-- Expose the header through oUF.headers.
		table.insert(headers, header)

		header.initialConfigFunction = initialConfigFunction
		header.headerType = isPetHeader and 'pet' or 'group'

		if(header:GetAttribute('showParty')) then
			self:DisableBlizzard('party')
		end

		if(visibility) then
			local type, list = string.split(' ', visibility, 2)
			if(list and type == 'custom') then
				RegisterStateDriver(header, 'visibility', list)
				header.visibility = list
			else
				local condition = getCondition(string.split(',', visibility))
				RegisterStateDriver(header, 'visibility', condition)
				header.visibility = condition
			end
		end

		return header
	end
end

--[[ oUF:Spawn(unit, overrideName)
Used to create a single unit frame and apply the currently active style to it.

* self         - the global oUF object
* unit         - the frame's unit (string)
* overrideName - unique global name to use for the unit frame. Defaults to an auto-generated name based on the unit
                 (string?)
--]]
function oUF:Spawn(unit, overrideName)
	argcheck(unit, 2, 'string')
	if(not style) then return error('Unable to create frame. No styles have been registered.') end

	unit = unit:lower()

	local name = overrideName or generateName(unit)
	local object = CreateFrame('Button', name, UIParent, 'SecureUnitButtonTemplate')
	Private.UpdateUnits(object, unit)

	self:DisableBlizzard(unit)
	walkObject(object, unit)

	object:SetAttribute('unit', unit)
	RegisterUnitWatch(object)

	return object
end

--[[ oUF:AddElement(name, update, enable, disable)
Used to register an element with oUF.

* self    - the global oUF object
* name    - unique name of the element (string)
* update  - used to update the element (function?)
* enable  - used to enable the element for a given unit frame and unit (function?)
* disable - used to disable the element for a given unit frame (function?)
--]]
function oUF:AddElement(name, update, enable, disable)
	argcheck(name, 2, 'string')
	argcheck(update, 3, 'function', 'nil')
	argcheck(enable, 4, 'function', 'nil')
	argcheck(disable, 5, 'function', 'nil')

	if(elements[name]) then return error('Element [%s] is already registered.', name) end

	elements[name] = {
		update = update;
		enable = enable;
		disable = disable;
	}
end

oUF.version = _VERSION
--[[ oUF.objects
Array containing all unit frames created by `oUF:Spawn`.
--]]
oUF.objects = objects
--[[ oUF.headers
Array containing all group headers created by `oUF:SpawnHeader`.
--]]
oUF.headers = headers

if(global) then
	if(parent ~= 'oUF' and global == 'oUF') then
		error('%s is doing it wrong and setting its global to "oUF".', parent)
	elseif(_G[global]) then
		error('%s is setting its global to an existing name "%s".', parent, global)
	else
		_G[global] = oUF
	end
end