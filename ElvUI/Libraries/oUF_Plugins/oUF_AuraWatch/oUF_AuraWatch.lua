--[[------------------------------------------------------------------------------------------------------
oUF_AuraWatch by Astromech
Please leave comments, suggestions, and bug reports on this addon's WoWInterface page

To setup, create a table named AuraWatch in your unit frame. There are several options
you can specify, as explained below.

    icons
        Mandatory!
        A table of frames to be used as icons. oUF_Aurawatch does not position
        these frames, so you must do so yourself. Each icon needs a spellID entry,
        which is the spell ID of the aura to watch. Table should be set up
        such that values are icon frames, but the keys can be anything.

        Note each icon can have several options set as well. See below.
    missingAlpha
        Default 0.75
        The alpha value for icons of auras which have faded from the unit.
    presentAlpha
        Default 1
        The alpha value for icons or auras present on the unit.
    onlyShowMissing
        Default false
        If this is true, oUF_AW will hide icons if they are present on the unit.
    onlyShowPresent
        Default false
        If this is true, oUF_AW will hide icons if they have expired from the unit.
    customIcons
        Default false
        If this is true, oUF_AW will not create any frames or textures for your
        icons. It assumes you will handle it.
    fromUnits
        Default {["player"] = true, ["pet"] = true, ["vehicle"] = true}
        A table of units from which auras can originate. Have the units be the keys
        and "true" be the values.
    anyUnit
        Default false
        Set to true for oUF_AW to to show an aura no matter what unit it
        originates from. This will override any fromUnits setting.
    PostCreateIcon
        Default nil
        A function to call when an icon is created to modify it, such as adding
        a border or repositioning the count fontstring. Leave as nil to ignore.
        The arguments are: AuraWatch table, icon, auraSpellID, auraName, unitFrame
    PostResetIcon
        Default nil
        A function to call when an icon is reset, that is an aura has been applied
        or refreshed. This is passed the AuraWatch frame, the icon, aura stack count,
        duration, and remaining time, as per a UnitAura call.
    PostExpireIcon
        Default nil
        A function to call when an icon is expired, that is an aura has disappeared.
        This is passed the AuraWatch frame and the icon.
    OverrideResetIcon
        Default nil
        Provide this function to handle the ResetIcon process yourself.
    OverrideExpireIcon
        Default nil
        Provide this function to handle the ExpireIcon process yourself.

Below are options set on a per icon basis. Set these as fields in the icon frames.

The following settings can be overridden from the AuraWatch table on a per-aura basis:
    onlyShowMissing
    onlyShowPresent
    fromUnits
    anyUnit

The following settings are unique to icons:

    spellID
        Mandatory!
        The spell id of the aura, as explained above.

Here is an example of how to set oUF_AW up:

    local createAuraWatch = function(self, unit)
        local auras = {}

        -- A table of spellIDs to create icons for
        -- To find spellIDs, look up a spell on www.wowhead.com and look at the URL
        -- http://www.wowhead.com/?spell=SPELL_ID
        local spellIDs = { ... }

        auras.presentAlpha = 1
        auras.missingAlpha = .7
        auras.PostCreateIcon = myCustomIconSkinnerFunction
        -- Set any other AuraWatch settings
        auras.icons = {}
        for i, sid in pairs(spellIDs) do
            local icon = CreateFrame("Frame", nil, self)
            icon.spellID = sid
            -- set the dimensions and positions
            icon:SetWidth(24)
            icon:SetHeight(24)
            icon:SetPoint("BOTTOM", self, "BOTTOM", 0, 28 * i)
            auras.icons[sid] = icon
            -- Set any other AuraWatch icon settings
        end
        self.AuraWatch = auras
    end
-----------------------------------------------------------------------------------------------------------]]

local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF_AuraWatch cannot find an instance of oUF. If your oUF is embedded into a layout, it may not be embedded properly.")

local UnitAura, UnitGUID = UnitAura, UnitGUID
local GUIDs = {}

local PLAYER_UNITS = {
    player = true,
    vehicle = true,
    pet = true,
}

local SetupGUID
do
    local cache = setmetatable({}, {__type = "k"})

    local frame = CreateFrame("Frame")
    frame:SetScript("OnEvent", function(self, event)
        for k,t in pairs(GUIDs) do
            GUIDs[k] = nil
            wipe(t)
            cache[t] = true
        end
    end)
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")

    function SetupGUID(guid)
        local t = next(cache)
        if t then
            cache[t] = nil
        else
            t = {}
        end
        GUIDs[guid] = t
    end
end

local function DefaultResetIcon(watch, icon, count, duration, expire)
    if not icon.onlyShowMissing then
        if icon.cd then
            if duration and duration > 0 then
                icon.cd:SetCooldown(expire - duration, duration)
                icon.cd:Show()
            else
                icon.cd:Hide()
            end
        end
        if icon.count then
            icon.count:SetText(count > 1 and count)
        end
        if icon.overlay then
            icon.overlay:Hide()
        end
        icon:SetAlpha(watch.presentAlpha)
        icon:Show()
        if watch.PostResetIcon then watch.PostResetIcon(watch, icon) end
    end
