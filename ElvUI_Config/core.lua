local E, L, V, P, G = unpack(ElvUI);
local D = E:GetModule("Distributor");
local AceGUI = LibStub("AceGUI-3.0");

local pairs = pairs;
local tsort, tinsert = table.sort, table.insert;
local format = string.format;

local UnitExists = UnitExists;
local UnitIsFriend = UnitIsFriend;
local UnitIsPlayer = UnitIsPlayer;
local UnitIsUnit = UnitIsUnit;
local UnitName = UnitName;

local DEFAULT_WIDTH = 890;
local DEFAULT_HEIGHT = 651;
local AC = LibStub("AceConfig-3.0-ElvUI");
local ACD = LibStub("AceConfigDialog-3.0-ElvUI");
local ACR = LibStub("AceConfigRegistry-3.0-ElvUI");

AC:RegisterOptionsTable("ElvUI", E.Options);
ACD:SetDefaultSize("ElvUI", DEFAULT_WIDTH, DEFAULT_HEIGHT);

function E:RefreshGUI()
	self:RefreshCustomTextsConfigs();
	ACR:NotifyChange("ElvUI");
end

E.Options.args = {
	ElvUI_Header = {
		order = 1,
		type = "header",
		name = L["Version"] .. format(": |cff99ff33%s|r", E.version),
		width = "full"
	},
	LoginMessage = {
		order = 2,
		type = "toggle",
		name = L["Login Message"],
		get = function(info) return E.db.general.loginmessage; end,
		set = function(info, value) E.db.general.loginmessage = value; end
	},
	ToggleTutorial = {
		order = 3,
		type = "execute",
		name = L["Toggle Tutorials"],
		func = function() E:Tutorials(true); E:ToggleConfig(); end
	},
	Install = {
		order = 4,
		type = "execute",
		name = L["Install"],
		desc = L["Run the installation process."],
		func = function() E:Install(); E:ToggleConfig(); end
	},
	ToggleAnchors = {
		order = 5,
		type = "execute",
		name = L["Toggle Anchors"],
		desc = L["Unlock various elements of the UI to be repositioned."],
		func = function() E:ToggleConfigMode(); end
	},
	ResetAllMovers = {
		order = 6,
		type = "execute",
		name = L["Reset Anchors"],
		desc = L["Reset all frames to their original positions."],
		func = function() E:ResetUI(); end
	}
};

local DONATOR_STRING = "";
local DEVELOPER_STRING = "";
local TESTER_STRING = "";
local LINE_BREAK = "\n";
local DONATORS = {
	"Dandruff",
	"Tobur/Tarilya",
	"Netu",
	"Alluren",
	"Thorgnir",
	"Emalal",
	"Bendmeova",
	"Curl",
	"Zarac",
	"Emmo",
	"Oz",
	"Hawké",
	"Aynya",
	"Tahira",
	"Karsten Lumbye Thomsen",
	"Thomas B. aka Pitschiqüü",
	"Sea Garnet",
	"Paul Storry",
	"Azagar",
	"Archury",
	"Donhorn",
	"Woodson Harmon",
	"Phoenyx",
	"Feat",
	"Konungr",
	"Leyrin",
	"Dragonsys",
	"Tkalec",
	"Paavi",
	"Giorgio",
	"Bearscantank",
	"Eidolic",
	"Cosmo",
	"Adorno",
	"Domoaligato",
	"Smorg",
	"Pyrokee",
	"Portable",
	"Ithilyn"
};

local DEVELOPERS = {
	"Tukz",
	"Haste",
	"Nightcracker",
	"Omega1970",
	"Hydrazine"
};

local TESTERS = {
	"Tukui Community",
	"|cffF76ADBSarah|r - For Sarahing",
	"Affinity",
	"Modarch",
	"Bladesdruid",
	"Tirain",
	"Phima",
	"Veiled",
	"Blazeflack",
	"Repooc",
	"Darth Predator",
	"Alex",
	"Nidra",
	"Kurhyus",
	"BuG",
	"Yachanay",
	"Catok"
}

tsort(DONATORS, function(a, b) return a < b end);
for _, donatorName in pairs(DONATORS) do
	tinsert(E.CreditsList, donatorName);
	DONATOR_STRING = DONATOR_STRING .. LINE_BREAK .. donatorName;
end

tsort(DEVELOPERS, function(a,b) return a < b end);
for _, devName in pairs(DEVELOPERS) do
	tinsert(E.CreditsList, devName);
	DEVELOPER_STRING = DEVELOPER_STRING .. LINE_BREAK .. devName;
end

tsort(TESTERS, function(a, b) return a < b end)
for _, testerName in pairs(TESTERS) do
	tinsert(E.CreditsList, testerName);
	TESTER_STRING = TESTER_STRING .. LINE_BREAK .. testerName;
end

E.Options.args.credits = {
	type = "group",
	name = L["Credits"],
	order = -1,
	args = {
		text = {
			order = 1,
			type = "description",
			name = L["ELVUI_CREDITS"] .. "\n\n" .. L["Coding:"] .. DEVELOPER_STRING .. "\n\n" .. L["Testing:"] .. TESTER_STRING .. "\n\n" .. L["Donations:"] .. DONATOR_STRING
		}
	}
};

