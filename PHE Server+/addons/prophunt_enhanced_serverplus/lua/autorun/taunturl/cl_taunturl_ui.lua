surface.CreateFont("tu_rbtBig", {
	font	= "Roboto",
	size	= 18,
	weight	= 500,
	antialias = true
})

local taunturl = {}
taunturl.time 	= 0
taunturl.taunt 	= ""

function PHT.LoadURLs()
	local files
	
	if file.Exists("url_tauntlist.txt", "DATA") then
		files = util.JSONToTable(file.Read("url_tauntlist.txt","DATA"))
		return files
	end
	
	return false
end

function PHT.SaveURLs(contents)
	if file.Exists("url_tauntlist.txt", "DATA") then
		chat.AddText(color_white,"[TauntURL] Overwritting Taunt List File...")
	else
		chat.AddText(color_white,"[TauntURL] Creating New Taunt List File...")
	end
	
	file.Write("url_tauntlist.txt", contents)
end

function PHT.AddTaunt(ls,window,edit)
	local wn = {}
	wn.main = vgui.Create("DFrame")
	wn.main:SetSize(300,200)
	wn.main:SetTitle("Add/Edit Taunt")
	wn.main:Center()
	wn.main:SetDraggable(false)
	wn.main:SetIcon("icon16/transmit.png")
	
	wn.main.OnClose = function()
		window.Frame:ShowCloseButton(true)
		wn.main:SetDrawOnTop(false)
	end
	
	wn.panel = vgui.Create("DPanel",wn.main)
	wn.panel:Dock(FILL)
	wn.panel:DockPadding(12,12,12,12)
	wn.panel:SetBackgroundColor(Color(20,20,20,200))
	
	wn.textName = vgui.Create("DLabel",wn.panel)
	wn.textName:SetText("Taunt Name")
	wn.textName:SetTextColor(color_white)
	wn.textName:SetPos(10,10)
	wn.textName:SizeToContents()
	
	wn.nameEntry = vgui.Create("DTextEntry",wn.panel)
	if edit then
		wn.nameEntry:SetText(ls:GetLine(ls:GetSelectedLine()):GetValue(1))
	else
		wn.nameEntry:SetText("Taunt Name Here")
	end
	wn.nameEntry:SetPos(10,30)
	wn.nameEntry:SetSize(250,24)
	
	wn.textURL = vgui.Create("DLabel",wn.panel)
	wn.textURL:SetText("Taunt URL")
	wn.textURL:SetTextColor(color_white)
	wn.textURL:SetPos(10,70)
	wn.textURL:SizeToContents()
	
	wn.nameURL = vgui.Create("DTextEntry",wn.panel)
	if edit then
		wn.nameURL:SetText(ls:GetLine(ls:GetSelectedLine()):GetValue(2))
	else
		wn.nameURL:SetText("http://...")
	end
	wn.nameURL:SetPos(10,90)
	wn.nameURL:SetSize(250,24)
	
	wn.btnOK = vgui.Create("DButton",wn.panel)
	if edit then
		wn.btnOK:SetText("Apply")
	else
		wn.btnOK:SetText("Add")
	end
	wn.btnOK:SetSize(86,32)
	wn.btnOK:SetPos((wn.main:GetWide()/2)-50,120)
	wn.btnOK.DoClick = function()
		if edit then
			ls:RemoveLine(ls:GetSelectedLine())
			ls:AddLine(wn.nameEntry:GetValue(),wn.nameURL:GetValue())
		else
			ls:AddLine(wn.nameEntry:GetValue(),wn.nameURL:GetValue())
		end
		window.Frame:ShowCloseButton(true)
		PHT.Notify("You have unsaved taunts list!", NOTIFY_UNDO)
		
		wn.main:Close()
	end
	
	wn.main:SetDrawOnTop(true)
	wn.main:MakePopup()
	wn.main:DoModal()
	
end

function PHT.Notify(strText,nottype)
	notification.AddLegacy(strText,nottype,4)
end

