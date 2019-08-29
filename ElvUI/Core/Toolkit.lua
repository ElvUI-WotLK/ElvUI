local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local LSM = E.Libs.LSM

--Lua functions
local _G = _G
local unpack, type, select, getmetatable, assert = unpack, type, select, getmetatable, assert
--WoW API / Variables
local CreateFrame = CreateFrame

local backdropr, backdropg, backdropb, backdropa, borderr, borderg, borderb = 0, 0, 0, 1, 0, 0, 0
local function GetTemplate(template, isUnitFrameElement)
	backdropa = 1

	if template == "ClassColor" then
		local color = _G.CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass]
		borderr, borderg, borderb = color.r, color.g, color.b
		backdropr, backdropg, backdropb = unpack(E.media.backdropcolor)
	elseif template == "Transparent" then
		borderr, borderg, borderb = unpack(isUnitFrameElement and E.media.unitframeBorderColor or E.media.bordercolor)
		backdropr, backdropg, backdropb, backdropa = unpack(E.media.backdropfadecolor)
	else
		borderr, borderg, borderb = unpack(isUnitFrameElement and E.media.unitframeBorderColor or E.media.bordercolor)
		backdropr, backdropg, backdropb = unpack(E.media.backdropcolor)
	end
end

local function Size(frame, width, height)
	assert(width)
	frame:SetSize(E:Scale(width), E:Scale(height or width))
end

local function Width(frame, width)
	assert(width)
	frame:SetWidth(E:Scale(width))
end

local function Height(frame, height)
	assert(height)
	frame:SetHeight(E:Scale(height))
end

local function Point(obj, arg1, arg2, arg3, arg4, arg5)
	if arg2 == nil then arg2 = obj:GetParent() end

	if type(arg2) == "number" then arg2 = E:Scale(arg2) end
	if type(arg3) == "number" then arg3 = E:Scale(arg3) end
	if type(arg4) == "number" then arg4 = E:Scale(arg4) end
	if type(arg5) == "number" then arg5 = E:Scale(arg5) end

	obj:SetPoint(arg1, arg2, arg3, arg4, arg5)
end

local function SetOutside(obj, anchor, xOffset, yOffset, anchor2)
	xOffset = xOffset or E.Border
	yOffset = yOffset or E.Border
	anchor = anchor or obj:GetParent()

	assert(anchor)
	if obj:GetPoint() then
		obj:ClearAllPoints()
	end

	obj:Point("TOPLEFT", anchor, "TOPLEFT", -xOffset, yOffset)
	obj:Point("BOTTOMRIGHT", anchor2 or anchor, "BOTTOMRIGHT", xOffset, -yOffset)
end

local function SetInside(obj, anchor, xOffset, yOffset, anchor2)
	xOffset = xOffset or E.Border
	yOffset = yOffset or E.Border
	anchor = anchor or obj:GetParent()

	assert(anchor)
	if obj:GetPoint() then
		obj:ClearAllPoints()
	end

	obj:Point("TOPLEFT", anchor, "TOPLEFT", xOffset, -yOffset)
	obj:Point("BOTTOMRIGHT", anchor2 or anchor, "BOTTOMRIGHT", -xOffset, yOffset)
end

local function SetTemplate(frame, template, glossTex, ignoreUpdates, forcePixelMode, isUnitFrameElement)
	GetTemplate(template, isUnitFrameElement)

	frame.template = template or "Default"
	if glossTex then frame.glossTex = glossTex end
	if ignoreUpdates then frame.ignoreUpdates = ignoreUpdates end
	if forcePixelMode then frame.forcePixelMode = forcePixelMode end
	if isUnitFrameElement then frame.isUnitFrameElement = isUnitFrameElement end

	local bgFile = glossTex and E.media.glossTex or E.media.blankTex

	if template ~= "NoBackdrop" then
		frame:SetBackdrop({
			bgFile = bgFile,
			edgeFile = E.media.blankTex,
			tile = false, tileSize = 0, edgeSize = E.mult,
			insets = {left = 0, right = 0, top = 0, bottom = 0}
		})

		frame:SetBackdropColor(backdropr, backdropg, backdropb, backdropa)

		if not E.PixelMode and not frame.forcePixelMode then
			if not frame.iborder then
				local border = CreateFrame("Frame", nil, frame)
				border:SetInside(frame, E.mult, E.mult)
				border:SetBackdrop({
					edgeFile = E.media.blankTex,
					edgeSize = E.mult,
					insets = {left = -E.mult, right = -E.mult, top = -E.mult, bottom = -E.mult}
				})
				border:SetBackdropBorderColor(0, 0, 0, 1)
				frame.iborder = border
			end

			if not frame.oborder then
				local border = CreateFrame("Frame", nil, frame)
				border:SetOutside(frame, E.mult, E.mult)
				border:SetFrameLevel(frame:GetFrameLevel() + 1)
				border:SetBackdrop({
					edgeFile = E.media.blankTex,
					edgeSize = E.mult,
					insets = {left = E.mult, right = E.mult, top = E.mult, bottom = E.mult}
				})
				border:SetBackdropBorderColor(0, 0, 0, 1)
				frame.oborder = border
			end
		end
	else
		frame:SetBackdrop(nil)
	end
	frame:SetBackdropBorderColor(borderr, borderg, borderb)

	if not frame.ignoreUpdates then
		if frame.isUnitFrameElement then
			E.unitFrameElements[frame] = true
		else
			E.frames[frame] = true
		end
	end
