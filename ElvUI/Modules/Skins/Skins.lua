local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local unpack, pairs, ipairs, select, type = unpack, pairs, ipairs, select, type
local floor = math.floor
local find, format, lower = string.find, string.format, string.lower
--WoW API / Variables
local IsAddOnLoaded = IsAddOnLoaded
local UIPanelWindows = UIPanelWindows
local UpdateUIPanelPositions = UpdateUIPanelPositions
local hooksecurefunc = hooksecurefunc

S.allowBypass = {}
S.addonCallbacks = {}
S.nonAddonCallbacks = {["CallPriority"] = {}}

S.ArrowRotation = {
	["up"] = 0,
	["down"] = 3.14,
	["left"] = 1.57,
	["right"] = -1.57,
}

function S:SetModifiedBackdrop()
	if self.backdrop then self = self.backdrop end
	self:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
end

function S:SetOriginalBackdrop()
	if self.backdrop then self = self.backdrop end
	self:SetBackdropBorderColor(unpack(E.media.bordercolor))
end

function S:StatusBarColorGradient(bar, value, max, backdrop)
	local current = (not max and value) or (value and max and max ~= 0 and value/max)
	if not (bar and current) then return end
	local r, g, b = E:ColorGradient(current, 0.8,0,0, 0.8,0.8,0, 0,0.8,0)
	local bg = backdrop or bar.backdrop
	if bg then bg:SetBackdropColor(r*0.25, g*0.25, b*0.25) end
	bar:SetStatusBarColor(r, g, b)
end

function S:HandleButton(button, strip, isDeclineButton, useCreateBackdrop, noSetTemplate)
	if button.isSkinned then return end

	local buttonName = button.GetName and button:GetName()
	if buttonName then
		local left = _G[buttonName.."Left"]
		local middle = _G[buttonName.."Middle"]
		local right = _G[buttonName.."Right"]

		if left then left:SetAlpha(0) end
		if middle then middle:SetAlpha(0) end
		if right then right:SetAlpha(0) end
	end

	if button.Left then button.Left:SetAlpha(0) end
	if button.Middle then button.Middle:SetAlpha(0) end
	if button.Right then button.Right:SetAlpha(0) end

	if button.SetNormalTexture then button:SetNormalTexture("") end
	if button.SetHighlightTexture then button:SetHighlightTexture("") end
	if button.SetPushedTexture then button:SetPushedTexture("") end
	if button.SetDisabledTexture then button:SetDisabledTexture("") end

	if strip then button:StripTextures() end

	if useCreateBackdrop then
		button:CreateBackdrop(nil, true)
	elseif not noSetTemplate then
		button:SetTemplate(nil, true)
	end

	button:HookScript("OnEnter", S.SetModifiedBackdrop)
	button:HookScript("OnLeave", S.SetOriginalBackdrop)

	button.isSkinned = true
end

function S:HandleButtonHighlight(frame, r, g, b, a)
	if not r then r = 0.9 end
	if not g then g = 0.9 end
	if not b then b = 0.9 end
	if not a then a = 0.35 end

	local highlightTexture

	if frame.SetHighlightTexture then
		highlightTexture = frame:GetHighlightTexture()
		highlightTexture:SetAllPoints(frame)
	elseif frame.SetTexture then
		highlightTexture = frame
		frame:SetAllPoints(frame:GetParent())
	elseif frame.HighlightTexture then
		highlightTexture = frame.HighlightTexture
	else
		highlightTexture = frame:CreateTexture(nil, "HIGHLIGHT")
		highlightTexture:SetAllPoints(frame)
		frame.HighlightTexture = highlightTexture
	end

	highlightTexture:SetTexture(E.Media.Textures.Highlight)
	highlightTexture:SetVertexColor(r, g, b, a)
end

