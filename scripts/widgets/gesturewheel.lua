local Widget = require "widgets/widget"
local Text = require "widgets/text"
local GestureBadge = require("widgets/gesturebadge")

local GestureWheel = Class(Widget, function(self, emote_sets, image, text, rightstick)
	Widget._ctor(self, "GestureWheel")
	self.isFE = false
	self:SetClickable(false)
	self.userightstick = rightstick
	self.screenscalefactor = 1

	self.root = self:AddChild(Widget("root"))

	self.gestures = {}
	self.wheels = {}
	self.activewheel = nil
	self.controllermode = false

	local function build_wheel(name, emotes, radius, color, scale)
		local wheel = self.root:AddChild(Widget("GestureWheelRoot-"..name))
		wheel:SetScale(1)
		table.insert(self.wheels, wheel)
		if name == "default" then
			self.activewheel = #self.wheels
		end
		local count = #emotes
		radius = radius * scale
		wheel.radius = radius
		local delta = 2*math.pi/count
		local theta = 0
		wheel.gestures = {}
		for i,v in ipairs(emotes) do
			local gesture = wheel:AddChild(GestureBadge(ThePlayer.prefab, v.name, v.anim, image, text, color))
			gesture:SetPosition(radius*math.cos(theta),radius*math.sin(theta), 0)
			gesture:SetScale(scale)
			self.gestures[v.name] = gesture
			wheel.gestures[v.name] = gesture
			theta = theta + delta
		end
	end
	-- Sort the emote sets in order of decreasing radius
	table.sort(emote_sets, function(a,b) return a.radius > b.radius end)
	local scale = 1
	for _,emote_set in ipairs(emote_sets) do
		build_wheel(emote_set.name, emote_set.emotes, emote_set.radius, emote_set.color, scale)
		scale = scale * 0.85
	end
	
	self.controllerhints = self:AddChild(Widget("controllerhintsroot"))
	local controller_id = TheInput:GetControllerID()
	self.innerhint = self.controllerhints:AddChild(Text(UIFONT, 30))
	self.innerhint:SetString(TheInput:GetLocalizedControl(controller_id, CONTROL_ROTATE_RIGHT))
	self.outerhint = self.controllerhints:AddChild(Text(UIFONT, 30))
	self.outerhint:SetString(TheInput:GetLocalizedControl(controller_id, CONTROL_ROTATE_LEFT))
	self.outerhint:SetPosition(-1*emote_sets[1].radius - 100, 0)
	self.controllerhints:Hide()
end)

local function GetMouseDistance(self, gesture, mouse)
	local pos = self:GetPosition()
	if gesture ~= nil then
		local offset = gesture:GetPosition()*self.screenscalefactor
		pos.x = pos.x + offset.x
		pos.y = pos.y + offset.y
	end
	local dx = pos.x - mouse.x
	local dy = pos.y - mouse.y
	return dx*dx + dy*dy
end

local function GetControllerDistance(self, gesture, direction)
	local pos = self:GetPosition()
	if gesture ~= nil then
		pos = gesture:GetPosition()
	else
		pos.x = 0
		pos.y = 0
	end
	local dx = pos.x - direction.x
	local dy = pos.y - direction.y
	return dx*dx + dy*dy
end

local function GetControllerTilt(right)
	local xdir = 0
	local ydir = 0
	if right then
		xdir = TheInput:GetAnalogControlValue(CONTROL_INVENTORY_RIGHT) - TheInput:GetAnalogControlValue(CONTROL_INVENTORY_LEFT)
		ydir = TheInput:GetAnalogControlValue(CONTROL_INVENTORY_UP) - TheInput:GetAnalogControlValue(CONTROL_INVENTORY_DOWN)
	else
		xdir = TheInput:GetAnalogControlValue(CONTROL_MOVE_RIGHT) - TheInput:GetAnalogControlValue(CONTROL_MOVE_LEFT)
		ydir = TheInput:GetAnalogControlValue(CONTROL_MOVE_UP) - TheInput:GetAnalogControlValue(CONTROL_MOVE_DOWN)
	end
	return xdir, ydir
end

function GestureWheel:OnUpdate()
	local mindist = math.huge
	local mingesture = nil
	
	if TheInput:ControllerAttached() then
		local xdir, ydir = GetControllerTilt(self.userightstick)
		local deadzone = .5
		if math.abs(xdir) >= deadzone or math.abs(ydir) >= deadzone then
			local wheel = self.wheels[self.activewheel]
			local dir = Vector3(xdir, ydir, 0):GetNormalized() * wheel.radius
			
			for k,v in pairs(wheel.gestures) do
				local dist = GetControllerDistance(self, v, dir)
				if dist < mindist then
					mindist = dist
					mingesture = k
				end
			end
		else
			mingesture = nil
			self.activegesture = nil		
		end
	else
		--find the gesture closest to the mouse
		local mouse = TheInput:GetScreenPosition()
		for k,v in pairs(self.gestures) do
			local dist = GetMouseDistance(self, v, mouse)
			if dist < mindist then
				mindist = dist
				mingesture = k
			end
		end
		-- make sure the mouse isn't still close to the center of the gesture wheel
		if GetMouseDistance(self, nil, mouse) < mindist then
			mingesture = nil
			self.activegesture = nil
		end
	end
	
	for k,v in pairs(self.gestures) do
		if k == mingesture then
			v:Expand()
			self.activegesture = k
		else
			v:Contract()
		end
	end
end

local function SetWheelAlpha(wheel, alpha)
	for _,badge in pairs(wheel.gestures) do
		badge:SetFadeAlpha(alpha)
		if badge.puppet ~= nil then
			badge.puppet.animstate:SetMultColour(1,1,1,alpha)
		end
	end
end

function GestureWheel:SetControllerMode(enabled)
	if self.controllermode ~= enabled then
		self.controllermode = enabled
		local alpha = enabled and 0.25 or 1
		for i,wheel in pairs(self.wheels) do
			SetWheelAlpha(wheel, i == self.activewheel and 1 or alpha)
		end
		if enabled then
			self.controllerhints:Show()
		else
			self.controllerhints:Hide()
		end
	end
end

function GestureWheel:SwitchWheel(delta)
	if self.activewheel == nil then return end
	local oldwheel = self.activewheel
	self.activewheel = math.max(1, math.min(self.activewheel + delta, #self.wheels))
	if oldwheel ~= self.activewheel then
		if self.activegesture ~= nil then
			self.gestures[self.activegesture]:Contract()
			self.activegesture = nil
		end
		SetWheelAlpha(self.wheels[oldwheel], 0.25)
		SetWheelAlpha(self.wheels[self.activewheel], 1)
	end
end

return GestureWheel