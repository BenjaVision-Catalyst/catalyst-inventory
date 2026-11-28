Class {
	#name : 'CISpecializationLoadout',
	#superclass : 'Object',
	#instVars : [
		'definition',
		'selectedPerks'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CISpecializationLoadout class >> definition: aDefinition universal: shared selected: identifiers [
	^ self new
		initializeDefinition: aDefinition
		universal: shared
		selected: identifiers
]

{ #category : 'accessing' }
CISpecializationLoadout >> definition [
	^ definition
]

{ #category : 'accessing' }
CISpecializationLoadout >> gadgetUpgradePerksForType: typeIdentifier [
	^ (selectedPerks
		select: [ :perk | 
			perk gadgetUpgrade
				ifNil: [ false ]
				ifNotNil: [ :upgrade | upgrade gadgetTypeIdentifier = typeIdentifier ] ])
		asArray
]

{ #category : 'initialization' }
CISpecializationLoadout >> initializeDefinition: aDefinition universal: shared selected: identifiers [
	| ids |
	definition := aDefinition.
	ids := identifiers asSet.
	selectedPerks := ids
			collect: [ :identifier | 
				(definition perkAt: identifier)
					ifNil: [ (shared perkAt: identifier)
							ifNil: [ self error: 'Perk is unavailable for this specialization: ' , identifier ] ] ].
	selectedPerks
		do: [ :perk | 
			(perk prerequisites allSatisfy: [ :id | ids includes: id ])
				ifFalse: [ self error: 'Missing prerequisite for: ' , perk id ].
			(perk exclusions anySatisfy: [ :id | ids includes: id ])
				ifTrue: [ self error: 'Mutually exclusive specialization perks: ' , perk id ] ].
	selectedPerks := (selectedPerks sorted: [ :a :b | a id < b id ]) asArray.
	^ self
]

{ #category : 'querying' }
CISpecializationLoadout >> modifiersFor: weaponClass [
	^ selectedPerks
		flatCollect: [ :perk | perk modifiers select: [ :each | each appliesTo: weaponClass ] ]
]

{ #category : 'querying' }
CISpecializationLoadout >> rewardIdentifiers [
	^ (selectedPerks collect: #rewardIdentifier) reject: #isNil
]

{ #category : 'accessing' }
CISpecializationLoadout >> selectedPerks [
	^ selectedPerks copy
]
