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

local GestureWheel = GLOBAL.require("widgets/gesturewheel")

local cursorx = 0
local cursory = 0
local centerx = 0
local centery = 0
local controls = nil
local keydown = false

--These get populated later when checking the screen size
local STARTSCALE = nil
local NORMSCALE = nil

local gesture = nil
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

local EMOTE_ITEMS = {
	{name = "sleepy",	anim = {anim="emote_sleepy"},	item = "emote_sleepy"},
	{name = "yawn",		anim = {anim="emote_yawn"},	item = "emote_yawn"},
}

local PARTY_ADDED = GLOBAL.KnownModIndex:IsModEnabled("workshop-437521942")
local OLD_ADDED = GLOBAL.KnownModIndex:IsModEnabled("workshop-732180082")
for k,v in pairs(GLOBAL.KnownModIndex:GetModsToLoad()) do
	PARTY_ADDED = PARTY_ADDED or v == "workshop-437521942"
	OLD_ADDED = OLD_ADDED or v == "workshop-732180082"
end

local emote_sets = {}

local function BuildEmoteSets()
	emote_sets = {}
	
	if PARTY_ADDED then
		ONLYEIGHT = false -- this isn't compatible with double-ring
		
		local function build_anim(pre, loop, pst)
			local anim = { pre }
			for i = 0, 10000 do
				table.insert(anim, loop)
			end
			table.insert(anim, pst)
			return anim
		end
		
		table.insert(emote_sets, { emotes = {
				{name = "dance2",	anim = {anim = build_anim("idle_onemanband1_pre", "idle_onemanband1_loop", "idle_onmanband1_pst")}},
				{name = "dance3",	anim = {anim = build_anim("idle_onemanband2_pre", "idle_onemanband2_loop", "idle_onmanband2_pst")}},
				{name = "run",		anim = { anim = { "run_pre", "run_loop", "run_loop", "run_loop", "run_pst" } }},
				{name = "thriller",	anim = {anim = build_anim("mime2", "mime2", "mime2")}},
				{name = "choochoo",	anim = { anim = "mime3" }},
				{name = "plsgo",	anim = { anim = "mime4" }},
				{name = "ez",		anim = {anim = "mime5" }},
				{name = "box",		anim = { anim = "mime6" }},
				{name = "bicycle",	anim = {anim = build_anim("mime8", "mime8", "mime8")}},
				{name = "comehere",	anim = {anim = "mime7" }},
				{name = "wasted",	anim = {anim = build_anim("dozy", "sleep_loop", "sleep_loop")}},
				{name = "buffed",	anim = {anim = "powerup" }},
				{name = "pushup",	anim = {anim = build_anim("powerdown", "powerdown", "powerdown")}},
				{name = "fakebed",	anim = {anim = build_anim("bedroll", "bedroll_sleep_loop", "bedroll_wakeup")}},
				{name = "shock",	anim = {anim = build_anim("shock", "shock", "shock_pst")}},
				{name = "dead",		anim = {anim = {"death", "wakeup"} }},
				{name = "spooked",	anim = {anim = build_anim("distress_pre", "distress_loop", "distress_pst")}},
			},
			radius_offset = 0
		})
	end

	if OLD_ADDED then
		ONLYEIGHT = false -- this isn't compatible with double-ring
		
		table.insert(emote_sets, { emotes = {
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
			radius_offset = -50
		})
	end
	
	local EMOTES = {}
	for _,v in ipairs(DEFAULT_EMOTES) do
		table.insert(EMOTES, v)
	end
    -- (hopefully) temporary code that makes crawling the whole inventory a little more efficient
    EMOTE_ITEM_LOOKUP = {}
    for _,item in pairs(EMOTE_ITEMS) do
        EMOTE_ITEM_LOOKUP[item.item] = item
    end
    -- this is kind of ugly but I want to make the ordering consistent, and they might somehow have duplicates?
    EMOTE_ITEM_POSSESSION = {}
    for _,item in pairs(GLOBAL.TheInventory:GetFullInventory()) do
        if EMOTE_ITEM_LOOKUP[item.item_type] then
            EMOTE_ITEM_POSSESSION[item.item_type] = true
        end
    end
    -- end ugly temporary code
	for _,item in pairs(EMOTE_ITEMS) do
		-- if GLOBAL.TheInventory:CheckClientOwnership(GLOBAL.TheNet:GetUserID(), item.item) then
        if EMOTE_ITEM_POSSESSION[item.item] then
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

	table.insert(emote_sets, {emotes = EMOTES, radius_offset = 0})
end

local function IsDefaultScreen()
	return (GLOBAL.TheFrontEnd:GetActiveScreen().name or ""):find("HUD") ~= nil
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
		
		local OldOnUpdate = controls.OnUpdate
		local function OnUpdate(...)
			OldOnUpdate(...)
			if keydown then
				self.gesturewheel:OnUpdate()
			end
		end
		controls.OnUpdate = OnUpdate
		
		handlers_applied = true
	end
end
AddClassPostConstruct( "widgets/controls", AddGestureWheel )

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