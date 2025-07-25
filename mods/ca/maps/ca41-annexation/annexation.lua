ScrinAttackValues = {
	easy = { Min = 6, Max = 16 },
	normal = { Min = 16, Max = 33 },
	hard = { Min = 25, Max = 55 },
}

NodBuildingsToSell = { NodConyard, NodHand, NodFactory, NodComms }

ScrinReinforcementInitialSquad = { "s3", "s1", "s1", "s1", "s1", "s1", "s2", "s2", "s3", "intl", "rtpd", GunWalkerSeekerOrLacerator, CorrupterOrDevourer, CorrupterOrDevourer, GunWalkerSeekerOrLacerator, GunWalkerSeekerOrLacerator }
ScrinReinforcementSquad = { "s3", "s1", "s1", "s1", "s1", "s2", "s3", "intl", "rtpd", GunWalkerSeekerOrLacerator, CorrupterOrDevourer }

if Difficulty == "hard" then
	table.insert(UnitCompositions.Scrin, {
		Infantry = { "impl", "impl", "impl", "impl", "impl", "impl", "impl", "impl", "impl" },
		Vehicles = { "null", "null", "null", "null", "null", "null" },
		MinTime = DateTime.Minutes(5),
		IsSpecial = true
	})
end

AdjustedScrinCompositions = AdjustCompositionsForDifficulty(UnitCompositions.Scrin)

