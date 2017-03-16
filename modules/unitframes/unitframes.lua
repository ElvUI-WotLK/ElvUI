local E, L, V, P, G = unpack(select(2, ...));
local UF = E:NewModule("UnitFrames", "AceTimer-3.0", "AceEvent-3.0", "AceHook-3.0");
local LSM = LibStub("LibSharedMedia-3.0");
UF.LSM = LSM;

local _G = _G;
local select, pairs, type, unpack, assert, tostring = select, pairs, type, unpack, assert, tostring;

local hooksecurefunc = hooksecurefunc;
local CreateFrame = CreateFrame;
local IsAddOnLoaded = IsAddOnLoaded;
local UnitFrame_OnEnter = UnitFrame_OnEnter;
local UnitFrame_OnLeave = UnitFrame_OnLeave;
local IsInInstance = IsInInstance;
local InCombatLockdown = InCombatLockdown;
local GetInstanceInfo = GetInstanceInfo;
local UnregisterStateDriver = UnregisterStateDriver;
local RegisterStateDriver = RegisterStateDriver;
local MAX_RAID_MEMBERS = MAX_RAID_MEMBERS;
local MAX_BOSS_FRAMES = MAX_BOSS_FRAMES;

local _, ns = ...;
local ElvUF = ns.oUF;
assert(ElvUF, "ElvUI was unable to locate oUF.");

UF["headerstoload"] = {};
UF["unitgroupstoload"] = {};
UF["unitstoload"] = {};

UF["groupPrototype"] = {};
UF["headerPrototype"] = {};
UF["headers"] = {};
UF["groupunits"] = {};
UF["units"] = {};

UF["statusbars"] = {};
UF["fontstrings"] = {};
UF["badHeaderPoints"] = {
	["TOP"] = "BOTTOM",
	["LEFT"] = "RIGHT",
	["BOTTOM"] = "TOP",
	["RIGHT"] = "LEFT"
};

UF["headerFunctions"] = {};

UF["classMaxResourceBar"] = {
	["DEATHKNIGHT"] = 6,
	["DRUID"] = 1
};

UF["mapIDs"] = {
	[444] = 10,
	[541] = 40,
	[513] = 15,
	[402] = 40,
	[462] = 15,
	[483] = 15
};

UF["headerGroupBy"] = {
	["CLASS"] = function(header)
		header:SetAttribute("groupingOrder", "DEATHKNIGHT,DRUID,HUNTER,MAGE,PALADIN,PRIEST,SHAMAN,WARLOCK,WARRIOR");
		header:SetAttribute("sortMethod", "NAME");
		header:SetAttribute("groupBy", "CLASS");
	end,
	["MTMA"] = function(header)
		header:SetAttribute("groupingOrder", "MAINTANK,MAINASSIST,NONE");
		header:SetAttribute("sortMethod", "NAME");
		header:SetAttribute("groupBy", "ROLE");
	end,
	["NAME"] = function(header)
		header:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8");
		header:SetAttribute("sortMethod", "NAME");
		header:SetAttribute("groupBy", nil);
	end,
	["GROUP"] = function(header)
		header:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8");
		header:SetAttribute("sortMethod", "INDEX");
		header:SetAttribute("groupBy", "GROUP");
	end,
	["PETNAME"] = function(header)
		header:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8");
		header:SetAttribute("sortMethod", "NAME");
		header:SetAttribute("groupBy", nil);
		header:SetAttribute("filterOnPet", true);
	end,
};

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
};

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
};

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
};

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
};

local DIRECTION_TO_COLUMN_ANCHOR_POINT = {
	DOWN_RIGHT = "LEFT",
	DOWN_LEFT = "RIGHT",
	UP_RIGHT = "LEFT",
	UP_LEFT = "RIGHT",
	RIGHT_DOWN = "TOP",
	RIGHT_UP = "BOTTOM",
	LEFT_DOWN = "TOP",
	LEFT_UP = "BOTTOM"
};

local DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER = {
	DOWN_RIGHT = 1,
	DOWN_LEFT = -1,
	UP_RIGHT = 1,
	UP_LEFT = -1,
	RIGHT_DOWN = 1,
	RIGHT_UP = 1,
	LEFT_DOWN = -1,
	LEFT_UP = -1
};

local DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER = {
	DOWN_RIGHT = -1,
	DOWN_LEFT = -1,
	UP_RIGHT = 1,
	UP_LEFT = 1,
	RIGHT_DOWN = -1,
	RIGHT_UP = 1,
	LEFT_DOWN = -1,
	LEFT_UP = 1
};

local find, gsub, format = string.find, string.gsub, string.format;
local min = math.min;
local tremove, tinsert = table.remove, table.insert;

function UF:ConvertGroupDB(group)
	local db = self.db.units[group.groupName];
	if(db.point and db.columnAnchorPoint) then
		db.growthDirection = POINT_COLUMN_ANCHOR_TO_DIRECTION[db.point..db.columnAnchorPoint];
		db.point = nil;
		db.columnAnchorPoint = nil;
	end

	if(db.growthDirection == "UP") then
		db.growthDirection = "UP_RIGHT";
	end

	if(db.growthDirection == "DOWN") then
		db.growthDirection = "DOWN_RIGHT";
	end
end

