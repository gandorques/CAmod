IonCannonEnabledTime = {
	easy = DateTime.Seconds((60 * 40) + 48),
	normal = DateTime.Seconds((60 * 25) + 48),
	hard = DateTime.Seconds((60 * 10) + 48),
}

AdjustedGDICompositions = AdjustCompositionsForDifficulty(UnitCompositions.GDI)

Squads = {
	Main = {
		InitTimeAdjustment = -DateTime.Minutes(3),
		Delay = {
			easy = DateTime.Minutes(7),
			normal = DateTime.Minutes(5),
			hard = DateTime.Minutes(3),
		},
		AttackValuePerSecond = {
			easy = { Min = 12, Max = 25 },
			normal = { Min = 25, Max = 50 },
			hard = { Min = 40, Max = 80 },
		},
		FollowLeader = true,
		ProducerActors = { Infantry = { GDIBarracks1 }, Vehicles = { GDIFactory1 } },
		ProducerTypes = { Infantry = { "tent" }, Vehicles = { "weap" } },
		Units = AdjustedGDICompositions,
		AttackPaths = {
			-- set on init
		},
	},
	Forward = {
		InitTimeAdjustment = -DateTime.Minutes(2),
		Delay = {
			easy = DateTime.Minutes(4),
			normal = DateTime.Minutes(3),
			hard = DateTime.Minutes(2),
		},
		AttackValuePerSecond = {
			easy = { Min = 12, Max = 25 },
			normal = { Min = 25, Max = 50 },
			hard = { Min = 40, Max = 80 },
		},
		FollowLeader = true,
		ProducerActors = { Infantry = { GDIBarracks2 }, Vehicles = { GDIFactory2 } },
		ProducerTypes = { Infantry = { "tent" }, Vehicles = { "weap" } },
		Units = AdjustedGDICompositions,
		AttackPaths = {
			-- set on init
		},
	},
	GDIAir = {
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
		ProducerTypes = { Aircraft = { "afld.gdi", "hpad.td" } },
		Units = {
			easy = {
				{ Aircraft = { "orca" } },
				{ Aircraft = { "orcb" } },
			},
			normal = {
				{ Aircraft = { "orca", "orca" } },
				{ Aircraft = { "a10" } },
				{ Aircraft = { "a10.gau" } },
				{ Aircraft = { "orcb" } },
				{ Aircraft = { "auro" } },
			},
			hard = {
				{ Aircraft = { "orca", "orca", "orca" } },
				{ Aircraft = { "a10", "a10" } },
				{ Aircraft = { "a10.gau", "a10.gau" } },
				{ Aircraft = { "orcb", "orcb" } },
				{ Aircraft = { "auro", "auro" } },
			}
		},
	},
	AntiCyborgAir = {
		Delay = {
			hard = DateTime.Minutes(7)
		},
		ActiveCondition = function()
			local AllCoopActors = 0
			Utils.Do(CoopPlayers,function(PID)
				AllCoopActors = AllCoopActors + #PID.GetActorsByTypes({ "rmbc", "enli", "reap", "avtr" })
			end)
			return AllCoopActors > 16
		end,
		AttackValuePerSecond = {
			hard = { Min = 35, Max = 35 },
		},
		ProducerTypes = { Aircraft = { "afld.gdi", "hpad.td" } },
		Units = {
			hard = {
				{ Aircraft = { "orcb", "orcb", "orcb", "orcb", "orcb", "orcb" } },
			}
		},
	}
}

-- Setup and Tick