function S:HandleScrollBar(frame, horizontal)
	if frame.backdrop then return end

	local parent = frame:GetParent()
	local frameName = frame:GetName()

	local scrollUpButton, scrollDownButton
	local thumb = frame.thumbTexture or frame.GetThumbTexture and frame:GetThumbTexture() or _G[format("%s%s", frameName, "ThumbTexture")]

	if not horizontal then
		scrollUpButton = parent.scrollUp or _G[format("%s%s", frameName, "ScrollUpButton")] or _G[format("%s%s", frameName, "UpButton")] or _G[format("%s%s", frameName, "ScrollUp")]
		scrollDownButton = parent.scrollDown or _G[format("%s%s", frameName, "ScrollDownButton")] or _G[format("%s%s", frameName, "DownButton")] or _G[format("%s%s", frameName, "ScrollDown")]
	else
		scrollUpButton = _G[format("%s%s", frameName, "ScrollLeftButton")] or _G[format("%s%s", frameName, "LeftButton")] or _G[format("%s%s", frameName, "ScrollLeft")]
		scrollDownButton = _G[format("%s%s", frameName, "ScrollRightButton")] or _G[format("%s%s", frameName, "RightButton")] or _G[format("%s%s", frameName, "ScrollRight")]
	end

	if not horizontal then
		frame:Width(18)
	else
		frame:Height(18)
	end

	local frameLevel = frame:GetFrameLevel()
	frame:StripTextures()
	frame:CreateBackdrop()
	frame.backdrop:SetAllPoints()
	frame.backdrop:SetFrameLevel(frameLevel)

	if scrollUpButton then
		if not horizontal then
			scrollUpButton:Point("BOTTOM", frame, "TOP", 0, 1)
			S:HandleNextPrevButton(scrollUpButton, "up")
		else
			scrollUpButton:Point("RIGHT", frame, "LEFT", -1, 0)
			S:HandleNextPrevButton(scrollUpButton, "left")
		end
	end

	if scrollDownButton then
		if not horizontal then
			scrollDownButton:Point("TOP", frame, "BOTTOM", 0, -1)
			S:HandleNextPrevButton(scrollDownButton, "down")
		else
			scrollDownButton:Point("LEFT", frame, "RIGHT", 1, 0)
			S:HandleNextPrevButton(scrollDownButton, "right")
		end
	end

	if thumb and not thumb.backdrop then
		if not horizontal then
			thumb:Size(18, 22)
		else
			thumb:Size(22, 18)
		end

		thumb:SetTexture()
		thumb:CreateBackdrop(nil, true, true)
		thumb.backdrop:SetFrameLevel(frameLevel + 1)
		thumb.backdrop:SetBackdropColor(0.6, 0.6, 0.6)

		thumb.backdrop:Point("TOPLEFT", thumb, "TOPLEFT", 2, -2)
		thumb.backdrop:Point("BOTTOMRIGHT", thumb, "BOTTOMRIGHT", -2, 2)

		if not frame.thumbTexture then
			frame.thumbTexture = thumb
		end
	end
end

local tabs = {
	"LeftDisabled",
	"MiddleDisabled",
	"RightDisabled",
	"Left",
	"Middle",
	"Right"
}

function S:HandleTab(tab, noBackdrop)
	if (not tab) or (tab.backdrop and not noBackdrop) then return end

	for _, object in ipairs(tabs) do
		local tex = _G[tab:GetName()..object]
		if tex then
			tex:SetTexture()
		end
	end

	local highlightTex = tab.GetHighlightTexture and tab:GetHighlightTexture()
	if highlightTex then
		highlightTex:SetTexture()
	else
		tab:StripTextures()
	end

	if not noBackdrop then
		tab:CreateBackdrop()
		tab.backdrop:Point("TOPLEFT", 10, E.PixelMode and -1 or -3)
		tab.backdrop:Point("BOTTOMRIGHT", -10, 3)

		tab:SetHitRectInsets(10, 10, E.PixelMode and 1 or 3, 3)
	end
