function PHT.PlaySound(ply, url, mode)
	sound.PlayURL(url, mode, function(station,id,err)
		if ( IsValid(station) && IsValid( ply ) ) and station ~= nil then
		
			if ply.st then 
				ply.st:Stop(); ply.st = nil;
				hook.Remove("Think", "MoveStation_"..ply:EntIndex())
			end
			
			timer.Simple(0.1, function()
				ply.st = station
				ply.st:SetPos(ply:GetPos())
				ply.st:SetVolume(1)
				ply.st:Play()
				
				-- Experimental Code, please be careful that this may be unstable!
				if GetConVar("ph_taunturl_followply"):GetBool() then
					hook.Add("Think", "MoveStation_"..ply:EntIndex(), function()
						if (IsValid(ply.st)) then
							ply.st:SetPos(ply:GetPos())
						end
					end)
				end
			end)
		else
			chat.AddText(Color(230,0,0),"[TauntURL] ",color_white,"Error: Invalid URL!")
			return
		end
	end)
end

net.Receive("svPHT.DoTauntURL", function()
	local url = net.ReadString()
	local ent = net.ReadEntity()
	local mode = net.ReadBool()
	
	if (!IsValid(ent)) then return end
	
	if !GetConVar("ph_taunturl_listen"):GetBool() then
		chat.AddText(Color(200,0,0),"[TauntURL] ",color_white,"It seems you disabled Taunt URL Listening. Use ph_taunturl_listen 1 to play the taunts!")
		return
	elseif !GetConVar("ph_taunturl_enable"):GetBool() then
		chat.AddText(Color(200,0,0),"[TauntURL] ",color_white,"TauntURL is disabled in this server.")
		return
	end
	
	if mode then
		PHT.PlaySound(ent, url, "3d mono")
	else
		PHT.PlaySound(ent, url, "3d")
	end
end)

net.Receive("svPHGCleanupMovingStations", function()
	for _,pl in pairs(player.GetAll()) do
		hook.Remove("Think", "MoveStation_"..pl:EntIndex())
		if IsValid(pl.st) then
			pl.st:Stop()
			pl.st = nil
		end
	end
end)