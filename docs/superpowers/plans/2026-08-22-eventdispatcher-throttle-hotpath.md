# EventDispatcher, Throttle Utility & Hot-Path Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a reusable event-dispatch fan-out utility and a bucketed throttle utility for this WotLK 3.3.5a ElvUI fork, add a native-CPU-profiling slash command for both, and migrate the three measured hot paths (nameplate `OnUpdate`, Smoothie's bar-smoothing `OnUpdate`, and the ElvUI-authored `UNIT_HEALTH` registrations) onto them to fix ICC trash-pull and Sindragosa raid-damage frame stutter.

**Architecture:** Two new zero-dependency `Core/*.lua` utilities (`EventDispatcher.lua`, `Throttle.lua`) generalize a pattern that already exists narrowly in `ElvUI/Libraries/oUF/elements/tags.lua` (one master frame per event/interval, in-Lua fan-out to subscriber callbacks) so any ElvUI file can register through them instead of hand-rolling its own frame. WotLK's native `GetFunctionCPUUsage` (gated by the `scriptProfile` CVar) profiles each registered callback function directly with no added wrapper code, keeping normal play at zero added cost. Six real hot-path call sites are then migrated onto this infrastructure.

**Tech Stack:** Lua 5.1 (WotLK 3.3.5a client), AceAddon-3.0 / AceEvent-3.0 / AceConsole-3.0 (already embedded on `E`), oUF (vendored).

**Spec:** `c:\Users\Brad\.claude\plans\this-codebase-is-a-pure-hopper.md`

## Global Constraints

- Indentation is tabs, matching every existing file touched by this plan.
- Every new/modified Core and module file keeps the existing
  `local E, L, V, P, G = unpack(select(2, ...))` header convention, even
  where `L`/`V`/`P`/`G` go unused — this matches every other file in
  `ElvUI/Core/` and `ElvUI/Modules/`.
- `ElvUI/Libraries/oUF_Plugins/**` files are loaded via `Libraries\Load_Libraries.xml`,
  which the top-level `ElvUI.toc` lists **before** `Init.lua`. `_G.ElvUI` (the
  Engine table whose `[1]` is `E`) does not exist yet when these files'
  top-level chunks execute. Any oUF plugin file that needs `E` must resolve
  it lazily inside a function body (`if not E then E = _G.ElvUI[1] end`),
  exactly like the existing precedent in
  `ElvUI/Libraries/oUF_Plugins/oUF_Fader/oUF_Fader.lua:33-34`. Never add
  `local E = _G.ElvUI[1]` at the top level of an oUF plugin file — it will
  be `nil` at load time.
- `ElvUI/Core/*.lua` files (including the two new ones this plan adds) ARE
  loaded after `Init.lua` (top-level `.toc` order: `Init.lua` then
  `Core\Load_Core.xml`), so they may use `E` directly at file scope, same as
  `ElvUI/Core/Smoothie.lua` and `ElvUI/Core/Commands.lua` already do.
- No automated Lua test runner or `luacheck` binary is available in this
  environment (verified: no `lua`/`luajit`/`luacheck` on PATH). "Verify"
  steps in this plan mean: careful self-read of the diff for balanced
  `function`/`end`/`if`/`then` blocks, grep-confirming no dangling
  references to removed identifiers, and matching this file's existing
  local-variable/style conventions. Full runtime verification happens
  in-game, per the spec's own Verification section, after this plan's
  tasks are merged — that is manual, out of scope for any implementer
  subagent, and is the human partner's job, not part of any task's
  completion criteria here.
- Commit after each task with a message describing the change (this repo
  has no enforced commit message format beyond being descriptive — see
  `git log` for the existing style, e.g. "Microbar buttonsPerRow typo").

### Rulings made while turning the spec into this plan

- **Slash command name:** the spec says "`/elvui cpu on|off|report`", but
  `/elvui` (and `/ec`) are already both bound to `AddOn:ToggleOptionsUI(msg)`
  (`ElvUI/Init.lua:325`), which already overloads its `msg` argument as a
  comma-separated list of config pages to jump to (e.g. `/elvui general,unitframes`).
  Piggybacking `cpu on|off|report` onto that same argument would silently
  break page-jump navigation for anyone who ever types `/elvui cpu` for
  unrelated reasons, and there's no existing subcommand-router pattern in
  this codebase to graft onto safely. Every other diagnostic/profiling
  command in `ElvUI/Core/Commands.lua` (`/cpuimpact`, `/cpuusage`) is
  instead its own dedicated top-level slash command. Ruling: implement as
  a new dedicated command, `/edcpu on|off|report`, following that existing
  convention instead of overloading `/elvui`.
