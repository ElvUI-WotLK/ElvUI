local _G = _G;
local print, tostring, select = print, tostring, select;
local format = format;

local GetMouseFocus = GetMouseFocus;
local FrameStackTooltip_Toggle = FrameStackTooltip_Toggle;

--[[
	Command to grab frame information when mouseing over a frame

	Frame Name
	Width
	Height
	Strata
	Level
	X Offset
	Y Offset
	Point
]]

SLASH_FRAME1 = "/frame"
SlashCmdList["FRAME"] = function(arg)
	if arg ~= "" then
		arg = _G[arg]
	else
		arg = GetMouseFocus()
	end
	if arg ~= nil then FRAME = arg end --Set the global variable FRAME to = whatever we are mousing over to simplify messing with frames that have no name.
	if arg ~= nil and arg:GetName() ~= nil then
		local point, relativeTo, relativePoint, xOfs, yOfs = arg:GetPoint()
		ChatFrame1:AddMessage("|cffCC0000----------------------------")
		ChatFrame1:AddMessage("Name: |cffFFD100"..arg:GetName())
		if arg:GetParent() and arg:GetParent():GetName() then
			ChatFrame1:AddMessage("Parent: |cffFFD100"..arg:GetParent():GetName())
		end

		ChatFrame1:AddMessage("Width: |cffFFD100"..format("%.2f",arg:GetWidth()))
		ChatFrame1:AddMessage("Height: |cffFFD100"..format("%.2f",arg:GetHeight()))
		ChatFrame1:AddMessage("Strata: |cffFFD100"..arg:GetFrameStrata())
		ChatFrame1:AddMessage("Level: |cffFFD100"..arg:GetFrameLevel())

		if xOfs then
			ChatFrame1:AddMessage("X: |cffFFD100"..format("%.2f",xOfs))
		end
		if yOfs then
			ChatFrame1:AddMessage("Y: |cffFFD100"..format("%.2f",yOfs))
		end
		if relativeTo and relativeTo:GetName() then
			ChatFrame1:AddMessage("Point: |cffFFD100"..point.."|r anchored to "..relativeTo:GetName().."'s |cffFFD100"..relativePoint)
		end
		ChatFrame1:AddMessage("|cffCC0000----------------------------|r")
	elseif arg == nil then
		ChatFrame1:AddMessage("Invalid frame name")
	else
		ChatFrame1:AddMessage("Could not find frame info")
	end
end

CreateFrame("Frame", "FrameStackHighlight");
FrameStackHighlight:SetFrameStrata("TOOLTIP");
local t = FrameStackHighlight:CreateTexture(nil, "BORDER");
t:SetAllPoints();
t:SetTexture(0, 1, 0, 0.5);

hooksecurefunc("FrameStackTooltip_Toggle", function()
	local tooltip = _G["FrameStackTooltip"];
	if(not tooltip:IsVisible()) then
		FrameStackHighlight:Hide();
	end
end);

local _timeSinceLast = 0
FrameStackTooltip:HookScript("OnUpdate", function(_, elapsed)
	_timeSinceLast = _timeSinceLast - elapsed;
	if(_timeSinceLast <= 0) then
		_timeSinceLast = FRAMESTACK_UPDATE_TIME;
		local highlightFrame = GetMouseFocus();

		FrameStackHighlight:ClearAllPoints();
		if(highlightFrame and highlightFrame ~= _G["WorldFrame"]) then
			FrameStackHighlight:SetPoint("BOTTOMLEFT", highlightFrame);
			FrameStackHighlight:SetPoint("TOPRIGHT", highlightFrame);
			FrameStackHighlight:Show();
		else
			FrameStackHighlight:Hide();
		end
	end
end);

SLASH_FRAMELIST1 = "/framelist"
SlashCmdList["FRAMELIST"] = function(msg)
	if(not FrameStackTooltip) then
		UIParentLoadAddOn("Blizzard_DebugTools");
	end

	local isPreviouslyShown = FrameStackTooltip:IsShown()
	if(not isPreviouslyShown) then
		if(msg == tostring(true)) then
			FrameStackTooltip_Toggle(true);
		else
			FrameStackTooltip_Toggle();
		end
	end

	print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	for i = 2, FrameStackTooltip:NumLines() do
		local text = _G["FrameStackTooltipTextLeft"..i]:GetText();
		if(text and text ~= "") then
			print(text)
		end
	end
	print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

	if(CopyChatFrame:IsShown()) then
		CopyChatFrame:Hide()
	end

	ElvUI[1]:GetModule("Chat"):CopyChat(ChatFrame1)
	if(not isPreviouslyShown) then
		FrameStackTooltip_Toggle();
	end
end

local function TextureList(frame)
	frame = _G[frame] or FRAME
	--[[for key, obj in pairs(frame) do
		if type(obj) == "table" and obj.GetObjectType and obj:GetObjectType() == "Texture" then
			print(key, obj:GetTexture())
		end
	end]]

	for i=1, frame:GetNumRegions() do
		local region = select(i, frame:GetRegions())
		if(region:GetObjectType() == "Texture") then
			print(region:GetTexture(), region:GetName())
		end
	end
end

SLASH_TEXLIST1 = "/texlist"
SlashCmdList["TEXLIST"] = TextureList

local function GetPoint(frame)
	if frame ~= "" then
		frame = _G[frame]
	else
		frame = GetMouseFocus()
	end

	local point, relativeTo, relativePoint, xOffset, yOffset = frame:GetPoint()
	local frameName = frame.GetName and frame:GetName() or "nil"
	local relativeToName = relativeTo.GetName and relativeTo:GetName() or "nil"

	print(frameName, point, relativeToName, relativePoint, xOffset, yOffset)
end

SLASH_GETPOINT1 = "/getpoint"
SlashCmdList["GETPOINT"] = GetPoint