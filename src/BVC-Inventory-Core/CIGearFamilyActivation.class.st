Class {
	#name : 'CIGearFamilyActivation',
	#superclass : 'Object',
	#instVars : [
		'family',
		'equippedCount',
		'mode',
		'activeTiers',
		'activeTalents'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIGearFamilyActivation class >> family: aFamily count: count mode: gameMode tiers: tiers talents: talents [
	^ self new
		initializeFamily: aFamily
		count: count
		mode: gameMode
		tiers: tiers
		talents: talents
]

{ #category : 'accessing' }
CIGearFamilyActivation >> activeTalents [
	^ activeTalents copy
]

{ #category : 'accessing' }
CIGearFamilyActivation >> activeTiers [
	^ activeTiers copy
]

{ #category : 'accessing' }
CIGearFamilyActivation >> effectiveSetParameters [
	| base parameters |
	base := family setTalent.
	(base isNil or: [ (activeTalents includes: base) not ]) ifTrue: [ ^ nil ].
	parameters := base parameters.
	activeTalents
		do: [ :talent | 
			talent == base
				ifFalse: [ talent parameters
						keysAndValuesDo: [ :key :value | 
							(#(familyId requiredPieces) includes: key)
								ifFalse: [ parameters at: key put: value ] ] ] ].
	^ parameters
]

{ #category : 'accessing' }
CIGearFamilyActivation >> equippedCount [
	^ equippedCount
]

{ #category : 'accessing' }
CIGearFamilyActivation >> family [
	^ family
]

{ #category : 'initialization' }
CIGearFamilyActivation >> initializeFamily: aFamily count: count mode: gameMode tiers: tiers talents: talents [
	family := aFamily.
	equippedCount := count.
	mode := gameMode.
	activeTiers := tiers asArray copy.
	activeTalents := talents asArray copy.
	^ self
]

{ #category : 'accessing' }
CIGearFamilyActivation >> mode [
	^ mode
]

{ #category : 'accessing' }
CIGearFamilyActivation >> modifiers [
	^ activeTiers flatCollect: [ :tier | tier modifiersForMode: mode ]
]
