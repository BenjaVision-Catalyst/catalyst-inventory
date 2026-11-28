Class {
	#name : 'CIItemTypeCatalog',
	#superclass : 'Object',
	#instVars : [
		'typesById',
		'talentsById',
		'talentPoolsByTypeId',
		'lootCatalogue'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'initialization' }
CIItemTypeCatalog >> initialize [
	super initialize.
	typesById := Dictionary new.
	talentsById := Dictionary new.
	talentPoolsByTypeId := Dictionary new
]

{ #category : 'accessing' }
CIItemTypeCatalog >> lootCatalogue [
	^ lootCatalogue ifNil: [ lootCatalogue := CILootCatalogue new ]
]

{ #category : 'accessing' }
CIItemTypeCatalog >> register: aType [
	| identifier |
	identifier := aType id.
	(identifier isString and: [ identifier notEmpty ])
		ifFalse: [ self error: 'Item type requires an identifier' ].
	(typesById includesKey: identifier)
		ifTrue: [ self error: 'Duplicate item type: ' , identifier ].
	typesById at: identifier put: aType.
	^ aType
]

{ #category : 'registration' }
CIItemTypeCatalog >> registerTalent: aTalent [
	| registry identifier |
	registry := talentsById ifNil: [ talentsById := Dictionary new ].
	identifier := aTalent id.
	(registry includesKey: identifier)
		ifTrue: [ self error: 'Duplicate talent: ' , identifier ].
	registry at: identifier put: aTalent.
	^ aTalent
]

{ #category : 'spawning' }
CIItemTypeCatalog >> rollTalentFor: aTypeIdentifier using: randomSample [
	| pool |
	pool := self talentPoolFor: aTypeIdentifier.
	pool isEmpty ifTrue: [ ^ nil ].
	pool size = 1 ifTrue: [ ^ pool first ].
	^ pool at: (randomSample value * pool size) floor + 1
]

{ #category : 'accessing' }
CIItemTypeCatalog >> talentAt: anIdentifier [
	^ self
		talentAt: anIdentifier
		ifAbsent: [ self error: 'Unknown talent: ' , anIdentifier ]
]

{ #category : 'accessing' }
CIItemTypeCatalog >> talentAt: anIdentifier ifAbsent: aBlock [
	talentsById ifNil: [ ^ aBlock value ].
	^ talentsById at: anIdentifier ifAbsent: aBlock
]

{ #category : 'registration' }
CIItemTypeCatalog >> talentPool: identifiers for: aTypeIdentifier [
	| type pool |
	type := self typeAt: aTypeIdentifier.
	pool := identifiers asArray collect: #copy.
	pool asSet size = pool size ifFalse: [ self error: 'Duplicate talent in pool' ].
	pool
		do: [ :id | 
			| talent |
			talent := self talentAt: id.
			talent eligibility = type talentEligibility
				ifFalse: [ self error: 'Ineligible talent: ' , id ] ].
	talentPoolsByTypeId ifNil: [ talentPoolsByTypeId := Dictionary new ].
	talentPoolsByTypeId at: aTypeIdentifier put: pool
]

{ #category : 'accessing' }
CIItemTypeCatalog >> talentPoolFor: aTypeIdentifier [
	talentPoolsByTypeId ifNil: [ ^ #() ].
	^ (talentPoolsByTypeId at: aTypeIdentifier ifAbsent: [ #() ]) collect: #copy
]

{ #category : 'accessing' }
CIItemTypeCatalog >> typeAt: anIdentifier [
	^ typesById
		at: anIdentifier
		ifAbsent: [ self error: 'Unknown item type: ' , anIdentifier ]
]

{ #category : 'accessing' }
CIItemTypeCatalog >> typeAt: anIdentifier ifAbsent: aBlock [
	^ typesById at: anIdentifier ifAbsent: aBlock
]
