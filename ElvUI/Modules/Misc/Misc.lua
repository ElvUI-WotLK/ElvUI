local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:GetModule("Misc")
local Bags = E:GetModule("Bags")

local format, gsub = string.format, string.gsub

local AcceptGroup = AcceptGroup
local CanGuildBankRepair = CanGuildBankRepair
local CanMerchantRepair = CanMerchantRepair
local GetCVarBool, SetCVar = GetCVarBool, SetCVar
local GetFriendInfo = GetFriendInfo
local GetGuildBankWithdrawMoney = GetGuildBankWithdrawMoney
local GetGuildRosterInfo = GetGuildRosterInfo
local GetNumFriends = GetNumFriends
local GetNumGuildMembers = GetNumGuildMembers
local GetNumPartyMembers = GetNumPartyMembers
local GetNumRaidMembers = GetNumRaidMembers
local GetPartyMember = GetPartyMember
local GetRaidRosterInfo = GetRaidRosterInfo
local GetRepairAllCost = GetRepairAllCost
local GetUnitSpeed = GetUnitSpeed
local GuildRoster = GuildRoster
local InCombatLockdown = InCombatLockdown
local IsInGuild = IsInGuild
local IsInInstance = IsInInstance
local IsShiftKeyDown = IsShiftKeyDown
local LeaveParty = LeaveParty
local RaidNotice_AddMessage = RaidNotice_AddMessage
local ShowFriends = ShowFriends
local StaticPopup_Hide = StaticPopup_Hide
local RepairAllItems = RepairAllItems
local SendChatMessage = SendChatMessage
local UninviteUnit = UninviteUnit
local UnitInRaid = UnitInRaid
local UnitGUID = UnitGUID
local UnitName = UnitName
local UIErrorsFrame = UIErrorsFrame
local ERR_NOT_ENOUGH_MONEY = ERR_NOT_ENOUGH_MONEY
local ERR_GUILD_NOT_ENOUGH_MONEY = ERR_GUILD_NOT_ENOUGH_MONEY
local MAX_PARTY_MEMBERS = MAX_PARTY_MEMBERS

local interruptMsg = INTERRUPTED.." %s's \124cff71d5ff\124Hspell:%d\124h[%s]\124h\124r!"

function M:ErrorFrameToggle(event)
	if not E.db.general.hideErrorFrame then return end

	if event == "PLAYER_REGEN_DISABLED" then
		UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
	else
		UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE")
	end
end

function M:COMBAT_LOG_EVENT_UNFILTERED(_, _, event, sourceGUID, _, _, _, destName, _, _, _, _, spellID, spellName)
	if E.db.general.interruptAnnounce == "NONE" then return end
	if not (event == "SPELL_INTERRUPT" and (sourceGUID == E.myguid or sourceGUID == UnitGUID("pet"))) then return end

	if E.db.general.interruptAnnounce == "SAY" then
		SendChatMessage(format(interruptMsg, destName, spellID, spellName), "SAY")
	elseif E.db.general.interruptAnnounce == "EMOTE" then
		SendChatMessage(format(interruptMsg, destName, spellID, spellName), "EMOTE")
	else
		local party, raid = GetNumPartyMembers(), GetNumRaidMembers()
		local _, instanceType = IsInInstance()
		local battleground = instanceType == "pvp"

		if E.db.general.interruptAnnounce == "PARTY" then
			if party > 0 then
				SendChatMessage(format(interruptMsg, destName, spellID, spellName), battleground and "BATTLEGROUND" or "PARTY")
			end
		elseif E.db.general.interruptAnnounce == "RAID" then
			if raid > 0 then
				SendChatMessage(format(interruptMsg, destName, spellID, spellName), battleground and "BATTLEGROUND" or "RAID")
			elseif party > 0 then
				SendChatMessage(format(interruptMsg, destName, spellID, spellName), battleground and "BATTLEGROUND" or "PARTY")
			end
		elseif E.db.general.interruptAnnounce == "RAID_ONLY" then
			if raid > 0 then
				SendChatMessage(format(interruptMsg, destName, spellID, spellName), battleground and "BATTLEGROUND" or "RAID")
			end
		end
	end
end

do -- Auto Repair Functions
	local STATUS, TYPE, COST, POSS
	function M:AttemptAutoRepair(playerOverride)
		STATUS, TYPE, COST, POSS = "", E.db.general.autoRepair, GetRepairAllCost()

		if POSS and COST > 0 then
			--This check evaluates to true even if the guild bank has 0 gold, so we add an override
			if TYPE == "GUILD" and (playerOverride or (not CanGuildBankRepair() or COST > GetGuildBankWithdrawMoney())) then
				TYPE = "PLAYER"
			end

			RepairAllItems(TYPE == "GUILD")

			--Delay this a bit so we have time to catch the outcome of first repair attempt
			E:Delay(0.5, M.AutoRepairOutput)
		end
	end

	function M:AutoRepairOutput()
		if TYPE == "GUILD" then
			if STATUS == "GUILD_REPAIR_FAILED" then
				M:AttemptAutoRepair(true) --Try using player money instead
			else
				E:Print(L["Your items have been repaired using guild bank funds for: "]..E:FormatMoney(COST, "SMART", true)) --Amount, style, textOnly
			end
		elseif TYPE == "PLAYER" then
			if STATUS == "PLAYER_REPAIR_FAILED" then
				E:Print(L["You don't have enough money to repair."])
			else
				E:Print(L["Your items have been repaired for: "]..E:FormatMoney(COST, "SMART", true)) --Amount, style, textOnly
			end
		end
	end

	function M:UI_ERROR_MESSAGE(_, messageType)
		if messageType == ERR_GUILD_NOT_ENOUGH_MONEY then
			STATUS = "GUILD_REPAIR_FAILED"
		elseif messageType == ERR_NOT_ENOUGH_MONEY then
			STATUS = "PLAYER_REPAIR_FAILED"
		end
	end
