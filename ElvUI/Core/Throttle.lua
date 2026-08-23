local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

--Lua functions
local tinsert, tremove = tinsert, tremove
local type, assert = type, assert
--WoW API / Variables
local CreateFrame = CreateFrame

local throttleGroups = {} --[interval] = { interval, elapsed, callbacks = {fn, ...}, frame }

local function OnUpdate(self, elapsed)
	local group = self.throttleGroup
	group.elapsed = group.elapsed + elapsed

	if group.elapsed >= group.interval then
		local dt = group.elapsed
		group.elapsed = 0

		local callbacks = group.callbacks
		for i = 1, #callbacks do
			callbacks[i](dt)
		end
	end
end

function E:AddThrottledCallback(interval, callback)
	assert(type(interval) == "number" and interval > 0, "AddThrottledCallback requires a positive interval.")
	assert(type(callback) == "function", "AddThrottledCallback requires a callback function.")

	local group = throttleGroups[interval]
	if not group then
		local frame = CreateFrame("Frame")
		group = {interval = interval, elapsed = 0, callbacks = {}, frame = frame}
		frame.throttleGroup = group
		throttleGroups[interval] = group

		frame:SetScript("OnUpdate", OnUpdate)
	end

	tinsert(group.callbacks, callback)
end

function E:RemoveThrottledCallback(interval, callback)
	local group = throttleGroups[interval]
	if not group then return end

	local callbacks = group.callbacks
	for i = #callbacks, 1, -1 do
		if callbacks[i] == callback then
			tremove(callbacks, i)
		end
	end

	if #callbacks == 0 then
		group.frame:SetScript("OnUpdate", nil)
		throttleGroups[interval] = nil
	end
end

function E:GetThrottleGroups()
	return throttleGroups
end
