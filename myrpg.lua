module("extensions.myrpg",package.seeall)
extension=sgs.Package("myrpg")
sgs.ProfList={}
sgs.MonsterList={}
sgs.SceneList={}
sgs.RPGConst={}
sgs.RPGConst.profcnt="luamyrpg_profcnt"
sgs.RPGConst.prof="luamyrpg_prof"
sgs.RPGConst.level="luamyrpg_level"
sgs.RPGConst.skill="luamyrpg_skill"
sgs.RPGConst.stage="luamyrpg_stage"
sgs.RPGConst.maxstage="luamyrpg_maxstage"
sgs.RPGConst.summoner="luamyrpg_summoner"
sgs.RPGConst.summonturn="luamyrpg_summonturn"
sgs.RPGConst.deathdamage="luamyrpg_deathdamage"
sgs.RPGConst.scene="luamyrpg_scene"
sgs.RPGConst.sceneenemy="luamyrpg_sceneenemy"
sgs.RPGConst.sceneini="luamyrpg_sceneini"
sgs.RPGConst.speed="luamyrpg_speed"
sgs.RPGConst.defaultspeed=100
sgs.RPGConst.actionslot="luamyrpg_actionslot"
sgs.RPGConst.defaultactionslot=100
sgs.RPGConst.speedlog1="$luamyrpg_speedlog1"
sgs.RPGConst.speedlog2="$luamyrpg_speedlog2"
sgs.RPGConst.proflog1="$luamyrpg_proflog1"
sgs.RPGConst.proflog2="$luamyrpg_proflog2"
sgs.RPGConst.summonlog1="$luamyrpg_summonlog1"
sgs.RPGConst.antisummonlog1="$luamyrpg_antisummonlog1"
sgs.RPGConst.stagelog1="$luamyrpg_stagelog1"
sgs.RPGConst.cancel="cancel"
sgs.RPGConst.choosechoice="Please choose a choice"
sgs.RPGConst.chooseprof="Please choose a profession"
sgs.RPGConst.chooseskill="Please choose a skill"
sgs.RPGConst.eachdraw="each draws a card"
sgs.RPGConst.drawandplay="draw a card and play"
sgs.RPGConst.role={["lord"]=0,["loyalist"]=0,["rebel"]=1,["renegade"]=1}
sgs.RPGConst.player=0
sgs.RPGConst.monster=1
sgs.RPGConst.actionslot_damaged=-10
sgs.RPGConst.actionslot_discard=-5
sgs.RPGConst.actionslot_draw=5
sgs.RPGConst.actionslot_useresponse=8
sgs.RPGConst.signal_levelup="levelup"
sgs.RPGConst.signal_nextstage="nextstage"
sgs.RPGConst.signal_summon="summon"
sgs.RPGConst.signal_antisummon="antisummon"
sgs.RPGConst.signal_death="death"

luarpgplayer=sgs.General(extension,"luarpgplayer","god",4,true)
luarpgdead=sgs.General(extension,"luarpgdead","god",4,true,true)
--luarpgrule=sgs.General(extension,"luarpgrule","god",4,true,true)

function sgs.SendLog(typestr,from,tolist,cardstr,arg,arg2)
	local room=from:getRoom()
	tolist=tolist or room:getAllPlayers(true)
	cardstr=cardstr or ""
	arg=arg or ""
	arg2=arg2 or ""
	local mylog=sgs.LogMessage()
	mylog.type=typestr
	mylog.from=from
	mylog.to=tolist
	mylog.cardstr=cardstr
	mylog.arg=arg
	mylog.arg2=arg2
	room:sendLog(mylog)
end
function sgs.EncodeSignal(sigtype,sigvalue)
	sigvalue=sigvalue or ""
	return sigtype.."|"..sigvalue
end
function sgs.DecodeSignal(sigstr)
	local list=sigstr:split("|")
	return list[1],list[2]
