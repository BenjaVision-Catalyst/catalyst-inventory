Class {
	#name : 'CIInventoryWeaponToolSummary',
	#superclass : 'CIInventoryEquipmentSummary',
	#instVars : [
		'consumableTypeIdentifier',
		'requiredPlayerLevel',
		'isProficient',
		'comparisonStats',
		'maximumAttributes',
		'talentIdentifiers',
		'weaponDefinitionRevision'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'accessing' }
CIInventoryWeaponToolSummary >> comparisonStats [
	^ comparisonStats copy
]

{ #category : 'accessing' }
CIInventoryWeaponToolSummary >> consumableTypeIdentifier [
	^ consumableTypeIdentifier copy
]

{ #category : 'gt' }
CIInventoryWeaponToolSummary >> gtWeaponDefinitionFor: aView [
	<gtView>
	weaponDefinitionRevision ifNil: [ ^ aView empty ].
	^ aView list
		title: 'Weapon definition';
		priority: 15;
		items: [ {'Pinned revision' -> weaponDefinitionRevision.
				'Generated talent'
					-> (weaponDefinitionRevision talentAt: self talentIdentifier).
				'Generated rolls' -> self comparisonStats.
				'Installed mods' -> self modSlots} ];
		itemText: #key;
		send: #value
]

{ #category : 'gt' }
CIInventoryWeaponToolSummary >> hasMagritteDescription [
	^ true
]

{ #category : 'initialization' }
CIInventoryWeaponToolSummary >> initializeMetadata: metadata [
	super initializeMetadata: metadata.
	(#('tool' 'weapon') includes: self presentationKind)
		ifFalse: [ self error: 'Expected a tool or weapon' ].
	consumableTypeIdentifier := self
			optionalIdentifierAt: #consumableTypeIdentifier
			in: metadata.
	requiredPlayerLevel := metadata at: #requiredPlayerLevel ifAbsent: [ nil ].
	(requiredPlayerLevel isNil
		or: [ requiredPlayerLevel isInteger and: [ requiredPlayerLevel >= 0 ] ])
		ifFalse: [ self error: 'Invalid required player level' ].
	isProficient := metadata at: #isProficient ifAbsent: [ false ].
	(isProficient == true or: [ isProficient == false ])
		ifFalse: [ self error: 'Invalid proficiency status' ].
	comparisonStats := (metadata at: #comparisonStats ifAbsent: [ #() ]) asArray
			copy.
	(comparisonStats size <= 8
		and: [ comparisonStats
				allSatisfy: [ :each | each isKindOf: CIInventoryComparisonStat ] ])
		ifFalse: [ self error: 'Invalid comparison stats' ].
	(comparisonStats collect: #statIdentifier) asSet size = comparisonStats size
		ifFalse: [ self error: 'Duplicate comparison stat' ].
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
CIInventoryWeaponToolSummary >> isProficient [
	^ isProficient
]

{ #category : 'descriptions' }
CIInventoryWeaponToolSummary >> magritteDescription [
	^ MAContainer
		withAll: super magritteDescription children asArray
				, {self
							readOnly: (MAStringDescription new
									accessor: #consumableTypeIdentifier;
									label: 'Consumable type';
									yourself).
						self
							readOnly: (MANumberDescription new
									accessor: #requiredPlayerLevel;
									label: 'Required player level';
									min: 0;
									yourself).
						self
							readOnly: (MABooleanDescription new
									accessor: #isProficient;
									label: 'Proficient';
									yourself).
						self
							readOnly: (MAToManyRelationDescription new
									accessor: #comparisonStats;
									label: 'Comparison stats';
									classes: {CIInventoryComparisonStat};
									beOrdered;
									yourself).
						self attributeField: #maximumAttributes label: 'Maximum attributes'.
						self attributeField: #talentIdentifiers label: 'Talents'}
]

{ #category : 'accessing' }
CIInventoryWeaponToolSummary >> maximumAttributes [
	^ maximumAttributes collect: #copy
]

{ #category : 'initialization' }
CIInventoryWeaponToolSummary >> pinWeaponDefinitionRevision: definition [
	(weaponDefinitionRevision isNil
		and: [ definition isDraft not
				and: [ definition definitionIdentifier = self definitionIdentifier ] ])
		ifFalse: [ self error: 'Cannot change the pinned weapon revision' ].
	weaponDefinitionRevision := definition
]

{ #category : 'accessing' }
CIInventoryWeaponToolSummary >> requiredPlayerLevel [
	^ requiredPlayerLevel
]

{ #category : 'accessing' }
CIInventoryWeaponToolSummary >> talentIdentifiers [
	^ talentIdentifiers collect: #copy
]

{ #category : 'accessing' }
CIInventoryWeaponToolSummary >> weaponDefinitionRevision [
	^ weaponDefinitionRevision
]
