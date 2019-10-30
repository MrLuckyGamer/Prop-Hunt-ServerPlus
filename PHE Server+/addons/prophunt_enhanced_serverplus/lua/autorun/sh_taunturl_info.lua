-- ConVars
CreateConVar("ph_taunturl_delay","10", {FCVAR_SERVER_CAN_EXECUTE,FCVAR_REPLICATED,FCVAR_ARCHIVE,FCVAR_NOTIFY}, "Delay when playing Taunt URL. Recommended Minimum value is 10.")
CreateConVar("ph_taunturl_followply","0",{FCVAR_SERVER_CAN_EXECUTE,FCVAR_REPLICATED,FCVAR_ARCHIVE,FCVAR_NOTIFY}, "Play the taunts follow the player? (Experimental) - 0 to stay on his last station movement.")
CreateConVar("ph_taunturl_enable","1", {FCVAR_SERVER_CAN_EXECUTE,FCVAR_REPLICATED,FCVAR_ARCHIVE,FCVAR_NOTIFY}, "Enable TauntURL feature.")

-- stupid callback tbh...
if (SERVER) then
	cvars.AddChangeCallback("ph_taunturl_followply", function(cvar,old,new)
		if GetConVar("ph_taunturl_enable"):GetBool() then
			if (new == "0" || tonumber(new) == 0) then
				net.Start("svPHGCleanupMovingStations")
				net.Broadcast()
			end
		end
	end, "tauntURLfollow")
end

-- Initialisation
PHT = {}
PHT.__index = PHT

PHT.UISTATE = 0

if (CLIENT) then
	CreateClientConVar("ph_taunturl_listen", "1", true,false,"Listen to played taunt URLs?")
end	

-- (Please Change) A template of Taunt List which SERVER can only provide to the client. 
-- User can include some custom url followed from what they had.
PHT.SERVER_DEFAULT_TAUNTURL = {
	["Crash: Crystal Pickup"] 	= "http://localhost/fastdl/public/crystal_pickup.wav",
	["Crash: Wumpa Pickup"] 	= "http://localhost/fastdl/public/wumpa_pickup.wav",
	["Running in 90"]			= "http://localhost/fastdl/public/29.wav",
	["JAWS"] 					= "http://localhost/fastdl/public/le_jaws.wav",
	["Truck Horn"]				= "http://localhost/fastdl/public/truck_horn.wav",
	["Fake Door Sound"]			= "http://localhost/fastdl/public/door.wav",
	["Weird Sound"]				= "http://localhost/fastdl/public/rc_notice1.wav"
}

-- Your Main Configuration Here
PHT.DEFAULT_KEY		= KEY_F7 	-- Default Key to make TauntURL to display.
PHT.ALLOWED_GROUPS 	= WLV.USER.DEFAULT_ALLVIP

if SERVER then
	include("taunturl/sv_action.lua")
	include("taunturl/sv_showui.lua")
	AddCSLuaFile("taunturl/cl_taunturl_ui.lua")
	AddCSLuaFile("taunturl/cl_taunturl_pl.lua")
else
	include("taunturl/cl_taunturl_ui.lua")
	include("taunturl/cl_taunturl_pl.lua")
end

local ADDON_INFO = {
	name	= "Taunt URL",
	version	= "1.0",
	info	= "Plays your favorite Taunt via URLs.",
	
	settings = {
		{"ph_taunturl_enable", "check", "SERVER", "Enable TauntURL feature"},
		{"ph_taunturl_delay" , "slider", {min = 8, max = 60, init = 10, dec = 0, kind = "SERVER"}, "Delay for TauntURL"},
		{"ph_taunturl_followply", "check", "SERVER", "(Experimental) Follow taunt to Player whom played the taunt"}
	},
	
	client	= {{"ph_taunturl_listen", "check", "CLIENT", "Listen to Taunt URL?"}}
}
list.Set("PHE.Plugins","TauntURL",ADDON_INFO)