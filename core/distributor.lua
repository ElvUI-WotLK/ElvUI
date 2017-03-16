local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local D = E:NewModule("Distributor", "AceEvent-3.0","AceTimer-3.0","AceComm-3.0","AceSerializer-3.0")
local LibCompress = LibStub:GetLibrary("LibCompress");
local LibBase64 = LibStub("LibBase64-1.0-ElvUI");

local tonumber, type, pcall, loadstring = tonumber, type, pcall, loadstring;
local len, format, split, find = string.len, string.format, string.split, string.find;

local CreateFrame = CreateFrame;
local GetNumRaidMembers, UnitInRaid = GetNumRaidMembers, UnitInRaid;
local GetNumPartyMembers, UnitInParty = GetNumPartyMembers, UnitInParty;
local ACCEPT, CANCEL, YES, NO = ACCEPT, CANCEL, YES, NO;

----------------------------------
-- CONSTANTS
----------------------------------

local REQUEST_PREFIX = "ELVUI_REQUEST"
local REPLY_PREFIX = "ELVUI_REPLY"
local TRANSFER_PREFIX = "ELVUI_TRANSFER"
local TRANSFER_COMPLETE_PREFIX = "ELVUI_COMPLETE"

-- The active downloads
local Downloads = {}
local Uploads = {}

function D:Initialize()
	self:RegisterComm(REQUEST_PREFIX)
	self:RegisterEvent("CHAT_MSG_ADDON")

	self.statusBar = CreateFrame("StatusBar", "ElvUI_Download", UIParent)
	E:RegisterStatusBar(self.statusBar);
	self.statusBar:CreateBackdrop("Default")
	self.statusBar:SetStatusBarTexture(E.media.normTex)
	self.statusBar:SetStatusBarColor(0.95, 0.15, 0.15)
	self.statusBar:Size(250, 18)
	self.statusBar.text = self.statusBar:CreateFontString(nil, "OVERLAY")
	self.statusBar.text:FontTemplate()
	self.statusBar.text:SetPoint("CENTER")
	self.statusBar:Hide()
end

-- Used to start uploads
function D:Distribute(target, otherServer, isGlobal)
	local profileKey, data;
	if not isGlobal then
		if ElvDB.profileKeys then
			profileKey = ElvDB.profileKeys[E.myname.." - "..E.myrealm]
		end

		data = ElvDB.profiles[profileKey]
	else
		profileKey = "global"
		data = ElvDB.global
	end

	if not data or not profileKey then return end

	local serialData = self:Serialize(data)
	local length = len(serialData)
	local message = format("%s:%d:%s", profileKey, length, target)

	Uploads[profileKey] = {
		serialData = serialData,
		target = target,
	}

	if otherServer then
		local numParty, numRaid = GetNumPartyMembers(), GetNumRaidMembers();
		if(numRaid > 0 and UnitInRaid("target")) then
			self:SendCommMessage(REQUEST_PREFIX, message, "RAID");
		elseif(numParty > 0 and UnitInParty("target")) then
			self:SendCommMessage(REQUEST_PREFIX, message, "PARTY");
		else
			E:Print(L["Must be in group with the player if he isn't on the same server as you."])
			return
		end
	else
		self:SendCommMessage(REQUEST_PREFIX, message, "WHISPER", target)
	end
	self:RegisterComm(REPLY_PREFIX)
	E:StaticPopup_Show("DISTRIBUTOR_WAITING")
end

function D:CHAT_MSG_ADDON(_, _, message, _, sender)
	if not Downloads[sender] then return end
	local cur = len(message)
	local max = Downloads[sender].length
	Downloads[sender].current = Downloads[sender].current + cur

	if Downloads[sender].current > max then
		Downloads[sender].current = max
	end

	self.statusBar:SetValue(Downloads[sender].current)
end