Squads = {
	ScrinRebels1 = {
		Delay = {
			easy = DateTime.Minutes(4),
			normal = DateTime.Minutes(3),
			hard = DateTime.Minutes(2),
		},
		AttackValuePerSecond = ScrinAttackValues,
		FollowLeader = true,
		ProducerTypes = { Infantry = BarracksTypes, Vehicles = FactoryTypes },
		Units = AdjustedScrinCompositions,
		AttackPaths = {
			{ RebelRally5.Location },
			{ RebelRally6.Location },
		},
	},
	ScrinRebels2 = {
		Delay = {
			easy = DateTime.Minutes(9),
			normal = DateTime.Minutes(6),
			hard = DateTime.Minutes(3),
		},
		AttackValuePerSecond = ScrinAttackValues,
		FollowLeader = true,
		ProducerTypes = { Infantry = BarracksTypes, Vehicles = FactoryTypes },
		Units = AdjustedScrinCompositions,
		AttackPaths = {
			{ RebelRally1.Location },
			{ RebelRally2.Location },
		},
	},
	ScrinRebels3 = {
		Delay = {
			easy = DateTime.Minutes(10),
			normal = DateTime.Minutes(7),
			hard = DateTime.Minutes(4),
		},
		AttackValuePerSecond = ScrinAttackValues,
		FollowLeader = true,
		ProducerTypes = { Infantry = BarracksTypes, Vehicles = FactoryTypes },
		Units = AdjustedScrinCompositions,
		AttackPaths = {
			{ RebelRally2.Location },
			{ RebelRally3.Location },
			{ RebelRally4.Location },
		},
	},
	ScrinRebelsAir = {
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

-- Setup and Tick

WorldLoaded = function()
	USSR = Player.GetPlayer("USSR")
	Nod = Player.GetPlayer("Nod")
	Scrin = Player.GetPlayer("Scrin")
	ScrinRebels1 = Player.GetPlayer("ScrinRebels1")
	ScrinRebels2 = Player.GetPlayer("ScrinRebels2")
	ScrinRebels3 = Player.GetPlayer("ScrinRebels3")
	SignalTransmittersPlayer = Player.GetPlayer("SignalTransmittersPlayer") -- separate player to prevent AI from attacking it
	Neutral = Player.GetPlayer("Neutral")
	MissionPlayers = { USSR }
	TimerTicks = DateTime.Minutes(3)
	NumTransmittersCaptured = 0

	Camera.Position = PlayerStart.CenterPosition

	InitObjectives(USSR)
	AdjustPlayerStartingCashForDifficulty()
	InitScrinRebels()
	InitNod()

	Actor.Create("hazmatsoviet.upgrade", true, { Owner = USSR })

	ObjectiveCaptureNerveCenter = USSR.AddObjective("Capture rebel Nerve Center.")
	ObjectiveEliminateRebels = USSR.AddObjective("Eliminate all rebel forces.")

	if Difficulty ~= "hard" then
		HardOnlyElite.Destroy()
		HardOnlyReaper.Destroy()
	end

	Trigger.AfterDelay(DateTime.Seconds(3), function()
		Media.DisplayMessage("Assist us to annihilate Kane and the rebels, and you will be rewarded.", "Scrin Overlord", HSLColor.FromHex("7700FF"))
		MediaCA.PlaySound("ovld_assist.aud", 2)

		Trigger.AfterDelay(AdjustTimeForGameSpeed(DateTime.Seconds(11)), function()
			Media.DisplayMessage("The vastness of space, uncorrupted by capitalism, is ours for the taking!", "Premier Cherdenko", HSLColor.FromHex("FF0000"))
			MediaCA.PlaySound("cdko_space.aud", 2)
		end)
	end)

	local transmitters = { SignalTransmitter1, SignalTransmitter2, SignalTransmitter3 }
	Utils.Do(transmitters, function(t)
		Trigger.OnEnteredProximityTrigger(t.CenterPosition, WDist.New(12 * 1024), function(a, id)
			if a.Owner == USSR then
				Trigger.RemoveProximityTrigger(id)
				InitSignalTransmittersObjective()
			end
		end)
	end)

	Trigger.OnCapture(GatewayNerveCenter, function(self, captor, oldOwner, newOwner)
		if newOwner == USSR and not USSR.IsObjectiveCompleted(ObjectiveCaptureNerveCenter) then
			USSR.MarkCompletedObjective(ObjectiveCaptureNerveCenter)
			ObjectiveHoldNerveCenter = USSR.AddObjective("Protect the captured Nerve Center.")
			TimerTicks = 0
			UpdateMissionText()

			Trigger.OnRemovedFromWorld(GatewayNerveCenter, function(a)
				if not USSR.IsObjectiveCompleted(ObjectiveHoldNerveCenter) then
					USSR.MarkFailedObjective(ObjectiveHoldNerveCenter)
					Gateway.Destroy()
				end
			end)
		end
	end)

	Trigger.OnKilled(GatewayNerveCenter, function(self, killer)
		if not USSR.IsObjectiveCompleted(ObjectiveCaptureNerveCenter) then
			USSR.MarkFailedObjective(ObjectiveCaptureNerveCenter)
			Gateway.Destroy()
		end
	end)

	Utils.Do(NodBuildingsToSell, function(b)
		Trigger.OnEnteredProximityTrigger(b.CenterPosition, WDist.New(5 * 1024), function(a, id)
			if a.Owner == USSR and a.Type == "e6" then
				Trigger.RemoveProximityTrigger(id)
				NodSellOff()
			end
		end)
	end)
end

Tick = function()
	OncePerSecondChecks()
	OncePerFiveSecondChecks()
	OncePerThirtySecondChecks()
end

OncePerSecondChecks = function()
	if DateTime.GameTime > 1 and DateTime.GameTime % 25 == 0 then
		ScrinRebels1.Resources = ScrinRebels1.ResourceCapacity - 500
		ScrinRebels2.Resources = ScrinRebels2.ResourceCapacity - 500
		ScrinRebels3.Resources = ScrinRebels3.ResourceCapacity - 500
		SignalTransmittersPlayer.Resources = SignalTransmittersPlayer.ResourceCapacity - 500

		if not PlayerHasBuildings(ScrinRebels1) and not PlayerHasBuildings(ScrinRebels2) and not PlayerHasBuildings(ScrinRebels3) then
			if not USSR.IsObjectiveCompleted(ObjectiveHoldNerveCenter) then
				USSR.MarkCompletedObjective(ObjectiveHoldNerveCenter)
			end

			if not USSR.IsObjectiveCompleted(ObjectiveEliminateRebels) then
				USSR.MarkCompletedObjective(ObjectiveEliminateRebels)
			end
		end

		if USSR.HasNoRequiredUnits() then
			if not USSR.IsObjectiveCompleted(ObjectiveEliminateRebels) then
				USSR.MarkFailedObjective(ObjectiveEliminateRebels)
			end
		end

		if TimerTicks > 0 then
			if TimerTicks > 25 then
				TimerTicks = TimerTicks - 25
			else
				TimerTicks = 0

				if not Gateway.IsDead then
					Gateway.Destroy()
					if not USSR.IsObjectiveCompleted(ObjectiveCaptureNerveCenter) then
						USSR.MarkFailedObjective(ObjectiveCaptureNerveCenter)
					end
				end
			end

			UpdateMissionText()
		end
	end
end

OncePerFiveSecondChecks = function()
	if DateTime.GameTime > 1 and DateTime.GameTime % 125 == 0 then
		UpdatePlayerBaseLocations()
	end
end

OncePerThirtySecondChecks = function()
	if DateTime.GameTime > 1 and DateTime.GameTime % DateTime.Seconds(30) == 0 then
		CalculatePlayerCharacteristics()
	end
end

UpdateMissionText = function()
	if TimerTicks > 0 then
		UserInterface.SetMissionText("Capture Nerve Center. Gateway collapses in " .. UtilsCA.FormatTimeForGameSpeed(TimerTicks), HSLColor.Yellow)
	else
		UserInterface.SetMissionText("")
	end
end

-- Functions

InitScrinRebels = function()
	AutoRepairAndRebuildBuildings(SignalTransmittersPlayer)
	Actor.Create("ai.unlimited.power", true, { Owner = SignalTransmittersPlayer })

	local scrinRebelPlayers = { ScrinRebels1, ScrinRebels2, ScrinRebels3 }

	Utils.Do(scrinRebelPlayers, function(p)
		AutoRepairAndRebuildBuildings(p)
		SetupRefAndSilosCaptureCredits(p)
		AutoReplaceHarvesters(p)
		AutoRebuildConyards(p)
		InitAiUpgrades(p)

		local scrinRebelsGroundAttackers = p.GetGroundAttackers()

		Utils.Do(scrinRebelsGroundAttackers, function(a)
			TargetSwapChance(a, 10)
			CallForHelpOnDamagedOrKilled(a, WDist.New(5120), IsScrinGroundHunterUnit)
		end)
	end)

	Trigger.AfterDelay(Squads.ScrinRebels1.Delay[Difficulty], function()
		InitAttackSquad(Squads.ScrinRebels1, ScrinRebels1)
	end)
	Trigger.AfterDelay(Squads.ScrinRebels2.Delay[Difficulty], function()
		InitAttackSquad(Squads.ScrinRebels2, ScrinRebels2)
	end)
	Trigger.AfterDelay(Squads.ScrinRebels3.Delay[Difficulty], function()
		InitAttackSquad(Squads.ScrinRebels3, ScrinRebels3)
	end)
	Trigger.AfterDelay(Squads.ScrinRebelsAir.Delay[Difficulty], function()
		InitAirAttackSquad(Squads.ScrinRebelsAir, ScrinRebels1)
	end)
end

InitNod = function()
	AutoRepairBuildings(Nod)
	SetupRefAndSilosCaptureCredits(Nod)

	local nodGroundAttackers = Nod.GetGroundAttackers()

	Utils.Do(nodGroundAttackers, function(a)
		TargetSwapChance(a, 10)
		CallForHelpOnDamagedOrKilled(a, WDist.New(5120), IsNodGroundHunterUnit)
	end)

	Trigger.AfterDelay(DateTime.Minutes(2), function()
		Utils.Do(nodGroundAttackers, function(a)
			AssaultPlayerBaseOrHunt(a, USSR)
		end)
	end)
end

InitSignalTransmittersObjective = function()
	if ObjectiveSignalTransmitters == nil then
		ObjectiveSignalTransmitters = USSR.AddObjective("Capture the three signal transmitters.")
		Media.DisplayMessage("Capture the rebel Signal Transmiters, and I will unleash my forces to assist you.", "Scrin Overlord", HSLColor.FromHex("7700FF"))
		MediaCA.PlaySound("ovld_capture.aud", 2)

		local transmitters = Utils.Where({ SignalTransmitter1, SignalTransmitter2, SignalTransmitter3 }, function(a)
			return not a.IsDead and a.Owner == SignalTransmittersPlayer
		end)

		Utils.Do(transmitters, function(t)
			local transmitterLocation = t.Location
			local transmitterFlare = Actor.Create("flare", true, { Owner = USSR, Location = transmitterLocation })

			Beacon.New(USSR, t.CenterPosition)
			Trigger.AfterDelay(DateTime.Seconds(20), function()
				transmitterFlare.Destroy()
			end)

			Trigger.OnCapture(t, function(self, captor, oldOwner, newOwner)
				NumTransmittersCaptured = NumTransmittersCaptured + 1

				if NumTransmittersCaptured == #transmitters and not USSR.IsObjectiveCompleted(ObjectiveSignalTransmitters) then
					USSR.MarkCompletedObjective(ObjectiveSignalTransmitters)
				end

				local wormholeLoc
				if self == SignalTransmitter1 then
					wormholeLoc = ScrinWormholeWp1.Location
				elseif self == SignalTransmitter2 then
					wormholeLoc = ScrinWormholeWp2.Location
				elseif self == SignalTransmitter3 then
					wormholeLoc = ScrinWormholeWp3.Location
				end

				Trigger.AfterDelay(DateTime.Seconds(3), function()
					local wormhole = SpawnWormhole(wormholeLoc)
					Trigger.AfterDelay(DateTime.Seconds(3), function()
						Media.PlaySpeechNotification(USSR, "ReinforcementsArrived")
						Notification("Reinforcements have arrived.")
						InitScrinReinforcements(wormhole)
						FleetRecall(transmitterLocation)
					end)
				end)
			end)

			Trigger.OnKilled(t, function(self, killer)
				if self.Owner == SignalTransmittersPlayer then
					USSR.MarkFailedObjective(ObjectiveSignalTransmitters)
				end
			end)
		end)
	end
end

NodSellOff = function()
	if NodSold then
		return
	end
	NodSold = true
	Utils.Do(NodBuildingsToSell, function(b)
		if not b.IsDead and b.Owner == Nod then
			b.Sell()
		end
	end)
end

SpawnWormhole = function(loc)
	return Actor.Create("wormhole", true, { Owner = Scrin, Location = loc })
end

InitScrinReinforcements = function(wormhole, initial)
	DeployScrinReinforcements(wormhole, true)
end

DeployScrinReinforcements = function(wormhole, initial)
	if not wormhole.IsDead then
		local unitsList = {}

		local compositionUnits
		if initial then
			compositionUnits = ScrinReinforcementInitialSquad
		else
			compositionUnits = ScrinReinforcementSquad
		end

		Utils.Do(compositionUnits, function(u)
			if type(u) == "table" then
				table.insert(unitsList, Utils.Random(u))
			else
				table.insert(unitsList, u)
			end
		end)

		local units = Reinforcements.Reinforce(Scrin, unitsList, { wormhole.Location }, 5)
		Utils.Do(units, function(unit)
			unit.Scatter()
			Trigger.AfterDelay(5, function()
				AssaultPlayerBaseOrHunt(unit, ScrinRebels1)
			end)
		end)

		Trigger.AfterDelay(DateTime.Minutes(3), function()
			DeployScrinReinforcements(wormhole, false)
		end)
	end
end

FleetRecall = function(loc)
	local effect = Actor.Create("recall.effect", true, { Owner = Scrin, Location = loc })
	Trigger.AfterDelay(DateTime.Seconds(5), effect.Destroy)

	local spawnLocations = {
		CPos.New(loc.X + 2, loc.Y + 1),
		CPos.New(loc.X - 2, loc.Y - 1),
		CPos.New(loc.X - 1, loc.Y + 2),
		CPos.New(loc.X + 1, loc.Y - 2)
	}

	Utils.Do(spawnLocations, function(loc)
		Actor.Create("pac", true, { Owner = Scrin, Location = loc, Facing = Angle.SouthWest, CenterPosition = Map.CenterOfCell(loc) + WVec.New(0, 0, Actor.CruiseAltitude("pac"))})
	end)
end
