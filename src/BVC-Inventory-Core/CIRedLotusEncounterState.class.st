Class {
	#name : 'CIRedLotusEncounterState',
	#superclass : 'Object',
	#instVars : [
		'parameters',
		'stacks'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIRedLotusEncounterState class >> forActivation: activation [
	^ self new updateFromActivation: activation
]

{ #category : 'private' }
CIRedLotusEncounterState >> currentDecayPerSecond [
	| highThreshold |
	highThreshold := parameters at: #highDecayMinimumStacks ifAbsent: [ nil ].
	(highThreshold notNil and: [ stacks >= highThreshold ])
		ifTrue: [ ^ parameters at: #highDecayStacksPerSecond ].
	^ stacks > (parameters at: #firstDecayThreshold)
		ifTrue: [ parameters at: #secondDecayPerSecond ]
		ifFalse: [ parameters at: #firstDecayPerSecond ]
]

{ #category : 'accessing' }
CIRedLotusEncounterState >> damageMultiplier [
	parameters ifNil: [ ^ 1 ].
	^ 1 + (stacks * (parameters at: #damagePerStack))
]

{ #category : 'combat' }
CIRedLotusEncounterState >> decayTick [
	stacks = 0 ifTrue: [ ^ 0 ].
	stacks := stacks - self currentDecayPerSecond max: 0.
	^ stacks
]

{ #category : 'initialization' }
CIRedLotusEncounterState >> initialize [
	super initialize.
	stacks := 0
]

{ #category : 'accessing' }
CIRedLotusEncounterState >> maximumStacks [
	^ parameters ifNil: [ 0 ] ifNotNil: [ parameters at: #maxStacks ]
]

{ #category : 'combat' }
CIRedLotusEncounterState >> recordWeaponHit [
	stacks := stacks + 1 min: self maximumStacks.
	^ stacks
]

{ #category : 'accessing' }
CIRedLotusEncounterState >> stacks [
	^ stacks
]

{ #category : 'combat' }
CIRedLotusEncounterState >> updateFromActivation: activation [
	activation family id = 'redLotusAssault'
		ifFalse: [ self error: 'Expected a Red Lotus activation' ].
	parameters := activation effectiveSetParameters.
	stacks := stacks min: self maximumStacks.
	^ self
]
