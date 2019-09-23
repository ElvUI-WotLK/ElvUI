local E = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local D = E:GetModule("Distributor")

local _, Engine = ...
Engine[1] = {}
Engine[2] = E.Libs.ACL:GetLocale("ElvUI", E.global.general.locale or "enUS")
local C, L = Engine[1], Engine[2]

local format = string.format

C.Values = {
	FontFlags = {
		["NONE"] = L["NONE"],
		["OUTLINE"] = "OUTLINE",
		["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
		["THICKOUTLINE"] = "THICKOUTLINE"
	}
}

E:AddLib("AceGUI", "AceGUI-3.0")
E:AddLib("AceConfig", "AceConfig-3.0-ElvUI")
E:AddLib("AceConfigDialog", "AceConfigDialog-3.0-ElvUI")
E:AddLib("AceConfigRegistry", "AceConfigRegistry-3.0-ElvUI")
E:AddLib("AceDBOptions", "AceDBOptions-3.0")

local UnitName = UnitName
local UnitExists = UnitExists
local UnitIsUnit = UnitIsUnit
local UnitIsFriend = UnitIsFriend
local UnitIsPlayer = UnitIsPlayer
local GameTooltip_Hide = GameTooltip_Hide
local GameFontHighlightSmall = _G.GameFontHighlightSmall

--Function we can call on profile change to update GUI
function E:RefreshGUI()
	E:RefreshCustomTextsConfigs()
	E.Libs.AceConfigRegistry:NotifyChange("ElvUI")
end

E.Libs.AceConfig:RegisterOptionsTable("ElvUI", E.Options)
E.Libs.AceConfigDialog:SetDefaultSize("ElvUI", E:GetConfigDefaultSize())

E.Options.args = {
	ElvUI_Header = {
		order = 1,
		type = "header",
		name = format("%s: |cff99ff33%s|r", L["Version"], E.version),
		width = "full"
	},
	RepositionWindow = {
		order = 2,
		type = "execute",
		name = L["Reposition Window"],
		desc = L["Reset the size and position of this frame."],
		customWidth = 175,
		func = function()
			E:UpdateConfigSize(true)
		end
	},
	ToggleTutorial = {
		order = 3,
		type = "execute",
		name = L["Toggle Tutorials"],
		customWidth = 150,
		func = function()
			E:Tutorials(true)
			E:ToggleOptionsUI()
		end
	},
	Install = {
		order = 4,
		type = "execute",
		name = L["Install"],
		customWidth = 100,
		desc = L["Run the installation process."],
		func = function()
			E:Install()
			E:ToggleOptionsUI()
		end
	},
	ResetAllMovers = {
		order = 5,
		type = "execute",
		name = L["Reset Anchors"],
		customWidth = 150,
		desc = L["Reset all frames to their original positions."],
		func = function()
			E:ResetUI()
		end
	},
	ToggleAnchors = {
		order = 6,
		type = "execute",
		name = L["Toggle Anchors"],
		customWidth = 150,
		desc = L["Unlock various elements of the UI to be repositioned."],
		func = function()
			E:ToggleMoveMode()
		end
	},
	LoginMessage = {
		order = 7,
		type = "toggle",
		name = L["Login Message"],
		customWidth = 150,
		get = function(info)
			return E.db.general.loginmessage
		end,
		set = function(info, value)
			E.db.general.loginmessage = value
		end
	}
}

local DEVELOPERS = {
	"Tukz",
	"Haste",
	"Nightcracker",
	"Omega1970",
	"Hydrazine",
	"Blazeflack",
	"NihilisticPandemonium",
	"|cffff7d0aMerathilis|r",
	"|cFF8866ccSimpy|r",
	"|cFF0070DEAzilroka|r"
}
local TESTERS = {
}
local DONATORS = {
}

do
	local DEVELOPER_STRING
	local TESTER_STRING
	local DONATOR_STRING

	if #DEVELOPERS > 0 then
		table.sort(DEVELOPERS)
		DEVELOPER_STRING = table.concat(DEVELOPERS, "\n")
	end
	if #TESTERS > 0 then
		table.sort(TESTERS)
		TESTER_STRING = table.concat(TESTERS, "\n")
	end
	if #DONATORS > 0 then
		table.sort(DONATORS)
		DONATOR_STRING = table.concat(DONATORS, "\n")
	end

	local CREDITS_STRING = format("%s%s%s%s",
		L["ELVUI_CREDITS"],
		(DEVELOPER_STRING and format("\n\n     %s\n%s", L["Coding:"], DEVELOPER_STRING) or ""),
		(TESTER_STRING and format("\n\n     %s\n%s", L["Testing:"], TESTER_STRING) or ""),
		(DONATOR_STRING and format("\n\n     %s\n%s", L["Donations:"], DONATOR_STRING) or "")
	)

	E.Options.args.credits = {
		order = -1,
		type = "group",
		name = L["Credits"],
		args = {
			text = {
				order = 1,
				type = "description",
				name = CREDITS_STRING
			}
		}
	}
end

local profileTypeItems = {
	["profile"] = L["Profile"],
	["private"] = L["Private (Character Settings)"],
	["global"] = L["Global (Account Settings)"],
	["filters"] = L["Aura Filters"],
	["styleFilters"] = L["NamePlate Style Filters"]
}
local profileTypeListOrder = {
	"profile",
	"private",
	"global",
	"filters",
	"styleFilters"
}
local exportTypeItems = {
	["text"] = L["Text"],
	["luaTable"] = L["Table"],
	["luaPlugin"] = L["Plugin"]
}
local exportTypeListOrder = {
	"text",
	"luaTable",
	"luaPlugin"
}

local exportString = ""
local function ExportImport_Open(mode)
	local Frame = E.Libs.AceGUI:Create("Frame")
	Frame:SetTitle(" ")
	Frame:EnableResize(false)
	Frame:SetWidth(800)
	Frame:SetHeight(600)
	Frame.frame:SetFrameStrata("FULLSCREEN_DIALOG")
	Frame:SetLayout("flow")

	local Box = E.Libs.AceGUI:Create("MultiLineEditBox")
	Box:SetNumLines(30)
	Box:DisableButton(true)
	Box:SetWidth(800)
	Box:SetLabel(" ")
	Frame:AddChild(Box)
	--Save original script so we can restore it later
	Box.editBox.OnTextChangedOrig = Box.editBox:GetScript("OnTextChanged")
	Box.editBox.OnCursorChangedOrig = Box.editBox:GetScript("OnCursorChanged")
	--Remove OnCursorChanged script as it causes weird behaviour with long text
	Box.editBox:SetScript("OnCursorChanged", nil)

	local Label1 = E.Libs.AceGUI:Create("Label")
	local font = GameFontHighlightSmall:GetFont()
	Label1:SetFont(font, 14)
	Label1:SetText(" ") --Set temporary text so height is set correctly
	Label1:SetWidth(800)
	Frame:AddChild(Label1)

	local Label2 = E.Libs.AceGUI:Create("Label")
	font = GameFontHighlightSmall:GetFont()
	Label2:SetFont(font, 14)
	Label2:SetText(" \n ")
	Label2:SetWidth(800)
	Frame:AddChild(Label2)

	if mode == "export" then
		Frame:SetTitle(L["Export Profile"])

		local ProfileTypeDropdown = E.Libs.AceGUI:Create("Dropdown")
		ProfileTypeDropdown:SetMultiselect(false)
		ProfileTypeDropdown:SetLabel(L["Choose What To Export"])
		ProfileTypeDropdown:SetList(profileTypeItems, profileTypeListOrder)
		ProfileTypeDropdown:SetValue("profile") --Default export
		Frame:AddChild(ProfileTypeDropdown)

		local ExportFormatDropdown = E.Libs.AceGUI:Create("Dropdown")
		ExportFormatDropdown:SetMultiselect(false)
		ExportFormatDropdown:SetLabel(L["Choose Export Format"])
		ExportFormatDropdown:SetList(exportTypeItems, exportTypeListOrder)
		ExportFormatDropdown:SetValue("text") --Default format
		ExportFormatDropdown:SetWidth(150)
		Frame:AddChild(ExportFormatDropdown)

		local exportButton = E.Libs.AceGUI:Create("Button")
		exportButton:SetText(L["Export Now"])
		exportButton:SetAutoWidth(true)
		local function OnClick(self)
			--Clear labels
			Label1:SetText(" ")
			Label2:SetText(" ")

			local profileType, exportFormat = ProfileTypeDropdown:GetValue(), ExportFormatDropdown:GetValue()
			local profileKey, profileExport = D:ExportProfile(profileType, exportFormat)
			if not profileKey or not profileExport then
				Label1:SetText(L["Error exporting profile!"])
			else
				Label1:SetText(
					format("%s: %s%s|r", L["Exported"], E.media.hexvaluecolor, profileTypeItems[profileType])
				)
				if profileType == "profile" then
					Label2:SetText(format("%s: %s%s|r", L["Profile Name"], E.media.hexvaluecolor, profileKey))
				end
			end
			Box:SetText(profileExport)
			Box.editBox:HighlightText()
			Box:SetFocus()
			exportString = profileExport
		end
		exportButton:SetCallback("OnClick", OnClick)
		Frame:AddChild(exportButton)

		--Set scripts
		Box.editBox:SetScript("OnChar", function()
			Box:SetText(exportString)
			Box.editBox:HighlightText()
		end)
		Box.editBox:SetScript("OnTextChanged", function(self, userInput)
			if userInput then
				--Prevent user from changing export string
				Box:SetText(exportString)
				Box.editBox:HighlightText()
			end
		end)
	elseif mode == "import" then
		Frame:SetTitle(L["Import Profile"])
		local importButton = E.Libs.AceGUI:Create("Button-ElvUI") --This version changes text color on SetDisabled
		importButton:SetDisabled(true)
		importButton:SetText(L["Import Now"])
		importButton:SetAutoWidth(true)
		importButton:SetCallback("OnClick", function()
			--Clear labels
			Label1:SetText(" ")
			Label2:SetText(" ")

			local text
			local success = D:ImportProfile(Box:GetText())
			if success then
				text = L["Profile imported successfully!"]
			else
				text = L["Error decoding data. Import string may be corrupted!"]
			end
			Label1:SetText(text)
		end)
		Frame:AddChild(importButton)

		local decodeButton = E.Libs.AceGUI:Create("Button-ElvUI")
		decodeButton:SetDisabled(true)
		decodeButton:SetText(L["Decode Text"])
		decodeButton:SetAutoWidth(true)
		decodeButton:SetCallback("OnClick", function()
			--Clear labels
			Label1:SetText(" ")
			Label2:SetText(" ")
			local decodedText
			local profileType, profileKey, profileData = D:Decode(Box:GetText())
			if profileData then
				decodedText = E:TableToLuaString(profileData)
			end
			local importText = D:CreateProfileExport(decodedText, profileType, profileKey)
			Box:SetText(importText)
		end)
		Frame:AddChild(decodeButton)

		local oldText = ""
		local function OnTextChanged()
			local text = Box:GetText()
			if text == "" then
				Label1:SetText(" ")
				Label2:SetText(" ")
				importButton:SetDisabled(true)
				decodeButton:SetDisabled(true)
			elseif oldText ~= text then
				local stringType = D:GetImportStringType(text)
				if stringType == "Base64" then
					decodeButton:SetDisabled(false)
				else
					decodeButton:SetDisabled(true)
				end

				local profileType, profileKey = D:Decode(text)
				if not profileType or (profileType and profileType == "profile" and not profileKey) then
					Label1:SetText(L["Error decoding data. Import string may be corrupted!"])
					Label2:SetText(" ")
					importButton:SetDisabled(true)
					decodeButton:SetDisabled(true)
				else
					Label1:SetText(
						format("%s: %s%s|r", L["Importing"], E.media.hexvaluecolor, profileTypeItems[profileType] or "")
					)
					if profileType == "profile" then
						Label2:SetText(format("%s: %s%s|r", L["Profile Name"], E.media.hexvaluecolor, profileKey))
					end
					importButton:SetDisabled(false)
				end

				--Scroll frame doesn't scroll to the bottom by itself, so let's do that now
				Box.scrollFrame:UpdateScrollChildRect()
				Box.scrollFrame:SetVerticalScroll(Box.scrollFrame:GetVerticalScrollRange())

				oldText = text
			end
		end

		Box.editBox:SetFocus()
		--Set scripts
		Box.editBox:SetScript("OnChar", nil)
		Box.editBox:SetScript("OnTextChanged", OnTextChanged)
	end

	Frame:SetCallback("OnClose", function(widget)
		--Restore changed scripts
		Box.editBox:SetScript("OnChar", nil)
		Box.editBox:SetScript("OnTextChanged", Box.editBox.OnTextChangedOrig)
		Box.editBox:SetScript("OnCursorChanged", Box.editBox.OnCursorChangedOrig)
		Box.editBox.OnTextChangedOrig = nil
		Box.editBox.OnCursorChangedOrig = nil

		--Clear stored export string
		exportString = ""

		E.Libs.AceGUI:Release(widget)
		E.Libs.AceConfigDialog:Open("ElvUI")
	end)

	--Clear default text
	Label1:SetText(" ")
	Label2:SetText(" ")

	--Close ElvUI OptionsUI
	E.Libs.AceConfigDialog:Close("ElvUI")

	GameTooltip_Hide() --The tooltip from the Export/Import button stays on screen, so hide it
end

--Create Profiles Table
E.Options.args.profiles = E.Libs.AceDBOptions:GetOptionsTable(E.data)
E.Libs.AceConfig:RegisterOptionsTable("ElvProfiles", E.Options.args.profiles)
E.Options.args.profiles.order = -10

E.Libs.DualSpec:EnhanceOptions(E.Options.args.profiles, E.data)

if not E.Options.args.profiles.plugins then
	E.Options.args.profiles.plugins = {}
end

E.Options.args.profiles.plugins.ElvUI = {
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
		type = "execute",
		name = L["Share Current Profile"],
		desc = L["Sends your current profile to your target."],
		func = function()
			if not UnitExists("target") or not UnitIsPlayer("target")
			or not UnitIsFriend("player", "target") or UnitIsUnit("player", "target") then
				E:Print(L["You must be targeting a player."])
				return
			end

			local name, server = UnitName("target")
			if name and (not server or server == "") then
				D:Distribute(name)
			elseif server then
				D:Distribute(name, true)
			end
		end
	},
	distributeGlobal = {
		order = 92,
		type = "execute",
		name = L["Share Filters"],
		desc = L["Sends your filter settings to your target."],
		func = function()
			if not UnitExists("target") or not UnitIsPlayer("target")
			or not UnitIsFriend("player", "target") or UnitIsUnit("player", "target") then
				E:Print(L["You must be targeting a player."])
				return
			end

			local name, server = UnitName("target")
			if name and (not server or server == "") then
				D:Distribute(name, false, true)
			elseif server then
				D:Distribute(name, true, true)
			end
		end
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
		func = function()
			ExportImport_Open("export")
		end
	},
	importProfile = {
		order = 95,
		type = "execute",
		name = L["Import Profile"],
		func = function()
			ExportImport_Open("import")
		end
	}
}

do
	local _, _, enabled = GetAddOnInfo("ElvUI_Config")
	if enabled then
		E:StaticPopup_Show("ELVUI_CONFIG_FOUND")
	end
end