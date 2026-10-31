--==============================================================
-- HatOrbit.lua  (STANDALONE: no HatCore.lua needed)
-- Contains only: shared FE hat/collide/claims/save core + the "orbit" feature code.
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
	X.animOffsets = X.animOffsets or function() end
	X.applyBToolsMode = X.applyBToolsMode or function() end
	X.applyBlend = X.applyBlend or function() end
	X.applyRootExtra = X.applyRootExtra or function() end
	X.applyStandCF = X.applyStandCF or function() end
	X.applyTrailProps = X.applyTrailProps or function() end
	X.autoCalib = X.autoCalib or function() end
	X.autoDetectMissileHats = X.autoDetectMissileHats or function() end
	X.ballBase = X.ballBase or function() end
	X.ballerOffsets = X.ballerOffsets or function() end
	X.beam = X.beam or function() end
	X.btoolsAnchor = X.btoolsAnchor or function() end
	X.btoolsExtra = X.btoolsExtra or function() end
	X.btoolsPlan = X.btoolsPlan or function() end
	X.btoolsPreset = X.btoolsPreset or function() end
	X.buildAnimOffsets = X.buildAnimOffsets or function() end
	X.buildClone = X.buildClone or function() end
	X.buildStructure = X.buildStructure or function() end
	X.bulletColor = X.bulletColor or function() end
	X.bulletFolder = X.bulletFolder or function() end
	X.calibrate = X.calibrate or function() end
	X.carry = X.carry or function() end
	X.castRay = X.castRay or function() end
	X.clawsLaserColor = X.clawsLaserColor or function() end
	X.clawsRage = X.clawsRage or function() end
	X.clawsRayParams = X.clawsRayParams or function() end
	X.cleanClone = X.cleanClone or function() end
	X.clearAllPlaced = X.clearAllPlaced or function() end
	X.clearBall = X.clearBall or function() end
	X.clearBone = X.clearBone or function() end
	X.clearCar = X.clearCar or function() end
	X.clearClone = X.clearClone or function() end
	X.clearGaster = X.clearGaster or function() end
	X.clearHeli = X.clearHeli or function() end
	X.clearMoto = X.clearMoto or function() end
	X.clearOmega = X.clearOmega or function() end
	X.clearPlane = X.clearPlane or function() end
	X.clearPlanet = X.clearPlanet or function() end
	X.clearShield = X.clearShield or function() end
	X.clearStructGhosts = X.clearStructGhosts or function() end
	X.clearTitan = X.clearTitan or function() end
	X.clearTool = X.clearTool or function() end
	X.clearWeapon = X.clearWeapon or function() end
	X.clickLabel = X.clickLabel or function() end
	X.combatOffsets = X.combatOffsets or function() end
	X.cycleDanceRec = X.cycleDanceRec or function() end
	X.cycleWeapon = X.cycleWeapon or function() end
	X.danceOffsets = X.danceOffsets or function() end
	X.danceRecNames = X.danceRecNames or function() end
	X.deleteDanceRec = X.deleteDanceRec or function() end
	X.desiredStandCF = X.desiredStandCF or function() end
	X.destroyStand = X.destroyStand or function() end
	X.doFire = X.doFire or function() end
	X.drivePlaneOrdnanceSlot = X.drivePlaneOrdnanceSlot or function() end
	X.ensurePlaneSpeedo = X.ensurePlaneSpeedo or function() end
	X.findAndClickMoveset = X.findAndClickMoveset or function() end
	X.finishDanceRec = X.finishDanceRec or function() end
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
	X.fixArms = X.fixArms or function() end
	X.flash = X.flash or function() end
	X.freezePlacedForRespawn = X.freezePlacedForRespawn or function() end
	X.gasterSlotCF = X.gasterSlotCF or function() end
	X.getActivePlaceHat = X.getActivePlaceHat or function() end
	X.getMouseWorldCF = X.getMouseWorldCF or function() end
	X.getRP = X.getRP or function() end
	X.getSourceRig = X.getSourceRig or function() end
	X.heliAddTrail = X.heliAddTrail or function() end
	X.heliConfigured = X.heliConfigured or function() end
	X.heliEngineUrl = X.heliEngineUrl or function() end
	X.heliGroupCF = X.heliGroupCF or function() end
	X.heliStyleTrail = X.heliStyleTrail or function() end
	X.heliTrailColorSeq = X.heliTrailColorSeq or function() end
	X.hitFX = X.hitFX or function() end
	X.idleOffsets = X.idleOffsets or function() end
	X.initSansStash = X.initSansStash or function() end
	X.jojoJumpOffsets = X.jojoJumpOffsets or function() end
	X.jojoRunOffsets = X.jojoRunOffsets or function() end
	X.jojoWalkOffsets = X.jojoWalkOffsets or function() end
	X.keepPlaced = X.keepPlaced or function() end
	X.launchOmegaBullet = X.launchOmegaBullet or function() end
	X.launchPlaneDrop = X.launchPlaneDrop or function() end
	X.legacyToRoot = X.legacyToRoot or function() end
	X.loadBToolsBuild = X.loadBToolsBuild or function() end
	X.loadDanceRecs = X.loadDanceRecs or function() end
	X.locoAnimOffsets = X.locoAnimOffsets or function() end
	X.locoV2 = X.locoV2 or function() end
	X.makeGhostClone = X.makeGhostClone or function() end
	X.makeTemplate = X.makeTemplate or function() end
	X.msCandidates = X.msCandidates or function() end
	X.msCleanup = X.msCleanup or function() end
	X.msClearLock = X.msClearLock or function() end
	X.msExplode = X.msExplode or function() end
	X.msPick = X.msPick or function() end
	X.newOffsets = X.newOffsets or function() end
	X.omegaBulletKey = X.omegaBulletKey or function() end
	X.omegaHatKey = X.omegaHatKey or function() end
	X.ownDanceSample = X.ownDanceSample or function() end
	X.pickMissileTube = X.pickMissileTube or function() end
	X.pivotExtra = X.pivotExtra or function() end
	X.placeBackNearest = X.placeBackNearest or function() end
	X.placeHatAt = X.placeHatAt or function() end
	X.placeShieldAtMouse = X.placeShieldAtMouse or function() end
	X.planeGunAimDir = X.planeGunAimDir or function() end
	X.planeGunColor = X.planeGunColor or function() end
	X.playAnim = X.playAnim or function() end
	X.playDance = X.playDance or function() end
	X.playOwnDance = X.playOwnDance or function() end
	X.playerIsDancing = X.playerIsDancing or function() end
	X.procDance = X.procDance or function() end
	X.rainbowSeq = X.rainbowSeq or function() end
	X.raisePlaneOrdnance = X.raisePlaneOrdnance or function() end
	X.rawSample = X.rawSample or function() end
	X.rebuildBall = X.rebuildBall or function() end
	X.rebuildBone = X.rebuildBone or function() end
	X.rebuildCar = X.rebuildCar or function() end
	X.rebuildGaster = X.rebuildGaster or function() end
	X.rebuildHeli = X.rebuildHeli or function() end
	X.rebuildMoto = X.rebuildMoto or function() end
	X.rebuildOmega = X.rebuildOmega or function() end
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
	X.resolve = X.resolve or function() end
	X.sampleCharacterLimbOffsets = X.sampleCharacterLimbOffsets or function() end
	X.sampleRig = X.sampleRig or function() end
	X.sansStashOn = X.sansStashOn or function() end
	X.saveBToolsBuild = X.saveBToolsBuild or function() end
	X.saveDanceRecs = X.saveDanceRecs or function() end
	X.scaleClone = X.scaleClone or function() end
	X.scanDances = X.scanDances or function() end
	X.scanWorkspaceMovesets = X.scanWorkspaceMovesets or function() end
	X.setHeliFly = X.setHeliFly or function() end
	X.setPlaneStay = X.setPlaneStay or function() end
	X.setSansUnderground = X.setSansUnderground or function() end
	X.spawnClawsShockwave = X.spawnClawsShockwave or function() end
	X.spawnHeliBullet = X.spawnHeliBullet or function() end
	X.spawnLocked = X.spawnLocked or function() end
	X.spawnPlaneHatBullet = X.spawnPlaneHatBullet or function() end
	X.spawnPlaneNeonBullet = X.spawnPlaneNeonBullet or function() end
	X.standUnit = X.standUnit or function() end
	X.startDanceRec = X.startDanceRec or function() end
	X.stashParams = X.stashParams or function() end
	X.stashShift = X.stashShift or function() end
	X.stepBall = X.stepBall or function() end
	X.stepBone = X.stepBone or function() end
	X.stepBullet = X.stepBullet or function() end
	X.stepCar = X.stepCar or function() end
	X.stepClawsBullet = X.stepClawsBullet or function() end
	X.stepClone = X.stepClone or function() end
	X.stepDanceRec = X.stepDanceRec or function() end
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
	X.stepPlaceAnims = X.stepPlaceAnims or function() end
	X.stepPlaced = X.stepPlaced or function() end
	X.stepPlane = X.stepPlane or function() end
	X.stepPlaneOrdnance = X.stepPlaneOrdnance or function() end
	X.stepPlaneOrdnanceSlot = X.stepPlaneOrdnanceSlot or function() end
	X.stepPlanet = X.stepPlanet or function() end
	X.stepShield = X.stepShield or function() end
	X.stepStand = X.stepStand or function() end
	X.stepTitan = X.stepTitan or function() end
	X.stepTool = X.stepTool or function() end
	X.stepWeapon = X.stepWeapon or function() end
	X.stepYeet = X.stepYeet or function() end
	X.stopOwnDance = X.stopOwnDance or function() end
	X.stripTrails = X.stripTrails or function() end
	X.swingTool = X.swingTool or function() end
	X.syncPlaneOrdnanceFromSettings = X.syncPlaneOrdnanceFromSettings or function() end
	X.targetExtras = X.targetExtras or function() end
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
	X.updateAir = X.updateAir or function() end
	X.updateLocoMode = X.updateLocoMode or function() end
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
	X.clearPlacePreview = function()
		if PlacePreviewPart then
			pcall(function() PlacePreviewPart:Destroy() end)
			PlacePreviewPart = nil
		end
	end

	X.clearOrbit = function()
		local keep = {}
		for handle, held in pairs(Held) do
			if held.Kind and held.Kind ~= "orbit" then keep[handle] = true end
		end
		X.releaseHeld(keep)
		OrbitSlots = {}
	end

	X.rebuildOrbit = function()
		if not X.modeAllowsOrbit() or not m.OrbitEnabled then
			X.clearOrbit()
			return
		end
		X.refreshAllHats()
		local usedHandles = {}
		for handle, held in pairs(Held) do
			if held.Kind == "stand" or held.Kind == "place" or held.Kind == "gaster"
				or held.Kind == "weapon" or held.Kind == "shield" or held.Kind == "car"
				or held.Kind == "clone" then
				usedHandles[handle] = true
			end
		end
		local keep = {}
		for handle, held in pairs(Held) do
			if held.Kind and held.Kind ~= "orbit" then keep[handle] = true end
		end
		local activeCount = 0
		for i = 1, 10 do
			if X.trim(m["OrbitHat" .. i]) ~= "" then activeCount = activeCount + 1 end
		end
		if activeCount == 0 then activeCount = 10 end
		local newSlots, count = {}, 0
		for i, key in ipairs(ORBIT_HAT_KEYS) do
			local hat = X.findHatFromLabel(m[key])
			if hat and hat.Handle and hat.Handle.Parent and not usedHandles[hat.Handle] then
				local held = m.FEMode and X.attachFE(hat, "orbit") or nil
				if held then
					keep[hat.Handle] = true
					usedHandles[hat.Handle] = true
				end
				local part = (held and hat.Handle) or (not m.FEMode and X.cloneHandle(hat.Handle, "Orbit_" .. i))
				if part then
					if not m.FEMode then part.Parent = workspace end
					count = count + 1
					newSlots[i] = {
						Handle = part, Held = held,
						Angle = (i - 1) * (math.pi * 2 / math.max(activeCount, 1)),
						Name = hat.Name, Index = i,
						SpdMult = tonumber(m["OrbitSpdMult" .. i]) or 1,
						RadOff = tonumber(m["OrbitRadOff" .. i]) or 0,
						VertOff = tonumber(m["OrbitVertOff" .. i]) or 0,
						Rot = CFrame.Angles(
							math.rad(tonumber(m["OrbitRotX" .. i]) or 0),
							math.rad(tonumber(m["OrbitRotY" .. i]) or 0),
							math.rad(tonumber(m["OrbitRotZ" .. i]) or 0)
						),
						Seed = (i * 17.13) % 1,
					}
				end
			end
		end
		X.releaseHeld(keep)
		OrbitSlots = newSlots
		NeedOrbitRebuild = false
		warn("[HatStand] orbit=" .. tostring(count) .. " mode=" .. tostring(m.OrbitMode or 1))
	end

	-- EXTRA ORBIT MODES 36-65: returns an offset from the follow root
	function X.orbitExtra(mode, base, slot, t, idx, total, rad, h, vert, ang, spd)
		local pi, pi2 = math.pi, math.pi * 2
		local sin, cos, abs, floor = math.sin, math.cos, math.abs, math.floor
		local V = Vector3.new
		local fr = (idx - 1) / math.max(total - 1, 1)
		local fo = (idx - 1) / math.max(total, 1)
		local seed = slot.Seed or 0.5
		local function polygon(n, a, r, step)
			local u = ((a / pi2) % 1) * n
			local k = floor(u)
			local f = u - k
			local function vtx(i)
				local aa = (i * (step or 1)) * pi2 / n
				return V(cos(aa) * r, 0, sin(aa) * r)
			end
			return vtx(k):Lerp(vtx(k + 1), f)
		end
		local B = {}
		B[36] = function() -- Vertical Figure-8
			return V(sin(ang) * rad, h + sin(ang * 2) * rad * 0.5 + vert, 0)
		end
		B[37] = function() -- Angel Wings (flapping, behind you)
			local side = (idx % 2 == 0) and 1 or -1
			local k = floor((idx - 1) / 2)
			local a = 0.25 + k * 0.32 + sin(t * spd * 2) * 0.25
			return base.RightVector * (side * cos(a) * rad * 0.9) + base.UpVector * (h + sin(a) * rad * 0.9) - base.LookVector * (rad * 0.3)
		end
		B[38] = function() -- Halo
			local r = rad * 0.35
			return V(cos(ang) * r, h + 2.5 + vert * 0.3, sin(ang) * r)
		end
		B[39] = function() -- Saturn Ring (tilted)
			local x, z = cos(ang) * rad, sin(ang) * rad
			return V(x, h + z * 0.4, z * 0.92)
		end
		B[40] = function() -- Atom (3 orbitals)
			local k = idx % 3
			if k == 0 then return V(cos(ang) * rad, h + sin(ang) * rad, 0)
			elseif k == 1 then return V(0, h + sin(ang) * rad, cos(ang) * rad) end
			return V(cos(ang) * rad, h + vert, sin(ang) * rad)
		end
		B[41] = function() -- Gyroscope
			local k = idx % 3
			local rot = CFrame.Angles(t * 0.5 * (k + 1), t * 0.3 * k, k * 1.05)
			local p = rot * V(cos(ang) * rad, 0, sin(ang) * rad)
			return V(p.X, h + p.Y, p.Z)
		end
		B[42] = function() -- Shield Arc (in front of you)
			local a = (fr - 0.5) * 2.1
			return base.LookVector * (cos(a) * rad) + base.RightVector * (sin(a) * rad) + V(0, h + vert * 0.3, 0)
		end
		B[43] = function() -- Cape Arc (behind you)
			local a = (fr - 0.5) * 2.1
			return -base.LookVector * (cos(a) * rad) + base.RightVector * (sin(a) * rad) + V(0, h + vert * 0.3, 0)
		end
		B[44] = function() -- Elevator Ring
			return V(cos(ang) * rad, h - 1 + ((t * spd * 0.8 + idx * 0.4) % 4), sin(ang) * rad)
		end
		B[45] = function() -- Bounce Ring
			return V(cos(ang) * rad, h + abs(sin(t * spd * 2 + idx)) * 2, sin(ang) * rad)
		end
		B[46] = function() -- Square Path
			local p = CFrame.Angles(0, pi / 4, 0) * polygon(4, ang, rad * 1.2)
			return V(p.X, h + vert, p.Z)
		end
		B[47] = function() -- Hexagon Path
			local p = polygon(6, ang, rad)
			return V(p.X, h + vert, p.Z)
		end
		B[48] = function() -- Pentagram Path
			local p = polygon(5, ang, rad * 1.1, 2)
			return V(p.X, h + vert, p.Z)
		end
		B[49] = function() -- Spirograph
			local x = 2 * cos(ang) + 5 * cos(2 * ang / 3)
			local z = 2 * sin(ang) - 5 * sin(2 * ang / 3)
			return V(x * rad / 7, h + vert, z * rad / 7)
		end
		B[50] = function() -- Lissajous
			return V(sin(3 * ang + idx * 0.3) * rad, h + sin(2 * ang) * rad * 0.5 + vert, cos(2 * ang + idx * 0.2) * rad * 0.8)
		end
		B[51] = function() -- Trefoil Knot
			local x = sin(ang) + 2 * sin(2 * ang)
			local y = cos(ang) - 2 * cos(2 * ang)
			local z = -sin(3 * ang)
			local s2 = rad * 0.33
			return V(x * s2, h + y * s2 * 0.8 + vert * 0.3, z * s2)
		end
		B[52] = function() -- Torus Knot
			local r = 2 + cos(3 * ang)
			local s2 = rad / 3
			return V(r * cos(2 * ang) * s2, h + sin(3 * ang) * s2, r * sin(2 * ang) * s2)
		end
		B[53] = function() -- Hourglass Swirl
			local yv = (fr - 0.5) * rad * 1.6
			local r = rad * (0.25 + 0.75 * abs(yv) / (rad * 0.8))
			local a = ang + idx * 1.2
			return V(cos(a) * r, h + yv + vert * 0.3, sin(a) * r)
		end
		B[54] = function() -- Cone
			local r = rad * (1 - fo * 0.85)
			local a = ang + idx * 0.9
			return V(cos(a) * r, h + fo * rad * 1.4, sin(a) * r)
		end
		B[55] = function() -- Funnel
			local r = rad * (0.2 + fo * 0.8)
			local a = ang + idx * 0.9
			return V(cos(a) * r, h + fo * rad * 1.2, sin(a) * r)
		end
		B[56] = function() -- Fountain
			local ph = (t * spd * 0.6 + fo) % 1
			local dir = idx * 2.39996
			local r = rad * ph * 0.9
			return V(cos(dir) * r, h + 4 * ph * (1 - ph) * rad * 0.9, sin(dir) * r)
		end
		B[57] = function() -- Bubbles
			local ph = (t * 0.12 * (spd + 0.5) + seed) % 1
			local sc = 0.3 + 0.7 * seed
			return V(sin(t * 0.7 + seed * 9) * rad * 0.5 * sc * 2, h - 1 + ph * rad * 1.3, cos(t * 0.6 + seed * 7) * rad * 0.5 * sc * 2)
		end
		B[58] = function() -- Conga Line
			local a = t * spd - idx * 0.35
			return V(cos(a) * rad, h + vert * 0.3, sin(a) * rad)
		end
		B[59] = function() -- Snake Weave
			local a = t * spd - idx * 0.4
			return V(cos(a) * rad, h + sin(a * 3) * 1.2, sin(a) * rad)
		end
		B[60] = function() -- Comet Ellipse
			local q = CFrame.Angles(0, t * 0.3, 0.35) * V(cos(ang) * rad * 1.4, 0, sin(ang) * rad * 0.7)
			return V(q.X, h + q.Y + vert * 0.3, q.Z)
		end
		B[61] = function() -- Shockwave
			local r = rad * (((t * spd * 0.5 + fo) % 1) * 1.3 + 0.15)
			local a = fo * pi2 + t * 0.4
			return V(cos(a) * r, h + vert * 0.3, sin(a) * r)
		end
		B[62] = function() -- Counter-Rotate
			if idx % 2 == 1 then return V(cos(ang) * rad, h + vert, sin(ang) * rad) end
			return V(cos(-ang) * rad * 0.7, h - vert, sin(-ang) * rad * 0.7)
		end
		B[63] = function() -- Forward Wheel
			return base.LookVector * (cos(ang) * rad) + V(0, h + sin(ang) * rad, 0)
		end
		B[64] = function() -- Triple Helix
			local a = ang + (idx % 3) * pi2 / 3
			local yv = ((ang * 0.5 + idx * 0.6) % 6) - 1
			return V(cos(a) * rad * 0.8, h + yv, sin(a) * rad * 0.8)
		end
		B[65] = function() -- Fibonacci Sphere
			local y = 1 - ((idx - 0.5) / math.max(total, 1)) * 2
			local rr = math.sqrt(math.max(1 - y * y, 0))
			local th = idx * 2.39996 + ang * 0.6
			return V(cos(th) * rr * rad, h + y * rad * 0.8 + vert * 0.3, sin(th) * rr * rad)
		end
		B[66] = function() -- Möbius Strip
			local u = ang
			local v = (fr - 0.5) * pi
			local x = (1 + 0.5 * cos(v)) * cos(u)
			local y = (1 + 0.5 * cos(v)) * sin(u)
			local z = 0.5 * sin(v)
			return V(x * rad * 0.7, h + z * rad * 0.7 + vert, y * rad * 0.7)
		end
		B[67] = function() -- Dual Ring
			local ring = (idx % 2)
			local a = ang + (ring == 0 and 0 or pi)
			local r = rad * (ring == 0 and 1 or 0.55)
			return V(cos(a) * r, h + (ring == 0 and 0 or 1.2) + vert, sin(a) * r)
		end
		B[68] = function() -- Orbit Ladder
			local step = floor((idx - 1) / 2)
			local side = (idx % 2 == 0) and 1 or -1
			return V(side * rad * 0.4, h + step * 1.1 + vert, cos(ang + step) * rad * 0.3)
		end
		B[69] = function() -- Pulsar
			local pulse = 0.5 + 0.5 * sin(t * spd * 3)
			local r = rad * (0.4 + 0.6 * pulse)
			return V(cos(ang) * r, h + vert * pulse, sin(ang) * r)
		end
		B[70] = function() -- Diamond Path
			local p = polygon(4, ang, rad)
			return V(p.X, h + abs(p.X) * 0.4 + vert, p.Z)
		end
		B[71] = function() -- Crescent Moon
			local a = (fr - 0.5) * pi * 1.4 + ang * 0.15
			return V(cos(a) * rad, h + sin(a * 0.5) * rad * 0.3 + vert, sin(a) * rad * 0.6)
		end
		B[72] = function() -- Vortex Tunnel
			local depth = ((t * spd * 0.4 + fo) % 1)
			local r = rad * (0.2 + depth * 0.9)
			local a = ang + depth * 4
			return V(cos(a) * r, h + (depth - 0.5) * rad + vert * 0.3, sin(a) * r)
		end
		B[73] = function() -- Ribbon Wave
			local x = ((idx - 1) / math.max(total - 1, 1) - 0.5) * rad * 2.2
			return V(x, h + sin(t * spd * 2 + x * 0.4) * 1.5, cos(t * spd + x * 0.3) * rad * 0.4)
		end
		B[74] = function() -- Cage Box
			local edge = floor((idx - 1) / math.max(math.floor(total / 12), 1)) % 12
			local f = ((ang / pi2) + fo) % 1
			local s = rad * 0.8
			local corners = {
				V(-s, -s, -s), V(s, -s, -s), V(s, s, -s), V(-s, s, -s),
				V(-s, -s, s), V(s, -s, s), V(s, s, s), V(-s, s, s),
			}
			local edges = {{1,2},{2,3},{3,4},{4,1},{5,6},{6,7},{7,8},{8,5},{1,5},{2,6},{3,7},{4,8}}
			local e = edges[(edge % 12) + 1]
			local p = corners[e[1]]:Lerp(corners[e[2]], f)
			return V(p.X, h + p.Y + vert * 0.2, p.Z)
		end
		B[75] = function() -- Solar Flare
			local burst = abs(sin(t * spd * 1.5 + idx * 0.7))
			local r = rad * (0.3 + burst * 1.2)
			local a = ang + burst * 0.5
			return V(cos(a) * r, h + burst * rad * 0.5 + vert, sin(a) * r)
		end
		B[76] = function() -- Twin Orbit
			local twin = (idx % 2 == 0) and 1 or -1
			return V(cos(ang) * rad, h + twin * 1.5 + vert * 0.5, sin(ang) * rad)
		end
		B[77] = function() -- Vertical Helix
			local yv = ((ang * 0.8 + idx * 0.5) % 8) - 2
			return V(cos(ang) * rad * 0.7, h + yv, sin(ang) * rad * 0.7)
		end
		B[78] = function() -- Orbit Cascade
			local layer = floor((idx - 1) / 3)
			local a = ang - layer * 0.4
			local r = rad * (1 - layer * 0.15)
			return V(cos(a) * r, h + layer * 1.3 + vert, sin(a) * r)
		end
		B[79] = function() -- Star Cross
			local arm = (idx % 4)
			local d = ((ang / pi2 + fo) % 1) * rad
			local dirs = {V(1,0,0), V(-1,0,0), V(0,0,1), V(0,0,-1)}
			local dir = dirs[arm + 1]
			return V(dir.X * d, h + vert, dir.Z * d)
		end
		B[80] = function() -- Planetary Dance
			local layer = ((idx - 1) % 4) + 1
			local r = rad * (0.35 + layer * 0.22)
			local a = ang * (1.3 - layer * 0.12) + idx * 0.4
			local incl = sin(a * 0.5) * 0.4 * layer
			return V(cos(a) * r, h + incl * rad * 0.3 + vert, sin(a) * r)
		end
		local fn = B[mode]
		if fn then return fn() end
		return V(cos(ang) * rad, h + vert, sin(ang) * rad)
	end

	function X.orbitPos(mode, base, slot, t, idx, total)
		local spd = m.OrbitSpd * (slot.SpdMult or 1)
		local rad = m.OrbitRad + (slot.RadOff or 0)
		local h = m.OrbitH + (slot.VertOff or 0)
		local ang = (slot.Angle or 0) + t * spd
		local vert = 0
		if m.OrbitVertical then
			vert = math.sin(t * (m.OrbitVertSpd or 0.8) + (slot.Angle or 0)) * (m.OrbitVertAmp or 1.5)
		end
		if m.OrbitFinalePulse or mode == 10 then
			local pulse = 1 + math.sin(t * (m.OrbitFinalePulseSpd or 2.5) + idx) * 0.15 * (m.OrbitFinalePulseAmt or 2)
			rad = rad * pulse
		end
		local offset
		if mode == 2 then -- line
			local span = rad * 2
			local x = ((idx - 1) / math.max(total - 1, 1) - 0.5) * span
			offset = base.RightVector * x + base.UpVector * (h + vert) - base.LookVector * (rad * 0.3)
			return base.Position + offset
		elseif mode == 3 then -- solar system layers
			local layer = ((idx - 1) % 3) + 1
			local r = rad * (0.45 + layer * 0.35)
			local a = ang * (1.2 - layer * 0.15)
			offset = Vector3.new(math.cos(a) * r, h + vert + (layer - 2) * 0.6, math.sin(a) * r)
		elseif mode == 4 then -- figure-8
			offset = Vector3.new(math.sin(ang) * rad, h + vert, math.sin(ang * 2) * rad * 0.55)
		elseif mode == 5 then -- helix
			offset = Vector3.new(math.cos(ang) * rad, h + (ang % (math.pi * 4)) * 0.35 + vert, math.sin(ang) * rad)
		elseif mode == 6 then -- wave line
			local x = ((idx - 1) / math.max(total - 1, 1) - 0.5) * rad * 2
			local y = math.sin(t * spd * 2 + x) * (m.OrbitVertAmp or 1.5)
			offset = base.RightVector * x + base.UpVector * (h + y) - base.LookVector * (rad * 0.4)
			return base.Position + offset
		elseif mode == 7 then -- spiral
			local r = rad * (0.35 + 0.65 * (0.5 + 0.5 * math.sin(t * 0.7 + idx)))
			offset = Vector3.new(math.cos(ang) * r, h + vert, math.sin(ang) * r)
		elseif mode == 8 then -- ring stack
			local ring = math.floor((idx - 1) / 3)
			local inRing = ((idx - 1) % 3)
			local a = ang + inRing * (math.pi * 2 / 3)
			offset = Vector3.new(math.cos(a) * rad, h + ring * 1.4 + vert, math.sin(a) * rad)
		elseif mode == 9 then -- random drift
			local s = slot.Seed or 0.5
			offset = Vector3.new(
				math.sin(t * (0.6 + s) + s * 10) * rad,
				h + math.sin(t * (0.9 + s * 0.5)) * (m.OrbitVertAmp or 1.5),
				math.cos(t * (0.55 + s * 0.3) + s * 7) * rad
			)
		elseif mode == 10 then -- Undertale Finale
			local a = ang * 1.35
			local r = rad * (0.85 + 0.2 * math.sin(t * 4 + idx))
			offset = Vector3.new(math.cos(a) * r, h + math.sin(t * 3 + idx) * 1.2, math.sin(a) * r)
		elseif mode == 11 then -- Rose curve (r = cos(kθ))
			local k = 3 + (idx % 3)
			local r = rad * math.abs(math.cos(k * ang))
			offset = Vector3.new(math.cos(ang) * r, h + vert, math.sin(ang) * r)
		elseif mode == 12 then -- Infinity (sideways 8)
			offset = Vector3.new(math.sin(ang) * rad, h + vert, math.sin(ang * 2) * rad * 0.45)
		elseif mode == 13 then -- DNA double helix
			local strand = ((idx - 1) % 2 == 0) and 1 or -1
			local a = ang + (strand > 0 and 0 or math.pi)
			offset = Vector3.new(math.cos(a) * rad * 0.7, h + (ang % (math.pi * 6)) * 0.28 + vert, math.sin(a) * rad * 0.7)
		elseif mode == 14 then -- Cube faces
			local face = ((idx - 1) % 6) + 1
			local u = ((idx - 1) / 6 - math.floor((idx - 1) / 6)) * 2 - 1
			local half = rad * 0.55
			local map = {
				Vector3.new(half, u * half, 0), Vector3.new(-half, u * half, 0),
				Vector3.new(u * half, half, 0), Vector3.new(u * half, -half, 0),
				Vector3.new(0, u * half, half), Vector3.new(0, u * half, -half),
			}
			local p = map[face] or Vector3.zero
			local rotA = ang * 0.4
			offset = Vector3.new(
				p.X * math.cos(rotA) - p.Z * math.sin(rotA),
				h + p.Y + vert,
				p.X * math.sin(rotA) + p.Z * math.cos(rotA)
			)
		elseif mode == 15 then -- Pyramid
			local layer = math.floor((idx - 1) / 3)
			local inL = ((idx - 1) % 3)
			local r = rad * (1 - layer * 0.28)
			local a = ang + inL * (math.pi * 2 / 3)
			offset = Vector3.new(math.cos(a) * r, h + layer * 1.2 + vert, math.sin(a) * r)
		elseif mode == 16 then -- Star path
			local points = 5
			local a = ang
			local r = rad * (0.55 + 0.45 * math.abs(math.cos(points * a / 2)))
			offset = Vector3.new(math.cos(a) * r, h + vert, math.sin(a) * r)
		elseif mode == 17 then -- Tornado
			local rise = (ang % (math.pi * 8)) * 0.22
			local r = rad * (0.25 + 0.75 * (1 - math.clamp(rise / (rad * 3), 0, 1)))
			offset = Vector3.new(math.cos(ang * 1.6) * r, h + rise + vert, math.sin(ang * 1.6) * r)
		elseif mode == 18 then -- Butterfly
			local a = ang
			local rx = math.sin(a) * (math.exp(math.cos(a)) - 2 * math.cos(4 * a) - math.sin(a / 12) ^ 5)
			local rz = math.cos(a) * (math.exp(math.cos(a)) - 2 * math.cos(4 * a) - math.sin(a / 12) ^ 5)
			offset = Vector3.new(rx * rad * 0.12, h + vert + math.sin(a * 2) * 0.4, rz * rad * 0.12)
		elseif mode == 19 then -- Flower bloom
			local petals = 6
			local a = ang
			local r = rad * (0.4 + 0.6 * math.abs(math.sin(petals * a)))
			offset = Vector3.new(math.cos(a) * r, h + vert + math.sin(a * 3) * 0.3, math.sin(a) * r)
		elseif mode == 20 then -- Orbit rings (concentric)
			local ring = ((idx - 1) % 4) + 1
			local r = rad * (0.35 + ring * 0.28)
			local a = ang * (1.1 - ring * 0.08) + ring
			offset = Vector3.new(math.cos(a) * r, h + (ring - 2) * 0.5 + vert, math.sin(a) * r)
		elseif mode == 21 then -- Sine weave
			local x = ((idx - 1) / math.max(total - 1, 1) - 0.5) * rad * 2.2
			local z = math.sin(t * spd * 1.5 + x * 0.4) * rad * 0.6
			local y = math.cos(t * spd + x * 0.3) * (m.OrbitVertAmp or 1.5) * 0.5
			offset = base.RightVector * x + base.UpVector * (h + y) + base.LookVector * z
			return base.Position + offset
		elseif mode == 22 then -- Pendulum
			local swing = math.sin(ang) * rad
			offset = Vector3.new(swing, h - math.abs(swing) * 0.15 + vert, math.cos(ang * 0.5) * rad * 0.2)
		elseif mode == 23 then -- Galaxy spiral
			local r = rad * (0.2 + 0.8 * ((idx - 1) / math.max(total, 1)))
			local a = ang + (idx - 1) * 0.45
			offset = Vector3.new(math.cos(a) * r, h + math.sin(a * 0.5) * 0.8 + vert, math.sin(a) * r)
		elseif mode == 24 then -- Grid lattice
			local cols = 3
			local row = math.floor((idx - 1) / cols)
			local col = ((idx - 1) % cols)
			local spacing = rad * 0.55
			local x = (col - 1) * spacing
			local z = (row - 1) * spacing
			local rotA = ang * 0.3
			offset = Vector3.new(
				x * math.cos(rotA) - z * math.sin(rotA),
				h + vert,
				x * math.sin(rotA) + z * math.cos(rotA)
			)
		elseif mode == 25 then -- Sphere surface
			local phi = ((idx - 1) / math.max(total, 1)) * math.pi
			local theta = ang + idx * 0.7
			offset = Vector3.new(
				math.sin(phi) * math.cos(theta) * rad,
				h + math.cos(phi) * rad * 0.7 + vert,
				math.sin(phi) * math.sin(theta) * rad
			)
		elseif mode == 26 then -- Triangle path
			local seg = (ang / (math.pi * 2 / 3)) % 3
			local f = (ang % (math.pi * 2 / 3)) / (math.pi * 2 / 3)
			local corners = {
				Vector3.new(rad, 0, 0), Vector3.new(-rad * 0.5, 0, rad * 0.866), Vector3.new(-rad * 0.5, 0, -rad * 0.866),
			}
			local i0 = math.floor(seg) % 3 + 1
			local i1 = i0 % 3 + 1
			local p = corners[i0]:Lerp(corners[i1], f)
			offset = Vector3.new(p.X, h + vert, p.Z)
		elseif mode == 27 then -- Heart shape
			local a = ang
			local hx = 16 * math.sin(a) ^ 3
			local hy = 13 * math.cos(a) - 5 * math.cos(2 * a) - 2 * math.cos(3 * a) - math.cos(4 * a)
			offset = Vector3.new(hx * rad * 0.06, h + hy * rad * 0.06 + vert, math.sin(a * 0.5) * rad * 0.15)
		elseif mode == 28 then -- Cross orbit
			local axis = ((idx - 1) % 2)
			if axis == 0 then
				offset = Vector3.new(math.cos(ang) * rad, h + vert, 0)
			else
				offset = Vector3.new(0, h + vert, math.sin(ang) * rad)
			end
		elseif mode == 29 then -- Chaotic swarm
			local s = slot.Seed or 0.5
			offset = Vector3.new(
				math.sin(t * (1.1 + s * 2) + s * 20) * rad * (0.6 + s * 0.5),
				h + math.sin(t * (1.4 + s) + s * 8) * (m.OrbitVertAmp or 1.5) * 1.2,
				math.cos(t * (0.9 + s * 1.5) + s * 12) * rad * (0.6 + (1 - s) * 0.5)
			)
		elseif mode == 30 then -- Rain fall
			local x = ((idx - 1) / math.max(total - 1, 1) - 0.5) * rad * 2
			local fall = ((t * spd * 2 + idx * 0.7) % 4) - 2
			offset = base.RightVector * x + base.UpVector * (h + 2 - fall) - base.LookVector * (rad * 0.2)
			return base.Position + offset
		elseif mode == 31 then -- Vertical circle
			offset = Vector3.new(math.cos(ang) * rad, h + math.sin(ang) * rad + vert, 0)
		elseif mode == 32 then -- Horizontal figure-8
			offset = Vector3.new(math.sin(ang) * rad, h + vert, math.sin(ang * 2) * rad * 0.5)
		elseif mode == 33 then -- Expanding pulse
			local pulse = 0.5 + 0.5 * math.sin(t * (m.OrbitFinalePulseSpd or 2.5))
			local r = rad * (0.4 + 0.6 * pulse)
			offset = Vector3.new(math.cos(ang) * r, h + vert * pulse, math.sin(ang) * r)
		elseif mode == 34 then -- Zigzag
			local x = ((idx - 1) / math.max(total - 1, 1) - 0.5) * rad * 2
			local z = (((idx - 1) % 2 == 0) and 1 or -1) * rad * 0.4 * math.sin(t * spd)
			offset = base.RightVector * x + base.UpVector * (h + vert) + base.LookVector * z
			return base.Position + offset
		elseif mode == 35 then -- Crown arc
			local a = -math.pi * 0.6 + ((idx - 1) / math.max(total - 1, 1)) * math.pi * 1.2 + ang * 0.15
			offset = Vector3.new(math.sin(a) * rad, h + math.cos(a * 0.5) * rad * 0.35 + vert, -math.cos(a) * rad * 0.3)
		elseif mode >= 36 and mode <= 65 then
			offset = X.orbitExtra(mode, base, slot, t, idx, total, rad, h, vert, ang, spd)
		else -- circle
			offset = Vector3.new(math.cos(ang) * rad, h + vert, math.sin(ang) * rad)
		end
		return base.Position + offset
	end

	function X.stepOrbit(dt)
		if not (X.modeAllowsOrbit() and m.OrbitEnabled) then return end
		if next(OrbitSlots) == nil then
			local any = false
			for i = 1, 10 do if X.trim(m["OrbitHat" .. i]) ~= "" then any = true break end end
			if any and m.OrbitAutoRebuild then NeedOrbitRebuild = true end
			return
		end
		OrbitT = OrbitT + dt
		local followRoot = X.getFollowRoot()
		if not followRoot then return end
		local base = followRoot.CFrame
		local mode = m.OrbitMode or 1
		local total = 0
		for _ in pairs(OrbitSlots) do total = total + 1 end
		for _, slot in pairs(OrbitSlots) do
			if slot.Handle and slot.Handle.Parent then
				local pos = X.orbitPos(mode, base, slot, OrbitT, slot.Index or 1, math.max(total, 1))
				local cf
				if m.OrbitFaceOut or mode == 10 then
					cf = CFrame.lookAt(pos, base.Position)
				else
					cf = CFrame.new(pos) * (base - base.Position)
				end
				if m.OrbitSpinSelf then
					cf = cf * CFrame.Angles(0, OrbitT * m.OrbitSpinSelfSpd, 0)
				end
				if slot.Rot then cf = cf * slot.Rot end
				if slot.Held then X.driveHandle(slot.Held, cf)
				else pcall(function() slot.Handle.CFrame = cf end) end
			else
				NeedOrbitRebuild = true
			end
		end
	end

	--------------------------------------------------------------
	-- GASTER BLASTER (5 slots) + BONE + OMEGA
	--------------------------------------------------------------
	local clearClaws, rebuildClaws, stepClaws, fireClawsCombo, fireClawsPush, fireClawsSpin
	clearClaws, rebuildClaws, stepClaws, fireClawsCombo, fireClawsPush, fireClawsSpin =
		function() end, function() end, function() end, function() end, function() end, function() end
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
		Util_CreateText(parent, "── HAT ORBIT (modes + Finale + per-slot rot) ──", 14, Enum.TextXAlignment.Center)
		onChanged(Util_CreateSwitch(parent, "Orbit Enabled", m.OrbitEnabled), function(v)
			m.OrbitEnabled = v NeedOrbitRebuild = true if not v then X.clearOrbit() else task.defer(X.rebuildOrbit) end
		end)
		onChanged(Util_CreateSwitch(parent, "Auto Rebuild Orbit", m.OrbitAutoRebuild), function(v) m.OrbitAutoRebuild = v end)
		local omDD = Util_CreateDropdown(parent, "Orbit Mode", m.OrbitModeNames, m.OrbitMode)
		if omDD and omDD.Changed then
			omDD.Changed:Connect(function(val)
				if type(val) == "number" then m.OrbitMode = val
				elseif type(val) == "string" then
					for i, n in ipairs(m.OrbitModeNames) do if n == val then m.OrbitMode = i break end end
				end
			end)
		end
		onChanged(Util_CreateSwitch(parent, "Face Outward", m.OrbitFaceOut), function(v) m.OrbitFaceOut = v end)
		onChanged(Util_CreateSwitch(parent, "Spin Self", m.OrbitSpinSelf), function(v) m.OrbitSpinSelf = v end)
		onChanged(Util_CreateSwitch(parent, "Vertical Motion (up/down)", m.OrbitVertical), function(v) m.OrbitVertical = v end)
		onChanged(Util_CreateSwitch(parent, "Finale Pulse Radius", m.OrbitFinalePulse), function(v) m.OrbitFinalePulse = v end)
		onChanged(Util_CreateSlider(parent, "Orbit Radius (base)", m.OrbitRad, 1, 30, 0.5), function(v) m.OrbitRad = v end)
		onChanged(Util_CreateSlider(parent, "Orbit Speed (base)", m.OrbitSpd, 0.1, 5, 0.1), function(v) m.OrbitSpd = v end)
		onChanged(Util_CreateSlider(parent, "Orbit Height", m.OrbitH, -5, 15, 0.5), function(v) m.OrbitH = v end)
		onChanged(Util_CreateSlider(parent, "Self Spin Speed", m.OrbitSpinSelfSpd, 0.5, 12, 0.5), function(v) m.OrbitSpinSelfSpd = v end)
		onChanged(Util_CreateSlider(parent, "Vertical Amplitude", m.OrbitVertAmp, 0, 6, 0.1), function(v) m.OrbitVertAmp = v end)
		onChanged(Util_CreateSlider(parent, "Vertical Speed", m.OrbitVertSpd, 0.1, 5, 0.1), function(v) m.OrbitVertSpd = v end)
		onChanged(Util_CreateSlider(parent, "Finale Pulse Amount", m.OrbitFinalePulseAmt, 0, 5, 0.1), function(v) m.OrbitFinalePulseAmt = v end)
		onChanged(Util_CreateSlider(parent, "Finale Pulse Speed", m.OrbitFinalePulseSpd, 0.5, 8, 0.1), function(v) m.OrbitFinalePulseSpd = v end)
		local orbitNames = X.dropdownNames(true)
		for i = 1, 10 do
			local key = ORBIT_HAT_KEYS[i]
			local start = 1
			for j, n in ipairs(orbitNames) do
				if m[key] ~= "" and string.find(string.lower(n), string.lower(m[key]), 1, true) then
					start = j break
				end
			end
			local dd = Util_CreateDropdown(parent, "Orbit Slot " .. i, orbitNames, start)
			if dd and dd.Changed then
				dd.Changed:Connect(function(val)
					m[key] = X.cleanLabel(type(val) == "number" and orbitNames[val] or tostring(val))
					NeedOrbitRebuild = true
					if m.OrbitAutoRebuild then task.defer(X.rebuildOrbit) end
				end)
			end
			onChanged(Util_CreateSlider(parent, "O" .. i .. " Speed Mult", m["OrbitSpdMult" .. i], 0.1, 5, 0.1), function(v)
				m["OrbitSpdMult" .. i] = v
				if OrbitSlots[i] then OrbitSlots[i].SpdMult = v end
			end)
			onChanged(Util_CreateSlider(parent, "O" .. i .. " Radius Offset", m["OrbitRadOff" .. i], -10, 20, 0.5), function(v)
				m["OrbitRadOff" .. i] = v
				if OrbitSlots[i] then OrbitSlots[i].RadOff = v end
			end)
			onChanged(Util_CreateSlider(parent, "O" .. i .. " Vert Offset", m["OrbitVertOff" .. i], -10, 10, 0.25), function(v)
				m["OrbitVertOff" .. i] = v
				if OrbitSlots[i] then OrbitSlots[i].VertOff = v end
			end)
			onChanged(Util_CreateSlider(parent, "O" .. i .. " Rot X", m["OrbitRotX" .. i], -180, 180, 1), function(v)
				m["OrbitRotX" .. i] = v
				if OrbitSlots[i] then
					OrbitSlots[i].Rot = CFrame.Angles(math.rad(v), math.rad(m["OrbitRotY" .. i] or 0), math.rad(m["OrbitRotZ" .. i] or 0))
				end
			end)
			onChanged(Util_CreateSlider(parent, "O" .. i .. " Rot Y", m["OrbitRotY" .. i], -180, 180, 1), function(v)
				m["OrbitRotY" .. i] = v
				if OrbitSlots[i] then
					OrbitSlots[i].Rot = CFrame.Angles(math.rad(m["OrbitRotX" .. i] or 0), math.rad(v), math.rad(m["OrbitRotZ" .. i] or 0))
				end
			end)
			onChanged(Util_CreateSlider(parent, "O" .. i .. " Rot Z", m["OrbitRotZ" .. i], -180, 180, 1), function(v)
				m["OrbitRotZ" .. i] = v
				if OrbitSlots[i] then
					OrbitSlots[i].Rot = CFrame.Angles(math.rad(m["OrbitRotX" .. i] or 0), math.rad(m["OrbitRotY" .. i] or 0), math.rad(v))
				end
			end)
		end
		onActivated(Util_CreateButton(parent, "Apply / Rebuild Orbit", 14), function() X.rebuildOrbit() end)
		onActivated(Util_CreateButton(parent, "Clear Orbit", 12), function()
			for _, key in ipairs(ORBIT_HAT_KEYS) do m[key] = "" end
			X.clearOrbit()
		end)

		-- SANS MASTER (Gaster + Bone + Omega)
		Util_CreateSeparator(parent)
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

local cfg = { id = "ORBIT", mode = 3, suffix = "_Orbit", name = "Hat Orbit", internal = "HAT_STAND_ORBIT", standInOrbit = false,
	desc = "FE hat orbit: 10 slots, 65+ orbit modes.",
	title = "Hat Orbit", subtitle = "FE hat orbit: 10 slots, 65+ orbit modes.",
	sections = { orbit = true } }

table.insert(modules, function()
	return makeHatModule(cfg)
end)

return modules
