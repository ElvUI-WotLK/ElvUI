local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local unpack = unpack
--WoW API / Variables

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.debug then return end

	ScriptErrorsFrame:SetParent(E.UIParent)
	ScriptErrorsFrame:StripTextures()
	ScriptErrorsFrame:SetTemplate("Transparent")
	S:HandleScrollBar(ScriptErrorsFrameScrollFrameScrollBar)
	S:HandleCloseButton(ScriptErrorsFrameClose)
	ScriptErrorsFrameScrollFrameText:FontTemplate(nil, 13)
	ScriptErrorsFrameScrollFrame:CreateBackdrop("Default")
	ScriptErrorsFrameScrollFrame.backdrop:Point("BOTTOMRIGHT", 0, -3)
	ScriptErrorsFrameScrollFrame:SetFrameLevel(ScriptErrorsFrameScrollFrame:GetFrameLevel() + 2)

	EventTraceFrame:StripTextures()
	EventTraceFrame:SetTemplate("Transparent")
	S:HandleSliderFrame(EventTraceFrameScroll)

	for i = 1, ScriptErrorsFrame:GetNumChildren() do
		local child = select(i, ScriptErrorsFrame:GetChildren())
		if child:GetObjectType() == "Button" and not child:GetName() then
			S:HandleButton(child)
		end
	end

	FrameStackTooltip:HookScript("OnShow", function(self)
		local noscalemult = E.mult * GetCVar("uiScale")

		self:SetBackdrop({
			bgFile = E.media.blankTex,
			edgeFile = E.media.blankTex,
			tile = false, tileSize = 0, edgeSize = noscalemult,
			insets = {left = -noscalemult, right = -noscalemult, top = -noscalemult, bottom = -noscalemult}
		})

		self:SetBackdropColor(unpack(E.media.backdropfadecolor))
		self:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end)

	EventTraceTooltip:HookScript("OnShow", function(self)
		self:SetTemplate("Transparent")
	end)

	S:HandleCloseButton(EventTraceFrameCloseButton)
end

S:AddCallbackForAddon("Blizzard_DebugTools", "Skin_Blizzard_DebugTools", LoadSkin)