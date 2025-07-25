
NWReactors = { NWPower1, NWPower2, NWPower3, NWPower4, NWPower5, NWPower6, NWPower7, NWPower8 }

NEReactors = { NEPower1, NEPower2, NEPower3, NEPower4, NEPower5, NEPower6, NEPower7, NEPower8 }

AdjustedScrinCompositions = AdjustCompositionsForDifficulty(UnitCompositions.Scrin)

Squads = {
	ScrinWest = {
		AttackValuePerSecond = {
			easy = { Min = 30, Max = 30 },
			normal = { Min = 50, Max = 50 },
			hard = { Min = 70, Max = 70 },
		},
		InitTime = DateTime.Minutes(2),
		FollowLeader = true,
		ProducerActors = { Infantry = { WestPortal }, Vehicles = { WestWarpSphere } },
		ProducerTypes = { Infantry = { "port" }, Vehicles = { "wsph" }, Aircraft = { "grav" } },
		Units = AdjustedScrinCompositions,
		AttackPaths = {
			{ WestAttackNode1.Location, WestAttackNode2.Location, WestAttackNode5.Location },
			{ WestAttackNode1.Location, WestAttackNode2.Location, WestAttackNode3.Location, WestAttackNode4.Location, WestAttackNode5.Location },
		},
	},
	ScrinEast = {
		AttackValuePerSecond = {
			easy = { Min = 30, Max = 30 },
			normal = { Min = 50, Max = 50 },
			hard = { Min = 70, Max = 70 },
		},
		InitTime = DateTime.Minutes(4),
		FollowLeader = true,
		ProducerActors = { Infantry = { EastPortal }, Vehicles = { EastWarpSphere } },
		ProducerTypes = { Infantry = { "port" }, Vehicles = { "wsph" }, Aircraft = { "grav" } },
		Units = AdjustedScrinCompositions,
		AttackPaths = {
			{ EastAttackNode1.Location, EastAttackNode2.Location, EastAttackNode3.Location, EastAttackNode4.Location, EastAttackNode5.Location },
			{ EastAttackNode1.Location, EastAttackNode5.Location },
		},
	},
	ScrinCenter = {
		AttackValuePerSecond = {
			easy = { Min = 30, Max = 30 },
			normal = { Min = 50, Max = 50 },
			hard = { Min = 70, Max = 70 },
		},
		InitTime = 0,
		FollowLeader = true,
		ProducerActors = { Infantry = { CenterPortal }, Vehicles = { CenterWarpSphere } },
		ProducerTypes = { Infantry = { "port" }, Vehicles = { "wsph" }, Aircraft = { "grav" } },
		Units = AdjustedScrinCompositions,
		AttackPaths = { { CenterAttackNode1.Location, CenterAttackNode2.Location, CenterAttackNode3.Location } },
	},
	SovietSlaves = {
		Delay = {
			easy = DateTime.Seconds(210),
			normal = DateTime.Seconds(150),
			hard = DateTime.Seconds(90)
		},
		AttackValuePerSecond = {
			easy = { Min = 10, Max = 15, RampDuration = DateTime.Minutes(15) },
			normal = { Min = 20, Max = 33, RampDuration = DateTime.Minutes(13) },
			hard = { Min = 30, Max = 50, RampDuration = DateTime.Minutes(11) },
		},
		ActiveCondition = function()
			return not SovietsFreed
		end,
		FollowLeader = true,
		ProducerTypes = { Infantry = { "barr" }, Vehicles = { "weap" } },
		Units = AdjustCompositionsForDifficulty(UnitCompositions.Soviet),
		AttackPaths = { { WestAttackNode4.Location, WestAttackNode5.Location } },
	},
	NodSlaves = {
		Delay = {
			easy = DateTime.Seconds(210),
			normal = DateTime.Seconds(150),
			hard = DateTime.Seconds(90)
		},
		AttackValuePerSecond = {
			easy = { Min = 10, Max = 15, RampDuration = DateTime.Minutes(15) },
			normal = { Min = 20, Max = 33, RampDuration = DateTime.Minutes(13) },
			hard = { Min = 30, Max = 50, RampDuration = DateTime.Minutes(11) },
		},
		ActiveCondition = function()
			return not NodFreed
		end,
		DispatchDelay = DateTime.Seconds(15),
		FollowLeader = true,
		ProducerTypes = { Infantry = { "hand" }, Vehicles = { "airs" } },
		Units = AdjustCompositionsForDifficulty(UnitCompositions.Nod),
		AttackPaths = { { EastAttackNode4.Location, EastAttackNode5.Location } },
	},
	AlliedSlaves = {
		Delay = {
			easy = DateTime.Seconds(210),
			normal = DateTime.Seconds(150),
			hard = DateTime.Seconds(90)
		},
		AttackValuePerSecond = {
			easy = { Min = 10, Max = 15, RampDuration = DateTime.Minutes(15) },
			normal = { Min = 20, Max = 33, RampDuration = DateTime.Minutes(13) },
			hard = { Min = 30, Max = 50, RampDuration = DateTime.Minutes(11) },
		},
		ActiveCondition = function()
			return not AlliesFreed
		end,
		FollowLeader = true,
		ProducerTypes = { Infantry = { "tent" }, Vehicles = { "weap" } },
		Units = AdjustCompositionsForDifficulty(UnitCompositions.Allied),
		AttackPaths = { { CenterAttackNode3.Location } },
	},
	USSR = {
		AttackValuePerSecond = {
			easy = { Min = 25, Max = 25 },
			normal = { Min = 25, Max = 25 },
			hard = { Min = 25, Max = 25 },
		},
		FollowLeader = true,
		ProducerTypes = { Infantry = { "barr" }, Vehicles = { "weap" } },
		Units = AdjustCompositionsForDifficulty(UnitCompositions.Soviet, "normal"),
		AttackPaths = { { WestAttackNode2.Location, WestAttackNode1.Location, WormholeWP.Location } },
	},
	Nod = {
		AttackValuePerSecond = {
			easy = { Min = 25, Max = 25 },
			normal = { Min = 25, Max = 25 },
			hard = { Min = 25, Max = 25 },
		},
		DispatchDelay = DateTime.Seconds(15),
		FollowLeader = true,
		ProducerTypes = { Infantry = { "hand" }, Vehicles = { "airs" } },
		Units = AdjustCompositionsForDifficulty(UnitCompositions.Nod, "normal"),
		AttackPaths = { { EastAttackNode2.Location, EastAttackNode1.Location, WormholeWP.Location } },
	},
	Greece = {
		AttackValuePerSecond = {
			easy = { Min = 25, Max = 25 },
			normal = { Min = 25, Max = 25 },
			hard = { Min = 25, Max = 25 },
		},
		FollowLeader = true,
		ProducerTypes = { Infantry = { "tent" }, Vehicles = { "weap" } },
		Units = AdjustCompositionsForDifficulty(UnitCompositions.Allied, "normal"),
		AttackPaths = { { CenterAttackNode2.Location, CenterAttackNode1.Location, WormholeWP.Location } },
	},
	ScrinAir = {
		Delay = {
			easy = DateTime.Minutes(6),
			normal = DateTime.Minutes(5),
			hard = DateTime.Minutes(4)
		},
		AttackValuePerSecond = {
			easy = { Min = 7, Max = 7 },
			normal = { Min = 14, Max = 14 },
			hard = { Min = 21, Max = 21 },
		},
		ProducerTypes = { Aircraft = { "grav" } },
		Units = {
			easy = {
				{ Aircraft = { "stmr" } }
			},
			normal = {
				{ Aircraft = { "stmr", "stmr" } },
				{ Aircraft = { "enrv" } },
			},
			hard = {
				{ Aircraft = { "stmr", "stmr", "stmr" } },
				{ Aircraft = { "enrv", "enrv" } },
			}
		}
	},
}

