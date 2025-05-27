
GreeceMainAttackPaths = {
	{ SouthAttackRally.Location, SouthAttack1.Location },
	{ EastAttackRally.Location, EastAttack1.Location, EastAttack2.Location, EastAttack3a.Location },
	{ EastAttackRally.Location, EastAttack1.Location, EastAttack2.Location, EastAttack3b.Location },
}

CruiserPatrolPath = { CruiserPatrol1.Location, CruiserPatrol2.Location, CruiserPatrol3.Location, CruiserPatrol4.Location, CruiserPatrol5.Location, CruiserPatrol6.Location, CruiserPatrol7.Location, CruiserPatrol8.Location, CruiserPatrol7.Location, CruiserPatrol6.Location, CruiserPatrol5.Location, CruiserPatrol4.Location, CruiserPatrol3.Location, CruiserPatrol2.Location }

TraitorUnits = {
	easy = {
		{ Infantry = { "e3", "e1", "e1", "e1", "e3", "e1" }, Vehicles = { "btr" }, MaxTime = DateTime.Minutes(14) },
		{ Infantry = { "e3", "e1", "e1", "e1", "e3", "e1", "shok" }, Vehicles = { "btr", "katy" }, MinTime = DateTime.Minutes(14) },
	},
	normal = {
		{ Infantry = { "e3", "e1", "e1", "e1", "e3", "e1" }, Vehicles = { "3tnk" }, MaxTime = DateTime.Minutes(12) },
		{ Infantry = { "e3", "e1", "e1", "e1", "e3", "e1", "shok" }, Vehicles = { "3tnk", "katy" }, MinTime = DateTime.Minutes(12) },
	},
	hard = {
		{ Infantry = { "e3", "e1", "e1", "e1", "e3", "e1" }, Vehicles = { "3tnk", "btr" }, MaxTime = DateTime.Minutes(10) },
		{ Infantry = { "e3", "e1", "e1", "e1", "e3", "e1", "shok" }, Vehicles = { "3tnk", "v2rl", "ttra" }, MinTime = DateTime.Minutes(10) },
	},
}

ReinforcementsDelay = {
	easy = DateTime.Minutes(3),
	normal = DateTime.Minutes(7),
	hard = DateTime.Minutes(11),
}

Squads = {
	Main = {
		Delay = {
			easy = DateTime.Seconds(270),
			normal = DateTime.Seconds(210),
			hard = DateTime.Seconds(150)
		},
		AttackValuePerSecond = {
			easy = { Min = 15, Max = 35, RampDuration = DateTime.Minutes(16) },
			normal = { Min = 34, Max = 68, RampDuration = DateTime.Minutes(14) },
			hard = { Min = 52, Max = 105, RampDuration = DateTime.Minutes(12) },
		},
		FollowLeader = true,
		ProducerActors = { Infantry = { AlliedSouthBarracks }, Vehicles = { AlliedSouthFactory } },
		Units = AdjustCompositionsForDifficulty(UnitCompositions.Allied),
		AttackPaths = GreeceMainAttackPaths,
	},
	Traitor = {
		Delay = {
			easy = DateTime.Minutes(5),
			normal = DateTime.Minutes(4),
			hard = DateTime.Minutes(3)
		},
		AttackValuePerSecond = {
			easy = { Min = 5, Max = 15, RampDuration = DateTime.Minutes(16) },
			normal = { Min = 16, Max = 32, RampDuration = DateTime.Minutes(14) },
			hard = { Min = 28, Max = 55, RampDuration = DateTime.Minutes(12) },
		},
		FollowLeader = true,
		ProducerActors = { Infantry = { TraitorBarracks }, Vehicles = { TraitorFactory } },
		Units = TraitorUnits,
		AttackPaths = GreeceMainAttackPaths,
	},
	Air = {
		Delay = {
			easy = DateTime.Minutes(13),
			normal = DateTime.Minutes(12),
			hard = DateTime.Minutes(11)
		},
		AttackValuePerSecond = {
			easy = { Min = 7, Max = 7 },
			normal = { Min = 14, Max = 14 },
			hard = { Min = 21, Max = 21 },
		},
		ProducerTypes = { Aircraft = { "hpad" } },
		Units = {
			easy = {
				{ Aircraft = { "heli" } }
			},
			normal = {
				{ Aircraft = { "heli", "heli" } },
				{ Aircraft = { "harr" } }
			},
			hard = {
				{ Aircraft = { "heli", "heli", "heli" } },
				{ Aircraft = { "harr", "harr" } }
			}
		},
	}
}

