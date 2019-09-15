local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local A = E:GetModule("Auras")
local LSM = E.Libs.LSM
local LBF = E.Libs.LBF

--Lua functions
local _G = _G
local unpack, pairs, ipairs, next, type = unpack, pairs, ipairs, next, type
local floor, min, max, huge = math.floor, math.min, math.max, math.huge
local format = string.format
local wipe, tinsert, tsort, tremove = table.wipe, table.insert, table.sort, table.remove
--WoW API / Variables
local CreateFrame = CreateFrame
local GetTime = GetTime
local UnitAura = UnitAura
local CancelItemTempEnchantment = CancelItemTempEnchantment
local CancelUnitBuff = CancelUnitBuff
local GetInventoryItemQuality = GetInventoryItemQuality
local GetItemQualityColor = GetItemQualityColor
local GetWeaponEnchantInfo = GetWeaponEnchantInfo
local GetInventoryItemTexture = GetInventoryItemTexture
local DebuffTypeColor = DebuffTypeColor

local DIRECTION_TO_POINT = {
	DOWN_RIGHT = "TOPLEFT",
	DOWN_LEFT = "TOPRIGHT",
	UP_RIGHT = "BOTTOMLEFT",
	UP_LEFT = "BOTTOMRIGHT",
	RIGHT_DOWN = "TOPLEFT",
	RIGHT_UP = "BOTTOMLEFT",
	LEFT_DOWN = "TOPRIGHT",
	LEFT_UP = "BOTTOMRIGHT"
}

local DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER = {
	DOWN_RIGHT = 1,
	DOWN_LEFT = -1,
	UP_RIGHT = 1,
	UP_LEFT = -1,
	RIGHT_DOWN = 1,
	RIGHT_UP = 1,
	LEFT_DOWN = -1,
	LEFT_UP = -1
}

local DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER = {
	DOWN_RIGHT = -1,
	DOWN_LEFT = -1,
	UP_RIGHT = 1,
	UP_LEFT = 1,
	RIGHT_DOWN = -1,
	RIGHT_UP = 1,
	LEFT_DOWN = -1,
	LEFT_UP = 1
}

local IS_HORIZONTAL_GROWTH = {
	RIGHT_DOWN = true,
	RIGHT_UP = true,
	LEFT_DOWN = true,
	LEFT_UP = true
}

local enchantableSlots = {
  [1] = 16,
  [2] = 17
}

local weaponEnchantTime = {}
A.EnchanData = weaponEnchantTime

function A:UpdateTime(elapsed)
	if self.IsWeapon then
		local expiration = weaponEnchantTime[self:GetID()]
		if expiration then
			self.timeLeft = expiration / 1e3
		else
			self.timeLeft = 0
		end
	else
		self.timeLeft = self.timeLeft - elapsed
	end

	if self.nextUpdate > 0 then
		self.nextUpdate = self.nextUpdate - elapsed
		return
	end

	if not E:Cooldown_IsEnabled(self) then
		self.timeLeft = nil
		self.time:SetText("")
		self:SetScript("OnUpdate", nil)
	else
		local timeColors, timeThreshold = (self.timerOptions and self.timerOptions.timeColors) or E.TimeColors, (self.timerOptions and self.timerOptions.timeThreshold) or E.db.cooldown.threshold
		if not timeThreshold then timeThreshold = E.TimeThreshold end

		local hhmmThreshold = (self.timerOptions and self.timerOptions.hhmmThreshold) or (E.db.cooldown.checkSeconds and E.db.cooldown.hhmmThreshold)
		local mmssThreshold = (self.timerOptions and self.timerOptions.mmssThreshold) or (E.db.cooldown.checkSeconds and E.db.cooldown.mmssThreshold)

		local value1, formatID, nextUpdate, value2 = E:GetTimeInfo(self.timeLeft, timeThreshold, hhmmThreshold, mmssThreshold)
		self.nextUpdate = nextUpdate
		self.time:SetFormattedText(format("%s%s|r", timeColors[formatID], E.TimeFormats[formatID][1]), value1, value2)

		if self.timeLeft > E.db.auras.fadeThreshold then
			E:StopFlash(self)
		else
			E:Flash(self, 1)
		end
	end