RiftEnabledTime = {
	easy = DateTime.Seconds((60 * 45) + 17),
	normal = DateTime.Seconds((60 * 30) + 17),
	hard = DateTime.Seconds((60 * 15) + 17),
}

MADTankAttackDelay = {
	easy = DateTime.Minutes(3),
	normal = DateTime.Minutes(3),
	hard = DateTime.Minutes(3),
}

ChronoTanksDelay = {
	easy = DateTime.Minutes(3),
	normal = DateTime.Minutes(3),
	hard = DateTime.Minutes(3),
}

HackersDelay = {
	easy = DateTime.Minutes(2),
	normal = DateTime.Minutes(2),
	hard = DateTime.Minutes(2),
}

WorldLoaded = function()
	GDI = Player.GetPlayer("GDI")
	Greece = Player.GetPlayer("Greece")
	USSR = Player.GetPlayer("USSR")
	Nod = Player.GetPlayer("Nod")
	Scrin = Player.GetPlayer("Scrin")
	AlliedSlaves = Player.GetPlayer("AlliedSlaves")
	SovietSlaves = Player.GetPlayer("SovietSlaves")
	NodSlaves = Player.GetPlayer("NodSlaves")
	CyborgSlaves = Player.GetPlayer("CyborgSlaves")
	Kane = Player.GetPlayer("Kane")
	NeutralGDI = Player.GetPlayer("NeutralGDI")
	NeutralScrin = Player.GetPlayer("NeutralScrin")
	SignalTransmitterPlayer = Player.GetPlayer("SignalTransmitterPlayer") -- separate player to prevent AI from attacking it
	MissionPlayers = { GDI }
	TimerTicks = 0
	
	DummyGuy = Player.GetPlayer("DummyGuy")
	ORAMod = "ca"
	coopInfo =
	{
		Mainplayer = GDI,
		MainEnemies = {Scrin, AlliedSlaves, SovietSlaves, NodSlaves, Kane, CyborSlaves},
		Dummyplayer = DummyGuy
	}
	
	CoopInit25(coopInfo)
	
	Utils.Do(MCVPlayers,function(PID)
		if PID ~= GDI then
			local ExtraMCV = Actor.Create("amcv", true, { Owner = PID, Location = PlayerStart.Location })			
			ExtraMCV.Scatter()
		end
	end)
	
	Camera.Position = Mothership.CenterPosition
	IntroCamTarget = Mothership
	local IntromothershipCamera = Actor.Create("camera", true, { Owner = GDI, Location = Mothership.Location })
	
	InitObjectives(GDI)
	AdjustPlayerStartingCashForDifficulty()
	StartCashSpread(3000)
	InitScrin()
	InitNodSlaves()
	InitSovietSlaves()
	InitAlliedSlaves()

	if Difficulty == "easy" then
		HardNormalAA1.Destroy()
		HardNormalAA2.Destroy()
		HardNormalAA3.Destroy()
	end

	ObjectiveDestroyMothership = GDI.AddObjective("Destroy the Scrin Mothership.")

	Trigger.OnAllKilledOrCaptured(NWReactors, function()
		ScrinDefenseBuff1.Destroy()
		Notification("The north-western reactors have been destroyed. Scrin defenses have been weakened.")
		MediaCA.PlaySound("c_nwreactorsdown.aud", 2)

		if ScrinDefenseBuff2.IsDead then
			IonConduits.Destroy()
			if NodFreed then
				InitHackers(HackersDelay[Difficulty])
			end
		end

		if MADTank ~= nil and not MADTank.IsDead and MADTankInvulnToken ~= nil then
			MADTank.RevokeCondition(MADTankInvulnToken)
		end
	end)

	Trigger.OnAllKilledOrCaptured(NEReactors, function()
		ScrinDefenseBuff2.Destroy()
		Notification("The north-eastern reactors have been destroyed. Scrin defenses have been weakened.")
		MediaCA.PlaySound("c_nereactorsdown.aud", 2)

		if ScrinDefenseBuff1.IsDead then
			IonConduits.Destroy()
			if NodFreed then
				InitHackers(HackersDelay[Difficulty])
			end
		end
	end)

	Trigger.OnKilled(AlliedMastermind, function(self, killer)
		FlipSlaveFaction(AlliedSlaves)
	end)
	Trigger.OnKilled(SovietMastermind, function(self, killer)
		FlipSlaveFaction(SovietSlaves)
	end)
	Trigger.OnKilled(NodMastermind, function(self, killer)
		FlipSlaveFaction(NodSlaves)
	end)

	Trigger.AfterDelay(DateTime.Seconds(5), function()
		Media.DisplayMessage("Beginning our attack run. Let's see what we're up against. Over.", "GDI Pilot", HSLColor.FromHex("F2CF74"))
		MediaCA.PlaySound("pilot_begin.aud", 1.5)
	end)

	Trigger.AfterDelay(DateTime.Seconds(10), function()
		DoInterceptors()
		IntromothershipCamera.Destroy()
		Trigger.AfterDelay(DateTime.Seconds(13), function()
			IntroCamTarget = PlayerStart
			Trigger.AfterDelay(120, function()
				IntroFinished = true
			end)
		end)
		Trigger.AfterDelay(DateTime.Seconds(15), function()
			Media.DisplayMessage("We barely made a scratch! We'll need you to bring those shields down before we can do any damage. Over and out.", "GDI Pilot", HSLColor.FromHex("F2CF74"))
			MediaCA.PlaySound("pilot_barelyscratch.aud", 1.5)
		end)
	end)

	Trigger.OnKilled(Mothership, function(self, killer)
		DoFinale()
	end)

	Trigger.OnDamaged(SignalTransmitter, function(self, attacker, damage)
		if IsOwnedByCoopPlayer(attacker) then
			InitHackers(0)
		end
	end)

	Trigger.OnEnteredProximityTrigger(SignalTransmitter.CenterPosition, WDist.New(12 * 1024), function(a, id)
		if IsOwnedByCoopPlayer(a) and a.HasProperty("Health") and not a.HasProperty("Land") then
			Trigger.RemoveProximityTrigger(id)
			InitHackers(0)
		end
	end)

	Trigger.OnEnteredProximityTrigger(WormholeWP.CenterPosition, WDist.New(6 * 1024), function(a, id)
		if a.Owner == Nod and not a.IsDead and a.HasProperty("Hunt") then
			a.Stop()
			Trigger.ClearAll(a)
			a.Hunt()
		end
	end)

	Trigger.OnKilled(SignalTransmitter, function(self, killer)
		CreatePermanentMothershipCamera()
		if ObjectiveHackSignalTransmitter ~= nil and not GDI.IsObjectiveCompleted(ObjectiveHackSignalTransmitter) then
			GDI.MarkFailedObjective(ObjectiveHackSignalTransmitter)
			Trigger.AfterDelay(DateTime.Seconds(2), function()
				Media.DisplayMessage("The Signal Transmitter has been destroyed! Your only option now is to use brute force to bring those shields down. I only hope you can do it in time.", "Nod Commander", HSLColor.FromHex("FF0000"))
			end)
		end
	end)

	local cyborgs = CyborgSlaves.GetActorsByTypes({ "rmbc", "enli", "tplr", "reap" })
	Utils.Do(cyborgs, function(c)
		c.GrantCondition("bluebuff")

		Trigger.OnDamaged(c, function(self, attacker, damage)
			if not SleepingCyborgsMessageShown and not Mothership.IsDead and not self.IsDead and self.Health < self.MaxHealth * 0.8 then
				SleepingCyborgsMessageShown = true
				Notification("Nod cyborgs appear to be in a hibernation state. The enriched Tiberium is providing powerful regeneration. Recommendation is to not engage.")
				MediaCA.PlaySound("c_hibernation.aud", 2)
				Utils.Do(cyborgs, function(c)
					if not c.IsDead then
						c.GrantCondition("warned")
					end
				end)
			end
		end)
	end)

	Trigger.OnAnyKilled(cyborgs, function()
		if not CyborgsProvoked then
			CyborgsProvoked = true
			Utils.Do(cyborgs, function(c)
				if not c.IsDead then
					c.Stop()
					c.GrantCondition("provoked")
					ClearCyborgTarget(c)
				end
			end)
		end
	end)

	SetupReveals({ EntranceReveal1, EntranceReveal2, EntranceReveal3, GrandCannonReveal1, GrandCannonReveal2 })
