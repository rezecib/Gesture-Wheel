local Widget = require "widgets/widget"
local GestureBadge = require("widgets/gesturebadge")

local GestureWheel = Class(Widget, function(self, emote_sets, image, text, leftstick)
    Widget._ctor(self, "GestureWheel")
    self.isFE = false
    self:SetClickable(false)
	self.useleftstick = leftstick

    self.root = self:AddChild(Widget("root"))

    self.icon = self.root:AddChild(Widget("target"))
    self.icon:SetScale(1)
	self.gestures = {}
	
	local function build_wheel(emotes, radius)
		local count = #emotes
		local dist = radius
		self.radius = math.max(self.radius or 0, dist)
		local delta = 2*math.pi/count
		local theta = 0
		for i,v in ipairs(emotes) do
			self.gestures[v.name] = self.icon:AddChild(GestureBadge(ThePlayer.prefab, v.name, v.anim, image, text))
			self.gestures[v.name]:SetPosition(dist*math.cos(theta),dist*math.sin(theta), 0)
			theta = theta + delta
		end
	end
	for _,emote_set in ipairs(emote_sets) do
		build_wheel(emote_set.emotes, emote_set.radius)
	end
end)

local function GetMouseDistance(self, gesture, mouse)
	local pos = self:GetPosition()
	if gesture ~= nil then
		local offset = gesture:GetPosition()
		pos.x = pos.x + offset.x
		pos.y = pos.y + offset.y
	end
	local dx = pos.x - mouse.x
	local dy = pos.y - mouse.y
	return dx*dx + dy*dy
end

local function GetControllerDistance(self, gesture, direction)
	direction = direction * self.radius
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

local function GetControllerTilt(left)
	local xdir = 0
	local ydir = 0
	if left then
		xdir = TheInput:GetAnalogControlValue(CONTROL_MOVE_RIGHT) - TheInput:GetAnalogControlValue(CONTROL_MOVE_LEFT)
		ydir = TheInput:GetAnalogControlValue(CONTROL_MOVE_UP) - TheInput:GetAnalogControlValue(CONTROL_MOVE_DOWN)
	else
		xdir = TheInput:GetAnalogControlValue(CONTROL_INVENTORY_RIGHT) - TheInput:GetAnalogControlValue(CONTROL_INVENTORY_LEFT)
		ydir = TheInput:GetAnalogControlValue(CONTROL_INVENTORY_UP) - TheInput:GetAnalogControlValue(CONTROL_INVENTORY_DOWN)
	end
	return xdir, ydir
end

function GestureWheel:OnUpdate()
	local mindist = math.huge
	local mingesture = nil
	
	if TheInput:ControllerAttached() then
		local xdir, ydir = GetControllerTilt(self.useleftstick)
		local deadzone = .5
		if math.abs(xdir) >= deadzone or math.abs(ydir) >= deadzone then
			local dir = Vector3(xdir, ydir, 0):GetNormalized()
			
			for k,v in pairs(self.gestures) do
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

return GestureWheel