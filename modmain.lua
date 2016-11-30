Assets = {
	Asset("IMAGE", "images/status_bg.tex"),
	Asset("ATLAS", "images/status_bg.xml"),
}

KEYBOARDTOGGLEKEY = GetModConfigData("KEYBOARDTOGGLEKEY")
if type(KEYBOARDTOGGLEKEY) == "string" then
	KEYBOARDTOGGLEKEY = KEYBOARDTOGGLEKEY:lower():byte()
end
local SCALEFACTOR = GetModConfigData("SCALEFACTOR")
local CENTERWHEEL = GetModConfigData("CENTERWHEEL")
local RESTORECURSOROPTS = GetModConfigData("RESTORECURSOR")
local RESTORECURSOR = RESTORECURSOROPTS and RESTORECURSOROPTS > 1
local ADJUSTCURSOR = RESTORECURSOROPTS and RESTORECURSOROPTS > 2
local IMAGETEXT = GetModConfigData("IMAGETEXT")
local SHOWIMAGE = not IMAGETEXT or IMAGETEXT > 1
local SHOWTEXT = not IMAGETEXT or IMAGETEXT%2 == 1
local LEFTSTICK = GetModConfigData("LEFTSTICK")
local ONLYEIGHT = GetModConfigData("ONLYEIGHT")
local EIGHTS = {}
for i=1,8 do
	EIGHTS[i] = GetModConfigData("EIGHT"..i)
end

local function GetTargetRadius(num_emotes)
	return 70*num_emotes / math.pi
end

--Constants for the emote definitions; name is used for display text, anim for puppet animation

local DEFAULT_EMOTES = {
	{name = "bye",		anim = {anim={"emoteXL_waving4", "emoteXL_waving3"}, randomanim=true}},
	{name = "annoyed",	anim = {anim="emoteXL_annoyed"}},
	{name = "sad",		anim = {anim="emoteXL_sad", fx="tears", fxoffset={0.25,3.25,0}, fxdelay=17*GLOBAL.FRAMES}},
	{name = "joy",		anim = {anim="research", fx=false}},
	{name = "facepalm",	anim = {anim="emoteXL_facepalm"}},
	{name = "wave",		anim = {anim={"emoteXL_waving1", "emoteXL_waving2"}, randomanim=true}},
	{name = "dance",	anim = { anim = { "emoteXL_pre_dance0", "emoteXL_loop_dance0" }, loop = true, fx = false, beaver = true }},
	{name = "pose",		anim = {anim = "emote_strikepose", zoom = true, soundoverride = "/pose"}},
	{name = "kiss",		anim = {anim="emoteXL_kiss"}},
	{name = "bonesaw",	anim = {anim="emoteXL_bonesaw"}},
	{name = "happy",	anim = {anim="emoteXL_happycheer"}},
	{name = "angry",	anim = {anim="emoteXL_angry"}},
	--TODO: make sure this list stays up to date
}

--These emotes are unlocked by certain cosmetic Steam/skin items
local EMOTE_ITEMS = {
	{name = "sleepy",	anim = {anim="emote_sleepy"},	item = "emote_sleepy"},
	{name = "yawn",		anim = {anim="emote_yawn"},	    item = "emote_yawn"},
}

--Checking for other emote mods
local PARTY_ADDED = GLOBAL.KnownModIndex:IsModEnabled("workshop-437521942")
local OLD_ADDED = GLOBAL.KnownModIndex:IsModEnabled("workshop-732180082")
for k,v in pairs(GLOBAL.KnownModIndex:GetModsToLoad()) do
	PARTY_ADDED = PARTY_ADDED or v == "workshop-437521942"
	OLD_ADDED = OLD_ADDED or v == "workshop-732180082"
end

