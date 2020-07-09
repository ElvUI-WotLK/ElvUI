local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local LO = E:GetModule("Layout")
local DT = E:GetModule("DataTexts")

--Lua functions
--WoW API / Variables
local CreateFrame = CreateFrame
local UIFrameFadeIn, UIFrameFadeOut = UIFrameFadeIn, UIFrameFadeOut

local PANEL_HEIGHT = 22
local SIDE_BUTTON_WIDTH = 16

local function Panel_OnShow(self)
	self:SetFrameLevel(0)
	self:SetFrameStrata("BACKGROUND")
end

function LO:Initialize()
	self.Initialized = true
	self:CreateChatPanels()
	self:CreateMinimapPanels()
	self:SetDataPanelStyle()

	self.BottomPanel = CreateFrame("Frame", "ElvUI_BottomPanel", E.UIParent)
	self.BottomPanel:SetTemplate("Transparent")
	self.BottomPanel:Point("BOTTOMLEFT", E.UIParent, "BOTTOMLEFT", -1, -1)
	self.BottomPanel:Point("BOTTOMRIGHT", E.UIParent, "BOTTOMRIGHT", 1, -1)
	self.BottomPanel:Height(PANEL_HEIGHT)
	self.BottomPanel:SetScript("OnShow", Panel_OnShow)
	Panel_OnShow(self.BottomPanel)
	self:BottomPanelVisibility()

	self.TopPanel = CreateFrame("Frame", "ElvUI_TopPanel", E.UIParent)
	self.TopPanel:SetTemplate("Transparent")
	self.TopPanel:Point("TOPLEFT", E.UIParent, "TOPLEFT", -1, 1)
	self.TopPanel:Point("TOPRIGHT", E.UIParent, "TOPRIGHT", 1, 1)
	self.TopPanel:Height(PANEL_HEIGHT)
	self.TopPanel:SetScript("OnShow", Panel_OnShow)
	Panel_OnShow(self.TopPanel)
	self:TopPanelVisibility()
end

function LO:BottomPanelVisibility()
	if E.db.general.bottomPanel then
		self.BottomPanel:Show()
	else
		self.BottomPanel:Hide()
	end
end

function LO:TopPanelVisibility()
	if E.db.general.topPanel then
		self.TopPanel:Show()
	else
		self.TopPanel:Hide()
	end
end

local function ChatPanelLeft_OnFade()
	LeftChatPanel:Hide()
end

local function ChatPanelRight_OnFade()
	RightChatPanel:Hide()
end

local function ChatButton_OnEnter(self)
	if E.db[self.parent:GetName().."Faded"] then
		self.parent:Show()
		UIFrameFadeIn(self.parent, 0.2, self.parent:GetAlpha(), 1)
		if E.db.chat.fadeChatToggles then
			UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1)
		end
	end

	if self == LeftChatToggleButton then
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, (E.PixelMode and 1 or 3))
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(L["Left Click:"], L["Toggle Chat Frame"], 1, 1, 1)
	else
		GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT", 0, (E.PixelMode and 1 or 3))
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(L["Left Click:"], L["Toggle Chat Frame"], 1, 1, 1)
	end

	GameTooltip:Show()
end

local function ChatButton_OnLeave(self)
	if E.db[self.parent:GetName().."Faded"] then
		UIFrameFadeOut(self.parent, 0.2, self.parent:GetAlpha(), 0)
		self.parent.fadeInfo.finishedFunc = self.parent.fadeFunc

		if E.db.chat.fadeChatToggles then
			UIFrameFadeOut(self, 0.2, self:GetAlpha(), 0)
		end
	end
	GameTooltip:Hide()
end

