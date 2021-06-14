local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local TT = E:GetModule("Tooltip")

--Lua functions
local _G = _G
local unpack, tonumber, select = unpack, tonumber, select
local twipe, tinsert, tconcat = table.wipe, table.insert, table.concat
local floor = math.floor
local find, format, sub, match = string.find, string.format, string.sub, string.match
--WoW API / Variables
local CreateFrame = CreateFrame
local GetTime = GetTime
local UnitGUID = UnitGUID
local InCombatLockdown = InCombatLockdown
local IsShiftKeyDown = IsShiftKeyDown
local IsControlKeyDown = IsControlKeyDown
local IsAltKeyDown = IsAltKeyDown
local GetInventoryItemLink = GetInventoryItemLink
local GetInventorySlotInfo = GetInventorySlotInfo
local UnitExists = UnitExists
local CanInspect = CanInspect
local NotifyInspect = NotifyInspect
local GetMouseFocus = GetMouseFocus
local UnitLevel = UnitLevel
local UnitIsPlayer = UnitIsPlayer
local UnitClass = UnitClass
local UnitName = UnitName
local GetGuildInfo = GetGuildInfo
local UnitPVPName = UnitPVPName
local UnitIsAFK = UnitIsAFK
local UnitIsDND = UnitIsDND
local GetQuestDifficultyColor = GetQuestDifficultyColor
local UnitRace = UnitRace
local UnitIsTapped = UnitIsTapped
local UnitIsTappedByPlayer = UnitIsTappedByPlayer
local UnitReaction = UnitReaction
local UnitClassification = UnitClassification
local UnitCreatureType = UnitCreatureType
local UnitIsPVP = UnitIsPVP
local UnitHasVehicleUI = UnitHasVehicleUI
local GetNumPartyMembers = GetNumPartyMembers
local GetNumRaidMembers = GetNumRaidMembers
local UnitIsUnit = UnitIsUnit
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local GetItemCount = GetItemCount
local UnitAura = UnitAura
local SetTooltipMoney = SetTooltipMoney
local GameTooltip_ClearMoney = GameTooltip_ClearMoney
local TARGET = TARGET
local DEAD = DEAD
local FOREIGN_SERVER_LABEL = FOREIGN_SERVER_LABEL
local PVP = PVP
local FACTION_ALLIANCE = FACTION_ALLIANCE
local FACTION_HORDE = FACTION_HORDE
local LEVEL = LEVEL
local FACTION_BAR_COLORS = FACTION_BAR_COLORS
local ID = ID

local GameTooltip, GameTooltipStatusBar = GameTooltip, GameTooltipStatusBar
local targetList, inspectCache = {}, {}
local TAPPED_COLOR = {r=.6, g=.6, b=.6}
local AFK_LABEL = " |cffFFFFFF[|r|cffE7E716"..L["AFK"].."|r|cffFFFFFF]|r"
local DND_LABEL = " |cffFFFFFF[|r|cffFF0000"..L["DND"].."|r|cffFFFFFF]|r"
local keybindFrame

local classification = {
	worldboss = format("|cffAF5050 %s|r", BOSS),
	rareelite = format("|cffAF5050+ %s|r", ITEM_QUALITY3_DESC),
	elite = "|cffAF5050+|r",
	rare = format("|cffAF5050 %s|r", ITEM_QUALITY3_DESC)
}

local inventorySlots = {
	"HeadSlot", "NeckSlot", "ShoulderSlot", "BackSlot", "ChestSlot", "WristSlot",
	"HandsSlot", "WaistSlot", "LegsSlot", "FeetSlot", "Finger0Slot", "Finger1Slot",
	"Trinket0Slot", "Trinket1Slot", "MainHandSlot", "SecondaryHandSlot", "RangedSlot"
}

local updateUnitModifiers = {
	["LSHIFT"] = true,
	["RSHIFT"] = true,
	["LCTRL"] = true,
	["RCTRL"] = true,
	["LALT"] = true,
	["RALT"] = true,
}

