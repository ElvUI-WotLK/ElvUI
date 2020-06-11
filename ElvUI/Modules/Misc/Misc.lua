local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:GetModule("Misc")
local Bags = E:GetModule("Bags")

--Lua functions
local ipairs = ipairs
local format = string.format
--WoW API / Variables
local AcceptGroup = AcceptGroup
local CanGuildBankRepair = CanGuildBankRepair
local CanMerchantRepair = CanMerchantRepair
local GetCVarBool, SetCVar = GetCVarBool, SetCVar
local GetFriendInfo = GetFriendInfo
local GetGuildBankMoney = GetGuildBankMoney
local GetGuildBankWithdrawMoney = GetGuildBankWithdrawMoney
local GetGuildRosterInfo = GetGuildRosterInfo
local GetMoney = GetMoney
local GetNumFriends = GetNumFriends
local GetNumGuildMembers = GetNumGuildMembers
local GetNumPartyMembers = GetNumPartyMembers
local GetNumRaidMembers = GetNumRaidMembers
local GetPartyMember = GetPartyMember
local GetRaidRosterInfo = GetRaidRosterInfo
local GetRepairAllCost = GetRepairAllCost
local GuildRoster = GuildRoster
local HideRepairCursor = HideRepairCursor
local InCombatLockdown = InCombatLockdown
local IsInGuild = IsInGuild
local IsInInstance = IsInInstance
local IsShiftKeyDown = IsShiftKeyDown
local LeaveParty = LeaveParty
local PickupInventoryItem = PickupInventoryItem
local RaidNotice_AddMessage = RaidNotice_AddMessage
local RepairAllItems = RepairAllItems
local SendChatMessage = SendChatMessage
local ShowFriends = ShowFriends
local ShowRepairCursor = ShowRepairCursor
local StaticPopup_Hide = StaticPopup_Hide
local UninviteUnit = UninviteUnit
local UnitGUID = UnitGUID
local UnitName = UnitName

local MAX_PARTY_MEMBERS = MAX_PARTY_MEMBERS

do
	local function EventHandler(event)
		if event == "PLAYER_REGEN_DISABLED" then
			UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
		else
			UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE")
		end
	end

	function M:ToggleErrorHandling()
		if E.db.general.hideErrorFrame then
			self:RegisterEvent("PLAYER_REGEN_ENABLED", EventHandler)
			self:RegisterEvent("PLAYER_REGEN_DISABLED", EventHandler)
		else
			self:UnregisterEvent("PLAYER_REGEN_ENABLED", EventHandler)
			self:UnregisterEvent("PLAYER_REGEN_DISABLED", EventHandler)
		end
	end
end

do
	local interruptMsg = INTERRUPTED.." %s's \124cff71d5ff\124Hspell:%d\124h[%s]\124h\124r!"

	function M:ToggleInterruptAnnounce()
		if E.db.general.interruptAnnounce == "NONE" then
			self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		else
			self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		end
	end

	function M:COMBAT_LOG_EVENT_UNFILTERED(_, _, event, sourceGUID, _, _, _, destName, _, _, _, _, spellID, spellName)
		if not (event == "SPELL_INTERRUPT" and (sourceGUID == E.myguid or sourceGUID == UnitGUID("pet"))) then return end

		if E.db.general.interruptAnnounce == "SAY" then
			SendChatMessage(format(interruptMsg, destName, spellID, spellName), "SAY")
		elseif E.db.general.interruptAnnounce == "EMOTE" then
			SendChatMessage(format(interruptMsg, destName, spellID, spellName), "EMOTE")
		else
			local _, instanceType = IsInInstance()
			local battleground = instanceType == "pvp"

			if E.db.general.interruptAnnounce == "PARTY" then
				if GetNumPartyMembers() > 0 then
					SendChatMessage(format(interruptMsg, destName, spellID, spellName), battleground and "BATTLEGROUND" or "PARTY")
				end
			elseif E.db.general.interruptAnnounce == "RAID" then
				if GetNumRaidMembers() > 0 then
					SendChatMessage(format(interruptMsg, destName, spellID, spellName), battleground and "BATTLEGROUND" or "RAID")
				elseif GetNumPartyMembers() > 0 then
					SendChatMessage(format(interruptMsg, destName, spellID, spellName), battleground and "BATTLEGROUND" or "PARTY")
				end
			elseif E.db.general.interruptAnnounce == "RAID_ONLY" then
				if GetNumRaidMembers() > 0 then
					SendChatMessage(format(interruptMsg, destName, spellID, spellName), battleground and "BATTLEGROUND" or "RAID")
				end
			end
		end
	end