local function ChatButton_OnClick(self)
	GameTooltip:Hide()

	local name = self.parent:GetName().."Faded"
	if E.db[name] then
		E.db[name] = nil
		UIFrameFadeIn(self.parent, 0.2, self.parent:GetAlpha(), 1)
		if E.db.chat.fadeChatToggles then
			UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1)
		end
	else
		E.db[name] = true
		UIFrameFadeOut(self.parent, 0.2, self.parent:GetAlpha(), 0)
		self.parent.fadeInfo.finishedFunc = self.parent.fadeFunc
		if E.db.chat.fadeChatToggles then
			UIFrameFadeOut(self, 0.2, self:GetAlpha(), 0)
		end
	end
end

function HideLeftChat()
	ChatButton_OnClick(LeftChatToggleButton)
end

function HideRightChat()
	ChatButton_OnClick(RightChatToggleButton)
end

function HideBothChat()
	ChatButton_OnClick(LeftChatToggleButton)
	ChatButton_OnClick(RightChatToggleButton)
end

function LO:ToggleChatTabPanels(rightOverride, leftOverride)
	if leftOverride or not E.db.chat.panelTabBackdrop then
		LeftChatTab:Hide()
	else
		LeftChatTab:Show()
	end

	if rightOverride or not E.db.chat.panelTabBackdrop then
		RightChatTab:Hide()
	else
		RightChatTab:Show()
	end
end

function LO:SetChatTabStyle()
	local tabStyle = E.db.chat.panelTabTransparency and "Transparent" or nil
	local glossTex = not tabStyle and true or nil

	LeftChatTab:SetTemplate(tabStyle, glossTex)
	RightChatTab:SetTemplate(tabStyle, glossTex)
end

function LO:SetDataPanelStyle()
	local miniStyle = E.db.datatexts.panelTransparency and "Transparent" or "Default"
	local panelStyle = (not E.db.datatexts.panelBackdrop) and "NoBackdrop" or miniStyle

	local panelGlossTex = (panelStyle and true) or nil
	local miniGlossTex = (miniStyle and nil) or true

	LeftChatDataPanel:SetTemplate(panelStyle, panelGlossTex)
	LeftChatToggleButton:SetTemplate(panelStyle, panelGlossTex)
	RightChatDataPanel:SetTemplate(panelStyle, panelGlossTex)
	RightChatToggleButton:SetTemplate(panelStyle, panelGlossTex)

	LeftMiniPanel:SetTemplate(miniStyle, miniGlossTex)
	RightMiniPanel:SetTemplate(miniStyle, miniGlossTex)
	ElvConfigToggle:SetTemplate(miniStyle, miniGlossTex)
end

