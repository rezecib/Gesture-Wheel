local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local SkinsPuppet = require "widgets/skinspuppet"
local Text = require "widgets/text"

local ATLAS = "images/avatars.xml"

local SMALLSCALE = 1.0
local LARGESCALE = 1.5
local BROWN = {80/255, 60/255, 30/255, 1}

local default_position = {
	offsetx = 0,
	offsety = -37,
	xyscale = 0.7,
	percent = 0.5,
}

local positions = {
	-- default emote exceptions
	emoteXL_pre_dance0 = {
		offsety = -32,
		percent = 1,
	},
	emoteXL_bonesaw = {
		offsety = -32,
		xyscale = 0.58,
	},
	research = { --/joy
		offsety = -64,
		offsetx = 5,
	},
	emoteXL_kiss = {
		offsety = -27,
		offsetx = -15,
		xyxyscale = 0.78,
	},
	emote_strikepose = {
		offsety = -32,
		percent = 0.4,
	},
	emoteXL_angry = {
		offsety = -42,
	},
	emote_sleepy = {
		xyscale = 0.78,
		percent = 0.7,
	},
	emote_yawn = {
		offsetx = 5,
	},
	
	-- party dance mod exceptions
	powerup = { --buffed
		offsety = -52,
	},
	bedroll_sleep_loop = { --fakebed
		offsety = -7,
		offsetx = 10,
	},
	sleep_loop = { --wasted
		offsety = -7,
		offsetx = 10,
	},
	powerdown = { --pushup
		offsety = -17,
		offsetx = -5,
	},
	death = { --dead
		offsety = -22,
	},
	shock = { --shocked
		offsety = -40,
		offsetx = 5,
	},
	mime = { --various different ones
		offsety = -27,
	},
	
	-- old emotes mod exceptions
}
--All old emotes really needed the same thing, so it's neater to do this
local old_emotes = {"angry", "annoyed_palmdown", "annoyed_facepalm", "feet",
					"hands", "hat", "pants", "happycheer", "sad", "waving"}
for _,emote in ipairs(old_emotes) do
	positions["emote_"..emote] = { offsety = -30 }
end

--Copy over mime positioning for each of the mime anims
for i=1,8 do
	positions["mime"..i] = positions.mime
end

--Set the default value for the table to be the default positioning
metapositions = {
	__index = function() return default_position end,
}
setmetatable(positions, metapositions)

--Set the default values for each of the adjustments listed above to the values of the default table
metaposition = {
	__index = default_position,
}
for anim,position in pairs(positions) do
	setmetatable(position, metaposition)
end

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
		
		--Inflate other characters; Wilson needs to be smaller because of his huge hair
		local wilsonoffsety = 0
		local wilsonxyscale = 1
		if self.prefabname ~= "wilson" and not anim:find("mime") then
			wilsonoffsety = 5
			wilsonxyscale = 1.1
		end
		local position = positions[anim]
		local offsety = position.offsety + wilsonoffsety
		local xyscale = position.xyscale * wilsonxyscale
		self.puppet:SetScale(xyscale)
		self.puppet:SetPosition(position.offsetx, offsety, 0)
		self.puppet.animstate:SetPercent(anim, position.percent)
		if emote.fx and emote.fx == "tears" then
			local fxscale = xyscale/0.7*0.18
			self.fx = self.icon:AddChild(UIAnim())
			self.fx:GetAnimState():SetBank("tears_fx")
			self.fx:GetAnimState():SetBuild("tears")
			self.fx:GetAnimState():Hide("TEARS")
			self.fx:GetAnimState():SetPercent("tears_fx", 0.2)
			self.fx:SetScale(fxscale)
			local m = 20
			self.fx:SetPosition(position.offsetx + emote.fxoffset[1]*m, offsety + emote.fxoffset[2]*m, emote.fxoffset[3]*m)
			
			self.fx2 = self.icon:AddChild(UIAnim())
			self.fx2:GetAnimState():SetBank("tears_fx")
			self.fx2:GetAnimState():SetBuild("tears")
			self.fx2:GetAnimState():Hide("TEARS")
			self.fx2:GetAnimState():SetPercent("tears_fx", 0.2)
			self.fx2:SetRotation(160)
			self.fx2:SetScale(fxscale)
			self.fx2:SetPosition(position.offsetx + emote.fxoffset[1]*m, offsety + emote.fxoffset[2]*m - 50, emote.fxoffset[3]*m)
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
    if not self.puppet then return end
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