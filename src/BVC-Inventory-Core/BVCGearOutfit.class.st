Class {
	#name : 'BVCGearOutfit',
	#superclass : 'Object',
	#instVars : [
		'pieces'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'accessing' }
BVCGearOutfit class >> withPieces: aCollection [
	^ self new initializePieces: aCollection
]

{ #category : 'accessing' }
BVCGearOutfit >> initializePieces: aCollection [
	(aCollection allSatisfy: [ :piece | piece isKindOf: BVCGearDefinition ])
		ifFalse: [ self error: 'An outfit requires gear definitions' ].
	(aCollection collect: #slot) asSet size = aCollection size
		ifFalse: [ self error: 'An outfit can hold only one piece per slot' ].
	(aCollection collect: #id) asSet size = aCollection size
		ifFalse: [ self error: 'An outfit cannot repeat an item definition' ].
	pieces := aCollection asArray copy
]

{ #category : 'accessing' }
BVCGearOutfit >> itemIds [
	^ pieces collect: #id
]

{ #category : 'accessing' }
BVCGearOutfit >> pieces [
	^ pieces copy
]
