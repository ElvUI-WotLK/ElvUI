local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:GetModule("Misc")

--Lua functions
local pairs, ipairs, unpack = pairs, ipairs, unpack
local find, format = string.find, string.format
local tinsert, twipe = table.insert, table.wipe
--WoW API / Variables
local ChatEdit_InsertLink = ChatEdit_InsertLink
local CreateFrame = CreateFrame
local CursorOnUpdate = CursorOnUpdate
local CursorUpdate = CursorUpdate
local DressUpItemLink = DressUpItemLink
local GetLootRollItemInfo = GetLootRollItemInfo
local GetLootRollItemLink = GetLootRollItemLink
local GetLootRollTimeLeft = GetLootRollTimeLeft
local IsModifiedClick = IsModifiedClick
local ResetCursor = ResetCursor
local RollOnLoot = RollOnLoot
local SetDesaturation = SetDesaturation
local UnitClass = UnitClass

local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local ROLL_DISENCHANT = ROLL_DISENCHANT

local POSITION = "TOP"
local FRAME_WIDTH, FRAME_HEIGHT = 328, 28

M.RollBars = {}

local locale = GetLocale()
local rollMessages = locale == "deDE" and {
	["(.*) passt automatisch bei (.+), weil [ersi]+ den Gegenstand nicht benutzen kann.$"] = 0,
	["(.*) würfelt nicht für: (.+|r)$"] = 0,
	["(.*) hat für (.+) 'Bedarf' ausgewählt"] = 1,
	["(.*) hat für (.+) 'Gier' ausgewählt"] = 2,
	["(.*) hat für '(.+)' Entzauberung gewählt."] = 3,
} or locale == "frFR" and {
	["(.*) a passé pour : (.+) parce qu'((il)|(elle)) ne peut pas ramasser cette objet.$"] = 0,
	["(.*) a passé pour : (.+)"] = 0,
	["(.*) a choisi Besoin pour : (.+)"] = 1,
	["(.*) a choisi Cupidité pour : (.+)"] = 2,
	["(.*) a choisi Désenchantement pour : (.+)"] = 3,
} or locale == "zhCN" and {
	["(.*)自动放弃了：(.+)，因为他无法拾取该物品$"] = 0,
	["(.*)自动放弃了：(.+)，因为她无法拾取该物品$"] = 0,
	["(.*)放弃了：(.+)"] = 0,
	["(.*)选择了需求取向：(.+)"] = 1,
	["(.*)选择了贪婪取向：(.+)"] = 2,
	["(.*)选择了分解取向：(.+)"] = 3,
} or locale == "zhTW" and {
	["(.*)自動放棄:(.+)，因為他無法拾取該物品$"] = 0,
	["(.*)自動放棄:(.+)，因為她無法拾取該物品$"] = 0,
	["(.*)放棄了:(.+)"] = 0,
	["(.*)選擇了需求:(.+)"] = 1,
	["(.*)選擇了貪婪:(.+)"] = 2,
	["(.*)選擇了分解:(.+)"] = 3,
} or locale == "ruRU" and {
	["(.*) автоматически передает предмет (.+), поскольку не может его забрать"] = 0,
	["(.*) пропускает розыгрыш предмета \"(.+)\", поскольку не может его забрать"] = 0,
	["(.*) отказывается от предмета (.+)%."] = 0,
	["Разыгрывается: (.+)%. (.*): \"Мне это нужно\""] = 1,
	["Разыгрывается: (.+)%. (.*): \"Не откажусь\""] = 2,
	["Разыгрывается: (.+)%. (.*): \"Распылить\""] = 3,
} or locale == "koKR" and {
	["(.*)님이 획득할 수 없는 아이템이어서 자동으로 주사위 굴리기를 포기했습니다: (.+)"] = 0,
	["(.*)님이 주사위 굴리기를 포기했습니다: (.+)"] = 0,
	["(.*)님이 입찰을 선택했습니다: (.+)"] = 1,
	["(.*)님이 차비를 선택했습니다: (.+)"] = 2,
	["(.*)님이 마력 추출을 선택했습니다: (.+)"] = 3,
} or locale == "esES" and {
	["^(.*) pasó automáticamente de: (.+) porque no puede despojar este objeto.$"] = 0,
	["^(.*) pasó de: (.+|r)$"] = 0,
	["(.*) eligió Necesidad para: (.+)"] = 1,
	["(.*) eligió Codicia para: (.+)"] = 2,
	["(.*) eligió Desencantar para: (.+)"] = 3,
} or locale == "esMX" and {
	["^(.*) pasó automáticamente de: (.+) porque no puede despojar este objeto.$"] = 0,
	["^(.*) pasó de: (.+|r)$"] = 0,
	["(.*) eligió Necesidad para: (.+)"] = 1,
	["(.*) eligió Codicia para: (.+)"] = 2,
	["(.*) eligió Desencantar para: (.+)"] = 3,
} or {
	["^(.*) automatically passed on: (.+) because s?he cannot loot that item.$"] = 0,
	["^(.*) passed on: (.+|r)$"] = 0,
	["(.*) has selected Need for: (.+)"] = 1,
	["(.*) has selected Greed for: (.+)"] = 2,
	["(.*) has selected Disenchant for: (.+)"] = 3
}