function TT:GameTooltip_SetDefaultAnchor(tt, parent)
	if not E.private.tooltip.enable then return end
	if not self.db.visibility then return end

	if tt:GetAnchorType() ~= "ANCHOR_NONE" then return end
	if InCombatLockdown() and self.db.visibility.combat then
		local modifier = self.db.visibility.combatOverride
		if (not(
				(modifier == "SHIFT" and IsShiftKeyDown())
				or
				(modifier == "CTRL" and IsControlKeyDown())
				or
				(modifier == "ALT" and IsAltKeyDown())
		)) then
			tt:Hide()
			return
		end
	end

	local ownerName = tt:GetOwner() and tt:GetOwner().GetName and tt:GetOwner():GetName()
	if self.db.visibility.actionbars ~= "NONE" and ownerName and (find(ownerName, "ElvUI_Bar") or find(ownerName, "ElvUI_StanceBar") or find(ownerName, "PetAction")) and not keybindFrame.active then
		local modifier = self.db.visibility.actionbars

		if modifier == "ALL" or not ((modifier == "SHIFT" and IsShiftKeyDown()) or (modifier == "CTRL" and IsControlKeyDown()) or (modifier == "ALT" and IsAltKeyDown())) then
			tt:Hide()
			return
		end
	end

	if tt.StatusBar then
		if self.db.healthBar.statusPosition == "BOTTOM" then
			if tt.StatusBar.anchoredToTop then
				tt.StatusBar:ClearAllPoints()
				tt.StatusBar:Point("TOPLEFT", tt, "BOTTOMLEFT", E.Border, -(E.Spacing * 3))
				tt.StatusBar:Point("TOPRIGHT", tt, "BOTTOMRIGHT", -E.Border, -(E.Spacing * 3))
				tt.StatusBar.text:Point("CENTER", tt.StatusBar, 0, 0)
				tt.StatusBar.anchoredToTop = nil
			end
		else
			if not tt.StatusBar.anchoredToTop then
				tt.StatusBar:ClearAllPoints()
				tt.StatusBar:Point("BOTTOMLEFT", tt, "TOPLEFT", E.Border, (E.Spacing * 3))
				tt.StatusBar:Point("BOTTOMRIGHT", tt, "TOPRIGHT", -E.Border, (E.Spacing * 3))
				tt.StatusBar.text:Point("CENTER", tt.StatusBar, 0, 0)
				tt.StatusBar.anchoredToTop = true
			end
		end
	end

	if parent then
		if self.db.cursorAnchor then
			tt:SetOwner(parent, self.db.cursorAnchorType, self.db.cursorAnchorX, self.db.cursorAnchorY)
			return
		else
			tt:SetOwner(parent, "ANCHOR_NONE")
		end
	end

	local _, anchor = tt:GetPoint()

	if anchor == nil or (ElvUI_ContainerFrame and anchor == ElvUI_ContainerFrame) or anchor == RightChatPanel or anchor == ElvTooltipMover or anchor == _G.UIParent or anchor == E.UIParent then
		tt:ClearAllPoints()
		if not E:HasMoverBeenMoved("ElvTooltipMover") then
			if ElvUI_ContainerFrame and ElvUI_ContainerFrame:IsShown() then
				tt:Point("BOTTOMRIGHT", ElvUI_ContainerFrame, "TOPRIGHT", 0, 18)
			elseif RightChatPanel:GetAlpha() == 1 and RightChatPanel:IsShown() then
				tt:Point("BOTTOMRIGHT", RightChatPanel, "TOPRIGHT", 0, 18)
			else
				tt:Point("BOTTOMRIGHT", RightChatPanel, "BOTTOMRIGHT", 0, 18)
			end
		else
			local point = E:GetScreenQuadrant(ElvTooltipMover)
			if point == "TOPLEFT" then
				tt:Point("TOPLEFT", ElvTooltipMover, "BOTTOMLEFT")
			elseif point == "TOPRIGHT" then
				tt:Point("TOPRIGHT", ElvTooltipMover, "BOTTOMRIGHT")
			elseif point == "BOTTOMLEFT" or point == "LEFT" then
				tt:Point("BOTTOMLEFT", ElvTooltipMover, "TOPLEFT")
			else
				tt:Point("BOTTOMRIGHT", ElvTooltipMover, "TOPRIGHT")
			end
		end
	end
end

function TT:GetItemLvL(unit)
	local total, items = 0, 0
	for i = 1, #inventorySlots do
		local itemLink = GetInventoryItemLink(unit, GetInventorySlotInfo(inventorySlots[i]))

		if itemLink then
			local iLvl = select(4, GetItemInfo(itemLink))
			if iLvl and iLvl > 0 then
				items = items + 1
				total = total + iLvl
			end
		end
	end

	if items == 0 then
		return 0
	end

	return E:Round(total / items, 2)
