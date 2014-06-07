local _, ns = ...
local oUF = ns.oUF or oUF
if not oUF then return end

local GetReadyCheckStatus = GetReadyCheckStatus

local statusTexture = {
	notready = [=[Interface\RAIDFRAME\ReadyCheck-NotReady]=],
	ready = [=[Interface\RAIDFRAME\ReadyCheck-Ready]=],
	waiting = [=[Interface\RAIDFRAME\ReadyCheck-Waiting]=],
}

local onUpdate
do
	function onUpdate(self, elapsed)
		if(self.finish) then
			self.finish = self.finish - elapsed
			if(self.finish <= 0) then
				self.finish = nil
			end
		elseif(self.fade) then
			self.fade = self.fade - elapsed
			if(self.fade <= 0) then
				self.fade = nil
				self:SetScript('OnUpdate', nil)

				for k, v in next, oUF.objects do
					if(v.ReadyCheck and v.unit == self.unit) then
						v.ReadyCheck:Hide()
					end
				end
			else
				for k, v in next, oUF.objects do
					if(v.ReadyCheck and v.unit == self.unit) then
						v.ReadyCheck:SetAlpha(self.fade / self.offset)
					end
				end
			end
		end
	end
end

local function Update(self)
	if(not IsRaidLeader() and not IsRaidOfficer() and not IsPartyLeader()) then return end

	self.ReadyCheck:SetTexture(statusTexture[GetReadyCheckStatus(self.unit)])
	self.ReadyCheck:SetAlpha(1)
	self.ReadyCheck:Show()
end

local function Prepare(self)
	local readycheck = self.ReadyCheck
	local dummy = readycheck.dummy

	dummy.unit = self.unit
	dummy.finish = readycheck.delayTime or 10
	dummy.fade = readycheck.fadeTime or 1.5
	dummy.offset = readycheck.fadeTime or 1.5

	dummy:SetScript('OnUpdate', OnUpdate)
end

local function Enable(self)
	local readycheck = self.ReadyCheck
	if(readycheck) then
		self:RegisterEvent('READY_CHECK', Update)
		self:RegisterEvent('READY_CHECK_CONFIRM', Update)
		self:RegisterEvent('READY_CHECK_FINISHED', Prepare)

		readycheck.dummy = CreateFrame('Frame', nil, self)

		return true
	end
end

local function Disable(self)
	if(self.ReadyCheck) then
		self:UnregisterEvent('READY_CHECK', Update)
		self:UnregisterEvent('READY_CHECK_CONFIRM', Update)
		self:UnregisterEvent('READY_CHECK_FINISHED', Prepare)
	end
end

oUF:AddElement('ReadyCheck', Update, Enable, Disable)