local rollTypes = {
	[0] = {
		tooltipText = PASS,
		normalTexture = "Interface\\Buttons\\UI-GroupLoot-Pass-Up",
		pushedTexture = "Interface\\Buttons\\UI-GroupLoot-Pass-Down",
		highlightTexture = nil,
	},
	[1] = {
		tooltipText = NEED,
		newbieText = NEED_NEWBIE,
		normalTexture = "Interface\\Buttons\\UI-GroupLoot-Dice-Up",
		pushedTexture = "Interface\\Buttons\\UI-GroupLoot-Dice-Down",
		highlightTexture = "Interface\\Buttons\\UI-GroupLoot-Dice-Highlight",
	},
	[2] = {
		tooltipText = GREED,
		newbieText = GREED_NEWBIE,
		normalTexture = "Interface\\Buttons\\UI-GroupLoot-Coin-Up",
		pushedTexture = "Interface\\Buttons\\UI-GroupLoot-Coin-Down",
		highlightTexture = "Interface\\Buttons\\UI-GroupLoot-Coin-Highlight",
	},
	[3] = {
		tooltipText = ROLL_DISENCHANT,
		newbieText = ROLL_DISENCHANT_NEWBIE,
		normalTexture = "Interface\\Buttons\\UI-GroupLoot-DE-Up",
		pushedTexture = "Interface\\Buttons\\UI-GroupLoot-DE-Down",
		highlightTexture = "Interface\\Buttons\\UI-GroupLoot-DE-Highlight",
	},
}

local reasons = {
	LOOT_ROLL_INELIGIBLE_REASON1,
	LOOT_ROLL_INELIGIBLE_REASON2,
	LOOT_ROLL_INELIGIBLE_REASON3,
	LOOT_ROLL_INELIGIBLE_REASON4,
	LOOT_ROLL_INELIGIBLE_REASON5,
}

local function buttonOnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

	GameTooltip:SetText(self.tooltipText)

	if self.newbieText and SHOW_NEWBIE_TIPS == "1" then
		GameTooltip:AddLine(self.newbieText, 1, 0.82, 0, true)
	end

	if self:IsEnabled() == 0 then
		GameTooltip:AddLine(self.reason, 1, 0.1, 0.1, true)
	end

	for playerName, rollData in pairs(self.parent.rollResults) do
		if self.rollType == rollData[1] and rollData[2] then
			local classColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[rollData[2]] or RAID_CLASS_COLORS[rollData[2]]
			GameTooltip:AddLine(playerName, classColor.r, classColor.g, classColor.b)
		end
	end

	GameTooltip:Show()
end

local function buttonOnLeave()
	GameTooltip:Hide()
end

local function buttonOnClick(self)
	RollOnLoot(self.parent.rollID, self.rollType)
