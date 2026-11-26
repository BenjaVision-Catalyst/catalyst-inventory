Class {
	#name : 'CIInventoryGearSummary',
	#superclass : 'CIInventoryEquipmentSummary',
	#instVars : [
		'brandName',
		'gearSlotIdentifier',
		'requiredPlayerLevel',
		'isJunk',
		'isFavorite',
		'isProficient',
		'primaryAttribute',
		'maximumAttributes',
		'talentIdentifiers'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'accessing' }
CIInventoryGearSummary >> brandName [
	^ brandName copy
]

{ #category : 'accessing' }
CIInventoryGearSummary >> equippedSlotIdentifier [
	^ super equippedSlotIdentifier ifNil: [ self gearSlotIdentifier ]
]

{ #category : 'initialization' }
CIInventoryGearSummary >> flagAt: key in: metadata [
	| flag |
	flag := metadata at: key ifAbsent: [ false ].
	(flag == true or: [ flag == false ])
		ifFalse: [ self error: 'Invalid gear flag' ].
	^ flag
]

{ #category : 'accessing' }
CIInventoryGearSummary >> gearSlotIdentifier [
	^ gearSlotIdentifier copy
]

{ #category : 'initialization' }
CIInventoryGearSummary >> initializeMetadata: metadata [
	super initializeMetadata: metadata.
	self presentationKind = 'gear' ifFalse: [ self error: 'Expected gear' ].
	brandName := self optionalIdentifierAt: #brandName in: metadata.
	gearSlotIdentifier := self
			optionalIdentifierAt: #gearSlotIdentifier
			in: metadata.
	requiredPlayerLevel := metadata at: #requiredPlayerLevel ifAbsent: [ nil ].
	(requiredPlayerLevel isNil
		or: [ requiredPlayerLevel isInteger and: [ requiredPlayerLevel >= 0 ] ])
		ifFalse: [ self error: 'Invalid required player level' ].
	isJunk := self flagAt: #isJunk in: metadata.
	isFavorite := self flagAt: #isFavorite in: metadata.
	isProficient := self flagAt: #isProficient in: metadata.
	primaryAttribute := metadata at: #primaryAttribute ifAbsent: [ nil ].
	(primaryAttribute isNil
		or: [ primaryAttribute isKindOf: CIInventoryGearAttributeSummary ])
		ifFalse: [ self error: 'Invalid primary attribute' ].
	maximumAttributes := self attributesAt: #maximumAttributes in: metadata.
	(maximumAttributes
		allSatisfy: [ :id |
			self offensiveAttributes , self defensiveAttributes , self utilityAttributes
				includes: id ])
		ifFalse: [ self error: 'Maximum attribute must exist on this item' ].
	talentIdentifiers := self attributesAt: #talentIdentifiers in: metadata.
	^ self
]

{ #category : 'accessing' }
CIInventoryGearSummary >> isFavorite [
	^ isFavorite
]

{ #category : 'accessing' }
CIInventoryGearSummary >> isJunk [
	^ isJunk
]

{ #category : 'accessing' }
CIInventoryGearSummary >> isProficient [
	^ isProficient
]

{ #category : 'descriptions' }
CIInventoryGearSummary >> magritteDescription [
	^ MAContainer
		withAll: super magritteDescription children asArray
				, {self
							readOnly: (MAStringDescription new
									accessor: #brandName;
									label: 'Brand name';
									yourself).
						self
							readOnly: (MAStringDescription new
									accessor: #gearSlotIdentifier;
									label: 'Gear slot';
									yourself).
						self
							readOnly: (MANumberDescription new
									accessor: #requiredPlayerLevel;
									label: 'Required player level';
									min: 0;
									yourself).
						self
							readOnly: (MABooleanDescription new
									accessor: #isJunk;
									label: 'Marked as junk';
									yourself).
						self
							readOnly: (MABooleanDescription new
									accessor: #isFavorite;
									label: 'Favorite';
									yourself).
						self
							readOnly: (MABooleanDescription new
									accessor: #isProficient;
									label: 'Proficient';
									yourself).
						self
							readOnly: (MAToOneRelationDescription new
									accessor: #primaryAttribute;
									label: 'Primary attribute';
									classes: {CIInventoryGearAttributeSummary};
									yourself).
						self attributeField: #maximumAttributes label: 'Maximum attributes'.
						self attributeField: #talentIdentifiers label: 'Talents'}
]

{ #category : 'accessing' }
CIInventoryGearSummary >> maximumAttributes [
	^ maximumAttributes collect: #copy
]

{ #category : 'accessing' }
CIInventoryGearSummary >> primaryAttribute [
	^ primaryAttribute
]

{ #category : 'accessing' }
CIInventoryGearSummary >> requiredPlayerLevel [
	^ requiredPlayerLevel
]

{ #category : 'accessing' }
CIInventoryGearSummary >> talentIdentifiers [
	^ talentIdentifiers collect: #copy
]