WorldLoaded = function()
	USSR = Player.GetPlayer("USSR")
	Greece = Player.GetPlayer("Greece")
	Traitor = Player.GetPlayer("Traitor")
	USSRAbandoned = Player.GetPlayer("USSRAbandoned")
	MissionPlayers = { USSR }
	TimerTicks = 0
	
	DummyGuy = Player.GetPlayer("DummyGuy")
	DummyGuy.Cash = 0
	ORAMod = "ca"
	coopInfo =
	{
		Mainplayer = USSR,
		MainEnemies = {Greece, Traitor},
		Dummyplayer = DummyGuy
	}
	
	Stopspread = true
	CoopInit25(coopInfo)
	
	--Override Sharing options
	BaseShared = true
	TechShared = true
	MoneyShareOverride = 100
	
	if #CoopPlayers >= 2 then
		Actor17.Owner = CoopPlayers[2]
	end
	
	AllBoris = {Boris}
	
	Utils.Do(CoopPlayers,function(PID)
		if PID ~= CoopPlayers[1] then
			local ExtraBoris = Actor.Create(Boris.Type, true, { Owner = PID, Location = Boris.Location })
			ExtraBoris.Scatter()
			table.insert(AllBoris, ExtraBoris)
			if PID ~= CoopPlayers[2] then
				local ExtraEngi = Actor.Create(Actor17.Type, true, { Owner = PID, Location = Actor17.Location })
				ExtraEngi.Scatter()
			end
		end
	end)
	Stopspread = false

	Camera.Position = PlayerStart.CenterPosition

	InitObjectives(USSR)
	AdjustPlayerStartingCashForDifficulty()
	StartCashSpread(2000)
	InitGreece()

	HaloDropper = Actor.Create("powerproxy.halodrop", false, { Owner = DummyGuy })
	ShockDropper = Actor.Create("powerproxy.shockdrop", false, { Owner = DummyGuy })

	ObjectiveKillTraitor = USSR.AddObjective("Find and kill the traitor General Yegorov.")
	ObjectiveFindSovietBase = USSR.AddSecondaryObjective("Take control of abandoned Soviet base.")

	AbandonedHalo.ReturnToBase(AbandonedHelipad)
	SetupRefAndSilosCaptureCredits(Traitor)

	if Difficulty == "hard" then
		Cruiser.Patrol(CruiserPatrolPath)
		AbandonedAirfield.Destroy()
		--local traitorConyardLocation = TraitorConyard.Location
		--TraitorConyard.Destroy()
		--Actor.Create("weap", true, { Owner = Traitor, Location = traitorConyardLocation })
	else
		Cruiser.Destroy()
		HardOnlyMGG.Destroy()
		HardOnlyTurret1.Destroy()
		HardOnlyTurret2.Destroy()
		HardOnlyTurret3.Destroy()
		HardOnlyTurret4.Destroy()
		HardOnlyTurret5.Destroy()
		HardOnlyGapGenerator.Destroy()
		HardOnlyTeslaCoil.Destroy()
		HardOnlyCryoLauncher.Destroy()
	end

	Trigger.OnCapture(AbandonedHelipad, function(self, captor, oldOwner, newOwner)
		if IsOwnedByCoopPlayer(captor) then
			AbandonedHalo.Owner = captor.Owner

			if Difficulty ~= "hard" then
				Trigger.AfterDelay(DateTime.Seconds(5), function()
					local islandFlare = Actor.Create("flare", true, { Owner = DummyGuy, Location = ReinforcementsDestination.Location })
					Trigger.AfterDelay(DateTime.Seconds(10), islandFlare.Destroy)
					Beacon.New(DummyGuy, ReinforcementsDestination.CenterPosition)
					Media.PlaySpeechNotification(All, "SignalFlare")
				end)
			end
		end
	end)

	Trigger.OnEnteredProximityTrigger(GuardsReveal1.CenterPosition, WDist.New(11 * 1024), function(a, id)
		if IsOwnedByCoopPlayer(a) and not a.HasProperty("Land") then
			Trigger.RemoveProximityTrigger(id)
			local camera = Actor.Create("smallcamera", true, { Owner = USSR, Location = GuardsReveal1.Location })
			Trigger.AfterDelay(DateTime.Seconds(5), function()
				camera.Destroy()
			end)
		end
	end)

	Trigger.OnEnteredProximityTrigger(TraitorTechCenter.CenterPosition, WDist.New(9 * 1024), function(a, id)
		if IsOwnedByCoopPlayer(a) and a.Type ~= "smig" then
			Trigger.RemoveProximityTrigger(id)
			TraitorTechCenterDiscovered()
		end
	end)

	Trigger.OnEnteredProximityTrigger(AbandonedBaseCenter.CenterPosition, WDist.New(10 * 1024), function(a, id)
		if IsOwnedByCoopPlayer(a) and not a.HasProperty("Land") then
			Trigger.RemoveProximityTrigger(id)
			AbandonedBaseDiscovered()
		end
	end)

	Trigger.OnAllKilled(AllBoris, function()
		Trigger.AfterDelay(DateTime.Seconds(1), function()
			Notification("Boris has been killed.")
			MediaCA.PlaySound("r2_boriskilled.aud", 2)
		end)
	end)

	Trigger.OnKilled(Bodyguard1, function(self, killer)
		Trigger.AfterDelay(DateTime.Seconds(4), function()
			if not TraitorGeneral.IsDead and TraitorGeneral.IsInWorld then
				TraitorGeneral.Move(TraitorGeneralSafePoint.Location)
			end
		end)
	end)

	Trigger.OnKilled(TraitorGeneral, function(self, killer)
		USSR.MarkCompletedObjective(ObjectiveKillTraitor)
		MediaCA.PlaySound("r2_yegeroveliminated.aud", 2)
	end)

	Trigger.OnAllKilled({ TraitorSAM1, TraitorSAM2 }, function()
		Media.PlaySpeechNotification(All, "ReinforcementsArrived")
		HaloDropper.TargetParatroopers(EastParadrop1.CenterPosition, Angle.West)

		Trigger.AfterDelay(DateTime.Seconds(2), function()
			ShockDropper.TargetParatroopers(EastParadrop2.CenterPosition, Angle.West)
		end)

		Trigger.AfterDelay(DateTime.Seconds(4), function()
			HaloDropper.TargetParatroopers(EastParadrop3.CenterPosition, Angle.West)
		end)
	end)

	Trigger.OnCapture(TraitorConyard, function(self, captor, oldOwner, newOwner)
		Trigger.AfterDelay(DateTime.Minutes(1), function()
			InitAlliedAttacks()
		end)
	end)

	Trigger.OnCapture(TraitorTechCenter, function(self, captor, oldOwner, newOwner)
		if IsOwnedByCoopPlayer(captor) then
			if ObjectiveCaptureTraitorTechCenter == nil then
				ObjectiveCaptureTraitorTechCenter = USSR.AddSecondaryObjective("Capture Traitor's Tech Center.")
			end
			USSR.MarkCompletedObjective(ObjectiveCaptureTraitorTechCenter)
			Trigger.AfterDelay(DateTime.Seconds(2), function()
				Notification("The traitor's tech center is ours! Let us rain down V3 rockets on the traitor, or perhaps crush him under the tracks of a Mammoth Tank!")
			end)
		end
	end)

	Trigger.OnKilled(TraitorTechCenter, function(self, killer)
		if ObjectiveCaptureTraitorTechCenter ~= nil and not USSR.IsObjectiveCompleted(ObjectiveCaptureTraitorTechCenter) then
			USSR.MarkFailedObjective(ObjectiveCaptureTraitorTechCenter)
		end
	end)

	Trigger.OnKilled(TraitorHQ, function(self, killer)
		TraitorHQKilledOrCaptured()
	end)

	Trigger.OnCapture(TraitorHQ, function(self, captor, oldOwner, newOwner)
		TraitorHQKilledOrCaptured()
	end)