function D:OnCommReceived(prefix, msg, dist, sender)
	if prefix == REQUEST_PREFIX then
		local profile, length, sendTo = split(":", msg)

		if dist ~= "WHISPER" and sendTo ~= E.myname then
			return
		end

		if self.statusBar:IsShown() then
			self:SendCommMessage(REPLY_PREFIX, profile..":NO", dist, sender)
			return
		end

		local textString = format(L["%s is attempting to share the profile %s with you. Would you like to accept the request?"], sender, profile)
		if profile == "global" then
			textString = format(L["%s is attempting to share his filters with you. Would you like to accept the request?"], sender)
		end

		E.PopupDialogs["DISTRIBUTOR_RESPONSE"] = {
			text = textString,
			OnAccept = function()
				self.statusBar:SetMinMaxValues(0, length)
				self.statusBar:SetValue(0)
				self.statusBar.text:SetFormattedText(L["Data From: %s"], sender)
				E:StaticPopupSpecial_Show(self.statusBar)
				self:SendCommMessage(REPLY_PREFIX, profile..":YES", dist, sender)
			end,
			OnCancel = function()
				self:SendCommMessage(REPLY_PREFIX, profile..":NO", dist, sender)
			end,
			button1 = ACCEPT,
			button2 = CANCEL,
			timeout = 32,
			whileDead = 1,
			hideOnEscape = 1,
		}
		E:StaticPopup_Show("DISTRIBUTOR_RESPONSE")

		Downloads[sender] = {
			current = 0,
			length = tonumber(length),
			profile = profile,
		}

		self:RegisterComm(TRANSFER_PREFIX)
	elseif prefix == REPLY_PREFIX then
		self:UnregisterComm(REPLY_PREFIX)
		E:StaticPopup_Hide("DISTRIBUTOR_WAITING")

		local profileKey, response = split(":", msg)
		if response == "YES" then
			self:RegisterComm(TRANSFER_COMPLETE_PREFIX)
			self:SendCommMessage(TRANSFER_PREFIX, Uploads[profileKey].serialData, dist, Uploads[profileKey].target)
			Uploads[profileKey] = nil
		else
			E:StaticPopup_Show("DISTRIBUTOR_REQUEST_DENIED")
			Uploads[profileKey] = nil
		end
	elseif prefix == TRANSFER_PREFIX then
		self:UnregisterComm(TRANSFER_PREFIX)
		E:StaticPopupSpecial_Hide(self.statusBar)

		local profileKey = Downloads[sender].profile
		local success, data = self:Deserialize(msg)

		if success then
			local textString = format(L["Profile download complete from %s, would you like to load the profile %s now?"], sender, profileKey)

			if profileKey == "global" then
				textString = format(L["Filter download complete from %s, would you like to apply changes now?"], sender)
			else
				if not ElvDB.profiles[profileKey] then
					ElvDB.profiles[profileKey] = data
				else
					textString = format(L["Profile download complete from %s, but the profile %s already exists. Change the name or else it will overwrite the existing profile."], sender, profileKey)
					E.PopupDialogs["DISTRIBUTOR_CONFIRM"] = {
						text = textString,
						button1 = ACCEPT,
						hasEditBox = 1,
						editBoxWidth = 350,
						maxLetters = 127,
						OnAccept = function(self)
							ElvDB.profiles[self.editBox:GetText()] = data
							LibStub("AceAddon-3.0"):GetAddon("ElvUI").data:SetProfile(self.editBox:GetText())
							E:UpdateAll(true)
							Downloads[sender] = nil
						end,
						OnShow = function(self) self.editBox:SetText(profileKey) self.editBox:SetFocus() end,
						timeout = 0,
						exclusive = 1,
						whileDead = 1,
						hideOnEscape = 1,
						preferredIndex = 3
					}

					E:StaticPopup_Show("DISTRIBUTOR_CONFIRM")
					self:SendCommMessage(TRANSFER_COMPLETE_PREFIX, "COMPLETE", dist, sender)
					return
				end
			end

			E.PopupDialogs["DISTRIBUTOR_CONFIRM"] = {
				text = textString,
				OnAccept = function()
					if profileKey == "global" then
						E:CopyTable(ElvDB.global, data)
						E:UpdateAll(true)
					else
						LibStub("AceAddon-3.0"):GetAddon("ElvUI").data:SetProfile(profileKey)
					end
					Downloads[sender] = nil
				end,
				OnCancel = function()
					Downloads[sender] = nil
				end,
				button1 = YES,
				button2 = NO,
				whileDead = 1,
				hideOnEscape = 1,
			}

			E:StaticPopup_Show("DISTRIBUTOR_CONFIRM")
			self:SendCommMessage(TRANSFER_COMPLETE_PREFIX, "COMPLETE", dist, sender)
		else
			E:StaticPopup_Show("DISTRIBUTOR_FAILED")
			self:SendCommMessage(TRANSFER_COMPLETE_PREFIX, "FAILED", dist, sender)
		end
	elseif prefix == TRANSFER_COMPLETE_PREFIX then
		self:UnregisterComm(TRANSFER_COMPLETE_PREFIX)
		if msg == "COMPLETE" then
			E:StaticPopup_Show("DISTRIBUTOR_SUCCESS")
		else
			E:StaticPopup_Show("DISTRIBUTOR_FAILED")
		end
	end
