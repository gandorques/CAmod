ProdigyPatrolPath = { ProdigyPatrol1.Location, ProdigyPatrol2.Location, ProdigyPatrol3.Location, ProdigyPatrol4.Location, ProdigyPatrol5.Location, ProdigyPatrol6.Location, ProdigyPatrol7.Location, ProdigyPatrol8.Location, ProdigyPatrol9.Location, ProdigyPatrol10.Location, ProdigyPatrol11.Location, ProdigyPatrol12.Location, ProdigyPatrol13.Location, ProdigyPatrol14.Location, ProdigyPatrol15.Location, ProdigyPatrol16.Location, ProdigyPatrol17.Location, ProdigyPatrol18.Location, ProdigyPatrol19.Location, ProdigyPatrol9.Location, ProdigyPatrol8.Location, ProdigyPatrol20.Location }

ScrinReinforcementInterval = {
	easy = DateTime.Seconds(40),
	normal = DateTime.Seconds(30),
	hard = DateTime.Seconds(20),
}

TimeLimit = {
	easy = DateTime.Minutes(30),
	normal = DateTime.Minutes(20),
	hard = DateTime.Minutes(10),
}

RushLimit = {
	easy = DateTime.Seconds(15),
	normal = DateTime.Seconds(10),
	hard = DateTime.Seconds(5),
}

IsValidTanya = function(actor)
	return not actor.IsDead and actor.Type == "e7"
end