function LO:RepositionChatDataPanels()
	LeftChatDataPanel:ClearAllPoints()
	RightChatDataPanel:ClearAllPoints()

	local SPACING = E.Border*3 - E.Spacing
	local SIDE_BUTTON_SPACING = (E.PixelMode and E.Border*4) or SPACING*2

	--Left Chat Tab
	LeftChatTab:Point("TOPLEFT", LeftChatPanel, "TOPLEFT", SPACING, -SPACING)
	LeftChatTab:Point("TOPRIGHT", LeftChatPanel, "TOPRIGHT", -SPACING, -SPACING)
	LeftChatTab:Point("BOTTOMRIGHT", LeftChatPanel, "TOPRIGHT", -SPACING, -(SPACING + PANEL_HEIGHT))
	LeftChatTab:Point("BOTTOMLEFT", LeftChatPanel, "TOPLEFT", SPACING, -(SPACING + PANEL_HEIGHT))

	--Left Chat Data Panel
	LeftChatDataPanel:Point("BOTTOMLEFT", LeftChatPanel, "BOTTOMLEFT", SPACING + SIDE_BUTTON_WIDTH, SPACING)
	LeftChatDataPanel:Point("BOTTOMRIGHT", LeftChatPanel, "BOTTOMRIGHT", -SPACING, SPACING)
	LeftChatDataPanel:Point("TOPRIGHT", LeftChatPanel, "BOTTOMRIGHT", -SPACING, (SPACING + PANEL_HEIGHT))
	LeftChatDataPanel:Point("TOPLEFT", LeftChatPanel, "BOTTOMLEFT", SIDE_BUTTON_SPACING + SIDE_BUTTON_WIDTH, (SPACING + PANEL_HEIGHT))

	--Left Chat Toggle Button
	LeftChatToggleButton:Point("TOPRIGHT", LeftChatDataPanel, "TOPLEFT", E.Border - E.Spacing*3, 0)
	LeftChatToggleButton:Point("TOPLEFT", LeftChatDataPanel, "TOPLEFT", -E.Border - E.Spacing*3 - SIDE_BUTTON_WIDTH, 0)
	LeftChatToggleButton:Point("BOTTOMLEFT", LeftChatPanel, "BOTTOMLEFT", SPACING, SPACING)
	LeftChatToggleButton:Point("BOTTOMRIGHT", LeftChatPanel, "BOTTOMLEFT", SPACING + SIDE_BUTTON_WIDTH, SPACING)

	--Right Chat Tab
	RightChatTab:Point("TOPRIGHT", RightChatPanel, "TOPRIGHT", -SPACING, -SPACING)
	RightChatTab:Point("TOPLEFT", RightChatPanel, "TOPLEFT", SPACING, -SPACING)
	RightChatTab:Point("BOTTOMLEFT", RightChatPanel, "TOPLEFT", SPACING, -(SPACING + PANEL_HEIGHT))
	RightChatTab:Point("BOTTOMRIGHT", RightChatPanel, "TOPRIGHT", -SPACING, -(SPACING + PANEL_HEIGHT))

	--Right Chat Data Panel
	RightChatDataPanel:Point("BOTTOMLEFT", RightChatPanel, "BOTTOMLEFT", SPACING, SPACING)
	RightChatDataPanel:Point("BOTTOMRIGHT", RightChatPanel, "BOTTOMRIGHT", -SPACING-SIDE_BUTTON_WIDTH, SPACING)
	RightChatDataPanel:Point("TOPRIGHT", RightChatPanel, "BOTTOMRIGHT", -(SIDE_BUTTON_SPACING + SIDE_BUTTON_WIDTH), SPACING + PANEL_HEIGHT)
	RightChatDataPanel:Point("TOPLEFT", RightChatPanel, "BOTTOMLEFT", (SPACING), SPACING + PANEL_HEIGHT)

	--Right Chat Toggle Button
	RightChatToggleButton:Point("TOPLEFT", RightChatDataPanel, "TOPRIGHT", -E.Border + E.Spacing*3, 0)
	RightChatToggleButton:Point("TOPRIGHT", RightChatDataPanel, "TOPRIGHT", E.Border + E.Spacing*3 + SIDE_BUTTON_WIDTH, 0)
	RightChatToggleButton:Point("BOTTOMRIGHT", RightChatPanel, "BOTTOMRIGHT", -SPACING, SPACING)
	RightChatToggleButton:Point("BOTTOMLEFT", RightChatPanel, "BOTTOMRIGHT", -SPACING - SIDE_BUTTON_WIDTH, SPACING)
end

