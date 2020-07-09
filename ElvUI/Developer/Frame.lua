--Lua functions
local _G = _G
local loadstring = loadstring
local pcall = pcall
local print = print
local select = select
local tostring = tostring
local type = type
local find, format, match = string.find, string.format, string.match
local tconcat = table.concat
--WoW API / Variables
local FrameStackTooltip_Toggle = FrameStackTooltip_Toggle
local GetMouseFocus = GetMouseFocus
local tostringall = tostringall

local WorldFrame = WorldFrame

local DEFAULT_CHAT_FRAME = DEFAULT_CHAT_FRAME
local oldAddMessage

local function printNoTimestamp(...)
	if oldAddMessage or DEFAULT_CHAT_FRAME.OldAddMessage then
		if not oldAddMessage then
			oldAddMessage = DEFAULT_CHAT_FRAME.OldAddMessage
		end

		if select("#", ...) > 1 then
			oldAddMessage(DEFAULT_CHAT_FRAME, tconcat({tostringall(...)}, ", "))
		else
			oldAddMessage(DEFAULT_CHAT_FRAME, ...)
		end
	elseif CHAT_TIMESTAMP_FORMAT then
		local tsformat = CHAT_TIMESTAMP_FORMAT
		CHAT_TIMESTAMP_FORMAT = nil
		print(...)
		CHAT_TIMESTAMP_FORMAT = tsformat
	else
		print(...)
	end
end

local function updateCopyChat()
	if CopyChatFrame and CopyChatFrame:IsShown() then
		CopyChatFrame:Hide()
		ElvUI[1]:GetModule("Chat"):CopyChat(DEFAULT_CHAT_FRAME)
	end
end

local function getObject(objName)
	local obj

	if objName == "" then
		obj = GetMouseFocus()
	else
		obj = _G[objName]

		if not obj then
			local pass

			if find(objName, "^[%.:]([A-z0-9_]+)") then
				local _obj = GetMouseFocus()

				if _obj and _obj ~= WorldFrame then
					local res = match(objName, "^[%.:]([A-z0-9_]+)")

					if res and _obj[res] and _obj:GetName() then
						objName = format("%s%s", _obj:GetName(), objName)
					end

					pass = true
				end
			elseif find(objName, "[%.()%[%]'\"]") then
				pass = true
			end

			if pass then
				local success, ret = pcall(loadstring(format("return %s", objName)))
				if success then
					ret = ret == "string" and _G[ret] or ret

					if type(ret) == "table" and ret.GetName then
						obj = ret
					end
				end
			end
		end
	end

	if obj then
		return obj ~= WorldFrame and obj or nil
	else
		printNoTimestamp(format("Object |cffFFD100%s|r not found!", objName))
	end
end

local FrameStackHighlight = CreateFrame("Frame", "FrameStackHighlight")
FrameStackHighlight:SetFrameStrata("TOOLTIP")
FrameStackHighlight.t = FrameStackHighlight:CreateTexture(nil, "BORDER")
FrameStackHighlight.t:SetAllPoints()
FrameStackHighlight.t:SetTexture(0, 1, 0, 0.5)

local FrameStackHitRectHighlight = CreateFrame("Frame", "FrameStackHitRectHighlight")
FrameStackHitRectHighlight:SetFrameStrata("TOOLTIP")
FrameStackHitRectHighlight.t = FrameStackHitRectHighlight:CreateTexture(nil, "ARTWORK")
FrameStackHitRectHighlight.t:SetAllPoints()
FrameStackHitRectHighlight.t:SetTexture(0, 0, 1, 0.5)
FrameStackHitRectHighlight.t:SetBlendMode("ADD")

hooksecurefunc("FrameStackTooltip_Toggle", function()
	if not FrameStackTooltip:IsVisible() then
		FrameStackHighlight:Hide()
		FrameStackHitRectHighlight:Hide()
	end
end)

local _timeSinceLast = 0
FrameStackTooltip:HookScript("OnUpdate", function(_, elapsed)
	_timeSinceLast = _timeSinceLast - elapsed
	if _timeSinceLast <= 0 then
		_timeSinceLast = FRAMESTACK_UPDATE_TIME
		local highlightFrame = GetMouseFocus()

		if highlightFrame and highlightFrame ~= WorldFrame then
			FrameStackHighlight:ClearAllPoints()
			FrameStackHighlight:SetPoint("BOTTOMLEFT", highlightFrame)
			FrameStackHighlight:SetPoint("TOPRIGHT", highlightFrame)
			FrameStackHighlight:Show()

			local l, r, t, b = highlightFrame:GetHitRectInsets()
			if l ~= 0 or r ~= 0 or t ~= 0 or b ~= 0 then
				local scale = highlightFrame:GetEffectiveScale()
				FrameStackHitRectHighlight:ClearAllPoints()
				FrameStackHitRectHighlight:SetPoint("TOPLEFT", highlightFrame, l * scale, -t * scale)
				FrameStackHitRectHighlight:SetPoint("BOTTOMRIGHT", highlightFrame, -r * scale, b * scale)
				FrameStackHitRectHighlight:Show()
			else
				FrameStackHitRectHighlight:Hide()
			end
		else
			FrameStackHighlight:Hide()
			FrameStackHitRectHighlight:Hide()
		end
	end
end)