function UF:Construct_UF(frame, unit)
	frame:SetScript("OnEnter", UnitFrame_OnEnter);
	frame:SetScript("OnLeave", UnitFrame_OnLeave);

	if(self.thinBorders) then
		frame.SPACING = 0;
		frame.BORDER = E.mult;
	else
		frame.BORDER = E.Border;
		frame.SPACING = E.Spacing;
	end

	frame.SHADOW_SPACING = 3;
	frame.CLASSBAR_YOFFSET = 0;
	frame.BOTTOM_OFFSET = 0;

	frame.RaisedElementParent = CreateFrame("Frame", nil, frame);
	frame.RaisedElementParent:SetFrameLevel(frame:GetFrameLevel() + 100);

	if(not self["groupunits"][unit]) then
		local stringTitle = E:StringTitle(unit);
		if(stringTitle:find("target")) then
			stringTitle = gsub(stringTitle, "target", "Target");
		end
		self["Construct_"..stringTitle.."Frame"](self, frame, unit);
	else
		UF["Construct_"..E:StringTitle(self["groupunits"][unit]).."Frames"](self, frame, unit);
	end

	self:Update_StatusBars();
	self:Update_FontStrings();
	return frame;
end

function UF:GetObjectAnchorPoint(frame, point)
	if(not frame[point] or point == "Frame") then
		return frame;
	elseif(frame[point] and not frame[point]:IsShown()) then
		return frame.Health;
	else
		return frame[point];
	end
end

function UF:GetPositionOffset(position, offset)
	if(not offset) then offset = 2; end
	local x, y = 0, 0;
	if(find(position, "LEFT")) then
		x = offset;
	elseif(find(position, "RIGHT")) then
		x = -offset;
	end

	if(find(position, "TOP")) then
		y = -offset;
	elseif(find(position, "BOTTOM")) then
		y = offset;
	end

	return x, y;
end

function UF:GetAuraOffset(p1, p2)
	local x, y = 0, 0;
	if(p1 == "RIGHT" and p2 == "LEFT") then
		x = -3;
	elseif(p1 == "LEFT" and p2 == "RIGHT") then
		x = 3;
	end

	if(find(p1, "TOP") and find(p2, "BOTTOM")) then
		y = -1;
	elseif(find(p1, "BOTTOM") and find(p2, "TOP")) then
		y = 1;
	end

	return E:Scale(x), E:Scale(y);
end

function UF:GetAuraAnchorFrame(frame, attachTo, isConflict)
	if(isConflict) then
		E:Print(format(L["%s frame(s) has a conflicting anchor point, please change either the buff or debuff anchor point so they are not attached to each other. Forcing the debuffs to be attached to the main unitframe until fixed."], E:StringTitle(frame:GetName())));
	end

	if(isConflict or attachTo == "FRAME") then
		return frame;
	elseif(attachTo == "TRINKET") then
		if(select(2, IsInInstance()) == "arena") then
			return frame.Trinket;
		end
	elseif(attachTo == "BUFFS") then
		return frame.Buffs;
	elseif(attachTo == "DEBUFFS") then
		return frame.Debuffs;
	elseif(attachTo == "HEALTH") then
		return frame.Health;
	elseif(attachTo == "POWER" and frame.Power) then
		return frame.Power;
	else
		return frame;
	end
end

function UF:ClearChildPoints(...)
	for i = 1, select("#", ...) do
		local child = select(i, ...);
		child:ClearAllPoints();
	end
end

function UF:UpdateColors()
	local db = E.db.unitframe.colors;

	local good = E:GetColorTable(db.reaction.GOOD);
	local bad = E:GetColorTable(db.reaction.BAD);
	local neutral = E:GetColorTable(db.reaction.NEUTRAL);

	ElvUF.colors.tapped = E:GetColorTable(db.tapped);
	ElvUF.colors.disconnected = E:GetColorTable(db.disconnected);
	ElvUF.colors.health = E:GetColorTable(db.health);
	ElvUF.colors.power.MANA = E:GetColorTable(db.power.MANA);
	ElvUF.colors.power.RAGE = E:GetColorTable(db.power.RAGE);
	ElvUF.colors.power.FOCUS = E:GetColorTable(db.power.FOCUS);
	ElvUF.colors.power.ENERGY = E:GetColorTable(db.power.ENERGY);
	ElvUF.colors.power.RUNIC_POWER = E:GetColorTable(db.power.RUNIC_POWER);

	ElvUF.colors.Runes = {};
	ElvUF.colors.Runes[1] = E:GetColorTable(db.classResources.DEATHKNIGHT[1]);
	ElvUF.colors.Runes[2] = E:GetColorTable(db.classResources.DEATHKNIGHT[2]);
	ElvUF.colors.Runes[3] = E:GetColorTable(db.classResources.DEATHKNIGHT[3]);
	ElvUF.colors.Runes[4] = E:GetColorTable(db.classResources.DEATHKNIGHT[4]);

	ElvUF.colors.ComboPoints = {};
	ElvUF.colors.ComboPoints[1] = E:GetColorTable(db.classResources.comboPoints[1]);
	ElvUF.colors.ComboPoints[2] = E:GetColorTable(db.classResources.comboPoints[2]);
	ElvUF.colors.ComboPoints[3] = E:GetColorTable(db.classResources.comboPoints[3]);
	ElvUF.colors.ComboPoints[4] = E:GetColorTable(db.classResources.comboPoints[4]);
	ElvUF.colors.ComboPoints[5] = E:GetColorTable(db.classResources.comboPoints[5]);

	ElvUF.colors.reaction[1] = bad;
	ElvUF.colors.reaction[2] = bad;
	ElvUF.colors.reaction[3] = bad;
	ElvUF.colors.reaction[4] = neutral;
	ElvUF.colors.reaction[5] = good;
	ElvUF.colors.reaction[6] = good;
	ElvUF.colors.reaction[7] = good;
	ElvUF.colors.reaction[8] = good;
	ElvUF.colors.smooth = {1, 0, 0,
	1, 1, 0,
	unpack(E:GetColorTable(db.health))};

	ElvUF.colors.castColor = E:GetColorTable(db.castColor);
	ElvUF.colors.castNoInterrupt = E:GetColorTable(db.castNoInterrupt);
end

