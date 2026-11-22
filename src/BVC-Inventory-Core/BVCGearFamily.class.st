Class {
	#name : 'BVCGearFamily',
	#superclass : 'Object',
	#instVars : [
		'id',
		'manufacturer',
		'tiers'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
BVCGearFamily class >> id: anId manufacturer: aManufacturer tiers: someTiers [
	^ self new
		initializeId: anId
		manufacturer: aManufacturer
		tiers: someTiers
]

{ #category : 'accessing' }
BVCGearFamily >> id [
	^ id
]

{ #category : 'accessing' }
BVCGearFamily >> initializeId: anId manufacturer: aManufacturer tiers: someTiers [
	(someTiers collect: #pieceCount) asSet size = someTiers size
		ifFalse: [ self error: 'Duplicate family threshold' ].
	id := anId.
	manufacturer := aManufacturer.
	tiers := (someTiers sorted: [ :a :b | a pieceCount < b pieceCount ]) asArray
]

{ #category : 'accessing' }
BVCGearFamily >> manufacturer [
	^ manufacturer
]

{ #category : 'accessing' }
BVCGearFamily >> tiers [
	^ tiers copy
]
