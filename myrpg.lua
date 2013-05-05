module("extensions.myrpg",package.seeall)
extension=sgs.Package("myrpg")
sgs.ProfList={}
sgs.BossList={}
sgs.SummonedList={}
sgs.RPGConst={}
sgs.RPGConst.profcnt="luamyrpg_profcnt"
sgs.RPGConst.prof="luamyrpg_prof"
sgs.RPGConst.level="luamyrpg_level"
sgs.RPGConst.skill="luamyrpg_skill"
sgs.RPGConst.stage="luamyrpg_stage"
sgs.RPGConst.maxstage="luamyrpg_maxstage"
sgs.RPGConst.summoner="luamyrpg_summoner"
sgs.RPGConst.summonturn="luamyrpg_summonturn"
sgs.RPGConst.speed="luamyrpg_speed"
sgs.RPGConst.defaultspeed=100
sgs.RPGConst.actionslot="luamyrpg_actionslot"
sgs.RPGConst.defaultactionslot=100
sgs.RPGConst.cancel="cancel"
sgs.RPGConst.choosechoice="Please choose a choice"
sgs.RPGConst.chooseprof="Please choose a profession"
sgs.RPGConst.chooseskill="Please choose a skill"
sgs.RPGConst.eachdraw="each draws a card"
sgs.RPGConst.drawandplay="draw a card and play"
sgs.RPGConst.role={["lord"]=0,["loyalist"]=0,["rebel"]=1,["renegade"]=1}
sgs.RPGConst.player=0
sgs.RPGConst.boss=1
sgs.RPGConst.summoned=2
luarpgplayer=sgs.General(extension,"luarpgplayer","god",4,true)
luarpgdead=sgs.General(extension,"luarpgdead","god",4,true,true)
--luarpgrule=sgs.General(extension,"luarpgrule","god",4,true,true)


function sgs.Index2Prof(getindex)
	if getindex==0 then return "" end
	return sgs.ProfList[getindex].name
end
function sgs.Prof2Index(getname)
	for var=1,#sgs.ProfList,1 do
		if sgs.ProfList[var].name==getname then return var end
	end
	return 0
end
function sgs.GetNextProfList(para)
	if type(para)=="number" then return sgs.GetNextProfList(sgs.Index2Prof(para)) end
	local getprof=para
	local list={}
	for var=1,#sgs.ProfList,1 do
		for key,value in pairs(sgs.ProfList[var].prev) do
			if key==getprof then list[var]=value break end
		end
	end
	return list
end
function sgs.GetProf(player)
	return sgs.Index2Prof(player:getMark(sgs.RPGConst.prof))
end
function GetLevelConst(getprof)
	return sgs.RPGConst.level.."_"..getprof
end
function sgs.GetLevel(player,getprof)
	return player:getMark(GetLevelConst(getprof))
end
function sgs.SetLevel(player,getprof,getnum)
	player:getRoom():setPlayerMark(player,GetLevelConst(getprof),getnum)
end
function GetSkillConst(player)
	return sgs.RPGConst.skill.."_"..player:objectName()
end
function sgs.GetStage(player)
	return player:getMark(sgs.RPGConst.stage)
end
function sgs.SetStage(player,getnum)
	player:getRoom():setPlayerMark(player,sgs.RPGConst.stage,getnum)
end
function sgs.GetSummoner(player)
	local room=player:getRoom()
	local data=room:getTag(sgs.RPGConst.summoner.."_"..player:objectName())
	if not data then return nil end
	local str=data:toString()
	if str=="" then return nil end
	for _,p in sgs.qlist(room:getAllPlayers(true)) do
		if p:objectName()==str then return p end
	end
	sgs.Alert("getsummoner?")
	return nil
end
function sgs.SetSummoner(player,summoner)
	player:getRoom():setTag(sgs.RPGConst.summoner.."_"..player:objectName(),sgs.QVariant(summoner:objectName()))
end
function sgs.GetType(gname)
	if gname=="luarpgplayer" then return sgs.RPGConst.player end
	if sgs.BossList[gname] then return sgs.RPGConst.boss end
	if sgs.SummonedList[gname] then return sgs.RPGConst.summoned end
	sgs.Alert(gname.."!!")