end

local function GetProfileData(profileType)
	if(not profileType or type(profileType) ~= "string") then
		E:Print("Bad argument #1 to 'GetProfileData' (string expected)");
		return;
	end

	local profileKey;
	local profileData = {};

	if(profileType == "profile") then
		if(ElvDB.profileKeys) then
			profileKey = ElvDB.profileKeys[E.myname.." - "..E.myrealm];
		end

		profileData = E:CopyTable(profileData , ElvDB.profiles[profileKey])
		profileData = E:RemoveTableDuplicates(profileData, P);
	elseif(profileType == "private") then
		local privateProfileKey = E.myname.." - "..E.myrealm;
		profileKey = "private";

		profileData = E:CopyTable(profileData, ElvPrivateDB.profiles[privateProfileKey]);
		profileData = E:RemoveTableDuplicates(profileData, V);
	elseif(profileType == "global") then
		profileKey = "global";

		profileData = E:CopyTable(profileData, ElvDB.global);
		profileData = E:RemoveTableDuplicates(profileData, G);
	elseif(profileType == "filtersNP") then
		profileKey = "filtersNP";

		profileData["nameplates"] = {};
		profileData["nameplates"]["filter"] = {};
		profileData["nameplates"]["filter"] = E:CopyTable(profileData["nameplates"]["filter"], ElvDB.global.nameplates.filter);
		profileData = E:RemoveTableDuplicates(profileData, G);
	elseif(profileType == "filtersUF") then
		profileKey = "filtersUF";

		profileData["unitframe"] = {};
		profileData["unitframe"]["aurafilters"] = {};
		profileData["unitframe"]["aurafilters"] = E:CopyTable(profileData["unitframe"]["aurafilters"], ElvDB.global.unitframe.aurafilters);
		profileData["unitframe"]["buffwatch"] = {};
		profileData["unitframe"]["buffwatch"] = E:CopyTable(profileData["unitframe"]["buffwatch"], ElvDB.global.unitframe.buffwatch);
		profileData = E:RemoveTableDuplicates(profileData, G);
	elseif(profileType == "filtersAll") then
		profileKey = "filtersAll";

		profileData["nameplates"] = {};
		profileData["nameplates"]["filter"] = {};
		profileData["nameplates"]["filter"] = E:CopyTable(profileData["nameplates"]["filter"], ElvDB.global.nameplates.filter);
		profileData["unitframe"] = {};
		profileData["unitframe"]["aurafilters"] = {};
		profileData["unitframe"]["aurafilters"] = E:CopyTable(profileData["unitframe"]["aurafilters"], ElvDB.global.unitframe.aurafilters);
		profileData["unitframe"]["buffwatch"] = {};
		profileData["unitframe"]["buffwatch"] = E:CopyTable(profileData["unitframe"]["buffwatch"], ElvDB.global.unitframe.buffwatch);
		profileData = E:RemoveTableDuplicates(profileData, G);
	end

	return profileKey, profileData;