end

Tick = function()

	Utils.Do(CoopPlayers,function(PID)
		if PID ~= USSR and #PID.GetActorsByType("proc") == 0 and #PID.GetActorsByType("harv") > 0 then
			Utils.Do(PID.GetActorsByType("harv"),function(UID)
				UID.Owner =	USSR
			end)
		end
		Utils.Do(PID.GetActorsByType("oilb"),function(UID)
			UID.Owner = DummyGuy
		end)
	end)
	if DummyGuy.Cash >= #CoopPlayers then
		DummyGuy.Cash = DummyGuy.Cash - #CoopPlayers
		Utils.Do(CoopPlayers,function(PID)
			PID.Cash = PID.Cash + 1
		end)
	end
	OncePerSecondChecks()
	OncePerFiveSecondChecks()
end

OncePerSecondChecks = function()
	if DateTime.GameTime > 1 and DateTime.GameTime % 25 == 0 then
		Greece.Resources = Greece.ResourceCapacity - 500
		Traitor.Resources = Traitor.ResourceCapacity - 500

		if TimerTicks > 0 then
			if TimerTicks > 25 then
				TimerTicks = TimerTicks - 25
			else
				TimerTicks = 0
			end
		end
	end
end

OncePerFiveSecondChecks = function()
	if DateTime.GameTime > 1 and DateTime.GameTime % 125 == 0 then
		UpdatePlayerBaseLocations()

		if CoopTeamHasNoRequiredUnits() then
			if ObjectiveKillTraitor ~= nil and not USSR.IsObjectiveCompleted(ObjectiveKillTraitor) then
				USSR.MarkFailedObjective(ObjectiveKillTraitor)
			end
		end
	end
