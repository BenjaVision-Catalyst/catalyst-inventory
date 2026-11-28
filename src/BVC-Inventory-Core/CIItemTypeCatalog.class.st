Class {
	#name : 'CIItemTypeCatalog',
	#superclass : 'Object',
	#instVars : [
		'typesById',
		'talentsById',
		'talentPoolsByTypeId',
		'lootCatalogue',
		'modCatalogue',
		'gearFamiliesById',
		'gadgetFamiliesByName',
		'attributeCatalogue',
		'gearReferencesByName',
		'weaponReferencesById',
		'familyReferencesByName',
		'talentReferencesById',
		'specializationsByName'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'accessing' }
CIItemTypeCatalog >> attributeCatalogue [
	^ attributeCatalogue ifNil: [ attributeCatalogue := CIAttributeCatalogue new ]
]

{ #category : 'accessing' }
CIItemTypeCatalog >> gadgetFamilies [
	gadgetFamiliesByName ifNil: [ ^ #() ].
	^ (gadgetFamiliesByName values sorted: [ :a :b | a name < b name ]) asArray
]

{ #category : 'accessing' }
CIItemTypeCatalog >> gadgetFamilyNamed: label [
	gadgetFamiliesByName ifNil: [ self error: 'No gadget families registered' ].
	^ gadgetFamiliesByName at: label
]

{ #category : 'accessing' }
CIItemTypeCatalog >> gearFamilies [
	gearFamiliesById ifNil: [ ^ #() ].
	^ (gearFamiliesById values sorted: [ :a :b | a id < b id ]) asArray
]

{ #category : 'accessing' }
CIItemTypeCatalog >> gearFamilyAt: anId [
	^ gearFamiliesById at: anId
]

{ #category : 'accessing' }
CIItemTypeCatalog >> gearFamilyReferenceAt: name [
	familyReferencesByName
		ifNil: [ self error: 'No gear family references registered' ].
	^ familyReferencesByName at: name
]

{ #category : 'accessing' }
CIItemTypeCatalog >> gearFamilyReferences [
	familyReferencesByName ifNil: [ ^ #() ].
	^ (familyReferencesByName values sorted: [ :a :b | a name < b name ]) asArray
]

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
CIItemTypeCatalog >> modCatalogue [
	^ modCatalogue ifNil: [ modCatalogue := CIModCatalogue new ]
]

{ #category : 'accessing' }
CIItemTypeCatalog >> namedGearReferenceAt: label [
	gearReferencesByName
		ifNil: [ self error: 'No named gear references registered' ].
	^ gearReferencesByName at: label
]

{ #category : 'accessing' }
CIItemTypeCatalog >> namedGearReferences [
	gearReferencesByName ifNil: [ ^ #() ].
	^ (gearReferencesByName values sorted: [ :a :b | a name < b name ]) asArray
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
CIItemTypeCatalog >> registerGadgetFamily: family [
	gadgetFamiliesByName ifNil: [ gadgetFamiliesByName := Dictionary new ].
	(gadgetFamiliesByName includesKey: family name)
		ifTrue: [ self error: 'Duplicate gadget family' ].
	gadgetFamiliesByName at: family name put: family.
	^ family
]

{ #category : 'registration' }
CIItemTypeCatalog >> registerGearFamily: family [
	| registry |
	registry := gearFamiliesById ifNil: [ gearFamiliesById := Dictionary new ].
	(registry includesKey: family id)
		ifTrue: [ self error: 'Duplicate gear family' ].
	registry at: family id put: family.
	^ family
]

{ #category : 'registration' }
CIItemTypeCatalog >> registerGearFamilyReference: reference [
	familyReferencesByName ifNil: [ familyReferencesByName := Dictionary new ].
	(familyReferencesByName includesKey: reference name)
		ifTrue: [ self error: 'Duplicate gear family reference' ].
	familyReferencesByName at: reference name put: reference.
	^ reference
]

{ #category : 'registration' }
CIItemTypeCatalog >> registerNamedGearReference: reference [
	gearReferencesByName ifNil: [ gearReferencesByName := Dictionary new ].
	(gearReferencesByName includesKey: reference name)
		ifTrue: [ self error: 'Duplicate named gear reference' ].
	gearReferencesByName at: reference name put: reference.
	^ reference
]

{ #category : 'registration' }
CIItemTypeCatalog >> registerSpecialization: definition [
	specializationsByName ifNil: [ specializationsByName := Dictionary new ].
	(specializationsByName includesKey: definition name)
		ifTrue: [ self error: 'Duplicate specialization' ].
	specializationsByName at: definition name put: definition.
	^ definition
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

{ #category : 'registration' }
CIItemTypeCatalog >> registerTalentReference: reference [
	talentReferencesById ifNil: [ talentReferencesById := Dictionary new ].
	(talentReferencesById includesKey: reference id)
		ifTrue: [ self error: 'Duplicate talent reference' ].
	talentReferencesById at: reference id put: reference.
	^ reference
]

{ #category : 'registration' }
CIItemTypeCatalog >> registerWeaponReference: reference [
	weaponReferencesById ifNil: [ weaponReferencesById := Dictionary new ].
	(weaponReferencesById includesKey: reference id)
		ifTrue: [ self error: 'Duplicate weapon reference' ].
	weaponReferencesById at: reference id put: reference.
	^ reference
]

{ #category : 'spawning' }
CIItemTypeCatalog >> rollTalentFor: aTypeIdentifier using: randomSample [
	| pool |
	pool := self talentPoolFor: aTypeIdentifier.
	pool isEmpty ifTrue: [ ^ nil ].
	pool size = 1 ifTrue: [ ^ pool first ].
	^ pool at: (randomSample value * pool size) floor + 1
]

{ #category : 'querying' }
CIItemTypeCatalog >> specializationLoadoutNamed: label selected: identifiers [
	label = 'Universal' ifTrue: [ self error: 'Select a concrete specialization' ].
	^ CISpecializationLoadout
		definition: (self specializationNamed: label)
		universal: (self specializationNamed: 'Universal')
		selected: identifiers
]

{ #category : 'accessing' }
CIItemTypeCatalog >> specializationNamed: label [
	specializationsByName ifNil: [ self error: 'No specializations registered' ].
	^ specializationsByName at: label
]

{ #category : 'specializations' }
CIItemTypeCatalog >> specializationPerkGrantingReward: aRewardIdentifier [
	aRewardIdentifier ifNil: [ ^ nil ].
	self specializations
		do: [ :specialization | 
			specialization perks
				do: [ :perk | perk rewardIdentifier = aRewardIdentifier ifTrue: [ ^ perk ] ] ].
	^ nil
]

{ #category : 'accessing' }
CIItemTypeCatalog >> specializations [
	specializationsByName ifNil: [ ^ #() ].
	^ (specializationsByName values sorted: [ :a :b | a name < b name ]) asArray
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
CIItemTypeCatalog >> talentReferenceAt: identifier [
	talentReferencesById ifNil: [ self error: 'No talent references registered' ].
	^ talentReferencesById at: identifier
]

{ #category : 'accessing' }
CIItemTypeCatalog >> talentReferences [
	talentReferencesById ifNil: [ ^ #() ].
	^ (talentReferencesById values sorted: [ :a :b | a id < b id ]) asArray
]

{ #category : 'querying' }
CIItemTypeCatalog >> talentReferencesNamed: label [
	^ self talentReferences
		select: [ :reference | 
			(reference name sameAs: label)
				or: [ reference perfectName
						ifNil: [ false ]
						ifNotNil: [ :perfectName | perfectName sameAs: label ] ] ]
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

{ #category : 'accessing' }
CIItemTypeCatalog >> weaponReferenceAt: identifier [
	weaponReferencesById ifNil: [ self error: 'No weapon references registered' ].
	^ weaponReferencesById at: identifier
]

{ #category : 'accessing' }
CIItemTypeCatalog >> weaponReferences [
	weaponReferencesById ifNil: [ ^ #() ].
	^ (weaponReferencesById values sorted: [ :a :b | a id < b id ]) asArray
]

{ #category : 'querying' }
CIItemTypeCatalog >> weaponReferencesNamed: label [
	^ self weaponReferences select: [ :reference | reference name sameAs: label ]
]
