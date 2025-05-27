
ShardLaunchers = { Shard1, Shard2, Shard3, Shard4, Shard5, Shard6 }

AdjustedNodCompositions = AdjustCompositionsForDifficulty(UnitCompositions.Nod)

Squads = {
	Main = {
		AttackValuePerSecond = {
			normal = { Min = 15, Max = 15 },
			hard = { Min = 25, Max = 25 },
		},
		ActiveCondition = function()
			return HasConyardAcrossRiver()
		end,
		DispatchDelay = DateTime.Seconds(15),
		FollowLeader = true,
		ProducerTypes = { Infantry = BarracksTypes, Vehicles = FactoryTypes },
		Units = AdjustedNodCompositions,
	},
	NodAir = {
		Delay = {
			easy = DateTime.Minutes(11),
			normal = DateTime.Minutes(8),
			hard = DateTime.Minutes(5)
		},
		AttackValuePerSecond = {
			easy = { Min = 7, Max = 7 },
			normal = { Min = 14, Max = 14 },
			hard = { Min = 21, Max = 21 },
		},
		ProducerTypes = { Aircraft = { "hpad.td" } },
		Units = {
			easy = {
				{ Aircraft = { "apch" } }
			},
			normal = {
				{ Aircraft = { "apch", "apch" } },
				{ Aircraft = { "venm", "venm" } },
				{ Aircraft = { "scrn" } },
				{ Aircraft = { "rah" } }
			},
			hard = {
				{ Aircraft = { "apch", "apch", "apch" } },
				{ Aircraft = { "venm", "venm", "venm" } },
				{ Aircraft = { "scrn", "scrn" } },
				{ Aircraft = { "rah", "rah" } }
			}
		},
	}
}

WorldLoaded = function()
    GDI = Player.GetPlayer("GDI")
	Scrin = Player.GetPlayer("Scrin")
	Nod = Player.GetPlayer("Nod")
    MissionPlayers = { GDI }
	
	DummyGuy = Player.GetPlayer("DummyGuy")
	ORAMod = "ca"
	coopInfo =
	{
		Mainplayer = GDI,
		MainEnemies = {Scrin, Nod},
		Dummyplayer = DummyGuy
	}
	
	CoopInit25(coopInfo)
    Camera.Position = PlayerStart.CenterPosition

	InitObjectives(GDI)
	AdjustPlayerStartingCashForDifficulty()
	StartCashSpread(3000)
	InitNod()
	UpdateMissionText()

	ObjectiveDestroyShardLaunchers = GDI.AddObjective("Destroy Scrin Shard Launchers.")
    ObjectiveCaptureComms = GDI.AddObjective("Locate and capture Nod Communications Center.")

    Trigger.OnAllKilled(ShardLaunchers, function()
        InitMcv()
		GDI.MarkCompletedObjective(ObjectiveDestroyShardLaunchers)
    end)

	Utils.Do(ShardLaunchers, function(s)
		Trigger.OnKilled(s, function(self, killer)
			UpdateMissionText()
		end)
	end)

    Trigger.OnCapture(NodCommsCenter, function(self, captor, oldOwner, newOwner)
        if IsOwnedByCoopPlayer(captor) then
            GDI.MarkCompletedObjective(ObjectiveCaptureComms)
        end
    end)

	Trigger.OnKilled(NodCommsCenter, function(self, killer)
		if not GDI.IsObjectiveCompleted(ObjectiveCaptureComms) then
			GDI.MarkFailedObjective(ObjectiveCaptureComms)
		end
	end)
end

Tick = function()
	OncePerSecondChecks()
	OncePerFiveSecondChecks()
end

OncePerSecondChecks = function()
	if DateTime.GameTime > 1 and DateTime.GameTime % 25 == 0 then
		Nod.Resources = Nod.ResourceCapacity - 500

		if CoopTeamHasNoRequiredUnits() then
			if not GDI.IsObjectiveCompleted(ObjectiveCaptureComms) then
				GDI.MarkFailedObjective(ObjectiveCaptureComms)
			end
		end
	end
end

OncePerFiveSecondChecks = function()
	if DateTime.GameTime > 1 and DateTime.GameTime % 125 == 0 then
		UpdatePlayerBaseLocations()

		if Difficulty ~= "easy" and not NodGroundAttacksStarted and HasConyardAcrossRiver() then
			NodGroundAttacksStarted = true
			InitAttackSquad(Squads.Main, Nod)
		end
	end
end

UpdateMissionText = function()
	ShardLaunchersRemaining = #Utils.Where(ShardLaunchers, function(s) return not s.IsDead end)

	if ShardLaunchersRemaining > 0 then
		UserInterface.SetMissionText("Shard Launchers remaining: " .. ShardLaunchersRemaining, HSLColor.Yellow)
	else
		UserInterface.SetMissionText("")
	end
end

InitNod = function()
	AutoRepairBuildings(Nod)
	AutoRepairAndRebuildBuildings(Nod)
	SetupRefAndSilosCaptureCredits(Nod)
	AutoReplaceHarvesters(Nod)
	InitAiUpgrades(Nod)

	local nodGroundAttackers = Nod.GetGroundAttackers()

	Utils.Do(nodGroundAttackers, function(a)
		TargetSwapChance(a, 10)
		CallForHelpOnDamagedOrKilled(a, WDist.New(5120), IsNodGroundHunterUnit)
	end)

	Trigger.AfterDelay(Squads.NodAir.Delay[Difficulty], function()
		Utils.Do(CoopPlayers,function(PID)
			InitAirAttackSquad(Squads.NodAir, Nod, PID)
		end)
	end)
end

InitMcv = function()
	Media.PlaySpeechNotification(All, "ReinforcementsArrived")
	Notification("Reinforcements have arrived.")
    local exitPath =  { CarryallSpawn.Location }
	local MCVIterator = 0
	if #CoopPlayers > 1 then
		Tip("Building space on this island is limited. Let one player build a naval yard and transport your MCVs to the mainland.")
	end
	Utils.Do(MCVPlayers,function(PID)
		local entryPath = { CarryallSpawn.Location, CarryallDest.Location + CVec.New((MCVIterator-3),(MCVIterator-3)) }
		ReinforcementsCA.ReinforceWithTransport(PID, "ocar.amcv", nil, entryPath, exitPath)
		MCVIterator = MCVIterator + 2
	end)
end

HasConyardAcrossRiver = function()
	local conyards = {}
	Utils.Do(CoopPlayers,function(PID)
		Utils.Do(PID.GetActorsByType("afac"),function(UID)
			table.insert(conyards,UID)
		end)
	end)

	local conyardsAcrossRiver = Utils.Where(conyards, function(c)
		return IsOwnedByCoopPlayer(c) and c.Location.X > 34 and c.Location.Y > 72
	end)

	return #conyardsAcrossRiver > 0
end
