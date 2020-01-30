local _, ns = ...
local oUF = oUF or ns.oUF
assert(oUF, "oUF_AuraBars was unable to locate oUF install.")

local type = type
local unpack = unpack
local floor, huge, min = math.floor, math.huge, math.min
local format = string.format
local tsort, tremove = table.sort, table.remove

local CreateFrame = CreateFrame
local GetTime = GetTime
local UnitAura = UnitAura
local UnitIsFriend = UnitIsFriend

local DAY, HOUR, MINUTE = 86400, 3600, 60
local function formatTime(s)
	if s < MINUTE then
		return format("%.1fs", s)
	elseif s < HOUR then
		return format("%dm %ds", s / 60 % 60, s % 60)
	elseif s < DAY then
		return format("%dh %dm", s / HOUR, s / 60 % 60)
	else
		return format("%dd %dh", s/DAY, (s / HOUR) - (floor(s / DAY) * 24))
	end
end

local function UpdateTooltip(self)
	GameTooltip:SetUnitAura(self.__unit, self:GetParent().aura.name, self:GetParent().aura.rank, self:GetParent().aura.filter)
end

local function OnEnter(self)
	if not self:IsVisible() then return end

	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
	self:UpdateTooltip()
end

local function OnLeave(self)
	GameTooltip:Hide()
end

local function SetAnchors(self)
	local bars = self.bars

	for i = 1, #bars do
		local frame = bars[i]
		local anchor = frame.anchor

		frame:Height(self.auraBarHeight or 20)
		frame:Width((self.auraBarWidth or self:GetWidth()) - (frame:GetHeight() + (self.gap or 0)))
		frame.statusBar.iconHolder:Size(frame:GetHeight())

		frame:ClearAllPoints()
		if self.down then
			if self == anchor then -- Root frame so indent for icon
				frame:SetPoint("TOPLEFT", anchor, "TOPLEFT", (frame:GetHeight() + (self.gap or 0)), -1)
			else
				frame:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, (-self.spacing or 0))
			end
		else
			if self == anchor then -- Root frame so indent for icon
				frame:SetPoint("BOTTOMLEFT", anchor, "BOTTOMLEFT", (frame:GetHeight() + (self.gap or 0)), 1)
			else
				frame:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 0, (self.spacing or 0))
			end
		end
	end
end

local function CreateAuraBar(self, anchor)
	local element = self.AuraBars

	local frame = CreateFrame("Frame", nil, element)
	frame:Height(element.auraBarHeight or 20)
	frame:Width((element.auraBarWidth or element:GetWidth()) - (frame:GetHeight() + (element.gap or 0)))
	frame.anchor = anchor

	-- the main bar
	local statusBar = CreateFrame("StatusBar", nil, frame)
	statusBar:SetStatusBarTexture(element.auraBarTexture or [[Interface\TargetingFrame\UI-StatusBar]])
	statusBar:SetAlpha(element.fgalpha or 1)
	statusBar:SetAllPoints(frame)

	frame.statusBar = statusBar

	if element.down then
		if element == anchor then -- Root frame so indent for icon
			frame:SetPoint("TOPLEFT", anchor, "TOPLEFT", (frame:GetHeight() + (element.gap or 0)), -1)
		else
			frame:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, (-element.spacing or 0))
		end
	else
		if element == anchor then -- Root frame so indent for icon
			frame:SetPoint("BOTTOMLEFT", anchor, "BOTTOMLEFT", (frame:GetHeight() + (element.gap or 0)), 1)
		else
			frame:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 0, (element.spacing or 0))
		end
	end

	local spark = statusBar:CreateTexture(nil, "OVERLAY", nil)
	spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
	spark:Width(12)
	spark:SetBlendMode("ADD")
	spark:SetPoint("CENTER", statusBar:GetStatusBarTexture(), "RIGHT")
	statusBar.spark = spark

	statusBar.iconHolder = CreateFrame("Button", nil, statusBar)
	statusBar.iconHolder:Size(frame:GetHeight())
	statusBar.iconHolder:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", -element.gap, 0)
	statusBar.iconHolder.__unit = self.unit
	statusBar.iconHolder:SetScript("OnEnter", OnEnter)
	statusBar.iconHolder:SetScript("OnLeave", OnLeave)
	statusBar.iconHolder.UpdateTooltip = UpdateTooltip

	statusBar.icon = statusBar.iconHolder:CreateTexture(nil, "BACKGROUND")
	statusBar.icon:SetTexCoord(unpack(ElvUI[1].TexCoords))
	statusBar.icon:SetAllPoints()

	statusBar.spelltime = statusBar:CreateFontString(nil, "ARTWORK")
	if element.spellTimeObject then
		statusBar.spelltime:SetFontObject(element.spellTimeObject)
	else
		statusBar.spelltime:SetFont(element.spellTimeFont or [[Fonts\FRIZQT__.TTF]], element.spellTimeSize or 10)
	end
	statusBar.spelltime:SetTextColor(1, 1, 1)
	statusBar.spelltime:SetJustifyH("RIGHT")
	statusBar.spelltime:SetJustifyV("CENTER")
	statusBar.spelltime:SetPoint("RIGHT")

	statusBar.spellname = statusBar:CreateFontString(nil, "ARTWORK")
	if element.spellNameObject then
		statusBar.spellname:SetFontObject(element.spellNameObject)
	else
		statusBar.spellname:SetFont(element.spellNameFont or [[Fonts\FRIZQT__.TTF]], element.spellNameSize or 10)
	end
	statusBar.spellname:SetTextColor(1, 1, 1)
	statusBar.spellname:SetJustifyH("LEFT")
	statusBar.spellname:SetJustifyV("CENTER")
	statusBar.spellname:SetPoint("LEFT")
	statusBar.spellname:SetPoint("RIGHT", statusBar.spelltime, "LEFT")

	if element.PostCreateBar then
		element.PostCreateBar(frame)
	end

	return frame
