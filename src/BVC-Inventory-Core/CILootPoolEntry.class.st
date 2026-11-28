Class {
	#name : 'CILootPoolEntry',
	#superclass : 'Object',
	#instVars : [
		'itemDefinition',
		'weight',
		'requirement',
		'evidence'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CILootPoolEntry class >> item: definition weight: relativeWeight requiring: prerequisite evidence: sourceReference [
	^ self new
		initializeItem: definition
		weight: relativeWeight
		requiring: prerequisite
		evidence: sourceReference
]

{ #category : 'accessing' }
CILootPoolEntry >> evidence [
	^ evidence copy
]

{ #category : 'initialization' }
CILootPoolEntry >> initializeItem: definition weight: relativeWeight requiring: prerequisite evidence: sourceReference [
	(relativeWeight isNil
		or: [ relativeWeight isNumber and: [ relativeWeight > 0 ] ])
		ifFalse: [ self error: 'Loot weight must be positive' ].
	itemDefinition := definition.
	weight := relativeWeight.
	requirement := prerequisite.
	evidence := sourceReference copy.
	^ self
]

{ #category : 'accessing' }
CILootPoolEntry >> itemDefinition [
	^ itemDefinition
]

{ #category : 'accessing' }
CILootPoolEntry >> requirement [
	^ requirement
]

{ #category : 'accessing' }
CILootPoolEntry >> weight [
	^ weight
]