function PHT.PlayTaunt(ls,bool)
	if taunturl.time <= CurTime() then
		
		repeat
			local t = ls:GetLine(ls:GetSelectedLine()):GetValue(2)
			if bool then
				print("Selecting: "..t.." to play in Mono.")
			else
				print("Selecting: "..t)
			end
			
			net.Start("clPHT.TauntInfo")
				net.WriteString(t)
				net.WriteBool(bool)
			net.SendToServer()
		until t != taunturl.taunt
		
		taunturl.time = CurTime() + GetConVar("ph_taunturl_delay"):GetInt()
		taunturl.taunt = t
	
	end
end

function PHT.CreateOpButton(name,panel,f,ico)
	local btn = vgui.Create("DButton", panel)
	btn:SetText(name)
	btn:SetFont("tu_rbtBig")
	btn:SetSize(panel:GetColWide(),panel:GetRowHeight()-8)
	btn.DoClick = f
	btn:SetIcon(ico)
	
	panel:AddItem(btn)
end

function PHT.CreateOpLabel(name,panel)
	local lbl = vgui.Create("DLabel",panel)
	lbl:SetText(name)
	lbl:SetFont("HudHintTextLarge")
	lbl:SetSize(panel:GetColWide(),panel:GetRowHeight())
	
	panel:AddItem(lbl)
end

