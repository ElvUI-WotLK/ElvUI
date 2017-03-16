local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local LSM = LibStub("LibSharedMedia-3.0")

local _G = _G;
local unpack, type, select, getmetatable = unpack, type, select, getmetatable;

local CreateFrame = CreateFrame;
local RAID_CLASS_COLORS = RAID_CLASS_COLORS;
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS;

--Preload shit..
E.mult = 1;
local backdropr, backdropg, backdropb, backdropa, borderr, borderg, borderb = 0, 0, 0, 1, 0, 0, 0;

local function GetTemplate(t, isPixelPerfectForced)
	backdropa = 1
	if t == "ClassColor" then
		if(CUSTOM_CLASS_COLORS) then
			borderr, borderg, borderb = CUSTOM_CLASS_COLORS[E.myclass].r, CUSTOM_CLASS_COLORS[E.myclass].g, CUSTOM_CLASS_COLORS[E.myclass].b;
		else
			borderr, borderg, borderb = RAID_CLASS_COLORS[E.myclass].r, RAID_CLASS_COLORS[E.myclass].g, RAID_CLASS_COLORS[E.myclass].b;
		end

		if t ~= "Transparent" then
			backdropr, backdropg, backdropb = unpack(E["media"].backdropcolor)
		else
			backdropr, backdropg, backdropb, backdropa = unpack(E["media"].backdropfadecolor)
		end
	elseif t == "Transparent" then
		borderr, borderg, borderb = unpack(E["media"].bordercolor)
		backdropr, backdropg, backdropb, backdropa = unpack(E["media"].backdropfadecolor)
	else
		borderr, borderg, borderb = unpack(E["media"].bordercolor)
		backdropr, backdropg, backdropb = unpack(E["media"].backdropcolor)
	end

	if(isPixelPerfectForced) then
		borderr, borderg, borderb = 0, 0, 0;
	end
end

local function Size(frame, width, height)
	assert(width);
	frame:SetSize(E:Scale(width), E:Scale(height or width));
end

local function Width(frame, width)
	frame:SetWidth(E:Scale(width))
end

local function Height(frame, height)
	assert(height)
	frame:SetHeight(E:Scale(height));
end

local function Point(obj, arg1, arg2, arg3, arg4, arg5)
	if(arg2 == nil) then
		arg2 = obj:GetParent();
	end

	if type(arg1)=="number" then arg1 = E:Scale(arg1) end
	if type(arg2)=="number" then arg2 = E:Scale(arg2) end
	if type(arg3)=="number" then arg3 = E:Scale(arg3) end
	if type(arg4)=="number" then arg4 = E:Scale(arg4) end
	if type(arg5)=="number" then arg5 = E:Scale(arg5) end

	obj:SetPoint(arg1, arg2, arg3, arg4, arg5)
end

local function SetOutside(obj, anchor, xOffset, yOffset, anchor2)
	xOffset = xOffset or E.Border
	yOffset = yOffset or E.Border
	anchor = anchor or obj:GetParent()

	assert(anchor);
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

	assert(anchor);
	if obj:GetPoint() then
		obj:ClearAllPoints()
	end

	obj:Point("TOPLEFT", anchor, "TOPLEFT", xOffset, -yOffset)
	obj:Point("BOTTOMRIGHT", anchor2 or anchor, "BOTTOMRIGHT", -xOffset, yOffset)
end

local function SetTemplate(f, t, glossTex, ignoreUpdates, forcePixelMode)
	GetTemplate(t, f.forcePixelMode or forcePixelMode)

	if(t) then
		f.template = t;
	end

	if(glossTex) then
		f.glossTex = glossTex;
	end

	if(ignoreUpdates) then
		f.ignoreUpdates = ignoreUpdates;
	end

	if(forcePixelMode) then
		f.forcePixelMode = forcePixelMode
	end

	local bgFile = E.media.blankTex;
	if(glossTex) then
		bgFile = E.media.glossTex;
	end

	if(t ~= "NoBackdrop") then
		if(E.private.general.pixelPerfect or f.forcePixelMode) then
			f:SetBackdrop({
				bgFile = bgFile,
				edgeFile = E["media"].blankTex,
				tile = false, tileSize = 0, edgeSize = E.mult,
				insets = {left = 0, right = 0, top = 0, bottom = 0}
			});
		else
			f:SetBackdrop({
				bgFile = bgFile,
				edgeFile = E["media"].blankTex,
				tile = false, tileSize = 0, edgeSize = E.mult,
				insets = {left = -E.mult, right = -E.mult, top = -E.mult, bottom = -E.mult}
			});
		end

		if not f.oborder and not f.iborder and not E.private.general.pixelPerfect and not f.forcePixelMode then
			local border = CreateFrame("Frame", nil, f)
			border:SetInside(f, E.mult, E.mult)
			border:SetBackdrop({
				edgeFile = E["media"].blankTex,
				edgeSize = E.mult,
				insets = {left = E.mult, right = E.mult, top = E.mult, bottom = E.mult}
			});
			border:SetBackdropBorderColor(0, 0, 0, 1)
			f.iborder = border

			if f.oborder then return end
			local border = CreateFrame("Frame", nil, f)
			border:SetOutside(f, E.mult, E.mult)
			border:SetFrameLevel(f:GetFrameLevel() + 1)
			border:SetBackdrop({
				edgeFile = E["media"].blankTex,
				edgeSize = E.mult,
				insets = {left = E.mult, right = E.mult, top = E.mult, bottom = E.mult}
			});
			border:SetBackdropBorderColor(0, 0, 0, 1)
			f.oborder = border
		end
	else
		f:SetBackdrop(nil);
	end

	f:SetBackdropColor(backdropr, backdropg, backdropb, backdropa)
	f:SetBackdropBorderColor(borderr, borderg, borderb)

	if(not f.ignoreUpdates and not f.forcePixelMode) then
		E["frames"][f] = true;
	end
