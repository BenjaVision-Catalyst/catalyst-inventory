Class {
	#name : 'CIModEvaluation',
	#superclass : 'Object',
	#instVars : [
		'contributions',
		'unresolved'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIModEvaluation class >> contributions: effects unresolved: unresolvedReferences [
	^ self new initializeContributions: effects unresolved: unresolvedReferences
]

{ #category : 'accessing' }
CIModEvaluation >> contributions [
	^ contributions copy
]

{ #category : 'querying' }
CIModEvaluation >> contributionsFor: statId on: itemId [
	^ contributions
		select: [ :effect | effect itemIdentifier = itemId and: [ effect stat = statId ] ]
]

{ #category : 'initialization' }
CIModEvaluation >> initializeContributions: effects unresolved: unresolvedReferences [
	contributions := effects asArray copy.
	unresolved := unresolvedReferences asArray copy.
	^ self
]

{ #category : 'querying' }
CIModEvaluation >> magazineCapacityFor: anItem base: baseRounds [
	| effects |
	baseRounds ifNil: [ ^ nil ].
	(unresolved
		anySatisfy: [ :reference | reference first = anItem itemIdentifier ])
		ifTrue: [ ^ nil ].
	effects := self contributionsFor: #magazineCapacity on: anItem itemIdentifier.
	(effects allSatisfy: [ :effect | effect operation = #flat ]) ifFalse: [ ^ nil ].
	^ effects inject: baseRounds into: [ :rounds :effect | rounds + effect value ]
]

{ #category : 'accessing' }
CIModEvaluation >> unresolved [
	^ unresolved collect: #copy
]
