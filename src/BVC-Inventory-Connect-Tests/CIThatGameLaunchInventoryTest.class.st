Class {
	#name : 'CIThatGameLaunchInventoryTest',
	#superclass : 'TestCase',
	#instVars : [
		'directory',
		'service'
	],
	#category : 'BVC-Inventory-Connect-Tests',
	#package : 'BVC-Inventory-Connect-Tests'
}

{ #category : 'helpers' }
CIThatGameLaunchInventoryTest >> gearRowsForFamily: familyId slots: slots catalogue: catalog [
	^ slots
		collect: [ :slot | 
			| identifier spec row |
			identifier := 'gear.launch.' , familyId , '.' , slot asLowercase.
			spec := CIThatGameLaunchCatalog spawnSpecs
					detect: [ :entry | entry key = identifier ].
			row := CIItemGenerator new
					generate: identifier
					type: identifier
					values: spec value
					from: catalog
					using: [ 0 ].
			row equippedSlotIdentifier: slot.
			row ]
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> rowsFor: identity [
	^ (service
		rowsForVerifiedUser: identity
		offset: 0
		limit: 32)
		, (service
				rowsForVerifiedUser: identity
				offset: 32
				limit: 32)
]

{ #category : 'running' }
CIThatGameLaunchInventoryTest >> setUp [
	super setUp.
	directory := FileLocator temp / ('thatgame-inventory-' , UUID new asString).
	directory ensureCreateDirectory
]

{ #category : 'running' }
CIThatGameLaunchInventoryTest >> startInventory [
	| config |
	config := CIInventoryConfiguration new
			identifier: #inventory;
			label: 'Inventory';
			authoritative: true;
			inventorySnapshotPath: (directory / 'inventory.ston') fullName;
			yourself.
	service := CIInventoryService new installWithConfiguration: config.
	service start
]

{ #category : 'running' }
CIThatGameLaunchInventoryTest >> tearDown [
	[ service ifNotNil: [ service stop ] ]
		ensure: [ directory ensureDeleteAll.
			super tearDown ]
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testAttributeCataloguePreservesScopeMissingValuesAndConflicts [
	| attributes rifle value gearMod notes |
	attributes := CIGameItemTypes buildCatalog attributeCatalogue.
	self assert: (attributes definitionsIn: #gearMod) size equals: 11.
	self assert: (attributes definitionsIn: #watch) size equals: 16.
	self assert: (attributes definitionsIn: #statusImmunity) size equals: 10.
	value := (attributes definitionAt: 'weapon.damage') valueFor: #prototypeMaximum.
	self assert: value magnitude equals: 0.225.
	self assert: value unit equals: #fraction.
	self assert: value evidence equals: 'Attribute Info!F2'.
	rifle := attributes definitionAt: 'weapon.class.rifle'.
	self assert: (rifle valueFor: #standardMaximum) status equals: #conflicting.
	self assert: (rifle valueFor: #standardMaximum) magnitude isNil.
	self assert: (rifle valueFor: #weaponsTabMaximum) magnitude equals: 0.17.
	self assert: (rifle valueFor: #prototypeMaximum) rawText equals: '51%%'.
	self
		assert: ((attributes definitionAt: 'weapon.class.pistol') valueFor: #standardMaximum)
				status
		equals: #inapplicable.
	self
		assert: ((attributes definitionAt: 'weapon.minor.optimalRange')
				valueFor: #prototypeMaximum) status
		equals: #unspecified.
	gearMod := attributes definitionAt: 'gearMod.criticalHitChance'.
	self assert: (gearMod valueFor: #standardMaximum) magnitude equals: 0.06.
	self assert: (gearMod valueFor: #prototypeMaximum) magnitude isNil.
	value := (attributes definitionAt: 'immunity.shock')
			valueFor: #immunityThreshold.
	self assert: value magnitude equals: 0.86.
	notes := (attributes definitionAt: 'immunity.shock') notes.
	self assert: (notes first includesSubstring: 'most enemies').
	self
		assert: ((attributes ruleAt: 'skillEfficiency') parameters at: #affectedStats) size
		equals: 6.
	self
		assert: ((attributes ruleAt: 'expertise.skill') parameters at: #exception)
		equals: #Achilles
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testBluescreenStackBandsShieldGateAndMarkedKill [
	| catalog bluescreen result nearby |
	catalog := CIGameItemTypes buildCatalog.
	bluescreen := CIExoticWeaponEncounter
			weapon: 'bluescreen'
			talent: (catalog talentAt: 'disruptorRounds')
			magazineCapacity: nil.
	11
		timesRepeat: [ bluescreen recordBluescreenHitFrom: 'bluescreen' on: 'marked' ].
	self
		assertEmpty: (bluescreen
				bluescreenApplicationsOnDeployingShield: true
				nearbyByMarkedTarget: Dictionary new).
	result := bluescreen
			bluescreenApplicationsOnDeployingShield: false
			nearbyByMarkedTarget: Dictionary new.
	self assert: (result collect: #statusIdentifier) equals: #(pulse disrupt).
	self
		assert: (result allSatisfy: [ :application | application durationSeconds = 5 ]).
	self
		assertEmpty: (bluescreen
				bluescreenApplicationsOnDeployingShield: false
				nearbyByMarkedTarget: Dictionary new).
	52
		timesRepeat: [ bluescreen recordBluescreenHitFrom: 'bluescreen' on: 'marked' ].
	nearby := {'marked'
				-> {'edge' -> 10.
						'outside' -> 11} asDictionary} asDictionary.
	self
		assertEmpty: (bluescreen
				bluescreenApplicationsOnKillOf: 'unmarked'
				nearbyByMarkedTarget: nearby).
	result := bluescreen
			bluescreenApplicationsOnKillOf: 'marked'
			nearbyByMarkedTarget: nearby.
	self
		assert: (result collect: #statusIdentifier)
		equals: #(pulse disrupt disorient).
	self
		assert: (result allSatisfy: [ :application | application targetIdentifier = 'edge' ])
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testCapacitorAndLibertyHitStacksUseWorkbookParameters [
	| catalog capacitor liberty |
	catalog := CIGameItemTypes buildCatalog.
	capacitor := CIExoticWeaponEncounter
			weapon: 'capacitor'
			talent: (catalog talentAt: 'capacitance')
			magazineCapacity: 41.
	50 timesRepeat: [ capacitor recordEnemyHitFrom: 'capacitor' at: 0 ].
	self assert: (capacitor capacitorSkillDamageBonusAt: 5) closeTo: 0.60.
	self assert: (capacitor capacitorSkillDamageBonusAt: 6) closeTo: 0.585.
	self assert: (capacitor capacitorSkillDamageBonusAt: 7) closeTo: 0.57.
	self assert: (capacitor capacitorSkillDamageBonusAt: 7) closeTo: 0.57.
	capacitor recordEnemyHitFrom: 'capacitor' at: 7.
	self assert: (capacitor capacitorSkillDamageBonusAt: 12) closeTo: 0.585.
	self assert: (capacitor capacitorWeaponDamageBonusAtSkillTier: 6) closeTo: 0.45.
	liberty := CIExoticWeaponEncounter
			weapon: 'liberty'
			talent: (catalog talentAt: 'libertyOrDeath')
			magazineCapacity: 8.
	35 timesRepeat: [ liberty recordEnemyHitFrom: 'liberty' at: 0 ].
	self assert: liberty libertyWeaponDamageBonus closeTo: 0.60.
	self assert: (liberty consumeLibertyStacksOnHeadshotFrom: 'other') equals: 0.
	self
		assert: (liberty consumeLibertyStacksOnHeadshotFrom: 'liberty')
		closeTo: 0.90.
	self assert: liberty libertyWeaponDamageBonus equals: 0
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testChatterboxReloadAndRefillUseEffectiveMagazine [
	| catalog owner row encounter distances |
	self startInventory.
	catalog := CIGameItemTypes buildCatalog.
	owner := 'chatterbox-combat'.
	row := CIItemGenerator new
			generate: 'chatterbox'
			type: 'weapon.launch.chatterbox'
			values: (Dictionary new
					at: 'weaponDamage' put: 0.1;
					yourself)
			from: catalog
			using: [ 0 ].
	row equippedSlotIdentifier: 'RangedWeapon'.
	service replaceReadRows: {row} forOwner: owner.
	encounter := service
			exoticWeaponEncounterFor: 'chatterbox'
			forVerifiedUser: owner.
	distances := {'a' -> 4.
			'b' -> 15.
			'c' -> 16} asDictionary.
	self
		deny: (encounter recordReloadFrom: 'another' enemiesAtDistances: distances).
	self assert: encounter rateOfFireBonus equals: 0.
	self
		assert: (encounter recordReloadFrom: 'chatterbox' enemiesAtDistances: distances).
	self assert: encounter rateOfFireBonus equals: 0.50.
	self
		assert: (encounter magazineRefillOnKillFrom: 'chatterbox' remaining: 8)
		equals: 30.
	self
		assert: (encounter magazineRefillOnKillFrom: 'chatterbox' remaining: 55)
		equals: 5.
	self assert: encounter rateOfFireBonus equals: 0.50.
	1 to: 8 do: [ :index | distances at: index put: 3 ].
	encounter recordReloadFrom: 'chatterbox' enemiesAtDistances: distances.
	self assert: encounter rateOfFireBonus equals: 1.25.
	encounter recordMagazineEndedFrom: 'chatterbox'.
	self assert: encounter rateOfFireBonus equals: 0
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testClassifiedUpgradesFollowEquippedSlots [
	| catalog evaluator rows chest backup red jupiter |
	catalog := CIGameItemTypes buildCatalog.
	evaluator := CILoadoutFamilyEvaluator new.
	rows := self
			gearRowsForFamily: 'redLotusAssault'
			slots: #('Chest' 'Backpack' 'Mask' 'Gloves' 'KneePads')
			catalogue: catalog.
	chest := rows first.
	backup := rows second.
	red := [ (evaluator
			evaluateRows: rows
			catalogue: catalog
			mode: #pve)
			detect: [ :activation | activation family id = 'redLotusAssault' ] ].
	chest equippedSlotIdentifier: nil.
	self assert: red value equippedCount equals: 4.
	self
		assert: (red value activeTalents collect: #id)
		equals: #('strikersGamble' 'riskManagement').
	self assert: (red value effectiveSetParameters at: #maxStacks) equals: 100.
	self
		assert: (red value effectiveSetParameters at: #damagePerStack)
		equals: 0.009.
	chest equippedSlotIdentifier: 'Chest'.
	self assert: (red value effectiveSetParameters at: #maxStacks) equals: 200.
	chest equippedSlotIdentifier: nil.
	backup equippedSlotIdentifier: nil.
	self assertEmpty: red value activeTalents.
	self assert: red value effectiveSetParameters isNil.
	rows := self
			gearRowsForFamily: 'jupiterTechnologies'
			slots: #('Chest' 'Backpack' 'Mask' 'Gloves')
			catalogue: catalog.
	jupiter := (evaluator
			evaluateRows: rows
			catalogue: catalog
			mode: #pve)
			detect: [ :activation | activation family id = 'jupiterTechnologies' ].
	self
		assert: (jupiter effectiveSetParameters at: #spreadRadiusMetres)
		equals: 15.
	self
		assert: (jupiter effectiveSetParameters at: #durationRefreshFraction)
		equals: 0.75.
	self
		assert: (jupiter effectiveSetParameters at: #damageAmplificationToStatusTargets)
		equals: 0.30
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testDoctorHomeMarksExpireAndNemesisKeepsItsDocumentedBounds [
	| catalog doctor nemesis pickup |
	catalog := CIGameItemTypes buildCatalog.
	doctor := CIExoticWeaponEncounter
			weapon: 'doctor'
			talent: (catalog talentAt: 'doctorHome')
			magazineCapacity: 10.
	self
		deny: (doctor
				recordDoctorHomeHitFrom: 'other'
				on: 'target'
				at: 0).
	self assert: (doctor doctorHomePickupOnKillOf: 'target' at: 0) isNil.
	self
		assert: (doctor
				recordDoctorHomeHitFrom: 'doctor'
				on: 'target'
				at: 1).
	pickup := doctor doctorHomePickupOnKillOf: 'target' at: 5.
	self assert: pickup fraction equals: 0.10.
	self deny: pickup grantsBonusArmor.
	self assert: (doctor doctorHomePickupOnKillOf: 'target' at: 5) isNil.
	doctor
		recordDoctorHomeHitFrom: 'doctor'
		on: 'expired'
		at: 5.
	self assert: (doctor doctorHomePickupOnKillOf: 'expired' at: 10) isNil.
	nemesis := CIExoticWeaponEncounter
			weapon: 'nemesis'
			talent: (catalog talentAt: 'electromagneticAccelerator')
			magazineCapacity: nil.
	self assert: nemesis nemesisChargeDamageBounds equals: #(0 1).
	self
		assert: (nemesis damageMultiplierForResolvedNemesisCharge: 0.5)
		equals: 0.5.
	self
		should: [ nemesis damageMultiplierForResolvedNemesisCharge: 1.1 ]
		raise: Error
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testEquippedCreepingDeathSpreadsWithCooldown [
	| owner catalog row encounter application distances targets |
	self startInventory.
	owner := 'gear-talent-owner'.
	catalog := CIGameItemTypes buildCatalog.
	row := (catalog typeAt: 'gear.launch.morrowWorks.backpack')
			inventoryItem: 'pack'
			values: (Dictionary new
					at: 'skillTier' put: 1;
					yourself)
			talentIdentifier: 'perfectCreepingDeath'.
	service replaceReadRows: {row} forOwner: owner.
	self
		should: [ service pveGearTalentEncounterFor: 'pack' forVerifiedUser: owner ]
		raise: Error.
	row := row copy.
	row equippedSlotIdentifier: 'Backpack'.
	service replaceReadRows: {row} forOwner: owner.
	encounter := service pveGearTalentEncounterFor: 'pack' forVerifiedUser: owner.
	application := CICombatStatusApplication
			status: 'burn'
			target: 'primary'
			durationSeconds: 5.
	distances := {'primary' -> 0.
			'edge' -> 10.
			'outside' -> 11} asDictionary.
	targets := encounter
			spreadStatus: application
			targetsAtDistances: distances
			at: 0.
	self assert: (targets collect: #targetIdentifier) equals: #('edge').
	self assert: targets first durationSeconds equals: 5.
	self
		assertEmpty: (encounter
				spreadStatus: application
				targetsAtDistances: distances
				at: 9).
	self
		assert: (encounter
				spreadStatus: application
				targetsAtDistances: distances
				at: 10) size
		equals: 1
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testFuturePerfectionUsesItsOwnStackCapAndDuration [
	| catalog scanner encounter |
	catalog := CIGameItemTypes buildCatalog.
	scanner := (catalog gadgetFamilyNamed: 'Pulse') variantNamed: 'Scanner'.
	encounter := CIGadgetEncounter
			variant: scanner
			baseTier: 0
			weapon: 'weapon'
			talent: (catalog talentAt: 'futurePerfection').
	4
		timesRepeat: [ self assert: (encounter recordWeaponKillFrom: 'weapon' at: 0) ].
	self deny: (encounter recordWeaponKillFrom: 'weapon' at: 1).
	self assert: (encounter effectiveTierAt: 18) equals: 4.
	self assert: (encounter effectiveTierAt: 19) equals: 0.
	self should: [ encounter effectiveTierAt: 18 ] raise: Error
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testGadgetEncounterOverchargeExpiresAndHonorsCooldown [
	| catalog owner type gadget weapon gear encounter |
	self startInventory.
	catalog := CIGameItemTypes buildCatalog.
	owner := 'overcharge-test-owner'.
	type := catalog typeAt: 'gadget.workbook.pulse.scanner'.
	gadget := type inventoryItem: 'scanner' values: Dictionary new.
	gadget equippedSlotIdentifier: 'GadgetLeft'.
	weapon := (catalog typeAt: 'weapon.launch.akM')
			inventoryItem: 'weapon'
			values: (Dictionary new
					at: 'weaponDamage' put: 0.1;
					yourself)
			talentIdentifier: 'futurePerfect'.
	weapon equippedSlotIdentifier: 'RangedWeapon'.
	gear := self
			gearRowsForFamily: 'morrowWorks'
			slots: #('Mask' 'Chest' 'Backpack' 'Gloves' 'KneePads')
			catalogue: catalog.
	service
		replaceReadRows: {gadget.
				weapon} , gear
		forOwner: owner.
	encounter := service
			gadgetEncounterFor: 'scanner'
			weapon: 'weapon'
			forVerifiedUser: owner.
	self assert: (encounter effectiveTierAt: 0) equals: 5.
	self deny: (encounter recordWeaponKillFrom: 'another' at: 0).
	self assert: (encounter recordWeaponKillFrom: 'weapon' at: 0).
	self assert: (encounter effectiveTierAt: 0) equals: 6.
	self assert: (encounter recordWeaponKillFrom: 'weapon' at: 1).
	self assert: (encounter effectiveTierAt: 1) equals: #overcharge.
	self assert: ((encounter statsAt: 1) at: 'Duration') equals: 24.
	self assert: (encounter overchargeEffectsAt: 1) notEmpty.
	self deny: (encounter recordWeaponKillFrom: 'weapon' at: 14).
	self assert: (encounter effectiveTierAt: 16) equals: 5.
	self assertEmpty: (encounter overchargeEffectsAt: 16).
	self assert: (encounter recordWeaponKillFrom: 'weapon' at: 90).
	self deny: (encounter recordWeaponKillFrom: 'weapon' at: 90).
	self assert: (encounter recordWeaponKillFrom: 'weapon' at: 91).
	self assert: (encounter effectiveTierAt: 91) equals: #overcharge
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testGearFamilyThresholdsAndModeValues [
	| catalog evaluator rows pve pvp rook |
	catalog := CIGameItemTypes buildCatalog.
	evaluator := CILoadoutFamilyEvaluator new.
	self
		assert: (catalog gearFamilies
				count: [ :family | (family id beginsWith: 'brand.workbook.') not ])
		equals: 5.
	rows := self
			gearRowsForFamily: 'rookStandard'
			slots: #('Mask' 'Gloves')
			catalogue: catalog.
	rook := [ :mode | 
		(evaluator
			evaluateRows: rows
			catalogue: catalog
			mode: mode) detect: [ :activation | activation family id = 'rookStandard' ] ].
	pve := rook value: #pve.
	pvp := rook value: #pvp.
	self assert: (pve activeTiers collect: #pieceCount) equals: #(1 2).
	self
		assert: (pve modifiers detect: [ :effect | effect stat = #hazardProtection ]) magnitude
		equals: 0.20.
	self
		assert: (pvp modifiers detect: [ :effect | effect stat = #hazardProtection ]) magnitude
		equals: 0.15.
	self assert: pvp activeTiers last evidence equals: 'Brandsets!F6,L6'
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testGearTalentTimersAndThresholds [
	| catalog make obliterate armor overwatch composure arms |
	catalog := CIGameItemTypes buildCatalog.
	make := [ :id | CIGearTalentEncounter talent: (catalog talentAt: id) ].
	obliterate := make value: 'perfectObliterate'.
	obliterate recordEnemyShotCritical: false at: 0.
	self assert: (obliterate totalWeaponDamageBonusAt: 0) equals: 0.
	25 timesRepeat: [ obliterate recordEnemyShotCritical: true at: 1 ].
	self assert: (obliterate totalWeaponDamageBonusAt: 10) closeTo: 0.24.
	self assert: (obliterate totalWeaponDamageBonusAt: 11) equals: 0.
	armor := make value: 'unbreakable'.
	self assert: (armor armorRepairFractionOnDepletionAt: 0) equals: 0.95.
	self assert: (armor armorRepairFractionOnDepletionAt: 59) equals: 0.
	self assert: (armor armorRepairFractionOnDepletionAt: 60) equals: 0.95.
	self
		assert: ((make value: 'perfectUnbreakable') armorRepairFractionOnDepletionAt: 0)
		equals: 1.
	overwatch := make value: 'perfectOverwatch'.
	overwatch coverState: #inCover at: 0.
	self assert: ((overwatch squadDamageBonusesAt: 7) at: #weaponDamage) equals: 0.
	overwatch coverState: #coverMove at: 8.
	self
		assert: ((overwatch squadDamageBonusesAt: 18) at: #skillDamage)
		equals: 0.14.
	overwatch coverState: #inCover at: 19.
	self
		assert: ((overwatch squadDamageBonusesAt: 19) at: #weaponDamage)
		equals: 0.14.
	overwatch coverState: #exposed at: 20.
	self assert: ((overwatch squadDamageBonusesAt: 20) at: #weaponDamage) equals: 0.
	composure := make value: 'perfectComposure'.
	composure coverState: #inCover at: 0.
	self assert: (composure totalWeaponDamageBonusAt: 0) equals: 0.20.
	composure coverState: #coverMove at: 1.
	self assert: (composure totalWeaponDamageBonusAt: 1) equals: 0.
	arms := make value: 'perfectCombinedArms'.
	arms recordEnemyShotCritical: false at: 0.
	self assert: (arms totalSkillDamageBonusAt: 2) equals: 0.30.
	self assert: (arms totalSkillDamageBonusAt: 3) equals: 0
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testInSyncEffectsOverlapAndExpireIndependently [
	| owner catalog weapon encounter |
	self startInventory.
	owner := 'weapon-talent-owner'.
	catalog := CIGameItemTypes buildCatalog.
	weapon := (catalog typeAt: 'weapon.launch.akM')
			inventoryItem: 'weapon'
			values: (Dictionary new
					at: 'weaponDamage' put: 0.1;
					yourself)
			talentIdentifier: 'perfectInSync'.
	service replaceReadRows: {weapon} forOwner: owner.
	self
		should: [ service weaponTalentEncounterFor: 'weapon' forVerifiedUser: owner ]
		raise: Error.
	weapon := weapon copy.
	weapon equippedSlotIdentifier: 'RangedWeapon'.
	service replaceReadRows: {weapon} forOwner: owner.
	encounter := service weaponTalentEncounterFor: 'weapon' forVerifiedUser: owner.
	encounter
		recordEnemyHitFrom: 'weapon'
		critical: false
		at: 1.
	self assert: ((encounter damageBonusesAt: 1) at: #skillDamage) equals: 0.20.
	encounter recordGadgetUseOrDamageAt: 3.
	self assert: ((encounter damageBonusesAt: 3) at: #skillDamage) equals: 0.40.
	self assert: ((encounter damageBonusesAt: 3) at: #weaponDamage) equals: 0.40.
	self assert: ((encounter damageBonusesAt: 6) at: #skillDamage) equals: 0.
	self assert: ((encounter damageBonusesAt: 6) at: #weaponDamage) equals: 0.20.
	self assert: ((encounter damageBonusesAt: 8) at: #weaponDamage) equals: 0
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testInstalledModEffectsUseWorkbookMagazineAndOwnedRoll [
	| catalog store owner value chatterbox capacitor vest gearMod report magazine gear graph row |
	catalog := CIGameItemTypes buildCatalog.
	store := CIInventoryReadStore new.
	owner := 'mod-evaluation-owner'.
	value := Dictionary new
			at: 'weaponDamage' put: 0.1;
			yourself.
	chatterbox := store
			grantItem: 'chatterbox'
			type: 'weapon.launch.chatterbox'
			values: value
			from: catalog
			forOwner: owner.
	capacitor := store
			grantItem: 'capacitor'
			type: 'weapon.launch.capacitor'
			values: value
			from: catalog
			forOwner: owner.
	store
		grantItem: 'vest'
		type: 'gear.launch.vossAndVale.chest'
		values: value
		from: catalog
		forOwner: owner.
	gearMod := store
			grantGearMod: 'gear-mod'
			definition: 'gearMod.criticalHitChance'
			tier: 2
			value: 0.04
			from: catalog
			forOwner: owner.
	vest := store
			installMod: gearMod itemIdentifier
			on: 'vest'
			socket: 'gearMod'
			from: catalog
			forOwner: owner.
	report := CIEquipmentModEvaluator new
			evaluateEquipment: {chatterbox.
					capacitor.
					vest}
			owned: (store allRowsForOwner: owner)
			catalogue: catalog modCatalogue.
	self assertEmpty: report unresolved.
	self
		assert: (report
				magazineCapacityFor: chatterbox
				base: (catalog typeAt: chatterbox definitionIdentifier) baseMagazineCapacity)
		equals: 60.
	self
		assert: (report
				magazineCapacityFor: capacitor
				base: (catalog typeAt: capacitor definitionIdentifier) baseMagazineCapacity)
		equals: 41.
	magazine := (report contributionsFor: #magazineCapacity on: 'chatterbox') first.
	self assert: magazine value equals: 10.
	self assert: magazine evidence equals: 'Weapons Named + Exotics!F130'.
	gear := (report contributionsFor: #criticalHitChance on: 'vest') first.
	self assert: gear value equals: 0.04.
	self assert: gear operation equals: #percent.
	row := chatterbox copy.
	row equippedSlotIdentifier: 'RangedWeapon'.
	graph := CIInventoryProfileGraph
			forVerifiedUser: owner
			rows: {row.
					vest.
					gearMod}
			savedSets: Dictionary new
			catalog: catalog.
	self assert: ((STON toString: graph) includesSubstring: '60 rounds').
	row := vest withMod: 'missing-mod' inSocket: 'gearMod'.
	report := CIEquipmentModEvaluator new
			evaluateEquipment: {row}
			owned: #()
			catalogue: catalog modCatalogue.
	self assertEmpty: report contributions.
	self assert: report unresolved equals: #(#('vest' 'gearMod' 'missing-mod'))
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testJupiterCombatSpreadUsesRangeAndDocumentedRefresh [
	| owner catalog rows encounter statuses targets result |
	self startInventory.
	owner := 'jupiter-combat'.
	catalog := CIGameItemTypes buildCatalog.
	rows := self
			gearRowsForFamily: 'jupiterTechnologies'
			slots: #('Mask' 'Chest' 'Backpack' 'Gloves' 'KneePads')
			catalogue: catalog.
	rows second equippedSlotIdentifier: nil.
	service replaceReadRows: rows forOwner: owner.
	encounter := service classifiedEncounterForVerifiedUser: owner mode: #pve.
	statuses := {CICombatStatusApplication
				status: 'burn'
				target: 'defeated'
				durationSeconds: 8.
			CICombatStatusApplication
				status: 'shock'
				target: 'another'
				durationSeconds: 6}.
	targets := {'defeated' -> 0.
			'ten' -> 10.
			'fifteen' -> 15.
			'outside' -> 16} asDictionary.
	result := encounter
			spreadOnKillOf: 'defeated'
			statuses: statuses
			targetsAtDistances: targets.
	self assert: (result collect: #targetIdentifier) equals: #('ten').
	self assert: result first statusIdentifier equals: 'burn'.
	self assert: result first durationSeconds equals: 4.
	self
		assert: (encounter jupiterDamageMultiplierForStatusAffected: true)
		equals: 1.30.
	self
		assert: (encounter jupiterDamageMultiplierForStatusAffected: false)
		equals: 1.
	rows second equippedSlotIdentifier: 'Chest'.
	rows third equippedSlotIdentifier: nil.
	service replaceReadRows: rows forOwner: owner.
	service
		updateClassifiedEncounter: encounter
		forVerifiedUser: owner
		mode: #pve.
	result := encounter
			spreadOnKillOf: 'defeated'
			statuses: statuses
			targetsAtDistances: targets.
	self
		assert: (result collect: #targetIdentifier) asSet
		equals: #('ten' 'fifteen') asSet.
	self
		assert: (result allSatisfy: [ :application | application durationSeconds = 6 ]).
	self
		assert: (encounter jupiterDamageMultiplierForStatusAffected: true)
		equals: 1.
	rows second equippedSlotIdentifier: nil.
	service replaceReadRows: rows forOwner: owner.
	service
		updateClassifiedEncounter: encounter
		forVerifiedUser: owner
		mode: #pve.
	self
		assertEmpty: (encounter
				spreadOnKillOf: 'defeated'
				statuses: statuses
				targetsAtDistances: targets)
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testLaunchInventoryAndTalentsSurviveRestart [
	| owner catalog before after |
	owner := 'launch-inventory-owner'.
	catalog := CIGameItemTypes buildCatalog.
	self startInventory.
	self
		assert: (service provisionLaunchInventoryForVerifiedUser: owner)
		equals: 53.
	before := (self rowsFor: owner)
			collect: [ :item | 
				{item itemIdentifier.
					item definitionIdentifier.
					item talentIdentifier} ].
	self assert: (before count: [ :entry | entry third notNil ]) equals: 38.
	before
		do: [ :entry | 
			| pool |
			pool := catalog talentPoolFor: entry second.
			pool
				ifEmpty: [ self assert: entry third isNil ]
				ifNotEmpty: [ self assert: (pool includes: entry third) ] ].
	service stop.
	service := nil.
	self startInventory.
	after := (self rowsFor: owner)
			collect: [ :item | 
				{item itemIdentifier.
					item definitionIdentifier.
					item talentIdentifier} ].
	self assert: after equals: before.
	self assert: (service provisionLaunchInventoryForVerifiedUser: owner) equals: 0.
	self assertEmpty: (self rowsFor: 'another-owner')
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testLootAwardPersistsSelectionAndGeneratedTalent [
	| catalog loot pool entries owner store path award samples calls reloaded noValues values |
	catalog := CIGameItemTypes buildCatalog.
	loot := catalog lootCatalogue.
	entries := #('weapon.launch.akM' 'weapon.launch.scorpio')
			collect: [ :id | 
				CILootPoolEntry
					item: (catalog typeAt: id)
					weight: 1
					requiring: nil
					evidence: 'Test fixture' ].
	pool := CILootPool
			id: 'testLoot'
			source: (loot poolAt: 'exoticCaches') source
			entries: entries
			complete: true.
	loot register: pool.
	owner := 'loot-test-owner'.
	path := (directory / 'loot.ston') fullName.
	store := CIInventorySnapshotStore at: path.
	noValues := [ :type | Dictionary new ].
	self
		should: [ store
				grantLoot: 'failed'
				pool: 'testLoot'
				valuesFrom: noValues
				satisfying: [ :entry | true ]
				from: catalog
				forOwner: owner
				using: [ 0.0 ] ]
		raise: Error.
	self assertEmpty: (store allRowsForOwner: owner).
	self assert: path asFileReference exists not.
	values := [ :type | 
		Dictionary new
			at: 'weaponDamage' put: 0.1;
			yourself ].
	calls := 0.
	samples := [ calls := calls + 1.
		#(0.2 0.0) at: calls ].
	award := store
			grantLoot: 'loot-award'
			pool: 'testLoot'
			valuesFrom: values
			satisfying: [ :entry | true ]
			from: catalog
			forOwner: owner
			using: samples.
	self assert: calls equals: 2.
	self assert: award definitionIdentifier equals: 'weapon.launch.akM'.
	self assert: award talentIdentifier equals: 'optimist'.
	reloaded := ((CIInventorySnapshotStore at: path) allRowsForOwner: owner) first.
	self assert: reloaded itemIdentifier equals: award itemIdentifier.
	self assert: reloaded lootPoolIdentifier equals: 'testLoot'.
	self assert: reloaded talentIdentifier equals: award talentIdentifier.
	self assert: reloaded comparisonStats first value equals: 0.1
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testNamedGearLayoutsEnforceFixedRollsExclusionsAndSocketCounts [
	| catalog type layout path store owner punch chill missing roll snapshot |
	catalog := CIGameItemTypes buildCatalog.
	type := catalog typeAt: 'gear.workbook.punchDrunk'.
	layout := type generationLayout.
	self assert: (layout slots collect: #id) equals: #('core' 'minor1' 'minor2').
	self assert: layout slots second fixedValue equals: 0.20.
	self
		deny: (layout slots third eligibleAttributeIds includes: 'gear.minor.headshotDamage').
	self assert: (type sourceInformation at: #acquisition) equals: 'LZ'.
	path := (directory / 'named-gear.ston') fullName.
	store := CIInventorySnapshotStore at: path.
	owner := 'named-layout-owner'.
	missing := Dictionary new
			at: 'core' put: 0.10;
			yourself.
	self
		should: [ store
				grantItem: 'missing'
				type: type id
				values: missing
				from: catalog
				forOwner: owner ]
		raise: Error.
	roll := CIGearAttributeRoll attribute: 'gear.minor.headshotDamage' value: 0.05.
	self
		should: [ store
				grantItem: 'excluded'
				type: type id
				values: (missing copy
						at: 'minor2' put: roll;
						yourself)
				from: catalog
				forOwner: owner ]
		raise: Error.
	roll := CIGearAttributeRoll
			attribute: 'gear.minor.criticalHitChance'
			value: 0.07.
	self
		should: [ store
				grantItem: 'over-cap'
				type: type id
				values: (missing copy
						at: 'minor2' put: roll;
						yourself)
				from: catalog
				forOwner: owner ]
		raise: Error.
	self assertEmpty: (store allRowsForOwner: owner).
	roll := CIGearAttributeRoll
			attribute: 'gear.minor.criticalHitChance'
			value: 0.06.
	punch := store
			grantItem: 'punch'
			type: type id
			values: (missing copy
					at: 'minor2' put: roll;
					yourself)
			from: catalog
			forOwner: owner.
	self assert: punch rolledAttributes first value equals: 0.20.
	self assert: punch rolledAttributes second value equals: 0.06.
	self assert: (punch modSlots collect: #slotIdentifier) equals: #('gearMod1').
	chill := store
			grantItem: 'chill'
			type: 'gear.workbook.chillOut'
			values: (Dictionary new
					at: 'core' put: 170000;
					at: 'minor1' put: roll;
					yourself)
			from: catalog
			forOwner: owner.
	self assert: chill rolledAttributes size equals: 1.
	self
		assert: (chill modSlots collect: #slotIdentifier)
		equals: #('gearMod1' 'gearMod2').
	snapshot := (CIInventorySnapshotStore at: path) allRowsForOwner: owner.
	self
		assert: (snapshot first rolledAttributes collect: #generationSlotIdentifier)
		equals: #('minor1' 'minor2').
	self
		assert: snapshot second primaryAttribute generationSlotIdentifier
		equals: 'core'
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testNamedGearReferencesPreserveSplitRowsAndExposeSupportedLayouts [
	| catalog reference rows store minor1 minor2 values courier gloves |
	catalog := CIGameItemTypes buildCatalog.
	rows := catalog namedGearReferences.
	self assert: (rows count: [ :each | each kind = #named ]) equals: 65.
	self assert: (rows count: [ :each | each kind = #exotic ]) equals: 32.
	self
		assert: (rows count: [ :each | each itemDefinitionIdentifier notNil ])
		equals: 10.
	reference := catalog namedGearReferenceAt: 'Vile'.
	self assert: (reference fieldAt: #talent) equals: 'Toxic Delivery'.
	self
		assert: (reference evidenceForField: #name)
		equals: 'Gear Named + Exotics!D69'.
	self
		assert: (reference evidenceForField: #talent)
		equals: 'Gear Named + Exotics!F68'.
	reference := catalog namedGearReferenceAt: 'Forge'.
	self assert: reference slot equals: 'Holster'.
	self assert: reference itemDefinitionIdentifier isNil.
	reference := catalog namedGearReferenceAt: 'The Courier'.
	self
		assert: reference itemDefinitionIdentifier
		equals: 'gear.workbook.theCourier'.
	store := CIInventoryReadStore new.
	minor1 := CIGearAttributeRoll
			attribute: 'gear.minor.criticalHitChance'
			value: 0.05.
	minor2 := CIGearAttributeRoll
			attribute: 'gear.minor.criticalHitDamage'
			value: 0.10.
	values := Dictionary new
			at: 'core' put: 50000;
			at: 'minor1' put: minor1;
			at: 'minor2' put: minor2;
			yourself.
	courier := store
			grantItem: 'courier'
			type: reference itemDefinitionIdentifier
			values: values
			from: catalog
			forOwner: 'owner'
			using: [ self error: 'Fixed talent must not draw' ].
	self assert: courier talentIdentifier equals: 'perfectCreepingDeath'.
	self assert: courier gearSlotIdentifier equals: 'Backpack'.
	self assert: courier modSlots size equals: 1.
	gloves := store
			grantItem: 'gloves'
			type: 'gear.workbook.firmHandshake'
			values: (Dictionary new
					at: 'core' put: 0.10;
					at: 'minor2' put: minor1;
					yourself)
			from: catalog
			forOwner: 'owner'.
	self assert: gloves gearSlotIdentifier equals: 'Gloves'.
	self assert: gloves rolledAttributes first value equals: 0.16.
	self assertEmpty: gloves modSlots
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testPvPGearTalentProfilesPreserveConflictsAndUseDocumentedOverrides [
	| catalog normal perfect conflicting missing owner row encounter cover |
	catalog := CIGameItemTypes buildCatalog.
	normal := catalog talentAt: 'obliterate'.
	perfect := catalog talentAt: 'perfectObliterate'.
	self assert: ((normal parametersForMode: #pvp) at: #maxStacks) equals: 16.
	self assert: ((perfect parametersForMode: #pvp) at: #maxStacks) equals: 20.
	self assert: ((perfect parametersForMode: #pve) at: #maxStacks) equals: 24.
	conflicting := (catalog talentAt: 'unbreakable') modeProfileFor: #pvp.
	self assert: conflicting status equals: #conflicting.
	self
		assert: ((conflicting sources at: 'Gear Talents!H14') includesSubstring: '50%').
	self
		assert: ((conflicting sources at: 'Gear Talents!K14') includesSubstring: '30%').
	self assert: ((catalog talentAt: 'unbreakable') parametersForMode: #pvp) isNil.
	self
		should: [ CIGearTalentEncounter talent: (catalog talentAt: 'unbreakable') mode: #pvp ]
		raise: Error.
	missing := (catalog talentAt: 'creepingDeath') modeProfileFor: #pvp.
	self assert: missing status equals: #unspecified.
	self assert: (missing sources at: 'Gear Talents!K47') isNil.
	self startInventory.
	owner := 'pvp-talent-owner'.
	row := (catalog typeAt: 'gear.launch.vossAndVale.chest')
			inventoryItem: 'vest'
			values: (Dictionary new
					at: 'weaponDamage' put: 0.1;
					yourself)
			talentIdentifier: 'obliterate'.
	row equippedSlotIdentifier: 'Chest'.
	service replaceReadRows: {row} forOwner: owner.
	encounter := service
			gearTalentEncounterFor: 'vest'
			forVerifiedUser: owner
			mode: #pvp.
	20 timesRepeat: [ encounter recordEnemyShotCritical: true at: 0 ].
	self assert: (encounter totalWeaponDamageBonusAt: 0) closeTo: 0.16.
	self assert: (encounter totalWeaponDamageBonusAt: 10) equals: 0.
	cover := CIGearTalentEncounter
			talent: (catalog talentAt: 'perfectOverwatch')
			mode: #pvp.
	cover coverState: #inCover at: 0.
	self assert: ((cover squadDamageBonusesAt: 5) at: #weaponDamage) equals: 0.
	self assert: ((cover squadDamageBonusesAt: 6) at: #weaponDamage) equals: 0.18
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testRedLotusCombatStacksDecayAndRefreshWithLoadout [
	| owner catalog rows encounter |
	self startInventory.
	owner := 'red-lotus-combat'.
	catalog := CIGameItemTypes buildCatalog.
	rows := self
			gearRowsForFamily: 'redLotusAssault'
			slots: #('Mask' 'Chest' 'Backpack' 'Gloves' 'KneePads')
			catalogue: catalog.
	service replaceReadRows: rows forOwner: owner.
	encounter := service classifiedEncounterForVerifiedUser: owner mode: #pve.
	50 timesRepeat: [ encounter recordWeaponHit ].
	self assert: encounter decayTick equals: 49.
	2 timesRepeat: [ encounter recordWeaponHit ].
	self assert: encounter decayTick equals: 49.
	300 timesRepeat: [ encounter recordWeaponHit ].
	self assert: encounter recordWeaponHit equals: 200.
	self assert: (encounter redLotusDamageMultiplier - 2.8) abs < 0.0001.
	self assert: encounter decayTick equals: 197.
	rows second equippedSlotIdentifier: nil.
	service replaceReadRows: rows forOwner: owner.
	service
		updateClassifiedEncounter: encounter
		forVerifiedUser: owner
		mode: #pve.
	self assert: encounter recordWeaponHit equals: 100.
	self assert: (encounter redLotusDamageMultiplier - 1.9) abs < 0.0001.
	rows third equippedSlotIdentifier: nil.
	service replaceReadRows: rows forOwner: owner.
	service
		updateClassifiedEncounter: encounter
		forVerifiedUser: owner
		mode: #pve.
	self assert: encounter recordWeaponHit equals: 0.
	self assert: encounter redLotusDamageMultiplier equals: 1
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testSavedSpecializationChangesGadgetTierAndSurvivesRestart [
	| owner catalog gadget loadout stats graph |
	self startInventory.
	owner := 'specialization-save-owner'.
	catalog := CIGameItemTypes buildCatalog.
	gadget := (catalog typeAt: 'gadget.workbook.pulse.scanner')
			inventoryItem: 'scanner'
			values: Dictionary new.
	gadget equippedSlotIdentifier: 'GadgetLeft'.
	service replaceReadRows: {gadget} forOwner: owner.
	self
		assert: ((service workbookGadgetStatsFor: 'scanner' forVerifiedUser: owner)
				at: 'Duration')
		equals: 8.
	service
		selectSpecialization: 'Technician'
		perks: #('technician.amped')
		forVerifiedUser: owner.
	self
		should: [ service
				selectSpecialization: 'Gunner'
				perks: #('technician.amped')
				forVerifiedUser: owner ]
		raise: Error.
	self assert: (service specializationLoadoutForVerifiedUser: 'other') isNil.
	service stop.
	service := nil.
	self startInventory.
	loadout := service specializationLoadoutForVerifiedUser: owner.
	self assert: loadout definition name equals: 'Technician'.
	self assert: (loadout selectedPerks collect: #id) equals: #('technician.amped').
	stats := service workbookGadgetStatsFor: 'scanner' forVerifiedUser: owner.
	self assert: (stats at: 'Duration') closeTo: 9.2.
	graph := service profileGraphForVerifiedUser: owner.
	self assert: ((STON toString: graph) includesSubstring: '9.200 s').
	service clearSpecializationForVerifiedUser: owner.
	self assert: (service specializationLoadoutForVerifiedUser: owner) isNil.
	self
		assert: ((service workbookGadgetStatsFor: 'scanner' forVerifiedUser: owner)
				at: 'Duration')
		equals: 8
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testScorpioVenomThresholdsAndStackNineRefresh [
	| catalog scorpio outcome |
	catalog := CIGameItemTypes buildCatalog.
	scorpio := CIExoticWeaponEncounter
			weapon: 'scorpio'
			talent: (catalog talentAt: 'septicShock')
			magazineCapacity: nil.
	outcome := scorpio
			recordScorpioHitFrom: 'scorpio'
			on: 'target'
			venomStacks: 6
			pelletHitFraction: 0.5
			at: 0.
	self assert: outcome triggeredStatuses equals: #(poison disorient shock).
	self assert: outcome pelletHitFraction equals: 0.5.
	self assert: outcome damageMultiplier isNil.
	outcome := scorpio
			recordScorpioHitFrom: 'scorpio'
			on: 'target'
			venomStacks: 2
			pelletHitFraction: 1
			at: 0.
	self assert: outcome stackCount equals: 8.
	self assert: outcome damageMultiplier equals: 1.20.
	self deny: outcome refreshesDamageDebuff.
	outcome := scorpio
			recordScorpioHitFrom: 'scorpio'
			on: 'target'
			venomStacks: 2
			pelletHitFraction: 1
			at: 0.
	self assert: outcome stackCount equals: 9.
	self assert: outcome refreshesDamageDebuff.
	outcome := scorpio
			recordScorpioHitFrom: 'scorpio'
			on: 'target'
			venomStacks: 1
			pelletHitFraction: 1
			at: 10.
	self assert: outcome stackCount equals: 1.
	self assertEmpty: outcome triggeredStatuses
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testSpecializationsPreserveWorkbookPerksAndValidateSelections [
	| catalog technician amped selected gear damage digital |
	catalog := CIGameItemTypes buildCatalog.
	self assert: catalog specializations size equals: 7.
	self
		assert: (catalog specializations sum: [ :specialization | specialization perks size ])
		equals: 100.
	technician := catalog specializationNamed: 'Technician'.
	amped := technician perkAt: 'technician.amped'.
	self assert: amped evidence equals: 'Specializations!G28:H28'.
	self assert: amped description equals: '+1 Skill Tier'.
	self
		should: [ catalog
				specializationLoadoutNamed: 'Technician'
				selected: #('technician.overclockedcpu' 'technician.enhanceddiagnostics') ]
		raise: Error.
	self
		should: [ catalog
				specializationLoadoutNamed: 'Technician'
				selected: #('sharpshooter.tactician') ]
		raise: Error.
	self
		should: [ catalog
				specializationLoadoutNamed: 'Technician'
				selected: #('technician.linkedlaserpointer') ]
		raise: Error.
	selected := catalog
			specializationLoadoutNamed: 'Technician'
			selected: #('technician.amped' 'technician.artificer' 'technician.linkedlaserpointer' 'universal.thisismyrifle' 'universal.emi').
	self
		assert: selected rewardIdentifiers asSet
		equals: #('attachment.workbook87' 'gadget.workbook.hive.artificer') asSet.
	gear := catalog typeAt: 'gadget.workbook.hive.artificer'.
	self assert: gear workbookVariantDefinition name equals: 'Artificer'.
	damage := (selected modifiersFor: #rifle)
			select: [ :each | each stat = #weaponDamage ].
	self assert: damage size equals: 1.
	self assert: damage first magnitude equals: 0.15.
	self
		assert: ((selected modifiersFor: #pistol) select: [ :each | each stat = #weaponDamage ])
				isEmpty.
	self
		assert: ((selected modifiersFor: #pistol) detect: [ :each | each stat = #skillTier ])
				unit
		equals: #skillTier.
	digital := (catalog specializationNamed: 'Sharpshooter')
			perkAt: 'sharpshooter.digitalscope'.
	self
		assert: (catalog modCatalogue definitionAt: digital rewardIdentifier) name
		equals: 'Digital Scope'
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testVersionOneInventorySnapshotCanStoreSpecialization [
	| path owner item old new selection |
	path := (directory / 'legacy-selection.ston') fullName.
	owner := 'legacy-owner'.
	item := CIInventoryItemSummary
			item: 'item'
			definition: 'legacy.definition'
			name: 'Legacy item'.
	path asFileReference
		writeStreamDo: [ :stream | 
			STON
				put: {1.
						Dictionary new
							at: owner put: {item};
							yourself.
						nil}
				onStream: stream ].
	old := CIInventorySnapshotStore at: path.
	self assert: (old specializationForOwner: owner) isNil.
	self assert: (old allRowsForOwner: owner) first itemIdentifier equals: 'item'.
	selection := CISpecializationSelection
			specialization: 'Technician'
			perks: #('technician.amped').
	old specialization: selection forOwner: owner.
	new := CIInventorySnapshotStore at: path.
	self assert: (new allRowsForOwner: owner) first itemIdentifier equals: 'item'.
	self
		assert: (new specializationForOwner: owner) perkIdentifiers
		equals: #('technician.amped')
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testWeaponAttachmentUnlocksAndOwnedGearModsPersist [
	| catalogue mods owner path store vest gloves mod unlock reloaded rows values |
	catalogue := CIGameItemTypes buildCatalog.
	mods := catalogue modCatalogue.
	owner := 'mod-test-owner'.
	path := (directory / 'mods.ston') fullName.
	store := CIInventorySnapshotStore at: path.
	vest := 'gear.launch.vossAndVale.chest'.
	gloves := 'gear.launch.vossAndVale.gloves'.
	values := Dictionary new
			at: 'weaponDamage' put: 0.1;
			yourself.
	store
		grantItem: 'vest'
		type: vest
		values: values
		from: catalogue
		forOwner: owner.
	store
		grantItem: 'gloves'
		type: gloves
		values: values
		from: catalogue
		forOwner: owner.
	self
		assert: (mods definitionAt: 'gearMod.criticalHitChance') maximum
		equals: 0.06.
	self
		assert: ((mods definitionAt: 'gearMod.criticalHitChance') maximumAtTier: 2) isNil.
	self
		should: [ store
				grantGearMod: 'bad'
				definition: 'gearMod.criticalHitChance'
				tier: 2
				value: 0.07
				from: catalogue
				forOwner: owner ]
		raise: Error.
	mod := store
			grantGearMod: 'rolled'
			definition: 'gearMod.criticalHitChance'
			tier: 2
			value: 0.04
			from: catalogue
			forOwner: owner.
	store
		installMod: mod itemIdentifier
		on: 'vest'
		socket: 'gearMod'
		from: catalogue
		forOwner: owner.
	self
		should: [ store
				installMod: mod itemIdentifier
				on: 'gloves'
				socket: 'gearMod'
				from: catalogue
				forOwner: owner ]
		raise: Error.
	self
		should: [ store
				installMod: mod itemIdentifier
				on: 'vest'
				socket: 'gearMod'
				from: catalogue
				forOwner: 'other' ]
		raise: Error.
	mods
		registerSocket: (CIItemSocket id: 'optic' interface: #shortOpticsRail)
		forItem: 'weapon.launch.akM'.
	mods
		registerSocket: (CIItemSocket id: 'optic' interface: #longOpticsRail)
		forItem: 'weapon.launch.tacticalMk16'.
	store
		grantItem: 'weapon-a'
		type: 'weapon.launch.akM'
		values: values
		from: catalogue
		forOwner: owner.
	store
		grantItem: 'weapon-b'
		type: 'weapon.launch.akM'
		values: values
		from: catalogue
		forOwner: owner.
	store
		grantItem: 'weapon-c'
		type: 'weapon.launch.tacticalMk16'
		values: values
		from: catalogue
		forOwner: owner.
	unlock := store
			unlockWeaponMod: 'attachment.lowReflexSight'
			from: catalogue
			forOwner: owner.
	self
		assert: (store
				unlockWeaponMod: unlock definitionIdentifier
				from: catalogue
				forOwner: owner) itemIdentifier
		equals: unlock itemIdentifier.
	#('weapon-a' 'weapon-b')
		do: [ :id | 
			store
				installMod: unlock itemIdentifier
				on: id
				socket: 'optic'
				from: catalogue
				forOwner: owner ].
	self
		should: [ store
				installMod: unlock itemIdentifier
				on: 'weapon-c'
				socket: 'optic'
				from: catalogue
				forOwner: owner ]
		raise: Error.
	reloaded := CIInventorySnapshotStore at: path.
	rows := reloaded allRowsForOwner: owner.
	self assert: (rows count: [ :row | row isKindOf: CIWeaponModUnlock ]) equals: 1.
	self
		assert: (rows detect: [ :row | row itemIdentifier = 'rolled' ]) rolledValue
		equals: 0.04.
	self
		assert: (rows detect: [ :row | row itemIdentifier = 'rolled' ]) tierId
		equals: 2.
	self
		assert: (rows detect: [ :row | row itemIdentifier = 'vest' ]) modSlots first
				equippedModIdentifier
		equals: 'rolled'.
	#('weapon-a' 'weapon-b')
		do: [ :id | 
			self
				assert: (rows detect: [ :row | row itemIdentifier = id ]) modSlots first
						equippedModIdentifier
				equals: unlock itemIdentifier ]
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testWeaponReferencesAndNamedTalentsKeepWorkbookLinks [
	| catalog references splash type store award source archivist |
	catalog := CIGameItemTypes buildCatalog.
	references := catalog weaponReferences.
	self
		assert: (references count: [ :entry | entry kind = #statistics ])
		equals: 316.
	self
		assert: (references count: [ :entry | entry kind ~= #statistics ])
		equals: 141.
	splash := catalog weaponReferenceAt: 'Weapons Named + Exotics!C131'.
	self assert: splash name equals: 'The Chatterbox'.
	self
		assert: (splash evidenceForField: #talentOrAttribute)
		equals: 'Weapons Named + Exotics!E130'.
	self assert: splash itemDefinitionIdentifier equals: 'weapon.launch.chatterbox'.
	self
		assert: (catalog weaponReferencesNamed: 'Shield Splinterer') size
		equals: 2.
	archivist := (catalog weaponReferencesNamed: 'The Archivist') first.
	self assert: archivist itemDefinitionIdentifier isNil.
	type := catalog typeAt: 'weapon.workbook.shieldSplinterer'.
	self assert: type baseMagazineCapacity equals: 30.
	self assert: (type statisticsReference fieldAt: #socketNotation) equals: '3#'.
	self
		assert: (type namedReference evidenceForField: #acquisition)
		equals: 'Weapons Named + Exotics!I8'.
	store := CIInventoryReadStore new.
	award := store
			grantItem: 'named-weapon'
			type: type id
			values: (Dictionary new
					at: 'weaponDamage' put: 0.15;
					yourself)
			from: catalog
			forOwner: 'named-owner'
			using: [ self error: 'Fixed talent must not draw' ].
	self assert: award talentIdentifier equals: 'perfectOptimist'.
	self assertEmpty: award modSlots.
	source := (catalog lootCatalogue poolsForItem: type id) first.
	self assert: source source name equals: 'Ivory Cache / then Cassie Mendoza'.
	self deny: source isComplete.
	self assert: source entries first weight isNil
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testWeaponTalentBoundariesAndPerfectVariants [
	| catalog make optimist perfect ranger repair reload |
	catalog := CIGameItemTypes buildCatalog.
	make := [ :id | CIWeaponTalentEncounter weapon: 'weapon' talent: (catalog talentAt: id) ].
	optimist := make value: 'optimist'.
	perfect := make value: 'perfectOptimist'.
	self
		assert: (optimist weaponDamageBonusForMagazine: 30 remaining: 28)
		equals: 0.
	self
		assert: (optimist weaponDamageBonusForMagazine: 30 remaining: 21)
		closeTo: 0.105.
	self
		assert: (perfect weaponDamageBonusForMagazine: 30 remaining: 21)
		closeTo: 0.135.
	self
		assert: (optimist weaponDamageBonusForMagazine: 30 remaining: 0)
		closeTo: 0.35.
	ranger := make value: 'ranger'.
	self assert: (ranger weaponDamageMultiplierAtDistance: 3.9) equals: 1.
	self assert: (ranger weaponDamageMultiplierAtDistance: 4) equals: 1.02.
	self
		assert: ((make value: 'perfectRanger') weaponDamageMultiplierAtDistance: 6)
		equals: 1.04.
	repair := (make value: 'perfectPreservation')
			armorRepairOnKillFrom: 'weapon'
			headshot: true.
	self assert: repair fraction closeTo: 0.30.
	self assert: repair durationSeconds equals: 5.
	self
		assert: ((make value: 'preservation') armorRepairOnKillFrom: 'another' headshot: true)
				isNil.
	reload := make value: 'perfectFastHands'.
	reload
		recordEnemyHitFrom: 'weapon'
		critical: false
		at: 0.
	reload
		recordEnemyHitFrom: 'another'
		critical: true
		at: 0.
	self assert: reload reloadSpeedBonus equals: 0.
	45
		timesRepeat: [ reload
				recordEnemyHitFrom: 'weapon'
				critical: true
				at: 1 ].
	self assert: reload reloadSpeedBonus equals: 2
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testWorkbookFactoryAttachmentsAreLockedAndPersist [
	| catalog mods owner path store item reloaded attachment magazine |
	catalog := CIGameItemTypes buildCatalog.
	mods := catalog modCatalogue.
	owner := 'factory-attachment-owner'.
	path := (directory / 'factory.ston') fullName.
	store := CIInventorySnapshotStore at: path.
	self assert: CIWorkbookModData weaponAttachments size equals: 94.
	self assert: CIWorkbookModData gearMods size equals: 11.
	self assert: CIWorkbookModData factoryAttachments size equals: 7.
	self
		assert: (mods definitionAt: 'attachment.workbook72') modelRestriction
		equals: 'Stoner only and Dare Only'.
	item := store
			grantItem: 'chatterbox'
			type: 'weapon.launch.chatterbox'
			values: (Dictionary new
					at: 'weaponDamage' put: 0.1;
					yourself)
			from: catalog
			forOwner: owner.
	self assert: item modSlots size equals: 4.
	self assert: (item modSlots allSatisfy: #isLocked).
	magazine := item modSlots detect: [ :slot | slot slotIdentifier = 'magazine' ].
	attachment := mods definitionAt: magazine equippedModIdentifier.
	self assert: attachment effects first equals: #(magazineCapacity flat 10).
	self assert: attachment evidence equals: 'Weapons Named + Exotics!F130'.
	self
		assertEmpty: (mods compatibleModsFor: 'weapon.launch.chatterbox' socket: 'magazine').
	self
		should: [ store
				unlockWeaponMod: attachment id
				from: catalog
				forOwner: owner ]
		raise: Error.
	self
		should: [ store
				removeModFrom: 'chatterbox'
				socket: 'magazine'
				forOwner: owner ]
		raise: Error.
	reloaded := ((CIInventorySnapshotStore at: path) allRowsForOwner: owner) first.
	self assert: (reloaded modSlots allSatisfy: #isLocked).
	self
		assert: (reloaded modSlots collect: #equippedModIdentifier)
		equals: (item modSlots collect: #equippedModIdentifier).
	store
		replaceRows: {(catalog typeAt: 'weapon.launch.chatterbox')
					inventoryItem: 'legacy'
					values: (Dictionary new
							at: 'weaponDamage' put: 0.1;
							yourself)}
		forOwner: owner.
	store restoreFactoryAttachmentsFrom: catalog.
	reloaded := ((CIInventorySnapshotStore at: path) allRowsForOwner: owner) first.
	self assert: reloaded itemIdentifier equals: 'legacy'.
	self assert: reloaded modSlots size equals: 4.
	self assert: (reloaded modSlots allSatisfy: #isLocked)
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testWorkbookFamiliesRetainModeColumnsMultiCoreAndNamedMembership [
	| catalog references core eclipse gila brand store row values evaluated |
	catalog := CIGameItemTypes buildCatalog.
	references := catalog gearFamilyReferences.
	self
		assert: (references count: [ :reference | reference kind = #brand ])
		equals: 37.
	self
		assert: (references count: [ :reference | reference kind = #gearSet ])
		equals: 28.
	core := catalog gearFamilyReferenceAt: 'Core Strength'.
	self
		assert: (core valuesFor: #coreOrSlotRule)
		equals: #('Weapon Damage' 'Skill Tier' 'Armor').
	self
		assert: (core referencesFor: #coreOrSlotRule)
		equals: #('Gearsets!B12' 'Gearsets!B13' 'Gearsets!B14').
	self assert: core runtimeFamilyIdentifier isNil.
	eclipse := catalog gearFamilyReferenceAt: 'Eclipse Protocol'.
	self assert: eclipse runtimeFamilyIdentifier equals: 'jupiterTechnologies'.
	self assert: (eclipse referencesFor: #vestTalent) equals: #('Gearsets!F15').
	gila := catalog gearFamilyReferenceAt: 'Gila Guard'.
	self assert: (gila valuesFor: #pveTwoPiece) equals: #('20% Hazard Protection').
	self assert: (gila valuesFor: #pvpTwoPiece) equals: #('15% Hazard Protection').
	brand := catalog gearFamilyAt: gila runtimeFamilyIdentifier.
	self
		assert: (brand tiers second modifiersForMode: #pvp) first magnitude
		equals: 0.15.
	self
		assert: (brand tiers second modifiersForMode: #pvp) first unit
		equals: #fraction.
	store := CIInventoryReadStore new.
	values := Dictionary new
			at: 'core' put: 50000;
			at: 'minor1'
				put: (CIGearAttributeRoll attribute: 'gear.minor.criticalHitChance' value: 0.05);
			at: 'minor2'
				put: (CIGearAttributeRoll attribute: 'gear.minor.criticalHitDamage' value: 0.10);
			yourself.
	row := store
			grantItem: 'courier'
			type: 'gear.workbook.theCourier'
			values: values
			from: catalog
			forOwner: 'owner'.
	row equippedSlotIdentifier: 'Backpack'.
	evaluated := (CILoadoutFamilyEvaluator new
			evaluateRows: {row}
			catalogue: catalog
			mode: #pve)
			detect: [ :activation | activation family manufacturer = 'Habsburg Guard' ].
	self assert: evaluated equippedCount equals: 1.
	self assert: evaluated modifiers first stat equals: #headshotDamage.
	self assert: evaluated modifiers first magnitude equals: 0.13
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testWorkbookGadgetInventoryKeepsIdentityAndUsesEquippedSkillTier [
	| catalog type store path owner gadget gear equipped restored rows graph |
	catalog := CIGameItemTypes buildCatalog.
	catalog gadgetFamilies
		do: [ :family | 
			family variants
				do: [ :variant | 
					type := catalog typeAt: (CIWorkbookGadgetData identifierFor: variant).
					self assert: type workbookVariantDefinition identicalTo: variant ] ].
	type := catalog typeAt: 'gadget.workbook.pulse.scanner'.
	self assert: (type baseStats at: 'Effect Radius') equals: 100.
	self
		assert: ((catalog typeAt: 'gadget.pulse.scanner') baseStats at: #scanRadiusMetres)
		equals: 20.
	path := (directory / 'gadget.ston') fullName.
	store := CIInventorySnapshotStore at: path.
	owner := 'workbook-gadget-owner'.
	gadget := store
			grantItem: 'scanner'
			type: type id
			values: Dictionary new
			from: catalog
			forOwner: owner.
	gear := store
			grantItem: 'vest'
			type: 'gear.launch.morrowWorks.chest'
			values: (Dictionary new
					at: 'skillTier' put: 1;
					yourself)
			from: catalog
			forOwner: owner.
	self
		assert: (CIInventoryProfileGraph
				workbookGadgetTierForRows: {gadget.
						gear})
		equals: 0.
	equipped := store
			rowsAfterEquipping: #(#('GadgetLeft' 'scanner') #('Chest' 'vest'))
			forOwner: owner
			outfit: false.
	store replaceRows: equipped forOwner: owner.
	restored := CIInventorySnapshotStore at: path.
	rows := restored allRowsForOwner: owner.
	self assert: rows first definitionIdentifier equals: type id.
	self assert: rows first equippedSlotIdentifier equals: 'GadgetLeft'.
	self
		assert: (CIInventoryProfileGraph workbookGadgetTierForRows: rows)
		equals: 1.
	graph := CIInventoryProfileGraph
			forVerifiedUser: owner
			rows: rows
			savedSets: Dictionary new
			catalog: catalog.
	self assert: ((STON toString: graph) includesSubstring: '9.200 s').
	self assert: ((STON toString: graph) includesSubstring: '100 m')
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testWorkbookGadgetTiersKeepMissingAndOverchargeSeparate [
	| catalog pulse scanner tactician track repair cooldown |
	catalog := CIGameItemTypes buildCatalog.
	self assert: catalog gadgetFamilies size equals: 12.
	self
		assert: (catalog gadgetFamilies sum: [ :family | family variants size ])
		equals: 43.
	self
		assert: (catalog gadgetFamilies
				sum: [ :family | family variants sum: [ :variant | variant tracks size ] ])
		equals: 270.
	pulse := catalog gadgetFamilyNamed: 'Pulse'.
	scanner := pulse variantNamed: 'Scanner'.
	self assert: ((scanner knownStatsAtTier: 0) at: 'Effect Radius') equals: 100.
	self
		assert: (((scanner knownStatsAtTier: 6) at: 'Duration') - 15.2) abs < 0.001.
	self
		assert: ((scanner knownStatsAtTier: #overcharge) at: 'Duration')
		equals: 24.
	self assert: (scanner overchargeEffects first includesSubstring: '15%').
	self assert: (scanner expertiseScaling first includesSubstring: '+1% Duration').
	cooldown := scanner trackNamed: 'Cooldown'.
	self assert: (cooldown rawValueAtTier: 1) equals: '-'.
	self assert: (cooldown magnitudeAtTier: 1) equals: 20.
	tactician := (catalog gadgetFamilyNamed: 'Drone') variantNamed: 'Tactician'.
	track := tactician trackNamed: 'Scan Range'.
	self assert: track unit equals: #metres.
	self assert: track evidence equals: 'Skill List!C260:M260'.
	self assert: (track magnitudeAtTier: 6) equals: 80.
	self assert: (track magnitudeAtTier: #overcharge) equals: 90.
	repair := ((catalog gadgetFamilyNamed: 'Chem Launcher')
			variantNamed: 'Reinforcer') trackNamed: 'Repair Over Time'.
	self assert: (repair rawValueAtTier: 1) isNil.
	self assert: (repair magnitudeAtTier: 1) isNil.
	self should: [ scanner knownStatsAtTier: 7 ] raise: Error
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testWorkbookLootSourcesKeepUnknownOdds [
	| catalog loot pools entry |
	catalog := CIGameItemTypes buildCatalog.
	loot := catalog lootCatalogue.
	pools := loot poolsForItem: 'weapon.launch.chatterbox'.
	self
		assert: (pools collect: #id)
		equals: #('chatterbox' 'exoticCaches' 'targetedLoot').
	entry := ((loot poolAt: 'exoticCaches')
			entriesForItem: 'weapon.launch.chatterbox') first.
	self assert: entry requirement equals: #blueprintAcquired.
	self assert: entry evidence equals: 'Weapons Named + Exotics!I130'.
	self assert: entry weight isNil.
	self
		should: [ (loot poolAt: 'exoticCaches') selectUsing: 0.5 satisfying: [ :each | true ] ]
		raise: Error
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testWorkbookTalentReferencesPreserveScopesAndExecutableLinks [
	| catalog reference repeated |
	catalog := CIGameItemTypes buildCatalog.
	self
		assert: (catalog talentReferences
				count: [ :each | each id beginsWith: 'Weapon Talents!' ])
		equals: 67.
	self
		assert: (catalog talentReferences count: [ :each | each id beginsWith: 'Gear Talents!' ])
		equals: 46.
	reference := (catalog talentReferencesNamed: 'Perfect Optimist') first.
	self assert: reference scope equals: #weapon.
	self assert: reference talentIdentifier equals: 'optimist'.
	self assert: reference perfectTalentIdentifier equals: 'perfectOptimist'.
	self
		assert: ((catalog talentAt: reference perfectTalentIdentifier) parameters
				at: #damagePerStep)
		equals: 0.045.
	self
		assert: (reference evidenceForField: #description)
		equals: 'Weapon Talents!D5'.
	repeated := catalog talentReferencesNamed: 'Back and Forth'.
	self assert: repeated size equals: 6.
	self
		assert: (repeated collect: #scope) asSet
		equals: #(rifle assaultRifle marksmanRifle smg lmg shotgun) asSet.
	reference := catalog talentReferenceAt: 'Gear Talents!D14'.
	self assert: (reference fieldAt: #pvpModifier) notNil.
	self assert: (reference fieldAt: #dzPvpDescription) notNil.
	self
		assert: (reference evidenceForField: #dzPvpDescription)
		equals: 'Gear Talents!K14'.
	reference := catalog talentReferenceAt: 'Gear Talents!D24'.
	self
		assert: ((reference fieldAt: #eligibilityNotes) includesSubstring: 'backpack').
	reference := (catalog talentReferencesNamed: 'Perpetuation') first.
	self assert: reference talentIdentifier isNil.
	self assert: (catalog talentAt: 'perpetuation' ifAbsent: [ nil ]) isNil
]