end

InitGreece = function()
	if Difficulty == "easy" then
		RebuildExcludes.Greece = { Types = { "gun", "pbox", "pris" } }
	end

	AutoRepairAndRebuildBuildings(Greece, 15)
	SetupRefAndSilosCaptureCredits(Greece)
	AutoReplaceHarvesters(Greece)
	InitAiUpgrades(Greece)
	InitAiUpgrades(Traitor)

	Actor.Create("ai.unlimited.power", true, { Owner = Traitor })

	local alliedGroundAttackers = Greece.GetGroundAttackers()

	Utils.Do(alliedGroundAttackers, function(a)
		TargetSwapChance(a, 10)
		CallForHelpOnDamagedOrKilled(a, WDist.New(5120), IsGreeceGroundHunterUnit)
	end)

	local traitorGroundAttackers = Traitor.GetGroundAttackers()

	Utils.Do(traitorGroundAttackers, function(a)
		TargetSwapChance(a, 10)
		CallForHelpOnDamagedOrKilled(a, WDist.New(5120), IsGroundHunterUnit)
	end)
end

TraitorTechCenterDiscovered = function()
	if IsTraitorTechCenterDiscovered then
		return
	end

	IsTraitorTechCenterDiscovered = true

	local traitorTechCenterFlare = Actor.Create("flare", true, { Owner = DummyGuy, Location = TraitorTechCenterFlare.Location })
	Trigger.AfterDelay(DateTime.Seconds(10), traitorTechCenterFlare.Destroy)
	Beacon.New(DummyGuy, TraitorTechCenterFlare.CenterPosition)
	Media.PlaySpeechNotification(All, "SignalFlare")

	if ObjectiveCaptureTraitorTechCenter == nil then
		ObjectiveCaptureTraitorTechCenter = USSR.AddSecondaryObjective("Capture Traitor's Tech Center.")
		if TraitorTechCenter.IsDead then
			USSR.MarkFailedObjective(ObjectiveCaptureTraitorTechCenter)
		end
	end