WorldLoaded = function()
	GDI = Player.GetPlayer("GDI")
	Scrin = Player.GetPlayer("Scrin")
	MissionPlayers = { GDI }
	TimerTicks = 0
	TimerText = ""
	RespawnEnabled = Map.LobbyOption("respawn")
	TimeLimitEnabled = Map.LobbyOption("missiontimer")
	if TimeLimitEnabled == "enabled" then
		TimerTicks = TimeLimit[Difficulty]
	end
	if TimeLimitEnabled == "rush" then
		TimerTicks = DateTime.Minutes(1)
	end
	DefaultText = "\n\n\n\nTiberium stores remaining: "
	sb = "\n---Leaderboard---\n"
	DummyGuy = Player.GetPlayer("DummyGuy")
	ORAMod = "ca"
	coopInfo =
	{
		Mainplayer = GDI,
		MainEnemies = {Scrin},
		Dummyplayer = DummyGuy
	}
	
	Stopspread = true
	CoopInit25(coopInfo)
	CommandoTeam = {Commando}
	TanyaTeam = {Tanya}
	CommandoTeamPlayers = {GDI, Multi2, Multi4}
	TanyaTeamPlayers = {Multi1, Multi3, Multi5}
	ActualCommandoTeamPlayers = {}
	ActualTanyaTeamPlayers = {}
	Utils.Do(CommandoTeamPlayers,function(PID)
		table.insert(ActualCommandoTeamPlayers,PID)
		if PID ~= nil then
			if PID ~= GDI then
				local ExtraCommando = Actor.Create(Commando.Type, true, { Owner = PID, Location = Commando.Location })
				ExtraCommando.Scatter()
				table.insert(CommandoTeam,ExtraCommando)
			end
			if PID.IsLocalPlayer then
				Camera.Position = Commando.CenterPosition
			end
		end
	end)
	local TanyaAssigned = false
	Utils.Do(TanyaTeamPlayers,function(PID)
		table.insert(ActualTanyaTeamPlayers,PID)
		if PID ~= nil then
			if TanyaAssigned == true then
				local ExtraTanya = Actor.Create(Tanya.Type, true, { Owner = PID, Location = Tanya.Location })
				ExtraTanya.Scatter()		
				table.insert(TanyaTeam,ExtraTanya)
			else
				TanyaAssigned = true
				Tanya.Owner = PID
				Tanya.Health = Tanya.MaxHealth
			end
			if PID.IsLocalPlayer then
				Camera.Position = Tanya.CenterPosition
			end
		end
	end)
	AllHeroes = {}

	InitObjectives(GDI)
	InitScrin()

	ObjectiveFindTanya = GDI.AddObjective("Find the other Team.")
	ObjectiveDestroyTiberiumStores = GDI.AddObjective("Destroy all Scrin Tiberium stores.")
	if RespawnEnabled == "disabled" then
		ObjectiveCommandoSurvive = GDI.AddObjective("All Commandos must survive.")
		ObjectiveTanyaSurvive = GDI.AddObjective("All Tanyas must survive.")
	else
		ObjectiveCommandoSurvive = GDI.AddSecondaryObjective("All Commandos must survive.")
		ObjectiveTanyaSurvive = GDI.AddSecondaryObjective("All Tanyas must survive.")
		
		Utils.Do(CommandoTeam,function(UID)
			CommandoDeathTrigger(UID)
			table.insert(AllHeroes,UID)
		end)
		Utils.Do(TanyaTeam,function(UID)
			TanyaDeathTrigger(UID)
			table.insert(AllHeroes,UID)
		end)
		
	end

	Scrin.Resources = Scrin.ResourceCapacity
	
	Utils.Do(AllHeroes,function(UID)
		UID.GrantCondition("difficulty-" .. Difficulty)
	end)
	
	TanyaFound = false
	--[[
	Utils.Do(CommandoTeam,function(UID)
		Media.DisplayMessage("Trigger attached to " .. UID.Type)
		Trigger.OnEnteredProximityTrigger(UID.CenterPosition, WDist.New(7 * 1024), function(a, id)
			Media.DisplayMessage("Detected Unit in Proximity: " .. a.Type)
			if a.Type == "e7" and TanyaFound == false then
				TanyaFound = true
				Trigger.RemoveProximityTrigger(id)
				if #ActualTanyaTeamPlayers == 0 then
					a.Owner = UID.Owner
				end
				GDI.MarkCompletedObjective(ObjectiveFindTanya)
				MediaCA.PlaySound("c_tanya.aud", 2)
			elseif TanyaFound == true then
				Trigger.RemoveProximityTrigger(id)
			end
		end)
	end)
	
	Utils.Do(TanyaTeam,function(UID)
		Media.DisplayMessage("Trigger attached to " .. UID.Type)
		Trigger.OnEnteredProximityTrigger(UID.CenterPosition, WDist.New(7 * 1024), function(a, id)
			Media.DisplayMessage("Detected Unit in Proximity: " .. a.Type)
			if a.Type == "rmbo" and TanyaFound == false then
				TanyaFound = true
				Trigger.RemoveProximityTrigger(id)
				if #ActualTanyaTeamPlayers == 0 then
					UID.Owner = a.Owner
				end
				GDI.MarkCompletedObjective(ObjectiveFindTanya)
				MediaCA.PlaySound("c_tanya.aud", 2)
			elseif TanyaFound == true then
				Trigger.RemoveProximityTrigger(id)
			end
		end)
	end)]]

	Trigger.OnAnyKilled(CommandoTeam, function(self, killer)
		if not CommandoEscaped then
			GDI.MarkFailedObjective(ObjectiveCommandoSurvive)
		end
	end)

	Trigger.OnAnyKilled(TanyaTeam, function(self, killer)
		if not TanyaEscaped then
			GDI.MarkFailedObjective(ObjectiveTanyaSurvive)
		end
	end)

	SiloScore = {}  -- [player] = totalDamage
	Utils.Do(CoopPlayers,function(PID)
		table.insert(SiloScore, {
			Player = PID,
			Score = 0
		})
	end)
	UpdateScoreboard()

	local silos = Scrin.GetActorsByTypes({ "silo.scrin", "silo.scrinblue"})
	Utils.Do(silos, function(a)
		NumSilosRemaining = #silos
		Trigger.OnKilled(a, function(self, killer)
			if TimeLimitEnabled == "rush" then
				TimerTicks = TimerTicks + RushLimit[Difficulty]
			end
			NumSilosRemaining = NumSilosRemaining - 1
			SiloScoring(killer)
			UpdateObjectiveText()
		end)
		--Uncomment this to Debug Ending Triggers
		--[[Trigger.AfterDelay(240,function()
			a.Kill()
		end)]]
	end)

	UpdateObjectiveText()

	if Difficulty == "hard" then
		HealCrate2.Destroy()
		HealCrate3.Destroy()
	end

	if Difficulty == "easy" then
		Prodigy.Destroy()
	end

	Trigger.AfterDelay(DateTime.Minutes(1), function()
		ActivateProdigy()
	end)
