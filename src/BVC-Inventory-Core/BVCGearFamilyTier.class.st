Class {
	#name : 'BVCGearFamilyTier',
	#superclass : 'Object',
	#instVars : [
		'pieceCount',
		'modifiers',
		'trigger',
		'consumeEvent',
		'limit'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
BVCGearFamilyTier class >> pieces: count modifiers: modifiers trigger: trigger consumeOn: event limit: maxActivations [
	^ self new
		initializePieces: count
		modifiers: modifiers
		trigger: trigger
		consumeOn: event
		limit: maxActivations
]

{ #category : 'accessing' }
BVCGearFamilyTier >> consumeEvent [
	^ consumeEvent
]

{ #category : 'accessing' }
BVCGearFamilyTier >> initializePieces: count modifiers: someModifiers trigger: triggerEvent consumeOn: event limit: maxActivations [
	(#(2 3 4) includes: count)
		ifFalse: [ self error: 'Unsupported family threshold' ].
	triggerEvent isNil = event isNil
		ifFalse: [ self error: 'A triggered tier needs both events' ].
	(maxActivations isInteger and: [ maxActivations > 0 ])
		ifFalse: [ self error: 'Invalid activation limit' ].
	pieceCount := count.
	modifiers := someModifiers asArray copy.
	trigger := triggerEvent.
	consumeEvent := event.
	limit := maxActivations
]

{ #category : 'accessing' }
BVCGearFamilyTier >> limit [
	^ limit
]

{ #category : 'accessing' }
BVCGearFamilyTier >> modifiers [
	^ modifiers copy
]

{ #category : 'accessing' }
BVCGearFamilyTier >> pieceCount [
	^ pieceCount
]

{ #category : 'accessing' }
BVCGearFamilyTier >> trigger [
	^ trigger
]
