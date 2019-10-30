local ModsOnly = PHE.SVAdmins
--[[ Change this if you want with several custom user groups

	local ModsOnly = {
		"moderator",
		"operator",
		"donator",
		"etc"
	}
]]

CreateConVar("ph_enable_team_limits","1",{FCVAR_ARCHIVE,FCVAR_SERVER_CAN_EXECUTE,FCVAR_NOTIFY},"Enable Team Change Limits?")
CreateConVar("ph_team_limits_num","3",{FCVAR_ARCHIVE,FCVAR_NOTIFY,FCVAR_SERVER_CAN_EXECUTE},"How many times that player can change the teams? (Map Restart is Required!)")

local MAX_TEAMCHANGE_LIMIT = GetConVar("ph_team_limits_num"):GetInt() -- starts from 0.

function PH_LimitChangeteamLimit(ply, oldt, newt)
	if GetConVar("ph_enable_team_limits"):GetBool() && then
		if !table.HasValue(ModsOnly, ply:GetUserGroup()) then
			if newt != TEAM_SPECTATOR then
				ply.ChangeLimit = ply.ChangeLimit + 1
				ply:ChatPrint("[Team Changes] You have "..ply.ChangeLimit.."x Team changes remaining. After ".. MAX_TEAMCHANGE_LIMIT+1 .."x, You can no longer switch to opposite team!")
				print("[Team Changes] "..ply:Nick().." has changed "..ply.ChangeLimit.."x.")
			end
			
			if ply.ChangeLimit > MAX_TEAMCHANGE_LIMIT and newt != TEAM_SPECTATOR then
				timer.Simple(0.3, function()
					if oldt != TEAM_SPECTATOR then
						ply:SetTeam(oldt)
						ply:ChatPrint("[Team Changes] You have exceeded the number of team changes. Reverting.")
						print("[Team Changes] Reverting "..ply:Nick().."\'s team to "..team.GetName(oldt))
					end
				end)
			end
		end
	end
end
hook.Add("OnPlayerChangedTeam", "PH_LimitTeamChange", PH_LimitChangeteamLimit)

function PH_InitialPlayerChangeTeamLimit(ply)
	timer.Simple(math.random(3,4), function()
		if GetConVar("ph_enable_team_limits"):GetBool() then
			ply.ChangeLimit = 0
			if IsValid(ply) && !table.HasValue(ModsOnly, ply:GetUserGroup()) then
				ply:ChatPrint("[Team Changes] You have 3 Team-Changes remaining.")
				print("[Team Changes] "..ply:Nick().." team change limit initialised.")
			end
		end
	end)
end
hook.Add("PlayerInitialSpawn", "PH_InitChangeteamLimit", PH_InitialPlayerChangeTeamLimit)