end

function M:MERCHANT_CLOSED()
	self:UnregisterEvent("UI_ERROR_MESSAGE")
	self:UnregisterEvent("UPDATE_INVENTORY_DURABILITY")
	self:UnregisterEvent("MERCHANT_CLOSED")
end

function M:MERCHANT_SHOW()
	if E.db.bags.vendorGrays.enable then E:Delay(0.5, Bags.VendorGrays, Bags) end

	if E.db.general.autoRepair == "NONE" or IsShiftKeyDown() or not CanMerchantRepair() then return end

	--Prepare to catch "not enough money" messages
	self:RegisterEvent("UI_ERROR_MESSAGE")

	--Use this to unregister events afterwards
	self:RegisterEvent("MERCHANT_CLOSED")

	M:AttemptAutoRepair()
end

function M:DisbandRaidGroup()
	if InCombatLockdown() then return end -- Prevent user error in combat

	if UnitInRaid("player") then
		for i = 1, GetNumRaidMembers() do
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

function M:CheckMovement()
	if not WorldMapFrame:IsShown() then return end

	if GetUnitSpeed("player") ~= 0 then
		if WorldMapPositioningGuide:IsMouseOver() then
			WorldMapFrame:SetAlpha(1)
		else
			WorldMapFrame:SetAlpha(E.global.general.mapAlphaWhenMoving)
		end
	else
		WorldMapFrame:SetAlpha(1)
	end
end

function M:UpdateMapAlpha()
	if (E.global.general.mapAlphaWhenMoving >= 1) and self.MovingTimer then
		self:CancelTimer(self.MovingTimer)
		self.MovingTimer = nil
	elseif (E.global.general.mapAlphaWhenMoving < 1) and not self.MovingTimer then
		self.MovingTimer = self:ScheduleRepeatingTimer("CheckMovement", 0.1)
	end
end

function M:PVPMessageEnhancement(_, msg)
	if not E.db.general.enhancedPvpMessages then return end

	local _, instanceType = IsInInstance()
	if instanceType == "pvp" or instanceType == "arena" then
		RaidNotice_AddMessage(RaidBossEmoteFrame, msg, ChatTypeInfo.RAID_BOSS_EMOTE)
	end
end

local hideStatic = false
function M:AutoInvite(event, leaderName)
	if not E.db.general.autoAcceptInvite then return end

	if event == "PARTY_INVITE_REQUEST" then
		if MiniMapLFGFrame:IsShown() then return end -- Prevent losing que inside LFD if someone invites you to group
		if GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0 then return end
		hideStatic = true

		-- Update Guild and Friendlist
		local numFriends = GetNumFriends()
		if numFriends > 0 then ShowFriends() end
		if IsInGuild() then GuildRoster() end
		local inGroup = false

		for friendIndex = 1, numFriends do
			local friendName = gsub(GetFriendInfo(friendIndex), "-.*", "")
			if friendName == leaderName then
				AcceptGroup()
				inGroup = true
				break
			end
		end

		if not inGroup then
			for guildIndex = 1, GetNumGuildMembers(true) do
				local guildMemberName = gsub(GetGuildRosterInfo(guildIndex), "-.*", "")
				if guildMemberName == leaderName then
					AcceptGroup()
					inGroup = true
					break
				end
			end
		end
	elseif event == "PARTY_MEMBERS_CHANGED" and hideStatic == true then
		StaticPopup_Hide("PARTY_INVITE")
		hideStatic = false
	end
end

function M:ForceCVars()
	if not GetCVarBool("lockActionBars") and E.private.actionbar.enable then
		SetCVar("lockActionBars", 1)
	end
end

function M:Initialize()
	self.Initialized = true
	self:LoadRaidMarker()
	self:LoadLoot()
	self:LoadLootRoll()
	self:LoadChatBubbles()
	self:RegisterEvent("MERCHANT_SHOW")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "ErrorFrameToggle")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "ErrorFrameToggle")
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent("CHAT_MSG_BG_SYSTEM_HORDE", "PVPMessageEnhancement")
	self:RegisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE", "PVPMessageEnhancement")
	self:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL", "PVPMessageEnhancement")
	self:RegisterEvent("PARTY_INVITE_REQUEST", "AutoInvite")
	self:RegisterEvent("PARTY_MEMBERS_CHANGED", "AutoInvite")
	self:RegisterEvent("CVAR_UPDATE", "ForceCVars")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "ForceCVars")

	if E.global.general.mapAlphaWhenMoving < 1 then
		self.MovingTimer = self:ScheduleRepeatingTimer("CheckMovement", 0.1)
	end
end

local function InitializeCallback()
	M:Initialize()
end

E:RegisterModule(M:GetName(), InitializeCallback)