sgs.CreateProf{
name="Warrior",
profbonus=function(player,prevprof)
	sgs.AcquireSkill(player,"longdan")
end,
translation={
	["Warrior"]="战士",
},
}

sgs.CreateProf{
name="Fighter",
levelup={
	events={sgs.CardUsed,sgs.CardResponded},
	on_trigger=function(self,event,player,data)
		local room=player:getRoom()
		if event==sgs.CardUsed then
			local use=data:toCardUse()
			if use.card:isKindOf("Slash") then sgs.LevelUp(player,"Fighter") end
		end
		if event==sgs.CardResponded then
			local res=data:toResponsed()
			if res.m_card:isKindOf("Slash") then sgs.LevelUp(player,"Fighter") end
		end
	end,
},
prev={["Warrior"]=5},
levelbonus=function(player,lv)
	if lv==3 then sgs.AcquireSkill(player,"wusheng") end
	if lv==6 then sgs.AcquireSkill(player,"wushen") end
end,
profbonus=function(player,prevprof)
	player:getRoom():loseMaxHp(player)
	sgs.AcquireSkill(player,"jiang")
end,
translation={
	["Fighter"]="斗士",
},
}

sgs.CreateProf{
name="Berserker",
levelup={
	events={sgs.SlashHit},
	on_trigger=function(self,event,player,data)
		if event==sgs.SlashHit then
			sgs.LevelUp(player,"Berserker")
		end
	end
},
prev={["Fighter"]=4},
levelbonus=function(player,lv)
	if lv==3 then sgs.AcquireSkill(player,"wushuang") end
	if lv==5 then sgs.AcquireSkill(player,"chongzhen") end	
end,
profbonus=function(player,prevprof)
	player:getRoom():loseMaxHp(player)
	sgs.AcquireSkill(player,"paoxiao")
end,
translation={
	["Berserker"]="B叔",
},
}

sgs.CreateProf{
name="Rider",
levelup={
	events={sgs.CardsMoveOneTime},
	on_trigger=function(self,event,player,data)
		local mv=data:toMoveOneTime()
		if mv.to and mv.to:objectName()==player:objectName() and mv.to_place==sgs.Player_PlaceEquip then
			local b=false
			for _,id in sgs.qlist(mv.card_ids) do
				if sgs.Sanguosha:getCard(id):isKindOf("DefensiveHorse") or sgs.Sanguosha:getCard(id):isKindOf("OffensiveHorse") then b=true break end
			end
			if b then sgs.LevelUp(player,"Rider") end
		end
	end,
},
prev={["Warrior"]=2},
speed=150,
levelbonus=function(player,lv)
	if lv==1 then sgs.AcquireSkill(player,"mashu") end
end,
profbonus=function(player,prevprof)
	player:getRoom():loseMaxHp(player)
	sgs.AcquireSkill(player,"tieji")
end,
translation={
	["Rider"]="骑手",
},
}

sgs.CreateProf{
name="Knight",
levelup={
	events={sgs.SlashHit},
	on_trigger=function(self,event,player,data)
		local room=player:getRoom()
		if event==sgs.SlashHit then
			if player:getEquip(2) or player:getEquip(3) then sgs.LevelUp(player,"Knight") end
		end
	end,
},
prev={["Rider"]=6},
speed=150,
levelbonus=function(player,lv)
	if lv==3 then sgs.AcquireSkill(player,"mengjin") end
end,
profbonus=function(player,prevprof)
	player:getRoom():loseMaxHp(player)
	sgs.AcquireSkill(player,"feiying")
end,
translation={
	["Knight"]="骑士",
},
}


sgs.CreateBoss{
name="BOSS",
hp=8,
speed=80,
stagenum=1,
stagechange={
	events={sgs.HpChanged},
	on_trigger=function(self,event,player,data)
		if event==sgs.HpChanged then
			if sgs.GetStage(player)==0 and player:getHp()*2<=player:getMaxHp() then
				sgs.NextStage(player)
			end
		end
	end,
},
stageeffect=function(player,currentstage)
	if currentstage==1 then player:speak("stage1") sgs.Summon(player,"summoned",false) end
end,
translation={
	["BOSS"]="魔王",
},
}

sgs.CreateSummoned{
name="summoned",
hp=3,
weakness={
	events={sgs.CardsMoveOneTime,sgs.TurnStart},
	on_trigger=function(self,event,player,data)
		if event==sgs.CardsMoveOneTime then
			local mv=data:toMoveOneTime()
			if mv.from and mv.from:objectName()==player:objectName() and mv.from_places:contains(sgs.Player_PlaceHand) and player:isKongcheng() then
				sgs.AntiSummon(player,"kongcheng")
			end
		end
		if event==sgs.TurnStart then
			if sgs.GetSummonTurn(player)>=4 then sgs.AntiSummon(player,"turn") end
		end
	end,
},
antisummoneffect=function(player,summoner,weakness)
	if not weakness then
		player:speak("no weakness")
	elseif weakness=="kongcheng" then
		player:speak(weakness)
		player:getRoom():loseHp(summoner)
	elseif weakness=="turn" then
		player:speak(weakness)
	end
end,
summoneffect=function(player,summoner)
	player:speak("summoned")
	summoner:speak("summoner")
	player:drawCards(3)
end,
translation={
	["summoned"]="召唤",
},
}