WorldLoaded = function()
	Nod = Player.GetPlayer("Nod")
	Nod2 = Player.GetPlayer("Nod2")
	Nod3 = Player.GetPlayer("Nod3")
	GDI = Player.GetPlayer("GDI")
	Neutral = Player.GetPlayer("Neutral")
	MissionPlayers = { Nod }
	TimerTicks = 0
	
	DummyGuy = Player.GetPlayer("DummyGuy")
	DummyGuy.Cash = 0
	ORAMod = "ca"
	coopInfo =
	{
		Mainplayer = Nod,
		MainEnemies = {GDI},
		Dummyplayer = DummyGuy
	}
	
	CoopInit25(coopInfo)
	Utils.Do(MCVPlayers,function(PID)
		if PID ~= Nod then
			local ExtraMCV = Actor.Create(Actor435.Type, true, { Owner = PID, Location = Actor435.Location })
			ExtraMCV.Scatter()
		end
	end)

	Camera.Position = PlayerStart.CenterPosition

	InitObjectives(Nod)
	AdjustPlayerStartingCashForDifficulty()
	if Nod.Cash > 2500 then
		StartCashSpread(2500)
	end
	
	InitGDI()
	InitNod()
	
	NodRadarProviders = {}
	Utils.Do(CoopPlayers,function(PID)
		local PlayerRadarProvider = Actor.Create("radar.dummy", true, { Owner = PID })
		table.insert(NodRadarProviders, PlayerRadarProvider)
	end)

	ObjectiveReinforce = Nod.AddObjective("Reinforce one of the two Nod bases.")

	local eastAttackTriggerCells = {}
	for x = 9, 18 do
		local cell = CPos.New(x, 78)
		table.insert(eastAttackTriggerCells, cell)
	end

	local westAttackTriggerCells = {}
	for x = 47, 56 do
		local cell = CPos.New(x, 101)
		table.insert(westAttackTriggerCells, cell)
	end

	Trigger.OnEnteredFootprint(eastAttackTriggerCells, function(a, id)
		if IsOwnedByCoopPlayer(a) then
			Trigger.RemoveProximityTrigger(id)
			InitGDIEast()
		end
	end)

	Trigger.OnEnteredFootprint(westAttackTriggerCells, function(a, id)
		if IsOwnedByCoopPlayer(a) then
			Trigger.RemoveProximityTrigger(id)
			InitGDIWest()
		end
	end)

	Trigger.OnEnteredProximityTrigger(WestBaseCenter.CenterPosition, WDist.New(15 * 1024), function(a, id)
		if IsOwnedByCoopPlayer(a) then
			Trigger.RemoveProximityTrigger(id)
			FlipWestBase()
		end
	end)

	Trigger.OnEnteredProximityTrigger(EastBaseCenter.CenterPosition, WDist.New(15 * 1024), function(a, id)
		if IsOwnedByCoopPlayer(a) then
			Trigger.RemoveProximityTrigger(id)
			FlipEastBase()
		end
	end)

	Banshee1.ReturnToBase(Helipad1)
	Banshee2.ReturnToBase(Helipad2)
end

Tick = function()
	OncePerSecondChecks()
	OncePerFiveSecondChecks()
	OncePerThirtySecondChecks()
end

OncePerSecondChecks = function()
	if DateTime.GameTime > 1 and DateTime.GameTime % 25 == 0 then
		GDI.Resources = GDI.ResourceCapacity - 500

		if CoopTeamHasNoRequiredUnits() then
			if not Nod.IsObjectiveCompleted(ObjectiveReinforce) then
				Nod.MarkFailedObjective(ObjectiveReinforce)
			end

			if ObjectiveDestroyGDI ~= nil and not Nod.IsObjectiveCompleted(ObjectiveDestroyGDI) then
				Nod.MarkCompletedObjective(ObjectiveDestroyGDI)
			end
		end

		if not Nod.IsObjectiveCompleted(ObjectiveReinforce) then
			if not PlayerHasBuildings(Nod2) and not PlayerHasBuildings(Nod3) then
				Nod.MarkFailedObjective(ObjectiveReinforce)
			end
		end
	end
end

OncePerFiveSecondChecks = function()
	if DateTime.GameTime > 1 and DateTime.GameTime % 125 == 0 then
		UpdatePlayerBaseLocations()

		if ObjectiveDestroyGDI ~= nil and not PlayerHasBuildings(GDI) then
			Nod.MarkCompletedObjective(ObjectiveDestroyGDI)
		end
	end
end

OncePerThirtySecondChecks = function()
	if DateTime.GameTime > 1 and DateTime.GameTime % DateTime.Seconds(30) == 0 then
		CalculatePlayerCharacteristics()
	end
end

-- Functions