end

local function CreateBackdrop(frame, template, glossTex, ignoreUpdates, forcePixelMode, isUnitFrameElement)
	if not template then template = "Default" end

	local parent = (frame.IsObjectType and frame:IsObjectType("Texture") and frame:GetParent()) or frame
	local backdrop = frame.backdrop or CreateFrame("Frame", nil, parent)
	if not frame.backdrop then frame.backdrop = backdrop end

	if frame.forcePixelMode or forcePixelMode then
		backdrop:SetOutside(frame, E.mult, E.mult)
	else
		backdrop:SetOutside(frame)
	end

	backdrop:SetTemplate(template, glossTex, ignoreUpdates, forcePixelMode, isUnitFrameElement)

	local frameLevel = parent.GetFrameLevel and parent:GetFrameLevel()
	local frameLevelMinusOne = frameLevel and (frameLevel - 1)
	if frameLevelMinusOne and (frameLevelMinusOne >= 0) then
		backdrop:SetFrameLevel(frameLevelMinusOne)
	else
		backdrop:SetFrameLevel(0)
	end
end

local function CreateShadow(frame, size)
	if frame.shadow then return end

	backdropr, backdropg, backdropb, borderr, borderg, borderb = 0, 0, 0, 0, 0, 0

	local shadow = CreateFrame("Frame", nil, frame)
	shadow:SetFrameLevel(1)
	shadow:SetFrameStrata(frame:GetFrameStrata())
	shadow:SetOutside(frame, size or 3, size or 3)
	shadow:SetBackdrop({edgeFile = LSM:Fetch("border", "ElvUI GlowBorder"), edgeSize = E:Scale(size or 3)})
	shadow:SetBackdropColor(backdropr, backdropg, backdropb, 0)
	shadow:SetBackdropBorderColor(borderr, borderg, borderb, 0.9)
	frame.shadow = shadow
end

local function Kill(object)
	if object.UnregisterAllEvents then
		object:UnregisterAllEvents()
		object:SetParent(E.HiddenFrame)
	else
		object.Show = object.Hide
	end

	object:Hide()
end

local function StripTextures(object, kill, alpha)
	if object:IsObjectType("Texture") then
		if kill then
			object:Kill()
		elseif alpha then
			object:SetAlpha(0)
		else
			object:SetTexture()
		end
	else
		if object.GetNumRegions then
			for i = 1, object:GetNumRegions() do
				local region = select(i, object:GetRegions())
				if region and region.IsObjectType and region:IsObjectType("Texture") then
					if kill then
						region:Kill()
					elseif alpha then
						region:SetAlpha(0)
					else
						region:SetTexture()
					end
				end
			end
		end
	end
end

local function FontTemplate(fs, font, fontSize, fontStyle)
	fs.font = font
	fs.fontSize = fontSize
	fs.fontStyle = fontStyle

	font = font or LSM:Fetch("font", E.db.general.font)
	fontSize = fontSize or E.db.general.fontSize
	fontStyle = fontStyle or E.db.general.fontStyle

	if fontStyle == "OUTLINE" and E.db.general.font == "Homespun" and (fontSize > 10 and not fs.fontSize) then
		fontSize, fontStyle = 10, "MONOCHROMEOUTLINE"
	end

	fs:SetFont(font, fontSize, fontStyle)

	if fontStyle == "NONE" then
		local s = E.mult or 1
		fs:SetShadowOffset(s, -s/2)
		fs:SetShadowColor(0, 0, 0, 1)
	else
		fs:SetShadowOffset(0, 0)
		fs:SetShadowColor(0, 0, 0, 0)
	end

	E.texts[fs] = true