end

local UpdateTooltip = function(self)
	if self.IsWeapon then
		GameTooltip:SetInventoryItem("player", enchantableSlots[self:GetID()])
	else
		GameTooltip:SetUnitAura("player", self:GetID(), self:GetParent().filter)
	end
end

local OnEnter = function(self)
	if not self:IsVisible() then return end

	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", -5, -5)
	self:UpdateTooltip()
end

local OnLeave = function()
	GameTooltip:Hide()
end

local OnClick = function(self)
	if self.IsWeapon then
		CancelItemTempEnchantment(self:GetID())
	else
		CancelUnitBuff("player", self:GetID(), self:GetParent().filter)
	end
end

function A:CreateIcon(button)
	local font = LSM:Fetch("font", self.db.font)
	local auraType = button:GetParent().filter

	local db = self.db.debuffs
	button.auraType = "debuffs" -- used to update cooldown text
	if auraType == "HELPFUL" then
		db = self.db.buffs
		button.auraType = "buffs"
	end

	button:RegisterForClicks("RightButtonUp")

	button.texture = button:CreateTexture(nil, "BORDER")
	button.texture:SetInside()
	button.texture:SetTexCoord(unpack(E.TexCoords))

	button.count = button:CreateFontString(nil, "ARTWORK")
	button.count:Point("BOTTOMRIGHT", -1 + self.db.countXOffset, 1 + self.db.countYOffset)
	button.count:FontTemplate(font, db.countFontSize, self.db.fontOutline)

	button.time = button:CreateFontString(nil, "ARTWORK")
	button.time:Point("TOP", button, "BOTTOM", 1 + self.db.timeXOffset, 0 + self.db.timeYOffset)

	button.highlight = button:CreateTexture(nil, "HIGHLIGHT")
	button.highlight:SetTexture(1, 1, 1, 0.45)
	button.highlight:SetInside()

	E:SetUpAnimGroup(button)

	-- fetch cooldown settings
	A:CooldownText_Update(button)

	-- support cooldown override
	if not button.isRegisteredCooldown then
		button.CooldownOverride = "auras"
		button.isRegisteredCooldown = true

		if not E.RegisteredCooldowns.auras then E.RegisteredCooldowns.auras = {} end
		tinsert(E.RegisteredCooldowns.auras, button)
	end

	if button.timerOptions and button.timerOptions.fontOptions and button.timerOptions.fontOptions.enable then
		button.time:FontTemplate(LSM:Fetch("font", button.timerOptions.fontOptions.font), button.timerOptions.fontOptions.fontSize, button.timerOptions.fontOptions.fontOutline)
	else
		button.time:FontTemplate(font, db.durationFontSize, self.db.fontOutline)
	end

	button.UpdateTooltip = UpdateTooltip
	button:SetScript("OnEnter", OnEnter)
	button:SetScript("OnLeave", OnLeave)
	button:SetScript("OnClick", OnClick)

	if self.LBFGroup and E.private.auras.lbf.enable then
		local ButtonData = {
			Icon = button.texture,
			Flash = nil,
			Cooldown = nil,
			AutoCast = nil,
			AutoCastable = nil,
			HotKey = nil,
			Count = false,
			Name = nil,
			Highlight = button.highlight
		}

		self.LBFGroup:AddButton(button, ButtonData)
	else
		button:SetTemplate("Default")
	end
end

function A:CooldownText_Update(button)
	if not button then return end

	-- cooldown override settings
	button.forceEnabled = true

	if not button.timerOptions then
		button.timerOptions = {}
	end

	button.timerOptions.reverseToggle = self.db.cooldown.reverse
	button.timerOptions.hideBlizzard = self.db.cooldown.hideBlizzard

	if self.db.cooldown.override and E.TimeColors.auras then
		button.timerOptions.timeColors, button.timerOptions.timeThreshold = E.TimeColors.auras, self.db.cooldown.thresholdd
	else
		button.timerOptions.timeColors, button.timerOptions.timeThreshold = nil, nil
	end

	if self.db.cooldown.checkSeconds then
		button.timerOptions.hhmmThreshold, button.timerOptions.mmssThreshold = self.db.cooldown.hhmmThreshold, self.db.cooldown.mmssThreshold
	else
		button.timerOptions.hhmmThreshold, button.timerOptions.mmssThreshold = nil, nil
	end

	if self.db.cooldown.fonts and self.db.cooldown.fonts.enable then
		button.timerOptions.fontOptions = self.db.cooldown.fonts
	elseif E.db.cooldown.fonts and E.db.cooldown.fonts.enable then
		button.timerOptions.fontOptions = E.db.cooldown.fonts
	else
		button.timerOptions.fontOptions = nil
	end