SLASH_FRAME1 = "/frame"
SlashCmdList.FRAME = function(frame)
	frame = getObject(frame)
	if not frame then return end

	local parent = frame:GetParent()
	local parentName = parent and parent.GetName and parent:GetName()

	printNoTimestamp("|cffCC0000----------------------------")

	printNoTimestamp(format("Name: |cffFFD100%s|r; ObjectType: |cffFFD100%s|r", frame:GetName() or "nil", frame:GetObjectType()))
	printNoTimestamp(format("Parent: |cffFFD100%s|r", parentName or (parent and tostring(parent)) or "nil"))

	if frame.GetFrameStrata then
		printNoTimestamp(format("Strata: |cffFFD100%s|r; FrameLevel: |cffFFD100%d|r", frame:GetFrameStrata(), frame:GetFrameLevel()))
	else
		printNoTimestamp(format("DrawLayer: |cffFFD100%s|r", frame:GetDrawLayer()))
	end

	if frame.GetScale then
		printNoTimestamp(format("Width: |cffFFD100%.0f|r; Height: |cffFFD100%.0f|r; Scale: |cffFFD100%s|r", frame:GetWidth(), frame:GetHeight(), frame:GetScale()))
	else
		printNoTimestamp(format("Width: |cffFFD100%.0f|r; Height: |cffFFD100%.0f|r", frame:GetWidth(), frame:GetHeight()))
	end

	local point, relativeTo, relativePoint, x, y, relativeName
	for i = 1, frame:GetNumPoints() do
		point, relativeTo, relativePoint, x, y = frame:GetPoint(i)
		relativeName = relativeTo and relativeTo.GetName and (relativeTo:GetName() or tostring(relativeTo)) or "nil"

		if point == relativePoint and relativeTo == parent then
			printNoTimestamp(format("Point %d: |cffFFD100\"%s\", %.0f, %.0f|r", i, point, x, y))
		else
			printNoTimestamp(format("Point %d: |cffFFD100\"%s\", %s, \"%s\", %.0f, %.0f|r", i, point, relativeName, relativePoint, x, y))
		end
	end

	printNoTimestamp("|cffCC0000----------------------------")

	updateCopyChat()
end

SLASH_FRAMELIST1 = "/framelist"
SlashCmdList.FRAMELIST = function(showHidden)
	if not FrameStackTooltip then
		UIParentLoadAddOn("Blizzard_DebugTools")
	end

	local isPreviouslyShown = FrameStackTooltip:IsShown()
	if not isPreviouslyShown then
		if showHidden == "true" then
			FrameStackTooltip_Toggle(true)
		else
			FrameStackTooltip_Toggle()
		end
	end

	printNoTimestamp("|cffCC0000----------------------------|r")
	for i = 2, FrameStackTooltip:NumLines() do
		local text = _G["FrameStackTooltipTextLeft"..i]:GetText()
		if text and text ~= "" then
			printNoTimestamp(text)
		end
	end
	printNoTimestamp("|cffCC0000----------------------------|r")

	updateCopyChat()

	if not isPreviouslyShown then
		FrameStackTooltip_Toggle()
	end
end

SLASH_TEXLIST1 = "/texlist"
SlashCmdList.TEXLIST = function(frame)
	frame = getObject(frame)
	if not (frame and frame.GetNumRegions) then return end

	for i = 1, frame:GetNumRegions() do
		local region = select(i, frame:GetRegions())
		if region.IsObjectType and region:IsObjectType("Texture") and region:GetTexture() then
			printNoTimestamp(region:GetTexture(), region:GetName(), region:GetDrawLayer())
		end
	end

	updateCopyChat()
end

SLASH_REGLIST1 = "/reglist"
SlashCmdList.REGLIST = function(frame)
	frame = getObject(frame)
	if not (frame and frame.GetNumRegions) then return end

	for i = 1, frame:GetNumRegions() do
		local region = select(i, frame:GetRegions())
		printNoTimestamp(i, region:GetObjectType(), region:GetName(), region:GetDrawLayer())
	end

	updateCopyChat()
end

SLASH_CHILDLIST1 = "/childlist"
SlashCmdList.CHILDLIST = function(frame)
	frame = getObject(frame)
	if not (frame and frame.GetNumChildren) then return end

	for i = 1, frame:GetNumChildren() do
		local obj = select(i, frame:GetChildren())
		printNoTimestamp(i, obj:GetObjectType(), obj:GetName(), obj:GetFrameStrata(), obj:GetFrameLevel())
	end

	updateCopyChat()
end

SLASH_GETPOINT1 = "/getpoint"
SlashCmdList.GETPOINT = function(frame)
	frame = getObject(frame)
	if not frame then return end

	local parent = frame:GetParent()
	local point, relativeTo, relativePoint, x, y, relativeName

	for i = 1, frame:GetNumPoints() do
		point, relativeTo, relativePoint, x, y = frame:GetPoint(i)
		relativeName = relativeTo and relativeTo.GetName and (relativeTo:GetName() or tostring(relativeTo)) or "nil"

		if point == relativePoint and relativeTo == parent then
			printNoTimestamp(format("\"%s\", %.0f, %.0f", point, x, y))
		else
			printNoTimestamp(format("\"%s\", %s, \"%s\", %.0f, %.0f", point, relativeName, relativePoint, x, y))
		end
	end

	updateCopyChat()
end