end
function sgs.InitialSpeed(player)
	local room=player:getRoom()
	local v=sgs.RPGConst.defaultspeed
	local gname=player:getGeneralName()
	local ptype=sgs.GetType(gname)
	if ptype==sgs.RPGConst.player then
		local prof=sgs.GetProf(player)
		if prof~="" then v=sgs.ProfList[sgs.Prof2Index(prof)].speed end
	end
	if ptype==sgs.RPGConst.boss then v=sgs.BossList[gname].speed end
	if ptype==sgs.RPGConst.summoned then v=sgs.SummonedList[gname].speed end
	room:setPlayerMark(player,sgs.RPGConst.speed,v)
	return v
end
function sgs.GetSpeed(player)
	local v=player:getMark(sgs.RPGConst.speed)
	if v==0 then v=sgs.InitialSpeed(player) end
	return v
end
function sgs.SetSpeed(player,v)
	if not v then sgs.InitialSpeed(player) end
	local room=player:getRoom()
	room:setPlayerMark(player,sgs.RPGConst.speed,v)
end
function sgs.GetActionSlot(player)
	return player:getMark(sgs.RPGConst.actionslot)
end
function sgs.SetActionSlot(player,v)
	v=v or sgs.RPGConst.defaultactionslot
	v=math.ceil(v)
	if v<0 then v=0 end
	player:getRoom():setPlayerMark(player,sgs.RPGConst.actionslot,v)
end
function sgs.Role(player,target,opposite)
	opposite=opposite or false
	return (sgs.RPGConst.role[player:getRole()]~=sgs.RPGConst.role[target:getRole()])==opposite
end

function sgs.NextProf(player,force)
	local room=player:getRoom()
	local prof0=sgs.GetProf(player)
	local list={}
	for key,value in pairs(sgs.GetNextProfList(prof0)) do
		if sgs.GetLevel(player,sgs.Index2Prof(key))>=value then table.insert(list,sgs.ProfList[key].name) end
	end
	if #list==0 then return nil end
	if not force then table.insert(list,"cancel") end
	local ch=room:askForChoice(player,sgs.RPGConst.chooseprof,table.concat(list,"+"))
	if ch=="cancel" then return nil end
	return ch
end

function sgs.ProfSkill(player)
	local room=player:getRoom()
	local cnt=player:getMark(sgs.RPGConst.profcnt)
	local list={}
	local skstr=room:getTag(GetSkillConst(player)):toString()
	if skstr~="" then list=skstr:split("+") end
	if #list<cnt then 
		sgs.Alert("skill count.") 
		return nil 
	elseif #list==cnt then
		for var=1,#list,1 do
			if not player:hasSkill(list[var]) then room:acquireSkill(player,list[var]) end
		end
		return nil
	end
	local list2={}
	for var=1,cnt,1 do
		local ch=room:askForChoice(player,sgs.RPGConst.chooseskill,table.concat(list,"+"))
		table.insert(list2,ch)
		table.removeOne(list,ch)
	end
	for var=1,#list,1 do
		if player:hasSkill(list[var]) then room:detachSkillFromPlayer(player,list[var]) end
	end
	for var=1,#list2,1 do
		if not player:hasSkill(list2[var]) then room:acquireSkill(player,list2[var]) end
	end
end

function sgs.LevelBonus(player,getprof)
	if not getprof then return nil end
	local index=sgs.Prof2Index(getprof)
	if sgs.ProfList[index].levelbonus then
		sgs.ProfList[index].levelbonus(player,sgs.GetLevel(player,getprof))
		--ProfSkill(player)
	end
end