end

Camlock = function()
	Utils.Do(CoopPlayers,function(PID)
		local CameraUnits = PID.GetActorsByTypes({"rmbo","e7"})
		if #CameraUnits == 1 and PID.IsLocalPlayer then
			Camera.Position = CameraUnits[1].CenterPosition
		end
	end)
end

Tick = function()
	Camlock()
	OncePerSecondChecks()
	OncePerFiveSecondChecks()
end

CommandoDeathTrigger = function(comID)
	Trigger.OnKilled(comID, function(self, killer)
		local HeroOwner = self.Owner
		Notification("Commando respawns in 30 seconds.")
		Trigger.AfterDelay(DateTime.Seconds(30), function()
			local respawnWaypoint = CommandoSpawn
			if NumSilosRemaining == 0 then
				respawnWaypoint = TanyaSpawn
			end
			local NewCommando = Actor.Create(self.Type, true, { Owner = HeroOwner, Location = respawnWaypoint.Location })
			Beacon.New(HeroOwner, respawnWaypoint.CenterPosition)
			Media.PlaySpeechNotification(HeroOwner, "ReinforcementsArrived")
			NewCommando.GrantCondition("difficulty-" .. Difficulty)
			table.insert(CommandoTeam,NewCommando)
			table.insert(AllHeroes,NewCommando)
			CommandoDeathTrigger(NewCommando)
			NewCommando.Scatter()
		end)
	end)
end

TanyaDeathTrigger = function(tanID)
	Trigger.OnKilled(tanID, function(self, killer)
		local HeroOwner = self.Owner
		Notification("Tanya respawns in 30 seconds.")
		Trigger.AfterDelay(DateTime.Seconds(30), function()
			local respawnWaypoint = TanyaSpawn
			NewTanya = Actor.Create("e7", true, { Owner = HeroOwner, Location = respawnWaypoint.Location })
			Beacon.New(HeroOwner, respawnWaypoint.CenterPosition)
			Media.PlaySpeechNotification(HeroOwner, "ReinforcementsArrived")
			NewTanya.GrantCondition("difficulty-" .. Difficulty)
			table.insert(TanyaTeam,NewTanya)
			table.insert(AllHeroes,NewTanya)
			TanyaDeathTrigger(NewTanya)
			NewTanya.Scatter()
		end)
	end)
end

