local fishpool = {}
fishpool.__index = fishpool

fishpool.RadiusConVar = CreateConVar("ph_fishpool_detection_radius", 128, {FCVAR_SERVER_CAN_EXECUTE,FCVAR_NOTIFY,FCVAR_ARCHIVE}, "Radius to detect Fish Pool nearby (default is 128) which allows props to become a fish.")
fishpool.EnableDisguiseFish = CreateConVar("ph_fishpool_detection_enable", 0, {FCVAR_SERVER_CAN_EXECUTE,FCVAR_NOTIFY,FCVAR_ARCHIVE}, "Enable Fish Pool detection on every Prop hunt map, if has any.")

-- Alow to set Props to School of Fishes
fishpool.RadiusConVar:GetInt()
fishpool.entToFind = "func_fish_pool"

fishpool.InformPlayertoFishPool = function()
	local lookup = ents.FindByClass( fishpool.entToFind )
	for _,pool in RandomPairs(lookup) do
		local ent = ents.FindInSphere( pool:GetPos(), fishpool.RadiusConVar:GetInt() )
		for _,capEnt in pairs(ent) do
			if (capEnt:IsPlayer() and capEnt:Alive() and (capEnt:Team() == TEAM_PROPS or capEnt:Team() == 2)) then
				capEnt:PrintMessage(HUD_PRINTCENTER, "Press [ CLICK ] to Disguise as Fish Nearby!")
			end
		end
	end
end

hook.Add("PostCleanupMap", "PH.POST.InformPlayerFishPool", function()
	local foundEnt = #ents.FindByClass( fishpool.entToFind )
	if (engine.ActiveGamemode() == "prop_hunt" and foundEnt > 1 and fishpool.EnableDisguiseFish:GetBool()) then
		timer.Simple(1,function()
			timer.Create("tmr_PH.fishpoolFunc", 1.5, 0, fishpool.InformPlayertoFishPool)
		end)
	end
end)

hook.Add("PreCleanupMap", "PH.PRE.FishPool", function()
	if timer.Exists("tmr_PH.fishpoolFunc") then timer.Remove("tmr_PH.fishpoolFunc") end
end)

-- Player Action by pressing Mouse1 Click
hook.Add("KeyPress", "PH.fishpool_BecomeAFish", function(ply,key)
	if ( engine.ActiveGamemode() == "prop_hunt" and fishpool.EnableDisguiseFish:GetBool() ) and #ents.FindByClass( fishpool.entToFind ) > 1 and
		( IsValid(ply) and (ply:Team() == TEAM_PROPS or ply:Team() == 2) and ply:Alive() and key == IN_ATTACK ) then
		local Pos = ply:GetPos()
		local ent = ents.FindInSphere(Pos, fishpool.RadiusConVar:GetInt() + 32) -- add lenght by 32 hammer units
		for _,ent in RandomPairs(ent) do
			if ( IsValid(ent) and ent:GetClass() == fishpool.entToFind ) then
				if !ply:IsOnGround() then
					ply:ChatPrint("[UnderWataaa] You need to stand in underwater ground!")
				else
				-- A copy reference from Prop Chooser
					local en = ents.Create("prop_physics")
					en:SetPos(Vector(Pos.x,Pos.y,Pos.z-512))
					en:SetAngles(Angle(0,0,0))
					en:SetKeyValue("spawnflags","654")
					en:SetNoDraw(true)
					en:SetModel(ent:GetModel())
					en:Spawn()
					GAMEMODE:PlayerExchangeProp(ply,en)
					en:Remove()
				end
				break
			end
		end	
	end
end)