function LO:ToggleChatPanels()
	LeftChatDataPanel:ClearAllPoints()
	RightChatDataPanel:ClearAllPoints()

	local SPACING = E.Border*3 - E.Spacing
	local SIDE_BUTTON_SPACING = (E.PixelMode and E.Border*4) or SPACING*2

	if E.db.datatexts.leftChatPanel then
		LeftChatDataPanel:Show()
		LeftChatToggleButton:Show()
	else
		LeftChatDataPanel:Hide()
		LeftChatToggleButton:Hide()
	end

	if E.db.datatexts.rightChatPanel then
		RightChatDataPanel:Show()
		RightChatToggleButton:Show()
	else
		RightChatDataPanel:Hide()
		RightChatToggleButton:Hide()
	end

	local panelBackdrop = E.db.chat.panelBackdrop
	if panelBackdrop == "SHOWBOTH" then
		LeftChatPanel.backdrop:Show()
		RightChatPanel.backdrop:Show()
		LeftChatDataPanel:Point("BOTTOMLEFT", LeftChatPanel, "BOTTOMLEFT", SIDE_BUTTON_SPACING + SIDE_BUTTON_WIDTH, SPACING)
		LeftChatDataPanel:Point("TOPRIGHT", LeftChatPanel, "BOTTOMRIGHT", -SPACING, (SPACING + PANEL_HEIGHT))
		RightChatDataPanel:Point("BOTTOMLEFT", RightChatPanel, "BOTTOMLEFT", SPACING, SPACING)
		RightChatDataPanel:Point("TOPRIGHT", RightChatPanel, "BOTTOMRIGHT", -(SIDE_BUTTON_SPACING + SIDE_BUTTON_WIDTH), SPACING + PANEL_HEIGHT)
		LeftChatToggleButton:Point("BOTTOMLEFT", LeftChatPanel, "BOTTOMLEFT", SPACING, SPACING)
		RightChatToggleButton:Point("BOTTOMRIGHT", RightChatPanel, "BOTTOMRIGHT", -SPACING, SPACING)
		LO:ToggleChatTabPanels()
	elseif panelBackdrop == "HIDEBOTH" then
		LeftChatPanel.backdrop:Hide()
		RightChatPanel.backdrop:Hide()
		LeftChatDataPanel:Point("BOTTOMLEFT", LeftChatPanel, "BOTTOMLEFT", SIDE_BUTTON_WIDTH, 0)
		LeftChatDataPanel:Point("TOPRIGHT", LeftChatPanel, "BOTTOMRIGHT", 0, PANEL_HEIGHT)
		RightChatDataPanel:Point("BOTTOMLEFT", RightChatPanel, "BOTTOMLEFT")
		RightChatDataPanel:Point("TOPRIGHT", RightChatPanel, "BOTTOMRIGHT", -SIDE_BUTTON_WIDTH, PANEL_HEIGHT)
		LeftChatToggleButton:Point("BOTTOMLEFT", LeftChatPanel, "BOTTOMLEFT")
		RightChatToggleButton:Point("BOTTOMRIGHT", RightChatPanel, "BOTTOMRIGHT")
		LO:ToggleChatTabPanels(true, true)
	elseif panelBackdrop == "LEFT" then
		LeftChatPanel.backdrop:Show()
		RightChatPanel.backdrop:Hide()
		LeftChatDataPanel:Point("BOTTOMLEFT", LeftChatPanel, "BOTTOMLEFT", SIDE_BUTTON_SPACING + SIDE_BUTTON_WIDTH, SPACING)
		LeftChatDataPanel:Point("TOPRIGHT", LeftChatPanel, "BOTTOMRIGHT", -SPACING, (SPACING + PANEL_HEIGHT))
		RightChatDataPanel:Point("BOTTOMLEFT", RightChatPanel, "BOTTOMLEFT")
		RightChatDataPanel:Point("TOPRIGHT", RightChatPanel, "BOTTOMRIGHT", -SIDE_BUTTON_WIDTH, PANEL_HEIGHT)
		LeftChatToggleButton:Point("BOTTOMLEFT", LeftChatPanel, "BOTTOMLEFT", SPACING, SPACING)
		RightChatToggleButton:Point("BOTTOMRIGHT", RightChatPanel, "BOTTOMRIGHT")
		LO:ToggleChatTabPanels(true)
	else
		LeftChatPanel.backdrop:Hide()
		RightChatPanel.backdrop:Show()
		LeftChatDataPanel:Point("BOTTOMLEFT", LeftChatPanel, "BOTTOMLEFT", SIDE_BUTTON_WIDTH, 0)
		LeftChatDataPanel:Point("TOPRIGHT", LeftChatPanel, "BOTTOMRIGHT", 0, PANEL_HEIGHT)
		RightChatDataPanel:Point("BOTTOMLEFT", RightChatPanel, "BOTTOMLEFT", SPACING, SPACING)
		RightChatDataPanel:Point("TOPRIGHT", RightChatPanel, "BOTTOMRIGHT", -(SIDE_BUTTON_SPACING + SIDE_BUTTON_WIDTH), SPACING + PANEL_HEIGHT)
		LeftChatToggleButton:Point("BOTTOMLEFT", LeftChatPanel, "BOTTOMLEFT")
		RightChatToggleButton:Point("BOTTOMRIGHT", RightChatPanel, "BOTTOMRIGHT", -SPACING, SPACING)
		LO:ToggleChatTabPanels(nil, true)
	end