end

function A:HasEnchant(index, weapon, expiration)
	if not weapon then
		if weaponEnchantTime[index] then
			weaponEnchantTime[index] = nil
			return true
		end
		return
	end

	if not weaponEnchantTime[index] or weaponEnchantTime[index] < expiration then
		weaponEnchantTime[index] = expiration
		return true
	end

	weaponEnchantTime[index] = expiration
end

local buttons = {}
function A:ConfigureAuras(header, auraTable, weaponPosition)
	local headerName = header:GetName()
	local db = self.db.debuffs
	if header.filter == "HELPFUL" then
		db = self.db.buffs
	end

	local xOffset, yOffset, wrapXOffset, wrapYOffset, minWidth, minHeight
	local size = db.size
	local point = DIRECTION_TO_POINT[db.growthDirection]
	local wrapAfter = db.wrapAfter
	local maxWraps = db.maxWraps

	if IS_HORIZONTAL_GROWTH[db.growthDirection] then
		minWidth = ((wrapAfter == 1 and 0 or db.horizontalSpacing) + size) * wrapAfter
		minHeight = (db.verticalSpacing + size) * maxWraps
		xOffset = DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER[db.growthDirection] * (db.horizontalSpacing + size)
		yOffset = 0
		wrapXOffset = 0
		wrapYOffset = DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[db.growthDirection] * (db.verticalSpacing + size)
	else
		minWidth = (db.horizontalSpacing + size) * maxWraps
		minHeight = ((wrapAfter == 1 and 0 or db.verticalSpacing) + size) * wrapAfter
		xOffset = 0
		yOffset = DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[db.growthDirection] * (db.verticalSpacing + size)
		wrapXOffset = DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER[db.growthDirection] * (db.horizontalSpacing + size)
		wrapYOffset = 0
	end

	wipe(buttons)
	local button
	for i = 1, #auraTable do
		button = _G[headerName.."AuraButton"..i]
		if button then
			if button:IsShown() then button:Hide() end
		else
			button = CreateFrame("Button", "$parentAuraButton"..i, header)
			self:CreateIcon(button)
		end
		local buffInfo = auraTable[i]
		button:SetID(buffInfo.index)

		if buffInfo.duration > 0 and buffInfo.expires then
			local timeLeft = buffInfo.expires - GetTime()
			if not button.timeLeft then
				button.timeLeft = timeLeft
				button:SetScript("OnUpdate", self.UpdateTime)
			else
				button.timeLeft = timeLeft
			end

			button.nextUpdate = -1
			self.UpdateTime(button, 0)
		else
			button.timeLeft = nil
			button.time:SetText("")
			button:SetScript("OnUpdate", nil)
		end

		if buffInfo.count > 1 then
			button.count:SetText(buffInfo.count)
		else
			button.count:SetText("")
		end

		if buffInfo.filter == "HARMFUL" then
			local color = DebuffTypeColor[buffInfo.dispelType or ""]
			button:SetBackdropBorderColor(color.r, color.g, color.b)
		else
			button:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end

		button.texture:SetTexture(buffInfo.icon)

		buttons[i] = button
	end

	if weaponPosition then
		for weapon = 2, 1, -1 do
			button = _G["ElvUIPlayerBuffsTempEnchant"..weapon]
			if weaponEnchantTime[weapon] then
				if not button then
					button = CreateFrame("Button", "$parentTempEnchant"..weapon, header)
					button.IsWeapon = true
					self:CreateIcon(button)
				end
				if button then
					if button:IsShown() then button:Hide() end

					button:SetID(weapon)
					local index = enchantableSlots[weapon]
					local quality = GetInventoryItemQuality("player", index)
					button.texture:SetTexture(GetInventoryItemTexture("player", index))

					if quality then
						button:SetBackdropBorderColor(GetItemQualityColor(quality))
					end

					local expirationTime = weaponEnchantTime[weapon]
					if expirationTime then
						if not button.timeLeft then
							button.timeLeft = expirationTime / 1e3
							button:SetScript("OnUpdate", self.UpdateTime)
						else
							button.timeLeft = expirationTime / 1e3
						end
						button.nextUpdate = -1
						A.UpdateTime(button, 0)
					else
						button.timeLeft = nil
						button.time:SetText("")
						button:SetScript("OnUpdate", nil)
					end

					if weaponPosition == 0 then
						tinsert(buttons, button)
					else
						tinsert(buttons, weaponPosition, button)
					end
				end
			else
				if button and type(button.Hide) == "function" then
					button:Hide()
				end
			end
		end
	end

	local display = #buttons
	if wrapAfter and maxWraps then
		display = min(display, wrapAfter * maxWraps)
	end

	local left, right, top, bottom = huge, -huge, -huge, huge
	for index = 1, display do
		button = buttons[index]
		local tick, cycle = floor((index - 1) % wrapAfter), floor((index - 1) / wrapAfter)
		button:ClearAllPoints()
		button:SetPoint(point, header, cycle * wrapXOffset + tick * xOffset, cycle * wrapYOffset + tick * yOffset)

		button:SetSize(size, size)

		if button.time then
			local font = LSM:Fetch("font", self.db.font)
			button.time:ClearAllPoints()
			button.time:Point("TOP", button, "BOTTOM", 1 + self.db.timeXOffset, 0 + self.db.timeYOffset)
			button.time:FontTemplate(font, db.durationFontSize, self.db.fontOutline)

			button.count:ClearAllPoints()
			button.count:Point("BOTTOMRIGHT", -1 + self.db.countXOffset, 0 + self.db.countYOffset)
			button.count:FontTemplate(font, db.countFontSize, self.db.fontOutline)
		end

		button:Show()
		left = min(left, button:GetLeft() or huge)
		right = max(right, button:GetRight() or -huge)
		top = max(top, button:GetTop() or -huge)
		bottom = min(bottom, button:GetBottom() or huge)
	end
	local deadIndex = #(auraTable) + 1
	button = _G[headerName.."AuraButton"..deadIndex]
	while button do
		if button:IsShown() then button:Hide() end
		deadIndex = deadIndex + 1
		button = _G[headerName.."AuraButton"..deadIndex]
	end

	if display >= 1 then
		header:SetWidth(max(right - left, minWidth))
		header:SetHeight(max(top - bottom, minHeight))
	else
		header:SetWidth(minWidth)
		header:SetHeight(minHeight)
	end
