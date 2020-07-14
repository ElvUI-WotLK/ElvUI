local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local unpack = unpack
--WoW API / Variables

S:AddCallbackForAddon("Blizzard_DebugTools", "Skin_Blizzard_DebugTools", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.debug then return end

	ScriptErrorsFrame:SetParent(E.UIParent)
	ScriptErrorsFrame:StripTextures()
	ScriptErrorsFrame:SetTemplate("Transparent")

	S:HandleScrollBar(ScriptErrorsFrameScrollFrameScrollBar)
	S:HandleCloseButton(ScriptErrorsFrameClose, ScriptErrorsFrame)

	ScriptErrorsFrameScrollFrameText:FontTemplate(nil, 13)
	ScriptErrorsFrameScrollFrameText:Width(461)

	ScriptErrorsFrameScrollFrame:CreateBackdrop("Default")
	ScriptErrorsFrameScrollFrame.backdrop:Point("BOTTOMRIGHT", 1, -2)
	ScriptErrorsFrameScrollFrame:SetFrameLevel(ScriptErrorsFrameScrollFrame:GetFrameLevel() + 2)
	ScriptErrorsFrameScrollFrame:Width(461)
	ScriptErrorsFrameScrollFrame:Point("TOPLEFT", 9, -30)

	ScriptErrorsFrameScrollFrameScrollBar:Point("TOPLEFT", ScriptErrorsFrameScrollFrame, "TOPRIGHT", 4, -18)
	ScriptErrorsFrameScrollFrameScrollBar:Point("BOTTOMLEFT", ScriptErrorsFrameScrollFrame, "BOTTOMRIGHT", 4, 17)

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

	S:HandleCloseButton(EventTraceFrameCloseButton, EventTraceFrame)
end)