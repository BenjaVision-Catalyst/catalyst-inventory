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
	self assert: catalog gearFamilies size equals: 5.
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