end

function TT:RemoveTrashLines(tt)
	for i = 3, tt:NumLines() do
		local tiptext = _G["GameTooltipTextLeft"..i]
		local linetext = tiptext:GetText()

		if linetext == PVP or linetext == FACTION_ALLIANCE or linetext == FACTION_HORDE then
			tiptext:SetText(nil)
--			tiptext:Hide()
		end
	end
end

function TT:GetLevelLine(tt, offset)
	for i = offset, tt:NumLines() do
		local tipText = _G["GameTooltipTextLeft"..i]
		if tipText:GetText() and find(tipText:GetText(), LEVEL) then
			return tipText
		end
	end
end

function TT:SetUnitText(tt, unit, level, isShiftKeyDown)
	local color
	if UnitIsPlayer(unit) then
		local localeClass, class = UnitClass(unit)
		if not localeClass or not class then return end

		local name, realm = UnitName(unit)
		local guildName, guildRankName = GetGuildInfo(unit)
		local pvpName = UnitPVPName(unit)

		color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]

		if not color then
			color = RAID_CLASS_COLORS.PRIEST
		end

		if self.db.playerTitles and pvpName then
			name = pvpName
		end

		if realm and realm ~= "" then
			if isShiftKeyDown or self.db.alwaysShowRealm then
				name = name.."-"..realm
			else
				name = name..FOREIGN_SERVER_LABEL
			end
		end

		if UnitIsAFK(unit) then
			name = name..AFK_LABEL
		elseif UnitIsDND(unit) then
			name = name..DND_LABEL
		end

		GameTooltipTextLeft1:SetFormattedText("%s%s", E:RGBToHex(color.r, color.g, color.b), name)

		local lineOffset = 2
		if guildName then
			if self.db.guildRanks then
				GameTooltipTextLeft2:SetFormattedText("<|cff00ff10%s|r> [|cff00ff10%s|r]", guildName, guildRankName)
			else
				GameTooltipTextLeft2:SetFormattedText("<|cff00ff10%s|r>", guildName)
			end

			lineOffset = 3
		end

		local levelLine = self:GetLevelLine(tt, lineOffset)
		if levelLine then
			local diffColor = GetQuestDifficultyColor(level)
			local race = UnitRace(unit)
			levelLine:SetFormattedText("|cff%02x%02x%02x%s|r %s %s%s|r", diffColor.r * 255, diffColor.g * 255, diffColor.b * 255, level > 0 and level or "??", race or "", E:RGBToHex(color.r, color.g, color.b), localeClass)
		end
	else
		if UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) then
			color = TAPPED_COLOR
		else
			local unitReaction = UnitReaction(unit, "player")
			if E.db.tooltip.useCustomFactionColors then
				if unitReaction then
					color = E.db.tooltip.factionColors[unitReaction]
				end
			else
				color = FACTION_BAR_COLORS[unitReaction]
			end
		end

		if not color then
			color = RAID_CLASS_COLORS.PRIEST
		end

		local levelLine = self:GetLevelLine(tt, 2)
		if levelLine then
			local creatureClassification = UnitClassification(unit)
			local creatureType = UnitCreatureType(unit)
			local pvpFlag = ""
			local diffColor = GetQuestDifficultyColor(level)

			if UnitIsPVP(unit) then
				pvpFlag = format(" (%s)", PVP)
			end

			levelLine:SetFormattedText("|cff%02x%02x%02x%s|r%s %s%s", diffColor.r * 255, diffColor.g * 255, diffColor.b * 255, level > 0 and level or "??", classification[creatureClassification] or "", creatureType or "", pvpFlag)
		end
	end

	return color
end

function TT:INSPECT_TALENT_READY(event, unit)
	if not unit then
		if self.lastGUID ~= UnitGUID("mouseover") then return end

		self:UnregisterEvent(event)

		unit = "mouseover"
		if not UnitExists(unit) then return end
	end

	local itemLevel = self:GetItemLvL(unit)
	local _, specName = E:GetTalentSpecInfo(true)
	inspectCache[self.lastGUID] = {time = GetTime()}

	if specName then
		inspectCache[self.lastGUID].specName = specName
	end

	if itemLevel then
		inspectCache[self.lastGUID].itemLevel = itemLevel
	end

	GameTooltip:SetUnit(unit)
