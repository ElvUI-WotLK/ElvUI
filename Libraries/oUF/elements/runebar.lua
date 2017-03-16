if select(2, UnitClass("player")) ~= "DEATHKNIGHT" then return end

local parent, ns = ...
local oUF = ns.oUF

local floor = math.floor

local IsUsableSpell = IsUsableSpell
local GetRuneCooldown = GetRuneCooldown
local GetTime = GetTime
local GetRuneType = GetRuneType

oUF.colors.Runes = {
	{1, 0, 0},		-- blood
	{0, .5, 0},		-- unholy
	{0, 1, 1},		-- frost
	{.9, .1, 1},	-- death
}

local runemap = { 1, 2, 5, 6, 3, 4 }
local BLOOD_OF_THE_NORTH = GetSpellInfo(54637)

local OnUpdate = function(self, elapsed)
	local duration = self.duration + elapsed
	self.duration = duration
	self:SetValue(duration)
end

local UpdateType = function(self, event, rid, alt)
	local runes = self.Runes
	local rune = runes[runemap[rid]]
	local runeType = GetRuneType(rid) or alt

	if IsUsableSpell(BLOOD_OF_THE_NORTH) and runeType == 1 then
		runeType = 4
	end
	if not runeType then return end

	local colors = self.colors.Runes[runeType]
	local r, g, b = colors[1], colors[2], colors[3]

	rune:SetStatusBarColor(r, g, b)

	if(rune.bg) then
		local mu = rune.bg.multiplier or 1
		rune.bg:SetVertexColor(r * mu, g * mu, b * mu)
	end

	if(runes.PostUpdateType) then
		return runes:PostUpdateType(rune, rid, alt)
	end
end

local Update = function(self, event, rid)
	local runes = self.Runes
	local rune = runes[runemap[rid]]
	if(not rune) then return end

	local start, duration, runeReady
	if(UnitHasVehicleUI("player")) then
		rune:Hide()
	else
		start, duration, runeReady = GetRuneCooldown(rid)
		if(not start) then return end

		if(runeReady) then
			rune:SetMinMaxValues(0, 1)
			rune:SetValue(1)
			rune:SetScript("OnUpdate", nil)
		else
			rune.duration = GetTime() - start
			rune.max = duration
			rune:SetMinMaxValues(1, duration)
			rune:SetScript("OnUpdate", OnUpdate)
		end

		rune:Show()
	end

	if(runes.PostUpdate) then
		return runes:PostUpdate(rune, rid, start, duration, runeReady)
	end
end

local Path = function(self, event, ...)
	local runes = self.Runes
	local UpdateMethod = runes.Override or Update
	if(event == "RUNE_POWER_UPDATE") then
		return UpdateMethod(self, event, ...)
	else
		for index = 1, #runes do
			UpdateMethod(self, event, index)
		end
	end
end

local ForceUpdate = function(element)
	return Path(element.__owner, "ForceUpdate")
end

local function UpdateAllRuneTypes(self, event)
	if(not self) then return end
	Path(self, event)
end

local Enable = function(self, unit)
	local runes = self.Runes
	if(runes and unit == "player") then
		runes.__owner = self
		runes.ForceUpdate = ForceUpdate

		for i = 1, #runes do
			local rune = runes[runemap[i]]
			if(rune:IsObjectType("StatusBar") and not rune:GetStatusBarTexture()) then
				rune:SetStatusBarTexture[[Interface\TargetingFrame\UI-StatusBar]]
			end

			-- From my minor testing this is a okey solution. A full login always remove
			-- the death runes, or at least the clients knowledge about them.
			UpdateType(self, nil, i, floor((i+1)/2))
		end

		self:RegisterEvent("RUNE_POWER_UPDATE", Path, true)
		self:RegisterEvent("RUNE_TYPE_UPDATE", UpdateType, true)
		self:RegisterEvent("PLAYER_ENTERING_WORLD", UpdateAllRuneTypes)

		-- oUF leaves the vehicle events registered on the player frame, so
		-- buffs and such are correctly updated when entering/exiting vehicles.
		--
		-- This however makes the code also show/hide the RuneFrame.
		RuneFrame.Show = RuneFrame.Hide
		RuneFrame:Hide()

		return true
	end
end

local Disable = function(self)
	RuneFrame.Show = nil
	RuneFrame:Show()

	local runes = self.Runes
	if(runes) then
		self:SetScript("OnUpdate", nil)

		self:UnregisterEvent("RUNE_POWER_UPDATE", Path)
		self:UnregisterEvent("RUNE_TYPE_UPDATE", UpdateType)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD", UpdateAllRuneTypes)
	end
end

oUF:AddElement("Runes", Path, Enable, Disable)