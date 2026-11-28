Class {
	#name : 'CIGameItemTypes',
	#superclass : 'Object',
	#category : 'BVC-Inventory-TypeCatalog',
	#package : 'BVC-Inventory-TypeCatalog'
}

{ #category : 'catalog' }
CIGameItemTypes class >> buildCatalog [
	| catalog |
	catalog := CIItemTypeCatalog new.
	catalog register: self scoutDrone.
	catalog register: self scannerPulse.
	catalog register: self responseAidVest.
	catalog register: self traversalPack.
	catalog register: self fieldKneePads.
	catalog register: self fieldBlade.
	catalog register: self relaySidearm.
	catalog register: self pathfinderCarbine.
	self registerTalentDefinitionsIn: catalog.
	self
		configureTalentPoolFor: 'gear.response.aidVest'
		profile: #vest
		in: catalog.
	self
		configureTalentPoolFor: 'gear.traversal.pack'
		profile: #backpack
		in: catalog.
	self
		configureTalentPoolFor: 'weapon.sidearm.relay'
		profile: #pistol
		in: catalog.
	self
		configureTalentPoolFor: 'weapon.ranged.pathfinder'
		profile: #assaultRifle
		in: catalog.
	CIThatGameLaunchCatalog registerIn: catalog.
	self registerLootIn: catalog.
	self registerModsIn: catalog.
	self registerLaunchGearFamiliesIn: catalog.
	CIWorkbookGadgetData registerIn: catalog.
	CIWorkbookGadgetData registerItemTypesIn: catalog.
	CIWorkbookAttributeData registerIn: catalog attributeCatalogue.
	CIWorkbookNamedGearData registerIn: catalog.
	CIWorkbookNamedGearReferences registerIn: catalog.
	CIWorkbookNamedGearData registerAdditionalIn: catalog.
	CIWorkbookWeaponData registerIn: catalog.
	^ catalog
]

{ #category : 'talents' }
CIGameItemTypes class >> configureTalentPoolFor: aTypeIdentifier profile: aProfile in: catalog [
	| profile |
	profile := self talentPoolProfiles
			detect: [ :entry | entry first = aProfile ]
			ifNone: [ self error: 'Unknown talent pool profile: ' , aProfile asString ].
	catalog talentPool: profile allButFirst for: aTypeIdentifier
]

{ #category : 'catalog' }
CIGameItemTypes class >> fieldBlade [
	^ (CIWeaponType
		id: 'weapon.melee.fieldBlade'
		name: 'Field Blade'
		slot: 'MeleeWeapon'
		core: #(#('Damage per hit' 48) #('Reach' '2 m'))
		handling: #()
		sockets: #())
		inspectorIdentity: {'inspectorManufacturer' -> 'Bastion Fabrication'.
				'inspectorCategory' -> 'Melee weapon'} asDictionary;
		yourself
]

{ #category : 'catalog' }
CIGameItemTypes class >> fieldKneePads [
	^ (CIGearType
		id: 'gear.field.kneePads'
		name: 'Field Knee Pads'
		slot: 'KneePads'
		attributes: #(#('armor' 'Armor' 'defensive' 'signedNumber' 30 60) #('hazard' 'Hazard resistance' 'defensive' 'signedPercent' 0.02 0.08))
		sockets: #())
		inspectorIdentity: {'inspectorManufacturer' -> 'Bastion Fabrication'.
				'inspectorArmour' -> 30} asDictionary;
		yourself
]

{ #category : 'families' }
CIGameItemTypes class >> launchFamilyModifiersFrom: specs [
	^ specs
		collect: [ :spec | 
			CIGearModifier
				stat: spec first
				operation: #add
				magnitude: spec second
				targetClass: nil
				duration: #whileEquipped ]
]

{ #category : 'families' }
CIGameItemTypes class >> launchFamilyTierFrom: spec [
	| tier |
	tier := CIGearFamilyTier
			pieces: spec first
			modifiers: (self launchFamilyModifiersFrom: spec second)
			trigger: nil
			consumeOn: nil
			limit: 1.
	tier
		pvpModifiers: (spec third ifNotNil: [ :values | self launchFamilyModifiersFrom: values ])
		evidence: spec fourth.
	^ tier
]

{ #category : 'catalog' }
CIGameItemTypes class >> pathfinderCarbine [
	^ (CIWeaponType
		id: 'weapon.ranged.pathfinder'
		name: 'Pathfinder Carbine'
		slot: 'RangedWeapon'
		core: #(#('Damage per hit' 25) #('Fire rate' '600 RPM') #('Magazine' '30 rounds') #('Optimal range' 32) #('Reload time' '2.1 s'))
		handling: #(#('Accuracy' 82) #('Stability' 68))
		sockets: #('optic' 'magazine' 'muzzle'))
		inspectorIdentity: {'inspectorManufacturer' -> 'Meridian Range'.
				'inspectorCategory' -> 'Carbine'.
				'inspectorConsumable' -> 'Carbine ammunition'.
				'inspectorConsumableIcon' -> 'cartridge'} asDictionary;
		damageFalloff: #(#(72 65) #(100 65));
		yourself
]

{ #category : 'talents' }
CIGameItemTypes class >> perfectTalentDefinitions [
	^ #(#('optimist' 'perfectOptimist' 'Perfect Optimist' #(#(damagePerStep 0.045)) 'Gain 4.5% weapon damage for every 10% ammo missing from the magazine.') #('fastHands' 'perfectFastHands' 'Perfect Fast Hands' #(#(reloadSpeedPerCriticalHit 0.05)) 'Each critical hit adds a 5% reload speed stack, up to 40 stacks.') #('ranger' 'perfectRanger' 'Perfect Ranger' #(#(distanceStepMetres 3)) 'Amplifies weapon damage by 2% per 3 m between you and the target.') #('preservation' 'perfectPreservation' 'Perfect Preservation' #(#(armorRepairOnKill 0.15) #(extraArmorRepairOnHeadshotKill 0.15)) 'A kill repairs 15% armor over 5 seconds. A headshot kill adds another 15% repair.') #('inSync' 'perfectInSync' 'Perfectly In Sync' #(#(skillDamageOnWeaponHit 0.20) #(weaponDamageOnSkillUseOrHit 0.20)) 'Weapon hits grant +20% skill damage for 5 seconds. Using a skill or hitting with one grants +20% weapon damage for 5 seconds. Both bonuses double while active together.') #('obliterate' 'perfectObliterate' 'Perfect Obliterate' #(#(maxStacks 24)) 'Each critical hit grants 1% total weapon damage for 10 seconds, up to 24 stacks.') #('unbreakable' 'perfectUnbreakable' 'Perfect Unbreakable' #(#(armorRepairOnDepletion 1.0) #(cooldownSeconds 55)) 'When armor is depleted, restore 100% armor. Cooldown is 55 seconds.') #('overwatch' 'perfectOverwatch' 'Perfect Overwatch' #(#(coverSeconds 8) #(squadWeaponDamage 0.14) #(squadSkillDamage 0.14)) 'After 8 seconds in cover, you and your squad gain 14% total weapon and skill damage while in cover or moving from cover to cover.') #('composure' 'perfectComposure' 'Perfect Composure' #(#(inCoverWeaponDamage 0.20)) 'While in cover, gain 20% total weapon damage.') #('combinedArms' 'perfectCombinedArms' 'Perfect Combined Arms' #(#(skillDamageOnWeaponHit 0.30)) 'Hitting an enemy with a weapon grants 30% total skill damage for 3 seconds.') #('creepingDeath' 'perfectCreepingDeath' 'Perfect Creeping Death' #(#(statusSpreadRadiusMetres 10) #(cooldownSeconds 10)) 'Applying a status effect also applies it to enemies within 10 m of the target. Cooldown is 10 seconds.'))
]

{ #category : 'families' }
CIGameItemTypes class >> registerClassifiedFamilyEffectsIn: catalog [
	#(#('redLotusAssault' 'strikersGamble' 'Striker''s Gamble' 'Weapon hits build stacks of 0.65% weapon damage, up to 100. Lose one stack per second up to 50 stacks and two per second above 50.' #(#(requiredPieces 4) #(trigger weaponHit) #(damagePerStack 0.0065) #(damageOperation amplifier) #(maxStacks 100) #(firstDecayThreshold 50) #(firstDecayPerSecond 1) #(secondDecayPerSecond 2)) 'pressTheAdvantage' 'riskManagement') #('jupiterTechnologies' 'indirectTransmission' 'Indirect Transmission' 'On a kill, spread status effects from that enemy to enemies within 10 m and refresh 50% of their duration.' #(#(requiredPieces 4) #(trigger kill) #(spreadRadiusMetres 10) #(durationRefreshFraction 0.50)) 'proliferation' 'symptomAggravator'))
		do: [ :spec | 
			| parameters talent |
			parameters := Dictionary new.
			spec fifth do: [ :pair | parameters at: pair first put: pair second ].
			talent := catalog
					registerTalent: (CIItemTalent
							id: spec second
							name: spec third
							eligibility: #set
							parameters: parameters
							comment: spec fourth).
			(catalog gearFamilyAt: spec first)
				setTalent: talent
				slotUpgrades: (Dictionary new
						at: 'Chest' put: (catalog talentAt: (spec at: 6));
						at: 'Backpack' put: (catalog talentAt: (spec at: 7));
						yourself) ]
]

{ #category : 'talents' }
CIGameItemTypes class >> registerGadgetOverchargeTalentsIn: catalog [
	#(#('futurePerfect' 'Future Perfect' 15 3 'Weapon kills grant +1 Skill Tier for 15 seconds, up to three stacks. A weapon kill at Skill Tier 6 grants Overcharge for 15 seconds with a 90-second cooldown.') #('futurePerfection' 'Future Perfection' 19 4 'Weapon kills grant +1 Skill Tier for 19 seconds, up to four stacks. A weapon kill at Skill Tier 6 grants Overcharge for 15 seconds with a 90-second cooldown.'))
		do: [ :spec | 
			catalog
				registerTalent: (CIItemTalent
						id: spec first
						name: spec second
						eligibility: #weapon
						parameters: (Dictionary new
								at: #evidence put: 'Weapon Talents!B18:D18';
								at: #trigger put: #weaponKill;
								at: #tierDurationSeconds put: spec third;
								at: #maxTierStacks put: spec fourth;
								at: #overchargeRequiredTier put: 6;
								at: #overchargeSeconds put: 15;
								at: #overchargeCooldownSeconds put: 90;
								yourself)
						comment: spec fifth) ]
]

{ #category : 'families' }
CIGameItemTypes class >> registerLaunchGearFamiliesIn: catalog [
	#(#('vossAndVale' 'Voss & Vale' #(#(1 #(#(headshotDamage 0.13)) #(#(headshotDamage 0.13)) 'Brandsets!E33,K33') #(2 #(#(criticalHitChance 0.08)) #(#(criticalHitChance 0.08)) 'Brandsets!F33,L33') #(3 #(#(criticalHitDamage 0.13)) #(#(criticalHitDamage 0.13)) 'Brandsets!G33,M33'))) #('rookStandard' 'Rook Standard' #(#(1 #(#(totalArmor 0.05)) #(#(totalArmor 0.05)) 'Brandsets!E6,K6') #(2 #(#(hazardProtection 0.20)) #(#(hazardProtection 0.15)) 'Brandsets!F6,L6') #(3 #(#(armorRegeneration 0.02)) #(#(armorRegeneration 0.02)) 'Brandsets!G6,M6'))) #('morrowWorks' 'Morrow Works' #(#(1 #(#(skillHaste 0.10)) #(#(skillHaste 0.10)) 'Brandsets!E17,K17') #(2 #(#(skillDamage 0.13)) #(#(skillDamage 0.13)) 'Brandsets!F17,L17') #(3 #(#(weaponDamage 0.18)) #(#(weaponDamage 0.18)) 'Brandsets!G17,M17'))) #('redLotusAssault' 'Red Lotus Assault' #(#(2 #(#(weaponHandling 0.15)) nil 'Gearsets!C45') #(3 #(#(rateOfFire 0.15)) nil 'Gearsets!D45') #(4 #() nil 'Gearsets!E45:H45'))) #('jupiterTechnologies' 'Jupiter Technologies' #(#(2 #(#(statusEffects 0.15)) nil 'Gearsets!C15') #(3 #(#(skillHaste 0.15) #(hazardProtection 0.30)) nil 'Gearsets!D15') #(4 #() nil 'Gearsets!E15:H15'))))
		do: [ :spec | 
			catalog
				registerGearFamily: (CIGearFamily
						id: spec first
						manufacturer: spec second
						tiers: (spec third collect: [ :tier | self launchFamilyTierFrom: tier ])) ].
	self registerClassifiedFamilyEffectsIn: catalog
]

{ #category : 'loot' }
CIGameItemTypes class >> registerLootIn: catalog [
	| targeted caches |
	targeted := OrderedCollection new.
	caches := OrderedCollection new.
	#(#('capacitor' 'The Summit challenges' challenge 'I112' blueprintAcquired) #('bluescreen' 'Season 9 Track' season 'I120') #('chatterbox' 'Hyena Cache questline' questline 'I130' blueprintAcquired) #('scorpio' 'Season 4 track' season 'I148') #('doctorHome' 'Season 10 Manhunt Reward' manhunt 'I156') #('nemesis' 'Invaded strongholds questline' questline 'I167' blueprintAcquired) #('liberty' 'True Sons missions questline' questline 'I173' blueprintAcquired))
		do: [ :spec | 
			| item entry evidence |
			item := catalog typeAt: 'weapon.launch.' , spec first.
			evidence := 'Weapons Named + Exotics!' , spec fourth.
			entry := CILootPoolEntry
					item: item
					weight: nil
					requiring: nil
					evidence: evidence.
			self
				registerLootPool: spec first
				name: spec second
				kind: spec third
				entries: {entry}
				in: catalog.
			entry := CILootPoolEntry
					item: item
					weight: nil
					requiring: (spec at: 5 ifAbsent: [ nil ])
					evidence: evidence.
			targeted add: entry.
			caches add: entry ].
	self
		registerLootPool: 'targetedLoot'
		name: 'Targeted loot'
		kind: #targetedLoot
		entries: targeted
		in: catalog.
	self
		registerLootPool: 'exoticCaches'
		name: 'Exotic Caches'
		kind: #cache
		entries: caches
		in: catalog
]

{ #category : 'loot' }
CIGameItemTypes class >> registerLootPool: identifier name: sourceName kind: kind entries: entries in: catalog [
	catalog lootCatalogue
		register: (CILootPool
				id: identifier
				source: (CILootSource
						id: identifier
						name: sourceName
						kind: kind)
				entries: entries
				complete: nil)
]

{ #category : 'mods' }
CIGameItemTypes class >> registerModsIn: catalog [
	| mods |
	mods := catalog modCatalogue.
	CIWorkbookModData registerIn: mods.
	CIThatGameLaunchCatalog gearFamilies
		do: [ :family | 
			(CIThatGameLaunchCatalog gearSlots
				select: [ :slot | #('Mask' 'Chest' 'Backpack') includes: slot first ])
				do: [ :slot | 
					mods
						registerSocket: (CIItemSocket id: 'gearMod' interface: #gearMod)
						forItem: (CIThatGameLaunchCatalog gearIdentifierFor: family slot: slot) ] ]
]

{ #category : 'talents' }
CIGameItemTypes class >> registerPvPGearTalentProfilesIn: catalog [
	#(#('obliterate' documented #(#(maxStacks 16)) #(#('Gear Talents!H7' nil) #('Gear Talents!K7' 'Critical hits increase total weapon damage by 1% for 10s. Stacks up to 🔴16 🔴(20) times.'))) #('perfectObliterate' documented #(#(maxStacks 20)) #(#('Gear Talents!H7' nil) #('Gear Talents!K7' 'Critical hits increase total weapon damage by 1% for 10s. Stacks up to 🔴16 🔴(20) times.'))) #('overwatch' documented #(#(coverSeconds 8) #(squadWeaponDamage 0.14) #(squadSkillDamage 0.14)) #(#('Gear Talents!H11' nil) #('Gear Talents!K11' 'After staying in cover for 🟢8s 🟢(6s), increase your and all allies’ TWD and skill damage by 🔴14% (18%) as long as you remain in cover or in a cover-to-cover move.'))) #('perfectOverwatch' documented #(#(coverSeconds 6) #(squadWeaponDamage 0.18) #(squadSkillDamage 0.18)) #(#('Gear Talents!H11' nil) #('Gear Talents!K11' 'After staying in cover for 🟢8s 🟢(6s), increase your and all allies’ TWD and skill damage by 🔴14% (18%) as long as you remain in cover or in a cover-to-cover move.'))) #('unbreakable' conflicting #() #(#('Gear Talents!H14' '50% Armor repaired; 60s cooldown; Perfect: 55% armor, 55s cooldown.') #('Gear Talents!K14' 'When your armor is depleted, repair 🔴30% 🔴(50%) of your armor. 🟢50s cool down.'))) #('perfectUnbreakable' conflicting #() #(#('Gear Talents!H14' '50% Armor repaired; 60s cooldown; Perfect: 55% armor, 55s cooldown.') #('Gear Talents!K14' 'When your armor is depleted, repair 🔴30% 🔴(50%) of your armor. 🟢50s cool down.'))) #('combinedArms' unspecified #() #(#('Gear Talents!H26' nil) #('Gear Talents!K26' nil))) #('perfectCombinedArms' unspecified #() #(#('Gear Talents!H26' nil) #('Gear Talents!K26' nil))) #('composure' unspecified #() #(#('Gear Talents!H33' nil) #('Gear Talents!K33' nil))) #('perfectComposure' unspecified #() #(#('Gear Talents!H33' nil) #('Gear Talents!K33' nil))) #('creepingDeath' unspecified #() #(#('Gear Talents!H47' nil) #('Gear Talents!K47' nil))) #('perfectCreepingDeath' unspecified #() #(#('Gear Talents!H47' nil) #('Gear Talents!K47' nil))))
		do: [ :spec | 
			| overrides cells |
			overrides := Dictionary new.
			spec third do: [ :pair | overrides at: pair first put: pair second ].
			cells := Dictionary new.
			spec fourth do: [ :pair | cells at: pair first put: pair second ].
			(catalog talentAt: spec first)
				modeProfile: (CITalentModeProfile
						status: spec second
						parameters: overrides
						sources: cells)
				for: #pvp ]
]

{ #category : 'talents' }
CIGameItemTypes class >> registerTalentDefinitionsIn: catalog [
	self talentDefinitions
		do: [ :spec | 
			| parameters |
			parameters := Dictionary new.
			spec fourth do: [ :pair | parameters at: pair first put: pair second ].
			catalog
				registerTalent: (CIItemTalent
						id: spec first
						name: spec second
						eligibility: spec third
						parameters: parameters
						comment: spec fifth) ].
	self perfectTalentDefinitions
		do: [ :spec | 
			| base parameters |
			base := catalog talentAt: spec first.
			parameters := base parameters.
			spec fourth do: [ :pair | parameters at: pair first put: pair second ].
			catalog
				registerTalent: (CIItemTalent
						id: spec second
						name: spec third
						eligibility: base eligibility
						parameters: parameters
						comment: spec fifth) ].
	self registerGadgetOverchargeTalentsIn: catalog.
	self registerPvPGearTalentProfilesIn: catalog
]

{ #category : 'catalog' }
CIGameItemTypes class >> relaySidearm [
	^ (CIWeaponType
		id: 'weapon.sidearm.relay'
		name: 'Relay Sidearm'
		slot: 'LeftHandWeapon'
		core: #(#('Damage per hit' 32) #('Fire rate' '360 RPM') #('Magazine' '12 rounds') #('Optimal range' 18) #('Reload time' '1.5 s'))
		handling: #(#('Accuracy' 72) #('Stability' 76))
		sockets: #('magazine' 'muzzle'))
		inspectorIdentity: {'inspectorManufacturer' -> 'Relay Works'.
				'inspectorCategory' -> 'Sidearm'.
				'inspectorConsumable' -> 'Sidearm ammunition'.
				'inspectorConsumableIcon' -> 'cartridge'} asDictionary;
		damageFalloff: #(#(42 55) #(60 55));
		yourself
]

{ #category : 'catalog' }
CIGameItemTypes class >> responseAidVest [
	^ (CIGearType
		id: 'gear.response.aidVest'
		name: 'Response Aid Vest'
		slot: 'Chest'
		attributes: #(#('utilityTier' 'Utility Tier' 'utility' 'signedNumber' 1 1) #('repair' 'Repair strength' 'utility' 'signedPercent' 0.04 0.12) #('haste' 'Gadget haste' 'utility' 'signedPercent' 0.03 0.10))
		sockets: #('utility'))
		inspectorIdentity: {'inspectorManufacturer' -> 'Sable Instruments'.
				'inspectorArmour' -> 100} asDictionary;
		yourself
]

{ #category : 'catalog' }
CIGameItemTypes class >> scannerPulse [
	^ CIScannerPulseType
		id: 'gadget.pulse.scanner'
		name: 'Scanner Pulse'
		icon: 'scannerPulse'
]

{ #category : 'catalog' }
CIGameItemTypes class >> scoutDrone [
	^ CIScoutDroneType
		id: 'gadget.drone.scout'
		name: 'Scout Drone'
		icon: 'scoutDrone'
]

{ #category : 'talents' }
CIGameItemTypes class >> talentDefinitions [
	^ #(#('optimist' 'Optimist' weapon #(#(magazineStep 0.10) #(damagePerStep 0.035)) 'Weapon damage is increased by +3.5% (4.5%) for every 10% ammo missing from the magazine.') #('fastHands' 'Fast Hands' weapon #(#(reloadSpeedPerCriticalHit 0.03) #(maxStacks 40)) 'Each critical hit adds a 3% (5%) reload speed stack, up to 40 stacks.') #('ranger' 'Ranger' weapon #(#(distanceStepMetres 4) #(damageAmplificationPerStep 0.02)) 'Amplifies weapon damage by 2% per 4 m (3 m) between you and the target.') #('preservation' 'Preservation' weapon #(#(armorRepairOnKill 0.10) #(extraArmorRepairOnHeadshotKill 0.10) #(repairSeconds 5)) 'A kill repairs 10% (15%) armor over 5 seconds. A headshot kill adds another 10% (15%) repair.') #('inSync' 'In Sync' weapon #(#(skillDamageOnWeaponHit 0.15) #(weaponDamageOnSkillUseOrHit 0.15) #(durationSeconds 5) #(dualBuffMultiplier 2)) 'Weapon hits grant +15% (+20%) skill damage for 5 seconds. Using a skill or hitting with one grants +15% (+20%) weapon damage for 5 seconds. Both bonuses double while active together.') #('obliterate' 'Obliterate' Chest #(#(weaponDamagePerCriticalHit 0.01) #(durationSeconds 10) #(maxStacks 20)) 'Each critical hit grants 1% total weapon damage for 10 seconds, up to 20 (24) stacks.') #('unbreakable' 'Unbreakable' Chest #(#(armorRepairOnDepletion 0.95) #(cooldownSeconds 60)) 'When armor is depleted, restore 95% (100%) armor. Cooldown is 60 (55) seconds.') #('overwatch' 'Overwatch' Chest #(#(coverSeconds 10) #(squadWeaponDamage 0.12) #(squadSkillDamage 0.12) #(persistsOnCoverToCover true)) 'After 10 (8) seconds in cover, you and your squad gain 12% (14%) total weapon and skill damage while in cover or moving from cover to cover.') #('composure' 'Composure' Backpack #(#(inCoverWeaponDamage 0.15)) 'While in cover, gain 15% (20%) total weapon damage.') #('combinedArms' 'Combined Arms' Backpack #(#(skillDamageOnWeaponHit 0.25) #(durationSeconds 3)) 'Hitting an enemy with a weapon grants 25% (30%) total skill damage for 3 seconds.') #('creepingDeath' 'Creeping Death' Backpack #(#(statusSpreadRadiusMetres 8) #(cooldownSeconds 15)) 'Applying a status effect also applies it to enemies within 8 m (10 m) of the target. Cooldown is 15 (10) seconds.') #('capacitance' 'Capacitance' weapon #(#(maxStacks 40) #(skillDamagePerHitStack 0.015) #(decayDelaySeconds 5) #(decayStacksPerSecond 1) #(weaponDamagePerSkillTier 0.075)) 'Weapon hits build up to 40 stacks of +1.5% skill damage each. After 5 seconds, stacks decay at one per second. Each skill tier grants +7.5% weapon damage.') #('incessantChatter' 'Incessant Chatter' weapon #(#(rateOfFirePerEnemyOnReload 0.25) #(radiusMetres 15) #(maxStacks 5) #(magazineRefillOnKill 0.50)) 'On reload, gain 25% rate of fire per enemy within 15 m, up to five stacks, for that magazine. Kills refill 50% of the magazine.') #('disruptorRounds' 'Disruptor Rounds' weapon #(#(maxStacks 50) #(pulseStacks 1) #(disruptStacks 11) #(disorientStacks 26) #(areaStacks 50) #(radiusMetres 10) #(durationSeconds 5) #(shieldDeploymentTriggers false) #(markedKillTriggers true)) 'Hits mark targets and build up to 50 stacks. Deploying a non-shield skill spends the stacks. At 1 stack, pulse marked targets. At 11, add disrupt. At 26, add disorient. The effects last 5 seconds. At 50 stacks, they also reach enemies within 10 m of marked targets. Killing a marked enemy triggers the effect immediately.') #('septicShock' 'Septic Shock' weapon #(#(venomDurationSeconds 10) #(poisonStacks 2) #(disorientStacks 4) #(shockStacks 6) #(damageTakenStacks 8) #(maxStacks 9) #(additionalDamageTaken 0.20) #(statusDurationScalesWithPelletHits true)) 'Hits apply venom for 10 seconds. Venom poisons at 2 stacks, disorients at 4, and shocks at 6. The target takes 20% more damage from any source at 8 stacks. The debuff refreshes at the 9-stack cap. Status duration scales with the share of pellets that hit.') #('doctorHome' 'Doctor Home' weapon #(#(markSeconds 5) #(groupArmorRepairOnMarkedKill 0.10) #(grantsBonusArmor false)) 'Weapon hits mark enemies for 5 seconds. Killing a marked enemy drops a kit that repairs 10% armor for the group and grants zero bonus armor.') #('electromagneticAccelerator' 'Electromagnetic Accelerator' weapon #(#(minimumChargedDamage 0) #(maximumChargedDamage 1)) 'Hold the trigger to charge the shot. On release, it deals between 0% and 100% weapon damage according to the charge.') #('libertyOrDeath' 'Liberty or Death' weapon #(#(weaponDamagePerHitStack 0.02) #(maxStacks 30) #(shieldRepairPerStackOnHeadshot 0.03)) 'Hits add 2% weapon damage per stack, up to 30 stacks. A headshot spends all stacks to repair 3% shield per stack.') #('pressTheAdvantage' 'Press the Advantage' Chest #(#(requiredPieces 4) #(familyId 'redLotusAssault') #(maxStacks 200) #(highDecayMinimumStacks 101) #(highDecayStacksPerSecond 3)) 'At four Red Lotus Assault pieces, the vest raises the set cap to 200 stacks. Above 100 stacks, three stacks decay per second.') #('riskManagement' 'Risk Management' Backpack #(#(requiredPieces 4) #(familyId 'redLotusAssault') #(damagePerStack 0.009)) 'At four Red Lotus Assault pieces, the backpack raises the damage gained per stack to 0.9%.') #('proliferation' 'Proliferation' Chest #(#(requiredPieces 4) #(familyId 'jupiterTechnologies') #(spreadRadiusMetres 15) #(durationRefreshFraction 0.75)) 'At four Jupiter Technologies pieces, the vest extends the status spread to 15 m and refreshes 75% of the status duration.') #('symptomAggravator' 'Symptom Aggravator' Backpack #(#(requiredPieces 4) #(familyId 'jupiterTechnologies') #(damageAmplificationToStatusTargets 0.30)) 'At four Jupiter Technologies pieces, the backpack amplifies damage you deal to status-affected enemies by 30%.'))
]

{ #category : 'talents' }
CIGameItemTypes class >> talentPoolProfiles [
	^ #(#(assaultRifle 'optimist' 'fastHands' 'preservation' 'inSync') #(smg 'optimist' 'fastHands' 'preservation') #(lmg 'optimist' 'fastHands' 'preservation') #(shotgun 'optimist' 'preservation' 'inSync') #(rifle 'optimist' 'ranger' 'preservation' 'inSync') #(marksmanRifle 'ranger' 'preservation' 'inSync') #(pistol 'optimist' 'preservation' 'inSync') #(vest 'obliterate' 'unbreakable' 'overwatch') #(backpack 'composure' 'combinedArms' 'creepingDeath') #(capacitor 'capacitance') #(chatterbox 'incessantChatter') #(bluescreen 'disruptorRounds') #(scorpio 'septicShock') #(doctorHome 'doctorHome') #(nemesis 'electromagneticAccelerator') #(liberty 'libertyOrDeath') #(redLotusVest 'pressTheAdvantage') #(redLotusBackpack 'riskManagement') #(jupiterVest 'proliferation') #(jupiterBackpack 'symptomAggravator'))
]

{ #category : 'catalog' }
CIGameItemTypes class >> traversalPack [
	^ (CIGearType
		id: 'gear.traversal.pack'
		name: 'Traversal Pack'
		slot: 'Backpack'
		attributes: #(#('armor' 'Armor' 'defensive' 'signedNumber' 60 100) #('hazard' 'Hazard resistance' 'defensive' 'signedPercent' 0.04 0.12) #('reload' 'Reload speed' 'offensive' 'signedPercent' 0.03 0.10))
		sockets: #('defensive' 'utility'))
		inspectorIdentity: {'inspectorManufacturer' -> 'Crosswind Systems'.
				'inspectorArmour' -> 40} asDictionary;
		yourself
]