end

function S:HandleRotateButton(btn)
	if btn.isSkinned then return end

	btn:SetTemplate()
	btn:Size(btn:GetWidth() - 14, btn:GetHeight() - 14)

	local normTex = btn:GetNormalTexture()
	local pushTex = btn:GetPushedTexture()
	local highlightTex = btn:GetHighlightTexture()

	normTex:SetInside()
	normTex:SetTexCoord(0.3, 0.29, 0.3, 0.65, 0.69, 0.29, 0.69, 0.65)

	pushTex:SetAllPoints(normTex)
	pushTex:SetTexCoord(0.3, 0.29, 0.3, 0.65, 0.69, 0.29, 0.69, 0.65)

	highlightTex:SetAllPoints(normTex)
	highlightTex:SetTexture(1, 1, 1, 0.3)

	btn.isSkinned = true
end

function S:HandleEditBox(frame)
	if frame.backdrop then return end

	frame:CreateBackdrop()
	frame.backdrop:SetFrameLevel(frame:GetFrameLevel())

	local EditBoxName = frame.GetName and frame:GetName()
	if EditBoxName then
		if _G[EditBoxName.."Left"] then _G[EditBoxName.."Left"]:SetAlpha(0) end
		if _G[EditBoxName.."Middle"] then _G[EditBoxName.."Middle"]:SetAlpha(0) end
		if _G[EditBoxName.."Right"] then _G[EditBoxName.."Right"]:SetAlpha(0) end
		if _G[EditBoxName.."Mid"] then _G[EditBoxName.."Mid"]:SetAlpha(0) end

		if find(EditBoxName, "Silver") or find(EditBoxName, "Copper") then
			frame.backdrop:Point("BOTTOMRIGHT", -12, -2)
		end
	end
end