end

function TT:ShowInspectInfo(tt, unit, r, g, b)
	local canInspect = CanInspect(unit)
	if not canInspect then return end

	local GUID = UnitGUID(unit)
	if GUID == E.myguid then
		local _, specName = E:GetTalentSpecInfo()

		tt:AddDoubleLine(L["Talent Specialization:"], specName, nil, nil, nil, r, g, b)
		tt:AddDoubleLine(L["Item Level:"], self:GetItemLvL("player"), nil, nil, nil, 1, 1, 1)
		return
	elseif inspectCache[GUID] then
		local specName = inspectCache[GUID].specName
		local itemLevel = inspectCache[GUID].itemLevel

		if (GetTime() - inspectCache[GUID].time) < 900 and specName and itemLevel then
			tt:AddDoubleLine(L["Talent Specialization:"], specName, nil, nil, nil, r, g, b)
			tt:AddDoubleLine(L["Item Level:"], itemLevel, nil, nil, nil, 1, 1, 1)
			return
		else
			inspectCache[GUID] = nil
		end
	end

	if InspectFrame and InspectFrame.unit then
		if UnitIsUnit(InspectFrame.unit, unit) then
			self.lastGUID = GUID
			self:INSPECT_TALENT_READY(nil, unit)
		end
	else
		self.lastGUID = GUID
		NotifyInspect(unit)
		self:RegisterEvent("INSPECT_TALENT_READY")
	end
end

function TT:GameTooltip_OnTooltipSetUnit(tt)
	local isShiftKeyDown = IsShiftKeyDown()
	local isControlKeyDown = IsControlKeyDown()

	if tt:GetOwner() ~= UIParent and (self.db.visibility and self.db.visibility.unitFrames ~= "NONE") then
		local modifier = self.db.visibility.unitFrames

		if modifier == "ALL" or not ((modifier == "SHIFT" and isShiftKeyDown) or (modifier == "CTRL" and isControlKeyDown) or (modifier == "ALT" and IsAltKeyDown())) then
			tt:Hide()
			return
		end
	end

	local _, unit = tt:GetUnit()

	if not unit then
		local GMF = GetMouseFocus()
		if GMF and GMF:GetAttribute("unit") then
			unit = GMF:GetAttribute("unit")
		end

		if not unit or not UnitExists(unit) then return end
	end

	self:RemoveTrashLines(tt)

	if not isShiftKeyDown and not isControlKeyDown and self.db.targetInfo then
		local unitTarget = unit.."target"
		if unit ~= "player" and UnitExists(unitTarget) then
			local targetColor
			if UnitIsPlayer(unitTarget) and not UnitHasVehicleUI(unitTarget) then
				local _, class = UnitClass(unitTarget)
				targetColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
			else
				targetColor = E.db.tooltip.useCustomFactionColors and E.db.tooltip.factionColors[UnitReaction(unitTarget, "player")] or FACTION_BAR_COLORS[UnitReaction(unitTarget, "player")]
			end

			if not targetColor then
				targetColor = RAID_CLASS_COLORS.PRIEST
			end

			tt:AddDoubleLine(format("%s:", TARGET), format("|cff%02x%02x%02x%s|r", targetColor.r * 255, targetColor.g * 255, targetColor.b * 255, UnitName(unitTarget)))
		end

		local numParty = GetNumPartyMembers()
		local numRaid = GetNumRaidMembers()
		local inRaid = numRaid > 0

		if inRaid or numParty > 0 then
			for i = 1, (inRaid and numRaid or numParty) do
				local groupUnit = (inRaid and "raid"..i or "party"..i)

				if not UnitIsUnit(groupUnit, "player") and UnitIsUnit(groupUnit.."target", unit) then
					local _, class = UnitClass(groupUnit)
					local classColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]

					if not classColor then
						classColor = RAID_CLASS_COLORS.PRIEST
					end

					tinsert(targetList, format("%s%s", E:RGBToHex(classColor.r, classColor.g, classColor.b), UnitName(groupUnit)))
				end
			end

			local numList = #targetList
			if numList > 0 then
				tt:AddLine(format("%s (|cffffffff%d|r): %s", L["Targeted By:"], numList, tconcat(targetList, ", ")), nil, nil, nil, 1)
				twipe(targetList)
			end
		end
	end

	local isPlayerUnit = UnitIsPlayer(unit)
	local color = self:SetUnitText(tt, unit, UnitLevel(unit), isShiftKeyDown)

	if isShiftKeyDown and isPlayerUnit then
		self:ShowInspectInfo(tt, unit, color.r, color.g, color.b)
	end

	if unit and self.db.npcID and not isPlayerUnit then
		local guid = UnitGUID(unit)
		if guid then
			local id = tonumber(sub(guid, 8, 12), 16)
			if id then
				tt:AddLine(format("|cFFCA3C3C%s|r %d", ID, id))
			end
		end
	end

	if color then
		tt.StatusBar:SetStatusBarColor(color.r, color.g, color.b)
	else
		tt.StatusBar:SetStatusBarColor(0.6, 0.6, 0.6)
	end

	local textWidth = tt.StatusBar.text:GetStringWidth()
	if textWidth then
		tt:SetMinimumWidth(textWidth)
	end