function sgs.ProfUp(player,getprof)
	if not getprof then return nil end
	--ProfClear(player)
	local room=player:getRoom()
	local index0=player:getMark(sgs.RPGConst.prof)	
	if index0~=0 then
		for key,_ in pairs(sgs.GetNextProfList(index0)) do
			if sgs.ProfList[key].levelup then
				local skname=sgs.ProfList[key].levelup:objectName()
				if player:hasSkill(skname) then room:detachSkillFromPlayer(player,skname) end
			end
			sgs.SetLevel(player,sgs.Index2Prof(key),0)
		end
	end
		
	local index=sgs.Prof2Index(getprof)
	room:setPlayerMark(player,sgs.RPGConst.profcnt,player:getMark(sgs.RPGConst.profcnt)+1)
	room:setPlayerMark(player,sgs.RPGConst.prof,index)
	room:changePlayerGeneral2(player,getprof)
	--room:setPlayerProperty(player,"screenname",sgs.QVariant(getprof))
	--player:speak(getprof)
	for key,_ in pairs(sgs.GetNextProfList(getprof)) do
		if sgs.ProfList[key].levelup then
			local skname=sgs.ProfList[key].levelup:objectName()
			if not player:hasSkill(skname) then room:acquireSkill(player,skname) end
		end
	end
	sgs.InitialSpeed(player)
	if sgs.ProfList[index].profbonus then
		sgs.ProfList[index].profbonus(player,sgs.Index2Prof(index0))
	end
	sgs.ProfSkill(player)
end

function sgs.ComboPlayer(player,current)
	local room=player:getRoom()
	local ch=room:askForChoice(player,sgs.RPGConst.choosechoice,sgs.RPGConst.eachdraw.."+"..sgs.RPGConst.drawandplay)
	if ch==sgs.RPGConst.eachdraw then
		player:drawCards(1)
		current:drawCards(1)
	elseif ch==sgs.RPGConst.drawandplay then
		player:drawCards(1)
		local phlist=sgs.PhaseList()
		phlist:append(sgs.Player_Play)
		player:play(phlist)
	end
end

