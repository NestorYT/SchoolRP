
IsDoingQuest = false
LastMeta = nil
LastQuestType = nil

local LastQID = -1
local dQuest = nil
local dQuestInfo = nil

local quests_username = surface.CreateFont("quests_username", {
	font = "Arial",
	size = 36
})

local quests_text = surface.CreateFont("quests_text", {
	font = "Arial",
	size = 24
})

local quests_button = surface.CreateFont("quests_button", {
	font = "Arial",
	size = 20
})

function RemoveQuestInfo()
	if dQuestInfo and IsValid(dQuestInfo) then
		dQuestInfo:Remove()
	end
	dQuestInfo = nil
end

local function DrawQuestInfo(questType, l4, meta)
	RemoveQuestInfo()

	IsDoingQuest = true

	local W,H = ScrW(), ScrH()
	local w,h = 200, 350
	local x,y = W - w - 30, H / 2 - h / 2
	local pd = 5 -- padding

	dQuestInfo = vgui.Create("DPanel")
	dQuestInfo:SetSize(w,h)
	dQuestInfo:SetPos(x,y)
	dQuestInfo.Paint = function(s,w,h)
		draw.RoundedBox(
			5,
			0,0,
			w,h,
			Color(33,33,33,200)
		)
		draw.RoundedBox(
			5,
			pd,pd,
			w-pd*2,h-pd*2,
			Color(44, 62, 80, 150)
		)
		draw.RoundedBox(
			5,
			pd, 150 + pd,
			w-pd*2,150,
			Color(44, 62, 80, 150)
		)
	end

	local richtext = vgui.Create("RichText", dQuestInfo)
	richtext:SetPos(pd, pd)
	richtext:SetSize(w - pd*2, 150)
	richtext.Paint = function(s,w,h)
		draw.RoundedBox(
			0,
			0,0,
			w,h,
			Color(33,33,33, 150)
		)
	end

	function richtext:PerformLayout()
		self:SetFontInternal( "quests_text" )
	end

	richtext:InsertColorChange(255,255,255,255)

	local questChoice = QUEST_CHOICES_DIALOGUE[questType][l4]

	for k,v in pairs(QUEST_TYPES[questType].Lines(questChoice, meta)) do
		if type(v) == "string" then
			richtext:AppendText(v .. " ")
		else
			richtext:InsertColorChange(v.r,v.g,v.b,255)
		end
	end

	richtext:AppendText(QUEST_TYPES[questType].Description)

	richtext:GotoTextStart()

	local icon = vgui.Create("DModelPanel", dQuestInfo)
	icon:SetPos(pd, 150 + pd)
	icon:SetSize(w-pd*2,150)
	icon:SetModel(QUEST_ITEMS[meta.ItemID].Model)
	icon:SetLookAt(Vector(0,0,0))

	local dButton1 = vgui.Create("DButton", dQuestInfo)
	dButton1:SetPos(pd, 300+pd)
	dButton1:SetSize(w-pd*2, 50-pd*2)
	dButton1:SetText("Abort")
	dButton1:SetFont("quests_button")
	dButton1.DoClick = function()
		net.Start("quest_abort")
			net.WriteBool(true)
		net.SendToServer()
		dQuestInfo:Remove()
	end
	dButton1.Paint = function(s,w,h)
		draw.RoundedBox(
			4,
			0,0,
			w,h,
			Color(192, 57, 43, 200)
		)
	end
	dButton1:SetTextColor(Color(255,255,255))
end

