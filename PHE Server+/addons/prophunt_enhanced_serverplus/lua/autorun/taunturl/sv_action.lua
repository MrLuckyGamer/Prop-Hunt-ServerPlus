util.AddNetworkString("clPHT.TauntInfo")
util.AddNetworkString("svPHT.DoTauntURL")
util.AddNetworkString("svPHGCleanupMovingStations")

local taunturltime = 0
net.Receive("clPHT.TauntInfo", function(len,ply)

	if taunturltime <= CurTime() then
		local url 	= net.ReadString()
		local mode	= net.ReadBool() -- if mode == true, it's a mono. otherwise stereo.
		
		net.Start("svPHT.DoTauntURL")
			net.WriteString(url)
			net.WriteEntity(ply) --Origin of the sound
			net.WriteBool(mode)
		net.Broadcast()
		
		taunturltime = CurTime() + GetConVar("ph_taunturl_delay"):GetInt()
	else
		ply:ChatPrint("[TauntURL] Please wait in ".. math.Round(taunturltime - CurTime()) .. " Seconds.")
	end
end)

hook.Add("PreCleanupMap", "RemoveAnyMovement", function()
	if GetConVar("ph_taunturl_enable"):GetBool() then
		net.Start("svPHGCleanupMovingStations")
		net.Broadcast()
	end
end)