end

function LO:CreateChatPanels()
	local SPACING = E.Border*3 - E.Spacing
	local SIDE_BUTTON_SPACING = (E.PixelMode and E.Border*4) or SPACING*2

	--Left Chat
	local lchat = CreateFrame("Frame", "LeftChatPanel", E.UIParent)
	lchat:SetFrameStrata("BACKGROUND")
	lchat:SetFrameLevel(100)
	lchat:Size(E.db.chat.panelWidth, E.db.chat.panelHeight)
	lchat:Point("BOTTOMLEFT", E.UIParent, 4, 4)
	lchat:CreateBackdrop("Transparent")
	lchat.backdrop.ignoreBackdropColors = true
	lchat.backdrop:SetAllPoints()
	E:CreateMover(lchat, "LeftChatMover", L["Left Chat"], nil, nil, nil, nil, nil, "chat,general")

	--Background Texture
	lchat.tex = lchat:CreateTexture(nil, "OVERLAY")
	lchat.tex:SetInside()
	lchat.tex:SetTexture(E.db.chat.panelBackdropNameLeft)
	lchat.tex:SetAlpha(E.db.general.backdropfadecolor.a - 0.7 > 0 and E.db.general.backdropfadecolor.a - 0.7 or 0.5)

	--Left Chat Tab
	local lchattab = CreateFrame("Frame", "LeftChatTab", lchat)
	lchattab:Point("TOPLEFT", lchat, "TOPLEFT", SPACING, -SPACING)
	lchattab:Point("TOPRIGHT", lchat, "TOPRIGHT", -SPACING, -SPACING)
	lchattab:Point("BOTTOMRIGHT", lchat, "TOPRIGHT", -SPACING, -(SPACING + PANEL_HEIGHT))
	lchattab:Point("BOTTOMLEFT", lchat, "TOPLEFT", SPACING, -(SPACING + PANEL_HEIGHT))
	lchattab:SetTemplate(E.db.chat.panelTabTransparency and "Transparent" or "Default", true)

	--Left Chat Data Panel
	local lchatdp = CreateFrame("Frame", "LeftChatDataPanel", lchat)
	lchatdp:Point("BOTTOMLEFT", lchat, "BOTTOMLEFT", SPACING + SIDE_BUTTON_WIDTH, SPACING)
	lchatdp:Point("BOTTOMRIGHT", lchat, "BOTTOMRIGHT", -SPACING, SPACING)
	lchatdp:Point("TOPRIGHT", lchat, "BOTTOMRIGHT", -SPACING, (SPACING + PANEL_HEIGHT))
	lchatdp:Point("TOPLEFT", lchat, "BOTTOMLEFT", SIDE_BUTTON_SPACING+SIDE_BUTTON_WIDTH, (SPACING + PANEL_HEIGHT))
	lchatdp:SetTemplate(E.db.datatexts.panelTransparency and "Transparent" or "Default", true)

	DT:RegisterPanel(lchatdp, 3, "ANCHOR_TOPLEFT", -17, 4)

	--Left Chat Toggle Button
	local lchattb = CreateFrame("Button", "LeftChatToggleButton", E.UIParent)
	lchattb.parent = lchat
	LeftChatPanel.fadeFunc = ChatPanelLeft_OnFade
	lchattb:Point("TOPRIGHT", lchatdp, "TOPLEFT", E.Border - E.Spacing*3, 0)
	lchattb:Point("TOPLEFT", lchatdp, "TOPLEFT", -E.Border - E.Spacing*3 - SIDE_BUTTON_WIDTH, 0)
	lchattb:Point("BOTTOMLEFT", lchat, "BOTTOMLEFT", SPACING, SPACING)
	lchattb:Point("BOTTOMRIGHT", lchat, "BOTTOMLEFT", SPACING+SIDE_BUTTON_WIDTH, SPACING)
	lchattb:SetTemplate(E.db.datatexts.panelTransparency and "Transparent" or "Default", true)
	lchattb:RegisterForClicks("AnyUp")
	lchattb:SetScript("OnEnter", ChatButton_OnEnter)
	lchattb:SetScript("OnLeave", ChatButton_OnLeave)
	lchattb:SetScript("OnClick", ChatButton_OnClick)
	lchattb.text = lchattb:CreateFontString(nil, "OVERLAY")
	lchattb.text:FontTemplate()
	lchattb.text:Point("CENTER")
	lchattb.text:SetJustifyH("CENTER")
	lchattb.text:SetText("<")

	--Right Chat
	local rchat = CreateFrame("Frame", "RightChatPanel", E.UIParent)
	rchat:SetFrameStrata("BACKGROUND")
	rchat:SetFrameLevel(100)
	rchat:Size(E.db.chat.separateSizes and E.db.chat.panelWidthRight or E.db.chat.panelWidth, E.db.chat.separateSizes and E.db.chat.panelHeightRight or E.db.chat.panelHeight)
	rchat:Point("BOTTOMRIGHT", E.UIParent, -4, 4)
	rchat:CreateBackdrop("Transparent")
	rchat.backdrop.ignoreBackdropColors = true
	rchat.backdrop:SetAllPoints()
	E:CreateMover(rchat, "RightChatMover", L["Right Chat"], nil, nil, nil, nil, nil, "chat,general")

	--Background Texture
	rchat.tex = rchat:CreateTexture(nil, "OVERLAY")
	rchat.tex:SetInside()
	rchat.tex:SetTexture(E.db.chat.panelBackdropNameRight)
	rchat.tex:SetAlpha(E.db.general.backdropfadecolor.a - 0.7 > 0 and E.db.general.backdropfadecolor.a - 0.7 or 0.5)

	--Right Chat Tab
	local rchattab = CreateFrame("Frame", "RightChatTab", rchat)
	rchattab:Point("TOPRIGHT", rchat, "TOPRIGHT", -SPACING, -SPACING)
	rchattab:Point("TOPLEFT", rchat, "TOPLEFT", SPACING, -SPACING)
	rchattab:Point("BOTTOMLEFT", rchat, "TOPLEFT", SPACING, -(SPACING + PANEL_HEIGHT))
	rchattab:Point("BOTTOMRIGHT", rchat, "TOPRIGHT", -SPACING, -(SPACING + PANEL_HEIGHT))
	rchattab:SetTemplate(E.db.chat.panelTabTransparency and "Transparent" or "Default", true)

	--Right Chat Data Panel
	local rchatdp = CreateFrame("Frame", "RightChatDataPanel", rchat)
	rchatdp:Point("BOTTOMLEFT", rchat, "BOTTOMLEFT", SPACING, SPACING)
	rchatdp:Point("BOTTOMRIGHT", rchat, "BOTTOMRIGHT", -SPACING-SIDE_BUTTON_WIDTH, SPACING)
	rchatdp:Point("TOPRIGHT", rchat, "BOTTOMRIGHT", -(SIDE_BUTTON_SPACING + SIDE_BUTTON_WIDTH), SPACING + PANEL_HEIGHT)
	rchatdp:Point("TOPLEFT", rchat, "BOTTOMLEFT", (SPACING), SPACING + PANEL_HEIGHT)
	rchatdp:SetTemplate(E.db.datatexts.panelTransparency and "Transparent" or "Default", true)
	DT:RegisterPanel(rchatdp, 3, "ANCHOR_TOPRIGHT", 17, 4)

	--Right Chat Toggle Button
	local rchattb = CreateFrame("Button", "RightChatToggleButton", E.UIParent)
	rchattb.parent = rchat
	rchat.fadeFunc = ChatPanelRight_OnFade
	rchattb:Point("TOPLEFT", rchatdp, "TOPRIGHT", -E.Border + E.Spacing*3, 0)
	rchattb:Point("TOPRIGHT", rchatdp, "TOPRIGHT", E.Border + E.Spacing*3 + SIDE_BUTTON_WIDTH, 0)
	rchattb:Point("BOTTOMRIGHT", rchat, "BOTTOMRIGHT", -SPACING, SPACING)
	rchattb:Point("BOTTOMLEFT", rchat, "BOTTOMRIGHT", -SPACING-SIDE_BUTTON_WIDTH, SPACING)
	rchattb:SetTemplate(E.db.datatexts.panelTransparency and "Transparent" or "Default", true)
	rchattb:RegisterForClicks("AnyUp")
	rchattb:SetScript("OnEnter", ChatButton_OnEnter)
	rchattb:SetScript("OnLeave", ChatButton_OnLeave)
	rchattb:SetScript("OnClick", ChatButton_OnClick)
	rchattb.text = rchattb:CreateFontString(nil, "OVERLAY")
	rchattb.text:FontTemplate()
	rchattb.text:Point("CENTER")
	rchattb.text:SetJustifyH("CENTER")
	rchattb.text:SetText(">")

	--Load Settings
	local fadeToggle = E.db.chat.fadeChatToggles
	if E.db.LeftChatPanelFaded then
		if fadeToggle then
			LeftChatToggleButton:SetAlpha(0)
		end

		lchat:Hide()
	end

	if E.db.RightChatPanelFaded then
		if fadeToggle then
			RightChatToggleButton:SetAlpha(0)
		end

		rchat:Hide()
	end

	self:ToggleChatPanels()
