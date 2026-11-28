Class {
	#name : 'CIGearFamily',
	#superclass : 'Object',
	#instVars : [
		'id',
		'manufacturer',
		'tiers',
		'setTalent',
		'slotUpgrades'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIGearFamily class >> id: anId manufacturer: aManufacturer tiers: someTiers [
	^ self new
		initializeId: anId
		manufacturer: aManufacturer
		tiers: someTiers
]

{ #category : 'accessing' }
CIGearFamily >> id [
	^ id
]

{ #category : 'accessing' }
CIGearFamily >> initializeId: anId manufacturer: aManufacturer tiers: someTiers [
	(someTiers collect: #pieceCount) asSet size = someTiers size
		ifFalse: [ self error: 'Duplicate family threshold' ].
	id := anId.
	manufacturer := aManufacturer.
	tiers := (someTiers sorted: [ :a :b | a pieceCount < b pieceCount ]) asArray
]

{ #category : 'accessing' }
CIGearFamily >> manufacturer [
	^ manufacturer
]

{ #category : 'accessing' }
CIGearFamily >> setTalent [
	^ setTalent
]

{ #category : 'initialization' }
CIGearFamily >> setTalent: aTalent slotUpgrades: upgradesBySlot [
	setTalent := aTalent.
	slotUpgrades := upgradesBySlot copy
]

{ #category : 'accessing' }
CIGearFamily >> tiers [
	^ tiers copy
]

{ #category : 'accessing' }
CIGearFamily >> upgradeAtSlot: aSlot [
	slotUpgrades ifNil: [ ^ nil ].
	^ slotUpgrades at: aSlot ifAbsent: [ nil ]
]
