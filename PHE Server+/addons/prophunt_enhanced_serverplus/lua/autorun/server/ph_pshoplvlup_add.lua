--Pointshop Hooks
local pts = {}

-- init value
pts.RandomPoints 		= 1
pts.RandomPoints_ER		= 1
pts.RandomPoints_ER_DEAD = 1
pts.RandomPoints_RW		= 1
pts.RandomPoints_RWH	= 1

	--// hook: OnPropKilled //--
	-- give a delay to make sure the player is dead or not.
	local function PropKilled(victim, attacker)		
		timer.Simple(0.2, function()
			if attacker:IsPlayer() && attacker:Alive() then
				
				pts.RandomPoints = math.Round(math.random(15,30))
				attacker:SendLua([[notification.AddLegacy("[Pointshop] You got ]]..pts.RandomPoints..[[ Bonus points for killing a prop!", NOTIFY_GENERIC, 5)]])
				attacker:SendLua([[surface.PlaySound("garrysmod/ui_return.wav")]])
				attacker:PS_GivePoints(pts.RandomPoints)
				
			elseif attacker:IsPlayer() && !attacker:Alive() then
				pts.RandomPoints = math.Round(math.random(1,15))
				attacker:SendLua([[notification.AddLegacy("[Pointshop] You got ]]..pts.RandomPoints..[[ Bonus dead points for killing a prop but you didn't survived!", NOTIFY_GENERIC, 5)]])
				attacker:SendLua([[surface.PlaySound("garrysmod/ui_return.wav")]])
				attacker:PS_GivePoints(pts.RandomPoints)
			end
		end)
	end
	hook.Add("PH_OnPropKilled", "PH.PropKilled_PshopBonus", PropKilled)
	
	--// hook: Lucky Ball Events Adder. Add new List with list.Set() //--
	
	list.Set("LuckyBallsAddition", "RandomPoint.Adder1", function(pl)
		local lb_pts
		if !PS.Config then return end
		
		lb_pts = math.Round(math.random(1,4))
		pl:PS_GivePoints(lb_pts)
		pl:SendLua([[notification.AddLegacy("[Pointshop] You got ]]..lb_pts..[[ Points from Lucky Ball!", NOTIFY_GENERIC, 5)]])
	end)
	
	-- Todo: DevilBallsAddition is pretty similar to have a function like in LuckyBallsAddition ones. 
	-- Just copy one of LuckyBallsAddition's and change them with DevilBallsAddition to add several features for Props.
	--[[  I guess I'll put this as placeholder v
	
	list.Set("DevilBallsAddition", "RandomPoint.Adder1", function(pl)
		local something = 0
		do something here pls
	end)]]
	
	list.Set("LuckyBallsAddition", "RandomPoint.Adder2", function(pl)
		local lb_pts
		if !PS.Config then return end
		
		lb_pts = math.Round(math.random(5,15))		
		pl:PS_GivePoints(lb_pts)
		pl:SendLua([[notification.AddLegacy("[Pointshop] You got ]]..lb_pts..[[ Points from Lucky Ball!", NOTIFY_GENERIC, 5)]])
	end)
	
	list.Set("LuckyBallsAddition", "RandomPoint.Adder3", function(pl)
		local lb_pts
		if !PS.Config then return end

		-- make sure this should be unique whenever its get called
		lb_pts = math.Round(math.random(16,46))
		if math.random() < 0.1 then -- 10% chance to get higher points
			pl:PS_GivePoints(lb_pts)
			pl:SendLua([[notification.AddLegacy("[Pointshop] You got ]]..lb_pts..[[ Points+ from Lucky Ball!", NOTIFY_GENERIC, 5)]])
		end
	end)
	
	local weapon = { "weapon_pistol", "weapon_stunstick", "weapon_slam", "weapon_rpg", "weapon_ar2", "weapon_crossbow", "weapon_frag" }
	list.Set("LuckyBallsAddition", "Weapon.DeagleUpgrade", function(pl)
		if IsValid(pl) && pl:Alive() && pl:Team() != TEAM_UNASSIGNED && pl:Team() != TEAM_SPECTATOR then
			local getw = table.Random(weapon)
			pl:Give(getw)
			if getw == "weapon_ar2" then
				pl:Give("item_ammo_ar2_altfire")
			elseif getw == "weapon_rpg" then
				pl:Give("item_rpg_round")
			end
		end
	end)
	
	list.Set("LuckyBallsAddition", "PShop.Grenade", function(pl)
		local pos = pl:GetPos()
		local grn = ents.Create("npc_grenade_frag")
		grn:SetPos(Vector(pos.x,pos.y,pos.z+16))
		grn:SetAngles(Angle(0,0,0))
		grn:Spawn()
		grn:Activate()
		
		grn:Fire("SetTimer","3",0)
		pl:ChatPrint("[Lucky Ball] You got a GRENADE!")
	end)
	
	-- for LevelUp Addons.
	list.Set("LuckyBallsAddition", "LuckyBall.levelup_Perk1", function(pl)
		if !levelup then return end
		
		local exp = math.random(5,500)
		levelup.increaseExperience(pl, exp)
		pl:ChatPrint("[Lucky-LevelUp] You've gained "..exp.." EXP points!")
	end)
	
	--// hook: OnRoundWinTeam //--
	local function RoundWinningTeam(TeamID)
		if TeamID == TEAM_PROPS then
			for _,ply in pairs(player.GetAll()) do
				pts.RandomPoints_RW = math.Round(math.random(4,15))
				if ply:Team() == TEAM_PROPS && ply:Alive() && ply:Frags() > 0 then
					ply:SendLua([[notification.AddLegacy("[Pointshop] Team Props wins!! You got ]]..pts.RandomPoints_RW..[[ Bonus Points for surviving without getting killed!", NOTIFY_GENERIC, 5)]])
					ply:PS_GivePoints(pts.RandomPoints_RW)
				elseif ply:Team() == TEAM_PROPS && !ply:Alive() && ply:Frags() > 0 then
					ply:SendLua([[notification.AddLegacy("[Pointshop] Team Props wins, but you're dead! You got 4 Bonus Points!", NOTIFY_GENERIC, 5)]])
					ply:PS_GivePoints(4)
				end
			end
		elseif TeamID == TEAM_HUNTERS then
			for _,ply in pairs(player.GetAll()) do
				pts.RandomPoints_RWH = math.Round(math.random(8,20))
				if ply:Team() == TEAM_HUNTERS && ply:Alive() && ply:Frags() > 0 then
					ply:SendLua([[notification.AddLegacy("[Pointshop] Team Hunters wins!! You got ]]..pts.RandomPoints_RWH..[[ Bonus Points for surviving and Killing all props!", NOTIFY_GENERIC, 5)]])
					ply:PS_GivePoints(pts.RandomPoints_RWH)
				elseif ply:Team() == TEAM_HUNTERS && !ply:Alive() && ply:Frags() > 0 then
					ply:SendLua([[notification.AddLegacy("[Pointshop] Team Hunters wins, but you're dead! You got 8 Bonus Points!", NOTIFY_GENERIC, 5)]])
					ply:PS_GivePoints(8)
				end
			end
		end
	end
	hook.Add("PH_OnRoundWinTeam", "PH.RoundWinning_PShopPoints", RoundWinningTeam)
	
	--// hook: OnRoundTimerEnd //--
	local function RoundEndPoints()
		for _,ply in pairs(player.GetAll()) do
			if ply:Team() == TEAM_PROPS && ply:Alive() && ply:Frags() >= 0 then
				pts.RandomPoints_ER 		= math.Round(math.random(6,50))				
				ply:SendLua([[notification.AddLegacy("[Pointshop] You Survived! You got ]]..pts.RandomPoints_ER..[[ Bonus Points for surviving without dying!", NOTIFY_GENERIC, 5)]])
				ply:PS_GivePoints(pts.RandomPoints_ER)
			elseif ply:Team() == TEAM_PROPS && !ply:Alive() && ply:Frags() >= 0 then
				pts.RandomPoints_ER_DEAD 	= math.Round(math.random(4,10))
				ply:SendLua([[notification.AddLegacy("[Pointshop] Team Props Win, however you didn't survived! You got ]]..pts.RandomPoints_ER_DEAD..[[ Bonus Points!", NOTIFY_GENERIC, 5)]])
				ply:PS_GivePoints(pts.RandomPoints_ER_DEAD)
			end
		end
	end
	hook.Add("PH_OnTimerEnd", "PH.RoundEnd_PShopPoints", RoundEndPoints)