end
--[[
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
]]
function sgs.GetNextProfList(getprof)
	--if type(para)=="number" then return sgs.GetNextProfList(sgs.Index2Prof(para)) end
	--local getprof=para
	local list={}
	for _,iprof in pairs(sgs.ProfList) do
		for key,value in pairs(iprof.prev) do
			if key==getprof then list[iprof.name]=value break end
		end
	end
	--[[
	for var=1,#sgs.ProfList,1 do
		for key,value in pairs(sgs.ProfList[var].prev) do
			if key==getprof then list[var]=value break end
		end
	end]]
	return list
end
function GetProfConst(player)
	return sgs.RPGConst.prof.."_"..player:objectName()
end
function sgs.GetProf(player)
	local data=player:getRoom():getTag(GetProfConst(player))
	local str=""
	if data then str=data:toString() end
	return str
end
function sgs.SetProf(player,getprof)
	player:getRoom():setTag(GetProfConst(player),sgs.QVariant(getprof))
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
	if sgs.MonsterList[gname] then return sgs.RPGConst.monster end
	sgs.Alert(gname.."!!")
end
function sgs.InitialSpeed(player)
	local room=player:getRoom()
	local v=sgs.RPGConst.defaultspeed
	local gname=player:getGeneralName()
	local ptype=sgs.GetType(gname)
	if ptype==sgs.RPGConst.player then
		local prof=sgs.GetProf(player)
		if prof~="" then v=sgs.ProfList[prof].speed end
	end
	if ptype==sgs.RPGConst.monster then v=sgs.MonsterList[gname].speed end
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
function sgs.GetScene(room)
	local data=room:getTag(sgs.RPGConst.scene)
	if not data then return "",1 end
	if data:toString()=="" then return "",1 end
	local list=data:toString():split("|")
	if #list~=2 then sgs.Alert("getscene") end
	return list[1],tonumber(list[2])
end
function sgs.SetScene(room,name,num)
	num=num or 1
	room:setTag(sgs.RPGConst.scene,sgs.QVariant(name.."|"..num))
end

function sgs.FindPlayers(room,includedead,ptype)
	includedead=includedead or false
	ptype=ptype or sgs.RPGConst.player
	local list={}
	for _,p in sgs.qlist(room:getAllPlayers(includedead)) do
		if sgs.GetType(p:getGeneralName())==ptype then table.insert(list,p) end
	end
	return list
end
function sgs.IsEnemy(player)
	return sgs.Role(player,sgs.FindPlayers(player:getRoom(),true)[1],true)
end

function sgs.NextProf(player,force)
	local room=player:getRoom()
	local prof0=sgs.GetProf(player)
	local list={}
	for key,value in pairs(sgs.GetNextProfList(prof0)) do
		if sgs.GetLevel(player,key)>=value then table.insert(list,key) end
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
	if sgs.ProfList[getprof].levelbonus then
		sgs.ProfList[getprof].levelbonus(player,sgs.GetLevel(player,getprof))
		--ProfSkill(player)
	end
end

function sgs.ProfUp(player,getprof)
	if not getprof then return nil end
	--ProfClear(player)
	local room=player:getRoom()
	local prof0=sgs.GetProf(player)	
	if prof0~="" then
		for key,_ in pairs(sgs.GetNextProfList(prof0)) do
			if sgs.ProfList[key].levelup then
				local skname=sgs.ProfList[key].levelup:objectName()
				if player:hasSkill(skname) then room:detachSkillFromPlayer(player,skname) end
			end
			sgs.SetLevel(player,key,0)
		end
	end
			
	room:setPlayerMark(player,sgs.RPGConst.profcnt,player:getMark(sgs.RPGConst.profcnt)+1)
	sgs.SetProf(player,getprof)
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
	if sgs.ProfList[getprof].profbonus then
		sgs.ProfList[getprof].profbonus(player,prof0)
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
		sgs.SendLog(sgs.RPGConst.speedlog1,p,room:getAllPlayers(true),"",sgs.GetActionSlot(p),sgs.GetSpeed(p))
		sgs.SetActionSlot(p,sgs.GetActionSlot(p)-sgs.GetSpeed(p)*mintime)
	end
	sgs.SendLog(sgs.RPGConst.speedlog2,pnext)
	room:setCurrent(pnext)
	room:getThread():trigger(sgs.TurnStart,room,pnext)
end