end

do
	local repairInventoryPriority = {
		16,	-- MainHandSlot
		17,	-- SecondaryHandSlot
		18,	-- RangedSlot
		1,	-- HeadSlot
		5,	-- ChestSlot
		7,	-- LegsSlot
		3,	-- ShoulderSlot
		10,	-- HandsSlot
		6,	-- WaistSlot
		8,	-- FeetSlot
		9,	-- WristSlot
	}

	local function RepairInventoryByPriority(playerMoney)
		local money = playerMoney

		ShowRepairCursor()

		for _, slotID in ipairs(repairInventoryPriority) do
			local hasItem, _, repairCost = GameTooltip:SetInventoryItem("player", slotID)

			if hasItem and repairCost and repairCost > 0 and repairCost <= money then
				PickupInventoryItem(slotID)
				money = money - repairCost
			end
		end

		HideRepairCursor()
		GameTooltip:Hide()

		return playerMoney - money
	end

	local function FullRepairMessage(repairAllCost)
		E:Print(format("%s%s", L["Your items have been repaired for: "], E:FormatMoney(repairAllCost, "SMART", true)))
	end

	function M:AutoRepair(repairMode, greyValue)
		if not CanMerchantRepair() or IsShiftKeyDown() then return end

		local repairAllCost, canRepair = GetRepairAllCost()
		if not canRepair or repairAllCost <= 0 then return end

		if repairMode == "GUILD" then
			if not CanGuildBankRepair() then
				repairMode = "PLAYER"
			else
				local guildWithdrawMoney = GetGuildBankWithdrawMoney()
				local guildMoney = GetGuildBankMoney()
				local availableGuildMoney

				if guildWithdrawMoney == -1 or guildMoney < guildWithdrawMoney then
					availableGuildMoney = guildMoney
				else
					availableGuildMoney = guildWithdrawMoney
				end

				if repairAllCost > availableGuildMoney then
					repairMode = "PLAYER"
				end
			end
		end

		if repairMode == "GUILD" then
			RepairAllItems(true)

			E:Print(format("%s%s", L["Your items have been repaired using guild bank funds for: "], E:FormatMoney(repairAllCost, "SMART", true)))
		else
			local playerMoney = GetMoney()

			if playerMoney >= repairAllCost then
				RepairAllItems()
				FullRepairMessage(repairAllCost)
			elseif greyValue and playerMoney + greyValue >= repairAllCost then
				self.playerMoney = playerMoney
				self.repairAllCost = repairAllCost

				self:RegisterEvent("MERCHANT_CLOSED")
				E.RegisterCallback(M, "VendorGreys_ItemSold")
			elseif playerMoney > 0 then
				local spent = RepairInventoryByPriority(playerMoney)

				if spent > 0 then
					E:Print(format("%s%s", L["Your items have been repaired for: "], E:FormatMoney(spent, "SMART", true)))
					E:Print(L["You don't have enough money to repair all items."])
				else
					E:Print(L["You don't have enough money to repair."])
				end
			else
				E:Print(L["You don't have enough money to repair."])
			end
		end
	end

	function M:VendorGreys_ItemSold(_, moneyGained)
		self.playerMoney = self.playerMoney + moneyGained

		if self.playerMoney >= self.repairAllCost then
			if self.playerMoney > GetMoney() then
				self:RegisterEvent("PLAYER_MONEY")
				E.UnregisterCallback(M, "VendorGreys_ItemSold")
			else
				RepairAllItems()
				FullRepairMessage(self.repairAllCost)
			end
		end
	end

	function M:PLAYER_MONEY()
		if self.playerMoney <= GetMoney() then
			RepairAllItems()
			FullRepairMessage(self.repairAllCost)

			self:MERCHANT_CLOSED()
		end
	end

	function M:MERCHANT_CLOSED()
		self.playerMoney = nil
		self.repairAllCost = nil

		self:UnregisterEvent("PLAYER_MONEY")
		self:UnregisterEvent("MERCHANT_CLOSED")
		E.UnregisterCallback(M, "VendorGreys_ItemSold")
	end