end

MoveToWormhole = function(a)
	if not a.IsDead then
		a.Stop()
		a.Scatter()
		a.Move(WormholeWP.Location)
		local randomDelay = Utils.RandomInteger(DateTime.Seconds(7), DateTime.Seconds(12))
		Trigger.AfterDelay(randomDelay, function()
			MoveToWormhole(a)
		end)
	end
end

Tick = function()
	if IntroFinished ~= true then
		IntroCamera()
	end
	OncePerSecondChecks()
	OncePerFiveSecondChecks()
	OncePerThirtySecondChecks()
	PanToFinale()
end

ClearCyborgTarget = function(cyborg)
	if not IsFinaleStarted then
		Trigger.AfterDelay(DateTime.Seconds(5), function()
			if not cyborg.IsDead then
				cyborg.Stop()
				ClearCyborgTarget(cyborg)
			end
		end)
	end
end

OncePerSecondChecks = function()
	if DateTime.GameTime > 1 and DateTime.GameTime % 25 == 0 then
		Scrin.Resources = Scrin.ResourceCapacity - 500
		SignalTransmitterPlayer.Resources = SignalTransmitterPlayer.ResourceCapacity - 500
		NodSlaves.Resources = NodSlaves.ResourceCapacity - 500
		AlliedSlaves.Resources = AlliedSlaves.ResourceCapacity - 500
		SovietSlaves.Resources = SovietSlaves.ResourceCapacity - 500
		Nod.Resources = Nod.ResourceCapacity - 500
		USSR.Resources = USSR.ResourceCapacity - 500
		Greece.Resources = Greece.ResourceCapacity - 500

		if TimerTicks > 0 then
			if TimerTicks > 25 then
				TimerTicks = TimerTicks - 25
			else
				TimerTicks = 0
			end
		end

		if CoopTeamHasNoRequiredUnits() and not GDI.IsObjectiveCompleted(ObjectiveDestroyMothership) then
			GDI.MarkFailedObjective(ObjectiveDestroyMothership)
		end

		RemoveCyborgsAtWormhole()
	end