function sgs.KillPlayer(player,reason)
	if not player:isAlive() then return nil end
	local room=player:getRoom()
	local sigvalue=""
	if reason then 
		sigvalue=sgs.RPGConst.deathdamage
		local data=sgs.QVariant()
		data:setValue(reason)
		room:setTag(sgs.RPGConst.deathdamage,data)
	end
	room:getThread():trigger(sgs.NonTrigger,room,player,sgs.QVariant(sgs.EncodeSignal(sgs.RPGConst.signal_death,sigvalue)))
end
function sgs.RevivePlayer(player,revived,fakealive)
	fakealive=fakealive or false
	local room=player:getRoom()
	if not fakealive then
		if player:isAlive() then return nil end
		room:revivePlayer(player)
		player:clearHistory()
	end
	local kingdom=sgs.Sanguosha:getGeneral(revived):getKingdom()
	if player:getKingdom()~=kingdom then room:setPlayerProperty(player,"kingdom",sgs.QVariant(kingdom)) end
	local maxhp=sgs.Sanguosha:getGeneral(revived):getMaxHp()
	if player:getMaxHp()~=maxhp then room:setPlayerProperty(player,"maxhp",sgs.QVariant(maxhp)) end
	if player:getHp()~=maxhp then room:setPlayerProperty(player,"hp",sgs.QVariant(maxhp)) end
	if not player:faceUp() then player:turnOver() end
	if player:isChained() then room:setPlayerProperty(player,"chained",sgs.QVariant(false)) end
	room:changeHero(player,revived,true,true,false,true)
end

function sgs.GetDead(player,opposite)
	opposite=opposite or false
	local room=player:getRoom()
	for _,p in sgs.qlist(room:getAllPlayers(true)) do
		if sgs.Role(player,p,opposite) and not p:isAlive() then return p end
	end
	return nil
end

