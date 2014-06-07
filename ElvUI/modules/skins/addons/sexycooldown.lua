local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.addons.enable ~= true or E.private.skins.addons.sexycooldown ~= true then return end
	local LSM = LibStub("LibSharedMedia-3.0")

	local function SCDStripSkinSettings(bar)
		bar.optionsTable.args.icon.args.borderheader = nil
		bar.optionsTable.args.icon.args.border = nil
		bar.optionsTable.args.icon.args.borderColor = nil
		bar.optionsTable.args.icon.args.borderSize = nil
		bar.optionsTable.args.icon.args.borderInset = nil
		bar.optionsTable.args.bar.args.bnbheader = nil
		bar.optionsTable.args.bar.args.texture = nil
		bar.optionsTable.args.bar.args.backgroundColor = nil
		bar.optionsTable.args.bar.args.border = nil
		bar.optionsTable.args.bar.args.borderColor = nil
		bar.optionsTable.args.bar.args.borderSize = nil
		bar.optionsTable.args.bar.args.borderInset = nil
	end

	local function SkinSexyCooldownBar(bar)
		SCDStripSkinSettings(bar)
		bar:SetTemplate("Transparent")
	end

	local function SkinSexyCooldownIcon(bar, icon)
		if not icon.skinned then
			icon:CreateBackdrop('Default')
			icon.overlay:CreateBackdrop("Default")
			icon.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			icon.tex.SetTexCoord = E.noop
			icon.overlay:SetBackdropColor(0,0,0,0)
			icon:SetBackdropColor(0,0,0,0)
			icon:SetBackdropBorderColor(E["media"].bordercolor)
			icon.overlay:SetBackdropBorderColor(E["media"].bordercolor)
			icon.skinned = true
		end
	end

	local function SkinSexyCooldownLabel(bar,label,store)
		if not label.skinned then
			label:SetFont(LSM:Fetch("font", E.db.actionbar.font), E.db.actionbar.fontSize, E.db.actionbar.fontOutline)
		end
	end

	local function SkinSexyCooldownBackdrop(bar)
		bar:SetTemplate("Transparent")
	end

	local function HookSCDBar(bar)
		hooksecurefunc(bar, "UpdateBarLook", SkinSexyCooldownBar)
		hooksecurefunc(bar, "UpdateSingleIconLook", SkinSexyCooldownIcon)
		hooksecurefunc(bar, "UpdateLabel", SkinSexyCooldownLabel)
		hooksecurefunc(bar, "UpdateBarBackdrop", SkinSexyCooldownBackdrop)
		bar.settings.icon.borderInset = 0
	end

	SexyCooldown.CreateBar_ = SexyCooldown.CreateBar
	SexyCooldown.CreateBar = function(self, settings, name)
		local bar = SexyCooldown:CreateBar_(settings,name)
		HookSCDBar(bar)
		return bar
	end

	for _,bar in ipairs(SexyCooldown.bars) do
		HookSCDBar(bar)
		bar:UpdateBarLook()
	end
end

S:RegisterSkin('SexyCooldown', LoadSkin)