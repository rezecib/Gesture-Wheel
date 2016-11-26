local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local SkinsPuppet = require "widgets/skinspuppet"
local Text = require "widgets/text"

local ATLAS = "images/avatars.xml"

local SMALLSCALE = 1.0
local LARGESCALE = 1.5
local BROWN = {80/255, 60/255, 30/255, 1}

local GestureBadge = Class(Widget, function(self, prefab, emotename, emote, image, text)
    Widget._ctor(self, "GestureBadge")
    self.isFE = false
    self:SetClickable(false)

    self.root = self:AddChild(Widget("root"))

    self.icon = self.root:AddChild(Widget("target"))
    self.icon:SetScale(SMALLSCALE)
	self.expanded = false

    if not table.contains(DST_CHARACTERLIST, prefab) and not table.contains(MODCHARACTERLIST, prefab) then
        self.prefabname = "wilson"
    else
        self.prefabname = prefab
    end
	
	if image then
		local anim = type(emote.anim) == "table" and emote.anim[math.floor(#emote.anim/2)] or emote.anim
		self.puppetbg = self.icon:AddChild(Image(ATLAS, "avatar_bg.tex"))
		self.puppet = self.icon:AddChild(SkinsPuppet())
		self.puppet.animstate:SetBank("wilson")
		self.puppet.animstate:Hide("ARM_carry")
		
		local offset = -45
		local offsetx = 0
		local scale = 0.18
		local percent = 0.5
		if anim == "emoteXL_pre_dance0" then
			offset = -40
			percent = 1
		elseif anim == "emoteXL_bonesaw" then
			scale = 0.15
			offset = -30
		elseif anim == "research" then
			offset = -72
			offsetx = 5
		elseif anim == "emoteXL_kiss" then
			scale = 0.2
			offset = -30
			offsetx = -15
		elseif anim == "emote_strikepose" then
			offset = -35
			percent = 0.4
		elseif anim == "powerup" then
			offset = -60
		elseif emotename == "fakebed" then
			offset = -15
			offsetx = 5
		elseif emotename == "wasted" then
			offset = -15
			offsetx = 5
		elseif emotename == "pushup" then
			offset = -25
			offsetx = -5
		elseif emotename == "dead" then
			offset = -30
		elseif anim:find("mime") then
			offset = -35
		end
		if self.prefabname ~= "wilson" then
			offset = offset + 5
			scale = scale*1.1
		end
		self.puppet:SetScale(scale*0.7/0.18)
		self.puppet:SetPosition(offsetx, offset+8, 0)
		self.puppet.animstate:SetPercent(anim, percent)
		if emote.fx and emote.fx == "tears" then
			self.fx = self.icon:AddChild(UIAnim())
			self.fx:GetAnimState():SetBank("tears_fx")
			self.fx:GetAnimState():SetBuild("tears")
			self.fx:GetAnimState():Hide("TEARS")
			self.fx:GetAnimState():SetPercent("tears_fx", 0.2)
			self.fx:SetScale(scale)
			local m = 20
			self.fx:SetPosition(offsetx + emote.fxoffset[1]*m, offset + emote.fxoffset[2]*m, emote.fxoffset[3]*m)
			
			self.fx2 = self.icon:AddChild(UIAnim())
			self.fx2:GetAnimState():SetBank("tears_fx")
			self.fx2:GetAnimState():SetBuild("tears")
			self.fx2:GetAnimState():Hide("TEARS")
			self.fx2:GetAnimState():SetPercent("tears_fx", 0.2)
			self.fx2:SetRotation(160)
			self.fx2:SetScale(scale)
			local m = 20
			self.fx2:SetPosition(offsetx + emote.fxoffset[1]*m, offset + emote.fxoffset[2]*m - 50, emote.fxoffset[3]*m)
		end
		self.puppetframe = self.icon:AddChild(Image(ATLAS, "avatar_frame_white.tex"))
		self.puppetframe:SetTint(unpack(BROWN))
	end
	
	if text then
		self.bg = self.icon:AddChild(Image("images/status_bg.xml", "status_bg.tex"))
		self.bg:SetScale(.11*(emotename:len()+1),.5,0)
		if image then self.bg:SetPosition(-.5,-34,0) end
		self.bg:SetTint(unpack(DEFAULT_PLAYER_COLOUR))

		self.text = self.icon:AddChild(Text(NUMBERFONT, 28))
		self.text:SetHAlign(ANCHOR_MIDDLE)
		if image then
			self.text:SetPosition(3.5, -50, 0)
		else
			self.text:SetPosition(3.5, -18, 0)
		end
		self.text:SetScale(1,.78,1)
		self.text:SetString("/"..emotename)
	end
end)

function GestureBadge:RefreshSkins()
	local data = TheNet:GetClientTableForUser(ThePlayer.userid)
	self.puppet:SetSkins(self.prefabname, data.base_skin,
		{	body = data.body_skin,
			hand = data.hand_skin,
			legs = data.legs_skin,
			feet = data.feet_skin	})
	--TODO: Beard? seems like there's no way to access it from clients, though...
end

function GestureBadge:GetAvatar()
	return "avatar_"..(self.prefabname ~= "" and self.prefabname or "unknown")..".tex"
end

function GestureBadge:Expand()
	if self.expanded then return end
	self.expanded = true
	self.icon:ScaleTo(SMALLSCALE, LARGESCALE, .25)
    if self.puppetframe then self.puppetframe:SetTint(unpack(PLAYERCOLOURS.GREEN)) end
	if self.text then self.bg:SetTint(unpack(PLAYERCOLOURS.GREEN)) end
	self:MoveToFront()
end

function GestureBadge:Contract()
	if not self.expanded then return end
	self.expanded = false
	self.icon:ScaleTo(LARGESCALE, SMALLSCALE, .25)
    if self.puppetframe then self.puppetframe:SetTint(unpack(BROWN)) end
    if self.text then self.bg:SetTint(unpack(DEFAULT_PLAYER_COLOUR)) end
	self:MoveToBack()
end

return GestureBadge