OncePerSecondChecks = function()
	if TanyaFound == false then
		Utils.Do(CommandoTeam, function(UID)
			if not UID.IsDead then
				local ValidTanyas = Map.ActorsInCircle(UID.CenterPosition, WDist.New(7 * 1024), IsValidTanya)
				if #ValidTanyas > 0 then
					TanyaFound = true
					if #ActualTanyaTeamPlayers == 0 then
						ValidTanyas[1].Owner = UID.Owner
					end
					GDI.MarkCompletedObjective(ObjectiveFindTanya)
					if GDI.IsObjectiveCompleted(ObjectiveDestroyTiberiumStores) then
						DefaultText = "\n\n\n\nExit the facility."
						UpdateObjectiveText()
					end
					MediaCA.PlaySound("c_tanya.aud", 2)
					Utils.Do(CoopPlayers, function(PID)
						Actor.Create("radar.dummy", true, { Owner = PID })
					end)
				end
			end
		end)
	end
	
	if DateTime.GameTime > 1 and DateTime.GameTime % 25 == 0 then
		--[[if TimerTicks > 0 then
			if TimerTicks > 25 then
				TimerTicks = TimerTicks - 25
			else
				TimerTicks = 0
			end
		end]]
		
		if TimerTicks > 0 then
			if TimerTicks > 25 then
				TimerTicks = TimerTicks - 25
				UpdateObjectiveText()
			else
				TimerTicks = 0

				if NumSilosRemaining > 0 then
					if not GDI.IsObjectiveCompleted(ObjectiveDestroyTiberiumStores) then
						GDI.MarkFailedObjective(ObjectiveDestroyTiberiumStores)
					end
				elseif GDI.IsObjectiveCompleted(ObjectiveDestroyTiberiumStores) then
					if not GDI.IsObjectiveCompleted(ObjectiveEscape) then
						GDI.MarkFailedObjective(ObjectiveEscape)
					end
				end
			end
			TimerText = " | Time remaining: " .. UtilsCA.FormatTimeForGameSpeed(TimerTicks)
		end

		if NumSilosRemaining == 0 and not GDI.IsObjectiveCompleted(ObjectiveDestroyTiberiumStores) then
			ObjectiveEscape = GDI.AddObjective("Exit the facility.")

			if GDI.IsObjectiveCompleted(ObjectiveFindTanya) then
				DefaultText = "\n\n\n\nExit the facility."
				UpdateObjectiveText()
			else
				DefaultText = "\n\n\n\nFind the other Team and exit the facility."
				UpdateObjectiveText()
			end

			GDI.MarkCompletedObjective(ObjectiveDestroyTiberiumStores)
			local exitFlare = Actor.Create("flare", true, { Owner = DummyGuy, Location = Exit.Location })
			Beacon.New(DummyGuy, Exit.CenterPosition)
			Media.PlaySpeechNotification(All, "SignalFlare")
			Notification("Signal flare detected.")
			Trigger.OnEnteredProximityTrigger(Exit.CenterPosition, WDist.New(4 * 1024), function(a, id)
				if IsOwnedByCoopPlayer(a) and a.Type ~= "flare" then
					Trigger.AfterDelay(DateTime.Seconds(5), function()
						if not exitFlare.IsDead then
							exitFlare.Destroy()
						end
					end)
					if a.Type == "rmbo" then
						if GDI.IsObjectiveCompleted(ObjectiveFindTanya) then
							CommandoEscaped = true
							if not GDI.IsObjectiveFailed(ObjectiveCommandoSurvive) then
								GDI.MarkCompletedObjective(ObjectiveCommandoSurvive)
							end
							a.Destroy()
						end
					elseif a.Type == "e7" then
						if GDI.IsObjectiveCompleted(ObjectiveFindTanya) then
							TanyaEscaped = true
							if not GDI.IsObjectiveFailed(ObjectiveTanyaSurvive) then
								GDI.MarkCompletedObjective(ObjectiveTanyaSurvive)
							end
							a.Destroy()
						end
					end
				end
			end)

			InitWormholes()
		end

		if CommandoEscaped and TanyaEscaped then
			GDI.MarkCompletedObjective(ObjectiveEscape)
		end
	end
end

OncePerFiveSecondChecks = function()
	if DateTime.GameTime > 1 and DateTime.GameTime % 125 == 0 then
		local silos = Scrin.GetActorsByTypes({ "silo.scrin", "silo.scrinblue"})
		if #silos == 0 and NumSilosRemaining > 0 then
			NumSilosRemaining = 0
		end
	end
end

InitScrin = function()
	local scrinGroundAttackers = Scrin.GetGroundAttackers()

	Utils.Do(scrinGroundAttackers, function(a)
		TargetSwapChance(a, 10)
		CallForHelpOnDamagedOrKilled(a, WDist.New(5120), IsScrinGroundHunterUnit)
	end)
end

SiloScoring = function(killer)
	if IsOwnedByCoopPlayer(killer) then
		--Media.DisplayMessage("Damage Registered. Target: " .. self.Type .. " Owner: " .. self.Owner.Name .. " Damage: " .. damage .. " Attacker: " .. attacker.Owner.Name, "Debug", HSLColor.FromHex("00FF00"))
		local p = killer.Owner
		for _, entry in ipairs(SiloScore) do
			if entry.Player == p then
				entry.Score = entry.Score + 1
				UpdateScoreboard()
				break
			end
		end
		--Media.DisplayMessage("Updating Scoreboard", "Debug", HSLColor.FromHex("00FF00"))
	end
end