function UF:Update_StatusBars()
	local statusBarTexture = LSM:Fetch("statusbar", self.db.statusbar);
	for statusbar in pairs(UF["statusbars"]) do
		if(statusbar and statusbar:GetObjectType() == "StatusBar" and not statusbar.isTransparent) then
			statusbar:SetStatusBarTexture(statusBarTexture);
		elseif(statusBar and statusbar:GetObjectType() == "Texture") then
			statusbar:SetTexture(statusBarTexture);
		end
	end
end

function UF:Update_StatusBar(bar)
	bar:SetStatusBarTexture(LSM:Fetch("statusbar", self.db.statusbar));
end

function UF:Update_FontString(object)
	object:FontTemplate(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline);
end

function UF:Update_FontStrings()
	local stringFont = LSM:Fetch("font", self.db.font);
	for font in pairs(UF["fontstrings"]) do
		font:FontTemplate(stringFont, self.db.fontSize, self.db.fontOutline);
	end
end

function UF:Configure_FontString(obj)
	UF["fontstrings"][obj] = true;
	obj:FontTemplate();
end

function UF:Update_AllFrames()
	if(InCombatLockdown()) then self:RegisterEvent("PLAYER_REGEN_ENABLED"); return; end
	if(E.private["unitframe"].enable ~= true) then return; end
	self:UpdateColors();
	self:Update_FontStrings();
	self:Update_StatusBars();

	for unit in pairs(self["units"]) do
		if(self.db["units"][unit].enable) then
			self[unit]:Enable();
			self[unit]:Update();
			E:EnableMover(self[unit].mover:GetName());
		else
			self[unit]:Disable();
			E:DisableMover(self[unit].mover:GetName());
		end
	end

	for unit, group in pairs(self["groupunits"]) do
		if(self.db["units"][group].enable) then
			self[unit]:Enable();
			self[unit]:Update();
			E:EnableMover(self[unit].mover:GetName());
		else
			self[unit]:Disable();
			E:DisableMover(self[unit].mover:GetName());
		end
	end

	self:UpdateAllHeaders();
end

function UF:CreateAndUpdateUFGroup(group, numGroup)
	if(InCombatLockdown()) then self:RegisterEvent("PLAYER_REGEN_ENABLED"); return; end

	for i = 1, numGroup do
		local unit = group..i;
		local frameName = E:StringTitle(unit);
		frameName = frameName:gsub("t(arget)", "T%1");
		if(not self[unit]) then
			self["groupunits"][unit] = group;
			self[unit] = ElvUF:Spawn(unit, "ElvUF_"..frameName);
			self[unit].index = i;
			self[unit]:SetID(i);
		end

		local frameName = E:StringTitle(group);
		frameName = frameName:gsub("t(arget)", "T%1");
		self[unit].Update = function()
			UF["Update_"..E:StringTitle(frameName).."Frames"](self, self[unit], self.db["units"][group]);
		end

		if(self.db["units"][group].enable) then
			self[unit]:Enable();
			self[unit].Update();

			if(self[unit].isForced) then
				self:ForceShow(self[unit]);
			end
			E:EnableMover(self[unit].mover:GetName());
		else
			self[unit]:Disable();
			E:DisableMover(self[unit].mover:GetName());
		end
	end
end

function UF:HeaderUpdateSpecificElement(group, elementName)
	assert(self[group], "Invalid group specified.");
	for i = 1, self[group]:GetNumChildren() do
		local frame = select(i, self[group]:GetChildren());
		if(frame and frame.Health) then
			frame:UpdateElement(elementName);
		end
	end
end

function UF.groupPrototype:GetAttribute(name)
	return self.groups[1]:GetAttribute(name);
end