end

local freshTable
local releaseTable
do
	local tableReserve = {}
	freshTable = function ()
		local t = next(tableReserve) or {}
		tableReserve[t] = nil
		return t
	end
	releaseTable = function (t)
		tableReserve[t] = wipe(t)
	end
end

local function sortFactory(key, separateOwn, reverse)
	if separateOwn ~= 0 then
		if reverse then
			return function(a, b)
				if a.filter == b.filter then
					local ownA, ownB = a.caster == "player", b.caster == "player"
					if ownA ~= ownB then
						return ownA == (separateOwn > 0)
					end
					return a[key] > b[key]
				else
					return a.filter < b.filter
				end
			end;
		else
			return function(a, b)
				if a.filter == b.filter then
					local ownA, ownB = a.caster == "player", b.caster == "player"
					if ownA ~= ownB then
						return ownA == (separateOwn > 0)
					end
					return a[key] < b[key]
				else
					return a.filter < b.filter
				end
			end;
		end
	else
		if reverse then
			return function(a, b)
				if a.filter == b.filter then
					return a[key] > b[key]
				else
					return a.filter < b.filter
				end
			end;
		else
			return function(a, b)
				if a.filter == b.filter then
					return a[key] < b[key]
				else
					return a.filter < b.filter
				end
			end;
		end
	end