end

function M:MERCHANT_SHOW()
	local greyValue

	if E.db.bags.vendorGrays.enable then
		local itemCount
		itemCount, greyValue = Bags:GetGraysInfo()

		if itemCount > 0 then
			Bags:VendorGrays()
		end
	end

	local repairMode = E.db.general.autoRepair
	if repairMode ~= "NONE" then
		E:Delay(0.03, self.AutoRepair, self, repairMode, greyValue)
	end
end

function M:DisbandRaidGroup()
	if InCombatLockdown() then return end -- Prevent user error in combat

	local numRaid = GetNumRaidMembers()

	if numRaid > 0 then
		for i = 1, numRaid do
			local name, _, _, _, _, _, _, online = GetRaidRosterInfo(i)
			if online and name ~= E.myname then
				UninviteUnit(name)
			end
		end
	else
		for i = MAX_PARTY_MEMBERS, 1, -1 do
			if GetPartyMember(i) then
				UninviteUnit(UnitName("party"..i))
			end
		end
	end

	LeaveParty()
end

function M:PVPMessageEnhancement(_, msg)
	if not E.db.general.enhancedPvpMessages then return end

	local _, instanceType = IsInInstance()
	if instanceType == "pvp" or instanceType == "arena" then
		RaidNotice_AddMessage(RaidBossEmoteFrame, msg, ChatTypeInfo.RAID_BOSS_EMOTE)
	end
end

function M:AutoInvite(event, leaderName)
	if not E.db.general.autoAcceptInvite then return end

	if MiniMapLFGFrame:IsShown() then return end
	if GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0 then return end

	local numFriends = GetNumFriends()

	if numFriends > 0 then
		ShowFriends()

		for i = 1, numFriends do
			if GetFriendInfo(i) == leaderName then
				AcceptGroup()
				StaticPopup_Hide("PARTY_INVITE")
				return
			end
		end
	end

	if not IsInGuild() then return end

	GuildRoster()

	for i = 1, GetNumGuildMembers() do
		if GetGuildRosterInfo(i) == leaderName then
			AcceptGroup()
			StaticPopup_Hide("PARTY_INVITE")
			return
		end
	end
end

function M:ForceCVars(event)
	if not GetCVarBool("lockActionBars") then
		SetCVar("lockActionBars", 1)
	end

	if event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end
end

function M:Initialize()
	self:LoadRaidMarker()
	self:LoadLoot()
	self:LoadLootRoll()
	self:LoadChatBubbles()

	self:ToggleErrorHandling()
	self:ToggleInterruptAnnounce()

	self:RegisterEvent("CHAT_MSG_BG_SYSTEM_HORDE", "PVPMessageEnhancement")
	self:RegisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE", "PVPMessageEnhancement")
	self:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL", "PVPMessageEnhancement")
	self:RegisterEvent("PARTY_INVITE_REQUEST", "AutoInvite")
	self:RegisterEvent("MERCHANT_SHOW")

	if E.private.actionbar.enable then
		self:RegisterEvent("CVAR_UPDATE", "ForceCVars")
		self:RegisterEvent("PLAYER_ENTERING_WORLD", "ForceCVars")
	end

	self.Initialized = true
end

local function InitializeCallback()
	M:Initialize()
end

E:RegisterModule(M:GetName(), InitializeCallback)