end

local function toggleLootButton(self, state, reason, reasonValue)
	if state then
		self:Enable()
		self:SetAlpha(1)
		self.reason = nil
		SetDesaturation(self:GetNormalTexture(), false)
	else
		self:Disable()
		self:SetAlpha(0.2)
		self.reason = reasonValue and format(reasons[reason], reasonValue) or reasons[reason]
		SetDesaturation(self:GetNormalTexture(), true)
	end
end

local function increaseRollCount(self, count)
	local text = self.text:GetText()
	if not text or text == "" then
		self.text:SetText(count or 1)
	else
		self.text:SetText(self.text:GetText() + (count or 1))
	end
end

function M:CreateRollButton(parent, rollType)
	local data = rollTypes[rollType]

	local button = CreateFrame("Button", nil, parent)
	button:Size(FRAME_HEIGHT - 4)
	button:SetNormalTexture(data.normalTexture)
	button:SetPushedTexture(data.highlightTexture)
	button:SetHighlightTexture(data.pushedTexture)

	button:SetMotionScriptsWhileDisabled(true)
	button:SetScript("OnEnter", buttonOnEnter)
	button:SetScript("OnLeave", buttonOnLeave)
	button:SetScript("OnClick", buttonOnClick)

	button.ToggleLootButton = toggleLootButton
	button.IncreaseRollCount = increaseRollCount
	button.parent = parent
	button.rollType = rollType
	button.tooltipText = data.tooltipText
	button.newbieText = data.newbieText

	button.text = button:CreateFontString(nil, nil)
	button.text:FontTemplate(nil, nil, "OUTLINE")

	return button
end

local function itemOnEnter(self)
	GameTooltip:SetOwner(self, POSITION == "TOP" and "ANCHOR_BOTTOMLEFT" or "ANCHOR_TOPLEFT")
	GameTooltip:SetLootRollItem(self.rollID)

	CursorUpdate(self)
end

local function itemOnLeave()
	GameTooltip:Hide()
	ResetCursor()
end

local function itemOnUpdate(self)
	if GameTooltip:IsOwned(self) then
		GameTooltip:SetOwner(self, POSITION == "TOP" and "ANCHOR_BOTTOMLEFT" or "ANCHOR_TOPLEFT")
		GameTooltip:SetLootRollItem(self.rollID)
	end

	CursorOnUpdate(self)
end

local function itemOnClick(self)
	if IsModifiedClick("CHATLINK") then
		ChatEdit_InsertLink(self.link)
	elseif IsModifiedClick("DRESSUP") then
		DressUpItemLink(self.link)
	end
end

local function statusbarOnUpdate(self)
	local timeLeft = GetLootRollTimeLeft(self.parent.rollID)
	if timeLeft < 0 or timeLeft > self.parent.rollTime then
		timeLeft = 0
	else
		self.spark:Point("CENTER", self, "LEFT", (timeLeft / self.parent.rollTime) * self:GetWidth(), 0)
	end

	self:SetValue(timeLeft)
end

