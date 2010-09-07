local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, 'oUF ReadyCheck was unable to locate oUF install')

local OnUpdateDummy
do
	OnUpdateDummy = CreateFrame('Frame')
	OnUpdateDummy.objects = {}
	OnUpdateDummy:Hide()
	OnUpdateDummy:SetScript('OnUpdate', function(self, elapsed)
		if(self.elapsed <= 6) then
			self.elapsed = self.elapsed + elapsed

			for object in pairs(self.objects) do
				object:SetAlpha(self.elapsed / 6)
			end
		else
			wipe(OnUpdateDummy.objects)
			self:Hide()
		end
	end)
end

local function Update(self, event)
	if(not IsRaidLeader() and not IsRaidOfficer() and not IsPartyLeader()) then return end
	local readycheck = self.ReadyCheck

	if(event == 'READY_CHECK_FINISHED') then
		if(readycheck:GetTexture() == READY_CHECK_WAITING_TEXTURE) then
			readycheck:SetTexture(READY_CHECK_NOT_READY)
		end

		OnUpdateDummy.elapsed = 6
		OnUpdateDummy.objects[readycheck] = true
		OnUpdateDummy:Show()
		return
	end

	local status = GetReadyCheckStatus(self.unit)
	if(not status) then
		return readycheck:Hide()
	end

	if(status == 'ready') then
		readycheck:SetTexture(READY_CHECK_READY_TEXTURE)
	elseif(status == 'notready') then
		readycheck:SetTexture(READY_CHECK_NOT_READY_TEXTURE)
	elseif(status == 'waiting') then
		readycheck:SetTexture(READY_CHECK_WAITING_TEXTURE)
	end

	readycheck:SetAlpha(1)
	readycheck:Show()
end

local function Path(self, ...)
	return (self.ReadyCheck.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local readycheck = self.ReadyCheck
	if(readycheck) then
		readycheck.__owner = self
		readycheck.ForceUpdate = ForceUpdate

		self:RegisterEvent('READY_CHECK', Path)
		self:RegisterEvent('READY_CHECK_CONFIRM', Path)
		self:RegisterEvent('READY_CHECK_FINISHED', Path)

		return true
	end
end

local function Disable(self)
	if(self.ReadyCheck) then
		self:UnregisterEvent('READY_CHECK', Path)
		self:UnregisterEvent('READY_CHECK_CONFIRM', Path)
		self:UnregisterEvent('READY_CHECK_FINISHED', Path)
	end
end

oUF:AddElement('ReadyCheck', Path, Enable, Disable)