end

function LO:CreateMinimapPanels()
	local lminipanel = CreateFrame("Frame", "LeftMiniPanel", Minimap)
	lminipanel:Point("TOPLEFT", Minimap, "BOTTOMLEFT", -E.Border, -E.Spacing*3)
	lminipanel:Point("BOTTOMRIGHT", Minimap, "BOTTOM", 0, -(E.Spacing*3 + PANEL_HEIGHT))
	lminipanel:SetTemplate(E.db.datatexts.panelTransparency and "Transparent" or "Default", true)
	DT:RegisterPanel(lminipanel, 1, "ANCHOR_BOTTOMLEFT", lminipanel:GetWidth() * 2, -4)

	local rminipanel = CreateFrame("Frame", "RightMiniPanel", Minimap)
	rminipanel:Point("TOPRIGHT", Minimap, "BOTTOMRIGHT", E.Border, -(E.Spacing*3))
	rminipanel:Point("BOTTOMLEFT", lminipanel, "BOTTOMRIGHT", -E.Border + (E.Spacing*3), 0)
	rminipanel:SetTemplate(E.db.datatexts.panelTransparency and "Transparent" or "Default", true)
	DT:RegisterPanel(rminipanel, 1, "ANCHOR_BOTTOM", 0, -4)

	if E.db.datatexts.minimapPanels then
		LeftMiniPanel:Show()
		RightMiniPanel:Show()
	else
		LeftMiniPanel:Hide()
		RightMiniPanel:Hide()
	end

	local configtoggle = CreateFrame("Button", "ElvConfigToggle", Minimap)
	if E.db.general.reminder.position == "LEFT" then
		configtoggle:Point("TOPRIGHT", lminipanel, "TOPLEFT", (E.PixelMode and 1 or -1), 0)
		configtoggle:Point("BOTTOMRIGHT", lminipanel, "BOTTOMLEFT", (E.PixelMode and 1 or -1), 0)
	else
		configtoggle:Point("TOPLEFT", rminipanel, "TOPRIGHT", (E.PixelMode and -1 or 1), 0)
		configtoggle:Point("BOTTOMLEFT", rminipanel, "BOTTOMRIGHT", (E.PixelMode and -1 or 1), 0)
	end
	configtoggle:RegisterForClicks("AnyUp")
	configtoggle:Width(E.RBRWidth)
	configtoggle:SetTemplate(E.db.datatexts.panelTransparency and "Transparent" or "Default", true)
	configtoggle.text = configtoggle:CreateFontString(nil, "OVERLAY")
	configtoggle.text:FontTemplate(E.Libs.LSM:Fetch("font", E.db.datatexts.font), E.db.datatexts.fontSize, E.db.datatexts.fontOutline)
	configtoggle.text:SetText("C")
	configtoggle.text:SetPoint("CENTER")
	configtoggle.text:SetJustifyH("CENTER")
	configtoggle:SetScript("OnClick", function(_, btn)
		if btn == "LeftButton" then
			E:ToggleOptionsUI()
		else
			E:BGStats()
		end
	end)
	configtoggle:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 0, -4)
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(L["Left Click:"], L["Toggle Configuration"], 1, 1, 1)

		if E.db.datatexts.battleground then
			GameTooltip:AddDoubleLine(L["Right Click:"], L["Show BG Texts"], 1, 1, 1)
		end
		GameTooltip:Show()
	end)
	configtoggle:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	local f = CreateFrame("Frame", "BottomMiniPanel", Minimap)
	f:SetPoint("BOTTOM", Minimap, "BOTTOM")
	f:Width(120)
	f:Height(20)
	f:SetFrameLevel(Minimap:GetFrameLevel() + 5)
	DT:RegisterPanel(f, 1, "ANCHOR_BOTTOM", 0, -10)

	f = CreateFrame("Frame", "TopMiniPanel", Minimap)
	f:SetPoint("TOP", Minimap, "TOP")
	f:Width(120)
	f:Height(20)
	f:SetFrameLevel(Minimap:GetFrameLevel() + 5)
	DT:RegisterPanel(f, 1, "ANCHOR_BOTTOM", 0, -10)

	f = CreateFrame("Frame", "TopLeftMiniPanel", Minimap)
	f:SetPoint("TOPLEFT", Minimap, "TOPLEFT")
	f:Width(75)
	f:Height(20)
	f:SetFrameLevel(Minimap:GetFrameLevel() + 5)
	DT:RegisterPanel(f, 1, "ANCHOR_BOTTOMLEFT", 0, -10)

	f = CreateFrame("Frame", "TopRightMiniPanel", Minimap)
	f:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT")
	f:Width(75)
	f:Height(20)
	f:SetFrameLevel(Minimap:GetFrameLevel() + 5)
	DT:RegisterPanel(f, 1, "ANCHOR_BOTTOMRIGHT", 0, -10)

	f = CreateFrame("Frame", "BottomLeftMiniPanel", Minimap)
	f:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT")
	f:Width(75)
	f:Height(20)
	f:SetFrameLevel(Minimap:GetFrameLevel() + 5)
	DT:RegisterPanel(f, 1, "ANCHOR_BOTTOMLEFT", 0, -10)

	f = CreateFrame("Frame", "BottomRightMiniPanel", Minimap)
	f:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT")
	f:Width(75)
	f:Height(20)
	f:SetFrameLevel(Minimap:GetFrameLevel() + 5)
	DT:RegisterPanel(f, 1, "ANCHOR_BOTTOMRIGHT", 0, -10)
end

local function InitializeCallback()
	LO:Initialize()
end

E:RegisterModule(LO:GetName(), InitializeCallback)