end

local sorters = {}
for _, key in ipairs{"index", "name", "expires"} do
	local label = string.upper(key)
	sorters[label] = {}
	for bool in pairs{[true] = true, [false] = false} do
		sorters[label][bool] = {}
		for sep = -1, 1 do
			sorters[label][bool][sep] = sortFactory(key, sep, bool)
		end
	end
end
sorters.TIME = sorters.EXPIRES

local sortingTable = {}
function A:UpdateHeader(header)
	local filter = header.filter
	local db = self.db.debuffs

	wipe(sortingTable)

	local weaponPosition
	if filter == "HELPFUL" then
		db = self.db.buffs
		weaponPosition = 1
	end

	local i = 1
	repeat
		local aura, _ = freshTable()
		aura.name, _, aura.icon, aura.count, aura.dispelType, aura.duration, aura.expires, aura.caster = UnitAura("player", i, filter)
		if aura.name then
			aura.filter = filter
			aura.index = i

			tinsert(sortingTable, aura)
		else
			releaseTable(aura)
		end
		i = i + 1
	until not aura.name

	local sortMethod = (sorters[db.sortMethod] or sorters.INDEX)[db.sortDir == "-"][db.seperateOwn]
	tsort(sortingTable, sortMethod)

	self:ConfigureAuras(header, sortingTable, weaponPosition)
	while sortingTable[1] do
		releaseTable(tremove(sortingTable))
	end

	if self.LBFGroup then
		self.LBFGroup:Skin(E.private.auras.lbf.skin)
	end
end

function A:CreateAuraHeader(filter)
	local name = "ElvUIPlayerDebuffs"
	if filter == "HELPFUL" then
		name = "ElvUIPlayerBuffs"
	end

	local header = CreateFrame("Frame", name, UIParent)
	header:SetClampedToScreen(true)
	header.filter = filter

	header:RegisterEvent("UNIT_AURA")
	header:SetScript("OnEvent", function(self, _, unit)
		if unit ~= "player" then return end

		A:UpdateHeader(self)
	end)

	self:UpdateHeader(header)

	return header
end

function A:Initialize()
	if E.private.auras.disableBlizzard then
		BuffFrame:Kill()
		ConsolidatedBuffs:Kill()
		TemporaryEnchantFrame:Kill()
	end

	if not E.private.auras.enable then return end

	self.Initialized = true
	self.db = E.db.auras

	if LBF then
		self.LBFGroup = LBF and LBF:Group("ElvUI", "Auras")
	end

	self.BuffFrame = self:CreateAuraHeader("HELPFUL")
	self.BuffFrame:Point("TOPRIGHT", MMHolder, "TOPLEFT", -(6 + E.Border), -E.Border - E.Spacing)
	E:CreateMover(self.BuffFrame, "BuffsMover", L["Player Buffs"], nil, nil, nil, nil, nil, "auras,buffs")

	self.BuffFrame.nextUpdate = -1
	self.BuffFrame:SetScript("OnUpdate", function(bf, elapsed)
		if bf.nextUpdate > 0 then
			bf.nextUpdate = bf.nextUpdate - elapsed
			return
		end

		bf.nextUpdate = 1

		local hasMainHandEnchant, mainHandExpiration, _, hasOffHandEnchant, offHandExpiration = GetWeaponEnchantInfo()
		if A:HasEnchant(1, hasMainHandEnchant, mainHandExpiration) or A:HasEnchant(2, hasOffHandEnchant, offHandExpiration) then
			A:UpdateHeader(bf)
		end
	end)

	self.DebuffFrame = self:CreateAuraHeader("HARMFUL")
	self.DebuffFrame:Point("BOTTOMRIGHT", MMHolder, "BOTTOMLEFT", -(6 + E.Border), E.Border + E.Spacing)
	E:CreateMover(self.DebuffFrame, "DebuffsMover", L["Player Debuffs"], nil, nil, nil, nil, nil, "auras,debuffs")
end

local function InitializeCallback()
	A:Initialize()
end

E:RegisterModule(A:GetName(), InitializeCallback)