InitNod = function()
	local nod2Forces = Nod2.GetGroundAttackers()
	Utils.Do(nod2Forces, function(a)
		CallForHelpOnDamagedOrKilled(a, WDist.New(10240), IsGroundHunterUnit, function(p) return true end)
	end)
	local nod3Forces = Nod3.GetGroundAttackers()
	Utils.Do(nod3Forces, function(a)
		CallForHelpOnDamagedOrKilled(a, WDist.New(10240), IsGroundHunterUnit, function(p) return true end)
	end)
end

InitGDI = function()
	AutoRepairAndRebuildBuildings(GDI)
	SetupRefAndSilosCaptureCredits(GDI)
	AutoReplaceHarvesters(GDI)
	AutoRebuildConyards(GDI)

	local gdiGroundAttackers = GDI.GetGroundAttackers()

	Utils.Do(gdiGroundAttackers, function(a)
		TargetSwapChance(a, 10)
		CallForHelpOnDamagedOrKilled(a, WDist.New(5120), IsGDIGroundHunterUnit)
	end)

	Trigger.AfterDelay(DateTime.Minutes(8), function()
		Actor.Create("ai.minor.superweapons.enabled", true, { Owner = GDI })
	end)

	Trigger.AfterDelay(IonCannonEnabledTime[Difficulty], function()
		Actor.Create("ai.superweapons.enabled", true, { Owner = GDI })
	end)
end

InitGDIWest = function()
	if GDIEastInitialized or GDIWestInitialized then
		return
	end

	GDIWestInitialized = true

	InitWestAttackers()

	-- main attacks will head to east base

	Squads.Main.AttackPaths = {
		{ EastRally1.Location },
		{ EastRally2.Location },
		{ EastRally3.Location },
	}

	Squads.Forward.AttackPaths = {
		{ EastRally2.Location },
		{ EastRally4.Location },
	}

	InitGDIAttacks()
end

InitWestAttackers = function()
	local westAttackers = Utils.Where(Map.ActorsInCircle(GDIWestAttack.CenterPosition, WDist.New(7 * 1024)), function(a)
		return a.HasProperty("AttackMove")
	end)

	Utils.Do(westAttackers, function(a)
		if a.Owner == GDI and not a.IsDead then
			local dest = CPos.New(WestBaseCenter.Location.X + Utils.RandomInteger(-5,5), WestBaseCenter.Location.Y + Utils.RandomInteger(-5,5))
			a.AttackMove(dest)
			a.Hunt()
			Trigger.AfterDelay(DateTime.Seconds(75), function()
				if not a.IsDead then
					a.Stop()
					Trigger.AfterDelay(DateTime.Minutes(1), function()
						if not a.IsDead then
							a.AttackMove(EastRally4.Location)
							if Difficulty == "hard" then
								Trigger.AfterDelay(DateTime.Minutes(1), function()
									if not a.IsDead then
										a.Hunt()
									end
								end)
							end
						end
					end)
				end
			end)
		end
	end)

	local westDefenders = Nod3.GetGroundAttackers()
	Utils.Do(westDefenders, function(a)
		if not a.IsDead then
			a.Hunt()
		end
	end)
end

InitGDIEast = function()
	if GDIEastInitialized or GDIWestInitialized then
		return
	end

	GDIEastInitialized = true

	InitEastAttackers()

	-- main attacks will head to west base

	Squads.Main.AttackPaths = {
		{ WestRally1.Location },
		{ WestRally2.Location },
		{ WestRally3.Location },
		{ WestRally4.Location, WestRally1.Location },
	}

	Squads.Forward.AttackPaths = {
		{ WestRally1.Location },
		{ WestRally2.Location },
		{ WestRally3.Location },
	}

	InitGDIAttacks()
end

