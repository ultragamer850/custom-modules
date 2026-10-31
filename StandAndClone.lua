--==============================================================
-- StandAndClone.lua  (STANDALONE: no HatCore.lua needed)
-- Contains only: shared FE hat/collide/claims/save core + the "stand" feature code.
-- Other features were cut out; their calls are no-op stubs (see STUBS block).
-- Shared claim registry _G.__HatStandClaims still stops two modules grabbing the same hat.
--==============================================================

local modules = {}

local function makeHatModule(cfg)
	local SUF = cfg.suffix or ""
	local INSTANCE_ID = cfg.id or "ALL"
	_G.__HatStandClaims = _G.__HatStandClaims or setmetatable({}, { __mode = "k" })
	local Claims = _G.__HatStandClaims
	pcall(function() warn("[HatStand] module factory running: " .. tostring(cfg.name)) end)

	local m = {}
	m.ModuleType = "MOVESET"
	m.Name = cfg.name or "Hat Stand"
	m.Description = cfg.desc or "Stand + Link Rigs + JoJo loco v2 + dance list + Clone + 10-slot BTools (real FE) + orbit + Gaster + Weapons + Shield + Car + Ravenger Claws (Go-Kart is a separate moveset)."
	m.InternalName = cfg.internal or "HAT_STAND"
	m.Assets = {}

	m.Enabled = true
	m.UseWithOtherMovesets = true
	m.StopOnExit = true -- leaving the moveset fully stops loops, hats, sounds, connections
	m.FEMode = true

	m.ActiveMode = cfg.mode or 1
	m.StandInOrbitMode = (cfg.standInOrbit ~= false) -- only used by the All module
	m.ActiveModeNames = {
		"1 Stand",
		"2 Place (BTools)",
		"3 Hat Orbit",
		"4 All (Stand+Place+Orbit)",
		"5 Feature module (no Stand/Place/Orbit)",
	}

	-- Stand
	m.SideOffset = 3.5
	m.ForwardOffset = 0
	m.HeightOffset = 0
	m.Smoothness = 60
	m.FaceSameWay = true
	m.OrbitStand = false
	m.OrbitSpeed = 0.7
	m.OrbitRadius = 5
	m.AutoBuild = true
	m.AutoLimbHats = true
	m.AutoSpareHats = true
	m.AllowUsedHats = false
	m.Keybinds = true
	m.StandScale = 1
	m.AnimSpeed = 1.1
	m.ShowHatNames = true
	m.IdleStyle = 1
	m.IdleStyleNames = {
		"1 Breathe", "2 Bounce", "3 Combat Ready",
		"4 Sway Dance", "5 Float", "6 None", "7 Baller",
	}
	m.MethodIndex = 1
	m.MethodNames = {
		"1 Side Stand", "2 Front Stand", "3 Orbit Stand",
		"4 Mirror Stand", "5 Freeze Place",
	}
	m.HatHead = ""
	m.HatTorso = ""
	m.HatLeftArm = ""
	m.HatRightArm = ""
	m.HatLeftLeg = ""
	m.HatRightLeg = ""
	m.SelectedOtherMoveset = ""
	m.PreviewText = "(refresh hats)"

	m.RotHeadX, m.RotHeadY, m.RotHeadZ = 0, 0, 0
	m.RotTorsoX, m.RotTorsoY, m.RotTorsoZ = 0, 0, 0
	m.RotLeftArmX, m.RotLeftArmY, m.RotLeftArmZ = 0, 0, 0
	m.RotRightArmX, m.RotRightArmY, m.RotRightArmZ = 0, 0, 0
	m.RotLeftLegX, m.RotLeftLegY, m.RotLeftLegZ = 0, 0, 0
	m.RotRightLegX, m.RotRightLegY, m.RotRightLegZ = 0, 0, 0

	-- Per-limb position offsets (side / up / forward) — move head, arms, torso, legs freely
	m.OffHeadX, m.OffHeadY, m.OffHeadZ = 0, 0, 0
	m.OffTorsoX, m.OffTorsoY, m.OffTorsoZ = 0, 0, 0
	m.OffLeftArmX, m.OffLeftArmY, m.OffLeftArmZ = 0, 0, 0
	m.OffRightArmX, m.OffRightArmY, m.OffRightArmZ = 0, 0, 0
	m.OffLeftLegX, m.OffLeftLegY, m.OffLeftLegZ = 0, 0, 0
	m.OffRightLegX, m.OffRightLegY, m.OffRightLegZ = 0, 0, 0

	m.ShowLimbPreview = false

	m.AutoCorrectDist = 25
	m.AutoCorrect = true

	-- Walk / Dance
	m.WalkWithMe = false
	m.WalkSideOffset = 2.8
	m.WalkForwardOffset = 0.5
	m.WalkHeightOffset = 0
	m.WalkSmoothness = 18
	m.WalkStrength = 1.0
	m.RunStrength = 1.15
	m.JumpStrength = 1.2
	m.WalkCycleSpeed = 8.5
	m.RunCycleSpeed = 12.5
	m.JumpHoldPose = true
	m.RunThreshold = 14
	m.DanceSync = true
	m.DanceStrength = 1.0
	m.DanceKey = true
	m.BallerMode = false
	m.BigRigFix = true
	m.BigRigArmSpread = 1.55
	m.BigRigLegSpread = 0.55
	m.BigRigHeight = 1.0
	m.FixAnyRigPose = true
	m.DanceMirrorCharacter = true

	-- v14: Link / Stand moveset / Loco v2
	m.LinkRigs = false
	m.LinkStrength = 1.0
	m.LinkSmooth = 26
	m.LinkSource = 1
	m.LinkSourceNames = { "1 Auto (Uhhhhhh rig, then avatar)", "2 Uhhhhhh rig only", "3 Avatar only" }
	m.StrictHats = true
	m.SelectFirst = false -- stand/clone auto-grab hats on build (set true if you want to pick hats first)
	m.PoseFix = true
	m.PoseAutoCalib = true
	m.PoseSnapAfterDance = true
	m.PoseSwapArms = false
	m.PoseInvertArmRoll = false
	m.PoseInvertArmPitch = false
	m.StandMoveset = 2
	m.StandMovesetNames = {
		"1 Linked (copy my moveset + dances)", "2 JoJo Stand", "3 Combat Ready", "4 Procedural Dance",
	}
	m.ProcDance = 1
	m.ProcDanceNames = { "1 Sway", "2 Floss", "3 Robot", "4 Disco", "5 Hype", "6 Wave" }
	m.SelectedDance = ""
	m.JojoLoco = true
	m.LocoBlend = 14
	m.LocoLean = 1.0
	m.LocoBob = 1.0
	m.LocoArmOut = 1.0
	m.FallSpread = 1.0
	m.LandSquash = 1.0

	-- v14: Clone (second body from spare hats) + 10 accessory slots with rot/offset/effects
	m.CloneEnabled = false
	m.CloneSide = -3.5
	m.CloneForward = 0.5
	m.CloneHeight = 0
	m.CloneSmooth = 22
	m.CloneFaceSame = true
	m.CloneAutoHats = true
	m.CloneHatHead = ""
	m.CloneHatTorso = ""
	m.CloneHatLeftArm = ""
	m.CloneHatRightArm = ""
	m.CloneHatLeftLeg = ""
	m.CloneHatRightLeg = ""
	-- per-limb rotation & position for clone (independent of stand)
	m.CloneRotHeadX, m.CloneRotHeadY, m.CloneRotHeadZ = 0, 0, 0
	m.CloneRotTorsoX, m.CloneRotTorsoY, m.CloneRotTorsoZ = 0, 0, 0
	m.CloneRotLeftArmX, m.CloneRotLeftArmY, m.CloneRotLeftArmZ = 0, 0, 0
	m.CloneRotRightArmX, m.CloneRotRightArmY, m.CloneRotRightArmZ = 0, 0, 0
	m.CloneRotLeftLegX, m.CloneRotLeftLegY, m.CloneRotLeftLegZ = 0, 0, 0
	m.CloneRotRightLegX, m.CloneRotRightLegY, m.CloneRotRightLegZ = 0, 0, 0
	m.CloneOffHeadX, m.CloneOffHeadY, m.CloneOffHeadZ = 0, 0, 0
	m.CloneOffTorsoX, m.CloneOffTorsoY, m.CloneOffTorsoZ = 0, 0, 0
	m.CloneOffLeftArmX, m.CloneOffLeftArmY, m.CloneOffLeftArmZ = 0, 0, 0
	m.CloneOffRightArmX, m.CloneOffRightArmY, m.CloneOffRightArmZ = 0, 0, 0
	m.CloneOffLeftLegX, m.CloneOffLeftLegY, m.CloneOffLeftLegZ = 0, 0, 0
	m.CloneOffRightLegX, m.CloneOffRightLegY, m.CloneOffRightLegZ = 0, 0, 0
	-- 10 extra accessory slots on the clone (hand/weapon/effect style)
	for i = 1, 10 do
		m["CloneSlotHat" .. i] = ""
		m["CloneSlotOffX" .. i] = 0
		m["CloneSlotOffY" .. i] = (i - 1) * 0.4 - 1.8
		m["CloneSlotOffZ" .. i] = 0
		m["CloneSlotRotX" .. i] = 0
		m["CloneSlotRotY" .. i] = 0
		m["CloneSlotRotZ" .. i] = 0
		m["CloneSlotKind" .. i] = 1 -- 1 float 2 weapon 3 effect 4 hand
	end
	m.CloneSlotKindNames = { "1 Float", "2 Weapon", "3 Effect", "4 Hand" }

	-- clone slots: 15 total (10 original + 5 new)
	for i = 11, 15 do
		m["CloneSlotHat" .. i] = ""
		m["CloneSlotOffX" .. i] = 0
		m["CloneSlotOffY" .. i] = (i - 11) * 0.4 - 1.8
		m["CloneSlotOffZ" .. i] = 0
		m["CloneSlotRotX" .. i] = 0
		m["CloneSlotRotY" .. i] = 0
		m["CloneSlotRotZ" .. i] = 0
		m["CloneSlotKind" .. i] = 1
	end

	-- Own dance (record Steve's Uhhhhhh dance, then stand / clone replay it by themselves)
	m.OwnDanceSpeed = 1
	m.OwnDanceLoop = true
	m.OwnDanceSounds = true
	m.OwnDanceBlend = 30
	m.OwnDanceRecSecs = 12

	-- Low-lag
	m.LowLag = true
	m.LowLagSkip = 2
	m.HatsSolid = false -- EVERY hat I wear becomes solid: hits / pushes NPCs, dummies and any unanchored part I simulate
	m.HatsSolidPush = 1 -- multiplies the real hat velocity that gets applied on contact
	m.HatsSolidIgnorePlayers = true -- no collision with other players
	m.HatsSolidBoost = true -- huge simulation radius so nearby unanchored parts are simulated by me

	-- TITAN (body from hats, placed every frame like Hellcopter)
	m.TitanEnabled = false
	m.TitanScale = 3.5
	m.TitanSmooth = 22
	m.TitanSide, m.TitanHeight, m.TitanForward = 0, 0, 0
	m.TitanRotX, m.TitanRotY, m.TitanRotZ = 0, 0, 0
	m.TitanHatCore = ""
	m.TitanCoreOffX, m.TitanCoreOffY, m.TitanCoreOffZ = 0, 1.0, -0.35
	m.TitanCoreRotX, m.TitanCoreRotY, m.TitanCoreRotZ = 0, 0, 0
	m.TitanHatHead = ""
	m.TitanHatTorso = ""
	m.TitanHatLeftArm = ""
	m.TitanHatRightArm = ""
	m.TitanHatLeftLeg = ""
	m.TitanHatRightLeg = ""
	m.TitanHatJetpack = ""
	m.TitanJetpackOffX, m.TitanJetpackOffY, m.TitanJetpackOffZ = 0, 0.4, 1.4
	m.TitanJetpackRotX, m.TitanJetpackRotY, m.TitanJetpackRotZ = 0, 0, 0
	m.TitanFly = false
	m.TitanFlySpeed = 70
	m.TitanAnim = true
	m.TitanAnimSpeed = 1
	m.TitanAutoRebuild = true
	m.TitanRebuildDelay = 0.08 -- seconds between auto-rebuild checks (lower = faster)
	m.TitanShieldEnabled = false
	m.TitanShieldHat = ""
	m.TitanShieldOffX, m.TitanShieldOffY, m.TitanShieldOffZ = 0, 1, -2.5
	-- Core FIRE: burst hat out fast, trail, snap back to core
	m.TitanCoreFireEnabled = true
	m.TitanCoreFireHat = "" -- hat used as the flame / projectile
	m.TitanCoreTrailHat = "" -- optional second hat for trailing behind the burst
	m.TitanCoreFireDist = 40
	m.TitanCoreFireSpeed = 180 -- outward speed
	m.TitanCoreFireReturn = 220 -- snap-back speed
	m.TitanCoreFireCooldown = 0.45
	m.TitanCoreFireCount = 1 -- how many bursts
	m.KeyTitanFly = "T"
	m.KeyTitanCoreFire = "Y"
	for _, limb in ipairs({ "Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg" }) do
		m["TitanOff" .. limb .. "X"] = 0
		m["TitanOff" .. limb .. "Y"] = 0
		m["TitanOff" .. limb .. "Z"] = 0
		m["TitanRot" .. limb .. "X"] = 0
		m["TitanRot" .. limb .. "Y"] = 0
		m["TitanRot" .. limb .. "Z"] = 0
	end
	m.TitanStyle = 1
	m.TitanStyleNames = { "1 Titan Cameraman", "2 Titan Speakerman", "3 Titan TV Man", "4 Custom" }

	-- HELLCOPTER (frames + propellers + weapons with hat bullets + physics ride)
	m.HeliEnabled = false
	m.HeliRide = false
	m.HeliEngine = false
	m.HeliAutoStart = true
	m.HeliPhysics = true
	m.HeliHoverAssist = true
	m.HeliAutoRebuild = true
	m.HeliSide, m.HeliHeight, m.HeliForward, m.HeliRotY = 8, 2, 0, 0
	m.HeliSeatOffY = -1.0
	m.HeliSmooth = 14
	m.HeliMaxSpeed = 120
	m.HeliClimb = 45
	m.HeliYawRate = 1.8
	m.HeliAccel = 2.5
	m.HeliTilt = 22
	m.HeliSpoolUp = 4
	m.HeliSpoolDown = 6
	m.HeliGravity = 1.0
	m.HeliCamLock = false
	m.HeliCamSmooth = 10
	m.HeliSFX = true
	m.HeliVolume = 1.0
	m.HeliPitch = 1
	m.HeliEngineMode = 1 -- 1 startup + idle (Roblox ids), 2 generated sound
	m.HeliEngineModeNames = { "1 Startup + Idle (your ids)", "2 Generated" }
	m.HeliStartSFXId = "rbxassetid://130598569401747" -- helicopter turn on
	m.HeliIdleSFXId = "rbxassetid://9073648220" -- helicopter idle loop
	m.HeliMiniSFX = true
	m.HeliMiniVolume = 1
	m.HeliMiniLoopId = "rbxassetid://138382899505069" -- minigun shoot loop
	m.HeliMiniStopId = "rbxassetid://130364388010467" -- minigun shoot stop
	m.KeyHeliRide = "F6" -- rebindable: Heli Ride (mount/dismount)
	m.KeyHeliEngine = "F7"
	m.KeyHeliFire = "F8"
	for i = 1, 12 do
		m["HeliFrameHat" .. i] = ""
		for _, p in ipairs({ "OffX", "OffY", "OffZ", "RotX", "RotY", "RotZ" }) do m["HeliFrame" .. p .. i] = 0 end
	end
	for i = 1, 4 do
		m["HeliPropHat" .. i] = ""
		for _, p in ipairs({ "OffX", "OffY", "OffZ", "RotX", "RotY", "RotZ" }) do m["HeliProp" .. p .. i] = 0 end
		m["HeliPropAxis" .. i] = 2
		m["HeliPropSpd" .. i] = 40
	end
	for i = 1, 4 do
		m["HeliWpnHat" .. i] = ""
		m["HeliWpnBullet" .. i] = ""
		m["HeliWpnBullet2" .. i] = ""
		m["HeliWpnFire" .. i] = true
		for _, p in ipairs({ "OffX", "OffY", "OffZ", "RotX", "RotY", "RotZ" }) do m["HeliWpn" .. p .. i] = 0 end
	end
	m.HeliAxisNames = { "1 X", "2 Y", "3 Z" }
	m.HeliFireStyle = 2
	m.HeliFireStyleNames = { "1 Single (click)", "2 Rapid", "3 Minigun", "4 Triple burst" }
	m.HeliBulletSpeed = 260
	m.HeliBulletRange = 260
	m.HeliCooldown = 0.14
	m.HeliSpread = 1.5
	m.HeliBulletSpin = true
	m.HeliTrail = true
	m.HeliBulletFallback = true
	m.HeliAimMouse = true
	m.HeliFireSFX = true
	m.HeliBulletRotX, m.HeliBulletRotY, m.HeliBulletRotZ = 0, 0, 0
	m.HeliFly = true -- off = the hellcopter can't be ridden / flown (P toggles, rebindable)
	m.KeyHeliOff = "P"
	m.HeliRebuildDelay = 0.1 -- seconds between auto-rebuild checks (how fast lost hats get put back)
	-- missile launcher
	m.HeliMissileEnabled = true
	m.KeyHeliMissile = "R"
	m.HeliMissileSFX = true
	m.HeliMissileVolume = 1 -- master
	m.HeliMissileLockVol = 0.8 -- lock-on beep
	m.HeliMissileLockSpeed = 1 -- lock sound playback speed (1 = normal)
	m.HeliMissileLockKeep = true -- lock sound keeps playing while locked, stops when the lock is lost
	m.HeliMissileLoopVol = 1 -- missile flying loop
	m.HeliMissileExplodeVol = 1 -- explosion
	m.HeliMissileLockSFXId = "rbxassetid://80778827175175" -- GTA V missile lock sound (loops while locking)
	m.HeliMissileExplodeSFXId = "rbxassetid://134741557832342" -- loud missile explosion
	m.HeliMissileLoopSFXId = "rbxassetid://117162697204649" -- missile flying loop
	m.HeliMissileCooldown = 1.5
	m.HeliMissileSpeed = 150
	m.HeliMissileTurn = 3.5
	m.HeliMissileLife = 8
	m.HeliMissileRange = 600
	m.HeliMissileLockTime = 1.0
	m.HeliMissileLockRadius = 140
	m.HeliMissileExplosion = true
	m.HeliMissileExplosionSize = 12
	m.HeliMissileNPC = false
	m.HeliMissileRotX, m.HeliMissileRotY, m.HeliMissileRotZ = 0, 0, 0
	for i = 1, 4 do m["HeliMissileHat" .. i] = "" end
	-- missile launcher hats (the visible launchers mounted on the helicopter): hat + position + rotation each
	m.HeliLaunchAim = true -- launchers swing toward your lock target / mouse
	m.HeliLaunchSmooth = false -- false = stays rigidly in place on the helicopter, true = smooth follow (lags a little)
	m.HeliLaunchSmoothSpeed = 6
	m.KeyHeliLauncher = "T" -- missile launcher ON / OFF (armed / disarmed)
	for i = 1, 4 do -- each missile can have its own position + rotation
		m["HeliMissileOffX" .. i], m["HeliMissileOffY" .. i], m["HeliMissileOffZ" .. i] = 0, 0, 0
		m["HeliMissileRotX" .. i], m["HeliMissileRotY" .. i], m["HeliMissileRotZ" .. i] = 0, 0, 0
	end
	for i = 1, 2 do
		m["HeliLaunchHat" .. i] = ""
		m["HeliLaunchOffX" .. i] = (i == 1) and -2.5 or 2.5
		m["HeliLaunchOffY" .. i], m["HeliLaunchOffZ" .. i] = -1, 0
		m["HeliLaunchRotX" .. i], m["HeliLaunchRotY" .. i], m["HeliLaunchRotZ" .. i] = 0, 0, 0
	end
	-- mouse flight control
	m.HeliMouseCtl = false
	m.HeliMouseMode = 1
	m.HeliMouseModeNames = { "1 Flight stick (cursor left/right of center turns)", "2 Face the mouse (heli turns toward where the mouse points)" }
	m.HeliMouseSens = 1.5
	m.HeliMouseDead = 0.12
	m.HeliMouseClimb = false -- cursor above / below screen center = climb / descend
	m.KeyHeliMouse = "F9"
	m.HeliHoming = true -- bullets curve toward the mouse (mouse tracker)
	m.HeliSolid = false -- heli hats become solid so they hit / push NPCs and dummies
	m.HeliSolidFrames, m.HeliSolidProps, m.HeliSolidWpns = true, true, true
	m.HeliSolidPush = 1 -- how hard the moving hats push (multiplies the heli's real velocity)
	m.HeliSolidIgnorePlayers = true -- never collide with other players (only NPCs / dummies / map)
	m.HeliSolidBoost = true -- keep the simulation radius huge so nearby NPC parts are simulated by me
	m.HeliAimAssist = true -- aim snaps onto a player / NPC / missile near the cursor (bullets chase it instead of the ground behind it)
	m.HeliAimAssistRadius = 90 -- pixels around the cursor
	m.HeliHomingStrength = 4
	m.HeliTrailColor = 1
	m.HeliTrailColorNames = { "1 Fire orange", "2 Ice blue", "3 Toxic green", "4 Purple", "5 Red", "6 White", "7 Rainbow" }
	m.HeliTrailLife = 0.35
	m.HeliTrailWidth = 1.2
	for i = 1, 8 do m["HeliAmmoHat" .. i] = "" end -- shared bullet hats: any weapon can shoot these
	-- group offsets: move ALL frames / ALL propellers / ALL weapons together (side, up/down, forward/back)
	for _, g in ipairs({ "HeliFramesAll", "HeliPropsAll", "HeliWpnsAll" }) do
		m[g .. "X"], m[g .. "Y"], m[g .. "Z"] = 0, 0, 0
	end


	-- Place
	m.PlaceEnabled = false
	m.PlacePreviewOn = true
	m.PlaceSpin = false
	m.PlaceSpinSpeed = 2.0
	m.PlaceBob = false
	m.PlaceBobSpeed = 1.5
	m.PlaceBobHeight = 0.4
	m.PlaceSnapGrid = 0
	m.PlaceMax = 80
	m.PlaceActiveSlot = 1
	m.PlaceBuildAnim = true
	m.PlaceBuildAnimSpeed = 1.2
	m.PlacePersist = true
	m.PlaceLock = true -- placed real hats stay: kept visible, repaired, and re-grabbed if the rig reloads
	m.PlaceCustomAnim = true
	m.PlaceYeetForce = 80
	m.PlaceYeetUp = 40
	m.PlaceUndergroundOnSelect = false -- when you pick a place slot, stash that hat underground until place
	m.PlaceUndergroundDepth = 12
	m.PlaceUndergroundSpeed = 0.25 -- rise/sink time
	m.PlaceStayAfterRespawn = true -- even on loop respawns, placed hats stay at last CF
	m.PlaceSolid = true -- placed / built hats are solid: your rig can stand and walk on them
	for i = 1, 10 do
		m["PlaceHat" .. i] = ""
		m["PlaceRot" .. i .. "X"] = 0
		m["PlaceRot" .. i .. "Y"] = 0
		m["PlaceRot" .. i .. "Z"] = 0
		m["PlaceOff" .. i .. "X"] = 0
		m["PlaceOff" .. i .. "Y"] = 0
		m["PlaceOff" .. i .. "Z"] = 0
	end
	-- BTools Build Modes (presets that arrange place slots into structures)
	m.BToolsMode = 1
	m.BToolsModeNames = {
		"1 Free / Manual", "2 Wall", "3 Floor", "4 House", "5 Tower",
		"6 Bridge", "7 Platform", "8 Stairs", "9 Fence", "10 Gate",
		"11 Car Frame", "12 Helicopter", "13 Boat", "14 Plane", "15 Throne",
		"16 Arch", "17 Pyramid", "18 Dome", "19 Ring", "20 Fort",
		"21 Table", "22 Chair", "23 Cage", "24 Ramp", "25 Spiral Stairs",
		"26 Double Wall", "27 Corridor", "28 Zigzag Wall", "29 Descending Stairs", "30 Pillars",
		"31 Cross", "32 X Shape", "33 Diamond", "34 Star", "35 Heart",
		"36 Floor Spiral", "37 Double Ring", "38 Cube Frame", "39 Skyscraper", "40 Windmill",
		"41 Pen / Enclosure", "42 Ziggurat", "43 Lighthouse", "44 Totem", "45 Couch",
		"46 Bench", "47 Shelf", "48 Ladder", "49 Slide", "50 Half-Pipe",
		"51 Vertical Loop", "52 Wave Wall", "53 Snake Path", "54 Parkour Path", "55 Bed",
		"56 Bunker", "57 Pier", "58 Torii Gate", "59 Crown", "60 Ferris Wheel",
		"61 Rocket", "62 Hourglass", "63 DNA Helix", "64 Tornado", "65 Podium",
	}
	m.BToolsScale = 1.0 -- overall size of preset
	m.BToolsSpacing = 2.5 -- stud spacing between parts
	m.BToolsPreviewAll = true -- show full structure ghost preview
	m.BToolsClickBuild = true -- click / Y places the WHOLE structure from every filled Place Slot
	m.BToolsCarry = false -- after build, carry the whole structure with you
	m.BToolsCarrySmooth = 14
	m.BToolsBuildName = "MyBuild"
	m.BToolsSavedBuilds = {} -- { name = { slots = { {hat,offX,offY,offZ,rotX,rotY,rotZ}, ... } } }
	m.BToolsLastSaved = ""

	-- Orbit (per-slot extras) — Undertale Finale style + modes
	m.OrbitEnabled = false
	for i = 1, 10 do
		m["OrbitHat" .. i] = ""
		m["OrbitSpdMult" .. i] = 1
		m["OrbitRadOff" .. i] = 0
		m["OrbitRotX" .. i] = 0
		m["OrbitRotY" .. i] = 0
		m["OrbitRotZ" .. i] = 0
		m["OrbitVertOff" .. i] = 0 -- per-slot vertical offset
	end
	m.OrbitRad = 6
	m.OrbitSpd = 1.0
	m.OrbitH = 2.0
	m.OrbitFaceOut = true
	m.OrbitSpinSelf = false
	m.OrbitSpinSelfSpd = 3
	m.OrbitMode = 1 -- 1..30+ modes
	m.OrbitModeNames = {
		"1 Circle", "2 Line", "3 Solar System", "4 Figure-8", "5 Helix",
		"6 Wave", "7 Spiral", "8 Ring Stack", "9 Random Drift", "10 Undertale Finale",
		"11 Rose Curve", "12 Infinity", "13 DNA Double Helix", "14 Cube Faces", "15 Pyramid",
		"16 Star Path", "17 Tornado", "18 Butterfly", "19 Flower Bloom", "20 Orbit Rings",
		"21 Sine Weave", "22 Pendulum", "23 Galaxy Spiral", "24 Grid Lattice", "25 Sphere Surface",
		"26 Triangle Path", "27 Heart Shape", "28 Cross Orbit", "29 Chaotic Swarm", "30 Rain Fall",
		"31 Vertical Circle", "32 Horizontal Figure-8", "33 Expanding Pulse", "34 Zigzag", "35 Crown Arc",
		"36 Vertical Figure-8", "37 Angel Wings", "38 Halo", "39 Saturn Ring", "40 Atom",
		"41 Gyroscope", "42 Shield Arc (front)", "43 Cape Arc (back)", "44 Elevator Ring", "45 Bounce Ring",
		"46 Square Path", "47 Hexagon Path", "48 Pentagram Path", "49 Spirograph", "50 Lissajous",
		"51 Trefoil Knot", "52 Torus Knot", "53 Hourglass Swirl", "54 Cone", "55 Funnel",
		"56 Fountain", "57 Bubbles", "58 Conga Line", "59 Snake Weave", "60 Comet Ellipse",
		"61 Shockwave", "62 Counter-Rotate", "63 Forward Wheel", "64 Triple Helix", "65 Fibonacci Sphere",
		"66 Möbius Strip", "67 Dual Ring", "68 Orbit Ladder", "69 Pulsar", "70 Diamond Path",
		"71 Crescent Moon", "72 Vortex Tunnel", "73 Ribbon Wave", "74 Cage Box", "75 Solar Flare",
		"76 Twin Orbit", "77 Vertical Helix", "78 Orbit Cascade", "79 Star Cross", "80 Planetary Dance",
	}
	m.OrbitVertical = true -- allow up/down motion
	m.OrbitVertAmp = 1.5 -- amplitude of vertical bob/orbit
	m.OrbitVertSpd = 0.8
	m.OrbitFinalePulse = true -- finale mode: pulse radius like Undyne/Finale
	m.OrbitFinalePulseAmt = 2.0
	m.OrbitFinalePulseSpd = 2.5
	m.OrbitAutoRebuild = true -- auto rebuild when hats change / slot set

	-- Gaster Blaster
	m.GasterEnabled = false
	m.GasterHat = "" -- legacy / slot 1 fallback
	m.GasterActiveSlot = 1
	for i = 1, 5 do
		m["GasterHat" .. i] = ""
		m["GasterSide" .. i] = 4.5 + (i - 1) * 0.8
		m["GasterHeight" .. i] = 1.2
		m["GasterForward" .. i] = -1
		m["GasterRotX" .. i] = 0
		m["GasterRotY" .. i] = 0
		m["GasterRotZ" .. i] = 0
		m["GasterFire" .. i] = true -- included in fire rotation
	end
	m.GasterSide = 4.5
	m.GasterHeight = 1.2
	m.GasterForward = -1
	m.GasterSize = 1.4
	m.GasterLaserLength = 80
	m.GasterLaserThick = 1.2
	m.GasterCooldown = 1.4
	m.GasterChargeTime = 0.35
	m.GasterPush = 45
	m.GasterColor = Color3.fromRGB(255, 255, 255)
	m.GasterUseHatBullet = false -- toggle: fire real hat bullet instead of / with laser
	m.GasterHatBullet = "" -- hat to use as bullet
	m.GasterTrailOsc = true -- after fire: hat bullet goes back & forth creating trails
	m.GasterTrailOscSpeed = 18 -- how fast the oscillation
	m.GasterTrailOscDist = 12 -- distance of back-forth
	m.GasterTrailOscTime = 1.2 -- how long oscillation lasts
	m.GasterSFX = true
	m.GasterSFXId = "rbxassetid://138081500" -- charge-ish default (change freely)
	m.GasterFireSFXId = "rbxassetid://138081308"
	m.GasterVolume = 1.0
	m.GasterTrackMouse = true -- aim / orient blasters toward mouse
	m.GasterTrackOnlyFire = false -- if true, only track while charging/firing
	m.GasterFireMode = 1 -- 1 = active slot only, 2 = all enabled slots at once
	m.GasterFireModeNames = { "1 Active slot only", "2 All enabled slots at once" }

	-- Bone attack (hat-based, Sans-style)
	m.BoneEnabled = false
	m.BoneHat = ""
	m.BoneSide = -3.5
	m.BoneHeight = 0.5
	m.BoneForward = -1
	m.BoneCount = 5 -- how many bones spawn in a row
	m.BoneSpread = 2.5
	m.BoneSpeed = 90
	m.BoneLife = 1.8
	m.BoneCooldown = 0.9
	m.BoneRise = 0.25
	m.BoneColor = Color3.fromRGB(255, 255, 255)
	m.BoneUseRealHat = true -- use the real FE hat as the bone projectile
	m.BoneSFX = true
	m.BoneSFXId = "rbxassetid://138081308"
	m.BoneVolume = 0.9
	m.BoneTrackMouse = true
	-- Sans attacks (Gaster / Bone / Omega): hats sit underground until you fire, then rise + attack + sink
	m.SansUnderground = true
	m.SansStashDepth = 12
	m.SansStashRise = 0.35
	m.SansStashHold = 1.0

	-- Omega Blaster (big dual/single hat blast)
	m.OmegaEnabled = false
	m.OmegaHat = ""
	m.OmegaHat2 = "" -- second hat when dual mode
	m.OmegaDual = true -- toggle: 2 bullets/blasters or 1
	m.OmegaSide = 0
	m.OmegaHeight = 2.5
	m.OmegaForward = -2
	m.OmegaSize = 2.2
	m.OmegaLaserLength = 120
	m.OmegaLaserThick = 2.4
	m.OmegaCooldown = 2.2
	m.OmegaChargeTime = 0.55
	m.OmegaPush = 80
	m.OmegaColor = Color3.fromRGB(180, 220, 255)
	m.OmegaTrackMouse = true
	m.OmegaSFX = true
	m.OmegaSFXId = "rbxassetid://138081500"
	m.OmegaFireSFXId = "rbxassetid://138081308"
	m.OmegaVolume = 1.2
	m.OmegaSpread = 3.5 -- horizontal split when dual
	m.OmegaRotX, m.OmegaRotY, m.OmegaRotZ = 0, 0, 0
	m.OmegaTrackOnlyFire = false -- if true, only aim at mouse while charging/firing
	m.OmegaStashDepth = 0 -- 0 = use SansStashDepth
	m.OmegaStashRise = 0 -- 0 = use SansStashRise
	m.OmegaStashHold = 0 -- 0 = use SansStashHold
	m.OmegaRiseBeforeFire = true -- wait until fully up before laser
	m.OmegaUseHatBullet = false -- fly a real hat down each beam
	m.OmegaActiveSlot = 1
	m.OmegaFireMode = 2 -- 1 = active slot only, 2 = all enabled slots at once
	m.OmegaFireModeNames = { "1 Active slot only", "2 All enabled slots at once" }
	m.OmegaTrailOsc = true -- after the hat bullet reaches the end it goes back & forth along the beam
	m.OmegaTrailOscSpeed = 18
	m.OmegaTrailOscDist = 12
	m.OmegaTrailOscTime = 1.2
	do
		local sides = { -1.75, 1.75, -5.25, 5.25, 0 }
		local heights = { 2.5, 2.5, 3.5, 3.5, 5 }
		for i = 1, 5 do
			if i >= 3 then
				m["OmegaHat" .. i] = ""
				m["OmegaBulletHat" .. i] = ""
			end
			m["OmegaSide" .. i] = sides[i]
			m["OmegaHeight" .. i] = heights[i]
			m["OmegaForward" .. i] = -2
			m["OmegaRotX" .. i] = 0
			m["OmegaRotY" .. i] = 0
			m["OmegaRotZ" .. i] = 0
			m["OmegaFire" .. i] = true
		end
	end
	m.KeyOmegaCycle = "O"
	m.KeySansToggle = "U" -- sink / raise ALL sans attacks (Gaster + Bone + Omega)
	m.OmegaBulletHat = "" -- bullet hat for blaster 1
	m.OmegaBulletHat2 = "" -- bullet hat for blaster 2 (dual)
	m.OmegaBulletSpeed = 220
	m.OmegaBulletSpin = true
	m.OmegaBulletTrail = true
	m.OmegaKeepUpWhileCharge = true -- stay up for whole charge + hold

	-- Weapons (10 slots, all float next to you; each has its own hat / position / rotation)
	m.WeaponEnabled = false
	m.WeaponStayUp = false -- toggle: weapons stay raised above you until you turn this off
	m.WeaponStayUpHeight = 3.5 -- extra height when Stay Up is ON
	m.WeaponActiveSlot = 1
	m.WeaponFloatSide = 1.8
	m.WeaponFloatHeight = 0.6
	m.WeaponFloatForward = -0.4
	m.WeaponRotX, m.WeaponRotY, m.WeaponRotZ = 0, 90, 0
	m.WeaponFireSpeed = 120
	m.WeaponFireCooldown = 0.25
	m.WeaponBulletLife = 2.5
	for i = 1, 10 do
		m["WeaponHat" .. i] = ""
		m["WeaponBullet" .. i] = 1 -- 1=beam 2=orb 3=spike 4=hat
		m["WeaponBulletHat" .. i] = ""
		m["WeaponFire" .. i] = (i <= 6) -- in the fire rotation (max 6 enabled)
		m["WeaponOffsetX" .. i] = 0
		m["WeaponOffsetY" .. i] = (i - 1) * 0.5 - 2.25 -- spread so slots do not stack
		m["WeaponOffsetZ" .. i] = 0
		m["WeaponRot" .. i .. "X"] = 0
		m["WeaponRot" .. i .. "Y"] = 0
		m["WeaponRot" .. i .. "Z"] = 0
	end
	m.WeaponBulletNames = { "1 Beam", "2 Orb", "3 Spike", "4 Hat", "5 Gaster Blaster", "6 Laser" }
	m.WeaponAntiSnap = true -- keep weapon / bullet hats free of Uhhhhhh (re-apply position pre-physics + before render)
	m.WeaponTrackMouse = true
	m.WeaponTrackMode = 2 -- 1 always, 2 only while firing (plus hold time)
	m.WeaponTrackModeNames = { "1 Always track mouse", "2 Only when I use the weapon" }
	m.WeaponTrackStrength = 1
	m.WeaponTrackSmooth = 12
	m.WeaponTrackPitch = true
	m.WeaponTrackHold = 1.5
	m.WeaponAimMouse = true
	m.WeaponAutoFire = false
	m.WeaponMuzzleFlash = true
	m.WeaponRecoil = 0.6
	m.WeaponRecoilSpeed = 7
	m.WeaponBobAmt = 0
	m.WeaponBobSpeed = 2
	m.WeaponFireMode = 1 -- 1 = one bullet per press, rotating through enabled slots; 2 = all enabled slots at once
	m.WeaponFireModeNames = { "1 One then next (rotate)", "2 All enabled at once" }
	m.UndergroundStash = false -- weapons / hat bullets / Gaster / blaster wait underground until used
	m.StashDepth = 10
	m.StashRise = 0.3
	m.StashHold = 1.2
	m.WeaponBlasterScale = 1
	m.WeaponBlasterCharge = 0.5
	m.WeaponLaserLength = 200
	m.WeaponLaserTime = 0.2
	m.WeaponRealHat = true -- hat bullets are the real FE hat (flies out and returns); off = local clones
	m.WeaponBulletSize = 1
	m.WeaponBulletR, m.WeaponBulletG, m.WeaponBulletB = 255, 220, 80
	m.WeaponBulletSpin = 0
	m.WeaponHoming = 0
	m.WeaponGravity = 0
	m.WeaponBurst = 1
	m.WeaponSpread = 8
	m.WeaponStopOnHit = true
	m.WeaponHitFX = true
	m.WeaponReturnSpeed = 140
	m.WeaponTrail = true
	m.WeaponRainbow = false
	m.WeaponTrailLife = 0.6
	m.WeaponTrailWidth = 1
	m.WeaponTrailR, m.WeaponTrailG, m.WeaponTrailB = 255, 180, 60
	-- Per-slot multi-bullet (5+ bullets per slot, hat bullets allowed)
	for i = 1, 10 do
		m["WeaponBurst" .. i] = 1 -- 1..12 bullets this slot fires
		m["WeaponHatBulletCount" .. i] = 1 -- how many hat-bullets this slot can use at once
	end
	m.WeaponMaxBurst = 12
	m.WeaponSFX = true
	m.WeaponFireSFXId = "rbxassetid://131961136" -- generic shot
	m.WeaponHitSFXId = "rbxassetid://9116382851"
	m.WeaponVolume = 0.85

	-- Shield
	m.ShieldEnabled = false
	m.ShieldHat = ""
	m.ShieldMode = 1 -- 1=hold front 2=free place 3=grab
	m.ShieldModeNames = { "1 Hold Front", "2 Free Place", "3 Grab" }
	m.ShieldSide = 0
	m.ShieldHeight = 1
	m.ShieldForward = -2.2
	m.ShieldRotX, m.ShieldRotY, m.ShieldRotZ = 0, 0, 0
	m.ShieldScale = 1.3
	m.ShieldAutoFace = true
	m.ShieldBob = false
	m.ShieldBobSpeed = 1.2
	m.ShieldBobAmt = 0.25
	m.ShieldSpin = false
	m.ShieldSpinSpeed = 2
	m.ShieldUnderground = false -- stash shield underground until you press the shield key
	m.ShieldStashDepth = 10
	m.ShieldStashRise = 0.3

	m.ShieldStashHold = 0 -- 0 = stay up until you press the key again, >0 = sink after N seconds

	-- Ravenger Claws (left/right claws or arms + optional head; per-piece place + rot)
	m.ClawsEnabled = false
	m.ClawsLeftHat = ""
	m.ClawsRightHat = ""
	m.ClawsHeadHat = ""
	m.ClawsScale = 1.8
	m.ClawsSide = 1.6
	m.ClawsHeight = 0.4
	m.ClawsForward = -0.8
	m.ClawsRotX, m.ClawsRotY, m.ClawsRotZ = 0, 0, 0
	m.ClawsLeftOffX, m.ClawsLeftOffY, m.ClawsLeftOffZ = 0, 0, 0
	m.ClawsLeftRotX, m.ClawsLeftRotY, m.ClawsLeftRotZ = 0, 0, 0
	m.ClawsRightOffX, m.ClawsRightOffY, m.ClawsRightOffZ = 0, 0, 0
	m.ClawsRightRotX, m.ClawsRightRotY, m.ClawsRightRotZ = 0, 0, 0
	m.ClawsHeadOffX, m.ClawsHeadOffY, m.ClawsHeadOffZ = 0, 1.4, 0
	m.ClawsHeadRotX, m.ClawsHeadRotY, m.ClawsHeadRotZ = 0, 0, 0
	m.ClawsIdleBob = true
	m.ClawsBobSpeed = 2.2
	m.ClawsBobAmt = 0.12
	m.ClawsComboCooldown = 0.28
	m.ClawsPushCooldown = 1.1
	m.ClawsSpinCooldown = 2.4
	m.ClawsComboRange = 8
	m.ClawsPushForce = 55
	m.ClawsPushUp = 18
	m.ClawsSpinSpeed = 14
	m.ClawsSpinDuration = 0.85
	m.ClawsSpinRadius = 4.5
	m.ClawsTrackMouse = false
	m.ClawsBloodTrail = true
	m.ClawsSFX = true
	m.ClawsSlashSFXId = "rbxassetid://131961136"
	m.ClawsPushSFXId = "rbxassetid://138081308"
	m.ClawsSpinSFXId = "rbxassetid://138081500"
	m.ClawsVolume = 0.95
	m.ClawsAnims = true -- idle / walk / run / jump / fall animations for the claws
	m.ClawsAnimStrength = 1.0
	m.ClawsAnimBlend = 12
	m.ClawsKeysEnabled = true -- attack keybinds ON/OFF (toggle with KeyClawsKeysToggle)
	m.KeyClawsKeysToggle = "F6" -- attack keys ON/OFF
	m.KeyClawsTrackToggle = "F7" -- mouse tracking ON/OFF
	m.KeyClawsRage = "F8" -- rage mode ON/OFF
	m.KeyClawsLaser = "H"
	m.KeyClawsSlam = "I"
	m.ClawsRage = false
	m.ClawsRageMul = 1.6 -- cooldowns / anim speed multiplier while raging
	m.ClawsLaserUseHat = true -- fly the bullet hat down the beam
	m.ClawsLaserHat = "" -- bullet hat (must be a different hat than the claws)
	m.ClawsLaserDual = true -- fire from both claws (off = alternate L/R)
	m.ClawsLaserAim = true -- aim at mouse (off = straight ahead)
	m.ClawsLaserCooldown = 1.6
	m.ClawsLaserCharge = 0.25
	m.ClawsLaserLength = 140
	m.ClawsLaserThick = 1.2
	m.ClawsLaserR, m.ClawsLaserG, m.ClawsLaserB = 255, 60, 60
	m.ClawsLaserBulletSpeed = 220
	m.ClawsLaserBulletSpin = true
	m.ClawsLaserTrail = true
	m.ClawsLaserTrailOsc = true -- after reaching the end the hat goes back & forth
	m.ClawsLaserTrailOscDist = 12
	m.ClawsLaserTrailOscSpeed = 18
	m.ClawsLaserTrailOscTime = 1.0
	m.ClawsSlamCooldown = 2.0
	m.ClawsSlamRadius = 14
	m.KeyClawsCombo = "Z"
	m.KeyClawsPush = "X"
	m.KeyClawsSpin = "C"

	-- Rebindable keys (KeyCode names)
	m.KeyGaster = "Q"
	m.KeyGasterCycle = "M"
	m.KeyBone = "L"
	m.KeyOmega = "K"
	m.KeyShield = "J" -- raise / lower shield from underground (when Shield Underground Stash is ON)
	m.KeyShieldPlace = "Y"
	m.KeySans = "P" -- fires every enabled Sans attack at once (Gaster + Bone + Omega)
	m.KeyNames = {
		"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
		"One","Two","Three","Four","Five","Six","Seven","Eight","Nine","Zero",
		"F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12",
		"MouseButton2","MouseButton3",
	}

	-- Car
	m.CarEnabled = false
	m.CarRide = false
	m.CarSpeedBoost = 1.35
	m.CarSide = 6
	m.CarHeight = 0
	m.CarForward = 0
	m.CarRotY = 0
	m.CarSmooth = 12
	for i = 1, 8 do
		m["CarHat" .. i] = ""
		m["CarOffX" .. i] = 0
		m["CarOffY" .. i] = 0
		m["CarOffZ" .. i] = 0
		m["CarRotX" .. i] = 0
		m["CarRotY" .. i] = 0
		m["CarRotZ" .. i] = 0
	end
	-- Car wheels (4) + engine
	m.CarWheelSpin = true
	m.CarWheelSpinSpd = 12
	for i = 1, 4 do
		m["CarWheelHat" .. i] = ""
		m["CarWheelOffX" .. i] = ({ -1.8, 1.8, -1.8, 1.8 })[i]
		m["CarWheelOffY" .. i] = -0.6
		m["CarWheelOffZ" .. i] = ({ 1.6, 1.6, -1.6, -1.6 })[i]
		m["CarWheelRotX" .. i] = 0
		m["CarWheelRotY" .. i] = 0
		m["CarWheelRotZ" .. i] = 90
	end
	m.CarEngineHat = ""
	m.CarEngineOffX, m.CarEngineOffY, m.CarEngineOffZ = 0, 0.4, -1.8
	m.CarEngineRotX, m.CarEngineRotY, m.CarEngineRotZ = 0, 0, 0
	m.CarEngineBob = true
	m.CarEngineBobAmt = 0.08
	m.CarEngineBobSpd = 18

	-- Ball system (10 slots: choose hat as ball, yeet, mouse track)
	m.BallEnabled = false
	m.BallActiveSlot = 1
	m.BallTrackMouse = true
	m.BallTrackStrength = 1
	m.BallFloatSide = 2.2
	m.BallFloatHeight = 1.0
	m.BallFloatForward = -0.5
	m.BallYeetForce = 90
	m.BallYeetUp = 35
	m.BallGravity = 40
	m.BallBounce = 0.55
	m.BallLife = 4
	m.BallReturn = true
	m.BallReturnSpeed = 100
	m.BallSize = 1.2
	m.BallSpin = true
	m.BallSpinSpd = 8
	m.BallKey = "Zero" -- yeet active ball (rebindable)
	for i = 1, 10 do
		m["BallHat" .. i] = ""
		m["BallOffX" .. i] = 0
		m["BallOffY" .. i] = (i - 1) * 0.35 - 1.5
		m["BallOffZ" .. i] = 0
		m["BallRotX" .. i] = 0
		m["BallRotY" .. i] = 0
		m["BallRotZ" .. i] = 0
		m["BallKind" .. i] = 1 -- 1 float 2 bounce 3 homing 4 sticky
	end
	m.BallKindNames = { "1 Float", "2 Bounce", "3 Homing", "4 Sticky" }

	-- PLANETS (10 slots, solar-system style orbit around you)
	m.PlanetEnabled = false
	m.PlanetSpin = true
	m.PlanetSpinSpd = 0.6 -- base angular speed
	m.PlanetSelfSpin = true -- each planet spins on own axis
	m.PlanetSelfSpinSpd = 4
	m.PlanetSmooth = 16
	m.PlanetFollow = true -- follow character
	m.PlanetAutoRebuild = true -- put hats back if lost / snapped
	for i = 1, 10 do
		m["PlanetHat" .. i] = ""
		-- solar-system defaults: increasing radius
		m["PlanetRad" .. i] = 3 + i * 1.4
		m["PlanetHeight" .. i] = 0.5 + ((i - 1) % 3) * 0.4
		m["PlanetSpeed" .. i] = 1.0 / (0.6 + i * 0.18) -- outer slower
		m["PlanetPhase" .. i] = (i - 1) * 0.628 -- start angle offset
		m["PlanetOffX" .. i] = 0 -- extra side
		m["PlanetOffY" .. i] = 0 -- extra up
		m["PlanetOffZ" .. i] = 0 -- extra forward
		m["PlanetRotX" .. i] = 0
		m["PlanetRotY" .. i] = 0
		m["PlanetRotZ" .. i] = 0
		m["PlanetIncline" .. i] = ((i % 3) - 1) * 8 -- orbital inclination deg
	end

	-- MOTORCYCLE (hat build + lean + wheel spin + ride)
	m.MotoEnabled = false
	m.MotoRide = false
	m.MotoSpeedBoost = 1.55
	m.MotoSide = 5
	m.MotoHeight = 0
	m.MotoForward = 0
	m.MotoRotY = 0
	m.MotoSmooth = 14
	m.MotoLean = true
	m.MotoLeanAmt = 18 -- max lean degrees when turning
	m.MotoWheelSpin = true
	m.MotoWheelSpinSpd = 16
	m.MotoEnterAnim = true
	m.MotoEnterTime = 0.85
	m.MotoEngineSFX = true
	m.MotoEngineSFXId = "rbxassetid://13114759" -- generic engine-ish (change freely)
	m.MotoIdleSFXId = "rbxassetid://13114759"
	m.MotoVolume = 0.7
	for i = 1, 6 do
		m["MotoHat" .. i] = ""
		m["MotoOffX" .. i] = 0
		m["MotoOffY" .. i] = 0
		m["MotoOffZ" .. i] = 0
		m["MotoRotX" .. i] = 0
		m["MotoRotY" .. i] = 0
		m["MotoRotZ" .. i] = 0
	end
	for i = 1, 2 do
		m["MotoWheelHat" .. i] = ""
		m["MotoWheelOffX" .. i] = 0
		m["MotoWheelOffY" .. i] = -0.5
		m["MotoWheelOffZ" .. i] = (i == 1) and 1.4 or -1.4
		m["MotoWheelRotX" .. i] = 0
		m["MotoWheelRotY" .. i] = 0
		m["MotoWheelRotZ" .. i] = 90
	end
	m.MotoEngineHat = ""
	m.MotoEngineOffX, m.MotoEngineOffY, m.MotoEngineOffZ = 0, 0.3, -0.4
	m.KeyMotoRide = "Equals" -- toggle ride
	m.MotoAutoRebuild = true

	-- HAT TOOLS (sword / random melee from hats)
	m.ToolEnabled = false
	m.ToolActiveSlot = 1
	m.ToolMode = 1 -- 1 sword 2 hammer 3 spear 4 random spin 5 shield-bash
	m.ToolModeNames = { "1 Sword", "2 Hammer", "3 Spear", "4 Spin Tool", "5 Bash" }
	m.ToolFloatSide = 1.2
	m.ToolFloatHeight = 0.4
	m.ToolFloatForward = -0.6
	m.ToolSwingCooldown = 0.35
	m.ToolSwingForce = 40
	m.ToolSwingRange = 7
	m.ToolTrackMouse = true
	m.ToolSFX = true
	m.ToolSwingSFXId = "rbxassetid://131961136"
	m.ToolVolume = 0.9
	m.KeyToolSwing = "V"
	m.KeyToolCycle = "LeftBracket"
	m.ToolAutoRebuild = true
	for i = 1, 6 do
		m["ToolHat" .. i] = ""
		m["ToolOffX" .. i] = 0
		m["ToolOffY" .. i] = (i - 1) * 0.3 - 0.6
		m["ToolOffZ" .. i] = 0
		m["ToolRotX" .. i] = 0
		m["ToolRotY" .. i] = 90
		m["ToolRotZ" .. i] = 0
	end

	-- PLANE (frames + 2 propellers + 2 engines + guns + flight + speedo + cam lock)
	m.PlaneEnabled = false
	m.PlaneRide = false
	m.PlaneFly = false -- free flight mode
	m.PlaneSpeed = 60 -- studs/s base
	m.PlaneMaxSpeed = 180
	m.PlaneAccel = 40
	m.PlaneTurnRate = 1.4
	m.PlanePitchRate = 1.1
	m.PlaneLift = 1.0
	m.PlaneSmooth = 10
	m.PlaneSide = 8
	m.PlaneHeight = 2
	m.PlaneForward = 0
	m.PlaneRotY = 0
	m.PlaneCamLock = false -- lock camera to plane frame
	m.PlaneCamSmooth = 12
	m.PlaneSpeedo = true -- local speedometer GUI
	m.PlaneEnterAnim = true
	m.PlaneEnterTime = 1.0
	m.PlaneEngineSFX = true
	m.PlaneEngineSFXId = "rbxassetid://13114759"
	m.PlanePropSFXId = "rbxassetid://13114759"
	m.PlaneVolume = 0.75
	m.PlaneGunEnabled = false
	m.PlaneGunCooldown = 0.2
	m.PlaneGunSpeed = 220
	m.PlaneGunLife = 2.0
	-- Plane gun aim / fire styles
	m.PlaneGunTrackMouse = true -- aim guns + bullets at mouse / world point
	m.PlaneGunTrackOnlyFire = false -- if true, only orient guns toward mouse while firing
	m.PlaneGunTrackSmooth = 14
	m.PlaneGunFireStyle = 1 -- 1 Beam 2 Gaster (back&forth) 3 AK47 4 Minigun
	m.PlaneGunFireStyleNames = { "1 Beam", "2 Gaster (back & forth)", "3 AK47", "4 Minigun" }
	m.PlaneGunBulletStyle = 1 -- 1 Neon beam 2 Orb 3 Spike 4 Hat bullet
	m.PlaneGunBulletStyleNames = { "1 Neon Beam", "2 Orb", "3 Spike", "4 Hat Bullet" }
	m.PlaneGunBulletHat = "" -- hat used when bullet style = Hat
	m.PlaneGunRealHat = true -- hat bullets use real FE hat (flies out + returns)
	m.PlaneGunSpread = 4 -- degrees spread (AK/minigun)
	m.PlaneGunBurst = 3 -- AK burst size
	m.PlaneGunAKCooldown = 0.12
	m.PlaneGunMiniCooldown = 0.04
	m.PlaneGunBeamLength = 180
	m.PlaneGunBeamThick = 0.9
	m.PlaneGunTrailOsc = true -- Gaster-style: bullet goes out then back & forth fast
	m.PlaneGunTrailOscSpeed = 22
	m.PlaneGunTrailOscDist = 14
	m.PlaneGunTrailOscTime = 1.0
	m.PlaneGunBulletSpin = true
	m.PlaneGunTrail = true
	m.PlaneGunR, m.PlaneGunG, m.PlaneGunB = 255, 220, 80
	m.PlaneGunSFX = true
	-- Plane ordnance: 5 attack toggles (Guns + Bomb + Package + Missile + Bomb2)
	-- Each has its own keybind; optional underground stash until you fire.
	m.PlaneOrdnanceUnderground = true
	-- STAY IN PLACE: after you change place (side / up-down / forward) or rot, the hat stays exactly there on the plane
	-- (kept raised, re-driven live every frame, and returns to the live spot after firing)
	m.PlaneBombStay = true
	m.PlanePackageStay = true
	m.PlaneMissileStay = true -- missile ammo tubes (the missile hats that fly out)
	m.PlaneBomb2Stay = true
	m.PlaneOrdnanceStashDepth = 12
	m.PlaneOrdnanceStashRise = 0.35
	m.PlaneOrdnanceStashHold = 1.2
	-- Attack 2: Bomb (any hat, e.g. Bomb Hat)
	m.PlaneBombEnabled = false
	m.PlaneBombHat = ""
	m.PlaneBombKey = "One"
	m.PlaneBombCooldown = 1.4
	m.PlaneBombCount = 1
	m.PlaneBombSpread = 2.5
	m.PlaneBombFallSpeed = 90
	m.PlaneBombLife = 5
	m.PlaneBombReturn = true
	m.PlaneBombReturnSpeed = 120
	m.PlaneBombBounce = true -- bounce off ground / surfaces
	m.PlaneBombBounceAmt = 0.55 -- restitution 0..1
	m.PlaneBombBounceFriction = 0.82 -- horizontal speed kept on bounce
	m.PlaneBombMinBounce = 6 -- stop bouncing when |Vy| below this
	m.PlaneBombSide, m.PlaneBombHeight, m.PlaneBombForward = 0, -1.5, 0
	m.PlaneBombRotX, m.PlaneBombRotY, m.PlaneBombRotZ = 0, 0, 0
	m.PlaneBombSFX = true
	-- Attack 3: Package / crate / box body (any hat)
	m.PlanePackageEnabled = false
	m.PlanePackageHat = ""
	m.PlanePackageKey = "Two"
	m.PlanePackageCooldown = 1.8
	m.PlanePackageCount = 1
	m.PlanePackageSpread = 2
	m.PlanePackageFallSpeed = 70
	m.PlanePackageLife = 6
	m.PlanePackageReturn = true
	m.PlanePackageReturnSpeed = 100
	m.PlanePackageBounce = true
	m.PlanePackageBounceAmt = 0.4
	m.PlanePackageBounceFriction = 0.75
	m.PlanePackageSide, m.PlanePackageHeight, m.PlanePackageForward = 0, -2, 0
	m.PlanePackageRotX, m.PlanePackageRotY, m.PlanePackageRotZ = 0, 0, 0
	m.PlanePackageSFX = true
	-- Attack 4: Missile launcher (launcher hat + missile hat e.g. AIM-54)
	m.PlaneMissileEnabled = false
	m.PlaneMissileLauncherHat = ""
	m.PlaneMissileHat = "" -- legacy alias for slot 1
	m.PlaneMissileKey = "Three"
	m.PlaneMissileCooldown = 1.1 -- full mag reload when all 4 tubes empty
	m.PlaneMissileShotCooldown = 0.22 -- fast delay between sequential tube shots
	m.PlaneMissileSpeed = 200
	m.PlaneMissileLife = 4
	m.PlaneMissileHoming = 1.2
	m.PlaneMissileTrackMouse = true
	m.PlaneMissileCount = 1 -- projectiles per tube press (usually 1)
	m.PlaneMissileSpread = 3
	m.PlaneMissileTrail = true
	m.PlaneMissileSpin = true
	m.PlaneMissileReturn = true
	m.PlaneMissileReturnSpeed = 140
	m.PlaneMissileSide, m.PlaneMissileHeight, m.PlaneMissileForward = 0, -0.8, 1.5
	m.PlaneMissileRotX, m.PlaneMissileRotY, m.PlaneMissileRotZ = 0, 0, 0
	m.PlaneMissileLauncherSide, m.PlaneMissileLauncherHeight, m.PlaneMissileLauncherForward = 0, -0.5, 0.5
	m.PlaneMissileLauncherRotX, m.PlaneMissileLauncherRotY, m.PlaneMissileLauncherRotZ = 0, 0, 0
	m.PlaneMissileLauncherLock = true -- launcher stays mounted on plane; only missile hat flies out
	m.PlaneMissileLauncherLockForce = true -- re-drive launcher every frame so it cannot snap/fly away
	m.PlaneMissileSFX = true
	-- 4 missile tubes / ammo slots (cycle after each fire for fast reload)
	m.PlaneMissileSlotCount = 5
	m.PlaneMissileActiveSlot = 1
	m.PlaneMissileAutoCycle = true -- after fire, advance to next loaded tube
	m.PlaneMissileCycleKey = "Five" -- optional manual cycle key
	m.PlaneMissileAutoDetect = true -- auto-fill empty tubes from AIM-54 / Phoenix hats on character
	m.PlaneMissileAutoDetectIds = { "104594291421043" } -- Aim-54 Pheonix catalog id
	m.PlaneMissileAutoDetectHints = { "aim-54", "aim54", "aim 54", "pheonix", "phoenix missile", "phoenix" }
	for i = 1, 5 do
		m["PlaneMissileHat" .. i] = ""
		-- per-tube park offset so all tubes sit on the plane at once
		m["PlaneMissileSlotSide" .. i] = ((i % 2 == 0) and -1.2 or 1.2)
		m["PlaneMissileSlotHeight" .. i] = -0.6 + ((i - 1) % 3) * 0.15
		m["PlaneMissileSlotForward" .. i] = 1.2 - (i - 1) * 0.3
		m["PlaneMissileSlotRotX" .. i] = 0
		m["PlaneMissileSlotRotY" .. i] = 0
		m["PlaneMissileSlotRotZ" .. i] = 0
		m["PlaneMissileSlotEnabled" .. i] = true
	end
	-- Attack 5: second bomb bay
	m.PlaneBomb2Enabled = false
	m.PlaneBomb2Hat = ""
	m.PlaneBomb2Key = "Four"
	m.PlaneBomb2Cooldown = 1.6
	m.PlaneBomb2Count = 2
	m.PlaneBomb2Spread = 3.5
	m.PlaneBomb2FallSpeed = 95
	m.PlaneBomb2Life = 5
	m.PlaneBomb2Return = true
	m.PlaneBomb2ReturnSpeed = 120
	m.PlaneBomb2Bounce = true
	m.PlaneBomb2BounceAmt = 0.5
	m.PlaneBomb2BounceFriction = 0.8
	m.PlaneBomb2Side, m.PlaneBomb2Height, m.PlaneBomb2Forward = 0, -1.8, -0.5
	m.PlaneBomb2RotX, m.PlaneBomb2RotY, m.PlaneBomb2RotZ = 0, 0, 0
	m.KeyPlaneRide = "RightBracket"
	m.KeyPlaneFly = "BackSlash"
	m.KeyPlaneGun = "MouseButton1" -- while riding (Attack 1)
	m.PlaneAutoRebuild = true -- continuously re-grab / put hats back in place
	m.PlaneLock = true -- force-drive every frame so hats cannot snap away
	-- FULL PLANE: one hat/accessory is the entire aircraft (e.g. red triplane pack)
	m.PlaneFullMode = false
	m.PlaneFullHat = ""
	m.PlaneFullOffX, m.PlaneFullOffY, m.PlaneFullOffZ = 0, -1.5, 0
	m.PlaneFullRotX, m.PlaneFullRotY, m.PlaneFullRotZ = 0, 0, 0
	m.PlaneFullScale = 1
	-- improved flight controls
	m.PlaneRollRate = 1.6
	m.PlaneYawRate = 1.3
	m.PlaneMouseSteer = true -- mouse aims pitch/yaw while flying
	m.PlaneMouseSens = 0.35
	m.PlaneBank = true -- auto bank into turns
	m.PlaneBankAmt = 25 -- max bank degrees
	m.PlaneThrottle = 0 -- 0..1 runtime
	m.PlaneMinFlySpeed = 8
	m.PlaneGravity = 28 -- how hard you fall when slow / stalling
	m.PlaneSeatOffY = -1.2 -- character offset when riding
	-- 10 frame slots
	for i = 1, 10 do
		m["PlaneFrameHat" .. i] = ""
		m["PlaneFrameOffX" .. i] = 0
		m["PlaneFrameOffY" .. i] = 0
		m["PlaneFrameOffZ" .. i] = (i - 5.5) * 0.8
		m["PlaneFrameRotX" .. i] = 0
		m["PlaneFrameRotY" .. i] = 0
		m["PlaneFrameRotZ" .. i] = 0
	end
	-- 2 propellers
	for i = 1, 2 do
		m["PlanePropHat" .. i] = ""
		m["PlanePropOffX" .. i] = (i == 1) and -2.5 or 2.5
		m["PlanePropOffY" .. i] = 0.2
		m["PlanePropOffZ" .. i] = 2.2
		m["PlanePropRotX" .. i] = 0
		m["PlanePropRotY" .. i] = 0
		m["PlanePropRotZ" .. i] = 0
		m["PlanePropSpinSpd" .. i] = 28
	end
	-- 2 engines
	for i = 1, 2 do
		m["PlaneEngineHat" .. i] = ""
		m["PlaneEngineOffX" .. i] = (i == 1) and -1.8 or 1.8
		m["PlaneEngineOffY" .. i] = -0.2
		m["PlaneEngineOffZ" .. i] = 1.5
		m["PlaneEngineRotX" .. i] = 0
		m["PlaneEngineRotY" .. i] = 0
		m["PlaneEngineRotZ" .. i] = 0
		m["PlaneEngineBob" .. i] = true
	end
	-- 4 gun slots on plane
	for i = 1, 4 do
		m["PlaneGunHat" .. i] = ""
		m["PlaneGunOffX" .. i] = (i <= 2) and -1.2 or 1.2
		m["PlaneGunOffY" .. i] = -0.4
		m["PlaneGunOffZ" .. i] = (i % 2 == 1) and 1.0 or 0.2
		m["PlaneGunRotX" .. i] = 0
		m["PlaneGunRotY" .. i] = 0
		m["PlaneGunRotZ" .. i] = 0
		m["PlaneGunFire" .. i] = true
	end

	-- CAR: GTA-style enter + engine start SFX
	m.CarEnterAnim = true
	m.CarEnterTime = 1.1
	m.CarEngineOn = false -- toggled when you enter / ride
	m.CarEngineSFX = true
	m.CarEngineStartSFXId = "rbxassetid://13114759"
	m.CarEngineLoopSFXId = "rbxassetid://13114759"
	m.CarEngineVolume = 0.8
	m.CarEngineType = 1 -- 1 car 2 truck 3 sport 4 motorcycle-ish
	m.CarEngineTypeNames = { "1 Car", "2 Truck", "3 Sport", "4 Moto-ish" }
	m.KeyCarRide = "Minus" -- toggle ride / enter
	m.CarAutoRebuild = true

	-- Refresh
	m.AutoRefresh = false
	m.AutoRefreshInterval = 1
	m.LastRefreshReport = ""

	--------------------------------------------------------------
	-- CONSTANTS
	--------------------------------------------------------------
	local LIMB_ASSET_IDS = {
		Head = { 107852478332182 },
		Torso = { 118799338103138 },
		LeftArm = { 101379144205559 },
		RightArm = { 132416515427938 },
		LeftLeg = { 121360936156823 },
		RightLeg = { 80628080423002 },
	}
	local LIMB_NAME_HINTS = {
		{ "LeftArm", { "larm", "leftarm", "left arm", "l arm" } },
		{ "RightArm", { "rarm", "rightarm", "right arm", "r arm", "black right" } },
		{ "LeftLeg", { "lleg", "leftleg", "left leg", "l leg" } },
		{ "RightLeg", { "rleg", "rightleg", "right leg", "r leg" } },
		{ "Head", { "head", "bigeye" } },
		{ "Torso", { "torso", "default" } },
	}
	local LIMB_NAMES = { "Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg" }
	local LIMB_KEYS = {
		Head = "HatHead", Torso = "HatTorso",
		LeftArm = "HatLeftArm", RightArm = "HatRightArm",
		LeftLeg = "HatLeftLeg", RightLeg = "HatRightLeg",
	}
	local LIMB_BASE_POS = {
		Head = Vector3.new(0, 1.5, 0),
		Torso = Vector3.new(0, 0.4, 0),
		LeftArm = Vector3.new(-1.3, 0.5, 0),
		RightArm = Vector3.new(1.3, 0.5, 0),
		LeftLeg = Vector3.new(-0.5, -1.3, 0),
		RightLeg = Vector3.new(0.5, -1.3, 0),
	}
	local LIMB_ROT_KEYS = {
		Head = { "RotHeadX", "RotHeadY", "RotHeadZ" },
		Torso = { "RotTorsoX", "RotTorsoY", "RotTorsoZ" },
		LeftArm = { "RotLeftArmX", "RotLeftArmY", "RotLeftArmZ" },
		RightArm = { "RotRightArmX", "RotRightArmY", "RotRightArmZ" },
		LeftLeg = { "RotLeftLegX", "RotLeftLegY", "RotLeftLegZ" },
		RightLeg = { "RotRightLegX", "RotRightLegY", "RotRightLegZ" },
	}
	local LIMB_OFF_KEYS = {
		Head = { "OffHeadX", "OffHeadY", "OffHeadZ" },
		Torso = { "OffTorsoX", "OffTorsoY", "OffTorsoZ" },
		LeftArm = { "OffLeftArmX", "OffLeftArmY", "OffLeftArmZ" },
		RightArm = { "OffRightArmX", "OffRightArmY", "OffRightArmZ" },
		LeftLeg = { "OffLeftLegX", "OffLeftLegY", "OffLeftLegZ" },
		RightLeg = { "OffRightLegX", "OffRightLegY", "OffRightLegZ" },
	}
	local ORBIT_HAT_KEYS, PLACE_HAT_KEYS = {}, {}
	for i = 1, 10 do
		ORBIT_HAT_KEYS[i] = "OrbitHat" .. i
		PLACE_HAT_KEYS[i] = "PlaceHat" .. i
	end

	local CONTROLLER_CLASSES = {
		"AlignPosition", "AlignOrientation", "BodyPosition", "BodyGyro",
		"BodyVelocity", "BodyForce", "BodyAngularVelocity",
		"LinearVelocity", "AngularVelocity", "VectorForce", "Torque",
	}
	local DANCE_HINTS = {
		"dance", "emote", "groove", "wave", "cheer", "laugh", "point",
		"sit", "lay", "floss", "disco", "shimmy", "twerk", "macarena",
		"robot", "thriller", "hype", "party", "defaultdance", "breakdance",
		"salsa", "tango", "hiphop", "freestyle", "boogie", "shuffle",
		"orange justice", "take the l", "electro shuffle", "fresh",
		"flapper", "ride the pony", "best mates", "worm", "scenario",
		"renegade", "say so", "sturdy", "toosie", "griddy", "dougie",
		"cabbage", "chicken", "gangnam", "harlem", "nae nae", "whip",
		"animate", "custom", "music", "song", "move", "idle_dance",
	}

	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local CoreGui = game:GetService("CoreGui")
	local UserInputService = game:GetService("UserInputService")
	local Workspace = game:GetService("Workspace")
	local TweenService = game:GetService("TweenService")
	local Debris = game:GetService("Debris")
	local LocalPlayer = Players.LocalPlayer
	local Mouse = LocalPlayer:GetMouse()

	local StandModel, StandRoot = nil, nil
	local Limbs, Held = {}, {}
	local OrbitAngle, IdleT = 0, 0
	local AnimState, AnimT, AnimToken = "idle", 0, 0
	local FollowBound, HBConn = false, nil
	local KeyConns, CharConns = {}, {}
	local HatCache = {}
	local LimbCache = setmetatable({}, { __mode = "k" })
	local NameLabels = {}
	local LimbPreviewParts = {}
	local RefreshToken, LastHatFingerprint = 0, ""
	local NeedRebuild, LastBuild = false, 0
	local OLD_BIND_NAMES = {
		"Uhhhhhh_HatStand_v6", "Uhhhhhh_HatStand_v7", "Uhhhhhh_HatStand_v8",
		"Uhhhhhh_HatStand_v9", "Uhhhhhh_HatStand_v10", "Uhhhhhh_HatStand_v11",
		"Uhhhhhh_HatStand_v12",
	}

	local LocoT, LocoMode = 0, "idle"
	local DanceT, ForceDance, ForceDanceUntil = 0, false, 0
	local DetectedDanceName = ""
	local PlacePreviewPart, PlacedHats, PlaceT, BuildAnimT = nil, {}, 0, 0
	local PlaceFolder = nil
	local OrbitSlots, OrbitT, NeedOrbitRebuild = {}, 0, false

	-- New systems state
	local GasterHeld, GasterLastFire, GasterCharging = nil, 0, false
	local GasterSlots = {} -- [1..5] = held entries
	local GasterFireIdx = 0
	local BoneHeld, BoneLastFire = nil, 0
	local BoneProjectiles = {}
	local OmegaHeld, OmegaHeld2, OmegaLastFire, OmegaCharging = nil, nil, 0, false
	local WeaponHeld, WeaponBullets, WeaponLastFire = nil, {}, 0
	local ShieldHeld, ShieldPlacedCF = nil, nil
	local CarSlots, CarRootCF = {}, nil
	local CarWheels, CarEngine = {}, nil -- wheel slots + engine
	local BallSlots, BallFlying, BallLastYeet = {}, {}, 0
	local PlanetSlots, PlanetT = {}, 0
	local MotoSlots, MotoWheels, MotoEngine, MotoRootCF = {}, {}, nil, nil
	local MotoEnterT, MotoEngineSound = 0, nil
	local ToolSlots, ToolLastSwing = {}, 0
	local PlaneFrames, PlaneProps, PlaneEngines, PlaneGuns = {}, {}, {}, {}
	local PlaneFull = nil -- single full-plane hat body
	local PlaneRootCF, PlaneVel, PlanePitch, PlaneYaw, PlaneRoll = nil, 0, 0, 0, 0
	local PlaneThrottle = 0
	local PlaneEnterT, PlaneEngineSound, PlaneSpeedoGui = 0, nil, nil
	-- Plane ordnance runtime (bomb / package / missile)
	local CarEnterT, CarEngineSound = 0, nil
	local NeedPlanetRebuild, NeedMotoRebuild, NeedToolRebuild, NeedPlaneRebuild, NeedCarRebuild = false, false, false, false, false
	local LastPlanetCheck, LastMotoCheck, LastToolCheck, LastPlaneCheck, LastCarCheck = 0, 0, 0, 0, 0
	local BToolsCarryCF = nil
	local YeetQueue = {} -- {handle, vel, until}
	local PlaceAnimQueue = {} -- animating place/yeet

	-- v14 state + functions live on one table (Luau local limit)
	local X = {
		Blend = {}, CloneLimbs = {}, CloneModel = nil, CloneCF = nil, CloneLastBuild = 0,
		PlaneBombHeld = nil, PlanePackageHeld = nil, PlaneBomb2Held = nil,
		PlaneMissileLauncher = nil, PlaneMissileAmmo = nil, PlaneMissileAmmoSlots = {}, PlaneMissileTubeLast = {},
		PlaneOrdnanceFlying = {},
		PlaneBombLast = 0, PlanePackageLast = 0, PlaneMissileLast = 0, PlaneBomb2Last = 0,
		CloneCount = -1, NeedCloneRebuild = false,
		Phase = 0, SpeedSm = 0, LeanSm = 0, SideSm = 0, AirT = 0, LandT = 0,
		WasAir = false, Air = false, State = nil, ClimbT = 0, ProcT = 0,
		WeaponSlots = {}, BulletHats = {}, LinkWarned = false, Extras = nil, ExtrasFrame = -1, Frame = 0, DanceSource = "",
		Rest = {}, RestSet = false, CalibT = 0, SnapT = 0, RawFrame = -1, Raw = nil, LastRaw = nil, LastLoco = "idle",
		ClawsLeft = nil, ClawsRight = nil, ClawsHead = nil,
		ClawsLastCombo = 0, ClawsLastPush = 0, ClawsLastSpin = 0,
		ClawsComboStep = 0, ClawsAnimT = 0, ClawsMode = "idle", ClawsSpinUntil = 0,
		ClawsBlood = {}, ClawsLocoT = 0, ClawsLoco = "idle", ClawsOff = {},
	}

	--------------------------------------------------------------
	-- HELPERS
	--------------------------------------------------------------
	--------------------------------------------------------------
	-- STUBS: features not in this module (no-ops so shared code can call them safely)
	--------------------------------------------------------------
	X.activeWeapon = X.activeWeapon or function() end
	X.addTrail = X.addTrail or function() end
	X.applyBToolsMode = X.applyBToolsMode or function() end
	X.applyTrailProps = X.applyTrailProps or function() end
	X.autoDetectMissileHats = X.autoDetectMissileHats or function() end
	X.ballBase = X.ballBase or function() end
	X.beam = X.beam or function() end
	X.btoolsAnchor = X.btoolsAnchor or function() end
	X.btoolsExtra = X.btoolsExtra or function() end
	X.btoolsPlan = X.btoolsPlan or function() end
	X.btoolsPreset = X.btoolsPreset or function() end
	X.buildStructure = X.buildStructure or function() end
	X.bulletColor = X.bulletColor or function() end
	X.bulletFolder = X.bulletFolder or function() end
	X.castRay = X.castRay or function() end
	X.clawsLaserColor = X.clawsLaserColor or function() end
	X.clawsRage = X.clawsRage or function() end
	X.clawsRayParams = X.clawsRayParams or function() end
	X.cleanClone = X.cleanClone or function() end
	X.clearAllPlaced = X.clearAllPlaced or function() end
	X.clearBall = X.clearBall or function() end
	X.clearBone = X.clearBone or function() end
	X.clearCar = X.clearCar or function() end
	X.clearGaster = X.clearGaster or function() end
	X.clearHeli = X.clearHeli or function() end
	X.clearMoto = X.clearMoto or function() end
	X.clearOmega = X.clearOmega or function() end
	X.clearOrbit = X.clearOrbit or function() end
	X.clearPlane = X.clearPlane or function() end
	X.clearPlanet = X.clearPlanet or function() end
	X.clearShield = X.clearShield or function() end
	X.clearStructGhosts = X.clearStructGhosts or function() end
	X.clearTitan = X.clearTitan or function() end
	X.clearTool = X.clearTool or function() end
	X.clearWeapon = X.clearWeapon or function() end
	X.cycleWeapon = X.cycleWeapon or function() end
	X.doFire = X.doFire or function() end
	X.drivePlaneOrdnanceSlot = X.drivePlaneOrdnanceSlot or function() end
	X.ensurePlaneSpeedo = X.ensurePlaneSpeedo or function() end
	X.fireBlaster = X.fireBlaster or function() end
	X.fireBone = X.fireBone or function() end
	X.fireClawsLaser = X.fireClawsLaser or function() end
	X.fireClawsSlam = X.fireClawsSlam or function() end
	X.fireGaster = X.fireGaster or function() end
	X.fireHeli = X.fireHeli or function() end
	X.fireHeliMissile = X.fireHeliMissile or function() end
	X.fireLaser = X.fireLaser or function() end
	X.fireList = X.fireList or function() end
	X.fireOmega = X.fireOmega or function() end
	X.fireOmegaBeam = X.fireOmegaBeam or function() end
	X.fireOneGasterSlot = X.fireOneGasterSlot or function() end
	X.fireOneOmegaSlot = X.fireOneOmegaSlot or function() end
	X.firePlaneBomb = X.firePlaneBomb or function() end
	X.firePlaneBomb2 = X.firePlaneBomb2 or function() end
	X.firePlaneGunBeam = X.firePlaneGunBeam or function() end
	X.firePlaneGuns = X.firePlaneGuns or function() end
	X.firePlaneMissile = X.firePlaneMissile or function() end
	X.firePlanePackage = X.firePlanePackage or function() end
	X.fireSeq = X.fireSeq or function() end
	X.fireWeapon = X.fireWeapon or function() end
	X.flash = X.flash or function() end
	X.freezePlacedForRespawn = X.freezePlacedForRespawn or function() end
	X.gasterSlotCF = X.gasterSlotCF or function() end
	X.getActivePlaceHat = X.getActivePlaceHat or function() end
	X.getMouseWorldCF = X.getMouseWorldCF or function() end
	X.getRP = X.getRP or function() end
	X.heliAddTrail = X.heliAddTrail or function() end
	X.heliConfigured = X.heliConfigured or function() end
	X.heliEngineUrl = X.heliEngineUrl or function() end
	X.heliGroupCF = X.heliGroupCF or function() end
	X.heliStyleTrail = X.heliStyleTrail or function() end
	X.heliTrailColorSeq = X.heliTrailColorSeq or function() end
	X.hitFX = X.hitFX or function() end
	X.initSansStash = X.initSansStash or function() end
	X.keepPlaced = X.keepPlaced or function() end
	X.launchOmegaBullet = X.launchOmegaBullet or function() end
	X.launchPlaneDrop = X.launchPlaneDrop or function() end
	X.loadBToolsBuild = X.loadBToolsBuild or function() end
	X.makeGhostClone = X.makeGhostClone or function() end
	X.makeTemplate = X.makeTemplate or function() end
	X.msCandidates = X.msCandidates or function() end
	X.msCleanup = X.msCleanup or function() end
	X.msClearLock = X.msClearLock or function() end
	X.msExplode = X.msExplode or function() end
	X.msPick = X.msPick or function() end
	X.omegaBulletKey = X.omegaBulletKey or function() end
	X.omegaHatKey = X.omegaHatKey or function() end
	X.orbitExtra = X.orbitExtra or function() end
	X.orbitPos = X.orbitPos or function() end
	X.pickMissileTube = X.pickMissileTube or function() end
	X.placeBackNearest = X.placeBackNearest or function() end
	X.placeHatAt = X.placeHatAt or function() end
	X.placeShieldAtMouse = X.placeShieldAtMouse or function() end
	X.planeGunAimDir = X.planeGunAimDir or function() end
	X.planeGunColor = X.planeGunColor or function() end
	X.rainbowSeq = X.rainbowSeq or function() end
	X.raisePlaneOrdnance = X.raisePlaneOrdnance or function() end
	X.rebuildBall = X.rebuildBall or function() end
	X.rebuildBone = X.rebuildBone or function() end
	X.rebuildCar = X.rebuildCar or function() end
	X.rebuildGaster = X.rebuildGaster or function() end
	X.rebuildHeli = X.rebuildHeli or function() end
	X.rebuildMoto = X.rebuildMoto or function() end
	X.rebuildOmega = X.rebuildOmega or function() end
	X.rebuildOrbit = X.rebuildOrbit or function() end
	X.rebuildPlane = X.rebuildPlane or function() end
	X.rebuildPlanet = X.rebuildPlanet or function() end
	X.rebuildShield = X.rebuildShield or function() end
	X.rebuildTitan = X.rebuildTitan or function() end
	X.rebuildTool = X.rebuildTool or function() end
	X.rebuildWeapon = X.rebuildWeapon or function() end
	X.reclaim = X.reclaim or function() end
	X.refreshTrails = X.refreshTrails or function() end
	X.removeNearest = X.removeNearest or function() end
	X.resetHeliEngine = X.resetHeliEngine or function() end
	X.resetHeliMini = X.resetHeliMini or function() end
	X.resetHeliSound = X.resetHeliSound or function() end
	X.sansStashOn = X.sansStashOn or function() end
	X.saveBToolsBuild = X.saveBToolsBuild or function() end
	X.scaleClone = X.scaleClone or function() end
	X.setHeliFly = X.setHeliFly or function() end
	X.setPlaneStay = X.setPlaneStay or function() end
	X.setSansUnderground = X.setSansUnderground or function() end
	X.spawnClawsShockwave = X.spawnClawsShockwave or function() end
	X.spawnHeliBullet = X.spawnHeliBullet or function() end
	X.spawnLocked = X.spawnLocked or function() end
	X.spawnPlaneHatBullet = X.spawnPlaneHatBullet or function() end
	X.spawnPlaneNeonBullet = X.spawnPlaneNeonBullet or function() end
	X.stashParams = X.stashParams or function() end
	X.stashShift = X.stashShift or function() end
	X.stepBall = X.stepBall or function() end
	X.stepBone = X.stepBone or function() end
	X.stepBullet = X.stepBullet or function() end
	X.stepCar = X.stepCar or function() end
	X.stepClawsBullet = X.stepClawsBullet or function() end
	X.stepGaster = X.stepGaster or function() end
	X.stepHeli = X.stepHeli or function() end
	X.stepHeliAudio = X.stepHeliAudio or function() end
	X.stepHeliBullets = X.stepHeliBullets or function() end
	X.stepHeliMissileLock = X.stepHeliMissileLock or function() end
	X.stepHeliMissiles = X.stepHeliMissiles or function() end
	X.stepHeliSolid = X.stepHeliSolid or function() end
	X.stepMoto = X.stepMoto or function() end
	X.stepOmega = X.stepOmega or function() end
	X.stepOmegaBullets = X.stepOmegaBullets or function() end
	X.stepOrbit = X.stepOrbit or function() end
	X.stepPlaceAnims = X.stepPlaceAnims or function() end
	X.stepPlaced = X.stepPlaced or function() end
	X.stepPlane = X.stepPlane or function() end
	X.stepPlaneOrdnance = X.stepPlaneOrdnance or function() end
	X.stepPlaneOrdnanceSlot = X.stepPlaneOrdnanceSlot or function() end
	X.stepPlanet = X.stepPlanet or function() end
	X.stepShield = X.stepShield or function() end
	X.stepTitan = X.stepTitan or function() end
	X.stepTool = X.stepTool or function() end
	X.stepWeapon = X.stepWeapon or function() end
	X.stepYeet = X.stepYeet or function() end
	X.stripTrails = X.stripTrails or function() end
	X.swingTool = X.swingTool or function() end
	X.syncPlaneOrdnanceFromSettings = X.syncPlaneOrdnanceFromSettings or function() end
	X.titanAnimOffsets = X.titanAnimOffsets or function() end
	X.titanCoreFire = X.titanCoreFire or function() end
	X.titanDetectMode = X.titanDetectMode or function() end
	X.titanLayout = X.titanLayout or function() end
	X.titanLiveOffRot = X.titanLiveOffRot or function() end
	X.toggleHeliEngine = X.toggleHeliEngine or function() end
	X.toggleHeliFly = X.toggleHeliFly or function() end
	X.toggleHeliMouse = X.toggleHeliMouse or function() end
	X.toggleHeliRide = X.toggleHeliRide or function() end
	X.toggleMotoRide = X.toggleMotoRide or function() end
	X.togglePlaneFly = X.togglePlaneFly or function() end
	X.togglePlaneRide = X.togglePlaneRide or function() end
	X.toggleShieldStash = X.toggleShieldStash or function() end
	X.toggleTitanFly = X.toggleTitanFly or function() end
	X.trailEnable = X.trailEnable or function() end
	X.updatePlacePreview = X.updatePlacePreview or function() end
	X.updateStructPreview = X.updateStructPreview or function() end
	X.weaponBase = X.weaponBase or function() end
	X.yeetBall = X.yeetBall or function() end
	X.yeetNearestPlaced = X.yeetNearestPlaced or function() end

	X.trim = function(s)
		return (tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", ""))
	end

	-- Lightweight SFX (client-only). Pass asset id string or number.
	X.playSFX = function(id, volume, parent, pitch)
		if not id or id == "" or id == "0" then return end
		local sid = tostring(id)
		if not string.find(sid, "rbxassetid://", 1, true) then
			sid = "rbxassetid://" .. sid:gsub("%D", "")
		end
		pcall(function()
			local s = Instance.new("Sound")
			s.Name = "HS_SFX"
			s.SoundId = sid
			s.Volume = tonumber(volume) or 1
			s.PlaybackSpeed = tonumber(pitch) or 1
			s.RollOffMaxDistance = 80
			s.Parent = parent or workspace.CurrentCamera or workspace
			s:Play()
			Debris:AddItem(s, 6)
		end)
	end

	X.modeAllowsStand = function()
		return m.ActiveMode == 1 or m.ActiveMode == 4
			or (m.ActiveMode == 3 and m.StandInOrbitMode ~= false)
	end
	X.modeAllowsPlace = function()
		if not m.PlaceEnabled then return false end
		if cfg.id == "STAND" then return false end -- the Place module owns BTools
		return m.ActiveMode == 1 or m.ActiveMode == 2 or m.ActiveMode == 4
	end
	X.modeAllowsOrbit = function()
		return m.ActiveMode == 3 or m.ActiveMode == 4
	end

	X.getRoot = function(char)
		if not char then return nil end
		return char:FindFirstChild("HumanoidRootPart")
			or char:FindFirstChild("Torso")
			or char:FindFirstChild("UpperTorso")
			or char.PrimaryPart
	end

	X.getFollowRoot = function()
		local ok, uh = pcall(function()
			return _G.Uhhhhhh and _G.Uhhhhhh.Character
		end)
		if ok and uh and uh.Parent then
			local r = X.getRoot(uh)
			if r and r.Parent then return r, uh, "uhhhhh" end
		end
		local char = LocalPlayer.Character
		if char then
			local r = X.getRoot(char)
			if r and r.Parent then return r, char, "character" end
		end
		return nil, nil, nil
	end

	X.getLiveHumanoid = function()
		local char = LocalPlayer.Character
		return char and char:FindFirstChildOfClass("Humanoid")
	end

	function X.boostNetwork()
		pcall(function() sethiddenproperty(LocalPlayer, "SimulationRadius", 1e9) end)
		pcall(function() sethiddenproperty(LocalPlayer, "MaximumSimulationRadius", 1e9) end)
		pcall(function() LocalPlayer.MaximumSimulationRadius = 1e9 end)
		pcall(function() settings().Physics.AllowSleep = false end)
	end

	X.ensurePlaceFolder = function()
		if PlaceFolder and PlaceFolder.Parent then return PlaceFolder end
		local f = Workspace:FindFirstChild(("UhhhhhhHatStand_Placed" .. SUF))
		if not f then
			f = Instance.new("Folder")
			f.Name = ("UhhhhhhHatStand_Placed" .. SUF)
			f.Parent = Workspace
		end
		PlaceFolder = f
		return f
	end

	function X.getLimbRotCFrame(limb)
		local keys = LIMB_ROT_KEYS[limb]
		if not keys then return CFrame.new() end
		return CFrame.Angles(
			math.rad(tonumber(m[keys[1]]) or 0),
			math.rad(tonumber(m[keys[2]]) or 0),
			math.rad(tonumber(m[keys[3]]) or 0)
		)
	end

	-- Default rotations that correct mesh orientation for most hat/accessory limb sets
	-- (big-head packs, classic R6 limbs, generic accessory handles). Arms get 90° Z so
	-- they hang down like a real figure; works with BigRigFix or the universal FixAnyRigPose.
	local BIGRIG_ROT = {
		Head     = CFrame.Angles(0, 0, 0),
		Torso    = CFrame.Angles(0, 0, 0),
		LeftArm  = CFrame.Angles(0, 0, math.rad(90)),
		RightArm = CFrame.Angles(0, 0, math.rad(-90)),
		LeftLeg  = CFrame.Angles(0, 0, math.rad(5)),
		RightLeg = CFrame.Angles(0, 0, math.rad(-5)),
	}
	function X.bigRigBasePos(limb)
		local h = m.BigRigHeight or 1
		local as = m.BigRigArmSpread or 1.55
		local ls = m.BigRigLegSpread or 0.55
		local map = {
			Head     = Vector3.new(0, 1.55 * h, 0),
			Torso    = Vector3.new(0, 0.45 * h, 0),
			LeftArm  = Vector3.new(-as * h, 0.55 * h, 0),
			RightArm = Vector3.new( as * h, 0.55 * h, 0),
			LeftLeg  = Vector3.new(-ls * h, -1.45 * h, 0),
			RightLeg = Vector3.new( ls * h, -1.45 * h, 0),
		}
		return map[limb] or Vector3.zero
	end

	function X.getLimbOffVector(limb)
		local keys = LIMB_OFF_KEYS[limb]
		if not keys then return Vector3.zero end
		return Vector3.new(
			tonumber(m[keys[1]]) or 0,
			tonumber(m[keys[2]]) or 0,
			tonumber(m[keys[3]]) or 0
		)
	end

	X.makeBaseOffset = function(limb)
		local scale = m.StandScale or 1
		local pos
		local extraRot = CFrame.new()
		-- BigRigFix = classic big-head pack layout; FixAnyRigPose = same corrections for any accessory rig
		if m.BigRigFix or m.FixAnyRigPose then
			pos = X.bigRigBasePos(limb)
			extraRot = BIGRIG_ROT[limb] or CFrame.new()
		else
			pos = LIMB_BASE_POS[limb] or Vector3.zero
		end
		local off = X.getLimbOffVector(limb)
		return CFrame.new(pos.X * scale + off.X, pos.Y * scale + off.Y, pos.Z * scale + off.Z)
			* extraRot
			* X.getLimbRotCFrame(limb)
	end

	X.refreshAllLimbOffsets = function()
		for limb, data in pairs(Limbs) do
			if data then data.BaseOffset = X.makeBaseOffset(limb) end
		end
		-- preview is refreshed from UI / applyStandCF / X.buildStand(after helpers exist)
	end

	X.getPlaceSlotRot = function(slot)
		-- per-slot position offset (side / up / forward) is applied before the rotation
		return CFrame.new(
			tonumber(m["PlaceOff" .. slot .. "X"]) or 0,
			tonumber(m["PlaceOff" .. slot .. "Y"]) or 0,
			tonumber(m["PlaceOff" .. slot .. "Z"]) or 0
		) * CFrame.Angles(
			math.rad(tonumber(m["PlaceRot" .. slot .. "X"]) or 0),
			math.rad(tonumber(m["PlaceRot" .. slot .. "Y"]) or 0),
			math.rad(tonumber(m["PlaceRot" .. slot .. "Z"]) or 0)
		)
	end

	--------------------------------------------------------------
	-- HAT SCAN
	--------------------------------------------------------------
	function X.assetIdInInstance(inst, id)
		if not inst then return false end
		local idStr = tostring(id)
		local ok, desc = pcall(function() return inst:GetDescendants() end)
		if not ok then return false end
		for _, d in ipairs(desc) do
			for _, prop in ipairs({ "MeshId", "TextureID", "TextureId" }) do
				local s, val = pcall(function() return d[prop] end)
				if s and type(val) == "string" and string.find(val, idStr, 1, true) then
					return true
				end
			end
		end
		local s2, sid = pcall(function() return inst:GetAttribute("SourceAssetId") end)
		if s2 and sid and tostring(sid) == idStr then return true end
		return false
	end

	function X.matchLimbForHat(h)
		local acc = h.Accessory
		if acc and LimbCache[acc] ~= nil then return LimbCache[acc] or nil end
		local result = nil
		for limb, ids in pairs(LIMB_ASSET_IDS) do
			for _, id in ipairs(ids) do
				if X.assetIdInInstance(h.Accessory, id) or X.assetIdInInstance(h.Handle, id) then
					result = limb break
				end
			end
			if result then break end
		end
		if not result then
			local lower = string.lower(h.Name)
			for _, pair in ipairs(LIMB_NAME_HINTS) do
				for _, hint in ipairs(pair[2]) do
					if string.find(lower, hint, 1, true) then result = pair[1] break end
				end
				if result then break end
			end
		end
		if acc then LimbCache[acc] = result or false end
		return result
	end

	function X.isDrivenByOther(handle)
		if not handle then return false end
		local lt = 0
		pcall(function() lt = handle.LocalTransparencyModifier end)
		if lt > 0.85 then return true end
		local ok, desc = pcall(function() return handle:GetDescendants() end)
		if ok then
			for _, d in ipairs(desc) do
				if not string.find(d.Name, "^HS_") then
					for _, cls in ipairs(CONTROLLER_CLASSES) do
						if d:IsA(cls) then return true end
					end
				end
			end
		end
		return false
	end

	X.refreshAllHats = function(report)
		local oldNames = {}
		for _, h in ipairs(HatCache) do oldNames[h.Name] = true end

		HatCache = {}
		local seen = {}
		local function addAccessory(acc, source)
			if not acc or seen[acc] then return end
			seen[acc] = true
			local handle = acc:FindFirstChild("Handle")
			local ours = (handle ~= nil) and (Held[handle] ~= nil)
			local used = false
			if handle and not ours then used = X.isDrivenByOther(handle) end
			local entry = {
				Name = acc.Name, Accessory = acc, Handle = handle,
				Used = used, Ours = ours, Source = source,
			}
			entry.LimbGuess = X.matchLimbForHat(entry)
			table.insert(HatCache, entry)
		end
		local function scan(model, source)
			if not model then return end
			for _, child in ipairs(model:GetChildren()) do
				if child:IsA("Accoutrement") then addAccessory(child, source) end
			end
		end
		scan(LocalPlayer.Character, "Character")
		pcall(function()
			scan(_G.Uhhhhhh and _G.Uhhhhhh.Character, "Uhhhhhh")
		end)
		table.sort(HatCache, function(a, b)
			if a.Used ~= b.Used then return not a.Used end
			if a.Name ~= b.Name then return a.Name < b.Name end
			return tostring(a.Source) < tostring(b.Source)
		end)

		local lines = {}
		local newOnes, missing = {}, {}
		local nowNames = {}
		for _, h in ipairs(HatCache) do
			nowNames[h.Name] = true
			local tag = h.Ours and "STAND" or (h.Used and "USED" or "SPARE")
			local limb = h.LimbGuess and (" -> " .. h.LimbGuess) or ""
			table.insert(lines, string.format("[%s] %s%s", tag, h.Name, limb))
			if not oldNames[h.Name] then table.insert(newOnes, h.Name) end
		end
		for n in pairs(oldNames) do
			if not nowNames[n] then table.insert(missing, n) end
		end

		m.PreviewText = (#lines > 0) and table.concat(lines, "\n") or "(no hats on character)"

		local reportParts = {}
		table.insert(reportParts, "Checked avatar + Uhhhhhh character")
		table.insert(reportParts, "Total hats: " .. #HatCache)
		if #newOnes > 0 then
			table.insert(reportParts, "NEW: " .. table.concat(newOnes, ", "))
		end
		if #missing > 0 then
			table.insert(reportParts, "GONE: " .. table.concat(missing, ", "))
		end
		if #newOnes == 0 and #missing == 0 then
			table.insert(reportParts, "No change since last scan")
		end
		m.LastRefreshReport = table.concat(reportParts, " | ")
		if report then
			warn("[HatStand] " .. m.LastRefreshReport)
			warn("[HatStand]\n" .. m.PreviewText)
		end
		return HatCache
	end

	function X.hatFingerprint()
		local parts = {}
		for _, h in ipairs(HatCache) do
			local tag = h.Ours and ":O" or (h.Used and ":U" or ":S")
			table.insert(parts, h.Name .. tag .. ":" .. tostring(h.LimbGuess or "") .. ":" .. tostring(h.Source))
		end
		return table.concat(parts, "|")
	end

	X.dropdownNames = function(includeNone)
		pcall(function()
			if #HatCache == 0 then X.refreshAllHats() end
		end)
		HatCache = HatCache or {}
		local names = {}
		if includeNone then table.insert(names, "(none)") end
		for _, h in ipairs(HatCache) do
			local label = tostring(h.Name or "?")
			if h.LimbGuess then label = label .. " [" .. h.LimbGuess .. "]" end
			if h.Used then label = label .. " USED" end
			label = label .. " · " .. tostring(h.Source or "?")
			table.insert(names, label)
		end
		if #names == 0 or (#names == 1 and includeNone) then table.insert(names, "(no hats)") end
		return names
	end

	X.dropdownNamesStand = function()
		pcall(function()
			if #HatCache == 0 then X.refreshAllHats() end
		end)
		HatCache = HatCache or {}
		local names = { "(auto)" }
		for _, h in ipairs(HatCache) do
			local label = tostring(h.Name or "?")
			if h.LimbGuess then label = label .. " [" .. h.LimbGuess .. "]" end
			if h.Used then label = label .. " USED" end
			label = label .. " · " .. tostring(h.Source or "?")
			table.insert(names, label)
		end
		if #names == 1 then names = { "(no hats)" } end
		return names
	end

	X.cleanLabel = function(label)
		label = X.trim(label)
		if label == "" or label == "(auto)" or label == "(no hats)" or label == "(none)" then return "" end
		label = label:gsub("%s*%[.-%]", ""):gsub("%s*USED", ""):gsub("%s*·.*$", "")
		return X.trim(label)
	end

	X.findHatFromLabel = function(label, claimed)
		label = X.cleanLabel(label)
		if label == "" then return nil end
		local lower = string.lower(label)
		local fallback = nil
		for pass = 1, 2 do
			for _, h in ipairs(HatCache) do
				local srcOk = (pass == 2) or (h.Source == "Character") or not m.FEMode
				if srcOk and string.lower(h.Name) == lower then
					if not (claimed and h.Handle and claimed[h.Handle]) then return h end
					fallback = fallback or h
				end
			end
		end
		if fallback then return fallback end
		for _, h in ipairs(HatCache) do
			if string.find(string.lower(h.Name), lower, 1, true) then
				if not (claimed and h.Handle and claimed[h.Handle]) then return h end
				fallback = fallback or h
			end
		end
		return fallback
	end

	X.orbitReservedName = function(name)
		if not (m.OrbitEnabled and X.modeAllowsOrbit()) then return false end
		local lower = string.lower(name or "")
		for i = 1, 10 do
			local lab = X.cleanLabel(m["OrbitHat" .. i] or "")
			if lab ~= "" and string.lower(lab) == lower then return true end
		end
		return false
	end

	X.autoAllowed = function(h, claimed, kind)
		if not h.Handle or not h.Handle.Parent then return false end
		if claimed[h.Handle] then return false end
		if Claims[h.Handle] and Claims[h.Handle] ~= INSTANCE_ID then return false end
		if kind ~= "orbit" and X.orbitReservedName(h.Name) then return false end
		local hd = Held[h.Handle]
		if hd and hd.Kind and hd.Kind ~= (kind or "stand") then return false end
		if h.Used and not m.AllowUsedHats then return false end
		if m.FEMode and h.Source ~= "Character" then return false end
		return true
	end

	X.findHatForLimb = function(limb, claimed, kind, keys)
		kind = kind or "stand"
		keys = keys or LIMB_KEYS
		local label = m[keys[limb]]
		local manual = X.findHatFromLabel(label, claimed)
		if manual and manual.Handle and manual.Handle.Parent and not claimed[manual.Handle] then
			return manual
		end
		-- Strict: you picked this exact hat -> never swap in a different one
		if m.StrictHats and X.trim(label) ~= "" then return nil end
		local autoLimb = (kind == "clone") and m.CloneAutoHats or (kind ~= "clone" and m.AutoLimbHats)
		if m.SelectFirst then autoLimb = false end
		if autoLimb then
			for _, h in ipairs(HatCache) do
				if h.LimbGuess == limb and X.autoAllowed(h, claimed, kind) then return h end
			end
		end
		return nil
	end

	X.nextSpare = function(claimed, kind)
		for _, h in ipairs(HatCache) do
			if (not h.Used) and (not h.LimbGuess) and X.autoAllowed(h, claimed, kind) then return h end
		end
		return nil
	end

	X.clearLabels = function()
		for _, gui in pairs(NameLabels) do pcall(function() gui:Destroy() end) end
		NameLabels = {}
	end

	function X.makeLabel(part, text)
		if not m.ShowHatNames or not part then return end
		local bg = Instance.new("BillboardGui")
		bg.Name = "HS_HatName"
		bg.Size = UDim2.fromOffset(130, 22)
		bg.StudsOffset = Vector3.new(0, 1.15, 0)
		bg.AlwaysOnTop = true
		bg.Adornee = part
		bg.Parent = part
		local tl = Instance.new("TextLabel")
		tl.Size = UDim2.fromScale(1, 1)
		tl.BackgroundTransparency = 0.3
		tl.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		tl.TextColor3 = Color3.fromRGB(255, 230, 100)
		tl.TextScaled = true
		tl.Font = Enum.Font.Code
		tl.Text = text
		tl.Parent = bg
		Instance.new("UICorner", tl).CornerRadius = UDim.new(0, 4)
		NameLabels[part] = bg
	end

	X.clearLimbPreview = function()
		for _, p in pairs(LimbPreviewParts) do
			pcall(function() p:Destroy() end)
		end
		LimbPreviewParts = {}
	end

	local PREVIEW_COLORS = {
		Head = Color3.fromRGB(255, 220, 80),
		Torso = Color3.fromRGB(80, 180, 255),
		LeftArm = Color3.fromRGB(100, 255, 140),
		RightArm = Color3.fromRGB(100, 255, 140),
		LeftLeg = Color3.fromRGB(255, 120, 180),
		RightLeg = Color3.fromRGB(255, 120, 180),
	}

	X.updateLimbPreview = function()
		X.clearLimbPreview()
		if not m.ShowLimbPreview then return end
		if not StandRoot or not StandRoot.Parent then return end
		for _, limb in ipairs(LIMB_NAMES) do
			local offset = X.makeBaseOffset(limb)
			local part = Instance.new("Part")
			part.Name = "HS_Preview_" .. limb
			part.Size = Vector3.new(0.55, 0.55, 0.55)
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.Material = Enum.Material.Neon
			part.Color = PREVIEW_COLORS[limb] or Color3.fromRGB(200, 200, 200)
			part.Transparency = 0.45
			part.CFrame = StandRoot.CFrame * offset
			part.Parent = StandModel or workspace
			local bg = Instance.new("BillboardGui")
			bg.Size = UDim2.fromOffset(70, 16)
			bg.StudsOffset = Vector3.new(0, 0.7, 0)
			bg.AlwaysOnTop = true
			bg.Adornee = part
			bg.Parent = part
			local tl = Instance.new("TextLabel")
			tl.Size = UDim2.fromScale(1, 1)
			tl.BackgroundTransparency = 0.4
			tl.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			tl.TextColor3 = Color3.fromRGB(255, 255, 255)
			tl.TextScaled = true
			tl.Font = Enum.Font.Code
			tl.Text = limb
			tl.Parent = bg
			Instance.new("UICorner", tl).CornerRadius = UDim.new(0, 3)
			LimbPreviewParts[limb] = part
		end
	end

	--------------------------------------------------------------
	-- FE CONTROL
	--------------------------------------------------------------
	X.releaseOne = function(handle, held)
		if handle and Claims[handle] == INSTANCE_ID then Claims[handle] = nil end
		pcall(function() if held.AP then held.AP:Destroy() end end)
		pcall(function() if held.AO then held.AO:Destroy() end end)
		pcall(function() if held.Att then held.Att:Destroy() end end)
		local acc = held.Acc
		if acc and acc.Parent then
			local char = LocalPlayer.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if hum then pcall(function() hum:AddAccessory(acc) end) end
		end
	end

	X.releaseHeld = function(keepSet)
		for handle, held in pairs(Held) do
			if not (keepSet and keepSet[handle]) then
				X.releaseOne(handle, held)
				Held[handle] = nil
			end
		end
	end

	X.attachFE = function(hat, kind)
		local handle = hat.Handle
		if not handle or not handle.Parent then return nil end
		if Held[handle] then
			Held[handle].Kind = kind or Held[handle].Kind
			return Held[handle]
		end
		if Claims[handle] and Claims[handle] ~= INSTANCE_ID then return nil end -- another Hat module owns it
		Claims[handle] = INSTANCE_ID pcall(X.boostNetwork)
		local held = { Acc = hat.Accessory, Handle = handle, Kind = kind or "stand" }
		for _, d in ipairs(handle:GetChildren()) do
			if d:IsA("JointInstance") or d:IsA("WeldConstraint") then
				pcall(function() d:Destroy() end)
			end
		end
		pcall(function()
			handle.Anchored = false
			handle.CanCollide = false
			handle.CanTouch = false
			handle.Massless = true
			handle.LocalTransparencyModifier = 0
		end)
		pcall(function()
			local att = Instance.new("Attachment")
			att.Name = "HS_Att"
			att.Parent = handle
			held.Att = att
			local ap = Instance.new("AlignPosition")
			ap.Name = "HS_AP"
			ap.Mode = Enum.PositionAlignmentMode.OneAttachment
			ap.Attachment0 = att
			ap.RigidityEnabled = true
			ap.MaxForce = math.huge
			ap.Responsiveness = 200
			ap.Position = handle.Position
			ap.Parent = handle
			held.AP = ap
			local ao = Instance.new("AlignOrientation")
			ao.Name = "HS_AO"
			ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
			ao.Attachment0 = att
			ao.RigidityEnabled = true
			ao.MaxTorque = math.huge
			ao.Responsiveness = 200
			ao.CFrame = handle.CFrame
			ao.Parent = handle
			held.AO = ao
		end)
		Held[handle] = held
		return held
	end

	X.driveHandle = function(held, cf, vel)
		if not held or not held.Handle then return end
		local last = held.LastCF
		held.LastCF = cf
		if m.HatsSolid and not vel then
			-- solid hats need a real velocity or they only overlap things instead of pushing them
			local t = os.clock()
			if last and held.LastT and t > held.LastT then
				local v = (cf.Position - last.Position) / (t - held.LastT) * (m.HatsSolidPush or 1)
				if v.Magnitude > 250 then v = v.Unit * 250 end
				vel = v
			end
			held.LastT = t
		end
		-- low-lag: a hat that has not moved does not need its CFrame/velocity rewritten every frame
		if last and not vel and m.LowLag ~= false then
			local sk = (held.SkipN or 0) + 1
			if sk < 8
				and (last.Position - cf.Position).Magnitude < 0.004
				and last.LookVector:Dot(cf.LookVector) > 0.99999
				and last.UpVector:Dot(cf.UpVector) > 0.99999 then
				held.SkipN = sk
				return
			end
			held.SkipN = 0
		end
		local part = held.Handle
		pcall(function()
			if held.AP then held.AP.Position = cf.Position end
			if held.AO then held.AO.CFrame = cf end
			part.CFrame = cf
			part.AssemblyLinearVelocity = vel or Vector3.zero
			part.AssemblyAngularVelocity = Vector3.zero
		end)
	end

	X.cloneHandle = function(handle, name)
		local ok, clone = pcall(function() return handle:Clone() end)
		if not ok or not clone then return nil end
		clone.Name = "Stand_" .. name
		clone.Anchored = true
		clone.CanCollide = false
		clone.CanQuery = false
		clone.CanTouch = false
		clone.Massless = true
		pcall(function()
			clone.LocalTransparencyModifier = 0
			if clone.Transparency > 0.5 then clone.Transparency = 0 end
		end)
		for _, d in ipairs(clone:GetDescendants()) do
			if d:IsA("Weld") or d:IsA("WeldConstraint") or d:IsA("Motor6D")
				or d:IsA("RigidConstraint") or d:IsA("JointInstance") then
				pcall(function() d:Destroy() end)
			elseif d:IsA("BasePart") then
				pcall(function() d.Anchored = true d.CanCollide = false end)
			end
		end
		return clone
	end

	--------------------------------------------------------------
	-- STAND
	--------------------------------------------------------------
	X.destroyStand = function()
		local keep = {}
		for handle, held in pairs(Held) do
			if held.Kind and held.Kind ~= "stand" then keep[handle] = true end
		end
		X.releaseHeld(keep)
		X.clearLabels()
		X.clearLimbPreview()
		Limbs = {}
		if StandModel then pcall(function() StandModel:Destroy() end) end
		StandModel, StandRoot = nil, nil
		AnimState, AnimT = "idle", 0
	end

	X.buildStand = function()
		if not X.modeAllowsStand() then return false end
		if m.SelectFirst and not X.Applied then return false end
		LastBuild = os.clock()
		X.clearLabels()
		Limbs = {}
		X.refreshAllHats()
		LastHatFingerprint = X.hatFingerprint()
		local followRoot = X.getFollowRoot()
		if not followRoot then
			warn("[HatStand] no follow root yet")
			return false
		end
		if m.FEMode then X.boostNetwork() end
		if not StandModel or not StandModel.Parent then
			local model = Instance.new("Model")
			model.Name = ("UhhhhhhHatStand" .. SUF)
			local root = Instance.new("Part")
			root.Name = "StandRoot"
			root.Size = Vector3.new(0.3, 0.3, 0.3)
			root.Transparency = 1
			root.Anchored = true
			root.CanCollide = false
			root.CanQuery = false
			root.CanTouch = false
			root.CFrame = followRoot.CFrame * CFrame.new(m.SideOffset, m.HeightOffset, m.ForwardOffset)
			root.Parent = model
			model.PrimaryPart = root
			model.Parent = workspace
			StandModel, StandRoot = model, root
		elseif not StandRoot or not StandRoot.Parent then
			StandRoot = StandModel:FindFirstChild("StandRoot")
		end
		if StandModel then
			for _, ch in ipairs(StandModel:GetChildren()) do
				if ch ~= StandRoot and ch.Name:sub(1, 6) == "Stand_" then
					pcall(function() ch:Destroy() end)
				end
			end
		end
		local claimed, assignment = {}, {}
		for handle, held in pairs(Held) do
			if held.Kind == "clone" then claimed[handle] = true end
		end
		for _, limb in ipairs(LIMB_NAMES) do
			local hat = X.findHatForLimb(limb, claimed, "stand", LIMB_KEYS)
			if hat then claimed[hat.Handle] = true assignment[limb] = hat end
		end
		if m.AutoSpareHats and not m.SelectFirst then
			for _, limb in ipairs(LIMB_NAMES) do
				if not assignment[limb] and not (m.StrictHats and X.trim(m[LIMB_KEYS[limb]]) ~= "") then
					local hat = X.nextSpare(claimed, "stand")
					if hat then claimed[hat.Handle] = true assignment[limb] = hat end
				end
			end
		end
		local keep = {}
		for handle, held in pairs(Held) do
			if held.Kind and held.Kind ~= "stand" then keep[handle] = true end
		end
		local assigned = 0
		for _, limb in ipairs(LIMB_NAMES) do
			local hat = assignment[limb]
			if hat then
				local offset = X.makeBaseOffset(limb)
				local part, held = nil, nil
				if m.FEMode then
					held = X.attachFE(hat, "stand")
					if held then keep[hat.Handle] = true part = hat.Handle end
				else
					part = X.cloneHandle(hat.Handle, limb .. "_" .. hat.Name)
					if part then part.CFrame = StandRoot.CFrame * offset part.Parent = StandModel end
				end
				if part then
					Limbs[limb] = { Part = part, BaseOffset = offset, Name = hat.Name, Limb = limb, Held = held }
					X.makeLabel(part, limb .. ": " .. hat.Name)
					assigned = assigned + 1
				end
			end
		end
		X.releaseHeld(keep)
		X.refreshAllHats()
		LastHatFingerprint = X.hatFingerprint()
		X.updateLimbPreview()
		warn("[HatStand] limbs=" .. tostring(assigned) .. " FE=" .. tostring(m.FEMode))
		return assigned > 0
	end

	--------------------------------------------------------------
	-- ANIM (dance detection improved)
	--------------------------------------------------------------
	X.newOffsets = function()
		return {
			Head = CFrame.new(), Torso = CFrame.new(),
			LeftArm = CFrame.new(), RightArm = CFrame.new(),
			LeftLeg = CFrame.new(), RightLeg = CFrame.new(),
		}
	end

	function X.playerIsDancing(hum)
		if ForceDance and os.clock() < ForceDanceUntil then
			DetectedDanceName = "force"
			return true
		end
		if not m.DanceSync or not hum then return false end
		local animator = hum:FindFirstChildOfClass("Animator")
		if not animator then return false end
		local ok, tracks = pcall(function() return animator:GetPlayingAnimationTracks() end)
		if not ok or type(tracks) ~= "table" then return false end
		DetectedDanceName = ""
		local bestWeight, bestName = 0, ""
		for _, track in ipairs(tracks) do
			local playing = false
			pcall(function() playing = track.IsPlaying end)
			if playing then
				local w = 0
				pcall(function() w = track.weightCurrent or 0 end)
				if w >= 0.08 then
					local name = ""
					pcall(function()
						name = string.lower(tostring(track.Name or "") .. " " .. tostring(track.Animation and track.Animation.Name or ""))
					end)
					local isLoco = string.find(name, "walk", 1, true) or string.find(name, "run", 1, true)
						or string.find(name, "jump", 1, true) or string.find(name, "fall", 1, true)
						or string.find(name, "climb", 1, true) or string.find(name, "swim", 1, true)
					local isIdle = false
					if m.PoseFix then
						local hintHit = false
						for _, hint in ipairs(DANCE_HINTS) do
							if string.find(name, hint, 1, true) then hintHit = true break end
						end
						if string.find(name, "idle", 1, true) or string.find(name, "toolnone", 1, true) then isIdle = true end
						pcall(function()
							if track.Priority == Enum.AnimationPriority.Idle and not hintHit then isIdle = true end
						end)
					end
					if not isLoco and not isIdle then
						local matched = false
						for _, hint in ipairs(DANCE_HINTS) do
							if string.find(name, hint, 1, true) then
								matched = true
								break
							end
						end
						local len = 0
						pcall(function() len = track.Length or 0 end)
						if matched or (w > 0.35 and len > 0.8) or (w > 0.55) then
							if w > bestWeight then
								bestWeight, bestName = w, name
							end
						end
					end
				end
			end
		end
		if bestWeight > 0 then
			DetectedDanceName = bestName
			return true
		end
		return false
	end

	local CHAR_LIMB_NAMES = {
		Head = { "Head" },
		Torso = { "Torso", "UpperTorso" },
		LeftArm = { "Left Arm", "LeftUpperArm", "LeftHand" },
		RightArm = { "Right Arm", "RightUpperArm", "RightHand" },
		LeftLeg = { "Left Leg", "LeftUpperLeg", "LeftFoot" },
		RightLeg = { "Right Leg", "RightUpperLeg", "RightFoot" },
	}
	function X.sampleCharacterLimbOffsets()
		if not m.DanceMirrorCharacter then return nil end
		local char = LocalPlayer.Character
		if not char then return nil end
		local root = X.getRoot(char)
		if not root then return nil end
		local inv = root.CFrame:Inverse()
		local out = X.newOffsets()
		local got = 0
		for limb, names in pairs(CHAR_LIMB_NAMES) do
			for _, n in ipairs(names) do
				local part = char:FindFirstChild(n)
				if part and part:IsA("BasePart") then
					local rel = inv * part.CFrame
					local base = X.makeBaseOffset(limb)
					out[limb] = base:Inverse() * rel
					got = got + 1
					break
				end
			end
		end
		if got < 3 then return nil end
		return out
	end

	X.updateLocoMode = function(dt)
		local followRoot = X.getFollowRoot()
		local hum = X.getLiveHumanoid()
		if X.playerIsDancing(hum) then
			LocoMode = "dance"
			DanceT = DanceT + dt
			return
		end
		if not followRoot then LocoMode = "idle" return end
		local vel = followRoot.AssemblyLinearVelocity or Vector3.zero
		local horiz = Vector3.new(vel.X, 0, vel.Z).Magnitude
		local state = hum and hum:GetState() or nil
		if state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall or vel.Y > 8 then
			LocoMode = "jump"
		elseif horiz > (m.RunThreshold or 14) then
			LocoMode = "run"
			LocoT = LocoT + dt
		elseif horiz > 1.5 then
			LocoMode = "walk"
			LocoT = LocoT + dt
		else
			LocoMode = "idle"
		end
	end


	function X.jojoWalkOffsets(t, strength)
		local o, s = X.newOffsets(), strength or 1
		local sw, sw2 = math.sin(t), math.sin(t + math.pi)
		o.LeftLeg = CFrame.Angles(-math.rad(28) * sw * s, 0, math.rad(4) * s)
			* CFrame.new(0, math.max(0, -sw) * 0.12 * s, -0.15 * sw * s)
		o.RightLeg = CFrame.Angles(-math.rad(28) * sw2 * s, 0, -math.rad(4) * s)
			* CFrame.new(0, math.max(0, -sw2) * 0.12 * s, -0.15 * sw2 * s)
		o.LeftArm = CFrame.Angles(-math.rad(35) * sw2 * s, 0, math.rad(18) * s)
			* CFrame.new(0.05 * s, 0, -0.1 * sw2 * s)
		o.RightArm = CFrame.Angles(-math.rad(35) * sw * s, 0, -math.rad(18) * s)
			* CFrame.new(-0.05 * s, 0, -0.1 * sw * s)
		o.Torso = CFrame.Angles(math.rad(6) * s, math.rad(8) * sw * s, 0)
			* CFrame.new(0, math.abs(sw) * 0.04 * s, 0)
		o.Head = CFrame.Angles(math.rad(4) * s, -math.rad(6) * sw * s, 0)
		return o
	end

	function X.jojoRunOffsets(t, strength)
		local o, s = X.newOffsets(), strength or 1
		local sw, sw2 = math.sin(t), math.sin(t + math.pi)
		o.LeftLeg = CFrame.Angles(-math.rad(55) * sw * s, 0, math.rad(8) * s)
			* CFrame.new(0, math.max(0, -sw) * 0.2 * s, -0.35 * sw * s)
		o.RightLeg = CFrame.Angles(-math.rad(55) * sw2 * s, 0, -math.rad(8) * s)
			* CFrame.new(0, math.max(0, -sw2) * 0.2 * s, -0.35 * sw2 * s)
		o.LeftArm = CFrame.Angles(-math.rad(70) * sw2 * s, math.rad(10) * s, math.rad(25) * s)
			* CFrame.new(0.1 * s, 0.1 * s, -0.4 * sw2 * s)
		o.RightArm = CFrame.Angles(-math.rad(70) * sw * s, -math.rad(10) * s, -math.rad(25) * s)
			* CFrame.new(-0.1 * s, 0.1 * s, -0.4 * sw * s)
		o.Torso = CFrame.Angles(math.rad(18) * s, math.rad(12) * sw * s, 0)
			* CFrame.new(0, math.abs(sw) * 0.08 * s, 0)
		o.Head = CFrame.Angles(math.rad(12) * s, -math.rad(8) * sw * s, 0)
		return o
	end

	function X.jojoJumpOffsets(strength)
		local o, s = X.newOffsets(), strength or 1
		o.LeftArm = CFrame.Angles(-math.rad(30) * s, 0, math.rad(50) * s) * CFrame.new(0.15 * s, 0.3 * s, -0.1 * s)
		o.RightArm = CFrame.Angles(-math.rad(30) * s, 0, -math.rad(50) * s) * CFrame.new(-0.15 * s, 0.3 * s, -0.1 * s)
		o.LeftLeg = CFrame.Angles(math.rad(25) * s, 0, math.rad(10) * s) * CFrame.new(0, 0.2 * s, 0.15 * s)
		o.RightLeg = CFrame.Angles(math.rad(15) * s, 0, -math.rad(10) * s) * CFrame.new(0, 0.15 * s, 0.1 * s)
		o.Torso = CFrame.Angles(-math.rad(8) * s, 0, 0) * CFrame.new(0, 0.15 * s, 0)
		o.Head = CFrame.Angles(math.rad(10) * s, 0, 0)
		return o
	end

	X.danceOffsets = function(t, strength)
		local o = X.newOffsets()
		local s = (strength or 1) * (m.DanceStrength or 1)
		local a, b, c = math.sin(t * 6.5), math.sin(t * 4.2), math.cos(t * 5.1)
		-- slightly vary by detected dance name
		local dn = DetectedDanceName or ""
		if string.find(dn, "floss") or string.find(dn, "disco") then
			a, b = math.sin(t * 8), math.sin(t * 3.5)
		elseif string.find(dn, "robot") then
			a = math.sin(t * 4) * 0.6
			b = math.cos(t * 4) * 0.6
		elseif string.find(dn, "wave") or string.find(dn, "cheer") then
			a = math.sin(t * 5)
			b = math.sin(t * 2.2)
		end
		o.Torso = CFrame.Angles(math.rad(5) * a * s, math.rad(20) * b * s, math.rad(8) * c * s)
			* CFrame.new(b * 0.2 * s, math.abs(a) * 0.25 * s, 0)
		o.Head = CFrame.Angles(math.rad(10) * a * s, math.rad(25) * b * s, math.rad(5) * c * s)
		o.LeftArm = CFrame.Angles(-math.rad(80) + math.rad(40) * a * s, 0, math.rad(40) + math.rad(30) * b * s)
			* CFrame.new(0.2 * s, 0.3 * s, -0.2 * s)
		o.RightArm = CFrame.Angles(-math.rad(80) + math.rad(40) * c * s, 0, -math.rad(40) - math.rad(30) * a * s)
			* CFrame.new(-0.2 * s, 0.3 * s, -0.2 * s)
		o.LeftLeg = CFrame.Angles(math.rad(15) * b * s, 0, math.rad(12) * s)
			* CFrame.new(0, math.max(0, a) * 0.15 * s, 0)
		o.RightLeg = CFrame.Angles(math.rad(15) * c * s, 0, -math.rad(12) * s)
			* CFrame.new(0, math.max(0, -a) * 0.15 * s, 0)
		return o
	end

	function X.ballerOffsets(t)
		local o = X.newOffsets()
		local s = 1
		local a = math.sin(t * 2.8)
		local b = math.sin(t * 1.6)
		o.Torso = CFrame.Angles(math.rad(8), math.rad(12) * b, 0) * CFrame.new(0, math.abs(a) * 0.08, 0)
		o.Head = CFrame.Angles(math.rad(6), -math.rad(10) * b, 0)
		o.LeftArm = CFrame.Angles(-math.rad(25) + a * 0.15, 0, math.rad(35))
			* CFrame.new(0.1, 0.15, -0.15)
		o.RightArm = CFrame.Angles(-math.rad(20) - a * 0.1, 0, -math.rad(40))
			* CFrame.new(-0.15, 0.2, -0.25)
		o.LeftLeg = CFrame.Angles(math.rad(5) * a, 0, math.rad(8))
		o.RightLeg = CFrame.Angles(-math.rad(8) * a, 0, -math.rad(6))
		return o
	end

	X.buildAnimOffsets = function(t, speed)
		local o = X.newOffsets()
		local s = speed or 1
		local a = math.sin(t * 8 * s)
		local b = math.sin(t * 5 * s)
		o.RightArm = CFrame.Angles(-math.rad(70) + math.rad(25) * a, math.rad(10), -math.rad(15))
			* CFrame.new(-0.1, 0.2 + 0.1 * a, -0.8 + 0.15 * a)
		o.LeftArm = CFrame.Angles(-math.rad(40), 0, math.rad(25)) * CFrame.new(0.15, 0.1, -0.2)
		o.Torso = CFrame.Angles(math.rad(12) + math.rad(3) * b, -math.rad(15), 0)
		o.Head = CFrame.Angles(math.rad(8), math.rad(10) * b, 0)
		return o
	end

	X.idleOffsets = function()
		local o = X.newOffsets()
		local style, t = m.IdleStyle, IdleT
		if m.BallerMode or style == 7 then
			return X.ballerOffsets(t)
		end
		if style == 6 then return o end
		if style == 1 then
			local b, s = math.sin(t * 1.7) * 0.05, math.sin(t * 0.9) * 0.025
			o.Torso = CFrame.new(0, b, 0) * CFrame.Angles(0, s, 0)
			o.Head = CFrame.Angles(b * 0.6, s * 1.4, 0)
			o.LeftArm = CFrame.Angles(math.sin(t * 1.3) * 0.06, 0, math.rad(5))
			o.RightArm = CFrame.Angles(-math.sin(t * 1.3) * 0.06, 0, -math.rad(5))
		elseif style == 2 then
			local b = math.abs(math.sin(t * 3.2)) * 0.2
			o.Torso = CFrame.new(0, b, 0)
			o.LeftArm = CFrame.Angles(-b * 0.8, 0, math.rad(8))
			o.RightArm = CFrame.Angles(-b * 0.8, 0, -math.rad(8))
		elseif style == 3 then
			o.LeftArm = CFrame.Angles(-math.rad(35), 0, math.rad(25)) * CFrame.new(0.15, 0.1, -0.2)
			o.RightArm = CFrame.Angles(-math.rad(40), 0, -math.rad(20)) * CFrame.new(-0.1, 0.15, -0.35)
			o.Torso = CFrame.Angles(math.rad(5), -math.rad(8), 0)
		elseif style == 4 then
			local sw = math.sin(t * 2.4)
			o.Torso = CFrame.Angles(0, 0, sw * 0.12) * CFrame.new(sw * 0.15, 0, 0)
			o.LeftArm = CFrame.Angles(sw * 0.4, 0, math.rad(20) + sw * 0.3)
			o.RightArm = CFrame.Angles(-sw * 0.4, 0, -math.rad(20) - sw * 0.3)
		elseif style == 5 then
			local f = math.sin(t * 1.2) * 0.35
			o.Torso = CFrame.new(0, 0.8 + f, 0)
			o.LeftArm = CFrame.Angles(0, 0, math.rad(25))
			o.RightArm = CFrame.Angles(0, 0, -math.rad(25))
		end
		return o
	end

	X.combatOffsets = function(state, t)
		local o = X.newOffsets()
		local s = m.AnimSpeed
		local a = math.clamp(t * 9 * s, 0, 1)
		local swing = math.sin(a * math.pi)
		if state == "punch" then
			o.RightArm = CFrame.Angles(-math.rad(100) * swing, math.rad(10) * swing, math.rad(25) * swing)
				* CFrame.new(0.2 * swing, 0.15 * swing, -1.6 * swing)
			o.Torso = CFrame.Angles(math.rad(8) * swing, -math.rad(40) * swing, 0)
			o.LeftArm = CFrame.Angles(math.rad(40) * swing, 0, math.rad(15) * swing)
		elseif state == "punch2" then
			o.LeftArm = CFrame.Angles(-math.rad(100) * swing, -math.rad(10) * swing, -math.rad(25) * swing)
				* CFrame.new(-0.2 * swing, 0.15 * swing, -1.6 * swing)
			o.Torso = CFrame.Angles(math.rad(8) * swing, math.rad(40) * swing, 0)
		elseif state == "uppercut" then
			o.RightArm = CFrame.Angles(-math.rad(140) * swing, 0, 0) * CFrame.new(0, 1.4 * swing, -0.6 * swing)
			o.Torso = CFrame.Angles(-math.rad(20) * swing, 0, 0)
		elseif state == "kick" then
			o.RightLeg = CFrame.Angles(-math.rad(110) * swing, 0, 0) * CFrame.new(0, 0.6 * swing, -1.4 * swing)
			o.Torso = CFrame.Angles(math.rad(18) * swing, 0, 0)
		elseif state == "block" then
			o.LeftArm = CFrame.Angles(-math.rad(80), math.rad(20), math.rad(50)) * CFrame.new(0.4, 0.5, -0.6)
			o.RightArm = CFrame.Angles(-math.rad(80), -math.rad(20), -math.rad(50)) * CFrame.new(-0.4, 0.5, -0.6)
		elseif state == "wave" then
			o.RightArm = CFrame.Angles(math.rad(-20), 0, math.rad(100) + math.rad(45) * math.sin(t * 12 * s))
		end
		return o
	end

	--------------------------------------------------------------
	-- v14: ROOT-SPACE ANIMATION, RIG LINK, LOCO V2, DANCE LIST, CLONE
	-- (all new functions live on the X table to stay under Luau's local limit)
	--------------------------------------------------------------
	X.standUnit = function()
		local h = (m.BigRigFix or m.FixAnyRigPose) and (m.BigRigHeight or 1) or 1
		return (m.StandScale or 1) * h
	end

	-- Rotate a limb about its joint. `joint` = vector from limb centre to its pivot.
	-- Result: CFrame whose position is the centre shift and rotation is R (stand-root space).
	X.pivotExtra = function(R, joint)
		return CFrame.new(joint - R:VectorToWorldSpace(joint)) * R
	end

	-- old limb-local extras (base * X) -> root-space extra with identical result
	function X.legacyToRoot(base, lx)
		local brot = base - base.Position
		local xp = lx.Position
		local xr = lx - xp
		local R = brot * xr * brot:Inverse()
		return CFrame.new(brot:VectorToWorldSpace(xp)) * R
	end

	X.applyRootExtra = function(base, E)
		local bp = base.Position
		local dp = E.Position
		local R = E - dp
		return CFrame.new(bp + dp) * R * (base - bp)
	end

	X.carry = function(Rt, limb, joint)
		local tc = X.makeBaseOffset("Torso").Position
		local d = X.makeBaseOffset(limb).Position + joint - tc
		return Rt:VectorToWorldSpace(d) - d
	end

	-- ---------- air / landing tracking ----------
	X.updateAir = function(dt)
		local hum = X.getLiveHumanoid()
		local air, st = false, nil
		if hum then
			pcall(function() st = hum:GetState() end)
			air = (st == Enum.HumanoidStateType.Freefall or st == Enum.HumanoidStateType.Jumping)
		else
			local r = X.getFollowRoot()
			if r then air = math.abs((r.AssemblyLinearVelocity or Vector3.zero).Y) > 8 end
		end
		X.State = st
		X.Air = air
		if air then
			X.AirT = X.AirT + dt
			X.WasAir = true
		else
			if X.WasAir and X.AirT > 0.18 then X.LandT = 0.24 end
			X.WasAir = false
			X.AirT = 0
		end
		X.LandT = math.max(0, X.LandT - dt)
	end

	-- ---------- rig link: copy the real animated rig onto the stand ----------
	X.getSourceRig = function()
		local src = m.LinkSource or 1
		local function pick(model)
			if not (model and model.Parent) then return nil, nil end
			local root = model:FindFirstChild("HumanoidRootPart")
				or model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso")
			if root and root:IsA("BasePart") then return model, root end
			return nil, nil
		end
		if src ~= 3 then
			local uh = nil
			pcall(function() uh = _G.Uhhhhhh and _G.Uhhhhhh.Character end)
			local mdl, r = pick(uh)
			if mdl then return mdl, r end
			if src == 2 then return nil, nil end
		end
		return pick(LocalPlayer.Character)
	end

	X.rawSample = function()
		if X.RawFrame == X.Frame then return X.Raw end
		X.RawFrame = X.Frame
		X.Raw = nil
		local model, root = X.getSourceRig()
		if not model then return nil end
		local inv = root.CFrame:Inverse()
		local rot, got = {}, 0
		if X._rawModel ~= model then X._rawModel = model; X._rawParts = {} end
		local pc = X._rawParts
		for limb, names in pairs(CHAR_LIMB_NAMES) do
			for _, n in ipairs(names) do
				local part = pc[n]
				if not (part and part.Parent) then
					part = model:FindFirstChild(n)
					pc[n] = part
				end
				if part and part:IsA("BasePart") then
					local rel = inv * part.CFrame
					rot[limb] = rel - rel.Position
					got = got + 1
					break
				end
			end
		end
		if got < 3 then return nil end
		X.Raw = rot
		return rot
	end

	X.calibrate = function()
		local raw = X.rawSample()
		if not raw then
			warn("[HatStand] calibrate: no source rig found")
			return false
		end
		X.Rest = {}
		for k, v in pairs(raw) do X.Rest[k] = v end
		X.RestSet = true
		X.Blend = {}
		warn("[HatStand] rest pose calibrated")
		return true
	end

	X.autoCalib = function(dt)
		if not (m.PoseFix and m.PoseAutoCalib) or X.RestSet then X.CalibT = 0 return end
		local raw = X.rawSample()
		if not raw then X.CalibT = 0 return end
		local fr = X.getFollowRoot()
		local v = fr and fr.AssemblyLinearVelocity or Vector3.zero
		local still = Vector3.new(v.X, 0, v.Z).Magnitude < 0.6 and math.abs(v.Y) < 2
			and LocoMode ~= "dance" and not (ForceDance and os.clock() < ForceDanceUntil)
		local dev = 1
		if X.LastRaw then
			dev = 0
			for k, c in pairs(raw) do
				local o = X.LastRaw[k]
				if o then dev = dev + (c.LookVector - o.LookVector).Magnitude + (c.UpVector - o.UpVector).Magnitude end
			end
		end
		X.LastRaw = raw
		if still and dev < 0.03 then X.CalibT = X.CalibT + dt else X.CalibT = 0 end
		if X.CalibT > 0.9 then
			X.CalibT = 0
			X.calibrate()
		end
	end

	X.fixArms = function(rot)
		local L, R = rot.LeftArm, rot.RightArm
		if m.PoseSwapArms and L and R then
			local function mir(c)
				local rx, ry, rz = c:ToEulerAnglesXYZ()
				return CFrame.Angles(rx, -ry, -rz)
			end
			L, R = mir(R), mir(L)
		end
		if m.PoseInvertArmPitch or m.PoseInvertArmRoll then
			local function adj(c)
				if not c then return c end
				local rx, ry, rz = c:ToEulerAnglesXYZ()
				if m.PoseInvertArmPitch then rx = -rx end
				if m.PoseInvertArmRoll then rz = -rz end
				return CFrame.Angles(rx, ry, rz)
			end
			L, R = adj(L), adj(R)
		end
		rot.LeftArm, rot.RightArm = L, R
	end

	X.sampleRig = function()
		local raw = X.rawSample()
		if not raw then return nil end
		local rot = {}
		for k, v in pairs(raw) do rot[k] = v end
		if m.PoseFix then
			if X.RestSet then
				for limb, r in pairs(rot) do
					if X.Rest[limb] then rot[limb] = r * X.Rest[limb]:Inverse() end
				end
			end
			X.fixArms(rot)
		end
		local u = X.standUnit()
		local Rt = rot.Torso or CFrame.new()
		local joints = {
			Head = Vector3.new(0, -0.6 * u, 0),
			LeftArm = Vector3.new(0, 0.9 * u, 0), RightArm = Vector3.new(0, 0.9 * u, 0),
			LeftLeg = Vector3.new(0, 0.95 * u, 0), RightLeg = Vector3.new(0, 0.95 * u, 0),
		}
		local out = {}
		local strength = m.LinkStrength or 1
		for _, limb in ipairs(LIMB_NAMES) do
			local E
			if limb == "Torso" then
				E = Rt
			else
				local R = rot[limb] or CFrame.new()
				local j = joints[limb]
				E = CFrame.new(X.carry(Rt, limb, j) + j - R:VectorToWorldSpace(j)) * R
			end
			if strength ~= 1 then E = CFrame.new():Lerp(E, math.clamp(strength, 0, 1.5)) end
			out[limb] = E
		end
		return out
	end

	-- ---------- JoJo locomotion v2 (root space, speed-locked stride) ----------
	X.locoV2 = function(dt, guard)
		local followRoot = X.getFollowRoot()
		if not followRoot then return nil end
		local u = X.standUnit()
		local vel = followRoot.AssemblyLinearVelocity or Vector3.zero
		local cfr = followRoot.CFrame
		local look = Vector3.new(cfr.LookVector.X, 0, cfr.LookVector.Z)
		local right = Vector3.new(cfr.RightVector.X, 0, cfr.RightVector.Z)
		look = look.Magnitude > 0.01 and look.Unit or Vector3.new(0, 0, -1)
		right = right.Magnitude > 0.01 and right.Unit or Vector3.new(1, 0, 0)
		local hv = Vector3.new(vel.X, 0, vel.Z)
		local a = 1 - math.exp(-(m.LocoBlend or 14) * dt)
		X.SpeedSm = X.SpeedSm + (hv.Magnitude - X.SpeedSm) * a
		X.LeanSm = X.LeanSm + (hv:Dot(look) - X.LeanSm) * a
		X.SideSm = X.SideSm + (hv:Dot(right) - X.SideSm) * a
		local sp, st, air = X.SpeedSm, X.State, X.Air
		local land = X.LandT > 0
		local climbing = (st == Enum.HumanoidStateType.Climbing)
		local seated = (st == Enum.HumanoidStateType.Seated)
		if not (sp > 0.6 or air or land or climbing or seated) then return nil end

		local runT = m.RunThreshold or 14
		local running = sp > runT
		local cyc = running and ((m.RunCycleSpeed or 12.5) / 12.5 * 0.42)
			or ((m.WalkCycleSpeed or 8.5) / 8.5 * 0.52)
		if not air then X.Phase = (X.Phase + dt * sp * cyc) % (math.pi * 2) end

		local kWalk = math.clamp(sp / 9, 0, 1)
		local kRun = math.clamp((sp - runT * 0.7) / (runT * 0.8), 0, 1)
		local ws, rs = m.WalkStrength or 1, m.RunStrength or 1.15
		local legAmp = math.rad(30) * ws * kWalk + math.rad(20) * rs * kRun
		local armAmp = math.rad(26) * ws * kWalk + math.rad(36) * rs * kRun
		local dir = (X.LeanSm < -2) and -1 or 1
		local s = math.sin(X.Phase) * dir
		local c = math.cos(X.Phase) * dir
		local bob = (math.cos(2 * X.Phase) * 0.5 + 0.5) * 0.09 * u * kWalk
			* (m.LocoBob or 1) * (1 + kRun * 0.6)
		local lean = math.clamp(X.LeanSm / 16, -0.5, 1.3) * math.rad(11) * (m.LocoLean or 1)
		local side = math.clamp(X.SideSm / 16, -1, 1) * math.rad(6) * (m.LocoLean or 1)
		local armOut = math.rad(7 + 5 * kWalk) * (m.LocoArmOut or 1)
		local armJ = Vector3.new(0, 0.9 * u, 0)
		local legJ = Vector3.new(0, 0.95 * u, 0)

		local function swing(pitch, roll, joint, lift)
			local R = CFrame.Angles(pitch, 0, 0) * CFrame.Angles(0, 0, roll)
			return CFrame.new(0, lift or 0, 0) * X.pivotExtra(R, joint)
		end

		local o = {}
		if climbing then
			X.ClimbT = X.ClimbT + dt * math.clamp(math.abs(vel.Y) / 6, 0, 3)
			local cs = math.sin(X.ClimbT * 5)
			o.LeftArm = swing(math.rad(150) + cs * math.rad(25), -math.rad(8), armJ, 0)
			o.RightArm = swing(math.rad(150) - cs * math.rad(25), math.rad(8), armJ, 0)
			o.LeftLeg = swing(math.rad(20) - cs * math.rad(25), 0, legJ, math.max(0, cs) * 0.15 * u)
			o.RightLeg = swing(math.rad(20) + cs * math.rad(25), 0, legJ, math.max(0, -cs) * 0.15 * u)
			o.Torso = CFrame.new()
			o.Head = CFrame.Angles(-math.rad(15), 0, 0)
			return o
		elseif seated then
			o.LeftArm = swing(math.rad(25), -math.rad(6), armJ, 0)
			o.RightArm = swing(math.rad(25), math.rad(6), armJ, 0)
			o.LeftLeg = swing(math.rad(85), -math.rad(4), legJ, 0)
			o.RightLeg = swing(math.rad(85), math.rad(4), legJ, 0)
			o.Torso = CFrame.new()
			o.Head = CFrame.new()
			return o
		elseif air then
			local vy = vel.Y
			local riseK = math.clamp(vy / 45, 0, 1)
			local fallK = math.clamp(-vy / 45, 0, 1)
			local fs = m.FallSpread or 1
			local js = m.JumpStrength or 1.2
			local fl = math.sin(X.AirT * 9) * math.rad(5) * fallK * fs
			local spread = (math.rad(30) + math.rad(35) * fallK) * fs
			local armUp = math.rad(35 + 25 * riseK) * js * 0.8
			o.LeftArm = swing(armUp + fl, -spread, armJ, 0)
			o.RightArm = swing(armUp - fl, spread, armJ, 0)
			o.LeftLeg = swing(math.rad(30) * riseK * js + math.rad(8) + fl, -math.rad(8), legJ, 0.12 * u * riseK)
			o.RightLeg = swing(-math.rad(14) * riseK - math.rad(10) * fallK - fl, math.rad(8), legJ, 0)
			local Rt = CFrame.Angles(-math.rad(6) * riseK + math.rad(4) * fallK, 0, 0)
			o.Torso = Rt
			o.Head = CFrame.Angles(-math.rad(8) * fallK, 0, 0)
			for _, l in ipairs({ "LeftArm", "RightArm", "LeftLeg", "RightLeg", "Head" }) do
				local j = (l == "Head") and Vector3.new(0, -0.6 * u, 0) or (l:find("Arm") and armJ or legJ)
				o[l] = CFrame.new(X.carry(Rt, l, j)) * o[l]
			end
		else
			o.LeftLeg = swing(legAmp * s, -math.rad(2), legJ, math.max(0, c) * 0.2 * u * kWalk)
			o.RightLeg = swing(-legAmp * s, math.rad(2), legJ, math.max(0, -c) * 0.2 * u * kWalk)
			if guard then
				local g = math.rad(55) * (1 - kWalk * 0.4)
				o.LeftArm = swing(g - armAmp * 0.3 * s, -math.rad(15), armJ, 0)
				o.RightArm = swing(g + armAmp * 0.3 * s, math.rad(15), armJ, 0)
			else
				o.LeftArm = swing(-armAmp * s, -armOut, armJ, 0)
				o.RightArm = swing(armAmp * s, armOut, armJ, 0)
			end
			local Rt = CFrame.Angles(-lean, -math.rad(6) * s * kWalk, -side)
			o.Torso = Rt
			o.Head = CFrame.Angles(lean * 0.7, math.rad(5) * s * kWalk, side * 0.5)
			for _, l in ipairs({ "LeftArm", "RightArm", "LeftLeg", "RightLeg", "Head" }) do
				local j = (l == "Head") and Vector3.new(0, -0.6 * u, 0) or (l:find("Arm") and armJ or legJ)
				o[l] = CFrame.new(X.carry(Rt, l, j)) * o[l]
			end
		end

		if land then
			local k = (X.LandT / 0.24) * (m.LandSquash or 1)
			local dip = CFrame.new(0, -0.28 * u * k, 0)
			o.Torso = dip * CFrame.Angles(-math.rad(14) * k, 0, 0) * o.Torso
			o.Head = dip * CFrame.Angles(math.rad(10) * k, 0, 0) * o.Head
			o.LeftArm = dip * swing(math.rad(28) * k, -math.rad(10) * k, armJ, 0) * o.LeftArm
			o.RightArm = dip * swing(math.rad(28) * k, math.rad(10) * k, armJ, 0) * o.RightArm
			o.LeftLeg = dip * swing(math.rad(12) * k, -math.rad(14) * k, legJ, 0) * o.LeftLeg
			o.RightLeg = dip * swing(-math.rad(12) * k, math.rad(14) * k, legJ, 0) * o.RightLeg
		end

		if bob ~= 0 and not air then
			local b = CFrame.new(0, bob, 0)
			for _, l in ipairs(LIMB_NAMES) do o[l] = b * o[l] end
		end
		return o
	end

	-- ---------- procedural dances (used by "Procedural Dance" moveset) ----------
	X.procDance = function(t, idx)
		local o = {}
		local u = X.standUnit()
		local s = m.DanceStrength or 1
		local armJ = Vector3.new(0, 0.9 * u, 0)
		local legJ = Vector3.new(0, 0.95 * u, 0)
		local function arm(side, pitch, roll)
			return X.pivotExtra(CFrame.Angles(pitch, 0, 0) * CFrame.Angles(0, 0, roll * side), armJ)
		end
		local function armAbs(pitch, rollAbs)
			return X.pivotExtra(CFrame.Angles(pitch, 0, 0) * CFrame.Angles(0, 0, rollAbs), armJ)
		end
		local function leg(side, pitch, roll, lift)
			local R = CFrame.Angles(pitch, 0, 0) * CFrame.Angles(0, 0, roll * side)
			return CFrame.new(0, lift or 0, 0) * X.pivotExtra(R, legJ)
		end
		local function body(pitch, yaw, roll, y, x)
			return CFrame.new((x or 0) * u, (y or 0) * u, 0) * CFrame.Angles(pitch, yaw, roll)
		end
		if idx == 2 then -- floss
			local a = math.sin(t * 8) * s
			o.LeftArm = armAbs(math.rad(45), a * math.rad(55))
			o.RightArm = armAbs(math.rad(45), a * math.rad(55))
			o.Torso = body(0, 0, 0, math.abs(a) * 0.05, -a * 0.25)
			o.Head = body(0, a * 0.2, 0)
			o.LeftLeg = leg(-1, 0, math.rad(6), 0)
			o.RightLeg = leg(1, 0, math.rad(6), 0)
		elseif idx == 3 then -- robot
			local stepA = (math.floor(t * 2.5) % 2 == 0)
			local hy = ({ 0, 1, 0, -1 })[(math.floor(t * 1.25) % 4) + 1] * math.rad(35) * s
			o.LeftArm = arm(-1, stepA and math.rad(85) or 0, math.rad(10))
			o.RightArm = arm(1, stepA and 0 or math.rad(85), math.rad(10))
			o.Torso = body(0, stepA and math.rad(12) or -math.rad(12), 0)
			o.Head = body(0, hy, 0)
			o.LeftLeg = leg(-1, stepA and math.rad(15) or 0, 0, 0)
			o.RightLeg = leg(1, stepA and 0 or math.rad(15), 0, 0)
		elseif idx == 4 then -- disco
			local sgn = math.sin(t * 3) > 0 and 1 or -1
			local hip = math.sin(t * 6) * 0.2
			o.RightArm = sgn > 0 and arm(1, math.rad(150), math.rad(20)) or arm(1, 0, math.rad(25))
			o.LeftArm = sgn > 0 and arm(-1, 0, math.rad(25)) or arm(-1, math.rad(150), math.rad(20))
			o.Torso = body(0, 0, hip * 0.5 * s, 0, hip)
			o.Head = body(0, 0, -hip * 0.4)
			o.LeftLeg = leg(-1, 0, math.rad(8), math.max(0, -hip) * 0.3)
			o.RightLeg = leg(1, 0, math.rad(8), math.max(0, hip) * 0.3)
		elseif idx == 5 then -- hype
			local p = math.sin(t * 10) * s
			o.LeftArm = arm(-1, math.rad(150) + p * math.rad(30), math.rad(15))
			o.RightArm = arm(1, math.rad(150) - p * math.rad(30), math.rad(15))
			o.Torso = body(0, 0, 0, math.abs(math.sin(t * 5)) * 0.3 * s)
			o.Head = body(-math.rad(10), 0, 0, math.abs(math.sin(t * 5)) * 0.3 * s)
			o.LeftLeg = leg(-1, 0, math.rad(6), math.max(0, p) * 0.25)
			o.RightLeg = leg(1, 0, math.rad(6), math.max(0, -p) * 0.25)
		elseif idx == 6 then -- wave
			o.RightArm = armAbs(0, math.rad(150) + math.sin(t * 9) * math.rad(25) * s)
			o.LeftArm = arm(-1, math.sin(t * 2) * math.rad(10), math.rad(8))
			o.Torso = body(0, 0, math.sin(t * 2) * 0.04)
			o.Head = body(0, 0, math.sin(t * 2) * 0.12)
			o.LeftLeg = leg(-1, 0, math.rad(4), 0)
			o.RightLeg = leg(1, 0, math.rad(4), 0)
		else -- sway
			local sw = math.sin(t * 2.4) * s
			o.Torso = body(0, 0, sw * 0.12, 0, sw * 0.15)
			o.Head = body(0, sw * 0.2, -sw * 0.08)
			o.LeftArm = arm(-1, sw * 0.4, math.rad(20) + sw * 0.3)
			o.RightArm = arm(1, -sw * 0.4, math.rad(20) + sw * 0.3)
			o.LeftLeg = leg(-1, 0, math.rad(6), 0)
			o.RightLeg = leg(1, 0, math.rad(6), 0)
		end
		return o
	end

	-- ---------- pick the pose source for this frame ----------
	X.targetExtras = function(dt)
		local ods = X.OwnDance and X.OwnDance.Stand
		if ods then
			local sample = X.ownDanceSample(ods, dt)
			if ods.Finished then
				X.stopOwnDance("Stand")
			elseif sample then
				return sample, true, m.OwnDanceBlend or 30
			end
		end
		if AnimState ~= "idle" then
			local idle = X.idleOffsets()
			local c = X.combatOffsets(AnimState, AnimT)
			return {
				Head = idle.Head * c.Head, Torso = idle.Torso * c.Torso,
				LeftArm = c.LeftArm, RightArm = c.RightArm,
				LeftLeg = c.LeftLeg, RightLeg = c.RightLeg,
			}, false, 40
		end
		if X.modeAllowsPlace() and m.PlaceBuildAnim then
			return X.buildAnimOffsets(BuildAnimT, m.PlaceBuildAnimSpeed), false, 20
		end
		local mode = m.LinkRigs and 1 or (m.StandMoveset or 2)
		if mode == 1 then
			local s = X.sampleRig()
			if s then return s, true, m.LinkSmooth or 26 end
			if not X.LinkWarned then
				X.LinkWarned = true
				warn("[HatStand] Link: no animated source rig found — using JoJo stand moveset instead")
			end
			mode = 2
		end
		if mode == 4 then
			X.ProcT = X.ProcT + dt
			return X.procDance(X.ProcT, m.ProcDance or 1), true, 18
		end
		if LocoMode == "dance" then
			if m.DanceMirrorCharacter then
				local s = X.sampleRig()
				if s then return s, true, 30 end
			end
			return X.danceOffsets(DanceT, 1), false, 16
		end
		if m.WalkWithMe or m.JojoLoco then
			local lo = X.locoV2(dt, mode == 3)
			if lo then return lo, true, m.LocoBlend or 14 end
		end
		if mode == 3 then
			local old = m.IdleStyle
			m.IdleStyle = 3
			local o = X.idleOffsets()
			m.IdleStyle = old
			return o, false, 24
		end
		return X.idleOffsets(), false, 24
	end

	X.applyBlend = function(dt, extras, isRoot, rate)
		local a = (rate and rate > 0) and (1 - math.exp(-rate * dt)) or 1
		local res = {}
		for _, limb in ipairs(LIMB_NAMES) do
			local tgt = extras and extras[limb] or CFrame.new()
			if not isRoot then tgt = X.legacyToRoot(X.makeBaseOffset(limb), tgt) end
			local cur = X.Blend[limb] or CFrame.new()
			local nxt = cur:Lerp(tgt, a)
			local p = nxt.Position
			if p.X ~= p.X or p.Y ~= p.Y or p.Z ~= p.Z then nxt = tgt end
			X.Blend[limb] = nxt
			res[limb] = nxt
		end
		return res
	end

	X.resolve = function(dt)
		X.autoCalib(dt)
		local ex, isRoot, rate = X.targetExtras(dt)
		if m.PoseFix and m.PoseSnapAfterDance then
			if X.LastLoco == "dance" and LocoMode ~= "dance" then X.SnapT = 0.45 end
			X.LastLoco = LocoMode
			if X.SnapT > 0 then
				X.SnapT = X.SnapT - dt
				rate = math.max(rate or 0, 34)
			end
		end
		return X.applyBlend(dt, ex, isRoot, rate)
	end

	-- ---------- dance list (best effort: Uhhhhhh tables, Uhhhhhh UI, then built-in) ----------
	X.scanDances = function()
		local names, seen = {}, {}
		local source = "none"
		local function add(n)
			n = X.trim(n)
			if n == "" or #n > 42 then return end
			local l = string.lower(n)
			if seen[l] then return end
			seen[l] = true
			table.insert(names, n)
		end
		pcall(function()
			local U = _G.Uhhhhhh
			if type(U) ~= "table" then return end
			local function walk(t, depth)
				if depth > 3 or type(t) ~= "table" then return end
				for k, v in pairs(t) do
					local ks = string.lower(tostring(k))
					if type(v) == "table" and (string.find(ks, "dance", 1, true) or string.find(ks, "emote", 1, true)) then
						for k2, v2 in pairs(v) do
							if type(k2) == "string" then add(k2)
							elseif type(v2) == "string" then add(v2)
							elseif type(v2) == "table" and type(v2.Name) == "string" then add(v2.Name) end
						end
					elseif type(v) == "table" then
						walk(v, depth + 1)
					end
				end
			end
			walk(U, 0)
		end)
		if #names > 0 then source = "Uhhhhhh data" end
		if #names == 0 then
			pcall(function()
				for _, lbl in ipairs(CoreGui:GetDescendants()) do
					if (lbl:IsA("TextLabel") or lbl:IsA("TextButton")) and string.find(string.lower(lbl.Text or ""), "dance", 1, true)
						and #(lbl.Text or "") < 30 then
						local anc = lbl.Parent
						for _ = 1, 4 do
							if not anc then break end
							local btns = {}
							for _, d in ipairs(anc:GetDescendants()) do
								if d:IsA("TextButton") and d ~= lbl and X.trim(d.Text) ~= "" then table.insert(btns, d) end
							end
							if #btns >= 3 and #btns <= 150 then
								for _, b in ipairs(btns) do add(b.Text) end
								break
							end
							anc = anc.Parent
						end
						if #names > 0 then break end
					end
				end
			end)
			if #names > 0 then source = "Uhhhhhh UI" end
		end
		table.sort(names)
		for i, n in ipairs(m.ProcDanceNames) do table.insert(names, "[Stand] " .. string.gsub(n, "^%d+ ", "")) end
		if source == "none" then source = "built-in only (Uhhhhhh dances not found)" end
		X.DanceSource = source
		return names
	end

	X.clickLabel = function(name)
		local lower = string.lower(X.trim(name))
		local best, bestScore = nil, 0
		pcall(function()
			for _, d in ipairs(CoreGui:GetDescendants()) do
				if d:IsA("TextButton") or d:IsA("TextLabel") then
					local t = string.lower(X.trim(d.Text or ""))
					if t ~= "" then
						local sc = 0
						if t == lower then sc = d:IsA("TextButton") and 4 or 3
						elseif string.find(t, lower, 1, true) then sc = d:IsA("TextButton") and 2 or 1 end
						if sc > bestScore then best, bestScore = d, sc end
					end
				end
			end
		end)
		if not best then return false end
		local fired = false
		local function fire(inst)
			pcall(function()
				if not getconnections then return end
				for _, sig in ipairs({ "Activated", "MouseButton1Click", "MouseButton1Down" }) do
					local ev = inst[sig]
					if typeof(ev) == "RBXScriptSignal" then
						for _, cn in ipairs(getconnections(ev)) do
							pcall(function() if cn.Function then cn.Function() fired = true end end)
						end
					end
				end
			end)
		end
		fire(best)
		if not fired and best.Parent then fire(best.Parent) end
		return fired
	end

	X.playDance = function(name)
		name = X.trim(name)
		if name == "" then return false end
		m.SelectedDance = name
		local proc = string.match(name, "^%[Stand%] (.+)$")
		if proc then
			for i, n in ipairs(m.ProcDanceNames) do
				if string.gsub(n, "^%d+ ", "") == proc then m.ProcDance = i break end
			end
			m.StandMoveset = 4
			m.LinkRigs = false
			return true
		end
		local ok = X.clickLabel(name)
		if not ok then warn("[HatStand] could not trigger dance '" .. name .. "' from the Uhhhhhh UI — start it from Uhhhhhh itself; the stand will still copy it") end
		return ok
	end

	-- ---------- CLONE (second body from spare hats; same moveset + dances) ----------
	X.CloneKeys = {
		Head = "CloneHatHead", Torso = "CloneHatTorso",
		LeftArm = "CloneHatLeftArm", RightArm = "CloneHatRightArm",
		LeftLeg = "CloneHatLeftLeg", RightLeg = "CloneHatRightLeg",
	}

	X.clearClone = function()
		local keep = {}
		for handle, held in pairs(Held) do
			if held.Kind and held.Kind ~= "clone" then keep[handle] = true end
		end
		X.releaseHeld(keep)
		X.CloneLimbs = {}
		X.CloneSlots = {}
		X.CloneBlend = nil
		X.CloneCF = nil
		if X.CloneModel then pcall(function() X.CloneModel:Destroy() end) X.CloneModel = nil end
	end

	X.buildClone = function()
		if not (m.Enabled and m.CloneEnabled) then return false end
		if m.SelectFirst and not X.Applied then return false end
		X.CloneLastBuild = os.clock()
		X.refreshAllHats()
		local followRoot = X.getFollowRoot()
		if not followRoot then return false end
		if m.FEMode then X.boostNetwork() end
		if not X.CloneModel or not X.CloneModel.Parent then
			local model = Instance.new("Model")
			model.Name = ("UhhhhhhHatStandClone" .. SUF)
			model.Parent = workspace
			X.CloneModel = model
		end
		for _, ch in ipairs(X.CloneModel:GetChildren()) do pcall(function() ch:Destroy() end) end
		X.CloneCF = X.CloneCF or (followRoot.CFrame * CFrame.new(m.CloneSide, m.CloneHeight, m.CloneForward))

		local claimed, assignment = {}, {}
		for handle, held in pairs(Held) do
			if held.Kind and held.Kind ~= "clone" then claimed[handle] = true end
		end
		for _, limb in ipairs(LIMB_NAMES) do
			local hat = X.findHatForLimb(limb, claimed, "clone", X.CloneKeys)
			if hat then claimed[hat.Handle] = true assignment[limb] = hat end
		end
		local slotHats = {}
		for i = 1, 15 do
			local label = X.trim(m["CloneSlotHat" .. i] or "")
			if label ~= "" then
				local sh = X.findHatFromLabel(label, claimed)
				if sh and sh.Handle and not claimed[sh.Handle] then
					claimed[sh.Handle] = true
					slotHats[i] = sh
				end
			end
		end
		if m.CloneAutoHats and not m.SelectFirst then
			for _, limb in ipairs(LIMB_NAMES) do
				if not assignment[limb] and not (m.StrictHats and X.trim(m[X.CloneKeys[limb]]) ~= "") then
					local hat = X.nextSpare(claimed, "clone")
					if hat then claimed[hat.Handle] = true assignment[limb] = hat end
				end
			end
		end
		local keep = {}
		for handle, held in pairs(Held) do
			if held.Kind ~= "clone" then keep[handle] = true end
		end
		X.CloneLimbs = {}
		local n = 0
		for _, limb in ipairs(LIMB_NAMES) do
			local hat = assignment[limb]
			if hat then
				local part, held = nil, nil
				if m.FEMode then
					held = X.attachFE(hat, "clone")
					if held then keep[hat.Handle] = true part = hat.Handle end
				else
					part = X.cloneHandle(hat.Handle, "Clone_" .. limb)
					if part then part.CFrame = X.CloneCF * X.makeBaseOffset(limb) part.Parent = X.CloneModel end
				end
				if part then X.CloneLimbs[limb] = { Part = part, Held = held, Name = hat.Name } n = n + 1 end
			end
		end
		X.CloneSlots = {}
		for i = 1, 15 do
			local hat = slotHats[i]
			if hat then
				local part, held = nil, nil
				if m.FEMode then
					held = X.attachFE(hat, "clone")
					if held then keep[hat.Handle] = true part = hat.Handle end
				else
					part = X.cloneHandle(hat.Handle, "CloneSlot_" .. i)
					if part then part.Parent = X.CloneModel end
				end
				if part then X.CloneSlots[i] = { Part = part, Held = held, Name = hat.Name } n = n + 1 end
			end
		end
		X.releaseHeld(keep)
		if n ~= X.CloneCount then
			X.CloneCount = n
			warn("[HatStand] clone limbs=" .. tostring(n))
		end
		return n > 0
	end

	X.stepClone = function(dt)
		if not (m.Enabled and m.CloneEnabled) then return end
		if m.SelectFirst and not X.Applied then return end
		local followRoot = X.getFollowRoot()
		if not followRoot then return end
		local now = os.clock()
		local standReady = (not X.modeAllowsStand()) or next(Limbs) ~= nil or not m.AutoBuild
		local total, missing = 0, 0
		for _, d in pairs(X.CloneLimbs) do
			total = total + 1
			if not d.Part or not d.Part.Parent then missing = missing + 1 end
		end
		if (total == 0 or missing > 0 or X.NeedCloneRebuild) and standReady and (now - X.CloneLastBuild) > 0.75 then
			X.NeedCloneRebuild = false
			for handle in pairs(Held) do
				if not handle.Parent then Held[handle] = nil end
			end
			pcall(X.buildClone)
		end
		if next(X.CloneLimbs) == nil then return end

		local base = followRoot.CFrame
		local cf = base * CFrame.new(m.CloneSide or -3.5, m.CloneHeight or 0, m.CloneForward or 0.5)
		local desired = m.CloneFaceSame and cf or CFrame.lookAt(cf.Position, base.Position)
		X.CloneCF = X.CloneCF or desired
		local dist = (X.CloneCF.Position - desired.Position).Magnitude
		local alpha = (dist > (m.AutoCorrectDist or 25)) and 1 or (1 - math.exp(-(m.CloneSmooth or 22) * dt))
		X.CloneCF = X.CloneCF:Lerp(desired, alpha)

		if X.ExtrasFrame ~= X.Frame then
			X.updateLocoMode(dt)
			X.updateAir(dt)
			IdleT = IdleT + dt
			if AnimState ~= "idle" then AnimT = AnimT + dt end
			X.Extras = X.resolve(dt)
			X.ExtrasFrame = X.Frame
		end
		local extras = X.Extras or {}
		local odc = X.OwnDance and X.OwnDance.Clone
		if odc then
			local ex = X.ownDanceSample(odc, dt)
			if odc.Finished then
				X.stopOwnDance("Clone")
			elseif ex then
				local blend = X.CloneBlend or {}
				X.CloneBlend = blend
				local a = 1 - math.exp(-(m.OwnDanceBlend or 30) * dt)
				for _, limb in ipairs(LIMB_NAMES) do
					local tgt = ex[limb] or CFrame.new()
					local cur = blend[limb] or tgt
					blend[limb] = cur:Lerp(tgt, a)
				end
				extras = blend
			end
		end
		local crKeys = X.CloneCRKeys
		if not crKeys then
			crKeys = {}
			for _, limb in ipairs(LIMB_NAMES) do
				crKeys[limb] = {
					"CloneRot" .. limb .. "X", "CloneRot" .. limb .. "Y", "CloneRot" .. limb .. "Z",
					"CloneOff" .. limb .. "X", "CloneOff" .. limb .. "Y", "CloneOff" .. limb .. "Z",
				}
			end
			X.CloneCRKeys = crKeys
		end
		for limb, d in pairs(X.CloneLimbs) do
			if d.Part and d.Part.Parent then
				-- clone can use its own per-limb rot/offset when set
				local base = X.makeBaseOffset(limb)
				local ck = crKeys[limb]
				if ck then
					local ox = tonumber(m[ck[4]]) or 0
					local oy = tonumber(m[ck[5]]) or 0
					local oz = tonumber(m[ck[6]]) or 0
					local rx = math.rad(tonumber(m[ck[1]]) or 0)
					local ry = math.rad(tonumber(m[ck[2]]) or 0)
					local rz = math.rad(tonumber(m[ck[3]]) or 0)
					if ox ~= 0 or oy ~= 0 or oz ~= 0 or rx ~= 0 or ry ~= 0 or rz ~= 0 then
						base = CFrame.new(base.Position + Vector3.new(ox, oy, oz)) * CFrame.Angles(rx, ry, rz) * (base - base.Position)
					end
				end
				local cl = X.CloneCF * X.applyRootExtra(base, extras[limb] or CFrame.new())
				d.LastCF = cl
				if d.Held then X.driveHandle(d.Held, cl) else pcall(function() d.Part.CFrame = cl end) end
			end
		end
		-- clone slots (extra hats): 1 Float, 2 Weapon, 3 Effect, 4 Hand
		local slots = X.CloneSlots
		if slots and next(slots) then
			local clock = os.clock()
			for i, sl in pairs(slots) do
				if sl.Part and sl.Part.Parent then
					local kind = m["CloneSlotKind" .. i] or 1
					local off = CFrame.new(m["CloneSlotOffX" .. i] or 0, m["CloneSlotOffY" .. i] or 0, m["CloneSlotOffZ" .. i] or 0)
					local rot = CFrame.Angles(math.rad(m["CloneSlotRotX" .. i] or 0), math.rad(m["CloneSlotRotY" .. i] or 0), math.rad(m["CloneSlotRotZ" .. i] or 0))
					local ref = X.CloneCF
					local extra = CFrame.new()
					if kind == 4 then
						local ra = X.CloneLimbs.RightArm
						if ra and ra.LastCF then ref = ra.LastCF end
					elseif kind == 1 then
						extra = CFrame.new(0, math.sin(clock * 2 + i) * 0.15, 0)
					elseif kind == 3 then
						extra = CFrame.Angles(0, clock * 3, 0)
					end
					local cf = ref * extra * off * rot
					if sl.Held then X.driveHandle(sl.Held, cf) else pcall(function() sl.Part.CFrame = cf end) end
				end
			end
		end
	end

	function X.locoAnimOffsets()
		if LocoMode == "dance" then
			-- Prefer real character limb poses when available (perfect dance mirror)
			local mirrored = X.sampleCharacterLimbOffsets()
			if mirrored then return mirrored end
			return X.danceOffsets(DanceT, 1)
		end
		if m.WalkWithMe then
			if LocoMode == "jump" then return X.jojoJumpOffsets(m.JumpStrength)
			elseif LocoMode == "run" then return X.jojoRunOffsets(LocoT * m.RunCycleSpeed, m.RunStrength)
			elseif LocoMode == "walk" then return X.jojoWalkOffsets(LocoT * m.WalkCycleSpeed, m.WalkStrength)
			end
		end
		return nil
	end

	X.animOffsets = function(state, t)
		if state ~= "idle" then
			local idle = X.idleOffsets()
			local c = X.combatOffsets(state, t)
			return {
				Head = idle.Head * c.Head, Torso = idle.Torso * c.Torso,
				LeftArm = c.LeftArm, RightArm = c.RightArm,
				LeftLeg = c.LeftLeg, RightLeg = c.RightLeg,
			}
		end
		if X.modeAllowsPlace() and m.PlaceBuildAnim then
			return X.buildAnimOffsets(BuildAnimT, m.PlaceBuildAnimSpeed)
		end
		local loco = X.locoAnimOffsets()
		if loco then return loco end
		return X.idleOffsets()
	end

	X.playAnim = function(name, duration)
		AnimState, AnimT = name, 0
		AnimToken = AnimToken + 1
		local mine = AnimToken
		task.delay(duration or 0.45, function()
			if AnimToken == mine then AnimState, AnimT = "idle", 0 end
		end)
	end

	--------------------------------------------------------------
	-- PLACE / BTOOLS — REAL HAT + YEET / PICKUP
	--------------------------------------------------------------
	X.clearPlacePreview = function()
		if PlacePreviewPart then
			pcall(function() PlacePreviewPart:Destroy() end)
			PlacePreviewPart = nil
		end
	end

	local clearClaws, rebuildClaws, stepClaws, fireClawsCombo, fireClawsPush, fireClawsSpin
	clearClaws, rebuildClaws, stepClaws, fireClawsCombo, fireClawsPush, fireClawsSpin =
		function() end, function() end, function() end, function() end, function() end, function() end
	function X.desiredStandCF(followRoot, dt)
		local base = followRoot.CFrame
		if m.WalkWithMe then
			local cf = base * CFrame.new(m.WalkSideOffset or 2.8, m.WalkHeightOffset or 0, m.WalkForwardOffset or 0.5)
			if m.FaceSameWay then return cf end
			return CFrame.lookAt(cf.Position, base.Position)
		end
		local method = m.MethodIndex
		if method == 5 then
			return StandRoot and StandRoot.CFrame or base * CFrame.new(m.SideOffset, m.HeightOffset, m.ForwardOffset)
		end
		if method == 3 or m.OrbitStand then
			OrbitAngle = OrbitAngle + m.OrbitSpeed * dt
			local pos = base.Position + Vector3.new(
				math.cos(OrbitAngle) * m.OrbitRadius, m.HeightOffset, math.sin(OrbitAngle) * m.OrbitRadius
			)
			if m.FaceSameWay then return CFrame.new(pos) * (base - base.Position) end
			return CFrame.lookAt(pos, base.Position)
		end
		if method == 2 then
			local cf = base * CFrame.new(0, m.HeightOffset, -(math.abs(m.SideOffset) + 2))
			if m.FaceSameWay then return cf end
			return CFrame.lookAt(cf.Position, base.Position)
		end
		if method == 4 then
			local cf = base * CFrame.new(-m.SideOffset, m.HeightOffset, m.ForwardOffset)
			if m.FaceSameWay then
				return CFrame.new(cf.Position) * CFrame.Angles(0, math.pi, 0) * (base - base.Position)
			end
			return cf
		end
		local cf = base * CFrame.new(m.SideOffset, m.HeightOffset, m.ForwardOffset)
		if m.FaceSameWay then return cf end
		return CFrame.lookAt(cf.Position, base.Position)
	end

	X.applyStandCF = function(rootCF, dt)
		if not StandRoot then return end
		StandRoot.CFrame = rootCF
		local extras = X.resolve(dt or 1 / 60)
		X.Extras = extras
		X.ExtrasFrame = X.Frame
		for limb, data in pairs(Limbs) do
			local part = data.Part
			if part and part.Parent then
				data.BaseOffset = X.makeBaseOffset(limb)
				local cf = rootCF * X.applyRootExtra(data.BaseOffset, extras[limb] or CFrame.new())
				if data.Held then X.driveHandle(data.Held, cf)
				else pcall(function() part.CFrame = cf end) end
			end
		end
		-- Keep limb-layout preview markers locked to current offsets
		if m.ShowLimbPreview then
			for limb, p in pairs(LimbPreviewParts) do
				if p and p.Parent then
					pcall(function() p.CFrame = rootCF * X.makeBaseOffset(limb) end)
				end
			end
		end
	end

	function X.stepStand(dt)
		if not X.modeAllowsStand() or not m.Enabled then return end
		X.updateLocoMode(dt)
		X.updateAir(dt)
		local now = os.clock()
		local canRebuild = (now - LastBuild) > 0.5
		if NeedRebuild and canRebuild then
			NeedRebuild = false
			if m.AutoBuild then pcall(X.buildStand) end
		end
		if not StandRoot or not StandModel or not StandModel.Parent then
			if m.AutoBuild and canRebuild then pcall(X.buildStand) end
			if not StandRoot then return end
		end
		local missing, total = 0, 0
		for _, data in pairs(Limbs) do
			total = total + 1
			if not data.Part or not data.Part.Parent then missing = missing + 1 end
		end
		if total > 0 and missing > 0 then
			for handle in pairs(Held) do
				if not handle.Parent then Held[handle] = nil end
			end
			NeedRebuild = true
			if missing == total then return end
		end
		local followRoot = X.getFollowRoot()
		if not followRoot then return end
		IdleT = IdleT + dt
		if AnimState ~= "idle" then AnimT = AnimT + dt end
		if m.MethodIndex == 5 and not m.WalkWithMe then
			X.applyStandCF(StandRoot.CFrame, dt)
			return
		end
		local desired = X.desiredStandCF(followRoot, dt)
		local dist = (StandRoot.Position - desired.Position).Magnitude
		local smooth = m.WalkWithMe and (m.WalkSmoothness or 18) or m.Smoothness
		if m.AutoCorrect and dist > (m.AutoCorrectDist or 25) then
			X.applyStandCF(desired, dt)
			return
		end
		local alpha = (dist > 20) and 1 or (1 - math.exp(-smooth * dt))
		X.applyStandCF(StandRoot.CFrame:Lerp(desired, alpha), dt)
	end

	--------------------------------------------------------------
	-- INPUT
	--------------------------------------------------------------
	function X.bindKeys()
		for _, c in ipairs(KeyConns) do pcall(function() c:Disconnect() end) end
		KeyConns = {}
		local lastPlace = 0
		local function tryPlaceClick(overGui, legacy)
			if not m.Enabled or not X.modeAllowsPlace() then return end
			local structure = m.BToolsClickBuild and (m.BToolsMode or 1) ~= 1
			-- whole-structure builds only from the real input event (so clicking GUI buttons never builds)
			if structure and (overGui or legacy) then return end
			local now = os.clock()
			if now - lastPlace < 0.15 then return end
			lastPlace = now
			if structure then X.buildStructure(true) return end
			local cf = X.getMouseWorldCF()
			if cf then X.placeHatAt(cf) end
		end
		table.insert(KeyConns, UserInputService.InputBegan:Connect(function(input, gp)
			if not m.Enabled then return end
			if input.UserInputType == Enum.UserInputType.MouseButton1 and X.modeAllowsPlace() then
				tryPlaceClick(gp, false)
			end
			if UserInputService:GetFocusedTextBox() then return end
			if m.Keybinds then
				if X.modeAllowsStand() then
					local kcName = input.KeyCode.Name
					local clawsBusy = m.ClawsEnabled and m.ClawsKeysEnabled and (
						kcName == tostring(m.KeyClawsCombo) or kcName == tostring(m.KeyClawsPush) or kcName == tostring(m.KeyClawsSpin)
						or kcName == tostring(m.KeyClawsLaser) or kcName == tostring(m.KeyClawsSlam)
					)
					if not clawsBusy then
						if input.KeyCode == Enum.KeyCode.Z then X.playAnim("punch", 0.42)
						elseif input.KeyCode == Enum.KeyCode.X then X.playAnim("punch2", 0.42)
						elseif input.KeyCode == Enum.KeyCode.C then X.playAnim("uppercut", 0.5)
						end
					end
					if input.KeyCode == Enum.KeyCode.V then X.playAnim("kick", 0.48)
					elseif input.KeyCode == Enum.KeyCode.F then X.playAnim("block", 0.7)
					elseif input.KeyCode == Enum.KeyCode.G then X.playAnim("wave", 0.9)
					elseif input.KeyCode == Enum.KeyCode.H and m.DanceKey then
						ForceDance = true
						ForceDanceUntil = os.clock() + 4
						DanceT = 0
					end
				end
				if X.modeAllowsPlace() then
					if input.KeyCode == Enum.KeyCode.Y then
						X.buildStructure(true)
					elseif input.KeyCode == Enum.KeyCode.R then
						m.PlaceActiveSlot = (m.PlaceActiveSlot % 10) + 1
						X.clearPlacePreview()
						warn("[HatStand] place slot -> " .. m.PlaceActiveSlot)
					elseif input.KeyCode == Enum.KeyCode.E then
						X.yeetNearestPlaced()
					elseif input.KeyCode == Enum.KeyCode.T then
						X.placeBackNearest()
					elseif input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
						X.removeNearest()
					end
				end
			end
			do
				local function keyIs(field)
					local want = tostring(m[field])
					if want == "MouseButton2" or want == "MouseButton3" then
						return input.UserInputType.Name == want
					end
					return input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode.Name == want
				end
				-- Gaster fire / cycle slot
				if m.GasterEnabled and keyIs("KeyGaster") then
					X.fireGaster()
				end
				if m.GasterEnabled and keyIs("KeyGasterCycle") then
					m.GasterActiveSlot = (m.GasterActiveSlot % 5) + 1
					warn("[HatStand] Gaster active slot -> " .. m.GasterActiveSlot)
				end
				-- Bone attack
				if m.BoneEnabled and keyIs("KeyBone") then
					X.fireBone()
				end
				-- Ravenger Claws
				if m.ClawsEnabled and keyIs("KeyClawsKeysToggle") then
					m.ClawsKeysEnabled = not m.ClawsKeysEnabled
					warn("[HatStand] Claws attack keys " .. (m.ClawsKeysEnabled and "ON" or "OFF"))
				end
				if m.ClawsEnabled and keyIs("KeyClawsTrackToggle") then
					m.ClawsTrackMouse = not m.ClawsTrackMouse
					warn("[HatStand] Claws mouse tracking " .. (m.ClawsTrackMouse and "ON" or "OFF"))
				end
				if m.ClawsEnabled and keyIs("KeyClawsRage") then
					m.ClawsRage = not m.ClawsRage
					warn("[HatStand] Claws RAGE " .. (m.ClawsRage and "ON" or "OFF"))
				end
				if m.ClawsEnabled and m.ClawsKeysEnabled then
					if keyIs("KeyClawsLaser") then X.fireClawsLaser() end
					if keyIs("KeyClawsSlam") then X.fireClawsSlam() end
					if keyIs("KeyClawsCombo") then fireClawsCombo() end
					if keyIs("KeyClawsPush") then fireClawsPush() end
					if keyIs("KeyClawsSpin") then fireClawsSpin() end
				end
				-- Omega Blaster
				if m.OmegaEnabled and keyIs("KeyOmega") then
					X.fireOmega()
				end
				-- Sans: fire every enabled Sans attack
				if keyIs("KeySans") then
					if m.GasterEnabled then pcall(X.fireGaster) end
					if m.BoneEnabled then pcall(X.fireBone) end
					if m.OmegaEnabled then pcall(X.fireOmega) end
				end
				-- Sans: sink / raise every Sans attack
				if keyIs("KeySansToggle") then
					X.setSansUnderground(not m.SansUnderground)
				end
				if m.OmegaEnabled and keyIs("KeyOmegaCycle") then
					m.OmegaActiveSlot = (m.OmegaActiveSlot % 5) + 1
					warn("[HatStand] Omega active slot -> " .. m.OmegaActiveSlot)
				end
				-- Shield raise / lower (underground stash)
				if keyIs("KeyShield") then
					X.toggleShieldStash()
				end
				-- Weapon fire
				if m.WeaponEnabled and input.KeyCode == Enum.KeyCode.B then
					X.BHeld = true
					X.fireWeapon()
				end
				if m.WeaponEnabled and input.KeyCode == Enum.KeyCode.N then
					X.cycleWeapon()
				end
				-- Ball yeet
				if m.BallEnabled and keyIs("BallKey") then
					X.yeetBall(m.BallActiveSlot or 1)
				end
				-- Motorcycle ride toggle
				if m.MotoEnabled and keyIs("KeyMotoRide") then
					X.toggleMotoRide()
				end
				-- Plane ride / fly
				if m.PlaneEnabled and keyIs("KeyPlaneRide") then
					X.togglePlaneRide()
				end
				if m.PlaneEnabled and keyIs("KeyPlaneFly") then
					X.togglePlaneFly()
				end
				-- Hellcopter
				if keyIs("KeyHeliRide") then
					if not m.HeliEnabled then
						m.HeliEnabled = true
						pcall(function() X.rebuildHeli() end)
					end
					X.toggleHeliRide()
				end
				if m.TitanEnabled and keyIs("KeyTitanFly") then X.toggleTitanFly() end
				if m.TitanEnabled and keyIs("KeyTitanCoreFire") then X.titanCoreFire() end
				if m.HeliEnabled and keyIs("KeyHeliEngine") then X.toggleHeliEngine() end
				if m.HeliEnabled and keyIs("KeyHeliOff") then X.toggleHeliFly() end
				if m.HeliEnabled and keyIs("KeyHeliMouse") then X.toggleHeliMouse() end
				if m.HeliEnabled and keyIs("KeyHeliLauncher") then
					m.HeliMissileEnabled = not (m.HeliMissileEnabled ~= false)
					if not m.HeliMissileEnabled then X.msClearLock() end
					warn("[HatStand] missile launcher " .. (m.HeliMissileEnabled and "ON" or "OFF"))
				end
				if m.HeliEnabled and m.HeliRide and keyIs("KeyHeliMissile") then X.fireHeliMissile() end
				if m.HeliEnabled and m.HeliRide and keyIs("KeyHeliFire") then X.fireHeli(true) end
				-- Plane ordnance attacks (only while riding)
				if m.PlaneEnabled and m.PlaneRide then
					if m.PlaneBombEnabled and keyIs("PlaneBombKey") then X.firePlaneBomb() end
					if m.PlanePackageEnabled and keyIs("PlanePackageKey") then X.firePlanePackage() end
					if m.PlaneMissileEnabled and keyIs("PlaneMissileKey") then X.firePlaneMissile() end
					if m.PlaneMissileEnabled and keyIs("PlaneMissileCycleKey") then
						local cur = math.clamp(math.floor(m.PlaneMissileActiveSlot or 1), 1, 5)
						m.PlaneMissileActiveSlot = (cur % 5) + 1
						if X.PlaneMissileAmmoSlots then
							X.PlaneMissileAmmo = X.PlaneMissileAmmoSlots[m.PlaneMissileActiveSlot] or X.PlaneMissileAmmo
						end
					end
					if m.PlaneBomb2Enabled and keyIs("PlaneBomb2Key") then X.firePlaneBomb2() end
				end
				-- Car ride / enter (GTA style)
				if m.CarEnabled and keyIs("KeyCarRide") then
					m.CarRide = not m.CarRide
					if m.CarRide and m.CarEnterAnim then CarEnterT = m.CarEnterTime or 1.1 end
					warn("[HatStand] car ride=" .. tostring(m.CarRide))
				end
				-- Hat tool swing / cycle
				if m.ToolEnabled and keyIs("KeyToolSwing") then
					X.swingTool()
				end
				if m.ToolEnabled and keyIs("KeyToolCycle") then
					m.ToolActiveSlot = (m.ToolActiveSlot % 6) + 1
					warn("[HatStand] tool slot -> " .. m.ToolActiveSlot)
				end
				-- Shield place
				if m.ShieldEnabled and keyIs("KeyShieldPlace") then
					X.placeShieldAtMouse()
				end
			end
		end))
		table.insert(KeyConns, UserInputService.InputEnded:Connect(function(input)
			if input.KeyCode == Enum.KeyCode.B then X.BHeld = false end
		end))
		pcall(function()
			table.insert(KeyConns, Mouse.Button1Down:Connect(function()
				if X.modeAllowsPlace() then tryPlaceClick(false, true) end
				if m.PlaneEnabled and m.PlaneRide and m.PlaneGunEnabled then X.firePlaneGuns() end
				if m.HeliEnabled and m.HeliRide then
					X.HeliFireHeld = true
					X.fireHeli(true)
				end
			end))
			table.insert(KeyConns, Mouse.Button1Up:Connect(function()
				X.HeliFireHeld = false
			end))
		end)
	end

	function X.autoRefreshHatsIfChanged()
		X.refreshAllHats(false)
		local after = X.hatFingerprint()
		if after ~= LastHatFingerprint then
			LastHatFingerprint = after
			NeedRebuild = true
			NeedOrbitRebuild = true
			if m.GasterEnabled then task.defer(X.rebuildGaster) end
			if m.BoneEnabled then task.defer(X.rebuildBone) end
			if m.OmegaEnabled then task.defer(X.rebuildOmega) end
			if m.WeaponEnabled then task.defer(X.rebuildWeapon) end
			if m.ShieldEnabled then task.defer(X.rebuildShield) end
			if m.ClawsEnabled then task.defer(rebuildClaws) end
			if m.CarEnabled then task.defer(X.rebuildCar) end
			if m.PlanetEnabled then task.defer(X.rebuildPlanet) end
			if m.MotoEnabled then task.defer(X.rebuildMoto) end
			if m.ToolEnabled then task.defer(X.rebuildTool) end
			if m.PlaneEnabled then task.defer(X.rebuildPlane) end
			if m.HeliEnabled and not m.HeliRide then task.defer(X.rebuildHeli) end
		end
	end

	function X.startHatAutoRefresh()
		RefreshToken = RefreshToken + 1
		local mine = RefreshToken
		task.spawn(function()
			while RefreshToken == mine do
				local waitTime = m.AutoRefresh and (m.AutoRefreshInterval or 1) or 1
				task.wait(waitTime)
				if RefreshToken ~= mine then break end
				if m.Enabled then
					if m.AutoRefresh then
						pcall(function() X.refreshAllHats(true) end)
						local fp = X.hatFingerprint()
						if fp ~= LastHatFingerprint then
							LastHatFingerprint = fp
							NeedRebuild = true
							NeedOrbitRebuild = true
						end
					else
						pcall(X.autoRefreshHatsIfChanged)
					end
				end
			end
		end)
	end

	function X.stopHatAutoRefresh()
		RefreshToken = RefreshToken + 1
	end

	function X.bindCharacter()
		for _, c in ipairs(CharConns) do pcall(function() c:Disconnect() end) end
		CharConns = {}
		table.insert(CharConns, LocalPlayer.CharacterAdded:Connect(function()
			task.delay(0.5, function()
				if m.Enabled then NeedRebuild = true NeedOrbitRebuild = true X.NeedCloneRebuild = true X.RestSet = false X.Blend = {} end
			end)
			task.delay(1.5, function()
				if m.Enabled then
					NeedRebuild = true
					NeedOrbitRebuild = true
					if m.GasterEnabled then X.rebuildGaster() end
					if m.BoneEnabled then X.rebuildBone() end
					if m.OmegaEnabled then X.rebuildOmega() end
					if m.WeaponEnabled then X.rebuildWeapon() end
					if m.ShieldEnabled then X.rebuildShield() end
					if m.ClawsEnabled then rebuildClaws() end
					if m.CarEnabled then X.rebuildCar() end
					if m.PlanetEnabled then X.rebuildPlanet() end
					if m.MotoEnabled then X.rebuildMoto() end
					if m.ToolEnabled then X.rebuildTool() end
					if m.PlaneEnabled then X.rebuildPlane() end
					if m.HeliEnabled then X.rebuildHeli() end
					NeedPlaneRebuild = true
					NeedMotoRebuild = true
					NeedPlanetRebuild = true
					NeedToolRebuild = true
					NeedCarRebuild = true
				end
			end)
		end))
		table.insert(CharConns, LocalPlayer.CharacterRemoving:Connect(function()
			pcall(X.freezePlacedForRespawn)
			Held = {}
			Limbs = {}
			OrbitSlots = {}
			GasterHeld = nil
			GasterSlots = {}
			BoneHeld = nil
			BoneProjectiles = {}
			OmegaHeld, OmegaHeld2 = nil, nil
			X.ClawsLeft, X.ClawsRight, X.ClawsHead = nil, nil, nil
			X.OmegaSlots = {}
			X.OmegaBullets = {}
			WeaponHeld = nil
			X.WeaponSlots = {}
			X.BulletHats = {}
			ShieldHeld = nil
			CarSlots = {}
			PlanetSlots = {}
			MotoSlots, MotoWheels, MotoEngine = {}, {}, nil
			ToolSlots = {}
			PlaneFrames, PlaneProps, PlaneEngines, PlaneGuns = {}, {}, {}, {}
			PlaneFull = nil
			X.CloneLimbs = {}
			X.NeedCloneRebuild = true
			if not m.PlacePersist then PlacedHats = {} end
			X.clearPlacePreview()
			NeedRebuild = true
			NeedOrbitRebuild = true
		end))
	end

	function X.scanWorkspaceMovesets()
		local found, seen = {}, {}
		local function add(n)
			if not n or n == "" then return end
			local l = string.lower(n)
			if l == "hat stand" or seen[l] then return end
			seen[l] = true
			table.insert(found, n)
		end
		if listfiles then
			for _, folder in ipairs({ "UhhhhhhReanim/Modules", "UhhhhhhReanim/BuiltinModules" }) do
				local ok, files = pcall(listfiles, folder)
				if ok and type(files) == "table" then
					for _, path in ipairs(files) do
						if type(path) == "string" and string.find(path, "%.lua") then
							local ok2, data = pcall(readfile, path)
							if ok2 and data and string.find(data, 'ModuleType%s*=%s*"MOVESET"') then
								add(string.match(data, 'm%.Name%s*=%s*"([^"]+)"') or path)
							end
						end
					end
				end
			end
		end
		if #found == 0 then
			for _, n in ipairs({ "Nothing", "Steve", "2007 Roblox", "Sans Undertale" }) do add(n) end
		end
		table.sort(found)
		return found
	end

	function X.findAndClickMoveset(name)
		name = X.trim(name)
		if name == "" then return false end
		local lower = string.lower(name)
		local labels = {}
		local function collect(root, depth)
			if depth > 16 or not root then return end
			for _, child in ipairs(root:GetChildren()) do
				if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("ImageButton") then
					local t = X.trim(child.Text or "")
					if t ~= "" then table.insert(labels, { text = t, inst = child }) end
				end
				collect(child, depth + 1)
			end
		end
		pcall(function() collect(CoreGui, 0) end)
		for _, entry in ipairs(labels) do
			local t = string.lower(X.trim(entry.text))
			if t == lower or string.find(t, lower, 1, true) then
				pcall(function()
					if getconnections then
						for _, sig in ipairs({ "Activated", "MouseButton1Click" }) do
							local ev = entry.inst[sig]
							if typeof(ev) == "RBXScriptSignal" then
								for _, c in ipairs(getconnections(ev)) do
									pcall(function() if c.Function then c.Function() end end)
								end
							end
						end
					end
				end)
				return true
			end
		end
		return false
	end

	-- ---------- anti-snap: stop Uhhhhhh dragging weapon / bullet hats back to the rig ----------
	X.lateApply = function(clean)
		if not (m.Enabled and m.WeaponAntiSnap) then return end
		for handle, held in pairs(Held) do
			local k = held.Kind
			if (k == "weapon" or k == "gaster") and held.LastCF and handle.Parent then
				if clean then
					for _, d in ipairs(handle:GetChildren()) do
						if not string.find(d.Name, "^HS_") then
							if d:IsA("JointInstance") or d:IsA("WeldConstraint") then
								pcall(function() d:Destroy() end)
							else
								for _, cls in ipairs(CONTROLLER_CLASSES) do
									if d:IsA(cls) then pcall(function() d:Destroy() end) break end
								end
							end
						end
					end
					if (not held.AP or not held.AP.Parent) and handle.Parent then
						pcall(function()
							local att = handle:FindFirstChild("HS_Att") or Instance.new("Attachment")
							att.Name = "HS_Att"
							att.Parent = handle
							held.Att = att
							local ap = Instance.new("AlignPosition")
							ap.Name = "HS_AP"
							ap.Mode = Enum.PositionAlignmentMode.OneAttachment
							ap.Attachment0 = att
							ap.RigidityEnabled = true
							ap.MaxForce = math.huge
							ap.Responsiveness = 200
							ap.Parent = handle
							held.AP = ap
							local ao = Instance.new("AlignOrientation")
							ao.Name = "HS_AO"
							ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
							ao.Attachment0 = att
							ao.RigidityEnabled = true
							ao.MaxTorque = math.huge
							ao.Responsiveness = 200
							ao.Parent = handle
							held.AO = ao
						end)
					end
					pcall(function()
						handle.Anchored = false
						handle.CanCollide = false
						handle.Massless = true
					end)
				end
				pcall(function()
					if held.AP then held.AP.Position = held.LastCF.Position end
					if held.AO then held.AO.CFrame = held.LastCF end
					handle.CFrame = held.LastCF
					handle.AssemblyLinearVelocity = Vector3.zero
					handle.AssemblyAngularVelocity = Vector3.zero
				end)
			end
		end
	end

	-- placed hats solid: set before every physics step (Stepped), because Roblox / Uhhhhhh reset hat collision
	function X.placedSolid()
		return m.PlaceSolid and not (m.BToolsCarry and BToolsCarryCF)
	end

	function X.solidStep()
		if not m.Enabled or #PlacedHats == 0 then return end
		local solid = X.placedSolid() and true or false
		local yeeting = {}
		for _, y in ipairs(YeetQueue) do
			if y.Entry then yeeting[y.Entry] = true end
		end
		for _, e in ipairs(PlacedHats) do
			local h = e.Handle
			if h and h.Parent and not yeeting[e] then
				pcall(function()
					if h.CanCollide ~= solid then h.CanCollide = solid end
					if solid and not h.CanQuery then h.CanQuery = true end
				end)
			end
		end
	end

	-- ===== ALL HATS SOLID (FE): every worn hat collides with NPCs / dummies / unanchored parts =====
	-- The hats are my own client-owned parts, so their collisions replicate. Anything they hit only moves
	-- for other players if this client simulates it (the huge simulation radius asks for that); server-owned
	-- or anchored things just block the hat.
	local HatNC = setmetatable({}, { __mode = "k" }) -- handle -> { [otherPart] = constraint }
	local HatNCT = setmetatable({}, { __mode = "k" })

	X.hatsSolidHandles = function()
		local list, seen = {}, {}
		local function add(h)
			if h and h:IsA("BasePart") and h.Parent and not seen[h] then seen[h] = true list[#list + 1] = h end
		end
		local function scan(char)
			if not (char and char.Parent) then return end
			for _, d in ipairs(char:GetChildren()) do
				if d:IsA("Accessory") then add(d:FindFirstChild("Handle")) end
			end
		end
		scan(LocalPlayer.Character)
		pcall(function() scan(_G.Uhhhhhh and _G.Uhhhhhh.Character) end)
		for handle in pairs(Held) do add(handle) end
		return list
	end

	function X.hatsSolidRestore()
		for h, set in pairs(HatNC) do
			for _, c in pairs(set) do pcall(function() c:Destroy() end) end
			HatNC[h] = nil
			if h and h.Parent then pcall(function() h.CanCollide = false end) end
		end
	end

	function X.hatsSolidStep()
		if not (m.Enabled and m.HatsSolid) then
			if X.HatsSolidWas then X.HatsSolidWas = false X.hatsSolidRestore() end
			return
		end
		X.HatsSolidWas = true
		local now = os.clock()
		if m.HatsSolidBoost ~= false and now - (X.HatsSolidBoostT or 0) > 1 then
			X.HatsSolidBoostT = now
			pcall(X.boostNetwork)
		end
		local handles = X.hatsSolidHandles()
		-- parts every hat must pass through: my body, the rig, the stand, the clone, (other players)
		local ghost = {}
		local function addModel(model)
			if not (model and model.Parent) then return end
			for _, d in ipairs(model:GetDescendants()) do
				if d:IsA("BasePart") then ghost[#ghost + 1] = d end
			end
		end
		local budget = 80 -- constraints created per step, keeps the frame smooth
		local needScan = false
		for _, h in ipairs(handles) do
			if now - (HatNCT[h] or 0) > 1.5 then needScan = true break end
		end
		if needScan then
			addModel(LocalPlayer.Character)
			pcall(function() addModel(_G.Uhhhhhh and _G.Uhhhhhh.Character) end)
			addModel(X.CloneModel)
			pcall(function() addModel(StandModel) end)
			if m.HatsSolidIgnorePlayers ~= false then
				for _, pl in ipairs(Players:GetPlayers()) do
					if pl ~= LocalPlayer then addModel(pl.Character) end
				end
			end
		end
		for _, h in ipairs(handles) do
			pcall(function()
				if not h.CanCollide then h.CanCollide = true end
				if not h.CanTouch then h.CanTouch = true end
				if not h.CanQuery then h.CanQuery = true end
			end)
			if needScan and now - (HatNCT[h] or 0) > 1.5 and budget > 0 then
				HatNCT[h] = now
				local set = HatNC[h]
				if not set then set = {} HatNC[h] = set end
				for _, part in ipairs(ghost) do
					if part ~= h and not set[part] and budget > 0 then
						budget = budget - 1
						local c = Instance.new("NoCollisionConstraint")
						c.Name = "HS_HatNC"
						c.Part0, c.Part1 = h, part
						c.Parent = h
						set[part] = c
					end
				end
				if budget <= 0 then HatNCT[h] = 0 end -- unfinished: come back next step
				for part, c in pairs(set) do
					if not part.Parent then pcall(function() c:Destroy() end) set[part] = nil end
				end
			end
		end
	end

	X.startLate = function()
		X.stopLate()
		X.LateConns = {
			RunService.Stepped:Connect(function() pcall(X.solidStep) end),
			RunService.Stepped:Connect(function() pcall(X.hatsSolidStep) end),
			RunService.Stepped:Connect(function()
				if m.LowLag ~= false then
					X.LateN = ((X.LateN or 0) + 1) % 4
					if X.LateN ~= 0 then return end
				end
				pcall(X.lateApply, true)
			end),
			RunService.RenderStepped:Connect(function() pcall(X.lateApply, false) end),
		}
	end

	X.stopLate = function()
		for _, c in ipairs(X.LateConns or {}) do pcall(function() c:Disconnect() end) end
		X.LateConns = {}
		if X.HatsSolidWas then X.HatsSolidWas = false pcall(X.hatsSolidRestore) end
	end


	--------------------------------------------------------------
	-- PLANETS (solar-system style 10-slot hat orbits)
	--------------------------------------------------------------
	X.slotsAlive = function(slots)
		if not slots then return false end
		local any, dead = false, false
		for _, s in pairs(slots) do
			if s then
				any = true
				if not (s.Handle and s.Handle.Parent) then dead = true end
			end
		end
		return any, dead
	end

	X.anyHatConfigured = function(prefix, n)
		for i = 1, n do
			if X.trim(m[prefix .. i] or "") ~= "" then return true end
		end
		return false
	end

	function X.checkVehicleRebuilds(now)
		now = now or os.clock()
		-- Plane
		if m.PlaneEnabled and m.PlaneAutoRebuild then
			if now - (LastPlaneCheck or 0) > 0.6 then
				LastPlaneCheck = now
				local hasFrames = PlaneFull ~= nil or next(PlaneFrames) ~= nil or next(PlaneProps) ~= nil or next(PlaneEngines) ~= nil
				local configured = (m.PlaneFullMode and X.trim(m.PlaneFullHat or "") ~= "")
					or X.anyHatConfigured("PlaneFrameHat", 10)
					or X.anyHatConfigured("PlanePropHat", 2)
					or X.anyHatConfigured("PlaneEngineHat", 2)
					or X.anyHatConfigured("PlaneGunHat", 4)
				if configured then
					local alive = PlaneFull and PlaneFull.Handle and PlaneFull.Handle.Parent
					local dead = PlaneFull and not (PlaneFull.Handle and PlaneFull.Handle.Parent)
					for _, group in ipairs({ PlaneFrames, PlaneProps, PlaneEngines, PlaneGuns }) do
						local a, d = X.slotsAlive(group)
						if a then alive = true end
						if d then dead = true end
					end
					if (not alive) or dead then
						NeedPlaneRebuild = true
					end
				end
			end
		end
		-- Moto
		if m.MotoEnabled and m.MotoAutoRebuild then
			if now - (LastMotoCheck or 0) > 0.6 then
				LastMotoCheck = now
				local configured = X.anyHatConfigured("MotoHat", 6) or X.anyHatConfigured("MotoWheelHat", 2) or X.trim(m.MotoEngineHat or "") ~= ""
				if configured then
					local a1, d1 = X.slotsAlive(MotoSlots)
					local a2, d2 = X.slotsAlive(MotoWheels)
					local engDead = MotoEngine and not (MotoEngine.Handle and MotoEngine.Handle.Parent)
					if (not a1 and not a2 and not MotoEngine) or d1 or d2 or engDead then
						NeedMotoRebuild = true
					end
				end
			end
		end
		-- Planet
		if m.PlanetEnabled and m.PlanetAutoRebuild then
			if now - (LastPlanetCheck or 0) > 0.6 then
				LastPlanetCheck = now
				if X.anyHatConfigured("PlanetHat", 10) then
					local a, d = X.slotsAlive(PlanetSlots)
					if (not a) or d then NeedPlanetRebuild = true end
				end
			end
		end
		-- Tool
		

		if m.ToolEnabled and m.ToolAutoRebuild then
			if now - (LastToolCheck or 0) > 0.6 then
				LastToolCheck = now
				if X.anyHatConfigured("ToolHat", 6) then
					local a, d = X.slotsAlive(ToolSlots)
					if (not a) or d then NeedToolRebuild = true end
				end
			end
		end
		-- Car
		if m.CarEnabled and m.CarAutoRebuild then
			if now - (LastCarCheck or 0) > 0.6 then
				LastCarCheck = now
				local configured = X.anyHatConfigured("CarHat", 8) or X.anyHatConfigured("CarWheelHat", 4) or X.trim(m.CarEngineHat or "") ~= ""
				if configured then
					local a1, d1 = X.slotsAlive(CarSlots)
					local a2, d2 = X.slotsAlive(CarWheels)
					local engDead = CarEngine and not (CarEngine.Handle and CarEngine.Handle.Parent)
					if (not a1 and not a2 and not CarEngine) or d1 or d2 or engDead then
						NeedCarRebuild = true
					end
				end
			end
		end
	end

	--------------------------------------------------------------
	-- OWN DANCE: record Steve's Uhhhhhh dance (pose + sounds), replay on stand / clone on their own
	--------------------------------------------------------------
	;(function()
		local HttpService = game:GetService("HttpService")
		local SoundService = game:GetService("SoundService")
		local DANCE_FILE = "HatStand_Dances" .. SUF .. ".json"
		local SKIP_SOUND = {
			Running = true, Jumping = true, Landing = true, Climbing = true,
			GettingUp = true, FreeFalling = true, Splash = true, Swimming = true,
		}

		X.DanceRecs = X.DanceRecs or {}
		X.OwnDance = X.OwnDance or {}
		X.DanceRec = nil
		X.OwnPick = X.OwnPick or ""

		function X.danceRecNames()
			local n = {}
			for k in pairs(X.DanceRecs) do n[#n + 1] = k end
			table.sort(n)
			return n
		end

		local function r4(v) return math.floor(v * 10000 + 0.5) / 10000 end

		function X.saveDanceRecs()
			if type(writefile) ~= "function" then return false end
			local out = {}
			for name, rec in pairs(X.DanceRecs) do
				local fr = {}
				for i, f in ipairs(rec.frames) do
					local e = { r4(f.t) }
					for _, limb in ipairs(LIMB_NAMES) do
						local c = f[limb]
						if c then
							local comps = { c:GetComponents() }
							for j = 1, #comps do comps[j] = r4(comps[j]) end
							e[#e + 1] = comps
						else
							e[#e + 1] = false
						end
					end
					fr[i] = e
				end
				out[name] = { len = rec.len, frames = fr, sounds = rec.sounds }
			end
			local ok = pcall(function() writefile(DANCE_FILE, HttpService:JSONEncode(out)) end)
			return ok
		end

		function X.loadDanceRecs()
			if type(readfile) ~= "function" or type(isfile) ~= "function" then return end
			local ok, data = pcall(function()
				if isfile(DANCE_FILE) then return HttpService:JSONDecode(readfile(DANCE_FILE)) end
			end)
			if not (ok and type(data) == "table") then return end
			for name, rec in pairs(data) do
				if type(rec) == "table" and type(rec.frames) == "table" and not X.DanceRecs[name] then
					local frames = {}
					for i, e in ipairs(rec.frames) do
						local f = { t = e[1] }
						for li, limb in ipairs(LIMB_NAMES) do
							local c = e[li + 1]
							if type(c) == "table" and #c == 12 then f[limb] = CFrame.new(table.unpack(c)) end
						end
						frames[i] = f
					end
					if #frames >= 2 then
						X.DanceRecs[name] = { frames = frames, sounds = rec.sounds or {}, len = tonumber(rec.len) or frames[#frames].t }
						if X.OwnPick == "" then X.OwnPick = name end
					end
				end
			end
		end

		function X.deleteDanceRec(name)
			name = X.trim(name or X.OwnPick or "")
			if X.DanceRecs[name] then
				X.DanceRecs[name] = nil
				if X.OwnPick == name then X.OwnPick = (X.danceRecNames()[1]) or "" end
				pcall(X.saveDanceRecs)
				warn("[HatStand] deleted recording '" .. name .. "'")
			end
		end

		function X.cycleDanceRec()
			local names = X.danceRecNames()
			if #names == 0 then warn("[HatStand] no recordings yet") return "" end
			local at = 0
			for i, n in ipairs(names) do if n == X.OwnPick then at = i break end end
			X.OwnPick = names[(at % #names) + 1]
			warn("[HatStand] selected recording: " .. X.OwnPick)
			return X.OwnPick
		end

		function X.startDanceRec(name, secs, playName)
			if X.DanceRec then X.finishDanceRec() end
			name = X.trim(name or "")
			if name == "" then name = "Dance " .. tostring(#X.danceRecNames() + 1) end
			X.DanceRec = {
				name = name, frames = {}, sounds = {}, seen = {},
				t = 0, acc = 0, sacc = 0, maxT = math.clamp(tonumber(secs) or 12, 1, 120),
			}
			warn("[HatStand] recording '" .. name .. "' ... (Stop to finish early)")
			if X.trim(playName or "") ~= "" then pcall(X.playDance, playName) end
		end

		function X.finishDanceRec()
			local r = X.DanceRec
			if not r then return end
			X.DanceRec = nil
			local f = r.frames
			if #f < 8 then
				warn("[HatStand] recording too short or no source rig found - nothing saved")
				return
			end
			-- trim the idle lead-in (time between pressing record and the dance actually starting)
			local first = f[1]
			local startI = 1
			for i = 2, #f do
				local dev = 0
				for _, limb in ipairs(LIMB_NAMES) do
					local a, b = first[limb], f[i][limb]
					if a and b then
						dev = dev + (a.LookVector - b.LookVector).Magnitude + (a.UpVector - b.UpVector).Magnitude + (a.Position - b.Position).Magnitude
					end
				end
				if dev > 0.25 then startI = math.max(1, i - 3) break end
			end
			local off = f[startI].t
			local frames = {}
			for i = startI, #f do
				local fr = f[i]
				fr.t = fr.t - off
				frames[#frames + 1] = fr
			end
			for _, s in ipairs(r.sounds) do
				local nt = s.t - off
				if nt < 0 then s.pos = (s.pos or 0) - nt nt = 0 end
				s.t = nt
			end
			table.sort(r.sounds, function(a, b) return a.t < b.t end)
			X.DanceRecs[r.name] = { frames = frames, sounds = r.sounds, len = frames[#frames].t }
			X.OwnPick = r.name
			warn("[HatStand] saved recording '" .. r.name .. "' (" .. #frames .. " frames, " .. #r.sounds .. " sounds, "
				.. string.format("%.1f", frames[#frames].t) .. "s)")
			pcall(X.saveDanceRecs)
			return r.name
		end

		local function checkSound(r, s)
			if not s:IsA("Sound") or r.seen[s] or SKIP_SOUND[s.Name] then return end
			local playing = false
			pcall(function() playing = s.IsPlaying end)
			if not playing then return end
			r.seen[s] = true
			local pos = 0
			pcall(function() pos = s.TimePosition end)
			r.sounds[#r.sounds + 1] = {
				t = math.max(0, r.t - pos), pos = math.max(0, pos - r.t),
				id = s.SoundId, vol = s.Volume, speed = s.PlaybackSpeed, looped = s.Looped,
			}
		end

		local function scanSounds(r, root)
			if not root then return end
			local list = root:GetDescendants()
			for i = 1, #list do checkSound(r, list[i]) end
		end

		function X.stepDanceRec(dt)
			local r = X.DanceRec
			if not r then return end
			r.t = r.t + dt
			r.acc = r.acc + dt
			if r.acc >= 1 / 30 then
				r.acc = r.acc % (1 / 30)
				local s = X.sampleRig()
				if s then
					local fr = { t = r.t }
					for _, limb in ipairs(LIMB_NAMES) do fr[limb] = s[limb] end
					r.frames[#r.frames + 1] = fr
				end
			end
			r.sacc = r.sacc + dt
			if r.sacc >= 0.15 then
				r.sacc = 0
				local model = X.getSourceRig()
				scanSounds(r, model)
				if LocalPlayer.Character ~= model then scanSounds(r, LocalPlayer.Character) end
				scanSounds(r, SoundService)
				for _, c in ipairs(Workspace:GetChildren()) do checkSound(r, c) end
			end
			if r.t >= r.maxT then X.finishDanceRec() end
		end

		local function stopSounds(od)
			if od and od.snds then
				for _, s in ipairs(od.snds) do pcall(function() s:Stop() s:Destroy() end) end
				od.snds = {}
			end
		end

		function X.stopOwnDance(tg)
			if tg == "Both" then X.stopOwnDance("Stand") X.stopOwnDance("Clone") return end
			local od = X.OwnDance[tg]
			if od then stopSounds(od) end
			X.OwnDance[tg] = nil
			if tg == "Clone" then X.CloneBlend = nil end
		end

		function X.playOwnDance(tg, name)
			name = X.trim(name or X.OwnPick or "")
			local rec = X.DanceRecs[name]
			if not rec then warn("[HatStand] no recording selected - record one first") return false end
			if tg == "Both" then X.playOwnDance("Stand", name) X.playOwnDance("Clone", name) return true end
			X.stopOwnDance(tg)
			X.OwnDance[tg] = { rec = rec, name = name, t = 0, idx = 1, sIdx = 1, snds = {}, out = {}, tg = tg }
			return true
		end

		local function playSnd(od, s)
			local parent = X.getFollowRoot()
			if od.tg == "Clone" then
				for _, d in pairs(X.CloneLimbs) do
					if d.Part and d.Part.Parent then parent = d.Part break end
				end
			end
			if not parent then return end
			pcall(function()
				local snd = Instance.new("Sound")
				snd.Name = "HS_OwnDanceSound"
				snd.SoundId = s.id
				snd.Volume = s.vol or 0.5
				snd.PlaybackSpeed = (s.speed or 1) * (m.OwnDanceSpeed or 1)
				snd.Looped = s.looped or false
				snd.Parent = parent
				snd.TimePosition = s.pos or 0
				snd:Play()
				od.snds[#od.snds + 1] = snd
				if not snd.Looped then
					snd.Ended:Connect(function() pcall(function() snd:Destroy() end) end)
				end
			end)
		end

		function X.ownDanceSample(od, dt)
			local rec = od.rec
			local fr = rec.frames
			local n = #fr
			if n < 2 then od.Finished = true return nil end
			od.t = od.t + dt * (m.OwnDanceSpeed or 1)
			if od.t >= rec.len then
				if m.OwnDanceLoop ~= false then
					od.t = od.t % math.max(rec.len, 0.05)
					od.idx, od.sIdx = 1, 1
					stopSounds(od)
				else
					od.Finished = true
					return nil
				end
			end
			if m.OwnDanceSounds ~= false then
				local snd = rec.sounds
				while od.sIdx <= #snd and snd[od.sIdx].t <= od.t do
					playSnd(od, snd[od.sIdx])
					od.sIdx = od.sIdx + 1
				end
			end
			local i = od.idx
			if i >= n then i = 1 end
			while i > 1 and fr[i].t > od.t do i = i - 1 end
			while i < n - 1 and fr[i + 1].t <= od.t do i = i + 1 end
			od.idx = i
			local a, b = fr[i], fr[i + 1]
			local span = b.t - a.t
			local k = span > 1e-4 and math.clamp((od.t - a.t) / span, 0, 1) or 0
			local out = od.out
			for _, limb in ipairs(LIMB_NAMES) do
				local ca, cb = a[limb], b[limb]
				if ca and cb then out[limb] = ca:Lerp(cb, k) else out[limb] = ca or cb end
			end
			return out
		end
	end)()

	--------------------------------------------------------------
	-- HELLCOPTER: hat frames + propellers + weapons (hat bullets), physics ride
	--------------------------------------------------------------
	function X.stepAll(dt)
		if not m.Enabled or X.Dead then return end
		X.Frame = X.Frame + 1 if X.Frame % 120 == 1 and next(Held) ~= nil then pcall(X.boostNetwork) end
		-- full rate: stand, clone, hellcopter, dance recorder
		pcall(X.stepDanceRec, dt)
		pcall(X.stepStand, dt)
		pcall(X.stepClone, dt)
		pcall(X.stepHeli, dt)
		pcall(X.stepHeliBullets, dt)
		pcall(X.stepHeliMissiles, dt)
		if m.TitanEnabled then pcall(X.stepTitan, dt) end

		local skip = m.LowLag and math.clamp(math.floor(m.LowLagSkip or 2), 1, 6) or 1
		X.SlowAcc = (X.SlowAcc or 0) + dt
		-- vehicles you are riding stay at full rate
		local rideP = m.PlaneEnabled and m.PlaneRide
		local rideM = m.MotoEnabled and m.MotoRide
		local rideC = m.CarEnabled and m.CarRide
		if rideP then pcall(X.stepPlane, dt) end
		if rideM then pcall(X.stepMoto, dt) end
		if rideC then pcall(X.stepCar, dt) end
		if skip > 1 and (X.Frame % skip) ~= 0 then return end
		local sdt = X.SlowAcc
		X.SlowAcc = 0

		pcall(X.updatePlacePreview)
		pcall(X.stepPlaced, sdt)
		if NeedOrbitRebuild then
			NeedOrbitRebuild = false
			pcall(X.rebuildOrbit)
		end
		pcall(X.checkVehicleRebuilds, os.clock())
		if NeedPlaneRebuild then
			NeedPlaneRebuild = false
			pcall(X.rebuildPlane)
		end
		if NeedMotoRebuild then
			NeedMotoRebuild = false
			pcall(X.rebuildMoto)
		end
		if NeedPlanetRebuild then
			NeedPlanetRebuild = false
			pcall(X.rebuildPlanet)
		end
		if NeedToolRebuild then
			NeedToolRebuild = false
			pcall(X.rebuildTool)
		end
		if NeedCarRebuild then
			NeedCarRebuild = false
			pcall(X.rebuildCar)
		end
		pcall(X.stepOrbit, sdt)
		pcall(X.stepGaster, sdt)
		pcall(X.stepBone, sdt)
		pcall(X.stepOmega, sdt)
		pcall(X.stepWeapon, sdt)
		pcall(X.stepShield, sdt)
		pcall(stepClaws, sdt)
		if not rideC then pcall(X.stepCar, sdt) end
		pcall(X.stepBall, sdt)
		pcall(X.stepPlanet, sdt)
		if not rideM then pcall(X.stepMoto, sdt) end
		pcall(X.stepTool, sdt)
		if not rideP then pcall(X.stepPlane, sdt) end
	end

	function X.startLoop()
		if FollowBound or X.Dead then return end
		for _, n in ipairs(OLD_BIND_NAMES) do
			pcall(function() RunService:UnbindFromRenderStep(n) end)
		end
		pcall(function()
			local g = getgenv()
			if g and g.Uhhhhhh_HatStandHB then
				g.Uhhhhhh_HatStandHB:Disconnect()
				g.Uhhhhhh_HatStandHB = nil
			end
		end)
		HBConn = RunService.Heartbeat:Connect(function(dt)
			pcall(X.stepAll, math.clamp(dt, 0, 0.1))
		end)
		pcall(function()
			local g = getgenv()
			if g then g.Uhhhhhh_HatStandHB = HBConn end
		end)
		X.bindKeys()
		X.bindCharacter()
		X.startLate()
		X.startHatAutoRefresh()
		X.ensurePlaceFolder()
		FollowBound = true
	end

	function X.stopLoop()
		if HBConn then pcall(function() HBConn:Disconnect() end) HBConn = nil end
		pcall(function()
			local g = getgenv()
			if g then g.Uhhhhhh_HatStandHB = nil end
		end)
		for _, c in ipairs(KeyConns) do pcall(function() c:Disconnect() end) end
		for _, c in ipairs(CharConns) do pcall(function() c:Disconnect() end) end
		KeyConns, CharConns = {}, {}
		X.stopLate()
		if X.HeliSolidConn then pcall(function() X.HeliSolidConn:Disconnect() end) X.HeliSolidConn = nil end
		X.stopHatAutoRefresh()
		X.clearPlacePreview()
		FollowBound = false
	end

	function X.refreshState()
		if m.Enabled then
			X.startLoop()
			if X.modeAllowsStand() and m.AutoBuild and (not StandModel or not StandModel.Parent) then
				NeedRebuild = true
			end
			if not X.modeAllowsStand() and StandModel then pcall(X.destroyStand) end
			if X.modeAllowsOrbit() and m.OrbitEnabled then NeedOrbitRebuild = true end
			if not X.modeAllowsPlace() then X.clearPlacePreview() end
			if not X.modeAllowsOrbit() then X.clearOrbit() end
			if m.GasterEnabled then task.defer(X.rebuildGaster) else X.clearGaster() end
			if m.BoneEnabled then task.defer(X.rebuildBone) else X.clearBone() end
			if m.OmegaEnabled then task.defer(X.rebuildOmega) else X.clearOmega() end
			if m.WeaponEnabled then task.defer(X.rebuildWeapon) else X.clearWeapon() end
			if m.ShieldEnabled then task.defer(X.rebuildShield) else X.clearShield() end
			if m.ClawsEnabled then task.defer(rebuildClaws) else clearClaws() end
			if m.CarEnabled then task.defer(X.rebuildCar) else X.clearCar() end
			if m.BallEnabled then task.defer(X.rebuildBall) else X.clearBall() end
			if m.PlanetEnabled then task.defer(X.rebuildPlanet) else X.clearPlanet() end
			if m.MotoEnabled then task.defer(X.rebuildMoto) else X.clearMoto() end
			if m.ToolEnabled then task.defer(X.rebuildTool) else X.clearTool() end
			if m.PlaneEnabled then task.defer(X.rebuildPlane) else X.clearPlane() end
			if m.HeliEnabled then task.defer(X.rebuildHeli) else X.clearHeli() end
			if m.CloneEnabled then X.NeedCloneRebuild = true else X.clearClone() end
		else
			X.stopLoop()
			X.releaseHeld(nil)
			Limbs = {}
			OrbitSlots = {}
			X.clearAllPlaced()
			X.clearGaster()
			X.clearBone()
			X.clearOmega()
			X.clearWeapon()
			X.clearShield()
			clearClaws()
			X.clearCar()
			X.clearHeli()
			X.clearClone()
			X.clearLabels()
			X.clearLimbPreview()
		end
	end

	function X.resetLimbRots()
		for _, limb in ipairs(LIMB_NAMES) do
			local keys = LIMB_ROT_KEYS[limb]
			if keys then m[keys[1]] = 0 m[keys[2]] = 0 m[keys[3]] = 0 end
		end
		X.refreshAllLimbOffsets()
		X.updateLimbPreview()
	end

	function X.resetLimbOffsets()
		for _, limb in ipairs(LIMB_NAMES) do
			local keys = LIMB_OFF_KEYS[limb]
			if keys then m[keys[1]] = 0 m[keys[2]] = 0 m[keys[3]] = 0 end
		end
		X.refreshAllLimbOffsets()
		X.updateLimbPreview()
	end

	--------------------------------------------------------------
	-- CONFIG UI
	--------------------------------------------------------------
	m.Config = function(parent)
		if not parent then
			warn("[HatStand] Config called with nil parent")
			return
		end

		-- Host Util_* can return nil; never chain .Changed/.Activated blindly
		local function onChanged(ctrl, fn)
			if ctrl ~= nil and ctrl.Changed then
				pcall(function() ctrl.Changed:Connect(fn) end)
			end
			return ctrl
		end
		local function onActivated(ctrl, fn)
			if ctrl ~= nil and ctrl.Activated then
				pcall(function() ctrl.Activated:Connect(fn) end)
			end
			return ctrl
		end

		-- per-module GUI: only the sections this module owns are created (cfg.sections = set of keys)
		local H_Text, H_Switch, H_Slider, H_Drop, H_Button, H_Sep =
			Util_CreateText, Util_CreateSwitch, Util_CreateSlider, Util_CreateDropdown, Util_CreateButton, Util_CreateSeparator
		local SEC = "core"
		local DUMMY
		DUMMY = setmetatable({}, {
			__index = function() return DUMMY end,
			__call = function() return DUMMY end,
			__newindex = function() end,
		})
		local SEC_MAP = {
			{ "HAT COLLISION", "core" }, { "PERFORMANCE", "core" },
			{ "LINK / MOVESET", "stand" }, { "POSE FIX", "stand" }, { "CLONE", "stand" },
			{ "OWN DANCE", "stand" }, { "WALK / DANCE", "stand" }, { "── STAND ──", "stand" },
			{ "PLACE / BTOOLS", "place" }, { "BTOOLS BUILD", "place" },
			{ "HAT ORBIT", "orbit" },
			{ "SANS MODE", "sans" }, { "GASTER", "sans" }, { "BONE ATTACK", "sans" }, { "OMEGA BLASTER", "sans" },
			{ "WEAPONS", "weapons" }, { "SHIELD", "shield" }, { "RAVENGER", "claws" },
			{ "CAR", "car" }, { "BALL SYSTEM", "ball" }, { "PLANETS", "planet" },
			{ "MOTORCYCLE", "moto" }, { "PLANE", "plane" }, { "HELLCOPTER", "heli" }, { "TITAN", "titan" },
		}
		local function showing()
			if SEC == "core" or cfg.sections == nil then return true end
			return cfg.sections[SEC] == true
		end
		local Util_CreateText = function(p, text, ...)
			if type(text) == "string" then
				if string.sub(text, 1, 4) == "── " then
					for _, pair in ipairs(SEC_MAP) do
						if string.find(text, pair[1], 1, true) then SEC = pair[2] break end
					end
				elseif text == "HAT STAND  v16" and cfg.title then
					text = cfg.title
				elseif string.sub(text, 1, 7) == "Link • " and cfg.subtitle then
					text = cfg.subtitle
				end
			end
			if not showing() then return DUMMY end
			return H_Text(p, text, ...)
		end
		local Util_CreateSwitch = function(...) if not showing() then return DUMMY end return H_Switch(...) end
		local Util_CreateSlider = function(...) if not showing() then return DUMMY end return H_Slider(...) end
		local Util_CreateDropdown = function(...) if not showing() then return DUMMY end return H_Drop(...) end
		local Util_CreateButton = function(...) if not showing() then return DUMMY end return H_Button(...) end
		local Util_CreateSeparator = function(...) if not showing() then return DUMMY end return H_Sep(...) end

		local function keyDropdown(label, field)
			local start = 1
			for i, n in ipairs(m.KeyNames) do
				if n == m[field] then start = i break end
			end
			local dd = Util_CreateDropdown(parent, label, m.KeyNames, start)
			if dd and dd.Changed then
				dd.Changed:Connect(function(val)
					local name = (type(val) == "number") and m.KeyNames[val] or tostring(val)
					if name and name ~= "" then m[field] = name end
				end)
			end
			return dd
		end

		local okUI, errUI = pcall(function()
		Util_CreateText(parent, "HAT STAND  v16", 18, Enum.TextXAlignment.Center)
		Util_CreateText(parent, "Link • Clone • Dances • JoJo Loco • Gaster • Weapons • Shield • Car • Claws", 12, Enum.TextXAlignment.Left)
		Util_CreateSeparator(parent)
		Util_CreateText(parent, "── HAT COLLISION (FE) ──", 14, Enum.TextXAlignment.Center)
		onChanged(Util_CreateSwitch(parent, "All My Hats Solid (hit NPCs / dummies / unanchored parts)", m.HatsSolid == true), function(v) m.HatsSolid = v end)
		onChanged(Util_CreateSlider(parent, "Hat Push Strength", m.HatsSolidPush or 1, 0, 3, 0.1), function(v) m.HatsSolidPush = v end)
		onChanged(Util_CreateSwitch(parent, "Ignore other players (no collision with them)", m.HatsSolidIgnorePlayers ~= false), function(v) m.HatsSolidIgnorePlayers = v end)
		onChanged(Util_CreateSwitch(parent, "Boost simulation radius (own nearby unanchored parts)", m.HatsSolidBoost ~= false), function(v) m.HatsSolidBoost = v end)
		Util_CreateText(parent, "Hats are your own parts, so their collisions are FE. What they hit only moves for everyone if your client simulates it; anchored or server-owned things just block the hat.", 11, Enum.TextXAlignment.Left)
		Util_CreateSeparator(parent)
		Util_CreateText(parent, "── PERFORMANCE ──", 14, Enum.TextXAlignment.Center)
		onChanged(Util_CreateSwitch(parent, "Low-Lag Mode (extras update less often)", m.LowLag), function(v) m.LowLag = v end)
		onChanged(Util_CreateSwitch(parent, "Full stop when I exit the moveset", m.StopOnExit ~= false), function(v) m.StopOnExit = v end)
		onChanged(Util_CreateSlider(parent, "Low-Lag Skip (1 = off, 2 = half rate)", m.LowLagSkip, 1, 6, 1), function(v) m.LowLagSkip = math.floor(v + 0.5) end)
		Util_CreateText(parent, "Stand, clone, hellcopter and anything you are riding stay at full rate. Orbit, weapons, Sans attacks, placed hats etc. run every Nth frame. Also on: duplicate hat writes are skipped and auto-refresh only rebuilds when your hats actually changed.", 11, Enum.TextXAlignment.Left)
		Util_CreateSeparator(parent)


		if cfg.mode == 4 then
			local modeDD = Util_CreateDropdown(parent, "Active Mode", m.ActiveModeNames, m.ActiveMode)
			if modeDD and modeDD.Changed then
				modeDD.Changed:Connect(function(val)
					if type(val) == "number" then m.ActiveMode = val
					elseif type(val) == "string" then
						for i, n in ipairs(m.ActiveModeNames) do
							if n == val then m.ActiveMode = i break end
						end
					end
					NeedRebuild = true
					NeedOrbitRebuild = true
					X.NeedCloneRebuild = true
					X.refreshState()
				end)
			end
			onChanged(Util_CreateSwitch(parent, "Stand + Clone also run in Hat Orbit mode", m.StandInOrbitMode ~= false), function(v)
				m.StandInOrbitMode = v
				NeedRebuild = true NeedOrbitRebuild = true X.NeedCloneRebuild = true
				X.refreshState()
			end)
		else
			Util_CreateText(parent, "Mode: " .. tostring(m.ActiveModeNames[m.ActiveMode] or m.ActiveMode) .. "  (this module is locked to that mode - run the other Hat modules next to it)", 11, Enum.TextXAlignment.Left)
		end
		onChanged(Util_CreateSwitch(parent, "Enabled", m.Enabled), function(v)
			m.Enabled = v X.refreshState()
		end)
		onChanged(Util_CreateSwitch(parent, "Use With Other Movesets", m.UseWithOtherMovesets), function(v)
			m.UseWithOtherMovesets = v X.refreshState()
		end)
		onChanged(Util_CreateSwitch(parent, "FE Real Hats", m.FEMode), function(v)
			m.FEMode = v
			X.releaseHeld(nil)
			NeedRebuild = true
			NeedOrbitRebuild = true
			X.refreshState()
		end)
		onActivated(Util_CreateButton(parent, "Refresh Hat List (check avatar)", 14), function()
			X.refreshAllHats(true)
			LastHatFingerprint = X.hatFingerprint()
		end)
		onChanged(Util_CreateSwitch(parent, "Auto Refresh every 1s", m.AutoRefresh), function(v)
			m.AutoRefresh = v
		end)
		Util_CreateText(parent, (m.LastRefreshReport ~= "" and m.LastRefreshReport) or "Last report: (press Refresh)", 11, Enum.TextXAlignment.Left)

		Util_CreateSeparator(parent)
		Util_CreateText(parent, "── LINK / MOVESET / DANCES ──", 14, Enum.TextXAlignment.Center)
		onChanged(Util_CreateSwitch(parent, "LINK RIGS (stand copies my moveset + dances)", m.LinkRigs), function(v)
			m.LinkRigs = v
			X.LinkWarned = false
		end)
		onChanged(Util_CreateSlider(parent, "Link Strength", m.LinkStrength, 0, 1.5, 0.05), function(v) m.LinkStrength = v end)
		onChanged(Util_CreateSlider(parent, "Link Smooth (higher = tighter)", m.LinkSmooth, 6, 60, 1), function(v) m.LinkSmooth = v end)
		local linkDD = Util_CreateDropdown(parent, "Link Source", m.LinkSourceNames, m.LinkSource)
		if linkDD and linkDD.Changed then
			linkDD.Changed:Connect(function(val)
				if type(val) == "number" then m.LinkSource = val
				elseif type(val) == "string" then
					for i, n in ipairs(m.LinkSourceNames) do
						if n == val then m.LinkSource = i break end
					end
				end
				X.LinkWarned = false
				X.RestSet = false
			end)
		end
		local msDD = Util_CreateDropdown(parent, "Stand Moveset (Link OFF)", m.StandMovesetNames, m.StandMoveset)
		if msDD and msDD.Changed then
			msDD.Changed:Connect(function(val)
				if type(val) == "number" then m.StandMoveset = val
				elseif type(val) == "string" then
					for i, n in ipairs(m.StandMovesetNames) do
						if n == val then m.StandMoveset = i break end
					end
				end
			end)
		end
		local pdDD = Util_CreateDropdown(parent, "Procedural Dance (Moveset 4)", m.ProcDanceNames, m.ProcDance)
		if pdDD and pdDD.Changed then
			pdDD.Changed:Connect(function(val)
				if type(val) == "number" then m.ProcDance = val
				elseif type(val) == "string" then
					for i, n in ipairs(m.ProcDanceNames) do
						if n == val then m.ProcDance = i break end
					end
				end
			end)
		end
		local danceNames = X.scanDances()
		Util_CreateText(parent, "Dance list source: " .. tostring(X.DanceSource) .. " (" .. #danceNames .. ")", 11, Enum.TextXAlignment.Left)
		local danceDD = Util_CreateDropdown(parent, "Dance (pick = play)", danceNames, 1)
		if danceDD and danceDD.Changed then
			danceDD.Changed:Connect(function(val)
				local name = (type(val) == "number") and danceNames[val] or tostring(val)
				X.playDance(name)
			end)
		end
		onActivated(Util_CreateButton(parent, "Print Dance List (console)", 12), function()
			warn("[HatStand] dances: " .. table.concat(X.scanDances(), ", "))
		end)
		onChanged(Util_CreateSwitch(parent, "SELECT FIRST (take no hats until I pick + Apply)", m.SelectFirst), function(v)
			m.SelectFirst = v
			X.Applied = false
			if v then
				X.destroyStand()
				X.clearClone()
			else
				NeedRebuild = true
				X.NeedCloneRebuild = true
			end
		end)
		Util_CreateText(parent, "Select First ON: pick Head/Torso/Arms/Legs (and Clone hats) below, then press Apply. Nothing is grabbed from Uhhhhhh before that, and no hat is auto-filled.", 11, Enum.TextXAlignment.Left)
		onActivated(Util_CreateButton(parent, "Apply Selected Hats (stand + clone)", 14), function()
			X.Applied = true
			NeedRebuild = true
			X.NeedCloneRebuild = true
			X.CloneLastBuild = 0
			X.refreshAllHats()
			local picked = 0
			for _, k in pairs(LIMB_KEYS) do if X.trim(m[k]) ~= "" then picked = picked + 1 end end
			for _, k in pairs(X.CloneKeys) do if X.trim(m[k]) ~= "" then picked = picked + 1 end end
			if picked == 0 and m.SelectFirst then
				warn("[HatStand] Select First is ON and no hats are picked — nothing was taken. Pick hats in the dropdowns, then Apply.")
			end
			pcall(X.buildStand)
		end)
		onActivated(Util_CreateButton(parent, "Release All Stand + Clone Hats", 12), function()
			X.Applied = false
			X.destroyStand()
			X.clearClone()
		end)
		onChanged(Util_CreateSwitch(parent, "Strict Hats (keep the hats I picked)", m.StrictHats), function(v)
			m.StrictHats = v NeedRebuild = true X.NeedCloneRebuild = true
		end)
		onChanged(Util_CreateSwitch(parent, "JoJo Loco (walk / run / jump / fall / land)", m.JojoLoco), function(v) m.JojoLoco = v end)
		onChanged(Util_CreateSlider(parent, "Loco Blend Speed", m.LocoBlend, 4, 40, 1), function(v) m.LocoBlend = v end)
		onChanged(Util_CreateSlider(parent, "Loco Lean", m.LocoLean, 0, 2, 0.05), function(v) m.LocoLean = v end)
		onChanged(Util_CreateSlider(parent, "Loco Bob", m.LocoBob, 0, 2, 0.05), function(v) m.LocoBob = v end)
		onChanged(Util_CreateSlider(parent, "Loco Arm Out", m.LocoArmOut, 0, 3, 0.05), function(v) m.LocoArmOut = v end)
		onChanged(Util_CreateSlider(parent, "Fall Spread", m.FallSpread, 0, 2, 0.05), function(v) m.FallSpread = v end)
		onChanged(Util_CreateSlider(parent, "Land Squash", m.LandSquash, 0, 2, 0.05), function(v) m.LandSquash = v end)

		Util_CreateSeparator(parent)
		Util_CreateText(parent, "── POSE FIX (always on: buttons only) ──", 14, Enum.TextXAlignment.Center)
		onActivated(Util_CreateButton(parent, "Calibrate Rest Pose NOW (stand still, arms down)", 13), function()
			X.calibrate()
		end)
		onActivated(Util_CreateButton(parent, "Clear Rest Calibration", 12), function()
			X.RestSet = false
			X.Rest = {}
			X.CalibT = 0
			X.Blend = {}
		end)
		onActivated(Util_CreateButton(parent, "Reset Pose (stop dance + clear blend)", 12), function()
			ForceDance = false
			ForceDanceUntil = 0
			DanceT = 0
			AnimState, AnimT = "idle", 0
			X.Blend = {}
			X.SnapT = 0.45
		end)
		onActivated(Util_CreateButton(parent, "FIX EVERYTHING (pose + rig + rest)", 14), function()
			m.PoseFix = true
			m.BigRigFix = true
			m.FixAnyRigPose = true
			ForceDance = false
			ForceDanceUntil = 0
			AnimState, AnimT = "idle", 0
			X.resetLimbRots()
			X.resetLimbOffsets()
			X.refreshAllLimbOffsets()
			X.Blend = {}
			X.RestSet = false
			X.calibrate()
			NeedRebuild = true
			pcall(X.buildStand)
			warn("[HatStand] FIX EVERYTHING applied")
		end)

		Util_CreateSeparator(parent)
		Util_CreateText(parent, "── CLONE (spare hats, copies stand pose) ──", 14, Enum.TextXAlignment.Center)
		onChanged(Util_CreateSwitch(parent, "Clone Enabled", m.CloneEnabled), function(v)
			m.CloneEnabled = v
			if v then X.NeedCloneRebuild = true else X.clearClone() end
		end)
		onChanged(Util_CreateSwitch(parent, "Clone Auto Hats (use spare hats)", m.CloneAutoHats), function(v)
			m.CloneAutoHats = v X.NeedCloneRebuild = true
		end)
		onChanged(Util_CreateSwitch(parent, "Clone Face Same Way", m.CloneFaceSame), function(v) m.CloneFaceSame = v end)
		onChanged(Util_CreateSlider(parent, "Clone Side", m.CloneSide, -15, 15, 0.25), function(v) m.CloneSide = v end)
		onChanged(Util_CreateSlider(parent, "Clone Forward", m.CloneForward, -15, 15, 0.25), function(v) m.CloneForward = v end)
		onChanged(Util_CreateSlider(parent, "Clone Height", m.CloneHeight, -10, 10, 0.25), function(v) m.CloneHeight = v end)
		onChanged(Util_CreateSlider(parent, "Clone Follow Smooth", m.CloneSmooth, 5, 60, 1), function(v) m.CloneSmooth = v end)
		local cloneNames = X.dropdownNamesStand()
		local function cloneDD(label, key)
			local start = 1
			for i, n in ipairs(cloneNames) do
				if m[key] ~= "" and string.find(string.lower(n), string.lower(m[key]), 1, true) then
					start = i break
				end
			end
			local dd = Util_CreateDropdown(parent, label, cloneNames, start)
			if dd and dd.Changed then
				dd.Changed:Connect(function(val)
					m[key] = X.cleanLabel(type(val) == "number" and cloneNames[val] or tostring(val))
					X.NeedCloneRebuild = true
				end)
			end
		end
		cloneDD("Clone Head", "CloneHatHead")
		cloneDD("Clone Torso", "CloneHatTorso")
		cloneDD("Clone Left Arm", "CloneHatLeftArm")
		cloneDD("Clone Right Arm", "CloneHatRightArm")
		cloneDD("Clone Left Leg", "CloneHatLeftLeg")
		cloneDD("Clone Right Leg", "CloneHatRightLeg")
		onActivated(Util_CreateButton(parent, "Build / Rebuild Clone", 14), function()
			X.NeedCloneRebuild = true
			X.CloneLastBuild = 0
		end)
		onActivated(Util_CreateButton(parent, "Destroy Clone", 12), function() X.clearClone() end)

		-- CLONE limb rotation + position (live, no rebuild needed)
		local CLONE_LIMBS = {
			{ "Head", "Head" }, { "Torso", "Torso" },
			{ "Left Arm", "LeftArm" }, { "Right Arm", "RightArm" },
			{ "Left Leg", "LeftLeg" }, { "Right Leg", "RightLeg" },
		}
		Util_CreateText(parent, "CLONE LIMB ROTATION (saved)", 13, Enum.TextXAlignment.Left)
		for _, L in ipairs(CLONE_LIMBS) do
			local label, limb = L[1], L[2]
			Util_CreateText(parent, "Clone " .. label, 12, Enum.TextXAlignment.Left)
			for _, ax in ipairs({ "X", "Y", "Z" }) do
				local key = "CloneRot" .. limb .. ax
				onChanged(Util_CreateSlider(parent, "Clone " .. label .. " Rot " .. ax, m[key] or 0, -180, 180, 1), function(v)
					m[key] = v
				end)
			end
		end
		Util_CreateText(parent, "CLONE LIMB POSITION (side / up / forward)", 13, Enum.TextXAlignment.Left)
		Util_CreateText(parent, "Move each clone limb up, down, or to the side independently", 11, Enum.TextXAlignment.Left)
		for _, L in ipairs(CLONE_LIMBS) do
			local label, limb = L[1], L[2]
			Util_CreateText(parent, "Clone " .. label .. " Offset", 12, Enum.TextXAlignment.Left)
			onChanged(Util_CreateSlider(parent, "Clone " .. label .. " Side (X)", m["CloneOff" .. limb .. "X"] or 0, -5, 5, 0.05), function(v)
				m["CloneOff" .. limb .. "X"] = v
			end)
			onChanged(Util_CreateSlider(parent, "Clone " .. label .. " Up (Y)", m["CloneOff" .. limb .. "Y"] or 0, -5, 5, 0.05), function(v)
				m["CloneOff" .. limb .. "Y"] = v
			end)
			onChanged(Util_CreateSlider(parent, "Clone " .. label .. " Forward (Z)", m["CloneOff" .. limb .. "Z"] or 0, -5, 5, 0.05), function(v)
				m["CloneOff" .. limb .. "Z"] = v
			end)
		end
		onActivated(Util_CreateButton(parent, "Reset Clone Limb Rot/Offsets", 12), function()
			for _, L in ipairs(CLONE_LIMBS) do
				for _, ax in ipairs({ "X", "Y", "Z" }) do
					m["CloneRot" .. L[2] .. ax] = 0
					m["CloneOff" .. L[2] .. ax] = 0
				end
			end
		end)

		-- CLONE SLOTS (15): extra hats on the clone
		Util_CreateSeparator(parent)
		Util_CreateText(parent, "CLONE SLOTS (15) - extra hats on the clone (Float / Weapon / Effect / Hand)", 13, Enum.TextXAlignment.Left)
		Util_CreateText(parent, "Pick a hat, press Build / Rebuild Clone. Offsets and rotation are live. Hand follows the clone's right arm.", 11, Enum.TextXAlignment.Left)
		for i = 1, 15 do
			local key = "CloneSlotHat" .. i
			local start = 1
			for j, n in ipairs(cloneNames) do
				if m[key] ~= "" and string.find(string.lower(n), string.lower(m[key]), 1, true) then start = j break end
			end
			local dd = Util_CreateDropdown(parent, "Clone Slot " .. i .. " Hat", cloneNames, start)
			if dd and dd.Changed then
				dd.Changed:Connect(function(val)
					m[key] = X.cleanLabel(type(val) == "number" and cloneNames[val] or tostring(val))
					X.NeedCloneRebuild = true
				end)
			end
			local kdd = Util_CreateDropdown(parent, "Slot " .. i .. " Kind", m.CloneSlotKindNames, m["CloneSlotKind" .. i] or 1)
			if kdd and kdd.Changed then
				kdd.Changed:Connect(function(val)
					local idx = (type(val) == "number") and val or nil
					if not idx then
						for j, n in ipairs(m.CloneSlotKindNames) do if n == val then idx = j break end end
					end
					if idx then m["CloneSlotKind" .. i] = idx end
				end)
			end
			for _, ax in ipairs({ "X", "Y", "Z" }) do
				onChanged(Util_CreateSlider(parent, "Slot " .. i .. " Off " .. ax, m["CloneSlotOff" .. ax .. i] or 0, -8, 8, 0.1), function(v)
					m["CloneSlotOff" .. ax .. i] = v
				end)
			end
			for _, ax in ipairs({ "X", "Y", "Z" }) do
				onChanged(Util_CreateSlider(parent, "Slot " .. i .. " Rot " .. ax, m["CloneSlotRot" .. ax .. i] or 0, -180, 180, 1), function(v)
					m["CloneSlotRot" .. ax .. i] = v
				end)
			end
		end

		-- OWN DANCE
		Util_CreateSeparator(parent)
		Util_CreateText(parent, "── OWN DANCE (stand / clone dance by themselves) ──", 14, Enum.TextXAlignment.Center)
		Util_CreateText(parent, "1) Pick a Steve (Uhhhhhh) dance and press Record: it plays on Steve and captures his animation + the sounds. 2) Press Play on Stand / Clone / Both. They keep dancing even when you do something else.", 11, Enum.TextXAlignment.Left)
		do
			local all = X.scanDances()
			local danceNames = {}
			for _, n in ipairs(all) do
				if not string.find(n, "^%[Stand%]") then danceNames[#danceNames + 1] = n end
			end
			if #danceNames == 0 then danceNames[1] = "(none found - use Record Manual)" end
			X.RecDanceName = X.RecDanceName or danceNames[1]
			local dd = Util_CreateDropdown(parent, "Steve Dance To Record", danceNames, 1)
			if dd and dd.Changed then
				dd.Changed:Connect(function(val)
					X.RecDanceName = X.cleanLabel(type(val) == "number" and danceNames[val] or tostring(val))
				end)
			end
		end
		onChanged(Util_CreateSlider(parent, "Record Length (sec)", m.OwnDanceRecSecs, 2, 60, 1), function(v) m.OwnDanceRecSecs = v end)
		onActivated(Util_CreateButton(parent, "RECORD selected Steve dance (anim + sounds)", 14), function()
			local nm = X.RecDanceName
			if not nm or string.find(nm, "^%(none") then warn("[HatStand] no dance selected") return end
			X.startDanceRec(nm, m.OwnDanceRecSecs, nm)
		end)
		onActivated(Util_CreateButton(parent, "RECORD manual (start any dance yourself, then Stop)", 12), function()
			X.startDanceRec("", 60, nil)
		end)
		onActivated(Util_CreateButton(parent, "STOP + SAVE recording", 12), function() X.finishDanceRec() end)
		onActivated(Util_CreateButton(parent, "Next recording (prints name in console)", 12), function() X.cycleDanceRec() end)
		onActivated(Util_CreateButton(parent, "PLAY on Stand", 14), function() X.playOwnDance("Stand") end)
		onActivated(Util_CreateButton(parent, "PLAY on Clone", 14), function() X.playOwnDance("Clone") end)
		onActivated(Util_CreateButton(parent, "PLAY on Stand + Clone", 14), function() X.playOwnDance("Both") end)
		onActivated(Util_CreateButton(parent, "STOP own dance (Stand + Clone)", 12), function() X.stopOwnDance("Both") end)
		onChanged(Util_CreateSwitch(parent, "Own Dance Loop", m.OwnDanceLoop), function(v) m.OwnDanceLoop = v end)
		onChanged(Util_CreateSwitch(parent, "Own Dance Play Sounds", m.OwnDanceSounds), function(v) m.OwnDanceSounds = v end)
		onChanged(Util_CreateSlider(parent, "Own Dance Speed", m.OwnDanceSpeed, 0.25, 3, 0.05), function(v) m.OwnDanceSpeed = v end)
		onChanged(Util_CreateSlider(parent, "Own Dance Blend", m.OwnDanceBlend, 8, 60, 1), function(v) m.OwnDanceBlend = v end)
		onActivated(Util_CreateButton(parent, "Delete selected recording", 12), function() X.deleteDanceRec() end)
		onActivated(Util_CreateButton(parent, "Print recordings (console)", 12), function()
			warn("[HatStand] recordings: " .. table.concat(X.danceRecNames(), ", ") .. "  | selected: " .. tostring(X.OwnPick))
		end)


		Util_CreateSeparator(parent)
		Util_CreateText(parent, "── WALK / DANCE / BALLER ──", 14, Enum.TextXAlignment.Center)
		onChanged(Util_CreateSwitch(parent, "Walk With Me", m.WalkWithMe), function(v) m.WalkWithMe = v end)
		onChanged(Util_CreateSwitch(parent, "Dance Sync (detect emote)", m.DanceSync), function(v) m.DanceSync = v end)
		onChanged(Util_CreateSwitch(parent, "H Key = Force Dance", m.DanceKey), function(v) m.DanceKey = v end)
		onChanged(Util_CreateSwitch(parent, "Baller Mode", m.BallerMode), function(v) m.BallerMode = v end)
		onChanged(Util_CreateSwitch(parent, "Big Rig Fix (correct limb pose)", m.BigRigFix), function(v)
			m.BigRigFix = v
			X.refreshAllLimbOffsets()
			NeedRebuild = true
		end)
		onChanged(Util_CreateSwitch(parent, "Fix Rig Stand Rot & Pose (Any Rigs)", m.FixAnyRigPose), function(v)
			m.FixAnyRigPose = v
			X.refreshAllLimbOffsets()
			NeedRebuild = true
		end)
		onChanged(Util_CreateSwitch(parent, "Dance Mirror Character", m.DanceMirrorCharacter), function(v)
			m.DanceMirrorCharacter = v
		end)
		onChanged(Util_CreateSlider(parent, "BigRig Arm Spread", m.BigRigArmSpread, 0.8, 3, 0.05), function(v)
			m.BigRigArmSpread = v X.refreshAllLimbOffsets()
		end)
		onChanged(Util_CreateSlider(parent, "BigRig Leg Spread", m.BigRigLegSpread, 0.2, 1.5, 0.05), function(v)
			m.BigRigLegSpread = v X.refreshAllLimbOffsets()
		end)
		onChanged(Util_CreateSlider(parent, "BigRig Height Scale", m.BigRigHeight, 0.5, 2, 0.05), function(v)
			m.BigRigHeight = v X.refreshAllLimbOffsets()
		end)
		onChanged(Util_CreateSlider(parent, "Walk Side Offset", m.WalkSideOffset, -8, 8, 0.25), function(v) m.WalkSideOffset = v end)
		onChanged(Util_CreateSlider(parent, "Walk Forward Offset", m.WalkForwardOffset, -8, 8, 0.25), function(v) m.WalkForwardOffset = v end)
		onChanged(Util_CreateSlider(parent, "Walk Height Offset", m.WalkHeightOffset, -5, 8, 0.25), function(v) m.WalkHeightOffset = v end)
		onChanged(Util_CreateSlider(parent, "Walk Follow Smooth", m.WalkSmoothness, 5, 40, 1), function(v) m.WalkSmoothness = v end)
		onChanged(Util_CreateSlider(parent, "Walk Strength", m.WalkStrength, 0, 2, 0.05), function(v) m.WalkStrength = v end)
		onChanged(Util_CreateSlider(parent, "Run Strength", m.RunStrength, 0, 2, 0.05), function(v) m.RunStrength = v end)
		onChanged(Util_CreateSlider(parent, "Jump Strength", m.JumpStrength, 0, 2, 0.05), function(v) m.JumpStrength = v end)
		onChanged(Util_CreateSlider(parent, "Walk Cycle Speed", m.WalkCycleSpeed, 2, 16, 0.25), function(v) m.WalkCycleSpeed = v end)
		onChanged(Util_CreateSlider(parent, "Run Cycle Speed", m.RunCycleSpeed, 4, 20, 0.25), function(v) m.RunCycleSpeed = v end)
		onChanged(Util_CreateSlider(parent, "Run Speed Threshold", m.RunThreshold, 6, 30, 1), function(v) m.RunThreshold = v end)
		onChanged(Util_CreateSlider(parent, "Dance Strength", m.DanceStrength, 0, 2, 0.05), function(v) m.DanceStrength = v end)

		Util_CreateSeparator(parent)
		Util_CreateText(parent, "── STAND ──", 14, Enum.TextXAlignment.Center)
		onChanged(Util_CreateSwitch(parent, "Auto Limb Catalog Hats", m.AutoLimbHats), function(v)
			m.AutoLimbHats = v NeedRebuild = true
		end)
		onChanged(Util_CreateSwitch(parent, "Auto Spare Hats (fill empty limbs)", m.AutoSpareHats), function(v)
			m.AutoSpareHats = v NeedRebuild = true
		end)
		onChanged(Util_CreateSwitch(parent, "Allow Used Hats (risky)", m.AllowUsedHats), function(v)
			m.AllowUsedHats = v NeedRebuild = true
		end)
		onChanged(Util_CreateSwitch(parent, "Auto Build", m.AutoBuild), function(v) m.AutoBuild = v end)
		onChanged(Util_CreateSwitch(parent, "Keybinds (see bottom)", m.Keybinds), function(v) m.Keybinds = v end)
		onChanged(Util_CreateSwitch(parent, "Show Hat Names", m.ShowHatNames), function(v)
			m.ShowHatNames = v NeedRebuild = true
		end)
		onChanged(Util_CreateSwitch(parent, "Auto Correct Place", m.AutoCorrect), function(v) m.AutoCorrect = v end)
		onActivated(Util_CreateButton(parent, "Build / Rebuild Stand", 14), function() X.buildStand() end)
		onActivated(Util_CreateButton(parent, "Destroy Stand", 12), function() X.destroyStand() end)
		onActivated(Util_CreateButton(parent, "Reset Limb Rotations", 12), function() X.resetLimbRots() end)
		onActivated(Util_CreateButton(parent, "Reset Limb Offsets", 12), function() X.resetLimbOffsets() end)
		onActivated(Util_CreateButton(parent, "Apply Perfect Big Rig Pose", 14), function()
			m.BigRigFix = true
			m.FixAnyRigPose = true
			X.resetLimbRots()
			X.resetLimbOffsets()
			X.refreshAllLimbOffsets()
			NeedRebuild = true
			pcall(X.buildStand)
			warn("[HatStand] Perfect pose applied (BigRig + AnyRig) — toggle off to disable")
		end)

		local idleDD = Util_CreateDropdown(parent, "Idle Style", m.IdleStyleNames, m.IdleStyle)
		if idleDD and idleDD.Changed then
			idleDD.Changed:Connect(function(val)
				if type(val) == "number" then m.IdleStyle = val
				elseif type(val) == "string" then
					for i, n in ipairs(m.IdleStyleNames) do
						if n == val then m.IdleStyle = i break end
					end
				end
			end)
		end

		local standNames = X.dropdownNamesStand()
		local function limbDD(label, key)
			local start = 1
			for i, n in ipairs(standNames) do
				if m[key] ~= "" and string.find(string.lower(n), string.lower(m[key]), 1, true) then
					start = i break
				end
			end
			local dd = Util_CreateDropdown(parent, label, standNames, start)
			if dd and dd.Changed then
				dd.Changed:Connect(function(val)
					m[key] = X.cleanLabel(type(val) == "number" and standNames[val] or tostring(val))
					NeedRebuild = true
				end)
			end
		end
		limbDD("Head", "HatHead")
		limbDD("Torso", "HatTorso")
		limbDD("Left Arm", "HatLeftArm")
		limbDD("Right Arm", "HatRightArm")
		limbDD("Left Leg", "HatLeftLeg")
		limbDD("Right Leg", "HatRightLeg")

		Util_CreateText(parent, "LIMB ROTATION (saved)", 13, Enum.TextXAlignment.Left)
		local function rotSliders(label, limb)
			local keys = LIMB_ROT_KEYS[limb]
			if not keys then return end
			Util_CreateText(parent, label, 12, Enum.TextXAlignment.Left)
			onChanged(Util_CreateSlider(parent, label .. " X", m[keys[1]], -180, 180, 1), function(v)
				m[keys[1]] = v X.refreshAllLimbOffsets() X.updateLimbPreview()
			end)
			onChanged(Util_CreateSlider(parent, label .. " Y", m[keys[2]], -180, 180, 1), function(v)
				m[keys[2]] = v X.refreshAllLimbOffsets() X.updateLimbPreview()
			end)
			onChanged(Util_CreateSlider(parent, label .. " Z", m[keys[3]], -180, 180, 1), function(v)
				m[keys[3]] = v X.refreshAllLimbOffsets() X.updateLimbPreview()
			end)
		end
		rotSliders("Head", "Head")
		rotSliders("Torso", "Torso")
		rotSliders("Left Arm", "LeftArm")
		rotSliders("Right Arm", "RightArm")
		rotSliders("Left Leg", "LeftLeg")
		rotSliders("Right Leg", "RightLeg")

		Util_CreateText(parent, "LIMB POSITION OFFSET (side / up / forward)", 13, Enum.TextXAlignment.Left)
		Util_CreateText(parent, "Move each limb up, down, or to the side independently", 11, Enum.TextXAlignment.Left)
		local function offSliders(label, limb)
			local keys = LIMB_OFF_KEYS[limb]
			if not keys then return end
			Util_CreateText(parent, label .. " Offset", 12, Enum.TextXAlignment.Left)
			onChanged(Util_CreateSlider(parent, label .. " Side (X)", m[keys[1]], -5, 5, 0.05), function(v)
				m[keys[1]] = v X.refreshAllLimbOffsets() X.updateLimbPreview()
			end)
			onChanged(Util_CreateSlider(parent, label .. " Up (Y)", m[keys[2]], -5, 5, 0.05), function(v)
				m[keys[2]] = v X.refreshAllLimbOffsets() X.updateLimbPreview()
			end)
			onChanged(Util_CreateSlider(parent, label .. " Forward (Z)", m[keys[3]], -5, 5, 0.05), function(v)
				m[keys[3]] = v X.refreshAllLimbOffsets() X.updateLimbPreview()
			end)
		end
		offSliders("Head", "Head")
		offSliders("Torso", "Torso")
		offSliders("Left Arm", "LeftArm")
		offSliders("Right Arm", "RightArm")
		offSliders("Left Leg", "LeftLeg")
		offSliders("Right Leg", "RightLeg")
		onActivated(Util_CreateButton(parent, "Reset Limb Offsets", 12), function()
			X.resetLimbOffsets()
		end)
		onChanged(Util_CreateSwitch(parent, "Show Limb Layout Preview", m.ShowLimbPreview), function(v)
			m.ShowLimbPreview = v
			if v then X.updateLimbPreview() else X.clearLimbPreview() end
		end)

		local methodDD = Util_CreateDropdown(parent, "Stand Mode (Walk OFF)", m.MethodNames, m.MethodIndex)
		if methodDD and methodDD.Changed then
			methodDD.Changed:Connect(function(val)
				if type(val) == "number" then m.MethodIndex = val
				elseif type(val) == "string" then
					for i, n in ipairs(m.MethodNames) do
						if n == val then m.MethodIndex = i break end
					end
				end
			end)
		end
		onChanged(Util_CreateSlider(parent, "Side Offset", m.SideOffset, -15, 15, 0.5), function(v) m.SideOffset = v end)
		onChanged(Util_CreateSlider(parent, "Forward Offset", m.ForwardOffset, -15, 15, 0.5), function(v) m.ForwardOffset = v end)
		onChanged(Util_CreateSlider(parent, "Height Offset", m.HeightOffset, -10, 10, 0.5), function(v) m.HeightOffset = v end)
		onChanged(Util_CreateSlider(parent, "Follow Smoothness", m.Smoothness, 5, 90, 1), function(v) m.Smoothness = v end)
		onChanged(Util_CreateSlider(parent, "Auto Correct Dist", m.AutoCorrectDist, 5, 80, 1), function(v) m.AutoCorrectDist = v end)
		onChanged(Util_CreateSlider(parent, "Stand Scale", m.StandScale, 0.4, 2.5, 0.05), function(v)
			m.StandScale = v X.refreshAllLimbOffsets()
		end)
		onChanged(Util_CreateSwitch(parent, "Face Same Way", m.FaceSameWay), function(v) m.FaceSameWay = v end)

		-- PLACE
		Util_CreateSeparator(parent)
		Util_CreateSeparator(parent)
		local movesetNames = X.scanWorkspaceMovesets()
		if #movesetNames == 0 then movesetNames = { "(none)" } end
		local mdd = Util_CreateDropdown(parent, "Other Moveset", movesetNames, 1)
		if mdd and mdd.Changed then
			mdd.Changed:Connect(function(val)
				if type(val) == "number" then m.SelectedOtherMoveset = movesetNames[val] or ""
				elseif type(val) == "string" then m.SelectedOtherMoveset = val end
			end)
		end
		onActivated(Util_CreateButton(parent, "Apply Moveset (keep stand)", 14), function()
			m.UseWithOtherMovesets = true
			X.refreshState()
			X.findAndClickMoveset(m.SelectedOtherMoveset ~= "" and m.SelectedOtherMoveset or movesetNames[1])
		end)

		end)
		if not okUI then
			warn("[HatStand] Config UI error: " .. tostring(errUI))
			pcall(function()
				Util_CreateText(parent, "CONFIG ERROR: " .. tostring(errUI), 12, Enum.TextXAlignment.Left)
			end)
		end
	end


	-- SAVE_KEYS + Load/SaveConfig in nested fn to avoid 200-local limit on outer function
	do
	function X._hsSetupSave()
		local SAVE_KEYS = {
			"Enabled", "UseWithOtherMovesets", "FEMode", "ActiveMode", "StandInOrbitMode",
			"SideOffset", "ForwardOffset", "HeightOffset",
			"Smoothness", "FaceSameWay", "OrbitStand", "AutoBuild", "AutoLimbHats", "AutoSpareHats", "AllowUsedHats",
			"Keybinds", "StandScale", "AnimSpeed", "ShowHatNames", "IdleStyle", "MethodIndex",
			"HatHead", "HatTorso", "HatLeftArm", "HatRightArm", "HatLeftLeg", "HatRightLeg",
			"SelectedOtherMoveset",
			"RotHeadX", "RotHeadY", "RotHeadZ",
			"RotTorsoX", "RotTorsoY", "RotTorsoZ",
			"RotLeftArmX", "RotLeftArmY", "RotLeftArmZ",
			"RotRightArmX", "RotRightArmY", "RotRightArmZ",
			"RotLeftLegX", "RotLeftLegY", "RotLeftLegZ",
			"RotRightLegX", "RotRightLegY", "RotRightLegZ",
			"OffHeadX", "OffHeadY", "OffHeadZ",
			"OffTorsoX", "OffTorsoY", "OffTorsoZ",
			"OffLeftArmX", "OffLeftArmY", "OffLeftArmZ",
			"OffRightArmX", "OffRightArmY", "OffRightArmZ",
			"OffLeftLegX", "OffLeftLegY", "OffLeftLegZ",
			"OffRightLegX", "OffRightLegY", "OffRightLegZ",
			"ShowLimbPreview",
			"AutoCorrect", "AutoCorrectDist",
			"WalkWithMe", "WalkSideOffset", "WalkForwardOffset", "WalkHeightOffset", "WalkSmoothness",
			"WalkStrength", "RunStrength", "JumpStrength", "WalkCycleSpeed", "RunCycleSpeed", "RunThreshold",
			"DanceSync", "DanceStrength", "DanceKey", "BallerMode",
			"BigRigFix", "BigRigArmSpread", "BigRigLegSpread", "BigRigHeight", "FixAnyRigPose", "DanceMirrorCharacter",
			"PlaceEnabled", "PlacePreviewOn", "PlaceSpin", "PlaceSpinSpeed",
			"PlaceBob", "PlaceBobSpeed", "PlaceBobHeight", "PlaceSnapGrid", "PlaceMax",
			"PlaceActiveSlot", "PlaceBuildAnim", "PlaceBuildAnimSpeed", "PlacePersist", "PlaceLock",
			"PlaceCustomAnim", "PlaceYeetForce", "PlaceYeetUp",
			"PlaceSolid", "BToolsMode", "BToolsScale", "BToolsSpacing", "BToolsPreviewAll", "BToolsClickBuild",
			"OrbitEnabled", "OrbitRad", "OrbitSpd", "OrbitH", "OrbitFaceOut", "OrbitSpinSelf", "OrbitSpinSelfSpd",
			"OrbitMode", "OrbitVertical", "OrbitVertAmp", "OrbitVertSpd", "OrbitFinalePulse", "OrbitFinalePulseAmt", "OrbitFinalePulseSpd", "OrbitAutoRebuild",
			"GasterEnabled", "GasterHat", "GasterSide", "GasterHeight", "GasterForward",
			"GasterSize", "GasterLaserLength", "GasterLaserThick", "GasterCooldown", "GasterChargeTime", "GasterPush",
			"GasterUseHatBullet", "GasterHatBullet", "GasterTrailOsc", "GasterTrailOscSpeed", "GasterTrailOscDist", "GasterTrailOscTime",
			"GasterSFX", "GasterSFXId", "GasterFireSFXId", "GasterVolume",
			"WeaponAntiSnap", "WeaponTrackMouse", "WeaponTrackMode", "WeaponTrackStrength", "WeaponTrackSmooth", "WeaponTrackPitch", "WeaponTrackHold",
			"WeaponAimMouse", "WeaponAutoFire", "WeaponMuzzleFlash", "WeaponRecoil", "WeaponRecoilSpeed", "WeaponBobAmt", "WeaponBobSpeed",
			"WeaponFireMode", "UndergroundStash", "StashDepth", "StashRise", "StashHold", "WeaponBlasterScale", "WeaponBlasterCharge", "WeaponLaserLength", "WeaponLaserTime",
			"WeaponRealHat", "WeaponBulletSize", "WeaponBulletR", "WeaponBulletG", "WeaponBulletB", "WeaponBulletSpin",
			"WeaponHoming", "WeaponGravity", "WeaponBurst", "WeaponSpread", "WeaponStopOnHit", "WeaponHitFX", "WeaponReturnSpeed",
			"WeaponTrail", "WeaponRainbow", "WeaponTrailLife", "WeaponTrailWidth", "WeaponTrailR", "WeaponTrailG", "WeaponTrailB",
			"WeaponMaxBurst", "WeaponSFX", "WeaponFireSFXId", "WeaponHitSFXId", "WeaponVolume",
			"WeaponEnabled", "WeaponActiveSlot", "WeaponFloatSide", "WeaponFloatHeight", "WeaponFloatForward",
			"WeaponRotX", "WeaponRotY", "WeaponRotZ", "WeaponFireSpeed", "WeaponFireCooldown", "WeaponBulletLife",
			"ShieldEnabled", "ShieldHat", "ShieldMode", "ShieldSide", "ShieldHeight", "ShieldForward",
			"ShieldRotX", "ShieldRotY", "ShieldRotZ", "ShieldScale",
			"ShieldAutoFace", "ShieldBob", "ShieldBobSpeed", "ShieldBobAmt", "ShieldSpin", "ShieldSpinSpeed", "ShieldUnderground",
			"ShieldStashDepth", "ShieldStashRise", "ShieldStashHold",
			"KeyGaster", "KeyGasterCycle", "KeyBone", "KeyOmega", "KeyShield", "KeyShieldPlace", "KeySans",
			"ClawsEnabled", "ClawsLeftHat", "ClawsRightHat", "ClawsHeadHat", "ClawsScale", "ClawsSide", "ClawsHeight", "ClawsForward",
			"ClawsRotX", "ClawsRotY", "ClawsRotZ",
			"ClawsLeftOffX", "ClawsLeftOffY", "ClawsLeftOffZ", "ClawsLeftRotX", "ClawsLeftRotY", "ClawsLeftRotZ",
			"ClawsRightOffX", "ClawsRightOffY", "ClawsRightOffZ", "ClawsRightRotX", "ClawsRightRotY", "ClawsRightRotZ",
			"ClawsHeadOffX", "ClawsHeadOffY", "ClawsHeadOffZ", "ClawsHeadRotX", "ClawsHeadRotY", "ClawsHeadRotZ",
			"ClawsIdleBob", "ClawsBobSpeed", "ClawsBobAmt",
			"ClawsComboCooldown", "ClawsPushCooldown", "ClawsSpinCooldown", "ClawsComboRange",
			"ClawsPushForce", "ClawsPushUp", "ClawsSpinSpeed", "ClawsSpinDuration", "ClawsSpinRadius",
			"ClawsTrackMouse", "ClawsBloodTrail", "ClawsSFX", "ClawsSlashSFXId", "ClawsPushSFXId", "ClawsSpinSFXId", "ClawsVolume",
			"KeyClawsCombo", "KeyClawsPush", "KeyClawsSpin",
			"ClawsAnims", "ClawsAnimStrength", "ClawsAnimBlend", "ClawsKeysEnabled", "KeyClawsKeysToggle", "KeyClawsTrackToggle", "KeyClawsRage",
			"KeyClawsLaser", "KeyClawsSlam", "ClawsRage", "ClawsRageMul", "ClawsLaserUseHat", "ClawsLaserHat", "ClawsLaserDual", "ClawsLaserAim",
			"ClawsLaserCooldown", "ClawsLaserCharge", "ClawsLaserLength", "ClawsLaserThick", "ClawsLaserR", "ClawsLaserG", "ClawsLaserB",
			"ClawsLaserBulletSpeed", "ClawsLaserBulletSpin", "ClawsLaserTrail", "ClawsLaserTrailOsc", "ClawsLaserTrailOscDist",
			"ClawsLaserTrailOscSpeed", "ClawsLaserTrailOscTime", "ClawsSlamCooldown", "ClawsSlamRadius",
			"PlaceUndergroundOnSelect", "PlaceUndergroundDepth", "PlaceUndergroundSpeed", "PlaceStayAfterRespawn",
			"CarEnabled", "CarRide", "CarSpeedBoost", "CarSide", "CarHeight", "CarForward", "CarRotY", "CarSmooth",
			"AutoRefresh", "AutoRefreshInterval",
			"SelectFirst", "LinkRigs", "LinkStrength", "LinkSmooth", "LinkSource", "StrictHats", "StandMoveset", "ProcDance",
			"SelectedDance", "JojoLoco", "LocoBlend", "LocoLean", "LocoBob", "LocoArmOut", "FallSpread", "LandSquash",
			"SansUnderground", "SansStashDepth", "SansStashRise", "SansStashHold",
			"OmegaRotX", "OmegaRotY", "OmegaRotZ", "OmegaTrackOnlyFire",
			"OmegaStashDepth", "OmegaStashRise", "OmegaStashHold",
			"OmegaRiseBeforeFire", "OmegaKeepUpWhileCharge",
			"OmegaUseHatBullet", "OmegaBulletHat", "OmegaBulletHat2", "OmegaBulletSpeed", "OmegaBulletSpin", "OmegaBulletTrail",
			"CloneEnabled", "CloneSide", "CloneForward", "CloneHeight", "CloneSmooth", "CloneFaceSame", "CloneAutoHats",
			"CloneHatHead", "CloneHatTorso", "CloneHatLeftArm", "CloneHatRightArm", "CloneHatLeftLeg", "CloneHatRightLeg",
			"CloneRotHeadX", "CloneRotHeadY", "CloneRotHeadZ",
			"CloneRotTorsoX", "CloneRotTorsoY", "CloneRotTorsoZ",
			"CloneRotLeftArmX", "CloneRotLeftArmY", "CloneRotLeftArmZ",
			"CloneRotRightArmX", "CloneRotRightArmY", "CloneRotRightArmZ",
			"CloneRotLeftLegX", "CloneRotLeftLegY", "CloneRotLeftLegZ",
			"CloneRotRightLegX", "CloneRotRightLegY", "CloneRotRightLegZ",
			"CloneOffHeadX", "CloneOffHeadY", "CloneOffHeadZ",
			"CloneOffTorsoX", "CloneOffTorsoY", "CloneOffTorsoZ",
			"CloneOffLeftArmX", "CloneOffLeftArmY", "CloneOffLeftArmZ",
			"CloneOffRightArmX", "CloneOffRightArmY", "CloneOffRightArmZ",
			"CloneOffLeftLegX", "CloneOffLeftLegY", "CloneOffLeftLegZ",
			"CloneOffRightLegX", "CloneOffRightLegY", "CloneOffRightLegZ",
		}
		for i = 1, 10 do
			table.insert(SAVE_KEYS, "PlaceHat" .. i)
			table.insert(SAVE_KEYS, "PlaceRot" .. i .. "X")
			table.insert(SAVE_KEYS, "PlaceRot" .. i .. "Y")
			table.insert(SAVE_KEYS, "PlaceRot" .. i .. "Z")
			table.insert(SAVE_KEYS, "PlaceOff" .. i .. "X")
			table.insert(SAVE_KEYS, "PlaceOff" .. i .. "Y")
			table.insert(SAVE_KEYS, "PlaceOff" .. i .. "Z")
			table.insert(SAVE_KEYS, "OrbitHat" .. i)
			table.insert(SAVE_KEYS, "OrbitSpdMult" .. i)
			table.insert(SAVE_KEYS, "OrbitRadOff" .. i)
			table.insert(SAVE_KEYS, "OrbitRotX" .. i)
			table.insert(SAVE_KEYS, "OrbitRotY" .. i)
			table.insert(SAVE_KEYS, "OrbitRotZ" .. i)
			table.insert(SAVE_KEYS, "OrbitVertOff" .. i)
			table.insert(SAVE_KEYS, "CloneSlotHat" .. i)
			table.insert(SAVE_KEYS, "CloneSlotOffX" .. i)
			table.insert(SAVE_KEYS, "CloneSlotOffY" .. i)
			table.insert(SAVE_KEYS, "CloneSlotOffZ" .. i)
			table.insert(SAVE_KEYS, "CloneSlotRotX" .. i)
			table.insert(SAVE_KEYS, "CloneSlotRotY" .. i)
			table.insert(SAVE_KEYS, "CloneSlotRotZ" .. i)
			table.insert(SAVE_KEYS, "CloneSlotKind" .. i)
		end
		for i = 11, 15 do
			for _, f in ipairs({ "Hat", "OffX", "OffY", "OffZ", "RotX", "RotY", "RotZ", "Kind" }) do
				table.insert(SAVE_KEYS, "CloneSlot" .. f .. i)
			end
		end
		for _, k in ipairs({
			"StopOnExit", "OwnDanceSpeed", "OwnDanceLoop", "OwnDanceSounds", "OwnDanceBlend", "OwnDanceRecSecs", "LowLag", "LowLagSkip",
			"HeliEnabled", "HeliAutoStart", "HeliPhysics", "HeliHoverAssist", "HeliAutoRebuild", "HeliSide", "HeliHeight",
			"HeliForward", "HeliRotY", "HeliSeatOffY", "HeliSmooth", "HeliMaxSpeed", "HeliClimb", "HeliYawRate", "HeliAccel",
			"HeliTilt", "HeliSpoolUp", "HeliSpoolDown", "HeliGravity", "HeliCamLock", "HeliCamSmooth", "HeliSFX", "HeliVolume", "HeliPitch", "HeliEngineMode", "HeliMiniSFX", "HeliMiniVolume",
			"KeyHeliRide", "KeyHeliEngine", "KeyHeliFire", "HeliFireStyle", "HeliBulletSpeed", "HeliBulletRange", "HeliCooldown",
			"HeliSpread", "HeliBulletSpin", "HeliTrail", "HeliBulletFallback", "HeliAimMouse", "HeliFireSFX",
			"HeliBulletRotX", "HeliBulletRotY", "HeliBulletRotZ",
			"HeliAimAssist", "HeliAimAssistRadius", "HeliSolid", "HeliSolidFrames", "HeliSolidProps", "HeliSolidWpns", "HeliSolidPush", "HeliSolidIgnorePlayers", "HeliSolidBoost",
			"HatsSolid", "HatsSolidPush", "HatsSolidIgnorePlayers", "HatsSolidBoost",
		}) do
			table.insert(SAVE_KEYS, k)
		end
		for i = 1, 12 do
			table.insert(SAVE_KEYS, "HeliFrameHat" .. i)
			for _, f in ipairs({ "OffX", "OffY", "OffZ", "RotX", "RotY", "RotZ" }) do table.insert(SAVE_KEYS, "HeliFrame" .. f .. i) end
		end
		for i = 1, 4 do
			table.insert(SAVE_KEYS, "HeliPropHat" .. i)
			table.insert(SAVE_KEYS, "HeliPropAxis" .. i)
			table.insert(SAVE_KEYS, "HeliPropSpd" .. i)
			table.insert(SAVE_KEYS, "HeliWpnHat" .. i)
			table.insert(SAVE_KEYS, "HeliWpnBullet" .. i)
			table.insert(SAVE_KEYS, "HeliWpnBullet2" .. i)
			table.insert(SAVE_KEYS, "HeliWpnFire" .. i)
			for _, f in ipairs({ "OffX", "OffY", "OffZ", "RotX", "RotY", "RotZ" }) do
				table.insert(SAVE_KEYS, "HeliProp" .. f .. i)
				table.insert(SAVE_KEYS, "HeliWpn" .. f .. i)
			end
		end
		for i = 1, 10 do
			table.insert(SAVE_KEYS, "WeaponRot" .. i .. "X")
			table.insert(SAVE_KEYS, "WeaponRot" .. i .. "Y")
			table.insert(SAVE_KEYS, "WeaponRot" .. i .. "Z")
			table.insert(SAVE_KEYS, "WeaponHat" .. i)
			table.insert(SAVE_KEYS, "WeaponBulletHat" .. i)
			table.insert(SAVE_KEYS, "WeaponFire" .. i)
			table.insert(SAVE_KEYS, "WeaponBullet" .. i)
			table.insert(SAVE_KEYS, "WeaponOffsetX" .. i)
			table.insert(SAVE_KEYS, "WeaponOffsetY" .. i)
			table.insert(SAVE_KEYS, "WeaponOffsetZ" .. i)
			table.insert(SAVE_KEYS, "WeaponBurst" .. i)
			table.insert(SAVE_KEYS, "WeaponHatBulletCount" .. i)
		end
		for i = 1, 8 do
			table.insert(SAVE_KEYS, "CarHat" .. i)
			table.insert(SAVE_KEYS, "CarOffX" .. i)
			table.insert(SAVE_KEYS, "CarOffY" .. i)
			table.insert(SAVE_KEYS, "CarOffZ" .. i)
			table.insert(SAVE_KEYS, "CarRotX" .. i)
			table.insert(SAVE_KEYS, "CarRotY" .. i)
			table.insert(SAVE_KEYS, "CarRotZ" .. i)
		end

		-- save EVERYTHING that is a plain setting (every hat slot, bullet hat, position, key, slider...)
		do
			local have = {}
			for _, k in ipairs(SAVE_KEYS) do have[k] = true end
			local skip = { Name = true, Description = true, InternalName = true, ModuleType = true }
			for k, v in pairs(m) do
				local t = type(v)
				if type(k) == "string" and not have[k] and not skip[k] and (t == "string" or t == "number" or t == "boolean") then
					have[k] = true
					table.insert(SAVE_KEYS, k)
				end
			end
		end

		-- rebuild every enabled attack so loaded hats are actually picked up
		X.rebuildEnabled = function()
			pcall(X.refreshAllHats)
			if m.GasterEnabled then pcall(X.rebuildGaster) end
			if m.BoneEnabled then pcall(X.rebuildBone) end
			if m.OmegaEnabled then pcall(X.rebuildOmega) end
			if m.WeaponEnabled then pcall(X.rebuildWeapon) end
			if m.ShieldEnabled then pcall(X.rebuildShield) end
			if m.ClawsEnabled then pcall(rebuildClaws) end
			if m.CarEnabled then pcall(X.rebuildCar) end
			if m.PlanetEnabled then pcall(X.rebuildPlanet) end
			if m.MotoEnabled then pcall(X.rebuildMoto) end
			if m.ToolEnabled then pcall(X.rebuildTool) end
			if m.PlaneEnabled then pcall(X.rebuildPlane) end
			if m.HeliEnabled then pcall(X.rebuildHeli) end
			if m.TitanEnabled then pcall(X.rebuildTitan) end
		end

		-- backup: hat choices are also written to a local file (when the executor has writefile/readfile)
		local HAT_FILE = "HatStand_Hats" .. SUF .. ".json"
		X.hatKeys = function()
			local out = {}
			for _, k in ipairs(SAVE_KEYS) do
				if type(m[k]) == "string" and string.find(k, "Hat", 1, true) then table.insert(out, k) end
			end
			return out
		end
		X.loadHatFile = function()
			if type(readfile) ~= "function" or type(isfile) ~= "function" then return end
			local ok, data = pcall(function()
				if isfile(HAT_FILE) then return game:GetService("HttpService"):JSONDecode(readfile(HAT_FILE)) end
			end)
			if ok and type(data) == "table" then
				for _, k in ipairs(X.hatKeys()) do
					if type(data[k]) == "string" and data[k] ~= "" and (m[k] == nil or m[k] == "") then m[k] = data[k] end
				end
				warn("[HatStand] hat choices restored from " .. HAT_FILE)
			end
		end
		X.startHatAutosave = function()
			if type(writefile) ~= "function" then return end
			local tok = {}
			_G["__HatStandSaveTok" .. SUF] = tok
			task.spawn(function()
				local last = nil
				while _G["__HatStandSaveTok" .. SUF] == tok do
					local ok, json = pcall(function()
						local out = {}
						for _, k in ipairs(X.hatKeys()) do out[k] = m[k] end
						return game:GetService("HttpService"):JSONEncode(out)
					end)
					if ok and json ~= last then
						last = json
						pcall(writefile, HAT_FILE, json)
					end
					task.wait(6)
				end
			end)
		end

		m.LoadConfig = function(save)
			if typeof(save) ~= "table" then return end
			for _, k in ipairs(SAVE_KEYS) do
				if save[k] ~= nil then m[k] = save[k] end
			end
			if cfg.mode ~= 4 then m.ActiveMode = cfg.mode or 1 m.StandInOrbitMode = (cfg.standInOrbit ~= false) end
			X.refreshAllLimbOffsets()
			X.refreshState()
			task.delay(1, function() if m.Enabled then X.rebuildEnabled() end end)
		end

		m.SaveConfig = function()
			local out = {}
			for _, k in ipairs(SAVE_KEYS) do out[k] = m[k] end
			return out
		end
	end
	X._hsSetupSave()
	end

	m.Init = function()
		X.Dead = false
		local ok, err = pcall(function()
			if X.loadHatFile then X.loadHatFile() end
			if X.loadDanceRecs then pcall(X.loadDanceRecs) end
			if X.startHatAutosave then X.startHatAutosave() end
			X.refreshAllHats()
			LastHatFingerprint = X.hatFingerprint()
			X.ensurePlaceFolder()
			X.refreshState()
			task.delay(1.5, function() if m.Enabled and X.rebuildEnabled then X.rebuildEnabled() end end)
			if m.Enabled and X.modeAllowsStand() and m.AutoBuild then task.defer(X.buildStand) end
			if m.Enabled and X.modeAllowsOrbit() and m.OrbitEnabled then task.defer(X.rebuildOrbit) end
		end)
		if not ok then warn("[HatStand] Init error: " .. tostring(err)) end
	end

	m.Update = function(dt)
		if m.Enabled and not X.Dead and not FollowBound then X.stepAll(dt or 1 / 60) end
	end

	m.Destroy = function()
		if m.StopOnExit ~= false or not m.UseWithOtherMovesets then
			X.Dead = true
			pcall(function() _G["__HatStandSaveTok" .. SUF] = nil end)
			pcall(function() X.DanceRec = nil end)
			pcall(function() X.stopOwnDance("Both") end)
			pcall(function() m.HeliRide = false m.HeliEngine = false X.HeliFireHeld = false end)
			X.stopLoop()
			X.destroyStand()
			X.clearOrbit()
			X.clearAllPlaced()
			X.clearGaster()
			X.clearBone()
			X.clearOmega()
			X.clearWeapon()
			X.clearShield()
			clearClaws()
			X.clearCar()
			X.clearBall()
			X.clearPlanet()
			X.clearMoto()
			X.clearTool()
			X.clearPlane()
			X.clearHeli()
			pcall(function() X.clearTitan() end)
			X.clearClone()
			X.clearStructGhosts()
			pcall(function() if X.HeliFolder then X.HeliFolder:Destroy() X.HeliFolder = nil end end)
			pcall(X.releaseHeld, nil)
			pcall(X.clearLabels)
			pcall(X.clearLimbPreview)
		end
	end

	task.defer(function()
		pcall(function()
			X.refreshAllHats()
			LastHatFingerprint = X.hatFingerprint()
			X.ensurePlaceFolder()
			X.refreshState()
		end)
	end)

	return m
end

local cfg = { id = "STAND", mode = 1, suffix = "_Stand", name = "Hat Stand: Stand + Clone", internal = "HAT_STAND_STAND", standInOrbit = false,
	desc = "FE stand + clone rig from spare hats, links to your dances and moveset.",
	title = "Hat Stand: Stand + Clone", subtitle = "FE stand + clone rig from spare hats, links to your dances and moveset.",
	sections = { stand = true } }

table.insert(modules, function()
	return makeHatModule(cfg)
end)

return modules