local function DrawQuest(ent, questType, l1, l2, l3, l4, l5, meta)
	if dQuest and IsValid(dQuest) then
		dQuest:Remove()
	end

	local W,H = ScrW(), ScrH()
	local w,h = W * 0.70, 150
	local x,y = W * 0.30 / 2, H - h - 30
	local pd = 5 -- padding

	dQuest = vgui.Create("DPanel")
	dQuest:SetSize(w,h)
	dQuest:SetPos(x,y)
	dQuest:MakePopup()

	dQuest.Paint = function(s,w,h)
		draw.RoundedBox(
			5,
			0,0,
			w,h,
			Color(33,33,33,200)
		)
		draw.RoundedBox(
			5,
			pd,pd,
			w-pd*2,h-pd*2,
			Color(44, 62, 80, 150)
		)
		draw.RoundedBox(
			5,
			pd,pd,
			175 - pd*2, h - pd*2,
			Color(33, 33, 33, 150)
		)

		draw.SimpleText(
			ent:GetNWString("Name"),
			"quests_username",
			175 + pd, pd * 2
		)
	end

	local icon = vgui.Create("DModelPanel", dQuest)
	icon:SetPos(pd, pd)
	icon:SetSize(175 - pd*2, h - pd*2)
	icon:SetModel(ent:GetModel())
	function icon:LayoutEntity( mod ) return
	end
	local eyepos = icon.Entity:GetBonePosition( icon.Entity:LookupBone( "ValveBiped.Bip01_Head1" ) )
	eyepos:Add( Vector( 0, 0, -5 ) )	-- Move up slightly
	icon:SetLookAt( eyepos )
	icon:SetCamPos( eyepos-Vector( -30, 0, 0 ) )	-- Move cam in front of eyes
	icon.Entity:SetEyeTarget( eyepos-Vector( -12, 0, 0 ) )

	local richtext = vgui.Create("RichText", dQuest)
	richtext:SetPos(175 + pd, pd * 2 + 40)
	richtext:SetSize(w - 175 - pd * 2 - 150, h - pd * 3 - 40)
	richtext.Paint = function(s,w,h)
		draw.RoundedBox(
			0,
			0,0,
			w,h,
			Color(33,33,33, 150)
		)
	end

	function richtext:PerformLayout()
		self:SetFontInternal( "quests_text" )
	end

	richtext:InsertColorChange(255,255,255,255)

	richtext:AppendText(QUEST_GREETINGS1[l1] .. " ")
	richtext:AppendText(QUEST_GREETINGS2[l2] .. " ")
	richtext:AppendText(QUEST_GREETINGS3[l3] .. " ")

	local questChoice = QUEST_CHOICES_DIALOGUE[questType][l4]

	for k,v in pairs(QUEST_TYPES[questType].Lines(questChoice, meta)) do
		if type(v) == "string" then
			richtext:AppendText(v .. " ")
		else
			richtext:InsertColorChange(v.r,v.g,v.b,255)
		end
	end

	richtext:AppendText(QUEST_GREETINGS4[l5] .. " ")

	richtext:GotoTextStart()

	local dButton1 = vgui.Create("DButton", dQuest)
	dButton1:SetPos(w - 140 - pd, h - 100)
	dButton1:SetSize(130, 45)
	dButton1:SetText("Cancel")
	dButton1:SetFont("quests_button")
	dButton1.DoClick = function()
		dQuest:Remove()
	end
	dButton1.Paint = function(s,w,h)
		draw.RoundedBox(
			4,
			0,0,
			w,h,
			Color(192, 57, 43, 200)
		)
	end
	dButton1:SetTextColor(Color(255,255,255))

	local dButton2 = vgui.Create("DButton", dQuest)
	dButton2:SetPos(w - 140 - pd, h - 50)
	dButton2:SetSize(130, 45)
	dButton2:SetFont("quests_button")
	dButton2:SetText("Accept")
	dButton2.DoClick = function()
		net.Start("quest_accept")
			net.WriteUInt(LastQID, 32)
		net.SendToServer()
		IsDoingQuest = true
		DrawQuestInfo(questType, l4, meta)
		dQuest:Remove()
	end
	dButton2.Paint = function(s,w,h)
		draw.RoundedBox(
			4,
			0,0,
			w,h,
			Color(39, 174, 96, 200)
		)
	end
	dButton2:SetTextColor(Color(255,255,255))
end

local function QuestRequest(qid, ent, questType, l1, l2, l3, l4, l5, meta)
	LastQID = qid
	LastQuestType = questType
	LastMeta = meta

	PrintTable(meta)
	DrawQuest(ent, questType, l1, l2, l3, l4, l5, meta)
end

net.Receive("quest_request", function(len)
	print("Got quest request!")
	local qid = net.ReadUInt(32)
	local qent = net.ReadEntity()
	local questType = net.ReadUInt(16)
	local questLine1 = net.ReadUInt(16)
	local questLine2 = net.ReadUInt(16)
	local questLine3 = net.ReadUInt(16)
	local questLine4 = net.ReadUInt(16)
	local questLine5 = net.ReadUInt(16)
	local meta = net.ReadTable()

	QuestRequest(qid,
		qent,
		questType,
		questLine1,
		questLine2,
		questLine3,
		questLine4,
		questLine5,
		meta)
end)