end

OncePerFiveSecondChecks = function()
	if DateTime.GameTime > 1 and DateTime.GameTime % 125 == 0 then
		UpdatePlayerBaseLocations()

		if not ShieldsOffline and not SignalTransmitter.IsDead and IsOwnedByCoopPlayer(SignalTransmitter) then
			ShieldsOffline = true
			MothershipShields.Destroy()
			CreatePermanentMothershipCamera()

			if ObjectiveHackSignalTransmitter ~= nil then
				GDI.MarkCompletedObjective(ObjectiveHackSignalTransmitter)
			end

			Notification("The Mothership's shields are down. Air attacks resuming.")
			MediaCA.PlaySound("c_resuming.aud", 2)

			Trigger.AfterDelay(DateTime.Seconds(10), function()
				DoInterceptors()
				MediaCA.PlaySound("pilot_engaging.aud", 1.5)

				Trigger.AfterDelay(DateTime.Seconds(15), function()
					if not Mothership.IsDead then
						Notification("Attack run successful. The Mothership's hull has sustained significant damage. Next attack run ETA 2 minutes.")
						MediaCA.PlaySound("c_attackrunsuccess.aud", 2)

						Trigger.AfterDelay(DateTime.Minutes(2), function()
							DoInterceptors()
							MediaCA.PlaySound("pilot_goingin.aud", 1.5)

							Trigger.AfterDelay(DateTime.Seconds(15), function()
								if not Mothership.IsDead then
									Notification("Estimate one more pass to destroy the Mothership, ETA 2 minutes.")
									MediaCA.PlaySound("c_onemorepass.aud", 2)

									Trigger.AfterDelay(DateTime.Minutes(2), function()
										DoInterceptors()
										MediaCA.PlaySound("pilot_approach.aud", 1.5)
									end)
								end
							end)
						end)
					end
				end)
			end)
		end

		if NodFreed and FirstHackersArrived and not MoreHackersRequested and not ShieldsOffline and not SignalTransmitter.IsDead then
			local hackers = {}
			Utils.Do(CoopPlayers, function(PID)
				Utils.Do(PID.GetActorsByType("hack"),function(UID)
					table.insert(hackers, UID)
				end)
			end)

			if #hackers == 0 then
				MoreHackersRequested = true

				Trigger.AfterDelay(HackersDelay[Difficulty], function()
					if SignalTransmitter.IsDead then
						return
					end

					DropHackers()
				end)
			end
		end
	end
end

OncePerThirtySecondChecks = function()
	if DateTime.GameTime > 1 and DateTime.GameTime % DateTime.Seconds(30) == 0 then
		CalculatePlayerCharacteristics()
	end
end

