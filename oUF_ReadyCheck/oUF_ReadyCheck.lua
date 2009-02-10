--[[

	Elements handled:
	 .ReadyCheck [texture]

--]]

local OnCheckUpdate
do
	local total = 0
	local pairs = pairs
	function OnCheckUpdate(self, elapsed)
		total = total + elapsed
		if(total >= 10) then
			for k,v in ipairs(oUF.objects) do
				if(type(v) == 'table' and v.ReadyCheck) then
					v.ReadyCheck:Hide()
				end
			end
			total = 0
			self:SetScript('OnUpdate', nil)
		else
			local alpha = (15 - total) / 15
			for k,v in ipairs(oUF.objects) do
				if(type(v) == 'table' and v.ReadyCheck) then
					v.ReadyCheck:SetAlpha(alpha)
				end
			end
		end
	end
end

local function READY_CHECK(self, event, name)
	if(not IsRaidLeader() and not IsRaidOfficer() and not IsPartyLeader()) then return end

	local icon = self.ReadyCheck
	if(UnitName(self.unit) == name) then
		icon:SetTexture([=[Interface\RAIDFRAME\ReadyCheck-Ready]=])
	else
		icon:SetTexture([=[Interface\RAIDFRAME\ReadyCheck-Waiting]=])
	end

	icon:SetAlpha(1)
	icon:Show()
end

local function READY_CHECK_CONFIRM(self, event, index, status)
	if(self.id ~= tostring(index)) then return end

	if(status and status == 1) then
		icon:SetTexture([=[Interface\RAIDFRAME\ReadyCheck-Ready]=])
	else
		icon:SetTexture([=[Interface\RAIDFRAME\ReadyCheck-NotReady]=])
	end
end

local function READY_CHECK_FINISHED()
	CreateFrame('Frame'):SetScript('OnUpdate', OnCheckUpdate)
end

local function Enable(self)
	if(self.ReadyCheck) then
		self:RegisterEvent('READY_CHECK', READY_CHECK)
		self:RegisterEvent('READY_CHECK_CONFIRM', READY_CHECK_CONFIRM)
		self:RegisterEvent('READY_CHECK_FINISHED', READY_CHECK_FINISHED)
	end
end

local function Disable(self)
	if(self.ReadyCheck) then
		self:UnregisterEvent('READY_CHECK', READY_CHECK)
		self:UnregisterEvent('READY_CHECK_CONFIRM', READY_CHECK_CONFIRM)
		self:UnregisterEvent('READY_CHECK_FINISHED', READY_CHECK_FINISHED)
	end
end

oUF:AddElement('ReadyCheck', nil, Enable, Disable)