end

local function UpdateBars(element)
	local bars = element.bars
	local currentTime = GetTime()

	for i = 1, #bars do
		local frame = bars[i]
		if not frame:IsVisible() then break end

		local bar = frame.statusBar

		if bar.aura.noTime then
			bar.spelltime:SetText()
			bar.spark:Hide()
		else
			local timeleft = bar.aura.expirationTime - currentTime
			bar:SetValue(timeleft)
			bar.spelltime:SetText(formatTime(timeleft))

			if element.spark == true then
				if element.scaleTime and ((element.scaleTime <= 0) or (element.scaleTime > 0 and timeleft < element.scaleTime)) then
					bar.spark:Show()
				else
					bar.spark:Hide()
				end
			end
		end
	end
end

local function DefaultFilter(self, unit, name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate)
	if unitCaster == "player" and not shouldConsolidate then
		return true
	end
end

local function sortByTime(a, b)
	local compa = a.noTime and huge or a.expirationTime
	local compb = b.noTime and huge or b.expirationTime
	return compa > compb
end

local function Update(self, event, unit)
	if self.unit ~= unit then return end

	local element = self.AuraBars
	local helpOrHarm
	local isFriend = UnitIsFriend("player", unit) == 1 and true or false

	if element.friendlyAuraType and element.enemyAuraType then
		if isFriend then
			helpOrHarm = element.friendlyAuraType
		else
			helpOrHarm = element.enemyAuraType
		end
	else
		helpOrHarm = isFriend and "HELPFUL" or "HARMFUL"
	end

	-- Create a table of auras to display
	local auras = {}
	local lastAuraIndex = 0

	if element.forceShow then
		local spellID = 47540
		local name, rank, icon = GetSpellInfo(spellID)
		local count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate = 5, "Magic", 0, 0, "player", nil, nil

		for i = 1, element.maxBars do
			lastAuraIndex = lastAuraIndex + 1
			auras[lastAuraIndex] = {}
			auras[lastAuraIndex].spellID = spellID
			auras[lastAuraIndex].name = name
			auras[lastAuraIndex].rank = rank
			auras[lastAuraIndex].icon = icon
			auras[lastAuraIndex].count = count
			auras[lastAuraIndex].debuffType = debuffType
			auras[lastAuraIndex].duration = duration
			auras[lastAuraIndex].expirationTime = expirationTime
			auras[lastAuraIndex].unitCaster = unitCaster
			auras[lastAuraIndex].isStealable = isStealable
			auras[lastAuraIndex].noTime = (duration == 0 and expirationTime == 0)
			auras[lastAuraIndex].filter = helpOrHarm
			auras[lastAuraIndex].shouldConsolidate = shouldConsolidate
		end
	else
		local i = 0
		while lastAuraIndex <= element.maxBars do
			i = i + 1

			local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellID = UnitAura(unit, i, helpOrHarm)
			if not name then break end

			if (element.filter or DefaultFilter)(self, unit, name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellID) then
				lastAuraIndex = lastAuraIndex + 1
				auras[lastAuraIndex] = {}
				auras[lastAuraIndex].spellID = spellID
				auras[lastAuraIndex].name = name
				auras[lastAuraIndex].rank = rank
				auras[lastAuraIndex].icon = icon
				auras[lastAuraIndex].count = count
				auras[lastAuraIndex].debuffType = debuffType
				auras[lastAuraIndex].duration = duration
				auras[lastAuraIndex].expirationTime = expirationTime
				auras[lastAuraIndex].unitCaster = unitCaster
				auras[lastAuraIndex].isStealable = isStealable
				auras[lastAuraIndex].noTime = (duration == 0 and expirationTime == 0)
				auras[lastAuraIndex].filter = helpOrHarm
				auras[lastAuraIndex].shouldConsolidate = shouldConsolidate
			end
		end
	end

	if element.sort and not element.forceShow then
		tsort(auras, type(element.sort) == "function" and element.sort or sortByTime)
	end

	-- Show and configure bars for buffs/debuffs.
	local bars = element.bars
	if lastAuraIndex == 0 then
		element:Height(1)
	end

	local currentTime = GetTime()

	for i = 1, lastAuraIndex do
		if element:GetWidth() == 0 then break end

		local aura = auras[i]
		local frame = bars[i]

		if not frame then
			frame = CreateAuraBar(self, i == 1 and element or bars[i - 1])
			bars[i] = frame
		end

		if i == lastAuraIndex then
			if element.down then
				element:Height(element:GetTop() - frame:GetBottom())
			elseif frame:GetTop() and element:GetBottom() then
				element:Height(frame:GetTop() - element:GetBottom())
			else
				element:Height(20)
			end
		end

		local bar = frame.statusBar
		frame.index = i

		-- Backup the details of the aura onto the bar, so the OnUpdate function can use it
		bar.aura = aura

		-- Configure
		if bar.aura.noTime then
			bar:SetMinMaxValues(0, 1)
			bar:SetValue(1)
		else
			if element.scaleTime and element.scaleTime > 0 then
				local maxValue = min(element.scaleTime, bar.aura.duration)
				bar:SetMinMaxValues(0, element.scaleTime)
				bar:Width((maxValue / element.scaleTime) * ((element.auraBarWidth or element:GetWidth()) - (bar:GetHeight() + (element.gap or 0)))) -- icon size + gap
			else
				bar:SetMinMaxValues(0, bar.aura.duration)
			end

			bar:SetValue(bar.aura.expirationTime - currentTime)
		end

		bar.icon:SetTexture(bar.aura.icon)

		bar.spellname:SetText(bar.aura.count > 1 and format("%s [%d]", bar.aura.name, bar.aura.count) or bar.aura.name)
		bar.spelltime:SetText(not bar.noTime and formatTime(bar.aura.expirationTime - currentTime))

		-- Colour bars
		local r, g, b

		if helpOrHarm == "HARMFUL" then
			local debuffType = bar.aura.debuffType and bar.aura.debuffType or "none"

			if element.debuffColor then
				r, g, b = unpack(element.debuffColor)
			elseif debuffType == "none" and element.defaultDebuffColor then
				r, g, b = unpack(element.defaultDebuffColor)
			else
				r, g, b = DebuffTypeColor[debuffType].r, DebuffTypeColor[debuffType].g, DebuffTypeColor[debuffType].b
			end
		elseif element.buffColor then
			r, g, b = unpack(element.buffColor)
		else
			-- buffs default
			r, g, b = .2, .6, 1
		end

		bar:SetStatusBarColor(r, g, b)
		frame:Show()
	end

	-- Hide unused bars
	for i = lastAuraIndex + 1, #bars do
		bars[i]:Hide()
	end

	if element.PostUpdate then
		element:PostUpdate(event, unit)
	end
end

local function Enable(self)
	local element = self.AuraBars

	if element then
		self:RegisterEvent("UNIT_AURA", Update)
		element.SetAnchors = SetAnchors
		element.maxBars = element.maxBars or 40
		element.bars = element.bars or {}
		element:Height(1)
		element:SetScript("OnUpdate", UpdateBars)

		return true
	end
end

local function Disable(self)
	local element = self.AuraBars

	if element then
		element:SetScript("OnUpdate", nil)
		self:UnregisterEvent("UNIT_AURA", Update)
	end
end

oUF:AddElement("AuraBars", Update, Enable, Disable)