end

local function StyleButton(button, noHover, noPushed, noChecked)
	if button.SetHighlightTexture and not button.hover and not noHover then
		local hover = button:CreateTexture()
		hover:SetInside()
		hover:SetTexture(1, 1, 1, 0.3)
		button:SetHighlightTexture(hover)
		button.hover = hover
	end

	if button.SetPushedTexture and not button.pushed and not noPushed then
		local pushed = button:CreateTexture()
		pushed:SetInside()
		pushed:SetTexture(0.9, 0.8, 0.1, 0.3)
		button:SetPushedTexture(pushed)
		button.pushed = pushed
	end

	if button.SetCheckedTexture and not button.checked and not noChecked then
		local checked = button:CreateTexture()
		checked:SetInside()
		checked:SetTexture(1, 1, 1, 0.3)
		button:SetCheckedTexture(checked)
		button.checked = checked
	end

	local name = button.GetName and button:GetName()
	local cooldown = name and _G[name.."Cooldown"]
	if cooldown then
		cooldown:ClearAllPoints()
		cooldown:SetInside()
	end
end

local CreateCloseButton
do
	local CloseButtonOnClick = function(btn) btn:GetParent():Hide() end
	local CloseButtonOnEnter = function(btn) if btn.Texture then btn.Texture:SetVertexColor(unpack(E.media.rgbvaluecolor)) end end
	local CloseButtonOnLeave = function(btn) if btn.Texture then btn.Texture:SetVertexColor(1, 1, 1) end end
	CreateCloseButton = function(frame, size, offset, texture, backdrop)
		if frame.CloseButton then return end

		local CloseButton = CreateFrame("Button", nil, frame)
		CloseButton:Size(size or 16)
		CloseButton:Point("TOPRIGHT", offset or -6, offset or -6)
		if backdrop then CloseButton:CreateBackdrop(nil, true) end

		CloseButton.Texture = CloseButton:CreateTexture(nil, "OVERLAY")
		CloseButton.Texture:SetAllPoints()
		CloseButton.Texture:SetTexture(texture or E.Media.Textures.Close)

		CloseButton:SetScript("OnClick", CloseButtonOnClick)
		CloseButton:SetScript("OnEnter", CloseButtonOnEnter)
		CloseButton:SetScript("OnLeave", CloseButtonOnLeave)

		frame.CloseButton = CloseButton
	end
end

local function GetNamedChild(frame, childName, index)
	local name = frame and frame.GetName and frame:GetName()
	if not name or not childName then return nil end
	return _G[name..childName..(index or "")]
end

local function addapi(object)
	local mt = getmetatable(object).__index
	if not object.Size then mt.Size = Size end
	if not object.Point then mt.Point = Point end
	if not object.SetOutside then mt.SetOutside = SetOutside end
	if not object.SetInside then mt.SetInside = SetInside end
	if not object.SetTemplate then mt.SetTemplate = SetTemplate end
	if not object.CreateBackdrop then mt.CreateBackdrop = CreateBackdrop end
	if not object.CreateShadow then mt.CreateShadow = CreateShadow end
	if not object.Kill then mt.Kill = Kill end
	if not object.Width then mt.Width = Width end
	if not object.Height then mt.Height = Height end
	if not object.FontTemplate then mt.FontTemplate = FontTemplate end
	if not object.StripTextures then mt.StripTextures = StripTextures end
	if not object.StyleButton then mt.StyleButton = StyleButton end
	if not object.CreateCloseButton then mt.CreateCloseButton = CreateCloseButton end
	if not object.GetNamedChild then mt.GetNamedChild = GetNamedChild end
end

local handled = {["Frame"] = true}
local object = CreateFrame("Frame")
addapi(object)
addapi(object:CreateTexture())
addapi(object:CreateFontString())

object = EnumerateFrames()
while object do
	if not handled[object:GetObjectType()] then
		addapi(object)
		handled[object:GetObjectType()] = true
	end

	object = EnumerateFrames(object)
end

--Add API to `CreateFont` objects without actually creating one
addapi(GameFontNormal)