function sgs.NextEnemy(pdead)
	local room=pdead:getRoom()
	local scenename,currentscene=sgs.GetScene(room)
	local str=room:getTag(sgs.RPGConst.sceneenemy):toString()
	if str=="" then return false end
	local list=str:split("|")
	local rnd=math.random(1,#list)
	local enemy=list[rnd]
	table.remove(list,rnd)
	room:setTag(sgs.RPGConst.sceneenemy,sgs.QVariant(table.concat(list,"|")))
	sgs.RevivePlayer(pdead,enemy,true)
	return true
end
function sgs.InitialScene(room,scenename,currentscene)
	local r1,r2=sgs.GetScene(room)
	scenename=scenename or r1
	currentscene=currentscene or r2
	if scenename==r1 and currentscene==r2 then
	else
		sgs.SetScene(room,scenename,currentscene)
	end
	local list={}
	for key,value in pairs(sgs.SceneList[scenename].sceneenemy[currentscene]) do
		local v1,v2=math.modf(value)
		for var=1,v1,1 do table.insert(list,key) end
		if math.random(1,100)/100<=v2 then table.insert(list,key) end
	end
	local list2={}
	local cnt=0
	for _,p in sgs.qlist(room:getAllPlayers(true)) do
		if sgs.IsEnemy(p) then cnt=cnt+1 end
	end
	while #list>cnt do
		local rnd=math.random(1,#list)
		table.insert(list2,list[rnd])
		table.remove(list,rnd)
	end
	cnt=0
	for _,p in sgs.qlist(room:getAllPlayers(true)) do
		if sgs.IsEnemy(p) then
			cnt=cnt+1
			sgs.RevivePlayer(p,list[cnt],p:isAlive())
		end
		if cnt==#list then break end
	end
	room:setTag(sgs.RPGConst.sceneenemy,sgs.QVariant(table.concat(list2,"|")))
	sgs.SceneList[scenename].sceneeffect(room,currentscene)
end
function sgs.NextScene(room)
	local scenename,currentscene=sgs.GetScene(room)
	if sgs.SceneList[scenename].scenenum>currentscene then
		--sgs.SetScene(player,scenename,currentscene+1)
		sgs.InitialScene(room,scenename,currentscene+1)
		return true
	else
		return false
	end
end

luarpgplayersk=sgs.CreateTriggerSkill{
name="luarpgplayersk",
events={sgs.GameStart,sgs.NonTrigger,sgs.EventPhaseChanging},
on_trigger=function(self,event,player,data)
	local room=player:getRoom()
	if event==sgs.GameStart then
		local chprof=sgs.NextProf(player,true)
		sgs.ProfUp(player,chprof)
	end
	if event==sgs.NonTrigger then
		local sigtype,getprof=sgs.DecodeSignal(data:toString())
		if sigtype~=sgs.RPGConst.signal_levelup then return false end
		sgs.SetLevel(player,getprof,sgs.GetLevel(player,getprof)+1)
		--player:speak(player:objectName().." "..getprof.." level:"..sgs.GetLevel(player,getprof))
		sgs.SendLog(sgs.RPGConst.proflog1,player,room:getAllPlayers(true),"",getprof,sgs.GetLevel(player,getprof))
		sgs.LevelBonus(player,getprof)
		local chprof=sgs.NextProf(player)
		if chprof then
			sgs.ProfUp(player,chprof)
		end
	end
	if event==sgs.EventPhaseChanging then
		local phasechange=data:toPhaseChange()
		if phasechange.to==sgs.Player_RoundStart then
			sgs.ProfSkill(player)
		elseif phasechange.to==sgs.Player_NotActive then
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

luarpgrulespeedsk=sgs.CreateTriggerSkill{
name="luarpgrulespeedsk",
events={sgs.GameStart,sgs.EventPhaseChanging,sgs.TurnStart,
		sgs.Damaged,sgs.CardUsed,sgs.CardResponded,sgs.CardsMoveOneTime},
on_trigger=function(self,event,player,data)
	local room=player:getRoom()
	if event==sgs.EventPhaseChanging then
		local phasechange=data:toPhaseChange()
		if phasechange.to==sgs.Player_NotActive then
			sgs.NextPlayer(player)
		end
	elseif event==sgs.TurnStart then
		sgs.SetActionSlot(player)
	elseif event==sgs.GameStart then
		for _,p in sgs.qlist(room:getAllPlayers()) do
			sgs.SetActionSlot(p,sgs.RPGConst.defaultactionslot+math.random(1,11)-6)
		end
	elseif event==sgs.Damaged then
		local dmg=data:toDamage()
		sgs.SetActionSlot(dmg.to,sgs.GetActionSlot(dmg.to)+sgs.RPGConst.actionslot_damaged)
	elseif event==sgs.CardUsed then
		local use=data:toCardUse()
		sgs.SetActionSlot(use.from,sgs.GetActionSlot(use.from)+sgs.RPGConst.actionslot_useresponse)
	elseif event==sgs.CardResponded then
		local resp=data:toResponsed()
		sgs.SetActionSlot(player,sgs.GetActionSlot(player)+sgs.RPGConst.actionslot_useresponse)
	elseif event==sgs.CardsMoveOneTime then
		local mv=data:toMoveOneTime()
		if mv.from and mv.from:objectName()==player:objectName() and mv.to_place==sgs.Player_DiscardPile then
			
		end
	end
end,
can_trigger=function(self,target)
	return true
end,
}

luarpgrulescenesk=sgs.CreateTriggerSkill{
name="luarpgrulescenesk",
events={sgs.AskForPeachesDone,sgs.MaxHpChanged,sgs.NonTrigger,sgs.GameStart},
can_trigger=function(self,player)
	return true
end,
on_trigger=function(self,event,player,data)
	local room=player:getRoom()
	if event==sgs.AskForPeachesDone then
		if not sgs.IsEnemy(player) then return false end
		if player:getHp()<=0 and player:isAlive() then
			local dying=data:toDying()
			sgs.KillPlayer(player,dying.damage)
			return true
		end
	elseif event==sgs.MaxHpChanged then
		if not sgs.IsEnemy(player) then return false end
		if player:getMaxHp()<=0 and player:isAlive() then
			room:setPlayerProperty(player,"maxhp",sgs.QVariant(1))
			sgs.KillPlayer(player)
		end
	elseif event==sgs.NonTrigger then
		local sigtype,sigvalue=sgs.DecodeSignal(data:toString())
		if sigtype==sgs.RPGConst.signal_death then
			local b=true			
			if sgs.IsEnemy(player) then
				if sgs.NextEnemy(player) then b=false
				else
					local b2=false
					for _,p in sgs.qlist(room:getOtherPlayers(player)) do
						if sgs.Role(p,player) then b2=true break end
					end
					if not b2 then b=not sgs.NextScene(room) end
				end
			end
			if b then
				local reason
				if sigvalue~="" then reason=room:getTag(sgs.RPGConst.deathdamage):toDamage() end
				room:killPlayer(player,reason)
				return false
			end
		end
	elseif event==sgs.GameStart then
		if room:getTag(sgs.RPGConst.sceneini):toString()=="started" then return false end
		local list={}
		for key,_ in pairs(sgs.SceneList) do
			table.insert(list,key)
		end
		table.insert(list,"cancel")
		local ch=room:askForChoice(player,"",table.concat(list,"+"))
		if ch~="cancel" then
			sgs.InitialScene(room,ch)
		end
		room:setTag(sgs.RPGConst.sceneini,sgs.QVariant("started"))
	end
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
addsk(luarpgrulespeedsk)
addsk(luarpgrulescenesk)


function cmpltrans(t)
	local key,value
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
			tmplist4here["illustrator:"..key]=tmplist4here["illustrator:"..key] or "ILLUSTRATOR"
		end
	end
	return tmplist4here
end
transtable={
["luarpgplayer"]="勇者",
["luarpgplayersk"]="勇者",
["luarpgdead"]="尸体",
["luarpgdeadsk"]="尸体",
[sgs.RPGConst.speedlog1]="%from 行动槽:%arg 速度:%arg2",
[sgs.RPGConst.speedlog2]="下一个行动的是 %from",
[sgs.RPGConst.proflog1]="%from %arg 升级，当前等级 %arg2",
[sgs.RPGConst.proflog2]="%from 获得技能 【%arg】",
[sgs.RPGConst.stagelog1]="%from 进入了状态 %arg",
[sgs.RPGConst.summonlog1]="%from 召唤了 %arg",
[sgs.RPGConst.antisummonlog1]="%from 回归虚无",
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
	sgs.ProfList[spec.name]=prof
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
--[[
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
					local sigtype=sgs.DecodeSignal(data:toString())
					if sigtype~=sgs.RPGConst.signal_nextstage then return false end
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
				local sigtype,sigvalue=sgs.DecodeSignal(data:toString())
				if sigtype==sgs.RPGConst.signal_summon then
					player:speak("summoning")
					spec.summoneffect(player,sgs.GetSummoner(player))
				elseif sigtype==sgs.RPGConst.signal_antisummon then
					player:speak("antisummoning")
					spec.antisummoneffect(player,sgs.GetSummoner(player),sigvalue)
					sgs.KillPlayer(player)
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
]]
function sgs.CreateMonster(spec)
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
		spec.stagechange.name="#"..spec.name.."_stagechange"
		local sk=sgs.CreateTriggerSkill(spec.stagechange)
		--addsk(sk)
		gntable.gn:addSkill(sk)
		table.insert(gntable.skills,sk)
	end	
	if spec.weakness then
		assert(type(spec.weakness)=="table")
		spec.weakness.name="#"..spec.name.."_weakness"
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
	if spec.stageeffect then assert(type(spec.stageeffect)=="function")
	else spec.stageeffect=function(player,currentstage) end
	end
	local sk0=sgs.CreateTriggerSkill{
		name=spec.name,
		events={sgs.NonTrigger,sgs.EventPhaseEnd,sgs.GameStart},
		on_trigger=function(self,event,player,data)
			local room=player:getRoom()
			if event==sgs.NonTrigger then
				local sigtype,sigvalue=sgs.DecodeSignal(data:toString())
				if sigtype==sgs.RPGConst.signal_summon then
					--player:speak("summoning")
					sgs.SendLog(sgs.RPGConst.summonlog1,sgs.GetSummoner(player),nil,"",player:getGeneralName())
					spec.summoneffect(player,sgs.GetSummoner(player))
				elseif sigtype==sgs.RPGConst.signal_antisummon then
					--player:speak("antisummoning")
					sgs.SendLog(sgs.RPGConst.antisummonlog1,player)
					spec.antisummoneffect(player,sgs.GetSummoner(player),sigvalue)
					sgs.KillPlayer(player)
				elseif sigtype==sgs.RPGConst.signal_nextstage then
					if sgs.GetStage(player)>=player:getMark(sgs.RPGConst.maxstage) then return false end
					sgs.SetStage(player,sgs.GetStage(player)+1)
					--player:speak(self:objectName()..": stage"..sgs.GetStage(player))
					sgs.SendLog(sgs.RPGConst.stagelog1,player,nil,"",sgs.GetStage(player))
					spec.stageeffect(player,sgs.GetStage(player))
				end					
			elseif event==sgs.EventPhaseEnd then
				if player:getPhase()==sgs.Player_Finish then room:setPlayerMark(player,sgs.RPGConst.summonturn,player:getMark(sgs.RPGConst.summonturn)+1) end
			elseif event==sgs.GameStart then
				room:setPlayerMark(player,sgs.RPGConst.maxstage,spec.stagenum)
			end
		end,
	}
	gntable.gn:addSkill(sk0)
	table.insert(gntable.skills,sk0)
	if spec.skills then
		assert(type(spec.skills)=="table")
		for _,isk in pairs(spec.skills) do
			gntable.gn:addSkill(isk)
			table.insert(gntable.skills,isk)
		end
	end
	sgs.MonsterList[spec.name]=gntable
	if spec.translation then
		assert(type(spec.translation)=="table")
		sgs.LoadTranslationTable(cmpltrans(spec.translation))
	end
end

function sgs.CreateScene(spec)
	assert(type(spec)=="table")
	assert(type(spec.name)=="string")
	spec.scenenum=spec.scenenum or 1
	assert(type(spec.scenenum)=="number")
	assert(type(spec.sceneenemy)=="table")
	assert(spec.sceneenemy[1])
	local sceneenemy0=spec.sceneenemy[1]
	for var=1,spec.scenenum,1 do
		spec.sceneenemy[var]=spec.sceneenemy[var] or sceneenemy0
		sceneenemy0=spec.sceneenemy[var]
	end
	spec.sceneeffect=spec.sceneeffect or function(room,currentscene) end
	assert(type(spec.sceneeffect)=="function")
	sgs.SceneList[spec.name]=spec
end

function sgs.LevelUp(player,getprof)
	local room=player:getRoom()
	room:getThread():trigger(sgs.NonTrigger,room,player,sgs.QVariant(sgs.EncodeSignal(sgs.RPGConst.signal_levelup,getprof)))
end
function sgs.NextStage(player)
	local room=player:getRoom()
	room:getThread():trigger(sgs.NonTrigger,room,player,sgs.QVariant(sgs.EncodeSignal(sgs.RPGConst.signal_nextstage)))
end
function sgs.AcquireSkill(player,skname)
	local room=player:getRoom()
	local list={}
	local skstr=room:getTag(GetSkillConst(player)):toString()
	if skstr~="" then list=skstr:split("+") end
	if not table.contains(list,skname) then
		--player:speak(player:objectName().." acquire:"..skname)
		sgs.SendLog(sgs.RPGConst.proflog2,player,nil,"",skname)
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


function sgs.Summon(player,summoned,opposite)
	opposite=opposite or false
	local pdead=sgs.GetDead(player,opposite)
	if not pdead then return nil end
	local room=player:getRoom()	
	sgs.RevivePlayer(pdead,summoned)
	room:getThread():trigger(sgs.NonTrigger,room,pdead,sgs.QVariant(sgs.EncodeSignal(sgs.RPGConst.signal_summon)))
	return pdead
end
function sgs.AntiSummon(player,weakness)
	local room=player:getRoom()
	room:getThread():trigger(sgs.NonTrigger,room,player,sgs.QVariant(sgs.EncodeSignal(sgs.RPGConst.signal_antisummon,weakness)))
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