end

local function GetProfileExport(profileType, exportFormat)
	local profileExport, exportString;
	local profileKey, profileData = GetProfileData(profileType);

	if(not profileKey or not profileData or (profileData and type(profileData) ~= "table")) then
		E:Print("Error getting data from 'GetProfileData'");
		return;
	end

	if(exportFormat == "text") then
		local serialData = D:Serialize(profileData);

		exportString = D:CreateProfileExport(serialData, profileType, profileKey);

		local compressedData = LibCompress:Compress(exportString);
		local encodedData = LibBase64:Encode(compressedData);
		profileExport = encodedData;
	elseif(exportFormat == "luaTable") then
		exportString = E:TableToLuaString(profileData);
		profileExport = D:CreateProfileExport(exportString, profileType, profileKey);
	elseif(exportFormat == "luaPlugin") then
		profileExport = E:ProfileTableToPluginFormat(profileData, profileType);
	end

	return profileKey, profileExport;
end

function D:CreateProfileExport(dataString, profileType, profileKey)
	local returnString;

	if(profileType == "profile") then
		returnString = format("%s::%s::%s", dataString, profileType, profileKey);
	else
		returnString = format("%s::%s", dataString, profileType);
	end

	return returnString;
end

function D:GetImportStringType(dataString)
	local stringType = "";

	if(LibBase64:IsBase64(dataString)) then
		stringType = "Base64";
	elseif(find(dataString, "{")) then
		stringType = "Table";
	end

	return stringType;
end

function D:Decode(dataString)
	local profileInfo, profileType, profileKey, profileData, message;
	local stringType = self:GetImportStringType(dataString);

	if(stringType == "Base64") then
		local decodedData = LibBase64:Decode(dataString);
		local decompressedData, message = LibCompress:Decompress(decodedData);

		if(not decompressedData) then
			E:Print("Error decompressing data:", message);
			return;
		end

		local serializedData, success;
		serializedData, profileInfo = E:StringSplitMultiDelim(decompressedData, "^^::");

		if not profileInfo then
			E:Print("Error importing profile. String is invalid or corrupted!")
			return
		end

		serializedData = format("%s%s", serializedData, "^^");
		profileType, profileKey = E:StringSplitMultiDelim(profileInfo, "::");
		success, profileData = D:Deserialize(serializedData);

		if(not success) then
			E:Print("Error deserializing:", profileData);
			return;
		end
	elseif(stringType == "Table") then
		local profileDataAsString;
		profileDataAsString, profileInfo = E:StringSplitMultiDelim(dataString, "}::");
		profileDataAsString = format("%s%s", profileDataAsString, "}");
		profileType, profileKey = E:StringSplitMultiDelim(profileInfo, "::");

		if(not profileDataAsString) then
			E:Print("Error extracting profile data. Invalid import string!");
			return;
		end

		local profileToTable = loadstring(format("%s %s", "return", profileDataAsString));
		if(profileToTable) then
			message, profileData = pcall(profileToTable);
		end

		if(not profileData or type(profileData) ~= "table") then
			E:Print("Error converting lua string to table:", message);
			return;
		end
	end

	return profileType, profileKey, profileData;
end

