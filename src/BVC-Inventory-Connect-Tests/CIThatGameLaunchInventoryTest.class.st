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