InitScrin = function()
	RebuildExcludes.Scrin = { Types = { "sign", "rfgn", "reac", "rea2" } }

	AutoRepairBuildings(SignalTransmitterPlayer)

	AutoRepairAndRebuildBuildings(Scrin, 15)
	SetupRefAndSilosCaptureCredits(Scrin)
	AutoReplaceHarvesters(Scrin)
	AutoRebuildConyards(Scrin)
	InitAiUpgrades(Scrin)

	local scrinGroundAttackers = Scrin.GetGroundAttackers()

	Utils.Do(scrinGroundAttackers, function(a)
		TargetSwapChance(a, 10)
		CallForHelpOnDamagedOrKilled(a, WDist.New(5120), IsScrinGroundHunterUnit)
	end)

	Mothership.Attack(Wormhole, true, true)
	Actor.Create("ai.unlimited.power", true, { Owner = Scrin })
	IonConduits = Actor.Create("ioncon.upgrade", true, { Owner = Scrin })
	ScrinDefenseBuff1 = Actor.Create("scrindefensebuff1", true, { Owner = Scrin })
	ScrinDefenseBuff2 = Actor.Create("scrindefensebuff2", true, { Owner = Scrin })
	MothershipShields = Actor.Create("mothership.shields", true, { Owner = Scrin })

	Trigger.AfterDelay(RiftEnabledTime[Difficulty], function()
		Actor.Create("ai.superweapons.enabled", true, { Owner = Scrin })
	end)

	Trigger.AfterDelay(Squads.ScrinAir.Delay[Difficulty], function()
		InitAirAttackSquad(Squads.ScrinAir, Scrin)
	end)

	local scrinPower = Scrin.GetActorsByTypes({ "reac", "rea2" })
	Trigger.OnAllKilledOrCaptured(scrinPower, function()
		local scrinDefenses = Scrin.GetActorsByTypes({ "scol", "shar" })
		Utils.Do(scrinDefenses, function(a)
			if not a.IsDead then
				a.GrantCondition("disabled")
			end
		end)
	end)
end

InitNodSlaves = function()
	AutoRepairAndRebuildBuildings(NodSlaves, 15)
	SetupRefAndSilosCaptureCredits(NodSlaves)
	AutoReplaceHarvesters(NodSlaves)

	local nodGroundAttackers = NodSlaves.GetGroundAttackers()

	Utils.Do(nodGroundAttackers, function(a)
		TargetSwapChance(a, 10)
	end)

	Trigger.AfterDelay(Squads.NodSlaves.Delay[Difficulty], function()
		InitAttackSquad(Squads.NodSlaves, NodSlaves)
	end)
end

InitSovietSlaves = function()
	AutoRepairAndRebuildBuildings(SovietSlaves, 15)
	SetupRefAndSilosCaptureCredits(SovietSlaves)
	AutoReplaceHarvesters(SovietSlaves)

	local sovietGroundAttackers = SovietSlaves.GetGroundAttackers()

	Utils.Do(sovietGroundAttackers, function(a)
		TargetSwapChance(a, 10)
	end)

	Trigger.AfterDelay(Squads.SovietSlaves.Delay[Difficulty], function()
		InitAttackSquad(Squads.SovietSlaves, SovietSlaves)
	end)
end

InitAlliedSlaves = function()
	AutoRepairAndRebuildBuildings(AlliedSlaves, 15)
	SetupRefAndSilosCaptureCredits(AlliedSlaves)
	AutoReplaceHarvesters(AlliedSlaves)

	local alliedGroundAttackers = AlliedSlaves.GetGroundAttackers()

	Utils.Do(alliedGroundAttackers, function(a)
		TargetSwapChance(a, 10)
	end)

	Trigger.AfterDelay(Squads.AlliedSlaves.Delay[Difficulty], function()
		InitAttackSquad(Squads.AlliedSlaves, AlliedSlaves)
	end)
end

InitNod = function()
	Trigger.AfterDelay(1, function()
		AutoRepairAndRebuildBuildings(Nod, 15)
		AutoReplaceHarvesters(Nod)
		InitAttackSquad(Squads.Nod, Nod, Scrin)
	end)
end

InitUSSR = function()
	Trigger.AfterDelay(1, function()
		AutoRepairAndRebuildBuildings(USSR, 15)
		AutoReplaceHarvesters(USSR)
		InitAttackSquad(Squads.USSR, USSR, Scrin)
	end)
end

InitGreece = function()
	Trigger.AfterDelay(1, function()
		AutoRepairAndRebuildBuildings(Greece, 15)
		AutoReplaceHarvesters(Greece)
		InitAttackSquad(Squads.Greece, Greece, Scrin)
	end)
end

InitHackers = function(delay)
	if FirstHackersRequested then
		return
	end

	FirstHackersRequested = true

	Trigger.AfterDelay(delay, function()
		if SignalTransmitter.IsDead then
			return
		end

		DropHackers()
		Beacon.New(DummyGuy, SignalTransmitter.CenterPosition)
	end)
end

DropHackers = function()
	Beacon.New(DummyGuy, HackerDropLanding.CenterPosition)

	if not FirstHackersArrived then
		MediaCA.PlaySound("seth_hackers.aud", 2)
		Media.DisplayMessage("Attention GDI commander. We are sending you some of our hackers. Use them to hack into the Scrin Signal Transmitter. They will be able to bring the Mothership's shields down for you.", "Nod Commander", HSLColor.FromHex("FF0000"))
	else
		MediaCA.PlaySound("seth_morehackers.aud", 2)
		Media.DisplayMessage("We are sending you another squad of hackers. Perhaps you'll be more careful with them this time.", "Nod Commander", HSLColor.FromHex("FF0000"))
	end

	local hackerFlare = Actor.Create("flare", true, { Owner = DummyGuy, Location = HackerDropLanding.Location })
	Trigger.AfterDelay(DateTime.Seconds(10), function()
		hackerFlare.Destroy()
	end)

	local entryPath = { HackerDropSpawn.Location, HackerDropLanding.Location }
	DoHelicopterDrop(Nod, entryPath, "tran.evac", { "hack", "hack", "hack" }, nil, function(t)
		Trigger.AfterDelay(DateTime.Seconds(5), function()
			if not t.IsDead then
				t.Move(entryPath[1])
				t.Destroy()
			end

			local hackers = Nod.GetActorsByType("hack")
			Utils.Do(hackers, function(a)
				a.Owner = DummyGuy
			end)

			if not FirstHackersArrived then
				if not SignalTransmitter.IsDead then
					ObjectiveHackSignalTransmitter = GDI.AddSecondaryObjective("Hack Signal Transmitter to bring shields down.")
				end
				FirstHackersArrived = true
			end
			MoreHackersRequested = false
		end)
	end)
