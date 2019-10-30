util.AddNetworkString("svPHT.ShowUI")

local allowedlist = {
	"STEAM_0:0:74820364",
	"STEAM_0:0:0"
}

function PHT.KeyUp(ply,key)
	if (IsValid(ply)) then
		if (key == PHT.DEFAULT_KEY) then
		
			--override specific
			if table.HasValue(allowedlist,ply:SteamID()) then
				net.Start("svPHT.ShowUI")
				net.Send(ply)
				return
			end
		
			if !table.HasValue(PHT.ALLOWED_GROUPS, ply:GetUserGroup()) then
				ply:ChatPrint("[Taunt URL] You are not eligible to access this feature. Sorry!")
			elseif !GetConVar("ph_taunturl_enable"):GetBool() then 
				ply:ChatPrint("[TauntURL] TauntURL is disabled on this server.")
			else
				net.Start("svPHT.ShowUI")
				net.Send(ply)
			end
		end
	end
end
hook.Add("PlayerButtonUp","PHT.PressedTauntURL",function(ply, btn)
	PHT.KeyUp(ply,btn)
end)