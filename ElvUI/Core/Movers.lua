local E, L, V, P, G = unpack(select(2, ...))
local Sticky = LibStub("LibSimpleSticky-1.0")

local _G = _G
local type, unpack, pairs = type, unpack, pairs
local find, format, split, trim = string.find, string.format, string.split, string.trim

local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local IsControlKeyDown = IsControlKeyDown
local IsShiftKeyDown = IsShiftKeyDown
local ERR_NOT_IN_COMBAT = ERR_NOT_IN_COMBAT

E.CreatedMovers = {}
E.DisabledMovers = {}

local function SizeChanged(frame)
	if InCombatLockdown() then return end

	if frame.dirtyWidth and frame.dirtyHeight then
		frame.mover:Size(frame.dirtyWidth, frame.dirtyHeight)
	else
		frame.mover:Size(frame:GetSize())
	end
end

local function GetPoint(obj, raw)
	local point, anchor, secondaryPoint, x, y = obj:GetPoint()
	if not anchor then anchor = ElvUIParent end

	if not raw then
		return format("%s,%s,%s,%d,%d", point, anchor:GetName(), secondaryPoint, E:Round(x), E:Round(y))
	else
		return point, anchor:GetName(), secondaryPoint, E:Round(x), E:Round(y)
	end
end

local function UpdateCoords(self)
	local mover = self.child
	local x, y, _, nudgePoint, nudgeInversePoint = E:CalculateMoverPoints(mover)

	local coordX, coordY = E:GetXYOffset(nudgeInversePoint, 1)
	ElvUIMoverNudgeWindow:ClearAllPoints()
	ElvUIMoverNudgeWindow:Point(nudgePoint, mover, nudgeInversePoint, coordX, coordY)
	E:UpdateNudgeFrame(mover, x, y)
end

local isDragging = false
local coordFrame = CreateFrame("Frame")
coordFrame:SetScript("OnUpdate", UpdateCoords)
coordFrame:Hide()