- **CPU instrumentation mechanism:** the spec says to "wrap" the
  dispatch/tick call with an optional profiling hook. Investigation
  (`ElvUI/Core/API.lua:212-249`, the existing `/cpuusage` command) found
  this codebase already has a simpler, native, zero-wrapper pattern:
  `GetFunctionCPUUsage(func, false)` returns a specific Lua function's
  accumulated CPU time directly from the WoW engine once
  `scriptProfile` is on — no manual `debugprofilestop()` timing needed
  around the dispatch/tick call itself. Ruling: skip the wrapper: both new
  utilities keep their subscriber/callback tables enumerable
  (`E:GetEventDispatcherSubscribers()`, `E:GetThrottleGroups()`), and
  `/edcpu report` queries `GetFunctionCPUUsage` directly against each
  registered callback function. This is a stronger form of "zero cost
  unless enabled" than a wrapper would be: the hot dispatch/tick path
  itself never branches on a profiling flag at all.
- **`ElvUI/Core/Tags.lua` excluded from the `UNIT_HEALTH` migration:** the
  spec's file list for this file turned out to be based on a
  misidentification. `Tags.lua`'s `UNIT_HEALTH` occurrences
  (e.g. `ElvUF.Tags.Events["healthcolor"] = "UNIT_HEALTH ..."`) are not
  event registrations at all — they're metadata strings consumed by oUF's
  own tag engine (`ElvUI/Libraries/oUF/elements/tags.lua:488-549`), which
  already registers each real event exactly once on its own single shared
  frame (the very pattern this plan's `EventDispatcher.lua` generalizes).
  Migrating it onto a second, different dispatcher would not remove any
  native registration and would add pure indirection. Ruling: excluded,
  no task touches this file.
- **`oUF_Fader.lua` excluded from the `UNIT_HEALTH` migration:**
  investigation (`ElvUI/Libraries/oUF_Plugins/oUF_Fader/oUF_Fader.lua:281-313`)
  found its `UNIT_HEALTH` registration lives inside a generic
  `SetOption`/`options[option].events` abstraction shared across seven
  distinct trigger groups (`Combat`, `Target`, `Focus`, `Health`, `Power`,
  `Vehicle`, `Casting`) — disabling any one of them runs the same generic
  loop that unregisters every event in that group's `events` array. Carving
  out just `Health` would require special-casing that shared loop and risks
  regressing the other six triggers, for a feature (alpha-fading on health
  change) that isn't what's driving the reported Sindragosa stutter (raid
  frame health-bar *rendering*, not fade-alpha, is). Ruling: excluded here;
  left as a candidate for whatever future phase migrates oUF_Fader's event
  groups as a whole.
- **oUF core `health.lua` (spec's "Wave B") excluded entirely:** the spec
  itself flags this as a stretch goal to attempt only after the rest of the
  phase is validated, explicitly permitting deferral to Phase 2 if
  migrating vendored oUF internals proves too invasive. Ruling: not
  included as a task in this plan at all (no task can be conditionally
  "attempt if there's time" in this task model) — deferred to a future
  Phase 2 plan, per the spec's own permission.
- **Nameplate target/mouseover updates stay on `NP`'s existing AceEvent
  registrations, not the new dispatcher:** the spec's own "later phases"
  section calls out `PLAYER_TARGET_CHANGED` as independently registered in
  14 files and explicitly scopes *generalizing the dispatcher* to cover it
  to a future phase, not this one. `Nameplates.lua` already registers
  `PLAYER_TARGET_CHANGED` / `UPDATE_MOUSEOVER_UNIT` via cheap, low-frequency
  AceEvent auto-dispatch (`NP:PLAYER_TARGET_CHANGED`, `NP:UPDATE_MOUSEOVER_UNIT`,
  `Nameplates.lua:1255,1260`) — those registrations are not the measured
  hot path; the *per-rendered-frame* `SetTargetFrame`/`SetMouseoverFrame`
  scan over every visible plate is. Ruling: Task 5 moves that scan into the
  two existing event-handler methods (still genuinely event-driven, just
  not re-registered through `Core/EventDispatcher.lua`), so the fix lands
  without pulling Phase 2's event-consolidation work into Phase 1.

## Critical files

- New: `ElvUI/Core/EventDispatcher.lua`, `ElvUI/Core/Throttle.lua`
- `ElvUI/Core/Load_Core.xml` — load-order registration for the two new files
- `ElvUI/Core/Commands.lua`, `ElvUI/Init.lua` (read-only reference for
  `ToggleOptionsUI`, not modified) — new `/edcpu` command
- `ElvUI/Core/Smoothie.lua` — swap driving `OnUpdate` for the throttle utility
- `ElvUI/Modules/Nameplates/Nameplates.lua` — `OnUpdate` split, `UNIT_HEALTH`
  migration
- `ElvUI/Modules/ActionBars/ActionBars.lua` — `UNIT_HEALTH` migration
- `ElvUI/Libraries/oUF_Plugins/oUF_ResComm/oUF_ResComm.lua`,
  `ElvUI/Libraries/oUF_Plugins/oUF_HealComm4/oUF_HealComm4.lua` —
  `UNIT_HEALTH` migration

---

### Task 1: `EventDispatcher.lua` — shared event fan-out utility

**Files:**
- Create: `ElvUI/Core/EventDispatcher.lua`
- Modify: `ElvUI/Core/Load_Core.xml`

**Interfaces:**
- Produces: `E:SubscribeEvent(event, owner, callback)` — registers `event`
  on a single shared frame the first time it's requested; appends
  `{owner, callback}` to that event's subscriber list. `callback` is
  invoked as `callback(owner, event, ...)` on every fan-out — this exact
  call shape lets an existing AceEvent method (`object:EVENT_NAME(event, ...)`,
  which desugars to `object.EVENT_NAME(object, event, ...)`) or an existing
  raw-frame `OnEvent` handler (`handler(frame, event, ...)`) be reused
  unchanged as the `callback` argument, with `owner` filling the first
  slot either way.
  `E:UnsubscribeEvent(event, owner)` — removes every subscriber entry for
  that `owner` on that `event`; unregisters the event from the shared frame
  once its subscriber list is empty.
  `E:GetEventDispatcherSubscribers()` — returns the internal
  `[event] = {{owner, callback}, ...}` table, for `/edcpu report` (Task 3)
  to enumerate.
- Consumes: nothing from other tasks.

- [ ] **Step 1: Write `ElvUI/Core/EventDispatcher.lua`**

```lua
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
```

- [ ] **Step 2: Register the new file in the load order**

In `ElvUI/Core/Load_Core.xml`, insert `EventDispatcher.lua` right after
`API.lua` (before `AprilFools.lua`) so it's available before `Commands.lua`
(Task 3) and every module's `Initialize()`:

```xml
	<Script file="Core.lua"/>
	<Script file="Math.lua"/>
	<Script file="API.lua"/>
	<Script file="EventDispatcher.lua"/>
	<Script file="AprilFools.lua"/>
```
(Leave every other line in the file exactly as-is; this only inserts the
one new `<Script>` line.)

- [ ] **Step 3: Self-review**

Confirm: the file has one `local`/`function` per line shown above (no
mismatched `end`s — there are 3 top-level `function`/`end` pairs plus the
`OnEvent` local function), and `Load_Core.xml` still has exactly the same
number of `<Script>` lines as before plus one.

- [ ] **Step 4: Commit**

```bash
git add ElvUI/Core/EventDispatcher.lua ElvUI/Core/Load_Core.xml
git commit -m "Add EventDispatcher Core utility for shared event fan-out"
```

---

### Task 2: `Throttle.lua` — shared bucketed throttle utility

**Files:**
- Create: `ElvUI/Core/Throttle.lua`
- Modify: `ElvUI/Core/Load_Core.xml`

**Interfaces:**
- Produces: `E:AddThrottledCallback(interval, callback)` — callbacks
  requesting the same numeric `interval` (seconds) share one `OnUpdate`
  frame with one elapsed accumulator; `callback` is invoked as
  `callback(dt)` where `dt` is the actual accumulated elapsed time since
  that bucket last fired (>= `interval`, may run slightly over on frame
  jitter). `E:RemoveThrottledCallback(interval, callback)` — removes that
  callback from its interval's bucket; tears down the bucket's `OnUpdate`
  frame once its callback list is empty.
  `E:GetThrottleGroups()` — returns the internal
  `[interval] = {interval, elapsed, callbacks, frame}` table, for
  `/edcpu report` (Task 3) to enumerate.
- Consumes: nothing from other tasks.

- [ ] **Step 1: Write `ElvUI/Core/Throttle.lua`**

```lua
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
```

- [ ] **Step 2: Register the new file in the load order**

In `ElvUI/Core/Load_Core.xml`, insert `Throttle.lua` right after the
`EventDispatcher.lua` line added in Task 1:

```xml
	<Script file="Core.lua"/>
	<Script file="Math.lua"/>
	<Script file="API.lua"/>
	<Script file="EventDispatcher.lua"/>
	<Script file="Throttle.lua"/>
	<Script file="AprilFools.lua"/>
```

- [ ] **Step 3: Self-review**

Confirm the file balances its `function`/`end` pairs (3 top-level plus the
`OnUpdate` local function) and `Load_Core.xml` gained exactly one more
`<Script>` line.

- [ ] **Step 4: Commit**

```bash
git add ElvUI/Core/Throttle.lua ElvUI/Core/Load_Core.xml
git commit -m "Add Throttle Core utility for shared bucketed OnUpdate ticks"
```

---

### Task 3: `/edcpu` CPU instrumentation slash command

**Files:**
- Modify: `ElvUI/Core/Commands.lua`

**Interfaces:**
- Consumes: `E:GetEventDispatcherSubscribers()` (Task 1),
  `E:GetThrottleGroups()` (Task 2).
- Produces: nothing consumed by later tasks — this is a leaf diagnostic
  command.

- [ ] **Step 1: Add `GetFunctionCPUUsage` to the localized WoW API list**

In `ElvUI/Core/Commands.lua`, after line 16
(`local ResetCPUUsage = ResetCPUUsage`), add:

```lua
local GetFunctionCPUUsage = GetFunctionCPUUsage
```

- [ ] **Step 2: Add the report helpers and command handler**

Insert the following in `ElvUI/Core/Commands.lua` immediately after the
end of `E:GetCPUImpact` (after the closing `end` on line 218, before the
`local BLIZZARD_ADDONS = {` table on line 220):

```lua
local dispatcherProfilingArmed = false

local function PrintEventSubscriberUsage()
	local subscribers = E:GetEventDispatcherSubscribers()
	for event, list in pairs(subscribers) do
		for i = 1, #list do
			local entry = list[i]
			local usage = GetFunctionCPUUsage(entry.callback, false)
			E:Print(format("EventDispatcher %s (%s): %.3fms", event, tostring(entry.owner), usage or 0))
		end
	end
end

local function PrintThrottleUsage()
	local groups = E:GetThrottleGroups()
	for interval, group in pairs(groups) do
		for i = 1, #group.callbacks do
			local usage = GetFunctionCPUUsage(group.callbacks[i], false)
			E:Print(format("Throttle %.3fs callback #%d: %.3fms", interval, i, usage or 0))
		end
	end
end

function E:CPUDispatcherCommand(msg)
	msg = lower(msg or "")

	if msg == "on" then
		SetCVar("scriptProfile", 1)
		ResetCPUUsage()
		dispatcherProfilingArmed = true
		E:Print("EventDispatcher/Throttle CPU profiling enabled. Use /edcpu report to see accumulated usage, /edcpu off to disable.")
	elseif msg == "off" then
		SetCVar("scriptProfile", 0)
		dispatcherProfilingArmed = false
		E:Print("EventDispatcher/Throttle CPU profiling disabled.")
	elseif msg == "report" then
		if not dispatcherProfilingArmed or not GetCVarBool("scriptProfile") then
			E:Print("For `/edcpu report` to work, run `/edcpu on` first.")
			return
		end

		PrintEventSubscriberUsage()
		PrintThrottleUsage()
	else
		E:Print("/edcpu on - /edcpu off - /edcpu report")
	end
end
```

- [ ] **Step 3: Register the slash command**

In `E:LoadCommands` (`ElvUI/Core/Commands.lua`), add the registration
right after the existing `cpuusage` block (after line 268's trailing
comment, before the blank line and `self:RegisterChatCommand("bgstats", "BGStats")`):

```lua
	self:RegisterChatCommand("edcpu", "CPUDispatcherCommand")
	-- args: on, off, report
	-- Profiles Core/EventDispatcher.lua subscribers and Core/Throttle.lua
	-- callbacks via native GetFunctionCPUUsage. Requires scriptProfile CVar,
	-- which `/edcpu on` sets automatically.
```

- [ ] **Step 4: Self-review**

Confirm `pairs` is already used unlocalized elsewhere in this file
(`E:EnableBlizzardAddOns`, line 247) so no new `local pairs` is needed;
confirm the new code sits between `E:GetCPUImpact`'s closing `end` and
`local BLIZZARD_ADDONS`; confirm `LoadCommands` still registers every
pre-existing command unchanged plus the one new line.

- [ ] **Step 5: Commit**

```bash
git add ElvUI/Core/Commands.lua
git commit -m "Add /edcpu slash command to profile EventDispatcher/Throttle callbacks"
```

---

### Task 4: Migrate Smoothie's bar-smoothing `OnUpdate` onto the Throttle utility

**Files:**
- Modify: `ElvUI/Core/Smoothie.lua`

**Interfaces:**
- Consumes: `E:AddThrottledCallback(interval, callback)`,
  `E:RemoveThrottledCallback(interval, callback)` (Task 2).
- Produces: nothing consumed by later tasks.

**Context:** `Smoothie.lua`'s `onUpdate` currently runs on every rendered
frame via a raw `frame:SetScript("OnUpdate", onUpdate)`
(`ElvUI/Core/Smoothie.lua:36-48,101-103`), animating every actively-smoothing
bar every frame — during Sindragosa, up to 25 raid-frame health bars can be
smoothing simultaneously. The `lerp`/`clamp`/`isCloseEnough` math already
uses real elapsed time (not frame count), so capping the tick rate changes
nothing about correctness — only how often it runs.

- [ ] **Step 1: Add a tick-interval constant and drop the module-level frame**

In `ElvUI/Core/Smoothie.lua`, replace line 8
(`local TARGET_FPS = 60`) with:

```lua
local TARGET_FPS = 60
local TICK_INTERVAL = 1 / TARGET_FPS
```

Then delete line 36 (`local frame = CreateFrame("Frame")`) entirely — the
throttle utility now owns the driving frame.

- [ ] **Step 2: Change `onUpdate`'s signature**

Replace:

```lua
local function onUpdate(_, elapsed)
```

with:

```lua
local function onUpdate(elapsed)
```

(The throttle utility calls `callback(dt)` — a single argument, no frame —
so the leading `_` self-parameter goes away. The body below this line is
unchanged.)

- [ ] **Step 3: Swap the registration in `SmoothBar`**

Replace:

```lua
	if not frame:GetScript("OnUpdate") then
		frame:SetScript("OnUpdate", onUpdate)
	end
```

with:

```lua
	if not next(handledObjects) then
		E:AddThrottledCallback(TICK_INTERVAL, onUpdate)
	end
```

(Must run this check **before** `handledObjects[bar] = true` below it, same
as the original ordering — `next(handledObjects)` being empty is the
"first bar ever smoothed" signal, mirroring what
`frame:GetScript("OnUpdate")` being nil used to mean.)

- [ ] **Step 4: Swap the teardown in `DesmoothBar`**

Replace:

```lua
	if not next(handledObjects) then
		frame:SetScript("OnUpdate", nil)
	end
```

with:

```lua
	if not next(handledObjects) then
		E:RemoveThrottledCallback(TICK_INTERVAL, onUpdate)
	end
```

(This is already the last block in `DesmoothBar`, after `handledObjects[bar] = nil`
and the `SetValue_`/`SetMinMaxValues_` restoration — only the frame-script
call changes.)

- [ ] **Step 5: Self-review**

Grep this file for `CreateFrame` and `SetScript` to confirm no leftover
reference to the deleted module-level `frame` remains, and that
`onUpdate` is referenced consistently (as a bare function value) in both
`SmoothBar` and `DesmoothBar`.

- [ ] **Step 6: Commit**

```bash
git add ElvUI/Core/Smoothie.lua
git commit -m "Cap Smoothie bar-smoothing tick rate via the Throttle utility"
```

---

### Task 5: Split Nameplates' `NP:OnUpdate` into event-driven highlighting + a throttled tick

**Files:**
- Modify: `ElvUI/Modules/Nameplates/Nameplates.lua`

**Interfaces:**
- Consumes: `E:AddThrottledCallback(interval, callback)` (Task 2).
- Produces: nothing consumed by later tasks.

**Context:** `NP:OnUpdate` (`Nameplates.lua:848-877`) currently runs on
every rendered frame for every visible nameplate — the direct cause of the
ICC trash-pull stutter. Per the ruling above, this splits into: (a) the
`SetTargetFrame`/`SetMouseoverFrame` full-plate scan moving into the
*existing* `NP:PLAYER_TARGET_CHANGED` / `NP:UPDATE_MOUSEOVER_UNIT` AceEvent
handlers (already registered, already low-frequency — this task does not
touch their registration, only their bodies), and (b) everything that must
still poll (new-plate discovery, per-plate alpha upkeep, threat checks)
moving to a throttled tick via the new `Throttle.lua`.

- [ ] **Step 1: Remove `NP:OnUpdate`, add `NP:ThrottledTick`**

Replace the entire `NP:OnUpdate` function
(`ElvUI/Modules/Nameplates/Nameplates.lua:848-877`):

```lua
function NP:OnUpdate()
	numChildren = WorldGetNumChildren(WorldFrame)
	if lastChildern ~= numChildren then
		findNewPlate(WorldGetChildren(WorldFrame))
		lastChildern = numChildren
	end

	for frame in pairs(NP.VisiblePlates) do
		if hasTarget then
			frame.alpha = frame:GetParent():GetAlpha()
			frame:GetParent():SetAlpha(1)
		else
			frame.alpha = 1
		end

		NP:SetMouseoverFrame(frame)
		NP:SetTargetFrame(frame)

		if frame.UnitReaction ~= NP:GetUnitInfo(frame) then
			NP:UpdateAllFrame(frame, nil, true)
		end

		local status = NP:UnitDetailedThreatSituation(frame)
		if frame.ThreatStatus ~= status then
			frame.ThreatStatus = status

			NP:Update_HealthColor(frame)
		end
	end
end
```

with:

```lua
function NP:ThrottledTick()
	numChildren = WorldGetNumChildren(WorldFrame)
	if lastChildern ~= numChildren then
		findNewPlate(WorldGetChildren(WorldFrame))
		lastChildern = numChildren
	end

	for frame in pairs(NP.VisiblePlates) do
		if hasTarget then
			frame.alpha = frame:GetParent():GetAlpha()
			frame:GetParent():SetAlpha(1)
		else
			frame.alpha = 1
		end

		if frame.UnitReaction ~= NP:GetUnitInfo(frame) then
			NP:UpdateAllFrame(frame, nil, true)
		end

		local status = NP:UnitDetailedThreatSituation(frame)
		if frame.ThreatStatus ~= status then
			frame.ThreatStatus = status

			NP:Update_HealthColor(frame)
		end
	end
end
```

(Only the `NP:SetMouseoverFrame(frame)` / `NP:SetTargetFrame(frame)` calls
are removed from the loop body; everything else is identical, including
keeping the function as a colon-method even though — same as the original
— its body never references `self`, only the `NP` upvalue.)

- [ ] **Step 2: Move the target scan into `NP:PLAYER_TARGET_CHANGED`**

Replace:

```lua
function NP:PLAYER_TARGET_CHANGED()
	hasTarget = UnitExists("target") == 1
end
```

with:

```lua
function NP:PLAYER_TARGET_CHANGED()
	hasTarget = UnitExists("target") == 1

	for frame in pairs(NP.VisiblePlates) do
		NP:SetTargetFrame(frame)
	end
end
```

- [ ] **Step 3: Move the mouseover scan into `NP:UPDATE_MOUSEOVER_UNIT`**

Replace:

```lua
function NP:UPDATE_MOUSEOVER_UNIT()
	if not UnitIsUnit("mouseover", "player") and UnitIsPlayer("mouseover") then
		local name = UnitName("mouseover")
		local guid = UnitGUID("mouseover")
		local unitType = self:GetUnitTypeFromUnit("mouseover")
		for frame in pairs(self.VisiblePlates) do
			if frame.UnitName == name and frame.UnitType == unitType then
				if not self.GUIDList[guid] then
					self.GUIDList[guid] = {name = name, unitType = frame.UnitType}
					self.OnShow(frame:GetParent(), nil, true)
					break
				end
			end
		end
	end
end
```

with:

```lua
function NP:UPDATE_MOUSEOVER_UNIT()
	for frame in pairs(NP.VisiblePlates) do
		NP:SetMouseoverFrame(frame)
	end

	if not UnitIsUnit("mouseover", "player") and UnitIsPlayer("mouseover") then
		local name = UnitName("mouseover")
		local guid = UnitGUID("mouseover")
		local unitType = self:GetUnitTypeFromUnit("mouseover")
		for frame in pairs(self.VisiblePlates) do
			if frame.UnitName == name and frame.UnitType == unitType then
				if not self.GUIDList[guid] then
					self.GUIDList[guid] = {name = name, unitType = frame.UnitType}
					self.OnShow(frame:GetParent(), nil, true)
					break
				end
			end
		end
	end
end
```

(The new loop is added at the top, unconditionally; the pre-existing
GUID-matching block below it is untouched.)

- [ ] **Step 4: Swap the `OnUpdate` registration for a throttled tick**

In `NP:Initialize`, replace line 1249:

```lua
	self.Frame = CreateFrame("Frame"):SetScript("OnUpdate", self.OnUpdate)
```

with:

```lua
	E:AddThrottledCallback(0.1, NP.ThrottledTick)
```

(0.1s = 10 ticks/sec for plate discovery, alpha upkeep, and threat checks —
fast enough that threat-color/alpha changes remain visually immediate,
far below full framerate cost. `NP.ThrottledTick` is passed as a bare
function reference the same way `self.OnUpdate` was — the throttle utility
calls it as `callback(dt)`, which harmlessly binds `dt` to the unused
colon-sugar `self` parameter, exactly as the original per-frame
`OnUpdate` script already tolerated.)

- [ ] **Step 5: Self-review**

Grep the file for `OnUpdate` and `self.Frame` to confirm no other code
references either (the `self.Frame` field itself is no longer created —
confirm nothing else in this file reads `NP.Frame`/`self.Frame`). Confirm
`findNewPlate`, `lastChildern`, `numChildren`, `hasTarget` are all still
declared as the same file-local upvalues they were before (unchanged
declarations at the top of the file) since `NP:ThrottledTick` still closes
over them.

- [ ] **Step 6: Commit**

```bash
git add ElvUI/Modules/Nameplates/Nameplates.lua
git commit -m "Split nameplate OnUpdate into event-driven highlighting + throttled tick"
```

---

### Task 6: Migrate Nameplates' and ActionBars' `UNIT_HEALTH` registrations onto the dispatcher

**Files:**
- Modify: `ElvUI/Modules/Nameplates/Nameplates.lua`
- Modify: `ElvUI/Modules/ActionBars/ActionBars.lua`

**Interfaces:**
- Consumes: `E:SubscribeEvent(event, owner, callback)` (Task 1).
- Produces: nothing consumed by later tasks.

**Context:** Both files independently register a native `UNIT_HEALTH`
event today. Neither handler needs to change — `E:SubscribeEvent`'s
`callback(owner, event, ...)` call shape exactly matches how AceEvent
already invokes `NP:UNIT_HEALTH` (`object:METHOD(event, ...)` ≡
`object.METHOD(object, event, ...)`) and how ActionBars' raw
`fadeParent:SetScript("OnEvent", handler)` already invokes
`AB.FadeParent_OnEvent` (`handler(frame, event, ...)`), so only the
registration call itself changes.

- [ ] **Step 1: Migrate Nameplates' module-level `UNIT_HEALTH` registration**

In `NP:Initialize` (`ElvUI/Modules/Nameplates/Nameplates.lua`), replace
line 1262:

```lua
	self:RegisterEvent("UNIT_HEALTH")
```

with:

```lua
	E:SubscribeEvent("UNIT_HEALTH", self, self.UNIT_HEALTH)
```

(Leave every other `self:RegisterEvent(...)` line around it — `UNIT_MANA`,
`UNIT_ENERGY`, `UNIT_FOCUS`, `UNIT_RAGE`, etc. — untouched; only
`UNIT_HEALTH` is in scope. The existing `NP:UNIT_HEALTH` function body at
lines 1064-1067 is unchanged.)

- [ ] **Step 2: Migrate ActionBars' `fadeParent` `UNIT_HEALTH` registration**

In `AB:Initialize` (`ElvUI/Modules/ActionBars/ActionBars.lua`), replace
line 987:

```lua
	self.fadeParent:RegisterEvent("UNIT_HEALTH")
```

with:

```lua
	E:SubscribeEvent("UNIT_HEALTH", self.fadeParent, self.FadeParent_OnEvent)
```

(Leave the other `self.fadeParent:RegisterEvent(...)` lines above and
below it untouched — only `UNIT_HEALTH` moves. The existing
`AB:FadeParent_OnEvent` function body at lines 658-676 is unchanged; it
already branches on `event == "UNIT_HEALTH"` so it works identically
whether invoked by the dispatcher or the old raw registration.)

- [ ] **Step 3: Self-review**

Grep both files for `"UNIT_HEALTH"` to confirm exactly one occurrence per
file changed from a `RegisterEvent` call to a `SubscribeEvent` call, and
that the handler function names/bodies were not touched.

- [ ] **Step 4: Commit**

```bash
git add ElvUI/Modules/Nameplates/Nameplates.lua ElvUI/Modules/ActionBars/ActionBars.lua
git commit -m "Migrate Nameplates and ActionBars UNIT_HEALTH onto EventDispatcher"
```

---

### Task 7: Migrate `oUF_ResComm` and `oUF_HealComm4`'s `UNIT_HEALTH` registrations onto the dispatcher

**Files:**
- Modify: `ElvUI/Libraries/oUF_Plugins/oUF_ResComm/oUF_ResComm.lua`
- Modify: `ElvUI/Libraries/oUF_Plugins/oUF_HealComm4/oUF_HealComm4.lua`

**Interfaces:**
- Consumes: `E:SubscribeEvent(event, owner, callback)`,
  `E:UnsubscribeEvent(event, owner)` (Task 1).
- Produces: nothing consumed by later tasks.

**Context:** Both plugins call `self:RegisterEvent("UNIT_HEALTH", Path)`
inside their `Enable(self)` (where `self` is an individual oUF unit frame —
up to 25 independent native registrations across a full raid) and
`self:UnregisterEvent("UNIT_HEALTH", Path)` inside `Disable(self)`. Per the
Global Constraints, these files are loaded before `Init.lua` runs, so `E`
must be resolved lazily, mirroring `oUF_Fader.lua:33-34`'s existing
pattern in this same codebase. `Path`'s signature (`Path(self, event, ...)`)
already matches oUF's own per-frame event-dispatch convention, which is
the same `(owner, event, ...)` shape `E:SubscribeEvent` invokes callbacks
with — `Path` itself does not change.

- [ ] **Step 1: Add a lazily-resolved `local E` to `oUF_ResComm.lua`**

After line 31 (`local tremove = table.remove`) in
`ElvUI/Libraries/oUF_Plugins/oUF_ResComm/oUF_ResComm.lua`, add:

```lua
local E -- ElvUI engine, resolved lazily in Enable/Disable (loads before Init.lua)
```

- [ ] **Step 2: Migrate `oUF_ResComm.lua`'s `Enable`/`Disable`**

Replace:

```lua
local function Enable(self)
	local element = self.ResurrectIndicator

	if element then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent("UNIT_HEALTH", Path)

		if element:IsObjectType("Texture") and not element:GetTexture() then
			element:SetTexture([[Interface\Icons\Spell_Holy_Resurrection]])
		end

		enabledUF[#enabledUF + 1] = self
		ToggleCallbacks(true)

		return true
	end
end

local function Disable(self)
	local element = self.ResurrectIndicator

	if element then
		element:Hide()

		self:UnregisterEvent("UNIT_HEALTH", Path)

		for i = 1, #enabledUF do
			if enabledUF[i] == self then
				tremove(enabledUF, i)
				break
			end
		end

		ToggleCallbacks(false)
	end
end
```

with:

```lua
local function Enable(self)
	local element = self.ResurrectIndicator

	if element then
		if not E then E = _G.ElvUI[1] end

		element.__owner = self
		element.ForceUpdate = ForceUpdate

		E:SubscribeEvent("UNIT_HEALTH", self, Path)

		if element:IsObjectType("Texture") and not element:GetTexture() then
			element:SetTexture([[Interface\Icons\Spell_Holy_Resurrection]])
		end

		enabledUF[#enabledUF + 1] = self
		ToggleCallbacks(true)

		return true
	end
end

local function Disable(self)
	local element = self.ResurrectIndicator

	if element then
		element:Hide()

		if not E then E = _G.ElvUI[1] end

		E:UnsubscribeEvent("UNIT_HEALTH", self)

		for i = 1, #enabledUF do
			if enabledUF[i] == self then
				tremove(enabledUF, i)
				break
			end
		end

		ToggleCallbacks(false)
	end
end
```

- [ ] **Step 3: Add a lazily-resolved `local E` to `oUF_HealComm4.lua`**

Near the top of
`ElvUI/Libraries/oUF_Plugins/oUF_HealComm4/oUF_HealComm4.lua`, alongside
its other top-level `local` declarations (before the `Enable`/`Disable`
functions), add:

```lua
local E -- ElvUI engine, resolved lazily in Enable/Disable (loads before Init.lua)
```

- [ ] **Step 4: Migrate only the `UNIT_HEALTH` half of `oUF_HealComm4.lua`'s `Enable`/`Disable`**

`oUF_HealComm4.lua` registers both `UNIT_HEALTH` and `UNIT_MAXHEALTH` on
the same `Path`. Only `UNIT_HEALTH` is in scope for this migration — leave
`UNIT_MAXHEALTH` on its existing raw registration.

In `Enable` (`ElvUI/Libraries/oUF_Plugins/oUF_HealComm4/oUF_HealComm4.lua`),
replace:

```lua
		self:RegisterEvent("UNIT_HEALTH", Path)
		self:RegisterEvent("UNIT_MAXHEALTH", Path)
```

with:

```lua
		if not E then E = _G.ElvUI[1] end

		E:SubscribeEvent("UNIT_HEALTH", self, Path)
		self:RegisterEvent("UNIT_MAXHEALTH", Path)
```

In `Disable`, replace:

```lua
		self:UnregisterEvent("UNIT_HEALTH", Path)
		self:UnregisterEvent("UNIT_MAXHEALTH", Path)
```

with:

```lua
		if not E then E = _G.ElvUI[1] end

		E:UnsubscribeEvent("UNIT_HEALTH", self)
		self:UnregisterEvent("UNIT_MAXHEALTH", Path)
```

(Every other line in both functions — the `element.myBar`/`element.otherBar`
handling, `enabledUF` bookkeeping, `ToggleCallbacks` — is unchanged.)

- [ ] **Step 5: Self-review**

Grep both files for `UNIT_HEALTH` to confirm exactly the intended lines
changed (`UNIT_MAXHEALTH` lines in `oUF_HealComm4.lua` must still read
`self:RegisterEvent`/`self:UnregisterEvent`, not `E:SubscribeEvent`/
`E:UnsubscribeEvent`). Confirm `local E` was added exactly once per file
and every `E:SubscribeEvent`/`E:UnsubscribeEvent` call site is preceded
(within the same function) by the `if not E then E = _G.ElvUI[1] end`
lazy-init line.

- [ ] **Step 6: Commit**

```bash
git add ElvUI/Libraries/oUF_Plugins/oUF_ResComm/oUF_ResComm.lua ElvUI/Libraries/oUF_Plugins/oUF_HealComm4/oUF_HealComm4.lua
git commit -m "Migrate oUF_ResComm and oUF_HealComm4 UNIT_HEALTH onto EventDispatcher"
```

---

## Post-plan verification (manual, in-game — not part of any task above)

This plan's tasks are code-complete once Task 7 is committed and
self-reviewed; the spec's own Verification section (baseline `/edcpu on`
capture before a trash pull / Sindragosa attempt, apply, re-capture,
compare, felt-smoothness sanity check) is manual in-game work for the
human partner to run afterward, not something any implementer or reviewer
subagent can execute.
