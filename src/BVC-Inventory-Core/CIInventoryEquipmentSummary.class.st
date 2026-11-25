"
Authorized projection of one individual tool, weapon, gear item or gadget. Inventory type count is independent of stack quantity.
"
Class {
	#name : 'CIInventoryEquipmentSummary',
	#superclass : 'CIInventoryItemSummary',
	#instVars : [
		'presentationKind',
		'inventoryTypeCount',
		'modSlots',
		'offensiveAttributes',
		'defensiveAttributes',
		'utilityAttributes',
		'brandIdentifier',
		'talentIdentifier',
		'expertiseLevel'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIInventoryEquipmentSummary class >> item: itemId fromDefinition: definition metadata: metadata [
	^ (self item: itemId fromDefinition: definition) initializeMetadata: metadata
]

{ #category : 'descriptions' }
CIInventoryEquipmentSummary >> attributeField: selector label: aLabel [
	^ self
		readOnly: (MAToManyScalarRelationDescription new
				accessor: selector;
				label: aLabel;
				classes: {String};
				reference: (MAStringDescription new
						accessor: MANullAccessor new;
						yourself);
				beOrdered;
				yourself)
]

{ #category : 'initialization' }
CIInventoryEquipmentSummary >> attributesAt: key in: metadata [
	| values |
	values := (metadata at: key ifAbsent: [ #() ]) asArray.
	(values size <= 16
		and: [ values
				allSatisfy: [ :value | value isString and: [ value size between: 1 and: 128 ] ] ])
		ifFalse: [ self error: 'Invalid equipment attribute identifiers' ].
	^ values collect: #copy
]

{ #category : 'accessing' }
CIInventoryEquipmentSummary >> brandIdentifier [
	^ brandIdentifier copy
]

{ #category : 'accessing' }
CIInventoryEquipmentSummary >> defensiveAttributes [
	^ defensiveAttributes collect: #copy
]

{ #category : 'accessing' }
CIInventoryEquipmentSummary >> expertiseLevel [
	^ expertiseLevel
]

{ #category : 'initialization' }
CIInventoryEquipmentSummary >> initializeMetadata: metadata [
	presentationKind := metadata at: #presentationKind.
	(#('tool' 'weapon' 'gear' 'gadget') includes: presentationKind)
		ifFalse: [ self error: 'Unsupported equipment kind' ].
	presentationKind := presentationKind copy.
	inventoryTypeCount := metadata at: #inventoryTypeCount.
	(inventoryTypeCount isInteger and: [ inventoryTypeCount >= 0 ])
		ifFalse: [ self error: 'Invalid inventory type count' ].
	modSlots := (metadata at: #modSlots ifAbsent: [ #() ]) asArray copy.
	(modSlots size <= 16
		and: [ modSlots allSatisfy: [ :slot | slot isKindOf: CIInventoryModSlotSummary ] ])
		ifFalse: [ self error: 'Invalid mod slots' ].
	(modSlots collect: #slotIdentifier) asSet size = modSlots size
		ifFalse: [ self error: 'Duplicate mod slot' ].
	offensiveAttributes := self attributesAt: #offensiveAttributes in: metadata.
	defensiveAttributes := self attributesAt: #defensiveAttributes in: metadata.
	utilityAttributes := self attributesAt: #utilityAttributes in: metadata.
	brandIdentifier := self optionalIdentifierAt: #brandIdentifier in: metadata.
	talentIdentifier := self optionalIdentifierAt: #talentIdentifier in: metadata.
	expertiseLevel := metadata at: #expertiseLevel ifAbsent: [ nil ].
	(expertiseLevel isNil
		or: [ expertiseLevel isInteger and: [ expertiseLevel >= 0 ] ])
		ifFalse: [ self error: 'Invalid expertise level' ].
	^ self
]

{ #category : 'accessing' }
CIInventoryEquipmentSummary >> inventoryTypeCount [
	^ inventoryTypeCount
]

{ #category : 'descriptions' }
CIInventoryEquipmentSummary >> magritteDescription [
	^ MAContainer
		withAll: super magritteDescription children asArray
				, {self readOnlyField: #presentationKind label: 'Presentation kind'.
						self
							readOnly: (MANumberDescription new
									accessor: #inventoryTypeCount;
									label: 'Items of this type';
									min: 0;
									beRequired;
									yourself).
						self
							readOnly: (MAToManyRelationDescription new
									accessor: #modSlots;
									label: 'Mod slots';
									classes: {CIInventoryModSlotSummary};
									beOrdered;
									yourself).
						self attributeField: #offensiveAttributes label: 'Offensive attributes'.
						self attributeField: #defensiveAttributes label: 'Defensive attributes'.
						self attributeField: #utilityAttributes label: 'Utility attributes'.
						self
							readOnly: (MAStringDescription new
									accessor: #brandIdentifier;
									label: 'Brand';
									yourself).
						self
							readOnly: (MAStringDescription new
									accessor: #talentIdentifier;
									label: 'Talent';
									yourself).
						self
							readOnly: (MANumberDescription new
									accessor: #expertiseLevel;
									label: 'Expertise';
									min: 0;
									yourself)}
]

{ #category : 'accessing' }
CIInventoryEquipmentSummary >> modSlots [
	^ modSlots copy
]

{ #category : 'accessing' }
CIInventoryEquipmentSummary >> offensiveAttributes [
	^ offensiveAttributes collect: #copy
]

{ #category : 'initialization' }
CIInventoryEquipmentSummary >> optionalIdentifierAt: key in: metadata [
	| value |
	value := metadata at: key ifAbsent: [ ^ nil ].
	value ifNil: [ ^ nil ].
	(value isString and: [ value size between: 1 and: 128 ])
		ifFalse: [ self error: 'Invalid equipment identifier' ].
	^ value copy
]

{ #category : 'accessing' }
CIInventoryEquipmentSummary >> presentationKind [
	^ presentationKind copy
]

{ #category : 'descriptions' }
CIInventoryEquipmentSummary >> readOnly: description [
	(description respondsTo: #readOnly:)
		ifTrue: [ description readOnly: true ]
		ifFalse: [ description readonly: true ].
	^ description
]

{ #category : 'accessing' }
CIInventoryEquipmentSummary >> talentIdentifier [
	^ talentIdentifier copy
]

{ #category : 'accessing' }
CIInventoryEquipmentSummary >> utilityAttributes [
	^ utilityAttributes collect: #copy
]