end

function TT:GameTooltipStatusBar_OnValueChanged(tt, value)
	if not value or not tt.text or not self.db.healthBar.text then return end

	local _, unit = tt:GetParent():GetUnit()

	if not unit then
		local GMF = GetMouseFocus()
		if GMF and GMF:GetAttribute("unit") then
			unit = GMF:GetAttribute("unit")
		end
	end

	local _, max = tt:GetMinMaxValues()
	if value > 0 and max == 1 then
		tt.text:SetFormattedText("%d%%", floor(value * 100))
		tt:SetStatusBarColor(TAPPED_COLOR.r, TAPPED_COLOR.g, TAPPED_COLOR.b)
	elseif value == 0 or (unit and UnitIsDeadOrGhost(unit)) then
		tt.text:SetText(DEAD)
	else
		tt.text:SetText(E:ShortValue(value).." / "..E:ShortValue(max))
	end
end

function TT:GameTooltip_OnTooltipCleared(tt)
	tt.itemCleared = nil
end

function TT:GameTooltip_OnTooltipSetItem(tt)
	if self.db.visibility and self.db.visibility.bags ~= "NONE" then
		local ownerName = tt:GetOwner() and tt:GetOwner().GetName and tt:GetOwner():GetName()

		if ownerName and (find(ownerName, "ElvUI_Container") or find(ownerName, "ElvUI_BankContainer")) then
			local modifier = self.db.visibility.bags

			if modifier == "ALL" or not ((modifier == "SHIFT" and IsShiftKeyDown()) or (modifier == "CTRL" and IsControlKeyDown()) or (modifier == "ALT" and IsAltKeyDown())) then
				tt.itemCleared = true
				tt:Hide()
				return
			end
		end
	end

	if tt.itemCleared then return end

	local _, link = tt:GetItem()
	if not link then return end

	local num = GetItemCount(link)
	local numall = GetItemCount(link, true)
	local left, right, bankCount

	if self.db.spellID then
		left = format("|cFFCA3C3C%s|r %d", ID, tonumber(match(link, ":(%d+)")))
	end

	if self.db.itemCount == "BAGS_ONLY" then
		right = format("|cFFCA3C3C%s|r %d", L["Count"], num)
	elseif self.db.itemCount == "BANK_ONLY" then
		bankCount = format("|cFFCA3C3C%s|r %d", L["Bank"], (numall - num))
	elseif self.db.itemCount == "BOTH" then
		right = format("|cFFCA3C3C%s|r %d", L["Count"], num)
		bankCount = format("|cFFCA3C3C%s|r %d", L["Bank"], (numall - num))
	end

	if left or right then
		tt:AddLine(" ")
		tt:AddDoubleLine(left or " ", right or " ")
	end
	if bankCount then
		tt:AddDoubleLine(" ", bankCount)
	end

	tt.itemCleared = true
end

function TT:GameTooltip_ShowStatusBar(tt)
	local sb = _G[tt:GetName().."StatusBar"..tt.shownStatusBars]
	if not sb or sb.backdrop then return end

	sb:StripTextures()
	sb:CreateBackdrop(nil, nil, true)
	sb:SetStatusBarTexture(E.media.normTex)
end

function TT:CheckBackdropColor(tt)
	if tt:GetAnchorType() == "ANCHOR_CURSOR" then
		local r, g, b = unpack(E.media.backdropfadecolor, 1, 3)
		tt:SetBackdropColor(r, g, b, self.db.colorAlpha)
	end
