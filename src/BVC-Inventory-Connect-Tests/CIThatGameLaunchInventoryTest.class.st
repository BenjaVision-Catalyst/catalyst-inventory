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
