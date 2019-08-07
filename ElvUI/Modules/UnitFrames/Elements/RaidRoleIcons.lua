local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule("UnitFrames")

--Lua functions
local match = string.match
local select, tonumber = select, tonumber
--WoW API / Variables
local CreateFrame = CreateFrame
local GetNumRaidMembers = GetNumRaidMembers
local GetRaidRosterInfo = GetRaidRosterInfo
local IsPartyLeader = IsPartyLeader
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid

local function CheckLeader(unit)
	if unit == "player" then
		return IsPartyLeader()
	elseif unit ~= "player" and (UnitInParty(unit) or UnitInRaid(unit)) then
		local gtype, index = match(unit, "(%D+)(%d+)")
		index = tonumber(index)
		if gtype == "party" and GetNumRaidMembers() == 0 then
			return GetPartyLeaderIndex() == index
		elseif gtype == "raid" and GetNumRaidMembers() > 0 then
			return select(2, GetRaidRosterInfo(index)) == 2
		end
	end
end

local function UpdateOverride(self)
	local element = self.LeaderIndicator

	if element.PreUpdate then
		element:PreUpdate()
	end

	local isLeader = CheckLeader(self.unit)

	if isLeader then
		element:Show()
	else
		element:Hide()
	end

	if element.PostUpdate then
		return element:PostUpdate(isLeader)
	end
end

function UF:Construct_RaidRoleFrames(frame)
	local anchor = CreateFrame("Frame", nil, frame.RaisedElementParent)
	frame.LeaderIndicator = anchor:CreateTexture(nil, "OVERLAY")
	frame.AssistantIndicator = anchor:CreateTexture(nil, "OVERLAY")
	frame.MasterLooterIndicator = anchor:CreateTexture(nil, "OVERLAY")

	anchor:Size(24, 12)
	frame.LeaderIndicator:Size(12)
	frame.AssistantIndicator:Size(12)
	frame.MasterLooterIndicator:Size(11)

	frame.LeaderIndicator.Override = UpdateOverride

	frame.LeaderIndicator.PostUpdate = UF.RaidRoleUpdate
	frame.AssistantIndicator.PostUpdate = UF.RaidRoleUpdate
	frame.MasterLooterIndicator.PostUpdate = UF.RaidRoleUpdate

	return anchor
end

function UF:Configure_RaidRoleIcons(frame)
	local raidRoleFrameAnchor = frame.RaidRoleFramesAnchor

	if frame.db.raidRoleIcons.enable then
		raidRoleFrameAnchor:Show()
		if not frame:IsElementEnabled("LeaderIndicator") then
			frame:EnableElement("LeaderIndicator")
			frame:EnableElement("MasterLooterIndicator")
			frame:EnableElement("AssistantIndicator")
		end

		raidRoleFrameAnchor:ClearAllPoints()
		if frame.db.raidRoleIcons.position == "TOPLEFT" then
			raidRoleFrameAnchor:Point("LEFT", frame.Health, "TOPLEFT", 2, 0)
		else
			raidRoleFrameAnchor:Point("RIGHT", frame, "TOPRIGHT", -2, 0)
		end
	elseif frame:IsElementEnabled("LeaderIndicator") then
		raidRoleFrameAnchor:Hide()
		frame:DisableElement("LeaderIndicator")
		frame:DisableElement("MasterLooterIndicator")
		frame:DisableElement("AssistantIndicator")
	end
end

function UF:RaidRoleUpdate()
	local anchor = self:GetParent()
	local frame = anchor:GetParent():GetParent()
	local leader = frame.LeaderIndicator
	local assistant = frame.AssistantIndicator
	local masterLooter = frame.MasterLooterIndicator

	if not leader or not masterLooter or not assistant then return; end

	local db = frame.db
	local isLeader = leader:IsShown()
	local isMasterLooter = masterLooter:IsShown()
	local isAssist = assistant:IsShown()

	leader:ClearAllPoints()
	assistant:ClearAllPoints()
	masterLooter:ClearAllPoints()

	if db and db.raidRoleIcons then
		if isLeader and db.raidRoleIcons.position == "TOPLEFT" then
			leader:Point("LEFT", anchor, "LEFT")
			masterLooter:Point("RIGHT", anchor, "RIGHT")
		elseif isLeader and db.raidRoleIcons.position == "TOPRIGHT" then
			leader:Point("RIGHT", anchor, "RIGHT")
			masterLooter:Point("LEFT", anchor, "LEFT")
		elseif isAssist and db.raidRoleIcons.position == "TOPLEFT" then
			assistant:Point("LEFT", anchor, "LEFT")
			masterLooter:Point("RIGHT", anchor, "RIGHT")
		elseif isAssist and db.raidRoleIcons.position == "TOPRIGHT" then
			assistant:Point("RIGHT", anchor, "RIGHT")
			masterLooter:Point("LEFT", anchor, "LEFT")
		elseif isMasterLooter and db.raidRoleIcons.position == "TOPLEFT" then
			masterLooter:Point("LEFT", anchor, "LEFT")
		else
			masterLooter:Point("RIGHT", anchor, "RIGHT")
		end
	end
end