local function SetImportedProfile(profileType, profileKey, profileData, force)
	D.profileType = nil;
	D.profileKey = nil;
	D.profileData = nil;

	if(profileType == "profile") then
		if(not ElvDB.profiles[profileKey] or force) then
			if(force and E.data.keys.profile == profileKey) then
				local tempKey = profileKey.."_Temp";
				E.data.keys.profile = tempKey;
			end
			ElvDB.profiles[profileKey] = profileData;
			E.data:SetProfile(profileKey);
		else
			D.profileType = profileType;
			D.profileKey = profileKey;
			D.profileData = profileData;
			E:StaticPopup_Show("IMPORT_PROFILE_EXISTS");

			return;
		end
	elseif(profileType == "private") then
		local profileKey = ElvPrivateDB.profileKeys[E.myname.." - "..E.myrealm];
		ElvPrivateDB.profiles[profileKey] = profileData;
		E:StaticPopup_Show("IMPORT_RL");

	elseif(profileType == "global") then
		E:CopyTable(ElvDB.global, profileData);
		E:StaticPopup_Show("IMPORT_RL");
	elseif(profileType == "filtersNP") then
		E:CopyTable(ElvDB.global.nameplates, profileData.nameplates);
	elseif(profileType == "filtersUF") then
		E:CopyTable(ElvDB.global.unitframe, profileData.unitframe);
	elseif(profileType == "filtersAll") then
		E:CopyTable(ElvDB.global.nameplates, profileData.nameplates);
		E:CopyTable(ElvDB.global.unitframe, profileData.unitframe);
	end

	E:UpdateAll(true);
end

function D:ExportProfile(profileType, exportFormat)
	if(not profileType or not exportFormat) then
		E:Print("Bad argument to 'ExportProfile' (string expected)");
		return;
	end

	local profileKey, profileExport = GetProfileExport(profileType, exportFormat);
	return profileKey, profileExport;
end

function D:ImportProfile(dataString)
	local profileType, profileKey, profileData = self:Decode(dataString);

	if(not profileData or type(profileData) ~= "table") then
		E:Print("Error: something went wrong when converting string to table!");
		return;
	end

	if(profileType and ((profileType == "profile" and profileKey) or profileType ~= "profile")) then
		SetImportedProfile(profileType, profileKey, profileData);
	end

	return true;
end

E.PopupDialogs["DISTRIBUTOR_SUCCESS"] = {
	text = L["Your profile was successfully recieved by the player."],
	whileDead = 1,
	hideOnEscape = 1,
	button1 = OKAY,
}

E.PopupDialogs["DISTRIBUTOR_WAITING"] = {
	text = L["Profile request sent. Waiting for response from player."],
	whileDead = 1,
	hideOnEscape = 1,
	timeout = 35,
}

E.PopupDialogs["DISTRIBUTOR_REQUEST_DENIED"] = {
	text = L["Request was denied by user."],
	whileDead = 1,
	hideOnEscape = 1,
	button1 = OKAY,
}

E.PopupDialogs["DISTRIBUTOR_FAILED"] = {
	text = L["Lord! It's a miracle! The download up and vanished like a fart in the wind! Try Again!"],
	whileDead = 1,
	hideOnEscape = 1,
	button1 = OKAY,
}

E.PopupDialogs["DISTRIBUTOR_RESPONSE"] = {}
E.PopupDialogs["DISTRIBUTOR_CONFIRM"] = {}

E.PopupDialogs["IMPORT_PROFILE_EXISTS"] = {
	text = L["The profile you tried to import already exists. Choose a new name or accept to overwrite the existing profile."],
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	editBoxWidth = 350,
	maxLetters = 127,
	OnAccept = function(self)
		local profileType = D.profileType;
		local profileKey = self.editBox:GetText();
		local profileData = D.profileData;
		SetImportedProfile(profileType, profileKey, profileData, true);
	end,
	EditBoxOnTextChanged = function(self)
		if(self:GetText() == "") then
			self:GetParent().button1:Disable();
		else
			self:GetParent().button1:Enable();
		end
	end,
	OnShow = function(self) self.editBox:SetText(D.profileKey); self.editBox:SetFocus(); end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = true,
	preferredIndex = 3
};

E.PopupDialogs["IMPORT_RL"] = {
	text = L["You have imported settings which may require a UI reload to take effect. Reload now?"],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() ReloadUI(); end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
	preferredIndex = 3
};

E:RegisterModule(D:GetName())