end

function TT:SetStyle(tt)
	if not tt.template then
		tt:SetTemplate("Transparent")
	else
		tt:SetBackdropBorderColor(unpack(E.media.bordercolor, 1, 3))
	end

	local r, g, b = unpack(E.media.backdropfadecolor, 1, 3)
	tt:SetBackdropColor(r, g, b, self.db.colorAlpha)
end

function TT:MODIFIER_STATE_CHANGED(_, key)
	if updateUnitModifiers[key] then
		local owner = GameTooltip:GetOwner()
		local notOnAuras = not (owner and owner.UpdateTooltip)
		if notOnAuras and UnitExists("mouseover") then
			GameTooltip:SetUnit("mouseover")
		end
	end
end

function TT:SetUnitAura(tt, ...)
	local caster, _, _, id = select(8, UnitAura(...))
	if id and self.db.spellID then
		if caster then
			local name = UnitName(caster)
			local _, class = UnitClass(caster)
			local color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
			tt:AddDoubleLine(format("|cFFCA3C3C%s|r %d", ID, id), format("%s%s", E:RGBToHex(color.r, color.g, color.b), name))
		else
			tt:AddLine(format("|cFFCA3C3C%s|r %d", ID, id))
		end

		tt:Show()
	end
end

function TT:GameTooltip_OnTooltipSetSpell(tt)
	local id = select(3, tt:GetSpell())
	if not id or not self.db.spellID then return end

	local displayString = format("|cFFCA3C3C%s|r %d", ID, id)

	for i = 1, tt:NumLines() do
		local line = _G[format("GameTooltipTextLeft%d", i)]
		if line and line:GetText() and find(line:GetText(), displayString) then
			return
		end
	end

	tt:AddLine(displayString)
	tt:Show()
end

function TT:SetHyperlink(refTooltip, link)
	if self.db.spellID and (find(link, "^spell:") or find(link, "^item:")) then
		refTooltip:AddLine(format("|cFFCA3C3C%s|r %d", ID, tonumber(match(link, "(%d+)"))))
		refTooltip:Show()
	end
end

function TT:SetTooltipFonts()
	local font = E.Libs.LSM:Fetch("font", E.db.tooltip.font)
	local fontOutline = E.db.tooltip.fontOutline
	local headerSize = E.db.tooltip.headerFontSize
	local textSize = E.db.tooltip.textFontSize
	local smallTextSize = E.db.tooltip.smallTextFontSize

	GameTooltipHeaderText:FontTemplate(font, headerSize, fontOutline)
	GameTooltipText:FontTemplate(font, textSize, fontOutline)
	GameTooltipTextSmall:FontTemplate(font, smallTextSize, fontOutline)
	if GameTooltip.hasMoney then
		for i = 1, GameTooltip.numMoneyFrames do
			_G["GameTooltipMoneyFrame"..i.."PrefixText"]:FontTemplate(font, textSize, fontOutline)
			_G["GameTooltipMoneyFrame"..i.."SuffixText"]:FontTemplate(font, textSize, fontOutline)
			_G["GameTooltipMoneyFrame"..i.."GoldButtonText"]:FontTemplate(font, textSize, fontOutline)
			_G["GameTooltipMoneyFrame"..i.."SilverButtonText"]:FontTemplate(font, textSize, fontOutline)
			_G["GameTooltipMoneyFrame"..i.."CopperButtonText"]:FontTemplate(font, textSize, fontOutline)
		end
	end

	-- Ignore header font size on DatatextTooltip
	if DatatextTooltip then
		DatatextTooltipTextLeft1:FontTemplate(font, textSize, fontOutline)
		DatatextTooltipTextRight1:FontTemplate(font, textSize, fontOutline)
	end

	--These show when you compare items ("Currently Equipped", name of item, item level)
	--Since they appear at the top of the tooltip, we set it to use the header font size.
	for i = 1, 2 do
		for j = 1, 4 do
			_G["ShoppingTooltip"..i.."TextLeft"..j]:FontTemplate(font, headerSize, fontOutline)
			_G["ShoppingTooltip"..i.."TextRight"..j]:FontTemplate(font, headerSize, fontOutline)
		end
	end
end

