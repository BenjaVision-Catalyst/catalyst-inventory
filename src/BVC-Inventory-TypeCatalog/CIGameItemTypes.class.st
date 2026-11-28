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
						parameters: parameters) ]
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
	^ #(#('optimist' 'Optimist' weapon #(#(magazineStep 0.10) #(damagePerStep 0.035))) #('fastHands' 'Fast Hands' weapon #(#(reloadSpeedPerCriticalHit 0.03) #(maxStacks 40))) #('ranger' 'Ranger' weapon #(#(distanceStepMetres 4) #(damageAmplificationPerStep 0.02))) #('preservation' 'Preservation' weapon #(#(armorRepairOnKill 0.10) #(extraArmorRepairOnHeadshotKill 0.10) #(repairSeconds 5))) #('inSync' 'In Sync' weapon #(#(skillDamageOnWeaponHit 0.15) #(weaponDamageOnSkillUseOrHit 0.15) #(durationSeconds 5) #(dualBuffMultiplier 2))) #('obliterate' 'Obliterate' Chest #(#(weaponDamagePerCriticalHit 0.01) #(durationSeconds 10) #(maxStacks 20))) #('unbreakable' 'Unbreakable' Chest #(#(armorRepairOnDepletion 0.95) #(cooldownSeconds 60))) #('overwatch' 'Overwatch' Chest #(#(coverSeconds 10) #(squadWeaponDamage 0.12) #(squadSkillDamage 0.12) #(persistsOnCoverToCover true))) #('composure' 'Composure' Backpack #(#(inCoverWeaponDamage 0.15))) #('combinedArms' 'Combined Arms' Backpack #(#(skillDamageOnWeaponHit 0.25) #(durationSeconds 3))) #('creepingDeath' 'Creeping Death' Backpack #(#(statusSpreadRadiusMetres 8) #(cooldownSeconds 15))) #('capacitance' 'Capacitance' weapon #(#(maxStacks 40) #(skillDamagePerHitStack 0.015) #(decayDelaySeconds 5) #(decayStacksPerSecond 1) #(weaponDamagePerSkillTier 0.075))) #('incessantChatter' 'Incessant Chatter' weapon #(#(rateOfFirePerEnemyOnReload 0.25) #(radiusMetres 15) #(maxStacks 5) #(magazineRefillOnKill 0.50))) #('disruptorRounds' 'Disruptor Rounds' weapon #(#(maxStacks 50) #(pulseStacks 1) #(disruptStacks 11) #(disorientStacks 26) #(areaStacks 50) #(radiusMetres 10) #(durationSeconds 5) #(shieldDeploymentTriggers false) #(markedKillTriggers true))) #('septicShock' 'Septic Shock' weapon #(#(venomDurationSeconds 10) #(poisonStacks 2) #(disorientStacks 4) #(shockStacks 6) #(damageTakenStacks 8) #(maxStacks 9) #(additionalDamageTaken 0.20) #(statusDurationScalesWithPelletHits true))) #('doctorHome' 'Doctor Home' weapon #(#(markSeconds 5) #(groupArmorRepairOnMarkedKill 0.10) #(grantsBonusArmor false))) #('electromagneticAccelerator' 'Electromagnetic Accelerator' weapon #(#(minimumChargedDamage 0) #(maximumChargedDamage 1))) #('libertyOrDeath' 'Liberty or Death' weapon #(#(weaponDamagePerHitStack 0.02) #(maxStacks 30) #(shieldRepairPerStackOnHeadshot 0.03))) #('pressTheAdvantage' 'Press the Advantage' Chest #(#(requiredPieces 4) #(familyId 'redLotusAssault') #(maxStacks 200) #(highDecayMinimumStacks 101) #(highDecayStacksPerSecond 3))) #('riskManagement' 'Risk Management' Backpack #(#(requiredPieces 4) #(familyId 'redLotusAssault') #(damagePerStack 0.009))) #('proliferation' 'Proliferation' Chest #(#(requiredPieces 4) #(familyId 'jupiterTechnologies') #(spreadRadiusMetres 15) #(durationRefreshFraction 0.75))) #('symptomAggravator' 'Symptom Aggravator' Backpack #(#(requiredPieces 4) #(familyId 'jupiterTechnologies') #(damageAmplificationToStatusTargets 0.30))))
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