end

AbandonedBaseDiscovered = function()
	if IsAbandonedBaseDiscovered then
		return
	end

	IsAbandonedBaseDiscovered = true

	-- Yegorov retreats to HQ
	if TraitorGeneral.IsInWorld then
		TraitorGeneral.Destroy()
	end

	local baseBuildings = Map.ActorsInBox(AbandonedBaseTopLeft.CenterPosition, AbandonedBaseBottomRight.CenterPosition, function(a)
		return a.Owner == USSRAbandoned
	end)

	Utils.Do(baseBuildings, function(a)
		a.Owner = USSR
	end)

	USSR.MarkCompletedObjective(ObjectiveFindSovietBase)

	Trigger.AfterDelay(DateTime.Seconds(10), function()
		TraitorTechCenterDiscovered()
	end)

	InitAlliedAttacks()

	Trigger.AfterDelay(1, function()
		Actor.Create("QueueUpdaterDummy", true, { Owner = USSR })
	end)

	Trigger.AfterDelay(ReinforcementsDelay[Difficulty], function()
		Media.PlaySpeechNotification(All, "ReinforcementsArrived")
		Beacon.New(DummyGuy, ReinforcementsDestination.CenterPosition)
		local reinforcements = { "4tnk", "4tnk", "v3rl", "v3rl", "btr" }
		if Difficulty == "hard" then
			reinforcements = { "4tnk", "4tnk", "v2rl", "btr" }
		end
		Reinforcements.Reinforce(DummyGuy, reinforcements, { ReinforcementsSpawn.Location, ReinforcementsDestination.Location }, 75)
	end)

	Trigger.AfterDelay(DateTime.Seconds(30), function()
		Media.PlaySpeechNotification(All, "ReinforcementsArrived")
		ShockDropper.TargetParatroopers(AbandonedBaseCenter.CenterPosition, Angle.SouthWest)
	end)
end

TraitorHQKilledOrCaptured = function()
	-- Spawn Yegorov (unless he's outside already)
	if not TraitorGeneral.IsInWorld then
		local traitorGeneral = Actor.Create("gnrl", true, { Owner = Traitor, Location = TraitorHQSpawn.Location })
		traitorGeneral.Move(TraitorGeneralSafePoint.Location)
		Trigger.OnKilled(traitorGeneral, function(self, killer)
			MediaCA.PlaySound("r2_yegeroveliminated.aud", 2)
			Trigger.AfterDelay(DateTime.Seconds(2), function()
				USSR.MarkCompletedObjective(ObjectiveKillTraitor)
			end)
		end)
	end
end

InitAlliedAttacks = function()
	if not AttacksStarted then
		AttacksStarted = true
		Trigger.AfterDelay(Squads.Main.Delay[Difficulty], function()
			InitAttackSquad(Squads.Main, Greece)
		end)

		Trigger.AfterDelay(Squads.Traitor.Delay[Difficulty], function()
			InitAttackSquad(Squads.Traitor, Traitor)
		end)

		Trigger.AfterDelay(Squads.Air.Delay[Difficulty], function()
			InitAirAttackSquad(Squads.Air, Greece, Nod, { "harv", "v2rl", "apwr", "tsla", "ttra", "v3rl", "mig", "hind", "suk", "suk.upg", "kiro", "apoc" })
		end)
	end
end