--This changes the growth direction of the toast frame depending on position of the mover
local function PostBNToastMove(mover)
	local x, y = mover:GetCenter()
	local screenHeight = E.UIParent:GetTop()
	local screenWidth = E.UIParent:GetRight()

	local anchorPoint
	if y > (screenHeight / 2) then
		anchorPoint = (x > (screenWidth / 2)) and "TOPRIGHT" or "TOPLEFT"
	else
		anchorPoint = (x > (screenWidth / 2)) and "BOTTOMRIGHT" or "BOTTOMLEFT"
	end
	mover.anchorPoint = anchorPoint

	BNToastFrame:ClearAllPoints()
	BNToastFrame:Point(anchorPoint, mover)
end

function TT:RepositionBNET(frame, _, anchor)
	if anchor ~= BNETMover then
		frame:ClearAllPoints()
		frame:Point("TOPLEFT", BNETMover, "TOPLEFT")
	end
end

function TT:Initialize()
	self.db = E.db.tooltip

	BNToastFrame:Point("TOPRIGHT", MMHolder, "BOTTOMRIGHT", 0, -10)
	E:CreateMover(BNToastFrame, "BNETMover", L["BNet Frame"], nil, nil, PostBNToastMove)
	self:SecureHook(BNToastFrame, "SetPoint", "RepositionBNET")

	if not E.private.tooltip.enable then return end

	SetCVar("showItemLevel", 1)

	GameTooltip.StatusBar = GameTooltipStatusBar
	GameTooltip.StatusBar:Height(self.db.healthBar.height)
	GameTooltip.StatusBar:SetScript("OnValueChanged", nil)
	GameTooltip.StatusBar.text = GameTooltip.StatusBar:CreateFontString(nil, "OVERLAY")
	GameTooltip.StatusBar.text:SetPoint("CENTER")
	GameTooltip.StatusBar.text:FontTemplate(E.Libs.LSM:Fetch("font", self.db.healthBar.font), self.db.healthBar.fontSize, self.db.healthBar.fontOutline)

	--Tooltip Fonts
	if not GameTooltip.hasMoney then
		--Force creation of the money lines, so we can set font for it
		SetTooltipMoney(GameTooltip, 1, nil, "", "")
		SetTooltipMoney(GameTooltip, 1, nil, "", "")
		GameTooltip_ClearMoney(GameTooltip)
	end
	self:SetTooltipFonts()

	local GameTooltipAnchor = CreateFrame("Frame", "GameTooltipAnchor", E.UIParent)
	GameTooltipAnchor:Point("BOTTOMRIGHT", RightChatToggleButton, "BOTTOMRIGHT")
	GameTooltipAnchor:Size(130, 20)
	GameTooltipAnchor:SetFrameLevel(GameTooltipAnchor:GetFrameLevel() + 400)
	E:CreateMover(GameTooltipAnchor, "ElvTooltipMover", L["Tooltip"], nil, nil, nil, nil, nil, "tooltip,general")

	self:SecureHook(ItemRefTooltip, "SetHyperlink")
	self:SecureHook("GameTooltip_SetDefaultAnchor")
	self:SecureHook(GameTooltip, "SetUnitAura")
	self:SecureHook(GameTooltip, "SetUnitBuff", "SetUnitAura")
	self:SecureHook(GameTooltip, "SetUnitDebuff", "SetUnitAura")
	self:HookScript(GameTooltip, "OnTooltipSetSpell", "GameTooltip_OnTooltipSetSpell")
	self:HookScript(GameTooltip, "OnTooltipCleared", "GameTooltip_OnTooltipCleared")
	self:HookScript(GameTooltip, "OnTooltipSetItem", "GameTooltip_OnTooltipSetItem")
	self:HookScript(GameTooltip, "OnTooltipSetUnit", "GameTooltip_OnTooltipSetUnit")
	self:HookScript(GameTooltip.StatusBar, "OnValueChanged", "GameTooltipStatusBar_OnValueChanged")
	self:RegisterEvent("MODIFIER_STATE_CHANGED")

	--Variable is localized at top of file, then set here when we're sure the frame has been created
	--Used to check if keybinding is active, if so then don"t hide tooltips on actionbars
	keybindFrame = ElvUI_KeyBinder

	self.Initialized = true
end

local function InitializeCallback()
	TT:Initialize()
end

E:RegisterModule(TT:GetName(), InitializeCallback)