function UF.groupPrototype:Configure_Groups(self)
	local db = UF.db.units[self.groupName];

	local point;
	local width, height, newCols, newRows = 0, 0, 0, 0;
	local direction = db.growthDirection;
	local xMult, yMult = DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER[direction], DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[direction];
	local UNIT_HEIGHT = db.infoPanel and db.infoPanel.enable and (db.height + db.infoPanel.height) or db.height;

	local numGroups = self.numGroups;

	for i = 1, numGroups do
		local group = self.groups[i];

		point = DIRECTION_TO_POINT[direction];

		if(group) then
			UF:ConvertGroupDB(group);
			if(point == "LEFT" or point == "RIGHT") then
				group:SetAttribute("xOffset", db.horizontalSpacing * DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER[direction]);
				group:SetAttribute("yOffset", 0);
				group:SetAttribute("columnSpacing", db.verticalSpacing);
			else
				group:SetAttribute("xOffset", 0);
				group:SetAttribute("yOffset", db.verticalSpacing * DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[direction]);
				group:SetAttribute("columnSpacing", db.horizontalSpacing);
			end

			--[[if not group.isForced then
				if not group.initialized then
					group:SetAttribute("startingIndex", db.raidWideSorting and (-min(numGroups * (db.groupsPerRowCol * 5), MAX_RAID_MEMBERS) + 1) or -4)
					group:Show()
					group.initialized = true
				end
				group:SetAttribute("startingIndex", 1)
			end]]

			group:ClearAllPoints();
			if(db.raidWideSorting and db.invertGroupingOrder) then
				group:SetAttribute("columnAnchorPoint", INVERTED_DIRECTION_TO_COLUMN_ANCHOR_POINT[direction]);
			else
				group:SetAttribute("columnAnchorPoint", DIRECTION_TO_COLUMN_ANCHOR_POINT[direction]);
			end

			group:ClearChildPoints();
			group:SetAttribute("point", point);

			if(not group.isForced) then
				group:SetAttribute("maxColumns", db.raidWideSorting and numGroups or 1);
				group:SetAttribute("unitsPerColumn", db.raidWideSorting and (db.groupsPerRowCol * 5) or 5);
				UF.headerGroupBy[db.groupBy](group);
				group:SetAttribute("sortDir", db.sortDir);
				group:SetAttribute("showPlayer", db.showPlayer);
			end

			if(i == 1 and db.raidWideSorting) then
				group:SetAttribute("groupFilter", "1,2,3,4,5,6,7,8");
			else
				group:SetAttribute("groupFilter", tostring(i));
			end
		end

		--MATH!! WOOT
		point = DIRECTION_TO_GROUP_ANCHOR_POINT[direction];
		if(db.raidWideSorting and db.startFromCenter) then
			point = DIRECTION_TO_GROUP_ANCHOR_POINT["OUT_"..direction];
		end
		if((i - 1) % db.groupsPerRowCol == 0) then
			if(DIRECTION_TO_POINT[direction] == "LEFT" or DIRECTION_TO_POINT[direction] == "RIGHT") then
				if(group) then
					group:Point(point, self, point, 0, height * yMult);
				end
				height = height + UNIT_HEIGHT + db.verticalSpacing;

				newRows = newRows + 1;
			else
				if(group) then
					group:Point(point, self, point, width * xMult, 0);
				end
				width = width + db.width + db.horizontalSpacing;

				newCols = newCols + 1;
			end
		else
			if(DIRECTION_TO_POINT[direction] == "LEFT" or DIRECTION_TO_POINT[direction] == "RIGHT") then
				if(newRows == 1) then
					if(group) then
						group:Point(point, self, point, width * xMult, 0);
					end
					width = width + ((db.width + db.horizontalSpacing) * 5);
					newCols = newCols + 1;
				elseif(group) then
					group:Point(point, self, point, (((db.width + db.horizontalSpacing) * 5) * ((i-1) % db.groupsPerRowCol)) * xMult, ((UNIT_HEIGHT + db.verticalSpacing) * (newRows - 1)) * yMult);
				end
			else
				if(newCols == 1) then
					if(group) then
						group:Point(point, self, point, 0, height * yMult);
					end
					height = height + ((UNIT_HEIGHT + db.verticalSpacing) * 5);
					newRows = newRows + 1;
				elseif(group) then
					group:Point(point, self, point, ((db.width + db.horizontalSpacing) * (newCols - 1)) * xMult, (((UNIT_HEIGHT + db.verticalSpacing) * 5) * ((i-1) % db.groupsPerRowCol)) * yMult);
				end
			end
		end

		if(height == 0) then
			height = height + ((UNIT_HEIGHT + db.verticalSpacing) * 5);
		elseif(width == 0) then
			width = width + ((db.width + db.horizontalSpacing) * 5);
		end
	end

	if(not self.isInstanceForced) then
		self.dirtyWidth = width - db.horizontalSpacing;
		self.dirtyHeight = height - db.verticalSpacing;
	end

	if(self.mover) then
		self.mover.positionOverride = DIRECTION_TO_GROUP_ANCHOR_POINT[direction];
		E:UpdatePositionOverride(self.mover:GetName());
		self:GetScript("OnSizeChanged")(self);
	end

	self:SetSize(width - db.horizontalSpacing, height - db.verticalSpacing);
end

function UF.groupPrototype:Update(self)
	local group = self.groupName;

	UF[group].db = UF.db["units"][group];
	for i = 1, #self.groups do
		self.groups[i].db = UF.db["units"][group];
		self.groups[i]:Update();
	end
end

function UF.groupPrototype:AdjustVisibility(self)
	if(not self.isForced) then
		local numGroups = self.numGroups;
		for i = 1, #self.groups do
			local group = self.groups[i];
			if((i <= numGroups) and ((self.db.raidWideSorting and i <= 1) or not self.db.raidWideSorting)) then
				group:Show();
			else
				if(group.forceShow) then
					group:Hide();
					UF:UnshowChildUnits(group, group:GetChildren());
					group:SetAttribute("startingIndex", 1);
				else
					group:Reset();
				end
			end
		end
	end
end

function UF.groupPrototype:UpdateHeader(self)
	local group = self.groupName;
	UF["Update_"..E:StringTitle(group).."Header"](UF, self, UF.db["units"][group]);
end

function UF.headerPrototype:ClearChildPoints()
	for i = 1, self:GetNumChildren() do
		local child = select(i, self:GetChildren());
		child:ClearAllPoints();
	end
end

function UF.headerPrototype:Update()
	local groupName = self.groupName;
	local db = UF.db["units"][groupName];

	local i = 1;
	local child = self:GetAttribute("child" .. i);

	while(child) do
		UF["Update_"..E:StringTitle(groupName).."Frames"](UF, child, db);

		if(_G[child:GetName().."Pet"]) then
			UF["Update_"..E:StringTitle(groupName).."Frames"](UF, _G[child:GetName().."Pet"], db);
		end

		if(_G[child:GetName().."Target"]) then
			UF["Update_"..E:StringTitle(groupName).."Frames"](UF, _G[child:GetName().."Target"], db);
		end

		i = i + 1;
		child = self:GetAttribute("child" .. i);
	end
end

function UF.headerPrototype:Reset()
	self:Hide();

	self:SetAttribute("showPlayer", true);

	self:SetAttribute("showSolo", true);
	self:SetAttribute("showParty", true);
	self:SetAttribute("showRaid", true);

	self:SetAttribute("columnSpacing", nil);
	self:SetAttribute("columnAnchorPoint", nil);
	self:SetAttribute("groupBy", nil);
	self:SetAttribute("groupFilter", nil);
	self:SetAttribute("groupingOrder", nil);
	self:SetAttribute("maxColumns", nil);
	self:SetAttribute("nameList", nil);
	self:SetAttribute("point", nil);
	self:SetAttribute("sortDir", nil);
	self:SetAttribute("sortMethod", "NAME");
	self:SetAttribute("startingIndex", nil);
	self:SetAttribute("strictFiltering", nil);
	self:SetAttribute("unitsPerColumn", nil);
	self:SetAttribute("xOffset", nil);
	self:SetAttribute("yOffset", nil);
