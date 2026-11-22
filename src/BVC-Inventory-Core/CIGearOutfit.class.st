Class {
	#name : 'CIGearOutfit',
	#superclass : 'Object',
	#instVars : [
		'pieces'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'accessing' }
CIGearOutfit class >> withPieces: aCollection [
	^ self new initializePieces: aCollection
]

{ #category : 'accessing' }
CIGearOutfit >> initializePieces: aCollection [
	(aCollection allSatisfy: [ :piece | piece isKindOf: CIGearDefinition ])
		ifFalse: [ self error: 'An outfit requires gear definitions' ].
	(aCollection collect: #slot) asSet size = aCollection size
		ifFalse: [ self error: 'An outfit can hold only one piece per slot' ].
	(aCollection collect: #id) asSet size = aCollection size
		ifFalse: [ self error: 'An outfit cannot repeat an item definition' ].
	pieces := aCollection asArray copy
]

{ #category : 'accessing' }
CIGearOutfit >> itemIds [
	^ pieces collect: #id
]

{ #category : 'accessing' }
CIGearOutfit >> pieces [
	^ pieces copy
]