function sgs.NextPlayer(player)
	local room=player:getRoom()
	local mintime=10000
	local minplist={}
	for _,p in sgs.qlist(room:getAllPlayers()) do
		local ptime=sgs.GetActionSlot(p)/sgs.GetSpeed(p)
		if ptime<mintime then
			mintime=ptime
			minplist={p}
		elseif ptime==mintime then
			table.insert(minplist,p)
		end
	end
	local inext=math.random(1,#minplist)
	local pnext=minplist[inext]
	for var=1,#minplist,1 do
		if var~=inext and sgs.Role(pnext,minplist[var]) then sgs.ComboPlayer(minplist[var],pnext) end
	end
	for _,p in sgs.qlist(room:getAllPlayers()) do
		p:speak(sgs.GetActionSlot(p).."|"..sgs.GetSpeed(p))
		sgs.SetActionSlot(p,sgs.GetActionSlot(p)-sgs.GetSpeed(p)*mintime)
	end
	room:setCurrent(pnext)
	room:getThread():trigger(sgs.TurnStart,room,pnext)
end

luarpgplayersk=sgs.CreateTriggerSkill{
name="luarpgplayersk",
events={sgs.GameStart,sgs.NonTrigger,sgs.EventPhaseStart},
on_trigger=function(self,event,player,data)
	local room=player:getRoom()
	if event==sgs.GameStart then
		local chprof=sgs.NextProf(player,true)
		sgs.ProfUp(player,chprof)
	end
	if event==sgs.NonTrigger then
		local getprof=data:toString()
		sgs.SetLevel(player,getprof,sgs.GetLevel(player,getprof)+1)
		player:speak(player:objectName().." "..getprof.." level:"..sgs.GetLevel(player,getprof))
		sgs.LevelBonus(player,getprof)
		local chprof=sgs.NextProf(player)
		if chprof then
			sgs.ProfUp(player,chprof)
		end
	end
	if event==sgs.EventPhaseStart then
		if player:getPhase()==sgs.Player_RoundStart then
			sgs.ProfSkill(player)
		elseif player:getPhase()==sgs.Player_NotActive then
			sgs.ProfSkill(player)
		end
	end
end,
}

luarpgdeadsk=sgs.CreateTriggerSkill{
name="luarpgdeadsk",
events={sgs.GameStart},
on_trigger=function(self,event,player,data)
	if event==sgs.GameStart then
		player:getRoom():killPlayer(player)
	end
end,
}

luarpgrulesk=sgs.CreateTriggerSkill{
name="luarpgrulesk",
events={sgs.GameStart,sgs.EventPhaseChanging,sgs.TurnStart},
on_trigger=function(self,event,player,data)
	local room=player:getRoom()
	if event==sgs.EventPhaseChanging then
		local phasechange=data:toPhaseChange()
		if phasechange.to==sgs.Player_NotActive then
			sgs.NextPlayer(player)
		end
	elseif event==sgs.TurnStart then
		player:speak("turnstart")
		sgs.SetActionSlot(player)
	elseif event==sgs.GameStart then
		for _,p in sgs.qlist(room:getAllPlayers()) do
			sgs.SetActionSlot(p,math.random(1,sgs.RPGConst.defaultactionslot))
		end
	end
end,
can_trigger=function(self,target)
	return true
end,
}

function addsk(sk)
	if not sgs.Sanguosha:getSkill(sk:objectName()) then
		local sklist=sgs.SkillList()
		sklist:append(sk)
		sgs.Sanguosha:addSkills(sklist)
	end
end
luarpgplayer:addSkill(luarpgplayersk)
luarpgdead:addSkill(luarpgdeadsk)
addsk(luarpgrulesk)


function cmpltrans(t)
	local key
	local value
	local tmplist4here={}
	for key,value in pairs(t) do
		tmplist4here[key]=value
		if string.sub(key,1,1)==":" and not t["~"..string.sub(key,2)] then
			tmplist4here["~"..string.sub(key,2)]=value
		end
		if string.sub(key,1,1)==":" and not t["@"..string.sub(key,2)] then
			tmplist4here["@"..string.sub(key,2)]=t[string.sub(key,2)]
		end
		if string.sub(key,1,1)~=":" and not t[":"..key] then
			tmplist4here["designer:"..key]=tmplist4here["designer:"..key] or "DESIGNER"
			tmplist4here["illustrator:"..key]=tmplist4here["illustrator:"..key] or "Internet"
		end
	end
	return tmplist4here
end
transtable={
["luarpgplayer"]="勇者",
["luarpgplayersk"]="勇者",
["luarpgdead"]="尸体",
["luarpgdeadsk"]="尸体",
}
sgs.LoadTranslationTable(cmpltrans(transtable))

function sgs.CreateProf(spec)
	assert(type(spec)=="table")
	assert(type(spec.name)=="string")	
	local prof={}
	prof["name"]=spec.name	
	prof.gn=sgs.General(extension,spec.name,"god",4,true,true)
	prof["speed"]=spec.speed or sgs.RPGConst.defaultspeed
	if spec.prev then
		assert(type(spec.prev)=="table")
		prof["prev"]=spec.prev		
	else
		prof["prev"]={[""]=0}
	end
	if spec.levelup then
		assert(type(spec.levelup)=="table")
		spec.levelup.name=spec.name
		local sk=sgs.CreateTriggerSkill(spec.levelup)
		addsk(sk)
		prof["levelup"]=sk
	end
	if spec.levelbonus then
		assert(type(spec.levelbonus)=="function")
		prof["levelbonus"]=spec.levelbonus
	end
	if spec.profbonus then
		assert(type(spec.profbonus)=="function")
		prof["profbonus"]=spec.profbonus
	end
	if spec.translation then
		assert(type(spec.translation)=="table")
		sgs.LoadTranslationTable(cmpltrans(spec.translation))
	end
	table.insert(sgs.ProfList,prof)
end

function sgs.AssertGeneral(spec)
	assert(type(spec)=="table")
	assert(type(spec.name)=="string")
	spec.kingdom=spec.kingdom or "god"
	assert(type(spec.kingdom)=="string")
	spec.hp=spec.hp or 4
	assert(type(spec.hp)=="number")
	spec.sex=spec.sex or true
	assert(type(spec.sex)=="boolean")
	spec.ishidden=spec.ishidden or false
	assert(type(spec.ishidden)=="boolean")
	spec.nevershown=spec.nevershown or false
	assert(type(spec.nevershown)=="boolean")
	return sgs.General(extension,spec.name,spec.kingdom,spec.hp,spec.sex,spec.ishidden,spec.nevershown)
end

function sgs.CreateBoss(spec)
	assert(type(spec)=="table")
	assert(type(spec.name)=="string")	
	local gntable={}
	gntable.gn=sgs.AssertGeneral(spec)
	gntable.skills={}
	gntable.speed=spec.speed or sgs.RPGConst.defaultspeed
	spec.stagenum=spec.stagenum or 0
	assert(type(spec.stagenum)=="number")
	if spec.stagechange then
		assert(type(spec.stagechange)=="table")
		spec.stagechange.name="#"..spec.name
		local sk=sgs.CreateTriggerSkill(spec.stagechange)
		--addsk(sk)
		gntable.gn:addSkill(sk)
		table.insert(gntable.skills,sk)
	end
	if spec.stageeffect then
		assert(type(spec.stageeffect)=="function")
		local sk=sgs.CreateTriggerSkill{
			name=spec.name,
			events={sgs.GameStart,sgs.NonTrigger},
			on_trigger=function(self,event,player,data)
				local room=player:getRoom()
				if event==sgs.GameStart then
					room:setPlayerMark(player,sgs.RPGConst.maxstage,spec.stagenum)
				end
				if event==sgs.NonTrigger then
					if sgs.GetStage(player)>=player:getMark(sgs.RPGConst.maxstage) then return false end
					sgs.SetStage(player,sgs.GetStage(player)+1)
					player:speak(self:objectName()..": stage"..sgs.GetStage(player))
					spec.stageeffect(player,sgs.GetStage(player))
				end
			end,
		}
		--addsk(sk)
		gntable.gn:addSkill(sk)
		table.insert(gntable.skills,sk)
	end
	sgs.BossList[spec.name]=gntable
	--table.insert(sgs.BossList,gntable)
	if spec.translation then
		assert(type(spec.translation)=="table")
		sgs.LoadTranslationTable(cmpltrans(spec.translation))
	end
end

function sgs.CreateSummoned(spec)
	assert(type(spec)=="table")
	assert(type(spec.name)=="string")
	local gntable={}
	gntable.gn=sgs.AssertGeneral(spec)
	gntable.skills={}
	gntable.speed=spec.speed or sgs.RPGConst.defaultspeed
	if spec.weakness then
		assert(type(spec.weakness)=="table")
		spec.weakness.name="#"..spec.name
		local sk=sgs.CreateTriggerSkill(spec.weakness)
		gntable.gn:addSkill(sk)
		table.insert(gntable.skills,sk)
	end
	if spec.summoneffect then assert(type(spec.summoneffect)=="function")
	else spec.summoneffect=function(player,summoner) end 
	end
	if spec.antisummoneffect then assert(type(spec.antisummoneffect)=="function")
	else spec.antisummoneffect=function(player,summoner,weakness) end
	end
	local sk0=sgs.CreateTriggerSkill{
		name=spec.name,
		events={sgs.NonTrigger,sgs.EventPhaseEnd},
		on_trigger=function(self,event,player,data)
			local room=player:getRoom()
			if event==sgs.NonTrigger then
				local strlist=data:toString():split("_")
				if strlist[1]=="summon" then
					player:speak("summoning")
					spec.summoneffect(player,sgs.GetSummoner(player))
				elseif strlist[1]=="antisummon" then
					player:speak("antisummoning")
					spec.antisummoneffect(player,sgs.GetSummoner(player),strlist[2])
					room:killPlayer(player)
				end
			end
			if event==sgs.EventPhaseEnd then
				if player:getPhase()==sgs.Player_Finish then room:setPlayerMark(player,sgs.RPGConst.summonturn,player:getMark(sgs.RPGConst.summonturn)+1) end
			end
		end,
	}
	gntable.gn:addSkill(sk0)
	table.insert(gntable.skills,sk0)
	sgs.SummonedList[spec.name]=gntable
	--table.insert(sgs.SummonedList,gntable)
	if spec.translation then
		assert(type(spec.translation)=="table")
		sgs.LoadTranslationTable(cmpltrans(spec.translation))
	end
end

function sgs.LevelUp(player,getprof)
	local room=player:getRoom()
	room:getThread():trigger(sgs.NonTrigger,room,player,sgs.QVariant(getprof))
end
function sgs.NextStage(player)
	local room=player:getRoom()
	room:getThread():trigger(sgs.NonTrigger,room,player)
end
function sgs.AcquireSkill(player,skname)
	local room=player:getRoom()
	local list={}
	local skstr=room:getTag(GetSkillConst(player)):toString()
	if skstr~="" then list=skstr:split("+") end
	if not table.contains(list,skname) then
		player:speak(player:objectName().." acquire:"..skname)
		table.insert(list,skname)
		local str=table.concat(list,"+")
		if str=="" then
			room:setTag(GetSkillConst(player),sgs.QVariant())
		else
			room:setTag(GetSkillConst(player),sgs.QVariant(str))
		end
	end
end
function sgs.DetachSkill(player,skname)
	local room=player:getRoom()
	local list={}
	local skstr=room:getTag(GetSkillConst(player)):toString()
	if skstr~="" then list=skstr:split("+") end
	if list:contains(skname) then 
		table.removeOne(list,skname)
		local str=table.concat(list,"+")
		if str=="" then
			room:setTag(GetSkillConst(player),sgs.QVariant())
		else
			room:setTag(GetSkillConst(player),sgs.QVariant(str))
		end
	end
end
function sgs.HasSkill(player,skname)
	local room=player:getRoom()
	local data=room:getTag(GetSkillConst(player))
	if not data then return false end
	return table.contains(data:toString():split("+"),skname)
end

function sgs.DeadCount(player,opposite)
	opposite=opposite or false
	local room=player:getRoom()
	local cnt=0
	for _,p in sgs.qlist(room:getAllPlayers(true)) do
		if sgs.Role(player,p,opposite) and not p:isAlive() then cnt=cnt+1 end
	end
	return cnt
end
function sgs.GetDead(player,opposite)
	opposite=opposite or false
	if sgs.DeadCount(player,opposite)==0 then return nil end
	local room=player:getRoom()
	for _,p in sgs.qlist(room:getAllPlayers(true)) do
		if sgs.Role(player,p,opposite) and not p:isAlive() then return p end
	end
	return nil
end
function sgs.Summon(player,summoned,opposite)
	opposite=opposite or false
	if sgs.DeadCount(player,opposite)==0 then return nil end
	local pdead=sgs.GetDead(player,opposite)	
	local room=player:getRoom()
	room:revivePlayer(pdead)
	sgs.SetSummoner(pdead,player)	
	pdead:clearHistory()
	if pdead:getKingdom()~=sgs.Sanguosha:getGeneral(summoned):getKingdom() then room:setPlayerProperty(pdead,"kingdom",sgs.QVariant(sgs.Sanguosha:getGeneral(summoned):getKingdom())) end
	if not pdead:faceUp() then pdead:turnOver() end
	if pdead:isChained() then room:setPlayerProperty(pdead,"chained",sgs.QVariant(false)) end
	room:changeHero(pdead,summoned,true,true,false,true)
	room:getThread():trigger(sgs.NonTrigger,room,pdead,sgs.QVariant("summon"))
	return pdead
end
function sgs.AntiSummon(player,weakness)
	local room=player:getRoom()
	room:getThread():trigger(sgs.NonTrigger,room,player,sgs.QVariant("antisummon_"..weakness))
end
function sgs.GetSummonTurn(player)
	return player:getMark(sgs.RPGConst.summonturn)
end

function exfiles()
	local files=sgs.GetFileNames("extensions")
	for _,file in ipairs(files) do
		if file:match("^myrpg%-.+%.lua$") then
			--sgs.Alert(file)
			require("extensions."..file:sub(0,file:find("%.")-1))
		end
	end	
end

exfiles()

--[[
function sgs.CreateGeneral(spec)
	assert(type(spec)=="table")
	assert(type(spec.name)=="string")
	spec.kingdom=spec.kingdom or "god"
	spec.hp=spec.hp or 4
	spec.sex=spec.sex or true
	spec.ishidden=spec.ishidden or false
	spec.nevershown=spec.nevershown or false
	assert(type(spec.kingdom)=="string")
	assert(type(spec.hp)=="number")
	assert(type(spec.sex)=="boolean")
	assert(type(spec.ishidden)=="boolean")
	assert(type(spec.nevershown)=="boolean")
	spec.gn=sgs.General(sgs.RPGConst.extension,spec.name,spec.kingdom,spec.hp,spec.sex,spec.ishidden,spec.nevershown)
	if spec.skill then
		assert(type(spec.skill)=="table")
		for _,sk in pairs(spec.skill) do
			spec.gn:addSkill(sk)
		end
	end
end
]]