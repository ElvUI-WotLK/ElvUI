﻿local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local Sticky = LibStub("LibSimpleSticky-1.0")

local _G = _G;
local type, unpack, pairs = type, unpack, pairs;
local min = math.min;
local format, split, find = string.format, string.split, string.find

local CreateFrame = CreateFrame;
local InCombatLockdown = InCombatLockdown;
local ERR_NOT_IN_COMBAT = ERR_NOT_IN_COMBAT;

E.CreatedMovers = {}

local function SizeChanged(frame)
	if InCombatLockdown() then return; end

	if frame.dirtyWidth and frame.dirtyHeight then
		frame.mover:Size(frame.dirtyWidth, frame.dirtyHeight)
	else
		frame.mover:Size(frame:GetSize())
	end
end

local function GetPoint(obj)
	local point, anchor, secondaryPoint, x, y = obj:GetPoint()
	if not anchor then anchor = ElvUIParent end

	return format("%s,%s,%s,%d,%d", point, anchor:GetName(), secondaryPoint, E:Round(x), E:Round(y));
end

local function UpdateCoords(self)
	local mover = self.child;
	local x, y, _, nudgePoint, nudgeInversePoint = E:CalculateMoverPoints(mover);
	
	local coordX, coordY = E:GetXYOffset(nudgeInversePoint, 1);
	ElvUIMoverNudgeWindow:ClearAllPoints();
	ElvUIMoverNudgeWindow:SetPoint(nudgePoint, mover, nudgeInversePoint, coordX, coordY);
	E:UpdateNudgeFrame(mover, x, y);
end

local isDragging = false;
local coordFrame = CreateFrame('Frame')
coordFrame:SetScript('OnUpdate', UpdateCoords)
coordFrame:Hide()