end

local function CreateBackdrop(f, t, tex, ignoreUpdates, forcePixelMode)
	if(not t) then t = "Default"; end

	local b = CreateFrame("Frame", nil, f);
	if(f.forcePixelMode or forcePixelMode) then
		b:SetOutside(nil, E.mult, E.mult);
	else
		b:SetOutside();
	end
	b:SetTemplate(t, tex, ignoreUpdates, forcePixelMode);

	if(f:GetFrameLevel() - 1 >= 0) then
		b:SetFrameLevel(f:GetFrameLevel() - 1);
	else
		b:SetFrameLevel(0);
	end

	f.backdrop = b;
end

local function CreateShadow(f)
	if f.shadow then return end

	borderr, borderg, borderb = 0, 0, 0
	backdropr, backdropg, backdropb = 0, 0, 0

	local shadow = CreateFrame("Frame", nil, f)
	shadow:SetFrameLevel(1)
	shadow:SetFrameStrata(f:GetFrameStrata())
	shadow:SetOutside(f, 3, 3)
	shadow:SetBackdrop({
		edgeFile = LSM:Fetch("border", "ElvUI GlowBorder"), edgeSize = E:Scale(3),
		insets = {left = E:Scale(5), right = E:Scale(5), top = E:Scale(5), bottom = E:Scale(5)}
	});
	shadow:SetBackdropColor(backdropr, backdropg, backdropb, 0)
	shadow:SetBackdropBorderColor(borderr, borderg, borderb, 0.9)
	f.shadow = shadow
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

local function StripTextures(object, kill)
	for i=1, object:GetNumRegions() do
		local region = select(i, object:GetRegions())
		if region and region:GetObjectType() == "Texture" then
			if kill and type(kill) == "boolean" then
				region:Kill()
			elseif region:GetDrawLayer() == kill then
				region:SetTexture(nil)
			elseif kill and type(kill) == "string" and region:GetTexture() ~= kill then
				region:SetTexture(nil)
			else
				region:SetTexture(nil)
			end
		end
	end
end

local function FontTemplate(fs, font, fontSize, fontStyle)
	fs.font = font
	fs.fontSize = fontSize
	fs.fontStyle = fontStyle

	font = font or LSM:Fetch("font", E.db["general"].font)
	fontSize = fontSize or E.db.general.fontSize

	if fontStyle == "OUTLINE" and (E.db.general.font == "Homespun") then
		if (fontSize > 10 and not fs.fontSize) then
			fontStyle = "MONOCHROMEOUTLINE"
			fontSize = 10
		end
	end

	fs:SetFont(font, fontSize, fontStyle)
	if fontStyle and (fontStyle ~= "NONE") then
		fs:SetShadowColor(0, 0, 0, 0.2)
	else
		fs:SetShadowColor(0, 0, 0, 1)
	end
	fs:SetShadowOffset((E.mult or 1), -(E.mult or 1))

	E["texts"][fs] = true
end

local function StyleButton(button, noHover, noPushed, noChecked)
	if button.SetHighlightTexture and not button.hover and not noHover then
		local hover = button:CreateTexture();
		hover:SetTexture(1, 1, 1, 0.3)
		hover:SetInside()
		button.hover = hover
		button:SetHighlightTexture(hover)
	end

	if button.SetPushedTexture and not button.pushed and not noPushed then
		local pushed = button:CreateTexture();
		pushed:SetTexture(0.9, 0.8, 0.1, 0.3)
		pushed:SetInside()
		button.pushed = pushed
		button:SetPushedTexture(pushed)
	end

	if button.SetCheckedTexture and not button.checked and not noChecked then
		local checked = button:CreateTexture();
		checked:SetTexture(1, 1, 1)
		checked:SetInside()
		checked:SetAlpha(0.3)
		button.checked = checked
		button:SetCheckedTexture(checked)
	end

	local cooldown = button:GetName() and _G[button:GetName().."Cooldown"]
	if cooldown then
		cooldown:ClearAllPoints()
		cooldown:SetInside()
	end
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