function S:HandleDropDownBox(frame, width, direction)
	if frame.backdrop then return end

	local FrameName = frame.GetName and frame:GetName()
	local button = FrameName and _G[FrameName.."Button"]
	local text = FrameName and _G[FrameName.."Text"]

	frame:StripTextures()
	frame:CreateBackdrop()
	frame.backdrop:SetFrameLevel(frame:GetFrameLevel())
	frame.backdrop:Point("TOPLEFT", 20, -3)
	frame.backdrop:Point("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)

	if not width then width = 155 end

	frame:Width(width)

	if text then
		text:ClearAllPoints()
		text:Point("RIGHT", button, "LEFT", -2, 0)
	end

	if button then
		S:HandleNextPrevButton(button, direction or nil, {1, 0.8, 0})
		button:ClearAllPoints()
		button:Point("RIGHT", frame, "RIGHT", -10, 3)
		button:Size(16, 16)
	end
end

function S:HandleStatusBar(frame, color)
	frame:SetFrameLevel(frame:GetFrameLevel() + 1)
	frame:StripTextures()
	frame:CreateBackdrop("Transparent")
	frame:SetStatusBarTexture(E.media.normTex)
	frame:SetStatusBarColor(unpack(color or {.01, .39, .1}))
	E:RegisterStatusBar(frame)
end

function S:HandleCheckBox(frame, noBackdrop, noReplaceTextures, forceSaturation)
	if frame.isSkinned then return end

	frame:StripTextures()
	frame.forceSaturation = forceSaturation

	if noBackdrop then
		frame:SetTemplate()
		frame:Size(16)
	else
		frame:CreateBackdrop()
		frame.backdrop:SetInside(nil, 4, 4)
	end

	if not noReplaceTextures then
		if frame.SetCheckedTexture then
			if E.private.skins.checkBoxSkin then
				frame:SetCheckedTexture(E.Media.Textures.Melli)

				local checkedTexture = frame:GetCheckedTexture()
				checkedTexture:SetVertexColor(1, 0.82, 0, 0.8)
				checkedTexture:SetInside(frame.backdrop)
			else
				frame:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")

				if noBackdrop then
					frame:GetCheckedTexture():SetInside(nil, -4, -4)
				end
			end
		end

		if frame.SetDisabledCheckedTexture then
			if E.private.skins.checkBoxSkin then
				frame:SetDisabledCheckedTexture(E.Media.Textures.Melli)

				local disabledCheckedTexture = frame:GetDisabledCheckedTexture()
				disabledCheckedTexture:SetVertexColor(0.6, 0.6, 0.6, 0.8)
				disabledCheckedTexture:SetInside(frame.backdrop)
			else
				frame:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")

				if noBackdrop then
					frame:GetDisabledCheckedTexture():SetInside(nil, -4, -4)
				end
			end
		end

		if frame.SetDisabledTexture then
			if E.private.skins.checkBoxSkin then
				frame:SetDisabledTexture(E.Media.Textures.Melli)

				local disabledTexture = frame:GetDisabledTexture()
				disabledTexture:SetVertexColor(0.6, 0.6, 0.6, 0.8)
				disabledTexture:SetInside(frame.backdrop)
			else
				frame:SetDisabledTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")

				if noBackdrop then
					frame:GetDisabledTexture():SetInside(nil, -4, -4)
				end
			end
		end

		frame:HookScript("OnDisable", function(checkbox)
			if not checkbox.SetDisabledTexture then return end

			if checkbox:GetChecked() then
				if E.private.skins.checkBoxSkin then
					checkbox:SetDisabledTexture(E.Media.Textures.Melli)
				else
					checkbox:SetDisabledTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
				end
			else
				checkbox:SetDisabledTexture("")
			end
		end)

		hooksecurefunc(frame, "SetNormalTexture", function(checkbox, texPath)
			if texPath ~= "" then checkbox:SetNormalTexture("") end
		end)
		hooksecurefunc(frame, "SetPushedTexture", function(checkbox, texPath)
			if texPath ~= "" then checkbox:SetPushedTexture("") end
		end)
		hooksecurefunc(frame, "SetHighlightTexture", function(checkbox, texPath)
			if texPath ~= "" then checkbox:SetHighlightTexture("") end
		end)
		hooksecurefunc(frame, "SetCheckedTexture", function(checkbox, texPath)
			if texPath == E.Media.Textures.Melli or texPath == "Interface\\Buttons\\UI-CheckBox-Check" then return end
			if E.private.skins.checkBoxSkin then
				checkbox:SetCheckedTexture(E.Media.Textures.Melli)
			else
				checkbox:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
			end
		end)
	end

	frame.isSkinned = true
end

function S:HandleColorSwatch(frame, size)
	if frame.isSkinned then return end

	frame:StripTextures()
	frame:CreateBackdrop("Default")
	frame.backdrop:SetFrameLevel(frame:GetFrameLevel())

	if size then
		frame:Size(size)
	end

	local normalTexture = frame:GetNormalTexture()
	normalTexture:SetTexture(E.media.blankTex)
	normalTexture:ClearAllPoints()
	normalTexture:SetInside(frame.backdrop)

	frame.isSkinned = true
end

function S:HandleIcon(icon, parent)
	parent = parent or icon:GetParent()

	icon:SetTexCoord(unpack(E.TexCoords))
	parent:CreateBackdrop("Default")
	icon:SetParent(parent.backdrop)
	parent.backdrop:SetOutside(icon)
end

function S:HandleItemButton(b, shrinkIcon)
	if b.isSkinned then return end

	local icon = b.icon or b.IconTexture or b.iconTexture
	local texture
	if b:GetName() and _G[b:GetName().."IconTexture"] then
		icon = _G[b:GetName().."IconTexture"]
	elseif b:GetName() and _G[b:GetName().."Icon"] then
		icon = _G[b:GetName().."Icon"]
	end

	if icon and icon:GetTexture() then
		texture = icon:GetTexture()
	end

	b:StripTextures()
	b:CreateBackdrop("Default", true)
	b:StyleButton()

	if icon then
		icon:SetTexCoord(unpack(E.TexCoords))

		if shrinkIcon then
			b.backdrop:SetAllPoints()
			icon:SetInside(b)
		else
			b.backdrop:SetOutside(icon)
		end
		icon:SetParent(b.backdrop)

		if texture then
			icon:SetTexture(texture)
		end
	end

	b.isSkinned = true
end

local handleCloseButtonOnEnter = function(btn) if btn.Texture then btn.Texture:SetVertexColor(unpack(E.media.rgbvaluecolor)) end end
local handleCloseButtonOnLeave = function(btn) if btn.Texture then btn.Texture:SetVertexColor(1, 1, 1) end end

function S:HandleCloseButton(f, point)
	f:StripTextures()

	if f:GetNormalTexture() then f:SetNormalTexture("") f.SetNormalTexture = E.noop end
	if f:GetPushedTexture() then f:SetPushedTexture("") f.SetPushedTexture = E.noop end

	if not f.Texture then
		f.Texture = f:CreateTexture(nil, "OVERLAY")
		f.Texture:Point("CENTER")
		f.Texture:SetTexture(E.Media.Textures.Close)
		f.Texture:Size(12, 12)
		f:HookScript("OnEnter", handleCloseButtonOnEnter)
		f:HookScript("OnLeave", handleCloseButtonOnLeave)
		f:SetHitRectInsets(6, 6, 7, 7)
	end

	if point then
		f:Point("TOPRIGHT", point, "TOPRIGHT", 2, 3)
	end
end

local sliderOnDisable = function(self) self:GetThumbTexture():SetVertexColor(0.6, 0.6, 0.6, 0.8) end
local sliderOnEnable = function(self) self:GetThumbTexture():SetVertexColor(1, 0.82, 0, 0.8) end

function S:HandleSliderFrame(frame)
	local orientation = frame:GetOrientation()

	frame:StripTextures()
	frame:SetTemplate()
	frame:SetThumbTexture(E.Media.Textures.Melli)

	local thumb = frame:GetThumbTexture()
	thumb:SetVertexColor(1, 0.82, 0, 0.8)
	thumb:Size(10)

	frame:HookScript("OnDisable", sliderOnDisable)
	frame:HookScript("OnEnable", sliderOnEnable)

	if orientation == "VERTICAL" then
		frame:Width(12)
	else
		frame:Height(12)

		for i = 1, frame:GetNumRegions() do
			local region = select(i, frame:GetRegions())
			if region and region:IsObjectType("FontString") then
				local point, anchor, anchorPoint, x, y = region:GetPoint()
				if find(anchorPoint, "BOTTOM") then
					region:Point(point, anchor, anchorPoint, x, y - 4)
				end
			end
		end
	end
end

function S:HandleIconSelectionFrame(frame, numIcons, buttonNameTemplate, frameNameOverride)
	local frameName = frameNameOverride or frame:GetName() --We need override in case Blizzard fucks up the naming (guild bank)
	local scrollFrame = _G[frameName.."ScrollFrame"]
	local editBox = _G[frameName.."EditBox"]
	local okayButton = _G[frameName.."OkayButton"] or _G[frameName.."Okay"]
	local cancelButton = _G[frameName.."CancelButton"] or _G[frameName.."Cancel"]

	frame:StripTextures()
	scrollFrame:StripTextures()
	editBox:DisableDrawLayer("BACKGROUND") --Removes textures around it

	frame:CreateBackdrop("Transparent")
	frame.backdrop:Point("TOPLEFT", frame, "TOPLEFT", 10, -12)
	frame.backdrop:Point("BOTTOMRIGHT", cancelButton, "BOTTOMRIGHT", 8, -8)

	S:HandleButton(okayButton)
	S:HandleButton(cancelButton)
	S:HandleEditBox(editBox)

	for i = 1, numIcons do
		local button = _G[buttonNameTemplate..i]
		local icon = _G[button:GetName().."Icon"]
		button:StripTextures()
		button:SetTemplate("Default")
		button:StyleButton(nil, true)
		icon:SetInside()
		icon:SetTexCoord(unpack(E.TexCoords))
	end
end

function S:HandleNextPrevButton(btn, arrowDir, color, noBackdrop, stipTexts)
	if btn.isSkinned then return end

	if not arrowDir then
		arrowDir = "down"
		local ButtonName = btn:GetName() and lower(btn:GetName())

		if ButtonName then
			if (find(ButtonName, "left") or find(ButtonName, "prev") or find(ButtonName, "decrement")) then
				arrowDir = "left"
			elseif (find(ButtonName, "right") or find(ButtonName, "next") or find(ButtonName, "increment")) then
				arrowDir = "right"
			elseif (find(ButtonName, "scrollup") or find(ButtonName, "upbutton") or find(ButtonName, "top") or find(ButtonName, "promote")) then
				arrowDir = "up"
			end
		end
	end

	btn:SetHitRectInsets(0, 0, 0, 0)

	btn:StripTextures()
	if not noBackdrop then
		S:HandleButton(btn)
	end

	if stipTexts then
		btn:StripTexts()
	end

	btn:SetNormalTexture(E.Media.Textures.ArrowUp)
	btn:SetPushedTexture(E.Media.Textures.ArrowUp)
	btn:SetDisabledTexture(E.Media.Textures.ArrowUp)

	local Normal, Disabled, Pushed = btn:GetNormalTexture(), btn:GetDisabledTexture(), btn:GetPushedTexture()

	if noBackdrop then
		btn:Size(20, 20)
		Disabled:SetVertexColor(.5, .5, .5)
		btn.Texture = Normal
		btn:HookScript("OnEnter", handleCloseButtonOnEnter)
		btn:HookScript("OnLeave", handleCloseButtonOnLeave)
	else
		btn:Size(18, 18)
		Disabled:SetVertexColor(.3, .3, .3)
	end

	Normal:SetInside()
	Pushed:SetInside()
	Disabled:SetInside()

	Normal:SetTexCoord(0, 1, 0, 1)
	Pushed:SetTexCoord(0, 1, 0, 1)
	Disabled:SetTexCoord(0, 1, 0, 1)

	Normal:SetRotation(S.ArrowRotation[arrowDir])
	Pushed:SetRotation(S.ArrowRotation[arrowDir])
	Disabled:SetRotation(S.ArrowRotation[arrowDir])

	Normal:SetVertexColor(unpack(color or {1, 1, 1}))

	btn.isSkinned = true
end

function S:SetNextPrevButtonDirection(frame, arrowDir)
	local direction = self.ArrowRotation[(arrowDir or "down")]

	frame:GetNormalTexture():SetRotation(direction)
	frame:GetDisabledTexture():SetRotation(direction)
	frame:GetPushedTexture():SetRotation(direction)
end

function S:ADDON_LOADED(_, addon)
	S:SkinAce3()

	if self.allowBypass[addon] then
		if self.addonCallbacks[addon] then
			--Fire events to the skins that rely on this addon
			for index, event in ipairs(self.addonCallbacks[addon].CallPriority) do
				self.addonCallbacks[addon][event] = nil
				self.addonCallbacks[addon].CallPriority[index] = nil
				E.callbacks:Fire(event)
			end
		end
		return
	end

	if not E.initialized then return end

	if self.addonCallbacks[addon] then
		for index, event in ipairs(self.addonCallbacks[addon].CallPriority) do
			self.addonCallbacks[addon][event] = nil
			self.addonCallbacks[addon].CallPriority[index] = nil
			E.callbacks:Fire(event)
		end
	end
end

local function SetPanelWindowInfo(frame, name, value, igroneUpdate)
	frame:SetAttribute(name, value)

	if not igroneUpdate and frame:IsShown() then
		UpdateUIPanelPositions(frame)
	end
end

local UI_PANEL_OFFSET = 7

function S:SetUIPanelWindowInfo(frame, name, value, offset, igroneUpdate)
	local frameName = frame and frame.GetName and frame:GetName()
	if not (frameName and UIPanelWindows[frameName]) then return end

	name = "UIPanelLayout-"..name

	if name == "UIPanelLayout-width" then
		value = E:Scale(value or (frame.backdrop and frame.backdrop:GetWidth() or frame:GetWidth())) + (offset or 0) + UI_PANEL_OFFSET
	end

	local valueChanged = frame:GetAttribute(name) ~= value

	if not frame:CanChangeAttribute() then
		local frameInfo = format("%s-%s", frameName, name)

		if self.uiPanelQueue[frameInfo] then
			if not valueChanged then
				self.uiPanelQueue[frameInfo][3] = nil
			else
				self.uiPanelQueue[frameInfo][3] = value
				self.uiPanelQueue[frameInfo][4] = igroneUpdate
			end
		elseif valueChanged then
			self.uiPanelQueue[frameInfo] = {frame, name, value, igroneUpdate}

			if not self.inCombat then
				self.inCombat = true
				S:RegisterEvent("PLAYER_REGEN_ENABLED")
			end
		end
	elseif valueChanged then
		SetPanelWindowInfo(frame, name, value, igroneUpdate)
	end
end

function S:SetBackdropHitRect(frame, backdrop, clampRect, attempt)
	if not frame then return end

	backdrop = backdrop or frame.backdrop
	if not backdrop then return end

	local left = frame:GetLeft()
	local bleft = backdrop:GetLeft()

	if not left or not bleft then
		if attempt ~= 10 then
			E:Delay(0.1, S.SetBackdropHitRect, S, frame, backdrop, clampRect, attempt and attempt + 1 or 1)
		end

		return
	end

	left = floor(left + 0.5)
	local right = floor(frame:GetRight() + 0.5)
	local top = floor(frame:GetTop() + 0.5)
	local bottom = floor(frame:GetBottom() + 0.5)

	bleft = floor(bleft + 0.5)
	local bright = floor(backdrop:GetRight() + 0.5)
	local btop = floor(backdrop:GetTop() + 0.5)
	local bbottom = floor(backdrop:GetBottom() + 0.5)

	left = bleft - left
	right = right - bright
	top = top - btop
	bottom = bbottom - bottom

	if not frame:CanChangeAttribute() then
		self.hitRectQueue[frame] = {left, right, top, bottom, clampRect}

		if not self.inCombat then
			self.inCombat = true
			S:RegisterEvent("PLAYER_REGEN_ENABLED")
		end
	else
		frame:SetHitRectInsets(left, right, top, bottom)

		if clampRect then
			frame:SetClampRectInsets(left, -right, -top, bottom)
		end
	end
end

function S:PLAYER_REGEN_ENABLED()
	self.inCombat = nil
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")

	for frameInfo, info in pairs(self.uiPanelQueue) do
		if info[3] then
			SetPanelWindowInfo(info[1], info[2], info[3], info[4])
		end
		self.uiPanelQueue[frameInfo] = nil
	end

	for frame, info in pairs(self.hitRectQueue) do
		frame:SetHitRectInsets(info[1], info[2], info[3], info[4])

		if info[5] then
			frame:SetClampRectInsets(info[1], info[2], info[3], info[4])
		end

		self.hitRectQueue[frame] = nil
	end
end

--Add callback for skin that relies on another addon.
--These events will be fired when the addon is loaded.
function S:AddCallbackForAddon(addonName, eventName, loadFunc, forceLoad, bypass)
	if not addonName or type(addonName) ~= "string" then
		E:Print("Invalid argument #1 to S:AddCallbackForAddon (string expected)")
		return
	elseif not eventName or type(eventName) ~= "string" then
		E:Print("Invalid argument #2 to S:AddCallbackForAddon (string expected)")
		return
	elseif not loadFunc or type(loadFunc) ~= "function" then
		E:Print("Invalid argument #3 to S:AddCallbackForAddon (function expected)")
		return
	end

	if bypass then
		self.allowBypass[addonName] = true
	end

	--Create an event registry for this addon, so that we can fire multiple events when this addon is loaded
	if not self.addonCallbacks[addonName] then
		self.addonCallbacks[addonName] = {["CallPriority"] = {}}
	end

	if self.addonCallbacks[addonName][eventName] or E.ModuleCallbacks[eventName] or E.InitialModuleCallbacks[eventName] then
		--Don't allow a registered callback to be overwritten
		E:Print("Invalid argument #2 to S:AddCallbackForAddon (event name:", eventName, "is already registered, please use a unique event name)")
		return
	end

	--Register loadFunc to be called when event is fired
	E.RegisterCallback(E, eventName, loadFunc)

	if forceLoad then
		E.callbacks:Fire(eventName)
	else
		--Insert eventName in this addons' registry
		self.addonCallbacks[addonName][eventName] = true
		self.addonCallbacks[addonName].CallPriority[#self.addonCallbacks[addonName].CallPriority + 1] = eventName
	end
end

--Add callback for skin that does not rely on a another addon.
--These events will be fired when the Skins module is initialized.
function S:AddCallback(eventName, loadFunc)
	if not eventName or type(eventName) ~= "string" then
		E:Print("Invalid argument #1 to S:AddCallback (string expected)")
		return
	elseif not loadFunc or type(loadFunc) ~= "function" then
		E:Print("Invalid argument #2 to S:AddCallback (function expected)")
		return
	end

	if self.nonAddonCallbacks[eventName] or E.ModuleCallbacks[eventName] or E.InitialModuleCallbacks[eventName] then
		--Don't allow a registered callback to be overwritten
		E:Print("Invalid argument #1 to S:AddCallback (event name:", eventName, "is already registered, please use a unique event name)")
		return
	end

	--Add event name to registry
	self.nonAddonCallbacks[eventName] = true
	self.nonAddonCallbacks.CallPriority[#self.nonAddonCallbacks.CallPriority + 1] = eventName

	--Register loadFunc to be called when event is fired
	E.RegisterCallback(E, eventName, loadFunc)
end

function S:SkinAce3()
	S:HookAce3(LibStub("AceGUI-3.0", true))
	S:Ace3_SkinTooltip(LibStub("AceConfigDialog-3.0", true))
	S:Ace3_SkinTooltip(E.Libs.AceConfigDialog, E.LibsMinor.AceConfigDialog)
end

function S:Initialize()
	self.Initialized = true

	self.db = E.private.skins

	self.uiPanelQueue = {}
	self.hitRectQueue = {}

	S:SkinAce3()

	--Fire event for all skins that doesn't rely on a Blizzard addon
	for index, event in ipairs(self.nonAddonCallbacks.CallPriority) do
		self.nonAddonCallbacks[event] = nil
		self.nonAddonCallbacks.CallPriority[index] = nil
		E.callbacks:Fire(event)
	end

	--Fire events for Blizzard addons that are already loaded
	for addon in pairs(self.addonCallbacks) do
		if IsAddOnLoaded(addon) then
			for index, event in ipairs(S.addonCallbacks[addon].CallPriority) do
				self.addonCallbacks[addon][event] = nil
				self.addonCallbacks[addon].CallPriority[index] = nil
				E.callbacks:Fire(event)
			end
		end
	end
end

S:RegisterEvent("ADDON_LOADED")

local function InitializeCallback()
	S:Initialize()
end

E:RegisterModule(S:GetName(), InitializeCallback)