InitEastAttackers = function()
	local eastAttackers = Utils.Where(Map.ActorsInCircle(GDIEastAttack.CenterPosition, WDist.New(7 * 1024)), function(a)
		return a.HasProperty("AttackMove")
	end)

	Utils.Do(eastAttackers, function(a)
		if a.Owner == GDI and not a.IsDead then
			local dest = CPos.New(EastBaseCenter.Location.X + Utils.RandomInteger(-5,5), EastBaseCenter.Location.Y + Utils.RandomInteger(-5,5))
			a.AttackMove(dest)
			a.Hunt()
			Trigger.AfterDelay(DateTime.Seconds(75), function()
				if not a.IsDead then
					a.Stop()
					Trigger.AfterDelay(DateTime.Minutes(1), function()
						if not a.IsDead then
							a.AttackMove(WestRally1.Location)
							if Difficulty == "hard" then
								Trigger.AfterDelay(DateTime.Minutes(1), function()
									if not a.IsDead then
										a.Hunt()
									end
								end)
							end
						end
					end)
				end
			end)
		end
	end)

	local eastDefenders = Nod2.GetGroundAttackers()
	Utils.Do(eastDefenders, function(a)
		if not a.IsDead then
			a.Hunt()
		end
	end)
end

FlipEastBase = function()
    if not Nod.IsObjectiveCompleted(ObjectiveReinforce) then
		Utils.Do(CoopPlayers,function(PID)
			PID.Cash = PID.Cash + ((6000 + CashAdjustments[Difficulty]) / #CoopPlayers)
			if PID.Cash < 2500 then
				PID.Cash = 2500
			end
		end)
		--Nod.Cash = 6000 + CashAdjustments[Difficulty]
		Utils.Do(NodRadarProviders,function(UID)
			UID.Destroy()
		end)
		--NodRadarProvider.Destroy()
		ObjectiveDestroyGDI = Nod.AddObjective("Destroy GDI forces.")
        Nod.MarkCompletedObjective(ObjectiveReinforce)

		local nod2Assets = Nod2.GetActors()
		local nod2Attackers = Nod2.GetGroundAttackers()
		Utils.Do(nod2Assets, function(a)
			if not a.IsDead and a.Type ~= "player" then
				a.Owner = Nod
			end
		end)
		Utils.Do(nod2Attackers, function(a)
			if not a.IsDead and a.Type ~= "player" then
				a.Owner = DummyGuy
			end
		end)

		if Difficulty ~= "easy" then
			Trigger.AfterDelay(DateTime.Seconds(15), function()
				InitEastAttackers()
			end)
		end
    end
end

FlipWestBase = function()
    if not Nod.IsObjectiveCompleted(ObjectiveReinforce) then
		Utils.Do(CoopPlayers,function(PID)
			PID.Cash = PID.Cash + ((6000 + CashAdjustments[Difficulty]) / #CoopPlayers)
		end)
		Utils.Do(NodRadarProviders,function(UID)
			UID.Destroy()
		end)
		--NodRadarProvider.Destroy()
		ObjectiveDestroyGDI = Nod.AddObjective("Destroy GDI forces.")
        Nod.MarkCompletedObjective(ObjectiveReinforce)

		local nod3Assets = Nod3.GetActors()
		local nod3Attackers = Nod3.GetGroundAttackers()
		Utils.Do(nod3Assets, function(a)
			if not a.IsDead and a.Type ~= "player" then
				a.Owner = Nod
			end
		end)
		Utils.Do(nod3Attackers, function(a)
			if not a.IsDead and a.Type ~= "player" then
				a.Owner = DummyGuy
			end
		end)

		if Difficulty ~= "easy" then
			Trigger.AfterDelay(DateTime.Seconds(15), function()
				InitWestAttackers()
			end)
		end
    end
end

InitGDIAttacks = function()
	Trigger.AfterDelay(Squads.Main.Delay[Difficulty], function()
		InitAttackSquad(Squads.Main, GDI)
	end)

	Trigger.AfterDelay(Squads.Forward.Delay[Difficulty], function()
		InitAttackSquad(Squads.Forward, GDI)
	end)

	Trigger.AfterDelay(Squads.GDIAir.Delay[Difficulty], function()
		InitAirAttackSquad(Squads.GDIAir, GDI)
	end)

	if Difficulty == "hard" then
		Trigger.AfterDelay(Squads.AntiCyborgAir.Delay[Difficulty], function()
			InitAirAttackSquad(Squads.AntiCyborgAir, GDI, MissionPlayers[1], { "rmbc", "enli", "reap", "avtr" })
		end)
	end
end
