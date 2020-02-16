local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule("Blizzard")

--Lua functions
--WoW API / Variables
local ChatEdit_ChooseBoxForSend = ChatEdit_ChooseBoxForSend
local GetTradeSkillListLink = GetTradeSkillListLink
local Minimap_SetPing = Minimap_SetPing
local UnitIsUnit = UnitIsUnit
local MINIMAPPING_FADE_TIMER = MINIMAPPING_FADE_TIMER

function B:ADDON_LOADED(_, addon)
	if addon == "Blizzard_TradeSkillUI" then
		TradeSkillLinkButton:SetScript("OnClick", function()
			local ChatFrameEditBox = ChatEdit_ChooseBoxForSend()
			if not ChatFrameEditBox:IsShown() then
				ChatEdit_ActivateChat(ChatFrameEditBox)
			end

			ChatFrameEditBox:Insert(GetTradeSkillListLink())
		end)

		self:UnregisterEvent("ADDON_LOADED")
	end
end

function B:Initialize()
	self.Initialized = true

	self:AlertMovers()
	self:EnhanceColorPicker()
	self:KillBlizzard()
	self:PositionCaptureBar()
	self:PositionDurabilityFrame()
	self:PositionGMFrames()
	self:PositionVehicleFrame()
	self:MoveWatchFrame()

	self:RegisterEvent("ADDON_LOADED")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", SetMapToCurrentZone)

	KBArticle_BeginLoading = E.noop
	KBSetup_BeginLoading = E.noop
	KnowledgeBaseFrame_OnEvent(nil, "KNOWLEDGE_BASE_SETUP_LOAD_FAILURE")

	if GetLocale() == "deDE" then
		DAY_ONELETTER_ABBR = "%d d"
		MINUTE_ONELETTER_ABBR = "%d m"
	end

	CreateFrame("Frame"):SetScript("OnUpdate", function()
		if LFRBrowseFrame.timeToClear then
			LFRBrowseFrame.timeToClear = nil
		end
	end)

	MinimapPing:HookScript("OnUpdate", function(self)
		if self.fadeOut or self.timer > MINIMAPPING_FADE_TIMER then
			Minimap_SetPing(Minimap:GetPingPosition())
		end
	end)

	QuestLogFrame:HookScript("OnShow", function()
		local questFrame = QuestLogFrame:GetFrameLevel()
		local controlPanel = QuestLogControlPanel:GetFrameLevel()
		local scrollFrame = QuestLogDetailScrollFrame:GetFrameLevel()

		if questFrame >= controlPanel then
			QuestLogControlPanel:SetFrameLevel(questFrame + 1)
		end
		if questFrame >= scrollFrame then
			QuestLogDetailScrollFrame:SetFrameLevel(questFrame + 1)
		end
	end)

	ReadyCheckFrame:HookScript("OnShow", function(self)
		if UnitIsUnit("player", self.initiator) then
			self:Hide()
		end
	end)

--	WORLDMAP_POI_FRAMELEVEL = 300
--	WorldMapFrame:SetToplevel(true)

	do
		local originalFunc = LFDQueueFrameRandomCooldownFrame_OnEvent
		local originalScript = LFDQueueFrameCooldownFrame:GetScript("OnEvent")

		LFDQueueFrameRandomCooldownFrame_OnEvent = function(self, event, unit, ...)
			if event == "UNIT_AURA" and not unit then return end
			originalFunc(self, event, unit, ...)
		end

		if originalFunc == originalScript then
			LFDQueueFrameCooldownFrame:SetScript("OnEvent", LFDQueueFrameRandomCooldownFrame_OnEvent)
		else
			LFDQueueFrameCooldownFrame:SetScript("OnEvent", function(self, event, unit, ...)
				if event == "UNIT_AURA" and not unit then return end
				originalScript(self, event, unit, ...)
			end)
		end
	end
end

local function InitializeCallback()
	B:Initialize()
end

E:RegisterModule(B:GetName(), InitializeCallback)