function M:CreateRollFrame()
	self.numFrames = self.numFrames + 1

	local frame = CreateFrame("Frame", format("ElvUI_GroupLootFrame%d", self.numFrames), E.UIParent)
	frame:Size(FRAME_WIDTH, FRAME_HEIGHT)
	frame:SetTemplate()
	frame:SetFrameStrata("DIALOG")
	frame:Hide()

	if POSITION == "TOP" then
		frame:Point("TOP", self.numFrames > 1 and self.RollBars[self.numFrames - 1] or AlertFrameHolder, "BOTTOM", 0, -4)
	else
		frame:Point("BOTTOM", self.numFrames > 1 and self.RollBars[self.numFrames - 1] or AlertFrameHolder, "TOP", 0, 4)
	end

	local itemButton = CreateFrame("Button", "$parentIconFrame", frame)
	itemButton:Size(FRAME_HEIGHT - (E.Border * 2))
	itemButton:Point("RIGHT", frame, "LEFT", -(E.Spacing * 3), 0)
	itemButton:CreateBackdrop()
	itemButton:SetScript("OnEnter", itemOnEnter)
	itemButton:SetScript("OnLeave", itemOnLeave)
	itemButton:SetScript("OnUpdate", itemOnUpdate)
	itemButton:SetScript("OnClick", itemOnClick)
	itemButton.hasItem = 1
	frame.itemButton = itemButton

	itemButton.icon = itemButton:CreateTexture(nil, "OVERLAY")
	itemButton.icon:SetAllPoints()
	itemButton.icon:SetTexCoord(unpack(E.TexCoords))

	local fade = frame:CreateTexture(nil, "BORDER")
	fade:Point("TOPLEFT", frame, "TOPLEFT", 4, 0)
	fade:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -4, 0)
	fade:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
	fade:SetBlendMode("ADD")
	fade:SetGradientAlpha("VERTICAL", 0.1, 0.1, 0.1, 0, 0.1, 0.1, 0.1, 0)
	frame.fade = fade

	local status = CreateFrame("StatusBar", "$parentStatusBar", frame)
	status:SetInside()
	status:SetFrameLevel(status:GetFrameLevel() - 1)
	status:SetStatusBarTexture(E.media.normTex)
	status:SetStatusBarColor(0.8, 0.8, 0.8, 0.9)
	status.parent = frame
	E:RegisterStatusBar(status)
	status:SetScript("OnUpdate", statusbarOnUpdate)
	frame.status = status

	status.bg = status:CreateTexture(nil, "BACKGROUND")
	status.bg:SetAlpha(0.1)
	status.bg:SetAllPoints()

	local spark = frame:CreateTexture(nil, "OVERLAY")
	spark:Size(14, FRAME_HEIGHT)
	spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
	spark:SetBlendMode("ADD")
	status.spark = spark

	frame.passButton = self:CreateRollButton(frame, 0)
	frame.needButton = self:CreateRollButton(frame, 1)
	frame.greedButton = self:CreateRollButton(frame, 2)
	frame.disenchantButton = self:CreateRollButton(frame, 3)

	frame.needButton:SetHitRectInsets(0, 0, -2, 0)
	frame.greedButton:SetHitRectInsets(0, 0, -3, 1)
	frame.disenchantButton:SetHitRectInsets(0, 0, -2, 0)
	frame.passButton:SetHitRectInsets(0, 0, 0, -2)

	frame.needButton:Point("LEFT", frame.itemButton, "RIGHT", 4, -1)
	frame.greedButton:Point("LEFT", frame.needButton, "RIGHT", 1, -1)
	frame.disenchantButton:Point("LEFT", frame.greedButton, "RIGHT", 0, 1)
	frame.passButton:Point("LEFT", frame.disenchantButton, "RIGHT", 0, 2)

	frame.needButton.text:Point("CENTER", 0, 2)
	frame.greedButton.text:Point("CENTER", 1, 3)
	frame.disenchantButton.text:Point("CENTER", 1, 2)
	frame.passButton.text:Point("CENTER", 1, 0)

	frame.bindText = frame:CreateFontString()
	frame.bindText:Point("LEFT", frame.passButton, "RIGHT", 2, 0)
	frame.bindText:FontTemplate(nil, nil, "OUTLINE")

	local itemName = frame:CreateFontString(nil, "ARTWORK")
	itemName:FontTemplate(nil, nil, "OUTLINE")
	itemName:Point("LEFT", frame.bindText, "RIGHT", 1, 0)
	itemName:Point("RIGHT", frame, "RIGHT", -5, 0)
	itemName:SetJustifyH("LEFT")
	frame.itemName = itemName

	frame.rollResults = {}
	frame.rollButtons = {
		[0] = frame.passButton,
		[1] = frame.needButton,
		[2] = frame.greedButton,
		[3] = frame.disenchantButton,
	}

	tinsert(self.RollBars, frame)

	return frame
end

