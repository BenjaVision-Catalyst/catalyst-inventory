Class {
	#name : 'CILootPool',
	#superclass : 'Object',
	#instVars : [
		'id',
		'source',
		'entries',
		'complete'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CILootPool class >> id: identifier source: aSource entries: documentedEntries complete: completeness [
	^ self new
		initializeId: identifier
		source: aSource
		entries: documentedEntries
		complete: completeness
]

{ #category : 'accessing' }
CILootPool >> entries [
	^ entries copy
]

{ #category : 'querying' }
CILootPool >> entriesForItem: definitionId [
	^ entries select: [ :entry | entry itemDefinition id = definitionId ]
]

{ #category : 'accessing' }
CILootPool >> id [
	^ id copy
]

{ #category : 'initialization' }
CILootPool >> initializeId: identifier source: aSource entries: documentedEntries complete: completeness [
	id := identifier copy.
	source := aSource.
	entries := documentedEntries asArray copy.
	complete := completeness.
	^ self
]

{ #category : 'accessing' }
CILootPool >> isComplete [
	^ complete == true
]

{ #category : 'selection' }
CILootPool >> selectUsing: sample satisfying: meetsRequirement [
	^ self selectWithRandom: [ sample ] satisfying: meetsRequirement
]

{ #category : 'selection' }
CILootPool >> selectWithRandom: randomSample satisfying: meetsRequirement [
	| eligible total sample point cumulative |
	self isComplete
		ifFalse: [ self error: 'Loot pool completeness is unspecified' ].
	eligible := entries
			select: [ :entry | entry requirement isNil or: [ meetsRequirement value: entry ] ].
	eligible ifEmpty: [ ^ nil ].
	(eligible anySatisfy: [ :entry | entry weight isNil ])
		ifTrue: [ self error: 'Loot pool entry weight is unspecified' ].
	sample := randomSample value.
	(sample >= 0 and: [ sample < 1 ])
		ifFalse: [ self error: 'Loot sample must be in [0, 1)' ].
	total := eligible sum: #weight.
	point := sample * total.
	cumulative := 0.
	^ eligible
		detect: [ :entry | 
			cumulative := cumulative + entry weight.
			point < cumulative ]
		ifNone: [ eligible last ]
]

{ #category : 'accessing' }
CILootPool >> source [
	^ source
]