function PHT.ShowWindow()

	if PHT.UISTATE > 0 then return end

	local files = PHT.LoadURLs()
	if !files then
		files = {};
		for name,url in pairs(PHT.SERVER_DEFAULT_TAUNTURL) do
			files[name]	= url;
		end
	end
	
	local main = {}
	local isPressed = false
	local isSaved	= true
	
	main.Frame = vgui.Create("DFrame")
	if (ScrW() < 800 && ScrH() < 500) then
		main.Frame:SetSize(800,600)
	else
		main.Frame:SetSize(math.Round(ScrW()/2),ScrH()-100)
	end
	main.Frame:Center()
	main.Frame:SetTitle("[Prop Hunt: Enhanced] - Play Taunt URL")
	main.Frame:SetVisible(true)
	main.Frame:ShowCloseButton(true)
	-- Keyboard Interaction and stuff
	main.Frame:SetMouseInputEnabled(true)
	main.Frame:SetKeyboardInputEnabled(true)
	
	main.Frame.OnClose = function()
		PHT.UISTATE = 0
	end
	
	-- Base Panels
	main.ORIGINPANEL = vgui.Create("DPanel",main.Frame)
	main.ORIGINPANEL:Dock(FILL)
	main.ORIGINPANEL:SetBackgroundColor(Color(20,20,20,100))
	
	main.TauntPnl = vgui.Create("DPanel",main.ORIGINPANEL)
	main.TauntPnl:Dock(LEFT)
	main.TauntPnl:SetSize(main.Frame:GetWide()-200,0)
	main.TauntPnl:SetBackgroundColor(Color(20,20,20,160))
	
	main.Operations = vgui.Create("DPanel",main.ORIGINPANEL)
	main.Operations:Dock(FILL)
	main.Operations:SetBackgroundColor(Color(20,20,20,100))
	
	-- DListView->.TauntPnl
	main.List = vgui.Create("DListView",main.TauntPnl)
	main.List:Dock(FILL)
	main.List:SetMultiSelect(false)
	main.List:AddColumn("Name")
	main.List:AddColumn("URL")
	
	for name,url in pairs(files) do main.List:AddLine(name,url) end;
	
	main.List.OnRowSelected = function()
		isPressed = true
	end
	
	-- Operations Panels
	main.grid = vgui.Create("DGrid", main.Operations)
	main.grid:Dock(FILL)
	main.grid:DockMargin(8,8,8,8)
	main.grid:SetCols(1)
	main.grid:SetColWide(170)
	main.grid:SetRowHeight(48)
	
	PHT.CreateOpLabel("Main Taunts",main.grid)
	PHT.CreateOpButton("Play Taunt", main.grid, function()
		if !isPressed then return end
		
		if LocalPlayer():Alive() && (LocalPlayer():Team() == TEAM_PROPS || LocalPlayer():Team() == TEAM_HUNTERS) then
			PHT.PlayTaunt(main.List,false)
		else
			chat.AddText(Color(200,0,0),"[TauntURL] ",Color(200,200,200),"Cannot do that at this moment.")
		end
	
	end,"icon16/control_play_blue.png")
	PHT.CreateOpButton("Play in Mono", main.grid, function()
		if !isPressed then return end
	
		if LocalPlayer():Alive() && (LocalPlayer():Team() == TEAM_PROPS || LocalPlayer():Team() == TEAM_HUNTERS) then
			PHT.PlayTaunt(main.List,true)
		else
			chat.AddText(Color(200,0,0),"[TauntURL] ",Color(200,200,200),"Cannot do that at this moment.")
		end
	end,"icon16/control_play.png")
	PHT.CreateOpLabel("Editor",main.grid)
	PHT.CreateOpButton("Add Taunt", main.grid, function() 
		main.Frame:ShowCloseButton(false)
		PHT.AddTaunt(main.List,main,false)
	end,"icon16/add.png")
	
	PHT.CreateOpButton("Edit Taunt", main.grid, function()
		if !isPressed then return end

		main.Frame:ShowCloseButton(false)
		PHT.AddTaunt(main.List,main,true)
	end,"icon16/layout_edit.png")
	
	PHT.CreateOpButton("Remove Taunt", main.grid, function()
		if !isPressed then return end
		
		main.List:RemoveLine(main.List:GetSelectedLine())
		isPressed = false
		PHT.Notify("Be Sure to save your list!", NOTIFY_GENERIC)
		PHT.Notify("A list has been removed.", NOTIFY_ERROR)
	end,"icon16/cross.png")
	PHT.CreateOpButton("Save Taunts List", main.grid, function(self)
		self:SetDisabled(true)
		local lst = {}
		for _,val in pairs(main.List:GetLines()) do 
			lst[val:GetValue(1)] = val:GetValue(2)
		end
		
		PHT.SaveURLs(util.TableToJSON(lst,true))
		
		timer.Simple(0.5, function()
			self:SetDisabled(false)
			chat.AddText(Color(0,200,0),"[TauntURL] ",Color(200,200,200),"Taunt URLs has been successfully saved!")
			PHT.Notify("Taunts list has been saved.", NOTIFY_GENERIC)
		end)
	end,"icon16/disk.png")
	PHT.CreateOpLabel("Misc. Stuff",main.grid)
	PHT.CreateOpButton("Reset Default", main.grid, function(self)
		self:SetDisabled(true)
		main.Frame:ShowCloseButton(false)
		Derma_Query("Are you sure you want to reset to default?\n\nThis will clear all the existing including your saved taunts!","Reset Default",
		"Yes", function() 
			chat.AddText(Color(0,150,220),"[TauntURL] ",color_white,"Requesting Taunt List from Server...")
			main.List:Clear()
			for name,url in pairs(PHT.SERVER_DEFAULT_TAUNTURL) do
				main.List:AddLine(name,url)
			end
			chat.AddText(Color(0,150,220),"[TauntURL] ",color_white,"Saving to file...")
			
			timer.Simple(1, function()
				local lst = {}
				for _,val in pairs(main.List:GetLines()) do lst[val:GetValue(1)] = val:GetValue(2) end
				PHT.SaveURLs(util.TableToJSON(lst,true))
				chat.AddText(Color(0,150,220),"[TauntURL] ",color_white,"Taunt list has successfully reset.")
				PHT.Notify("Successfully Reset.", NOTIFY_GENERIC)
				main.Frame:ShowCloseButton(true)
				self:SetDisabled(false)
			end)
		end,
		"No", function()
			main.Frame:ShowCloseButton(true)
			self:SetDisabled(false)
		end)
	end,"icon16/arrow_refresh.png")
	
	main.Frame:MakePopup()
	main.Frame:SetKeyboardInputEnabled(false)
end
net.Receive("svPHT.ShowUI", function() PHT.ShowWindow(); timer.Simple(0.15, function() PHT.UISTATE = 1 end); end)