end

local function ResetIcon(watch, icon, ...)
    if watch.OverrideResetIcon then
        watch.OverrideResetIcon(watch, icon, ...)
    else
        DefaultResetIcon(watch, icon, ...)
    end
end

local function DefaultExpireIcon(watch, icon)
    if not icon.onlyShowPresent then
        if icon.cd then
            icon.cd:Hide()
        end
        if icon.count then
            icon.count:SetText()
        end
        icon:SetAlpha(watch.missingAlpha)
        if icon.overlay then
            icon.overlay:Show()
        end
        icon:Show()
        if watch.PostExpireIcon then watch.PostExpireIcon(watch, icon) end
    end
end

local function ExpireIcon(watch, icon, ...)
    if watch.OverrideExpireIcon then
        watch.OverrideExpireIcon(watch, icon, ...)
    else
        DefaultExpireIcon(watch, icon, ...)
    end
end

local Update
do
    local found = {}
    function Update(frame, event, unit)
        if frame.unit ~= unit then return end
        local watch = frame.AuraWatch
        local index, icons = 1, watch.watched
        local filter = "HELPFUL"
        local guid = UnitGUID(unit)
        if not GUIDs[guid] then SetupGUID(guid) end

        for _, icon in pairs(icons) do
            icon:Hide()
        end

        local _, name, _, count, duration, expire, caster, icon, spellid
        while true do
            name, _, count, _, duration, expire, caster, _, _, spellid = UnitAura(unit, index, filter)
            if not name then
                if filter == "HELPFUL" then
                    filter = "HARMFUL"
                    index = 1
                else
                    break
                end
            else
                icon = icons[spellid]
                if icon and not icon.ignore and (icon.anyUnit or (caster and icon.fromUnits[caster])) then
                    ResetIcon(watch, icon, count, duration, expire)
                    GUIDs[guid][spellid] = true
                    found[spellid] = true
                end
                index = index + 1
            end
        end

        for key in pairs(GUIDs[guid]) do
            if icons[key] and not found[key] and not icons[key].ignore then
                ExpireIcon(watch, icons[key])
            end
        end

        wipe(found)
    end
end

local function SetupIcons(self)

    local watch = self.AuraWatch
    local icons = watch.icons
    watch.watched = {}
    if not watch.missingAlpha then watch.missingAlpha = 0.75 end
    if not watch.presentAlpha then watch.presentAlpha = 1 end

    for _,icon in pairs(icons) do

        local name, _, image = GetSpellInfo(icon.spellID)
        if not name then error("oUF_AuraWatch error: no spell with "..tostring(icon.spellID).." spell ID exists") end
        icon.name = name

        if not watch.customIcons then
            local cd = CreateFrame("Cooldown", nil, icon)
            cd:SetAllPoints(icon)
            icon.cd = cd

            local tex = icon:CreateTexture(nil, "BACKGROUND")
            tex:SetAllPoints(icon)
            tex:SetTexture(image)
            icon.icon = tex

            local overlay = icon:CreateTexture(nil, "OVERLAY")
            overlay:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
            overlay:SetAllPoints(icon)
            overlay:SetTexCoord(.296875, .5703125, 0, .515625)
            overlay:SetVertexColor(1, 0, 0)
            icon.overlay = overlay

            local count = icon:CreateFontString(nil, "OVERLAY")
            count:SetFontObject(NumberFontNormal)
            count:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", -1, 0)
            icon.count = count
        end

        if icon.onlyShowMissing == nil then
            icon.onlyShowMissing = watch.onlyShowMissing
        end
        if icon.onlyShowPresent == nil then
            icon.onlyShowPresent = watch.onlyShowPresent
        end
        if icon.fromUnits == nil then
            icon.fromUnits = watch.fromUnits or PLAYER_UNITS
        end
        if icon.anyUnit == nil then
            icon.anyUnit = watch.anyUnit
        end

        watch.watched[icon.spellID] = icon

        if watch.PostCreateIcon then watch:PostCreateIcon(icon, icon.spellID, name, self) end
    end
end

local function ForceUpdate(element)
    return Update(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function Enable(self)
    if self.AuraWatch then
        self.AuraWatch.__owner = self
        self.AuraWatch.ForceUpdate = ForceUpdate

        self:RegisterEvent("UNIT_AURA", Update)
        SetupIcons(self)
        return true
    else
        return false
    end
end

local function Disable(self)
    if self.AuraWatch then
        self:UnregisterEvent("UNIT_AURA", Update)
        for _,icon in pairs(self.AuraWatch.icons) do
            icon:Hide()
        end
    end
end

oUF:AddElement("AuraWatch", Update, Enable, Disable)