local profileTypeItems = {
	["profile"] = L["Profile"],
	["private"] = L["Private (Character Settings)"],
	["global"] = L["Global (Account Settings)"],
	["filtersNP"] = L["Filters (NamePlates)"],
	["filtersUF"] = L["Filters (UnitFrames)"],
	["filtersAll"] = L["Filters (All)"]
};

local profileTypeListOrder = {
	"profile",
	"private",
	"global",
	"filtersNP",
	"filtersUF",
	"filtersAll"
};

local exportTypeItems = {
	["text"] = L["Text"],
	["luaTable"] = L["Table"],
	["luaPlugin"] = L["Plugin"]
};

local exportTypeListOrder = {
	"text",
	"luaTable",
	"luaPlugin"
};

local exportString = "";
local function ExportImport_Open(mode)
	local frame = AceGUI:Create("Frame");
	frame:SetTitle("");
	frame:EnableResize(false);
	frame:SetWidth(800);
	frame:SetHeight(600);
	frame.frame:SetFrameStrata("FULLSCREEN_DIALOG");
	frame:SetLayout("flow");

	local box = AceGUI:Create("MultiLineEditBox");
	box:SetNumLines(30);
	box:DisableButton(true);
	box:SetWidth(800);
	box:SetLabel("");
	frame:AddChild(box);
	box.editBox.OnTextChangedOrig = box.editBox:GetScript("OnTextChanged");
	box.editBox.OnCursorChangedOrig = box.editBox:GetScript("OnCursorChanged");
	box.editBox:SetScript("OnCursorChanged", nil);

	local label1 = AceGUI:Create("Label");
	local font = GameFontHighlightSmall:GetFont();
	label1:SetFont(font, 14);
	label1:SetText(" ");
	label1:SetWidth(800);
	frame:AddChild(label1);

	local label2 = AceGUI:Create("Label");
	local font = GameFontHighlightSmall:GetFont();
	label2:SetFont(font, 14);
	label2:SetText(" \n ")
	label2:SetWidth(800);
	frame:AddChild(label2);

	if(mode == "export") then
		frame:SetTitle(L["Export Profile"]);

		local profileTypeDropdown = AceGUI:Create("Dropdown");
		profileTypeDropdown:SetMultiselect(false);
		profileTypeDropdown:SetLabel(L["Choose What To Export"]);
		profileTypeDropdown:SetList(profileTypeItems, profileTypeListOrder);
		profileTypeDropdown:SetValue("profile");
		frame:AddChild(profileTypeDropdown);

		local exportFormatDropdown = AceGUI:Create("Dropdown");
		exportFormatDropdown:SetMultiselect(false);
		exportFormatDropdown:SetLabel(L["Choose Export Format"]);
		exportFormatDropdown:SetList(exportTypeItems, exportTypeListOrder);
		exportFormatDropdown:SetValue("text");
		exportFormatDropdown:SetWidth(150);
		frame:AddChild(exportFormatDropdown);

		local exportButton = AceGUI:Create("Button");
		exportButton:SetText(L["Export Now"]);
		exportButton:SetAutoWidth(true);
		local function OnClick(self)
			label1:SetText(" ");
			label2:SetText(" ");

			local profileType, exportFormat = profileTypeDropdown:GetValue(), exportFormatDropdown:GetValue();
			local profileKey, profileExport = D:ExportProfile(profileType, exportFormat);
			if(not profileKey or not profileExport) then
				label1:SetText(L["Error exporting profile!"]);
			else
				label1:SetText(format("%s: %s%s|r", L["Exported"], E.media.hexvaluecolor, profileTypeItems[profileType]));
				if(profileType == "profile") then
					label2:SetText(format("%s: %s%s|r", L["Profile Name"], E.media.hexvaluecolor, profileKey));
				end
			end
			box:SetText(profileExport);
			box.editBox:HighlightText();
			box:SetFocus();
			exportString = profileExport;
		end
		exportButton:SetCallback("OnClick", OnClick);
		frame:AddChild(exportButton);

		box.editBox:SetScript("OnChar", function() box:SetText(exportString); box.editBox:HighlightText(); end);
		box.editBox:SetScript("OnTextChanged", function(self, userInput)
			if(userInput) then
				box:SetText(exportString);
				box.editBox:HighlightText();
			end
		end);
	elseif(mode == "import") then
		frame:SetTitle(L["Import Profile"]);
		local importButton = AceGUI:Create("Button-ElvUI");
		importButton:SetDisabled(true);
		importButton:SetText(L["Import Now"]);
		importButton:SetAutoWidth(true);
		importButton:SetCallback("OnClick", function()
			label1:SetText(" ");
			label2:SetText(" ");

			local text;
			local success = D:ImportProfile(box:GetText());
			if(success) then
				text = L["Profile imported successfully!"];
			else
				text = L["Error decoding data. Import string may be corrupted!"];
			end
			label1:SetText(text);
		end)
		frame:AddChild(importButton);

		local decodeButton = AceGUI:Create("Button-ElvUI");
		decodeButton:SetDisabled(true);
		decodeButton:SetText(L["Decode Text"]);
		decodeButton:SetAutoWidth(true);
		decodeButton:SetCallback("OnClick", function()
			label1:SetText(" ");
			label2:SetText(" ");
			local decodedText;
			local profileType, profileKey, profileData = D:Decode(box:GetText());
			if(profileData) then
				decodedText = E:TableToLuaString(profileData);
			end
			local importText = D:CreateProfileExport(decodedText, profileType, profileKey);
			box:SetText(importText)
		end)
		frame:AddChild(decodeButton);

		local oldText = "";
		local function OnTextChanged()
			local text = box:GetText();
			if(text == "") then
				label1:SetText(" ");
				label2:SetText(" ");
				importButton:SetDisabled(true);
				decodeButton:SetDisabled(true)
			elseif(oldText ~= text) then
				local stringType = D:GetImportStringType(text);
				if(stringType == "Base64") then
					decodeButton:SetDisabled(false);
				else
					decodeButton:SetDisabled(true);
				end

				local profileType, profileKey = D:Decode(text);
				if not profileType or (profileType and profileType == "profile" and not profileKey) then
					label1:SetText(L["Error decoding data. Import string may be corrupted!"]);
					label2:SetText(" ");
					importButton:SetDisabled(true);
					decodeButton:SetDisabled(true);
				else
					label1:SetText(format("%s: %s%s|r", L["Importing"], E.media.hexvaluecolor, profileTypeItems[profileType] or ""));
					if(profileType == "profile") then
						label2:SetText(format("%s: %s%s|r", L["Profile Name"], E.media.hexvaluecolor, profileKey));
					end
					importButton:SetDisabled(false);
				end

				box.scrollFrame:UpdateScrollChildRect()
				box.scrollFrame:SetVerticalScroll(box.scrollFrame:GetVerticalScrollRange())

				oldText = text;
			end
		end

		box.editBox:SetFocus();
		box.editBox:SetScript("OnChar", nil);
		box.editBox:SetScript("OnTextChanged", OnTextChanged);
	end

	frame:SetCallback("OnClose", function(widget)
		box.editBox:SetScript("OnChar", nil);
		box.editBox:SetScript("OnTextChanged", box.editBox.OnTextChangedOrig);
		box.editBox:SetScript("OnCursorChanged", box.editBox.OnCursorChangedOrig);
		box.editBox.OnTextChangedOrig = nil;
		box.editBox.OnCursorChangedOrig = nil;

		exportString = "";

		AceGUI:Release(widget);
		ACD:Open("ElvUI");
	end);

	label1:SetText(" ");
	label2:SetText(" ");

	ACD:Close("ElvUI");

	GameTooltip_Hide();