local function CreateMover(parent, name, text, overlay, snapOffset, postdrag)
	if not parent then return end --If for some reason the parent isnt loaded yet
	if E.CreatedMovers[name].Created then return end
	
	if overlay == nil then overlay = true end
	local point, anchor, secondaryPoint, x, y = split(",", GetPoint(parent));
	local f = CreateFrame("Button", name, E.UIParent)
	f:SetClampedToScreen(true)
	f:RegisterForDrag("LeftButton", "RightButton");
	f:EnableMouseWheel(true);
	f:SetMovable(true);
	f:SetWidth(parent:GetWidth())
	f:SetHeight(parent:GetHeight())
	f:SetTemplate("Transparent", nil, nil, true);
	f:Hide();
	f.parent = parent
	f.name = name
	f.textString = text
	f.postdrag = postdrag
	f.overlay = overlay
	f.snapOffset = snapOffset or -2;
	
	f:SetFrameLevel(parent:GetFrameLevel() + 1);
	if(overlay == true) then
		f:SetFrameStrata("DIALOG")
	else
		f:SetFrameStrata("BACKGROUND")
	end
	
	E.CreatedMovers[name].mover = f;
	E['snapBars'][#E['snapBars'] + 1] = f;
	
	local fs = f:CreateFontString(nil, "OVERLAY");
	fs:FontTemplate();
	fs:SetJustifyH("CENTER");
	fs:SetPoint("CENTER");
	fs:SetText(text or name);
	fs:SetTextColor(unpack(E["media"].rgbvaluecolor));
	f:SetFontString(fs);
	f.text = fs;
	
	if E.db['movers'] and E.db['movers'][name] then
		if type(E.db['movers'][name]) == 'table' then
			f:SetPoint(E.db["movers"][name]["p"], E.UIParent, E.db["movers"][name]["p2"], E.db["movers"][name]["p3"], E.db["movers"][name]["p4"])
			E.db['movers'][name] = GetPoint(f)
			f:ClearAllPoints()
		end
		
		local delim;
		local anchorString = E.db["movers"][name];
		if(find(anchorString, "\031")) then
			delim = "\031";
		elseif(find(anchorString, ",")) then
			delim = ",";
		end
		local point, anchor, secondaryPoint, x, y = split(delim, anchorString);
		f:SetPoint(point, anchor, secondaryPoint, x, y)
	else

		f:SetPoint(point, anchor, secondaryPoint, x, y)
	end
	
	local function OnDragStart(self)
		if InCombatLockdown() then E:Print(ERR_NOT_IN_COMBAT) return end
		
		if E.db['general'].stickyFrames then
			Sticky:StartMoving(self, E['snapBars'], f.snapOffset, f.snapOffset, f.snapOffset, f.snapOffset)
		else
			self:StartMoving() 
		end
		coordFrame.child = self
		coordFrame:Show()
		isDragging = true;
	end
	
	local function OnDragStop(self)
		if InCombatLockdown() then E:Print(ERR_NOT_IN_COMBAT) return end
		isDragging = false;
		if E.db['general'].stickyFrames then
			Sticky:StopMoving(self)
		else
			self:StopMovingOrSizing()
		end

		--[[
			okay i'm too drunk to figure this out in my head, i need to adjust this so moving a mover to the topleft topright or bottomright corners of the screen calculates the point from their respective areas
			instead of the bottomleft always, this way moving a raid group to the topleft corner of the screen will cause the raid group to spawn to the right and down
			
			GetLeft(), GetTop(), GetRight(), GetBottom() all return values based on on the bottomleft corner of the screen
			
			top:
				need to calculate the distance from this point to the very top of the screen then make it negative
				-(screenHeight - 846)
				OMG YAY IT WORKS!!! NOW LETS TRY FOR THE RIGHT SIDE
				
			right:
				need to calculate the distance from this point to the far right of the screen then make it negative
				YAY SAME FORMULAR WORKS!@!
				
		]]
		
		local x, y, point = E:CalculateMoverPoints(self);
		
		if self.positionOverride then
			self.parent:ClearAllPoints()
			self.parent:Point(self.positionOverride, self, self.positionOverride)
			
			self:ClearAllPoints()
			self:Point(self.positionOverride, E.UIParent, "BOTTOMLEFT", x, y)
		else
			self:ClearAllPoints()
			self:Point(point, E.UIParent, point, x, y)
		end
		
		E:SaveMoverPosition(name)

		if ElvUIMoverNudgeWindow then
			E:UpdateNudgeFrame(self)
		end
		
		coordFrame.child = nil
		coordFrame:Hide()		
			
		if postdrag ~= nil and type(postdrag) == 'function' then
			postdrag(self, E:GetScreenQuadrant(self))
		end
	
		self:SetUserPlaced(false)
	end
	
	local function OnEnter(self)
		if isDragging then return end
		self.text:SetTextColor(1, 1, 1)
		ElvUIMoverNudgeWindow:Show()
		E.AssignFrameToNudge(self)
		coordFrame.child = self
		coordFrame:GetScript('OnUpdate')(coordFrame)
	end
	
	local function OnMouseDown(self, button)
		if button == "RightButton" then
			isDragging = false;
			if E.db['general'].stickyFrames then
				Sticky:StopMoving(self)
			else
				self:StopMovingOrSizing()
			end
			if(IsControlKeyDown() and self.textString) then
				E:ResetMovers(self.textString);
			end
		end
	end
	
	local function OnLeave(self)
		if isDragging then return end
		self.text:SetTextColor(unpack(E["media"].rgbvaluecolor))
	end
	local function OnShow(self)
		self:SetBackdropBorderColor(unpack(E["media"].rgbvaluecolor))
	end
	
	local function OnMouseWheel(self, delta)
		if(IsShiftKeyDown()) then
			E:NudgeMover(delta);
		else
			E:NudgeMover(nil, delta);
		end
	end
	
	f:SetScript("OnDragStart", OnDragStart);
	f:SetScript('OnMouseUp', E.AssignFrameToNudge);
	f:SetScript("OnDragStop", OnDragStop);
	f:SetScript("OnEnter", OnEnter);
	f:SetScript("OnMouseDown", OnMouseDown);
	f:SetScript("OnLeave", OnLeave);
	f:SetScript("OnShow", OnShow);
	f:SetScript("OnMouseWheel", OnMouseWheel);
	
	parent:SetScript("OnSizeChanged", SizeChanged);
	parent.mover = f;
	
	parent:ClearAllPoints();
	parent:SetPoint(point, f, 0, 0);

	if postdrag ~= nil and type(postdrag) == 'function' then
		f:RegisterEvent("PLAYER_ENTERING_WORLD")
		f:SetScript("OnEvent", function(self, event)
			postdrag(f, E:GetScreenQuadrant(f))
			self:UnregisterAllEvents()
		end)
	end
	
	E.CreatedMovers[name].Created = true;
end

function E:CalculateMoverPoints(mover, nudgeX, nudgeY)
	local screenWidth, screenHeight, screenCenter = E.UIParent:GetRight(), E.UIParent:GetTop(), E.UIParent:GetCenter();
	local x, y = mover:GetCenter();
	
	local LEFT = screenWidth / 3;
	local RIGHT = screenWidth * 2 / 3;
	local TOP = screenHeight / 2;
	local point, nudgePoint, nudgeInversePoint;
	
	if(y >= TOP) then
		point = "TOP";
		nudgePoint = "TOP";
		nudgeInversePoint = "BOTTOM";
		y = -(screenHeight - mover:GetTop());
	else
		point = "BOTTOM";
		nudgePoint = "BOTTOM";
		nudgeInversePoint = "TOP";
		y = mover:GetBottom();
	end
	
	if(x >= RIGHT) then
		point = point .. "RIGHT";
		nudgePoint = "RIGHT";
		nudgeInversePoint = "LEFT";
		x = mover:GetRight() - screenWidth;
	elseif(x <= LEFT) then
		point = point .. "LEFT"
		nudgePoint = "LEFT";
		nudgeInversePoint = "RIGHT";
		x = mover:GetLeft()
	else
		x = x - screenCenter;
	end
	
	if(mover.positionOverride) then
		if(mover.positionOverride == "TOPLEFT") then
			x = mover:GetLeft() - E.diffGetLeft;
			y = mover:GetTop() - E.diffGetTop;
		elseif(self.positionOverride == "TOPRIGHT") then
			x = mover:GetRight() - E.diffGetRight;
			y = mover:GetTop() - E.diffGetTop;
		elseif(mover.positionOverride == "BOTTOMLEFT") then
			x = mover:GetLeft() - E.diffGetLeft;
			y = mover:GetBottom() - E.diffGetBottom;
		elseif(mover.positionOverride == "BOTTOMRIGHT") then
			x = mover:GetRight() - E.diffGetRight;
			y = mover:GetBottom() - E.diffGetBottom;
		end
	end
	
	x = x + (nudgeX or 0);
	y = y + (nudgeY or 0);
	
	return x, y, point, nudgePoint, nudgeInversePoint;
end

function E:UpdatePositionOverride(name)
	if _G[name] and _G[name]:GetScript("OnDragStop") then
		_G[name]:GetScript("OnDragStop")(_G[name])
	end
end

function E:HasMoverBeenMoved(name)
	if E.db["movers"] and E.db["movers"][name] then
		return true
	else
		return false
	end
end

function E:SaveMoverPosition(name)
	if not _G[name] then return end
	if not E.db.movers then E.db.movers = {} end

	E.db.movers[name] = GetPoint(_G[name])
end

function E:SetMoverSnapOffset(name, offset)
	if not _G[name] or not E.CreatedMovers[name] then return end
	E.CreatedMovers[name].mover.snapOffset = offset or -2
	E.CreatedMovers[name]["snapoffset"] = offset or -2
end

function E:SaveMoverDefaultPosition(name)
	if not _G[name] then return end

	E.CreatedMovers[name]["point"] = GetPoint(_G[name])
	E.CreatedMovers[name]["postdrag"](_G[name], E:GetScreenQuadrant(_G[name]))
end

function E:CreateMover(parent, name, text, overlay, snapoffset, postdrag, moverTypes)
	if not moverTypes then moverTypes = 'ALL,GENERAL' end
	local p, p2, p3, p4, p5 = parent:GetPoint()
	
	if E.CreatedMovers[name] == nil then 
		E.CreatedMovers[name] = {}
		E.CreatedMovers[name]["parent"] = parent
		E.CreatedMovers[name]["text"] = text
		E.CreatedMovers[name]["overlay"] = overlay
		E.CreatedMovers[name]["postdrag"] = postdrag
		E.CreatedMovers[name]["snapoffset"] = snapOffset
		E.CreatedMovers[name]["point"] = GetPoint(parent)

		E.CreatedMovers[name]["type"] = {}
		local types = {split(',', moverTypes)}
		for i = 1, #types do
			local moverType = types[i]
			E.CreatedMovers[name]["type"][moverType] = true
		end
	end
	
	CreateMover(parent, name, text, overlay, snapoffset, postdrag)
end

function E:ToggleMovers(show, moverType)
	for name, _ in pairs(E.CreatedMovers) do
		if not show then
			_G[name]:Hide()
		else
			if E.CreatedMovers[name]['type'][moverType] then
				_G[name]:Show()
			else
				_G[name]:Hide()
			end
		end
	end
end

function E:ResetMovers(arg)
	if arg == "" or arg == nil then
		for name, _ in pairs(E.CreatedMovers) do
			local f = _G[name]
			local point, anchor, secondaryPoint, x, y = split(",", E.CreatedMovers[name]["point"]);
			f:ClearAllPoints()
			f:SetPoint(point, anchor, secondaryPoint, x, y)
			
			for key, value in pairs(E.CreatedMovers[name]) do
				if key == "postdrag" and type(value) == 'function' then
					value(f, E:GetScreenQuadrant(f))
				end
			end
		end
		self.db.movers = nil
	else
		for name, _ in pairs(E.CreatedMovers) do
			for key, value in pairs(E.CreatedMovers[name]) do
				local mover
				if key == "text" then
					if arg == value then 
						local f = _G[name]
						local point, anchor, secondaryPoint, x, y = split(",", E.CreatedMovers[name]["point"]);
						f:ClearAllPoints()
						f:SetPoint(point, anchor, secondaryPoint, x, y)				
						
						if self.db.movers then
							self.db.movers[name] = nil
						end
						
						if E.CreatedMovers[name]["postdrag"] ~= nil and type(E.CreatedMovers[name]["postdrag"]) == 'function' then
							E.CreatedMovers[name]["postdrag"](f, E:GetScreenQuadrant(f))
						end
					end
				end
			end
		end
	end
end

--Profile Change
function E:SetMoversPositions()
	for name, _ in pairs(E.CreatedMovers) do
		local f = _G[name]
		local point, anchor, secondaryPoint, x, y
		if E.db["movers"] and E.db["movers"][name] and type(E.db["movers"][name]) == 'string' then
			local delim;
			local anchorString = E.db["movers"][name];
			if(find(anchorString, "\031")) then
				delim = "\031";
			elseif(find(anchorString, ",")) then
				delim = ",";
			end
			point, anchor, secondaryPoint, x, y = split(delim, anchorString);
			f:ClearAllPoints()
			f:SetPoint(point, anchor, secondaryPoint, x, y)
		elseif f then
			point, anchor, secondaryPoint, x, y = split(",", E.CreatedMovers[name]["point"]);
			f:ClearAllPoints()
			f:SetPoint(point, anchor, secondaryPoint, x, y)
		end
	end
end

--Called from core.lua
function E:LoadMovers()
	for n, _ in pairs(E.CreatedMovers) do
		local p, t, o, so, pd
		for key, value in pairs(E.CreatedMovers[n]) do
			if key == "parent" then
				p = value
			elseif key == "text" then
				t = value
			elseif key == "overlay" then
				o = value
			elseif key == "snapoffset" then
				so = value
			elseif key == "postdrag" then
				pd = value
			end
		end
		CreateMover(p, n, t, o, so, pd)
	end
end