end

function UF:CreateHeader(parent, groupFilter, overrideName, template, groupName, headerTemplate)
	local group = parent.groupName or groupName;
	ElvUF:SetActiveStyle("ElvUF_"..E:StringTitle(group));
	local header = ElvUF:SpawnHeader(overrideName, headerTemplate, nil,
			"groupFilter", groupFilter,
			"showParty", true,
			"showRaid", true,
			"showSolo", true,
			template and "template", template);

	header.groupName = group;
	header:SetParent(parent);
	header:Show();

	for k, v in pairs(self.headerPrototype) do
		header[k] = v;
	end

	return header;
end

function UF:CreateAndUpdateHeaderGroup(group, groupFilter, template, headerUpdate, headerTemplate)
	if(InCombatLockdown()) then self:RegisterEvent("PLAYER_REGEN_ENABLED"); return; end
	local db = self.db["units"][group];
	local raidFilter = UF.db.smartRaidFilter;
	local numGroups = db.numGroups;
	if(raidFilter and numGroups and (self[group] and not self[group].blockVisibilityChanges)) then
		local inInstance, instanceType = IsInInstance();
		if(inInstance and (instanceType == "raid" or instanceType == "pvp")) then
			local _, _, _, _, maxPlayers = GetInstanceInfo();
			local mapID = GetCurrentMapAreaID();
			if(UF.mapIDs[mapID]) then
				maxPlayers = UF.mapIDs[mapID];
			end

			if(maxPlayers > 0) then
				numGroups = E:Round(maxPlayers/5);
			end
		end
	end

	if(not self[group]) then
		local stringTitle = E:StringTitle(group);
		ElvUF:RegisterStyle("ElvUF_"..stringTitle, UF["Construct_" .. stringTitle .. "Frames"]);
		ElvUF:SetActiveStyle("ElvUF_"..stringTitle);

		if(db.numGroups) then
			self[group] = CreateFrame("Frame", "ElvUF_" .. stringTitle, E.UIParent, "SecureHandlerStateTemplate");
			self[group].groups = {};
			self[group].groupName = group;
			self[group].template = self[group].template or template;
			self[group].headerTemplate = self[group].headerTemplate or headerTemplate;
			if not UF["headerFunctions"][group] then UF["headerFunctions"][group] = {}; end
			for k, v in pairs(self.groupPrototype) do
				UF["headerFunctions"][group][k] = v;
			end
		else
			self[group] = self:CreateHeader(E.UIParent, groupFilter, "ElvUF_" .. E:StringTitle(group), template, group, headerTemplate);
		end

		self[group].db = db;
		self["headers"][group] = self[group];
		self[group]:Show();
	end

	self[group].numGroups = numGroups;
	if(numGroups) then
		if(db.enable ~= true and group ~= "raidpet") then
			UnregisterStateDriver(self[group], "visibility");
			self[group]:Hide();
			if(self[group].mover) then
				E:DisableMover(self[group].mover:GetName());
			end
			return;
		end

		if(db.raidWideSorting) then
			if(not self[group].groups[1]) then
				self[group].groups[1] = self:CreateHeader(self[group], nil, "ElvUF_"..E:StringTitle(self[group].groupName) .. "Group1", template or self[group].template, nil, headerTemplate or self[group].headerTemplate);
			end
		else
			while(numGroups > #self[group].groups) do
				local index = tostring(#self[group].groups + 1);
				tinsert(self[group].groups, self:CreateHeader(self[group], index, "ElvUF_" .. E:StringTitle(self[group].groupName) .. "Group" .. index, template or self[group].template, nil, headerTemplate or self[group].headerTemplate));
			end
		end

		UF["headerFunctions"][group]:AdjustVisibility(self[group]);

		if(headerUpdate or not self[group].mover) then
			UF["headerFunctions"][group]:Configure_Groups(self[group]);
			if(not self[group].isForced and not self[group].blockVisibilityChanges) then
				RegisterStateDriver(self[group], "visibility", db.visibility);
			end

			if(not self[group].mover) then
				UF["headerFunctions"][group]:Update(self[group]);
				UF["headerFunctions"][group]:UpdateHeader(self[group]);
			end
		else
			UF["headerFunctions"][group]:Configure_Groups(self[group]);
			UF["headerFunctions"][group]:Update(self[group]);
		end

		if(db.enable) then
			E:EnableMover(self[group].mover:GetName());
		else
			E:DisableMover(self[group].mover:GetName());
		end

		if(db.enable ~= true and group == "raidpet") then
			UnregisterStateDriver(self[group], "visibility");
			self[group]:Hide();
			return;
		end
	else
		self[group].db = db;

		if not UF["headerFunctions"][group] then UF["headerFunctions"][group] = {}; end
		UF["headerFunctions"][group]["Update"] = function()
			local db = UF.db["units"][group];
			if(db.enable ~= true) then
				UnregisterStateDriver(UF[group], "visibility");
				UF[group]:Hide();
				if(UF[group].mover) then
					E:DisableMover(UF[group].mover:GetName());
				end
				return;
			end
			UF["Update_" .. E:StringTitle(group) .. "Header"](UF, UF[group], db);

			for i = 1, UF[group]:GetNumChildren() do
				local child = select(i, UF[group]:GetChildren());
				UF["Update_" .. E:StringTitle(group) .. "Frames"](UF, child, UF.db["units"][group]);

				if _G[child:GetName() .. "Target"] then
					UF["Update_" .. E:StringTitle(group) .. "Frames"](UF, _G[child:GetName() .. "Target"], UF.db["units"][group]);
				end

				if _G[child:GetName() .. "Pet"] then
					UF["Update_" .. E:StringTitle(group) .. "Frames"](UF, _G[child:GetName() .. "Pet"], UF.db["units"][group]);
				end
			end

			E:EnableMover(UF[group].mover:GetName());
		end

		if(headerUpdate) then
			UF["Update_"..E:StringTitle(group).."Header"](self, self[group], db);
		else
			UF["headerFunctions"][group]:Update(self[group]);
		end
	end
end

function UF:PLAYER_REGEN_ENABLED()
	self:Update_AllFrames();
	self:UnregisterEvent("PLAYER_REGEN_ENABLED");
end

function UF:CreateAndUpdateUF(unit)
	assert(unit, "No unit provided to create or update.");
	if(InCombatLockdown()) then self:RegisterEvent("PLAYER_REGEN_ENABLED"); return; end

	local frameName = E:StringTitle(unit);
	frameName = frameName:gsub("t(arget)", "T%1");
	if(not self[unit]) then
		self[unit] = ElvUF:Spawn(unit, "ElvUF_"..frameName);
		self["units"][unit] = unit;
	end

	self[unit].Update = function()
		UF["Update_"..frameName.."Frame"](self, self[unit], self.db["units"][unit]);
	end

	if(self.db["units"][unit].enable) then
		self[unit]:Enable();
		self[unit].Update();
		E:EnableMover(self[unit].mover:GetName());
	else
		self[unit]:Disable();
		E:DisableMover(self[unit].mover:GetName());
	end
end

function UF:LoadUnits()
	for _, unit in pairs(self["unitstoload"]) do
		self:CreateAndUpdateUF(unit);
	end
	self["unitstoload"] = nil;

	for group, groupOptions in pairs(self["unitgroupstoload"]) do
		local numGroup, template = unpack(groupOptions);
		self:CreateAndUpdateUFGroup(group, numGroup, template);
	end
	self["unitgroupstoload"] = nil;

	for group, groupOptions in pairs(self["headerstoload"]) do
		local groupFilter, template, headerTemplate;
		if(type(groupOptions) == "table") then
			groupFilter, template, headerTemplate = unpack(groupOptions);
		end

		self:CreateAndUpdateHeaderGroup(group, groupFilter, template, nil, headerTemplate);
	end
	self["headerstoload"] = nil;
end

function UF:UpdateAllHeaders(event)
	if(InCombatLockdown()) then
		self:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateAllHeaders");
		return;
	end

	if(event == "PLAYER_REGEN_ENABLED") then
		self:UnregisterEvent("PLAYER_REGEN_ENABLED");
	end

	local _, instanceType = IsInInstance();
	local ORD = ns.oUF_RaidDebuffs or oUF_RaidDebuffs;
	if(ORD) then
		ORD:ResetDebuffData();

		if(instanceType == "party" or instanceType == "raid") then
			ORD:RegisterDebuffs(E.global.unitframe.aurafilters.RaidDebuffs.spells);
		else
			ORD:RegisterDebuffs(E.global.unitframe.aurafilters.CCDebuffs.spells);
		end
	end

	if(E.private["unitframe"]["disabledBlizzardFrames"].party) then
		ElvUF:DisableBlizzard("party");
	end

	local smartRaidFilterEnabled = self.db.smartRaidFilter
	for group, header in pairs(self["headers"]) do
		UF["headerFunctions"][group]:Update(header);

		local shouldUpdateHeader;
		if(header.numGroups == nil or smartRaidFilterEnabled) then
			shouldUpdateHeader = false;
		elseif(header.numGroups ~= nil and not smartRaidFilterEnabled) then
			shouldUpdateHeader = true;
		end

		self:CreateAndUpdateHeaderGroup(group, nil, nil, shouldUpdateHeader);

		if(group == "party" or group == "raid" or group == "raid40") then
			self:UpdateAuraWatchFromHeader(group);
		end
	end
end

local hiddenParent = CreateFrame("Frame");
hiddenParent:Hide();

local HandleFrame = function(baseName)
	local frame;
	if(type(baseName) == "string") then
		frame = _G[baseName];
	else
		frame = baseName;
	end

	if(frame) then
		frame:UnregisterAllEvents();
		frame:Hide();

		frame:SetParent(hiddenParent);

		local health = frame.healthbar;
		if(health) then
			health:UnregisterAllEvents();
		end

		local power = frame.manabar;
		if(power) then
			power:UnregisterAllEvents();
		end

		local spell = frame.spellbar;
		if(spell) then
			spell:UnregisterAllEvents();
		end
	end
end

function ElvUF:DisableBlizzard(unit)
	if((not unit) or InCombatLockdown()) then return; end

	if((unit == "player") and E.private["unitframe"]["disabledBlizzardFrames"].player) then
		HandleFrame(PlayerFrame);

		PlayerFrame:RegisterEvent("UNIT_ENTERING_VEHICLE");
		PlayerFrame:RegisterEvent("UNIT_ENTERED_VEHICLE");
		PlayerFrame:RegisterEvent("UNIT_EXITING_VEHICLE");
		PlayerFrame:RegisterEvent("UNIT_EXITED_VEHICLE");

		RuneFrame:SetParent(PlayerFrame)
	elseif((unit == "pet") and E.private["unitframe"]["disabledBlizzardFrames"].player) then
		HandleFrame(PetFrame)
	elseif((unit == "target") and E.private["unitframe"]["disabledBlizzardFrames"].target) then
		HandleFrame(TargetFrame);
		HandleFrame(ComboFrame);
	elseif((unit == "focus") and E.private["unitframe"]["disabledBlizzardFrames"].focus) then
		HandleFrame(FocusFrame);
		HandleFrame(FocusFrameToT);
	elseif((unit == "targettarget") and E.private["unitframe"]["disabledBlizzardFrames"].target) then
		HandleFrame(TargetFrameToT);
	elseif((unit:match"(boss)%d?$" == "boss") and E.private["unitframe"]["disabledBlizzardFrames"].boss) then
		local id = unit:match"boss(%d)";
		if(id) then
			HandleFrame("Boss"..id.."TargetFrame");
		else
			for i = 1, MAX_BOSS_FRAMES do
				HandleFrame(("Boss%dTargetFrame"):format(i));
			end
		end
	elseif((unit:match"(party)%d?$" == "party") and E.private["unitframe"]["disabledBlizzardFrames"].party) then
		local id = unit:match"party(%d)";
		if(id) then
			HandleFrame("PartyMemberFrame"..id);
		else
			for i = 1, 4 do
				HandleFrame(("PartyMemberFrame%d"):format(i));
			end
		end
		HandleFrame(PartyMemberBackground);
	elseif((unit:match"(arena)%d?$" == "arena") and E.private["unitframe"]["disabledBlizzardFrames"].arena) then
		local id = unit:match"arena(%d)";
		if(id) then
			HandleFrame("ArenaEnemyFrame"..id);
			HandleFrame("ArenaEnemyFrame"..id.."PetFrame");
		else
			for i = 1, 5 do
				HandleFrame(("ArenaEnemyFrame%d"):format(i));
				HandleFrame(("ArenaEnemyFrame%dPetFrame"):format(i));
			end
		end
	end
end

function UF:ADDON_LOADED(_, addon)
	if(addon ~= "Blizzard_ArenaUI") then return; end
	ElvUF:DisableBlizzard("arena");
	self:UnregisterEvent("ADDON_LOADED");
end

local hasEnteredWorld = false
function UF:PLAYER_ENTERING_WORLD(event)
	if(not hasEnteredWorld) then
		--We only want to run Update_AllFrames once when we first log in or /reload
		self:Update_AllFrames();
		hasEnteredWorld = true;
	else
		--We need to update headers in case we zoned into an instance
		UF:UpdateAllHeaders();
	end
end

function UF:UnitFrameThreatIndicator_Initialize(_, unitFrame)
	unitFrame:UnregisterAllEvents();
end

function UF:Initialize()
	self.db = E.db["unitframe"];

	self.thinBorders = self.db.thinBorders or E.PixelMode;
	if(E.private["unitframe"].enable ~= true) then return; end
	E.UnitFrames = UF;

	self:UpdateColors();
	ElvUF:RegisterStyle("ElvUF", function(frame, unit)
		self:Construct_UF(frame, unit);
	end);

	self:LoadUnits();
	self:RegisterEvent("PLAYER_ENTERING_WORLD");

	for k, v in pairs(UnitPopupMenus) do
		for x, y in pairs(UnitPopupMenus[k]) do
			if(y == "SET_FOCUS") then
				tremove(UnitPopupMenus[k], x);
			elseif(y == "CLEAR_FOCUS") then
				tremove(UnitPopupMenus[k], x);
			end
		end
	end

	if(E.private["unitframe"]["disabledBlizzardFrames"].arena and E.private["unitframe"]["disabledBlizzardFrames"].focus and E.private["unitframe"]["disabledBlizzardFrames"].party) then
		InterfaceOptionsFrameCategoriesButton10:SetScale(0.0001);
	end

	if(E.private["unitframe"]["disabledBlizzardFrames"].player) then
		InterfaceOptionsStatusTextPanelPlayer:SetScale(0.0001);
		InterfaceOptionsStatusTextPanelPlayer:SetAlpha(0);
		InterfaceOptionsStatusTextPanelPet:SetScale(0.0001);
		InterfaceOptionsStatusTextPanelPet:SetAlpha(0);
	end

	if(E.private["unitframe"]["disabledBlizzardFrames"].target) then
		InterfaceOptionsStatusTextPanelTarget:SetScale(0.0001);
		InterfaceOptionsStatusTextPanelTarget:SetAlpha(0);
		InterfaceOptionsCombatPanelEnemyCastBarsOnPortrait:SetAlpha(0);
		InterfaceOptionsCombatPanelEnemyCastBarsOnPortrait:EnableMouse(false);
		InterfaceOptionsCombatPanelEnemyCastBarsOnNameplates:ClearAllPoints();
		InterfaceOptionsCombatPanelEnemyCastBarsOnNameplates:SetPoint(InterfaceOptionsCombatPanelEnemyCastBarsOnPortrait:GetPoint());
		InterfaceOptionsCombatPanelTargetOfTarget:SetScale(0.0001);
		InterfaceOptionsCombatPanelTargetOfTarget:SetAlpha(0);
		InterfaceOptionsDisplayPanelShowAggroPercentage:SetScale(0.0001);
		InterfaceOptionsDisplayPanelShowAggroPercentage:SetAlpha(0);
	end

	if(E.private["unitframe"]["disabledBlizzardFrames"].party) then
		InterfaceOptionsStatusTextPanelParty:SetScale(0.0001);
		InterfaceOptionsStatusTextPanelParty:SetAlpha(0);
		InterfaceOptionsFrameCategoriesButton11:SetScale(0.0001);
	end

	if(E.private["unitframe"]["disabledBlizzardFrames"].arena) then
		self:SecureHook("UnitFrameThreatIndicator_Initialize");

		if(not IsAddOnLoaded("Blizzard_ArenaUI")) then
			self:RegisterEvent("ADDON_LOADED");
		else
			ElvUF:DisableBlizzard("arena");
		end
	end

	local ORD = ns.oUF_RaidDebuffs or oUF_RaidDebuffs;
	if(not ORD) then return; end
	ORD.ShowDispelableDebuff = true;
	ORD.FilterDispellableDebuff = true;
	ORD.MatchBySpellName = true;
end

function UF:ResetUnitSettings(unit)
	E:CopyTable(self.db["units"][unit], P["unitframe"]["units"][unit]);

	if(self.db["units"][unit].buffs and self.db["units"][unit].buffs.sizeOverride) then
		self.db["units"][unit].buffs.sizeOverride = P.unitframe.units[unit].buffs.sizeOverride or 0;
	end

	if(self.db["units"][unit].debuffs and self.db["units"][unit].debuffs.sizeOverride) then
		self.db["units"][unit].debuffs.sizeOverride = P.unitframe.units[unit].debuffs.sizeOverride or 0;
	end

	self:Update_AllFrames();
end

function UF:ToggleForceShowGroupFrames(unitGroup, numGroup)
	for i = 1, numGroup do
		if(self[unitGroup..i] and not self[unitGroup..i].isForced) then
			UF:ForceShow(self[unitGroup..i]);
		elseif(self[unitGroup..i]) then
			UF:UnforceShow(self[unitGroup..i]);
		end
	end
end

local ignoreSettings = {
	["position"] = true,
	["playerOnly"] = true,
	["noConsolidated"] = true,
	["useBlacklist"] = true,
	["useWhitelist"] = true,
	["noDuration"] = true,
	["onlyDispellable"] = true,
	["useFilter"] = true
};

local ignoreSettingsGroup = {
	["visibility"] = true
};

local allowPass = {
	["sizeOverride"] = true
};

function UF:MergeUnitSettings(fromUnit, toUnit, isGroupUnit)
	local db = self.db["units"];
	local filter = ignoreSettings;
	if(isGroupUnit) then
		filter = ignoreSettingsGroup;
	end
	if(fromUnit ~= toUnit) then
		for option, value in pairs(db[fromUnit]) do
			if(type(value) ~= "table" and not filter[option]) then
				if(db[toUnit][option] ~= nil) then
					db[toUnit][option] = value;
				end
			elseif(not filter[option]) then
				if(type(value) == "table") then
					for opt, val in pairs(db[fromUnit][option]) do
						--local val = db[fromUnit][option][opt]
						if(type(val) ~= "table" and not filter[opt]) then
							if(db[toUnit][option] ~= nil and (db[toUnit][option][opt] ~= nil or allowPass[opt])) then
								db[toUnit][option][opt] = val;
							end
						elseif(not filter[opt]) then
							if(type(val) == "table") then
								for o, v in pairs(db[fromUnit][option][opt]) do
									if(not filter[o]) then
										if(db[toUnit][option] ~= nil and db[toUnit][option][opt] ~= nil and db[toUnit][option][opt][o] ~= nil) then
											db[toUnit][option][opt][o] = v;
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
		E:Print(L["You cannot copy settings from the same unit."]);
	end

	self:Update_AllFrames();
end

local function updateColor(self, r, g, b)
	if(not self.isTransparent) then
		return;
	end
	if(self.backdrop) then
		local _, _, _, a = self.backdrop:GetBackdropColor();
		self.backdrop:SetBackdropColor(r * 0.58, g * 0.58, b * 0.58, a);
	elseif(self:GetParent().template) then
		local _, _, _, a = self:GetParent():GetBackdropColor();
		self:GetParent():SetBackdropColor(r * 0.58, g * 0.58, b * 0.58, a);
	end

	if(self.bg and self.bg:GetObjectType() == "Texture" and not self.bg.multiplier) then
		self.bg:SetTexture(r * 0.35, g * 0.35, b * 0.35);
	end
end

function UF:ToggleTransparentStatusBar(isTransparent, statusBar, backdropTex, adjustBackdropPoints, invertBackdropTex)
	statusBar.isTransparent = isTransparent;

	local statusBarTex = statusBar:GetStatusBarTexture();
	local statusBarOrientation = statusBar:GetOrientation();
	if(isTransparent) then
		if(statusBar.backdrop) then
			statusBar.backdrop:SetTemplate("Transparent");
			statusBar.backdrop.ignoreUpdates = true;
		elseif(statusBar:GetParent().template) then
			statusBar:GetParent():SetTemplate("Transparent");
			statusBar:GetParent().ignoreUpdates = true;
		end

		statusBar:SetStatusBarTexture("");
		backdropTex:ClearAllPoints();
		if(statusBarOrientation == "VERTICAL") then
			backdropTex:SetPoint("TOPLEFT", statusBar, "TOPLEFT");
			backdropTex:SetPoint("BOTTOMLEFT", statusBarTex, "TOPLEFT");
			backdropTex:SetPoint("BOTTOMRIGHT", statusBarTex, "TOPRIGHT");
		else
			backdropTex:SetPoint("TOPLEFT", statusBarTex, "TOPRIGHT");
			backdropTex:SetPoint("BOTTOMLEFT", statusBarTex, "BOTTOMRIGHT");
			backdropTex:SetPoint("BOTTOMRIGHT", statusBar, "BOTTOMRIGHT");
		end

		if(invertBackdropTex) then
			backdropTex:Show();
		end

		if(not invertBackdropTex and not statusBar.hookedColor) then
			hooksecurefunc(statusBar, "SetStatusBarColor", updateColor);
			statusBar.hookedColor = true;
		end

		if(backdropTex.multiplier) then
			backdropTex.multiplier = 0.25;
		end
	else
		if(statusBar.backdrop) then
			statusBar.backdrop:SetTemplate("Default", nil, nil, not statusBar.PostCastStart and self.thinBorders);
			statusBar.backdrop.ignoreUpdates = nil;
		elseif(statusBar:GetParent().template) then
			statusBar:GetParent():SetTemplate("Default", nil, nil, self.thinBorders);
			statusBar:GetParent().ignoreUpdates = nil;
		end

		statusBar:SetStatusBarTexture(LSM:Fetch("statusbar", self.db.statusbar));
		if(adjustBackdropPoints) then
			backdropTex:ClearAllPoints();
			backdropTex:SetAllPoints(statusBar);
		end

		if(invertBackdropTex) then
			backdropTex:Hide();
		end

		if(backdropTex.multiplier) then
			backdropTex.multiplier = 0.25;
		end
	end
end

E:RegisterInitialModule(UF:GetName());