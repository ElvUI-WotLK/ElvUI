local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.debug ~= true then return end

	ScriptErrorsFrame:SetParent(E.UIParent)
	ScriptErrorsFrame:SetTemplate("Transparent")
	S:HandleScrollBar(ScriptErrorsFrameScrollFrameScrollBar)
	S:HandleCloseButton(ScriptErrorsFrameClose)
	ScriptErrorsFrameScrollFrameText:FontTemplate(nil, 13)
	ScriptErrorsFrameScrollFrame:CreateBackdrop("Default")
	ScriptErrorsFrameScrollFrame:SetFrameLevel(ScriptErrorsFrameScrollFrame:GetFrameLevel() + 2)
	EventTraceFrame:SetTemplate("Transparent")
	local texs = {
		"TopLeft",
		"TopRight",
		"Top",
		"BottomLeft",
		"BottomRight",
		"Bottom",
		"Left",
		"Right",
		"TitleBG",
		"DialogBG",
	}

	for i=1, #texs do
		_G["ScriptErrorsFrame"..texs[i]]:SetTexture(nil)
		_G["EventTraceFrame"..texs[i]]:SetTexture(nil)
	end

	for i=1, ScriptErrorsFrame:GetNumChildren() do
		local child = select(i, ScriptErrorsFrame:GetChildren())
		if child:GetObjectType() == "Button" and not child:GetName() then
			S:HandleButton(child)
		end
	end

	FrameStackTooltip:HookScript("OnShow", function(self)
		local noscalemult = E.mult * GetCVar("uiScale")
		self:SetBackdrop({
			bgFile = E["media"].blankTex,
			edgeFile = E["media"].blankTex,
			tile = false, tileSize = 0, edgeSize = noscalemult,
			insets = { left = -noscalemult, right = -noscalemult, top = -noscalemult, bottom = -noscalemult}
		});
		self:SetBackdropColor(unpack(E["media"].backdropfadecolor))
		self:SetBackdropBorderColor(unpack(E["media"].bordercolor))
	end)

	EventTraceTooltip:HookScript("OnShow", function(self)
		self:SetTemplate("Transparent")
	end)

	S:HandleCloseButton(EventTraceFrameCloseButton)
end

S:AddCallbackForAddon("Blizzard_DebugTools", "DebugTools", LoadSkin);