local PARTY_EMOTES = {}
if PARTY_ADDED then
	ONLYEIGHT = false -- this isn't compatible with double-ring
	PARTY_EMOTES = { emotes = {
				{name = "dance2",	anim = {anim = "idle_onemanband1_loop"}},
				{name = "dance3",	anim = {anim = "idle_onemanband2_loop"}},
				{name = "run",		anim = {anim = {"run_pre", "run_loop", "run_loop", "run_loop", "run_pst"}}},
				{name = "thriller",	anim = {anim = "mime2"}},
				{name = "choochoo",	anim = {anim = "mime3"}},
				{name = "plsgo",	anim = {anim = "mime4"}},
				{name = "ez",		anim = {anim = "mime5"}},
				{name = "box",		anim = {anim = "mime6"}},
				{name = "bicycle",	anim = {anim = "mime8"}},
				{name = "comehere",	anim = {anim = "mime7"}},
				{name = "wasted",	anim = {anim = "sleep_loop"}},
				{name = "buffed",	anim = {anim = "powerup"}},
				{name = "pushup",	anim = {anim = "powerdown"}},
				{name = "fakebed",	anim = {anim = "bedroll_sleep_loop"}},
				{name = "shocked",	anim = {anim = "shock"}},
				{name = "dead",		anim = {anim = {"death", "wakeup"}}},
				{name = "spooked",	anim = {anim = "distress_loop"}},
			},
		}
	--Will need to be adjusted if number of emotes changes; currently evaluates to ~399
	PARTY_EMOTES.radius = GetTargetRadius(#PARTY_EMOTES.emotes) + 20
end

local OLD_EMOTES = {}
if OLD_ADDED then
	ONLYEIGHT = false -- this isn't compatible with double-ring
	OLD_EMOTES = { emotes = {
				{name = "angry2",	anim = {anim = "emote_angry"}},
				{name = "annoyed2",	anim = {anim = "emote_annoyed_palmdown"}},
				{name = "gdi",		anim = {anim = "emote_annoyed_facepalm"}},
				{name = "pose2",	anim = {anim = "emote_feet"}},
				{name = "pose3",	anim = {anim = "emote_hands"}},
				{name = "pose4",	anim = {anim = "emote_hat"}},
				{name = "pose5",	anim = {anim = "emote_pants"}},
				{name = "grats",	anim = {anim = "emote_happycheer"}},
				{name = "sigh",		anim = {anim = "emote_sad"}},
				{name = "heya",		anim = {anim = "emote_waving"}},
			},
		}
	--Will need to be adjusted if number of emotes changes; currently evaluates to ~173
	OLD_EMOTES.radius = GetTargetRadius(#OLD_EMOTES.emotes) - 50
end

local emote_sets = {}

local function BuildEmoteSets()
	emote_sets = {}
	
	if PARTY_ADDED then
		table.insert(emote_sets, PARTY_EMOTES)
	end

	if OLD_ADDED then
		table.insert(emote_sets, OLD_EMOTES)
	end
	
	--Add in all the default emotes
	local EMOTES = {}
	for _,v in ipairs(DEFAULT_EMOTES) do
		table.insert(EMOTES, v)
	end
	--Check if we have some of the emote items
	for _,item in pairs(EMOTE_ITEMS) do
		if GLOBAL.TheInventory:CheckOwnership(item.item) then
			table.insert(EMOTES, item)
		end
	end

	if ONLYEIGHT then
		local EIGHTEMOTES = {}
		for i,v in ipairs(EIGHTS) do
			for i,w in ipairs(EMOTES) do
				if v == w.name then
					table.insert(EIGHTEMOTES, w)
				end
			end
		end
		EMOTES = EIGHTEMOTES
	end
	
	--Will need to be adjusted if number of emotes changes; currently evaluates to ~282
	table.insert(emote_sets, {
			emotes = EMOTES,
			radius = ONLYEIGHT and GetTargetRadius(#EMOTES)
								-- We want it to be the same radius regardless of how many you unlocked
								or GetTargetRadius(#DEFAULT_EMOTES + #EMOTE_ITEMS)-30
		}
	)
end

--All code below is for handling the wheel

local GestureWheel = GLOBAL.require("widgets/gesturewheel")

--Variables to control the display of the wheel
local cursorx = 0
local cursory = 0
local centerx = 0
local centery = 0
local controls = nil
local keydown = false
local STARTSCALE = nil
local NORMSCALE = nil

local function IsDefaultScreen()
	local screen = GLOBAL.TheFrontEnd:GetActiveScreen()
	return ((screen and type(screen.name) == "string") and screen.name or ""):find("HUD") ~= nil
		and not(GLOBAL.ThePlayer.HUD:IsControllerCraftingOpen() or GLOBAL.ThePlayer.HUD:IsControllerInventoryOpen())
end

local function ResetTransform()
	local screenwidth, screenheight = GLOBAL.TheSim:GetScreenSize()
	centerx = screenwidth/2
	centery = screenheight/2
	local screenscalefactor = math.min(screenwidth/1920, screenheight/1080) --normalize by my testing setup, 1080p
	STARTSCALE = 0.25*SCALEFACTOR*screenscalefactor
	NORMSCALE = SCALEFACTOR*screenscalefactor
	controls.gesturewheel:SetPosition(centerx, centery, 0)
	controls.gesturewheel.inst.UITransform:SetScale(STARTSCALE, STARTSCALE, 1)
end

local function ShowGestureWheel()
	if keydown then return end
	if type(GLOBAL.ThePlayer) ~= "table" or type(GLOBAL.ThePlayer.HUD) ~= "table" then return end
	if not IsDefaultScreen() then return end
	
	keydown = true
	SetModHUDFocus("GestureWheel", true)
	
	ResetTransform()
	
	for _,gesturebadge in pairs(controls.gesturewheel.gestures) do
		gesturebadge:RefreshSkins()
	end
	
	if RESTORECURSOR then
		cursorx, cursory = GLOBAL.TheInputProxy:GetOSCursorPos()
	end
	
	if CENTERWHEEL then
		GLOBAL.TheInputProxy:SetOSCursorPos(centerx, centery)
	else
		controls.gesturewheel:SetPosition(GLOBAL.TheInput:GetScreenPosition():Get())
	end
	controls.gesturewheel:Show()
	controls.gesturewheel:ScaleTo(STARTSCALE, NORMSCALE, .25)
end

local function HideGestureWheel(delay_focus_loss)
	if type(GLOBAL.ThePlayer) ~= "table" or type(GLOBAL.ThePlayer.HUD) ~= "table" then return end
	keydown = false
	if delay_focus_loss and controls.gesturewheel.activegesture then
		--delay a little on controllers to prevent canceling the emote by moving
		GLOBAL.ThePlayer:DoTaskInTime(0.5, function() SetModHUDFocus("GestureWheel", false) end)
	else
		SetModHUDFocus("GestureWheel", false)
	end
	
	controls.gesturewheel:Hide()
	controls.gesturewheel.inst.UITransform:SetScale(STARTSCALE, STARTSCALE, 1)
	
	if not IsDefaultScreen() then return end
	
	if RESTORECURSOR then
		if ADJUSTCURSOR then
			local x,y = GLOBAL.TheInputProxy:GetOSCursorPos()
			local gx, gy = controls.gesturewheel:GetPosition():Get()
			local dx, dy = x-gx, y-gy
			cursorx = cursorx + dx
			cursory = cursory + dy
		end
		GLOBAL.TheInputProxy:SetOSCursorPos(cursorx, cursory)
	end
	
	if controls.gesturewheel.activegesture then
		GLOBAL.TheNet:SendSlashCmdToServer(controls.gesturewheel.activegesture, true)
	end
end

local handlers_applied = false
local function AddGestureWheel(self)
	BuildEmoteSets() --delay this so that the account item checks are more likely to work
	controls = self -- this just makes controls available in the rest of the modmain's functions
	if controls.gesturewheel then
		controls.gesturewheel:Kill()
	end
	controls.gesturewheel = controls:AddChild(GestureWheel(emote_sets, SHOWIMAGE, SHOWTEXT, LEFTSTICK))
	ResetTransform()
	controls.gesturewheel:Hide()
	
	if not handlers_applied then
		-- Keyboard controls
		GLOBAL.TheInput:AddKeyDownHandler(KEYBOARDTOGGLEKEY, ShowGestureWheel)
		GLOBAL.TheInput:AddKeyUpHandler(KEYBOARDTOGGLEKEY, HideGestureWheel)
		
		-- Controller controls
		-- This is pressing the left stick in
		-- CONTROL_MENU_MISC_3 is the same thing as CONTROL_OPEN_DEBUG_MENU
		-- CONTROL_MENU_MISC_4 is the right stick click
		GLOBAL.TheInput:AddControlHandler(GLOBAL.CONTROL_MENU_MISC_3, function(down)
			if down then
				ShowGestureWheel()
			else
				HideGestureWheel(true)
			end
		end)
				
		handlers_applied = true
	end
end
AddClassPostConstruct( "widgets/controls", AddGestureWheel )

--Patch the class definition directly instead of each new instance
local Controls = GLOBAL.require("widgets/controls")
local OldOnUpdate = Controls.OnUpdate
local function OnUpdate(self, ...)
	OldOnUpdate(self, ...)
	if keydown then
		self.gesturewheel:OnUpdate()
	end
end
Controls.OnUpdate = OnUpdate

--In order to update the emote set when a skin is received, hook into the giftitempopup
AddClassPostConstruct("screens/giftitempopup", function(self)
	local function ScheduleRebuild()
		--give it a little time to update the skin inventory
		controls.owner:DoTaskInTime(5, function() AddGestureWheel(controls) end)
	end
	local OldOnClose = self.OnClose
	function self:OnClose(...)
		OldOnClose(self, ...)
		ScheduleRebuild()
	end
	local OldApplySkin = self.ApplySkin
	function self:ApplySkin(...)
		OldApplySkin(self, ...)
		ScheduleRebuild()
	end
end)