UpdateScoreboard = function()
		-- Sort the entries by Score
	table.sort(SiloScore, function(a, b)
		return a.Score > b.Score
	end)

	sb = "\n---Leaderboard---\n"
	local rank = 1
	Utils.Do(SiloScore,function(entry)
	--for _, entry in ipairs(SiloScore) do
		sb = sb .. string.format("%d) %-12s  %8d\n", rank, entry.Player.Name, entry.Score)
		rank = rank + 1
	end)
	--local msg = DefaultText .. NumSilosRemaining .. TimerText .. sb
	--UserInterface.SetMissionText(msg, HSLColor.Yellow)
	
	--UserInterface.SetMissionText("Tiberium stores remaining: " .. NumSilosRemaining , HSLColor.Yellow)
end


UpdateObjectiveText = function()
	local msg = ""
	if NumSilosRemaining > 0 then
		msg = DefaultText .. NumSilosRemaining .. TimerText .. sb
	else
		msg = DefaultText .. TimerText .. sb
	end
	UserInterface.SetMissionText(msg, HSLColor.Yellow)
	--UserInterface.SetMissionText("Tiberium stores remaining: " .. NumSilosRemaining , HSLColor.Yellow)
end

ActivateProdigy = function()
	if not Prodigy.IsDead then
		Notification("We're tracking a powerful Scrin unit. Do not engage!")
		MediaCA.PlaySound("c_powerfulscrin.aud", 2)
		Prodigy.GrantCondition("activated")
		Beacon.New(DummyGuy, Prodigy.CenterPosition)

		if Difficulty == "hard" then
			UpdateProdigyTarget()
		else
			Prodigy.Patrol(ProdigyPatrolPath)
		end
	end
end

UpdateProdigyTarget = function()
	if not Prodigy.IsDead then
		local maintainCurrentTarget = false

		-- if current target has been set and is not dead, determine whether it's close enough to prevent looking for a new target
		if ProdigyCurrentTarget ~= nil and not ProdigyCurrentTarget.IsDead then
			local closeTargets = Map.ActorsInCircle(Prodigy.CenterPosition, WDist.New(30 * 1024), function(t)
				return not t.IsDead and IsOwnedByCoopPlayer(t) and (t.Type == "rmbo" or t.Type == "e7")
			end)
			Utils.Do(closeTargets, function(t)
				if t == ProdigyCurrentTarget then
					maintainCurrentTarget = true
				end
			end)
		end

		-- if current target hasn't been set yet, or it's dead, or the current target isn't close, randomly select a new target
		if not maintainCurrentTarget then
			local possibleTargets = {}
			Utils.Do(CoopPlayers, function(PID)
				table.insert(possibleTargets,PID.GetActorsByTypes({ "rmbo", "e7" }))
			end)
			if #possibleTargets > 0 then
				ProdigyCurrentTarget = Utils.Random(possibleTargets)
				Prodigy.Stop()
				Prodigy.AttackMove(ProdigyCurrentTarget.Location)
			end
		end
	end

	Trigger.AfterDelay(DateTime.Seconds(15), function()
		UpdateProdigyTarget()
	end)
end

InitWormholes = function()
	Actor.Create("wormhole", true, { Owner = Scrin, Location = WormholeSpawn1.Location })
	Actor.Create("wormhole", true, { Owner = Scrin, Location = WormholeSpawn2.Location })
	Actor.Create("wormhole", true, { Owner = Scrin, Location = WormholeSpawn3.Location })
	Trigger.AfterDelay(DateTime.Seconds(8), function()
		ScrinReinforcements()
	end)
end

ScrinReinforcements = function()
	local wormholes = Scrin.GetActorsByType("wormhole")

	Utils.Do(wormholes, function(wormhole)
		local units = { }
		local possibleUnits = { "s1", "s1", "s3", "gscr", "brst2", "s2", "s4" }
		for i=1, 4 do
			table.insert(units, Utils.Random(possibleUnits))
		end

		local units = Reinforcements.Reinforce(Scrin, units, { wormhole.Location }, 5, function(a)
			a.Scatter()
			Trigger.AfterDelay(5, function()
				if not a.IsDead then
					a.AttackMove(Exit.Location)
					IdleHunt(a)
				end
			end)
		end)
	end)

	Trigger.AfterDelay(ScrinReinforcementInterval[Difficulty], ScrinReinforcements)
end