local function CreateMover(parent, name, text, overlay, snapOffset, postdrag, shouldDisable)
	if not parent then return end
	if E.CreatedMovers[name].Created then return end

	if overlay == nil then overlay = true end

	local width = parent.dirtyWidth or parent:GetWidth()
	local height = parent.dirtyHeight or parent:GetHeight()

	local f = CreateFrame("Button", name, E.UIParent)
	f:SetClampedToScreen(true)
	f:RegisterForDrag("LeftButton", "RightButton")
	f:EnableMouseWheel(true)
	f:SetMovable(true)
	f:Width(width)
	f:Height(height)
	f:SetTemplate("Transparent", nil, nil, true)
	f:Hide()

	f.parent = parent
	f.name = name
	f.textString = text
	f.postdrag = postdrag
	f.overlay = overlay
	f.snapOffset = snapOffset or -2
	f.shouldDisable = shouldDisable

	f:SetFrameLevel(parent:GetFrameLevel() + 1)
	if overlay then
		f:SetFrameStrata("DIALOG")
	else
		f:SetFrameStrata("BACKGROUND")
	end

	E.CreatedMovers[name].mover = f
	E["snapBars"][#E["snapBars"] + 1] = f

	local fs = f:CreateFontString(nil, "OVERLAY")
	fs:FontTemplate()
	fs:SetJustifyH("CENTER")
	fs:SetPoint("CENTER")
	fs:SetText(text or name)
	fs:SetTextColor(unpack(E["media"].rgbvaluecolor))
	f:SetFontString(fs)
	f.text = fs

	local point, anchor, secondaryPoint, x, y = GetPoint(parent, true)

	if E.db["movers"] and type(E.db["movers"][name]) == "string" then
		f:Point(split(",", E.db["movers"][name]))
	else
		f:Point(point, anchor, secondaryPoint, x, y)
	end

	local function OnDragStart(self)
		if InCombatLockdown() then E:Print(ERR_NOT_IN_COMBAT) return end

		if E.db["general"].stickyFrames then
			Sticky:StartMoving(self, E["snapBars"], f.snapOffset, f.snapOffset, f.snapOffset, f.snapOffset)
		else
			self:StartMoving()
		end

		coordFrame.child = self
		coordFrame:Show()
		isDragging = true
	end

	local function OnDragStop(self)
		if InCombatLockdown() then E:Print(ERR_NOT_IN_COMBAT) return end

		isDragging = false

		if E.db["general"].stickyFrames then
			Sticky:StopMoving(self)
		else
			self:StopMovingOrSizing()
		end

		local overridePoint
		if self.positionOverride then
			if self.positionOverride == "BOTTOM" or self.positionOverride == "TOP" then
				overridePoint = "BOTTOM"
			else
				overridePoint = "BOTTOMLEFT"
			end
		end

		local x, y, point = E:CalculateMoverPoints(self)
		self:ClearAllPoints()
		self:Point(self.positionOverride or point, E.UIParent, overridePoint and overridePoint or point, x, y)

		if self.positionOverride then
			self.parent:ClearAllPoints()
			self.parent:Point(self.positionOverride, self, self.positionOverride)
		end

		E:SaveMoverPosition(name)

		if ElvUIMoverNudgeWindow then
			E:UpdateNudgeFrame(self, x, y)
		end

		coordFrame.child = nil
		coordFrame:Hide()

		if postdrag and type(postdrag) == "function" then
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
		coordFrame:GetScript("OnUpdate")(coordFrame)
	end

	local function OnMouseDown(self, button)
		if button == "RightButton" then
			isDragging = false

			if E.db["general"].stickyFrames then
				Sticky:StopMoving(self)
			else
				self:StopMovingOrSizing()
			end

			if IsControlKeyDown() and self.textString then
				E:ResetMovers(self.textString)
			elseif IsShiftKeyDown() then
				self:Hide()
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

	local function OnMouseWheel(_, delta)
		if IsShiftKeyDown() then
			E:NudgeMover(delta)
		else
			E:NudgeMover(nil, delta)
		end
	end

	f:SetScript("OnDragStart", OnDragStart)
	f:SetScript("OnMouseUp", E.AssignFrameToNudge)
	f:SetScript("OnDragStop", OnDragStop)
	f:SetScript("OnEnter", OnEnter)
	f:SetScript("OnMouseDown", OnMouseDown)
	f:SetScript("OnLeave", OnLeave)
	f:SetScript("OnShow", OnShow)
	f:SetScript("OnMouseWheel", OnMouseWheel)

	parent:SetScript("OnSizeChanged", SizeChanged)
	parent.mover = f

	parent:ClearAllPoints()
	parent:Point(point, f, 0, 0)

	if postdrag and type(postdrag) == "function" then
		f:RegisterEvent("PLAYER_ENTERING_WORLD")
		f:SetScript("OnEvent", function(self)
			postdrag(f, E:GetScreenQuadrant(f))
			self:UnregisterAllEvents()
		end)
	end

	E.CreatedMovers[name].Created = true
end

function E:CalculateMoverPoints(mover, nudgeX, nudgeY)
	local screenWidth, screenHeight, screenCenter = E.UIParent:GetRight(), E.UIParent:GetTop(), E.UIParent:GetCenter()
	local x, y = mover:GetCenter()

	local LEFT = screenWidth / 3
	local RIGHT = screenWidth * 2 / 3
	local TOP = screenHeight / 2
	local point, nudgePoint, nudgeInversePoint

	if y >= TOP then
		point = "TOP"
		nudgePoint = "TOP"
		nudgeInversePoint = "BOTTOM"
		y = -(screenHeight - mover:GetTop())
	else
		point = "BOTTOM"
		nudgePoint = "BOTTOM"
		nudgeInversePoint = "TOP"
		y = mover:GetBottom()
	end

	if x >= RIGHT then
		point = point .. "RIGHT"
		nudgePoint = "RIGHT"
		nudgeInversePoint = "LEFT"
		x = mover:GetRight() - screenWidth
	elseif x <= LEFT then
		point = point .. "LEFT"
		nudgePoint = "LEFT"
		nudgeInversePoint = "RIGHT"
		x = mover:GetLeft()
	else
		x = x - screenCenter
	end

	if mover.positionOverride then
		if mover.positionOverride == "TOPLEFT" then
			x = mover:GetLeft() - E.diffGetLeft
			y = mover:GetTop() - E.diffGetTop
		elseif mover.positionOverride == "TOPRIGHT" then
			x = mover:GetRight() - E.diffGetRight
			y = mover:GetTop() - E.diffGetTop
		elseif mover.positionOverride == "BOTTOMLEFT" then
			x = mover:GetLeft() - E.diffGetLeft
			y = mover:GetBottom() - E.diffGetBottom
		elseif mover.positionOverride == "BOTTOMRIGHT" then
			x = mover:GetRight() - E.diffGetRight
			y = mover:GetBottom() - E.diffGetBottom
		elseif mover.positionOverride == "BOTTOM" then
			x = mover:GetCenter() - screenCenter
			y = mover:GetBottom() - E.diffGetBottom
		elseif mover.positionOverride == "TOP" then
			x = mover:GetCenter() - screenCenter
			y = mover:GetTop() - E.diffGetTop
		end
	end

	x = x + (nudgeX or 0)
	y = y + (nudgeY or 0)

	return x, y, point, nudgePoint, nudgeInversePoint
end

function E:UpdatePositionOverride(name)
	local f = _G[name]
	if f and f:GetScript("OnDragStop") then
		f:GetScript("OnDragStop")(f)
	end
end

function E:HasMoverBeenMoved(name)
	if E.db["movers"] and E.db["movers"][name] then
		return true
	else
		return false
	end
end

function E:SetMoverSnapOffset(name, offset)
	if not _G[name] or not E.CreatedMovers[name] then return end

	E.CreatedMovers[name].mover.snapOffset = offset or -2
	E.CreatedMovers[name]["snapoffset"] = offset or -2
end

function E:SaveMoverPosition(name)
	if not _G[name] then return end
	if not E.db.movers then E.db.movers = {} end

	E.db.movers[name] = GetPoint(_G[name])
end

function E:SaveMoverDefaultPosition(name)
	if not _G[name] then return end

	local f = _G[name]
	E.CreatedMovers[name]["point"] = GetPoint(f)
	E.CreatedMovers[name]["postdrag"](f, E:GetScreenQuadrant(f))
end

function E:CreateMover(parent, name, text, overlay, snapoffset, postdrag, moverTypes, shouldDisable)
	if not moverTypes then moverTypes = "ALL,GENERAL" end

	if not E.CreatedMovers[name] then
		E.CreatedMovers[name] = {}
		E.CreatedMovers[name]["parent"] = parent
		E.CreatedMovers[name]["text"] = text
		E.CreatedMovers[name]["overlay"] = overlay
		E.CreatedMovers[name]["postdrag"] = postdrag
		E.CreatedMovers[name]["snapoffset"] = snapoffset
		E.CreatedMovers[name]["point"] = GetPoint(parent)
		E.CreatedMovers[name]["shouldDisable"] = shouldDisable
		E.CreatedMovers[name]["type"] = {}

		local types = {split(",", moverTypes)}
		for i = 1, #types do
			E.CreatedMovers[name]["type"][types[i]] = true
		end
	end

	CreateMover(parent, name, text, overlay, snapoffset, postdrag, shouldDisable)
end

function E:ToggleMovers(show, moverType)
	self.configMode = show

	for name in pairs(E.CreatedMovers) do
		if show then
			if E.CreatedMovers[name]["type"][moverType] then
				_G[name]:Show()
			else
				_G[name]:Hide()
			end
		else
			_G[name]:Hide()
		end
	end
end

function E:DisableMover(name)
	if self.DisabledMovers[name] then return end

	if not self.CreatedMovers[name] then
		error(format("'%s' mover doesn't exist", name), 2)
	end

	self.DisabledMovers[name] = {}
	for x, y in pairs(self.CreatedMovers[name]) do
		self.DisabledMovers[name][x] = y
	end

	if self.configMode then
		_G[name]:Hide()
	end

	self.CreatedMovers[name] = nil
end

function E:EnableMover(name)
	if self.CreatedMovers[name] then return end

	if not self.DisabledMovers[name] then
		error(format("'%s' mover doesn't exist", name), 2)
	end

	self.CreatedMovers[name] = {}
	for x, y in pairs(self.DisabledMovers[name]) do
		self.CreatedMovers[name][x] = y
	end

	if self.configMode then
		_G[name]:Show()
	end

	self.DisabledMovers[name] = nil
end

function E:ResetMovers(arg)
	if not arg or trim(arg) == "" then
		for name in pairs(E.CreatedMovers) do
			local f = _G[name]
			local point, anchor, secondaryPoint, x, y = split(",", E.CreatedMovers[name]["point"])
			f:ClearAllPoints()
			f:Point(point, anchor, secondaryPoint, x, y)

			if E.CreatedMovers[name]["postdrag"] and type(E.CreatedMovers[name]["postdrag"]) == "function" then
				E.CreatedMovers[name]["postdrag"](f, E:GetScreenQuadrant(f))
			end
		end
		self.db.movers = nil
	else
		for name in pairs(E.CreatedMovers) do
			if E.CreatedMovers[name]["text"] == arg then
				local f = _G[name]
				local point, anchor, secondaryPoint, x, y = split(",", E.CreatedMovers[name]["point"])
				f:ClearAllPoints()
				f:Point(point, anchor, secondaryPoint, x, y)

				if self.db.movers then
					self.db.movers[name] = nil
				end

				if E.CreatedMovers[name]["postdrag"] and type(E.CreatedMovers[name]["postdrag"]) == "function" then
					E.CreatedMovers[name]["postdrag"](f, E:GetScreenQuadrant(f))
				end

				break
			end
		end
	end
end

function E:SetMoversPositions()
	for name, data in pairs(E.DisabledMovers) do
		local shouldDisable = data.shouldDisable and data.shouldDisable()
		if not shouldDisable then
			E:EnableMover(name)
		end
	end

	for name in pairs(E.CreatedMovers) do
		local f = _G[name]

		if E.db["movers"] and type(E.db["movers"][name]) == "string" then
			f:ClearAllPoints()
			f:Point(split(",", E.db["movers"][name]))
		elseif f then
			f:ClearAllPoints()
			f:Point(split(",", E.CreatedMovers[name]["point"]))
		end
	end
end

function E:SetMoversClampedToScreen(value)
	for name in pairs(E.CreatedMovers) do
		_G[name]:SetClampedToScreen(value)
	end
end

function E:LoadMovers()
	local mover
	for name in pairs(E.CreatedMovers) do
		mover = E.CreatedMovers[name]

		CreateMover(
			mover.parent,
			name,
			mover.text,
			mover.overlay,
			mover.snapOffset,
			mover.postdrag,
			mover.shouldDisable
		)
	end
end