end

InitChronoTanks = function()
	Trigger.AfterDelay(ChronoTanksDelay[Difficulty], function()
		if ScrinDefenseBuff2.IsDead then
			return
		end

		Notification("The Allies have provided a squadron of Chrono Tanks. Use them to destroy Scrin Reactors in the north-east.")
		MediaCA.PlaySound("c_chronotanks.aud", 2)
		local northEastPowerFlare = Actor.Create("flare", true, { Owner = DummyGuy, Location = NorthEastPowerBeacon.Location })
		Trigger.AfterDelay(DateTime.Seconds(10), function()
			northEastPowerFlare.Destroy()
		end)

		Beacon.New(DummyGuy, NorthEastPowerBeacon.CenterPosition)
		Beacon.New(DummyGuy, ChronoTankBeacon.CenterPosition)

		Lighting.Flash("Chronoshift", 10)
		Media.PlaySound("chrono2.aud")
		Actor.Create("ctnk.reinforce", true, { Owner = DummyGuy, Location = ChronoTankSpawn1.Location, Facing = Angle.NorthEast })
		Actor.Create("ctnk.reinforce", true, { Owner = DummyGuy, Location = ChronoTankSpawn2.Location, Facing = Angle.NorthEast })
		Actor.Create("ctnk.reinforce", true, { Owner = DummyGuy, Location = ChronoTankSpawn3.Location, Facing = Angle.NorthEast })
		Actor.Create("ctnk.reinforce", true, { Owner = DummyGuy, Location = ChronoTankSpawn4.Location, Facing = Angle.NorthEast })
		Actor.Create("ctnk.reinforce", true, { Owner = DummyGuy, Location = ChronoTankSpawn5.Location, Facing = Angle.NorthEast })
		Actor.Create("ctnk.reinforce", true, { Owner = DummyGuy, Location = ChronoTankSpawn6.Location, Facing = Angle.NorthEast })
	end)
end

InitMADTankAttack = function()
	Trigger.AfterDelay(MADTankAttackDelay[Difficulty] - DateTime.Seconds(20), function()
		if ScrinDefenseBuff1.IsDead then
			return
		end
		Notification("Signal flare detected. The Soviets are sending a MAD Tank to destroy Scrin Reactors in the north-west. They have requested a rendezvous to provide escort.")
		MediaCA.PlaySound("c_madtank.aud", 2)

		local northWestPowerFlare = Actor.Create("flare", true, { Owner = DummyGuy, Location = MADTankPath9.Location })
		local madTankFlare = Actor.Create("flare", true, { Owner = DummyGuy, Location = MADTankPath1.Location })
		Trigger.AfterDelay(DateTime.Seconds(20), function()
			northWestPowerFlare.Destroy()
			madTankFlare.Destroy()
		end)

		Beacon.New(DummyGuy, MADTankPath9.CenterPosition)
		Beacon.New(DummyGuy, MADTankPath1.CenterPosition)
	end)

	Trigger.AfterDelay(MADTankAttackDelay[Difficulty], function()
		if ScrinDefenseBuff1.IsDead then
			return
		end

		MADTank = Actor.Create("qtnk", true, { Owner = USSR, Location = MADTankSpawn.Location, Facing = Angle.East })
		MADTank.Move(MADTankPath1.Location)
		Notification("MAD Tank has arrived. Rendezvous to provide escort.")
		MediaCA.PlaySound("c_madtankarrived.aud", 2)

		Trigger.OnDamaged(MADTank, function(self, attacker, damage)
			if self.Health < self.MaxHealth / 3 and not IsMADTankIronCurtained and not MADTank.IsDead then
				IsMADTankIronCurtained = true
				MADTankInvulnToken = MADTank.GrantCondition("invulnerability")
				Media.PlaySound("ironcur9.aud")
				Trigger.AfterDelay(DateTime.Minutes(3), function()
					if not MADTank.IsDead and MADTankInvulnToken ~= nil then
						MADTank.RevokeCondition(MADTankInvulnToken)
					end
				end)
			end
		end)

		Trigger.OnEnteredProximityTrigger(MADTankPath1.CenterPosition, WDist.New(7 * 1024), function(a, id)
			if IsOwnedByCoopPlayer(a) and a.HasProperty("Attack") then
				Trigger.RemoveProximityTrigger(id)
				SendMADTank()
			end
		end)

		Trigger.AfterDelay(DateTime.Minutes(2), function()
			SendMADTank()
		end)
	end)
end

SendMADTank = function()
	if not MADTankEnRoute and not MADTank.IsDead then
		MADTankEnRoute = true
		Notification("MAD Tank en route to target.")
		MediaCA.PlaySound("c_madtankenroute.aud", 2)
		MADTank.Move(MADTankPath2.Location)
		MADTank.Move(MADTankPath3.Location)
		MADTank.Move(MADTankPath4.Location)
		MADTank.Move(MADTankPath5.Location)
		MADTank.Move(MADTankPath6.Location)
		MADTank.Move(MADTankPath7.Location)
		MADTank.Move(MADTankPath8.Location)
		MADTank.Move(MADTankPath9.Location)
		MADTank.Wait(25)
		MADTank.MadTankDetonate()
	end