function M:ReleaseFrame(frame)
	frame:Hide()
	frame.rollID = nil
	frame.rollTime = nil

	for i = 0, 3 do
		frame.rollButtons[i].text:SetText("")
	end

	twipe(frame.rollResults)
end

function M:GetFrame()
	for _, frame in ipairs(M.RollBars) do
		if not frame.rollID then
			return frame
		end
	end

	return self:CreateRollFrame()
end

function M:START_LOOT_ROLL(_, rollID, rollTime)
	local f = self:GetFrame()
	f.rollID = rollID
	f.rollTime = rollTime

	local texture, name, count, quality, bindOnPickUp, canNeed, canGreed, canDisenchant, reasonNeed, reasonGreed, reasonDisenchant, deSkillRequired = GetLootRollItemInfo(rollID)

	f.itemButton.icon:SetTexture(texture)
	f.itemButton.rollID = rollID
	f.itemButton.link = GetLootRollItemLink(rollID)

	if count > 1 then
		f.itemName:SetFormattedText("%dx %s", count, name)
	else
		f.itemName:SetText(name)
	end

	f.status:SetMinMaxValues(0, rollTime)
	f.status:SetValue(rollTime)

	local color = ITEM_QUALITY_COLORS[quality]
	f.status:SetStatusBarColor(color.r, color.g, color.b, 0.7)
	f.status.bg:SetTexture(color.r, color.g, color.b)

	f.bindText:SetText(bindOnPickUp and "BoP" or "BoE")
	f.bindText:SetVertexColor(bindOnPickUp and 1 or 0.3, bindOnPickUp and 0.3 or 1, bindOnPickUp and 0.1 or 0.3)

	f.needButton:ToggleLootButton(canNeed, reasonNeed)
	f.greedButton:ToggleLootButton(canGreed, reasonGreed)
	f.disenchantButton:ToggleLootButton(canDisenchant, reasonDisenchant, deSkillRequired)

	f:Show()

	AlertFrame_FixAnchors()

	if E.db.general.autoRoll and E.mylevel == MAX_PLAYER_LEVEL and quality == 2 and not bindOnPickUp then
		if canDisenchant then
			RollOnLoot(rollID, 3)
		else
			RollOnLoot(rollID, 2)
		end
	end
end

function M:CANCEL_LOOT_ROLL(_, rollID)
	for _, frame in ipairs(self.RollBars) do
		if frame.rollID == rollID then
			self:ReleaseFrame(frame)
			E:StaticPopup_Hide("CONFIRM_LOOT_ROLL", self.rollID)
			break
		end
	end
end

function M:ParseRollChoice(msg)
	for regex, rollType in pairs(rollMessages) do
		local _, _, playerName, itemName = find(msg, regex)

		if playerName and itemName and playerName ~= "Everyone" then
			if locale == "ruRU" and rollType ~= 0 then
				playerName, itemName = itemName, playerName
			end

			return playerName, itemName, rollType
		end
	end
end

function M:CHAT_MSG_LOOT(_, msg)
	local playerName, itemName, rollType = self:ParseRollChoice(msg)

	if playerName and itemName then
		local _, class = UnitClass(playerName)

		for _, frame in ipairs(self.RollBars) do
			if frame.rollID and frame.itemButton.link == itemName and not frame.rollResults[playerName] then
				frame.rollResults[playerName] = {rollType, class}
				frame.rollButtons[rollType]:IncreaseRollCount()
				break
			end
		end
	end
end

function M:LoadLootRoll()
	if not E.private.general.lootRoll then return end

	self.numFrames = 0

	self:RegisterEvent("CHAT_MSG_LOOT")
	self:RegisterEvent("START_LOOT_ROLL")
	self:RegisterEvent("CANCEL_LOOT_ROLL")

	UIParent:UnregisterEvent("START_LOOT_ROLL")
	UIParent:UnregisterEvent("CANCEL_LOOT_ROLL")

	for i = 1, NUM_GROUP_LOOT_FRAMES do
		_G["GroupLootFrame"..i]:UnregisterEvent("CANCEL_LOOT_ROLL")
	end
end