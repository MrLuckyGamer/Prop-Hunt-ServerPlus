-- Warning: Code is half finished. Use at your own Risk!
-- Todo: 
-- >> Net Security issue.
-- >> snake.URL is not Uploaded yet, so this code appear to be useless until the page is published!
-- >> several coding flaws (Pointshop Checks, etc.)

-- /!\ IMPORTANT NOTES /!\ DO NOT USE THIS CODE IF THE SECURITY ISSUE HAS NOT BEEN FIXED YET! --
-- /!\ IMPORTANT NOTES /!\ DO NOT USE THIS CODE IF THE SECURITY ISSUE HAS NOT BEEN FIXED YET! --
-- /!\ IMPORTANT NOTES /!\ DO NOT USE THIS CODE IF THE SECURITY ISSUE HAS NOT BEEN FIXED YET! --
-- /!\ IMPORTANT NOTES /!\ DO NOT USE THIS CODE IF THE SECURITY ISSUE HAS NOT BEEN FIXED YET! --
-- /!\ IMPORTANT NOTES /!\ DO NOT USE THIS CODE IF THE SECURITY ISSUE HAS NOT BEEN FIXED YET! --









snake = {}

if SERVER then

AddCSLuaFile()

util.AddNetworkString("snake.PostScore")
util.AddNetworkString("snake.AlertScore")

net.Receive("snake.PostScore", function(len,ply)
	if !PS.Config then return end

	local cur = tonumber(net.ReadString())
		
	if (IsValid(ply)) then
		ply.bonuspts = 0
		
		if cur >= 10 then ply.bonuspts = math.Round(cur*0.1) end
		
		ply:PS_GivePoints(ply.bonuspts)
		ply:SendLua("surface.PlaySound(\"ui/buttonrollover.wav\")")
		
		for _,v in pairs(player.GetAll()) do
			if !v:Alive() then
				v:ChatPrint("[AWSnake] "..ply:Nick().." scored "..tostring(cur).." Pts from playing Snake (".. ply.bonuspts .." Point bonus!)")
			end
		end
	end
end)

net.Receive("snake.AlertScore", function(len,ply)
	local h = net.ReadString()
	local cur = net.ReadString()
		
	if (IsValid(ply)) then
		for _,v in pairs(player.GetAll()) do
			if !v:Alive() then
				v:ChatPrint("[AWSnake] "..ply:Nick().." beated their Highscore: "..tostring(cur).." Pts! (Before: "..h.." Pts)")
			end
		end
	end
end)

hook.Add("PlayerDeath", "AlertSnakeGame", function(ply)
	timer.Simple(2, function()
		if IsValid(ply) then
			ply:SendLua([[notification.AddLegacy("Type !snake to play 'Snake' mini games and gain more Pointshop Points!", NOTIFY_GENERIC, 15)]])
			ply:SendLua([[surface.PlaySound('garrysmod/save_load]]..math.random(1,4)..[[.wav')]])
		end
	end)
end)

hook.Add("PlayerSay", "triggerSnakeGame", function(ply, text)
	if string.lower(text) == "!snake" || string.lower(text) == "/snake" then
		ply:ConCommand("wlv_snake")
	end
end)

else

-- Very unsafe net call. Todo: better serverside code to prevent this happening!!
function snake.post(cur, hscore)
	net.Start("snake.PostScore")
		net.WriteString(cur)
	net.SendToServer()
	
	if (cur == nil || !cur) then cur = 0 end
	if (hscore == nil || !hscore) then hscore = 0 end
	
	if tonumber(cur) > tonumber(hscore) then
		Derma_Message("You beat your High Score!\n\nYour current score is now on your Highscore: "..cur.." Points!", "AWSnake")
	else
		Derma_Message("Your current score is: "..cur.." Points.\n\nYour Highscore was: "..hscore.." Points.", "AWSnake")
	end
end

function snake.alert(highScore, curScore)
	net.Start("snake.AlertScore")
		net.WriteString(highScore)
		net.WriteString(curScore)
	net.SendToServer()
end

-- UI
snake.Width		= ScrW()-100
snake.Height 	= ScrH()-30
snake.URL		= "https://example.com" -- NOT YET UPLOADED...!

function snake.BeginPlay()
	if LocalPlayer():Alive() then
		chat.AddText(Color(255,40,40),"[AWSnake] Snake mini game is only available when Spectating!")
		return
	end

	snake.f = vgui.Create("DFrame")
	snake.f:SetSize(snake.Width, snake.Height)
	snake.f:SetPos(0,0)
	snake.f:SetTitle("AWSnake - Garry's Mod Snake Game!")
	snake.f.Paint = function(self,w,h)
		draw.RoundedBox(8,0,0,w,h,Color(20,20,20,180))
	end
	
	snake.html = vgui.Create("DHTML", snake.f)
	snake.html:Dock(FILL)
	snake.html:OpenURL(snake.URL)
	
	snake.f:MakePopup()
	snake.f:Center()
	
	snake.html:SetAllowLua(true)
end
concommand.Add("wlv_snake", snake.BeginPlay, nil, "Begin play Snake mini game")

end