end

IntroCamera = function()
	PanToPos(IntroCamTarget.CenterPosition, 2000)
end

DoInterceptors = function()
	if Mothership.IsDead then
		return
	end

	local mothershipCamera = Actor.Create("camera", true, { Owner = GDI, Location = Mothership.Location })

	Trigger.AfterDelay(1, function()
		Media.PlaySound("interceptors.aud")
		local interceptor1 = Actor.Create("yf23.interceptor", true, { Owner = GDI, Location = InterceptorSpawn1.Location, CenterPosition = InterceptorSpawn1.CenterPosition + WVec.New(0, 0, Actor.CruiseAltitude("yf23.interceptor")), Facing = Angle.North })
		if IntroFinished ~= true then
			IntroCamTarget = interceptor1
		end
		if not Mothership.IsDead then
			interceptor1.Attack(Mothership)
		end

		Trigger.OnIdle(interceptor1, function(a)
			a.Stop()
			a.Move(InterceptorExit1.Location)
			a.Destroy()
		end)

		Trigger.AfterDelay(8, function()
			local interceptor2 = Actor.Create("yf23.interceptor", true, { Owner = GDI, Location = InterceptorSpawn2.Location, CenterPosition = InterceptorSpawn2.CenterPosition + WVec.New(0, 0, Actor.CruiseAltitude("yf23.interceptor")), Facing = Angle.North })
			local interceptor3 = Actor.Create("yf23.interceptor", true, { Owner = GDI, Location = InterceptorSpawn3.Location, CenterPosition = InterceptorSpawn3.CenterPosition + WVec.New(0, 0, Actor.CruiseAltitude("yf23.interceptor")), Facing = Angle.North })
			interceptor2.Move(InterceptorWP2.Location)
			interceptor3.Move(InterceptorWP3.Location)

			if not Mothership.IsDead then
				interceptor2.Attack(Mothership)
				interceptor3.Attack(Mothership)
			end

			Trigger.OnIdle(interceptor2, function(a)
				if IntroFinished ~= true and FinishedIntroAttack ~= true then
					FinishedIntroAttack = true
					IntroCamTarget = Mothership
				end
				a.Stop()
				a.Move(InterceptorExit2.Location)
				a.Destroy()
			end)

			Trigger.OnIdle(interceptor3, function(a)
				a.Stop()
				a.Move(InterceptorExit3.Location)
				a.Destroy()
			end)
		end)
	end)

	Trigger.AfterDelay(DateTime.Seconds(20), function()
		mothershipCamera.Destroy()
	end)
end

FlipSlaveFaction = function(player)
	local attackPath
	local targetPlayer

	if player == NodSlaves then
		targetPlayer = Nod
		NodFreed = true
		Squads.NodSlaves.IdleUnits = { }
		attackPath = { EastAttackNode1.Location, WormholeWP.Location }
		InitNod()
		InitAttackSquad(Squads.ScrinEast, Scrin)
		if ScrinDefenseBuff1.IsDead and ScrinDefenseBuff2.IsDead then
			InitHackers(HackersDelay[Difficulty])
		end
		Notification("Nod forces have been released from Scrin control.")
		MediaCA.PlaySound("c_nodreleased.aud", 2)
	elseif player == SovietSlaves then
		targetPlayer = USSR
		SovietsFreed = true
		Squads.SovietSlaves.IdleUnits = { }
		attackPath = { WestAttackNode1.Location, WormholeWP.Location }
		InitUSSR()
		InitAttackSquad(Squads.ScrinWest, Scrin)
		InitMADTankAttack()
		Notification("Soviet forces have been released from Scrin control.")
		MediaCA.PlaySound("c_sovietsreleased.aud", 2)
	elseif player == AlliedSlaves then
		targetPlayer = Greece
		AlliesFreed = true
		Squads.AlliedSlaves.IdleUnits = { }
		attackPath = { CenterAttackNode1.Location, WormholeWP.Location }
		InitGreece()
		InitAttackSquad(Squads.ScrinCenter, Scrin)
		InitChronoTanks()
		Notification("Allied forces have been released from Scrin control.")
		MediaCA.PlaySound("c_alliesreleased.aud", 2)
	end

	local actors = player.GetActors()

	Utils.Do(actors, function(a)
		if not a.IsDead and a.IsInWorld and a.Type ~= "player" then
			a.Owner = targetPlayer
			Trigger.ClearAll(a)

			local delay = Utils.RandomInteger(DateTime.Seconds(1), DateTime.Seconds(25))
			if a.HasProperty("FindResources") then
				delay = 1
			end

			Trigger.AfterDelay(delay, function()
				if not a.IsDead then
					if a.HasProperty("AttackMove") then
						a.Stop()
						a.AttackMove(attackPath[1], 2)
						a.AttackMove(attackPath[2], 2)
					elseif a.HasProperty("FindResources") then
						a.Stop()
						a.FindResources()
					end
				end
			end)
		end
	end)
end

