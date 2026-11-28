Class {
	#name : 'CIWorkbookNamedGearType',
	#superclass : 'CIGearType',
	#instVars : [
		'layout',
		'sourceInformation'
	],
	#category : 'BVC-Inventory-TypeCatalog',
	#package : 'BVC-Inventory-TypeCatalog'
}

{ #category : 'instance creation' }
CIWorkbookNamedGearType class >> id: anId name: aName layout: itemLayout sockets: sockets information: information [
	^ (self
		id: anId
		name: aName
		slot: 'Mask'
		attributes: #()
		sockets: sockets) initializeLayout: itemLayout information: information
]

{ #category : 'instance creation' }
CIWorkbookNamedGearType class >> id: anId name: aName slot: gearSlot layout: itemLayout sockets: sockets information: information [
	^ (self
		id: anId
		name: aName
		slot: gearSlot
		attributes: #()
		sockets: sockets) initializeLayout: itemLayout information: information
]

{ #category : 'accessing' }
CIWorkbookNamedGearType >> generationLayout [
	^ layout
]

{ #category : 'initialization' }
CIWorkbookNamedGearType >> initializeLayout: itemLayout information: information [
	layout := itemLayout.
	sourceInformation := information collect: #copy.
	self
		inspectorIdentity: (Dictionary new
				at: 'inspectorManufacturer' put: (sourceInformation at: #brand);
				yourself).
	^ self
]

{ #category : 'spawning' }
CIWorkbookNamedGearType >> inventoryFamilyMetadata [
	^ Dictionary new
		at: #brandName put: (sourceInformation at: #brand);
		yourself
]

{ #category : 'spawning' }
CIWorkbookNamedGearType >> inventoryItem: itemIdentifier values: values talentIdentifier: aTalentIdentifier [
	| sockets |
	sockets := socketIdentifiers
			collect: [ :id | CIInventoryModSlotSummary slot: id equippedMod: nil ].
	^ self
		inventoryItem: itemIdentifier
		attributes: (layout attributesFor: values)
		sockets: sockets
		talentIdentifier: aTalentIdentifier
]

{ #category : 'accessing' }
CIWorkbookNamedGearType >> sourceInformation [
	^ sourceInformation collect: #copy
]

{ #category : 'validation' }
CIWorkbookNamedGearType >> validateInventoryItemValues: values [
	layout completeValues: values
]