end

E.Options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(E.data);
AC:RegisterOptionsTable("ElvProfiles", E.Options.args.profiles);
E.Options.args.profiles.order = -10;

LibStub("LibDualSpec-1.0"):EnhanceOptions(E.Options.args.profiles, E.data);

if(not E.Options.args.profiles.plugins) then
	E.Options.args.profiles.plugins = {};
end

E.Options.args.profiles.plugins["ElvUI"] = {
	spacer = {
		order = 89,
		type = "description",
		name = "\n\n"
	},
	desc = {
		order = 90,
		type = "description",
		name = L["This feature will allow you to transfer settings to other characters."]
	},
	distributeProfile = {
		order = 91,
		name = L["Share Current Profile"],
		desc = L["Sends your current profile to your target."],
		type = "execute",
		func = function()
			if(not UnitExists("target") or not UnitIsPlayer("target") or not UnitIsFriend("player", "target") or UnitIsUnit("player", "target")) then
				E:Print(L["You must be targeting a player."]);
				return;
			end
			local name, server = UnitName("target");
			if(name and (not server or server == "")) then
				D:Distribute(name);
			elseif(server) then
				D:Distribute(name, true);
			end
		end
	},
	distributeGlobal = {
		order = 92,
		type = "execute",
		name = L["Share Filters"],
		desc = L["Sends your filter settings to your target."],
		func = function()
			if(not UnitExists("target") or not UnitIsPlayer("target") or not UnitIsFriend("player", "target") or UnitIsUnit("player", "target")) then
				E:Print(L["You must be targeting a player."]);
				return;
			end
			local name, server = UnitName("target")
			if(name and (not server or server == "")) then
				D:Distribute(name, false, true);
			elseif(server) then
				D:Distribute(name, true, true);
			end
		end,
	},
	spacer2 = {
		order = 93,
		type = "description",
		name = ""
	},
	exportProfile = {
		order = 94,
		type = "execute",
		name = L["Export Profile"],
		func = function() ExportImport_Open("export"); end
	},
	importProfile = {
		order = 95,
		type = "execute",
		name = L["Import Profile"],
		func = function() ExportImport_Open("import"); end
	}
};

