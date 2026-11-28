Class {
	#name : 'CIGearFamilyTier',
	#superclass : 'Object',
	#instVars : [
		'pieceCount',
		'modifiers',
		'trigger',
		'consumeEvent',
		'limit',
		'pvpModifiers',
		'evidence'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIGearFamilyTier class >> pieces: count modifiers: modifiers trigger: trigger consumeOn: event limit: maxActivations [
	^ self new
		initializePieces: count
		modifiers: modifiers
		trigger: trigger
		consumeOn: event
		limit: maxActivations
]

{ #category : 'accessing' }
CIGearFamilyTier >> consumeEvent [
	^ consumeEvent
]

{ #category : 'accessing' }
CIGearFamilyTier >> evidence [
	^ evidence ifNotNil: #copy
]

{ #category : 'accessing' }
CIGearFamilyTier >> initializePieces: count modifiers: someModifiers trigger: triggerEvent consumeOn: event limit: maxActivations [
	(count isInteger and: [ count > 0 ])
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
CIGearFamilyTier >> limit [
	^ limit
]

{ #category : 'accessing' }
CIGearFamilyTier >> modifiers [
	^ modifiers copy
]

{ #category : 'accessing' }
CIGearFamilyTier >> modifiersForMode: mode [
	mode = #pvp
		ifTrue: [ ^ pvpModifiers ifNil: [ self modifiers ] ifNotNil: #copy ].
	^ self modifiers
]

{ #category : 'accessing' }
CIGearFamilyTier >> pieceCount [
	^ pieceCount
]

{ #category : 'initialization' }
CIGearFamilyTier >> pvpModifiers: otherModifiers evidence: reference [
	pvpModifiers := otherModifiers ifNotNil: #asArray.
	evidence := reference copy
]

{ #category : 'accessing' }
CIGearFamilyTier >> trigger [
	^ trigger
]