DoFinale = function()
	if IsFinaleStarted then
		return
	end
	IsFinaleStarted = true
	local pacs = Scrin.GetActorsByTypes({ "pac", "deva", "stmr" })
	Utils.Do(pacs, function(a)
		if not a.IsDead then
			a.Kill()
		end
	end)

	Notification("Scrin mothership destroyed.")
	MediaCA.PlaySound("c_mothershipdestroyed.aud", 2)

	Lighting.Flash("Chronoshift", 10)

	Lighting.Ambient = 0.8
	Lighting.Red = 1
	Lighting.Blue = 1.2
	Lighting.Green = 0.8

	Wormhole.Destroy()
	Actor.Create("camera", true, { Owner = GDI, Location = WormholeWP.Location })

	Trigger.AfterDelay(1, function()
		Gateway = Actor.Create("wormholexxl", true, { Owner = Scrin, Location = WormholeWP.Location })
	end)

	Actor.Create("wormhole", true, { Owner = Kane, Location = KaneSpawn.Location })
	Actor.Create("wormhole", true, { Owner = Kane, Location = CyborgWormhole1.Location })
	Actor.Create("wormhole", true, { Owner = Kane, Location = CyborgWormhole2.Location })

	local kane = Actor.Create("kane", true, { Owner = Kane, Location = KaneSpawn.Location, Facing = Angle.South })

	Trigger.AfterDelay(DateTime.Seconds(5), function()
		kane.Stop()
		kane.Move(KaneSpawn.Location + CVec.New(0, 3))
	end)

	local cyborgs = CyborgSlaves.GetActorsByTypes({ "rmbc", "enli", "tplr", "reap" })

	Utils.Do(cyborgs, function(a)
		a.Owner = Kane
	end)

	Trigger.AfterDelay(DateTime.Seconds(6), function()
		Beacon.New(DummyGuy, kane.CenterPosition, 50)
		Media.DisplayMessage("Well commander, we meet at last! Your contribution has been invaluable, unwitting as it may be.", "Kane", HSLColor.FromHex("FF0000"))
		MediaCA.PlaySound("outro.aud", 2.5)

		Trigger.AfterDelay(AdjustTimeForGameSpeed(DateTime.Seconds(25)), function()
			if not Gateway.IsDead then
				Gateway.GrantCondition("kane-revealed")
			end

			Utils.Do(cyborgs, function(a)
				MoveToWormhole(a)
			end)

			Reinforcements.Reinforce(Kane, { "n1c", "rmbc", "rmbc", "enli", "reap", "rmbc", "enli", "reap", "rmbc", "enli", "enli", "n3c", "rmbc", "reap", "n3c" }, { CyborgWormhole1.Location, WormholeWP.Location }, 25)
			Reinforcements.Reinforce(Kane, { "rmbc", "rmbc", "enli", "reap", "rmbc", "enli", "reap", "rmbc", "enli", "n1c", "reap", "n1c", "n3c", "enli", "rmbc" }, { CyborgWormhole2.Location, WormholeWP.Location }, 25)
		end)

		Trigger.AfterDelay(AdjustTimeForGameSpeed(DateTime.Seconds(6)), function()
			Media.DisplayMessage("Ironic isn't it? That GDI should lay the foundation for the Brotherhood's ultimate victory.", "Kane", HSLColor.FromHex("FF0000"))
		end)

		Trigger.AfterDelay(AdjustTimeForGameSpeed(DateTime.Seconds(12)), function()
			Media.DisplayMessage("Of course the Allies and Soviets played their part as well.", "Kane", HSLColor.FromHex("FF0000"))
		end)

		Trigger.AfterDelay(AdjustTimeForGameSpeed(DateTime.Seconds(16)), function()
			Media.DisplayMessage("My painstaking manipulation of time and space finally bears fruit, and now we stand at the threshold.", "Kane", HSLColor.FromHex("FF0000"))
		end)

		Trigger.AfterDelay(AdjustTimeForGameSpeed(DateTime.Seconds(21)), function()
			Media.DisplayMessage("There is much yet to be done. I have no doubt our paths will cross again.", "Kane", HSLColor.FromHex("FF0000"))
		end)

		Trigger.AfterDelay(AdjustTimeForGameSpeed(DateTime.Seconds(27)), function()
			if not kane.IsDead then
				kane.Stop()
				kane.Move(WormholeWP.Location)
			end
			UserInterface.SetMissionText("To be continued...", HSLColor.Red)
		end)

		Trigger.AfterDelay(AdjustTimeForGameSpeed(DateTime.Seconds(37)), function()
			GDI.MarkCompletedObjective(ObjectiveDestroyMothership)
		end)
	end)
end

CreatePermanentMothershipCamera = function()
	if not Mothership.IsDead and not IsPermanentMothershipCameraCreated then
		IsPermanentMothershipCameraCreated = true
		Actor.Create("camera", true, { Owner = GDI, Location = Mothership.Location })
	end
end

PanToFinale = function()
	if PanToFinaleComplete or not Mothership.IsDead then
		return
	end

	local targetPos = WormholeWP.CenterPosition
	PanToPos(targetPos, 2048)

	if Camera.Position.X == targetPos.X and Camera.Position.Y == targetPos.Y then
		PanToFinaleComplete = true
	end
end

RemoveCyborgsAtWormhole = function()
	if not Mothership.IsDead then
		return
	end

	local kaneTroops = Map.ActorsInCircle(WormholeWP.CenterPosition, WDist.New(2 * 1024))
	Utils.Do(kaneTroops, function(a)
		if a.Owner == Kane and not a.IsDead then
			a.Stop()
			a.Destroy()
		end
	end)
end
