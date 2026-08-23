local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

--Lua functions
local tinsert, tremove = tinsert, tremove
local type, assert = type, assert
--WoW API / Variables
local CreateFrame = CreateFrame

local subscribers = {} --[event] = { {owner = owner, callback = callback}, ... }
local dispatchFrame = CreateFrame("Frame")

local function OnEvent(_, event, ...)
	local list = subscribers[event]
	if not list then return end

	for i = 1, #list do
		local entry = list[i]
		entry.callback(entry.owner, event, ...)
	end
end

dispatchFrame:SetScript("OnEvent", OnEvent)

function E:SubscribeEvent(event, owner, callback)
	assert(type(event) == "string", "SubscribeEvent requires a string event name.")
	assert(owner ~= nil, "SubscribeEvent requires an owner.")
	assert(type(callback) == "function", "SubscribeEvent requires a callback function.")

	local list = subscribers[event]
	if not list then
		list = {}
		subscribers[event] = list
		dispatchFrame:RegisterEvent(event)
	end

	tinsert(list, {owner = owner, callback = callback})
end

function E:UnsubscribeEvent(event, owner)
	local list = subscribers[event]
	if not list then return end

	for i = #list, 1, -1 do
		if list[i].owner == owner then
			tremove(list, i)
		end
	end

	if #list == 0 then
		subscribers[event] = nil
		dispatchFrame:UnregisterEvent(event)
	end
end

function E:GetEventDispatcherSubscribers()
	return subscribers
end
