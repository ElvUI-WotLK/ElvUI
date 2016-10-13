local E, L, V, P, G = unpack(select(2, ...));
local UF = E:GetModule("UnitFrames");

local match = string.match;
local CreateFrame = CreateFrame;

local function CheckLeader(unit)
	if(unit == "player") then
		return IsPartyLeader();
	elseif(unit ~= "player" and (UnitInParty(unit) or UnitInRaid(unit))) then
		local gtype, index = unit:match("(%D+)(%d+)");
		index = tonumber(index);
		if(gtype == "party" and GetNumRaidMembers() == 0) then
			return GetPartyLeaderIndex() == index;
		elseif(gtype == "raid" and GetNumRaidMembers() > 0) then
			return select(2, GetRaidRosterInfo(index)) == 2;
		end
	end
end

local function UpdateOverride(self, event)
	local leader = self.Leader;
	if(leader.PreUpdate) then
		leader:PreUpdate();
	end

	local isLeader = CheckLeader(self.unit)

	if(isLeader) then
		leader:Show();
	else
		leader:Hide();
	end

	if(leader.PostUpdate) then
		return leader:PostUpdate(isLeader);
	end
end

function UF:Construct_RaidRoleFrames(frame)
	local anchor = CreateFrame('Frame', nil, frame.RaisedElementParent);
	frame.Leader = anchor:CreateTexture(nil, "OVERLAY");
	frame.Assistant = anchor:CreateTexture(nil, "OVERLAY");
	frame.MasterLooter = anchor:CreateTexture(nil, "OVERLAY");

	anchor:Size(24, 12);
	frame.Leader:Size(12);
	frame.Assistant:Size(12);
	frame.MasterLooter:Size(11);

	frame.Leader.Override = UpdateOverride;

	frame.Leader.PostUpdate = UF.RaidRoleUpdate;
	frame.Assistant.PostUpdate = UF.RaidRoleUpdate;
	frame.MasterLooter.PostUpdate = UF.RaidRoleUpdate;

	return anchor;
end

function UF:Configure_RaidRoleIcons(frame)
	local raidRoleFrameAnchor = frame.RaidRoleFramesAnchor;

	if(frame.db.raidRoleIcons.enable) then
		raidRoleFrameAnchor:Show()
		if(not frame:IsElementEnabled("Leader")) then
			frame:EnableElement("Leader");
			frame:EnableElement("MasterLooter");
			frame:EnableElement('Assistant');
		end

		raidRoleFrameAnchor:ClearAllPoints();
		if(frame.db.raidRoleIcons.position == "TOPLEFT") then
			raidRoleFrameAnchor:Point("LEFT", frame.Health, "TOPLEFT", 2, 0);
		else
			raidRoleFrameAnchor:Point("RIGHT", frame, "TOPRIGHT", -2, 0);
		end
	elseif(frame:IsElementEnabled("Leader")) then
		raidRoleFrameAnchor:Hide();
		frame:DisableElement("Leader");
		frame:DisableElement("MasterLooter");
		frame:DisableElement('Assistant');
	end
end

function UF:RaidRoleUpdate()
	local anchor = self:GetParent();
 	local frame = anchor:GetParent():GetParent()
 	local leader = frame.Leader
 	local assistant = frame.Assistant
	local masterLooter = frame.MasterLooter

	if(not leader or not masterLooter or not assistant) then return; end

	local db = frame.db
	local isLeader = leader:IsShown();
	local isMasterLooter = masterLooter:IsShown();
	local isAssist = assistant:IsShown();

	leader:ClearAllPoints();
	assistant:ClearAllPoints();
	masterLooter:ClearAllPoints();

	if(db and db.raidRoleIcons) then
		if(isLeader and db.raidRoleIcons.position == "TOPLEFT") then
			leader:Point("LEFT", anchor, "LEFT");
			masterLooter:Point("RIGHT", anchor, "RIGHT");
		elseif(isLeader and db.raidRoleIcons.position == "TOPRIGHT") then
			leader:Point("RIGHT", anchor, "RIGHT");
			masterLooter:Point("LEFT", anchor, "LEFT");
		elseif(isAssist and db.raidRoleIcons.position == "TOPLEFT") then
			assistant:Point("LEFT", anchor, "LEFT");
			masterLooter:Point("RIGHT", anchor, "RIGHT");
		elseif(isAssist and db.raidRoleIcons.position == "TOPRIGHT") then
			assistant:Point("RIGHT", anchor, "RIGHT");
			masterLooter:Point("LEFT", anchor, "LEFT");
		elseif(isMasterLooter and db.raidRoleIcons.position == "TOPLEFT") then
			masterLooter:Point("LEFT", anchor, "LEFT");
		else
			masterLooter:Point("RIGHT", anchor, "RIGHT");
		end
	end
end