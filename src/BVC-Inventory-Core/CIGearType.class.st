Class {
	#name : 'CIGearType',
	#superclass : 'CIItemType',
	#instVars : [
		'slotIdentifier',
		'attributeSpecs',
		'socketIdentifiers'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIGearType class >> id: id name: name slot: slot attributes: attributes sockets: sockets [
	^ (self
		id: id
		name: name
		icon: nil)
		initializeSlot: slot
		attributes: attributes
		sockets: sockets
]

{ #category : 'initialization' }
CIGearType >> initializeSlot: slot attributes: attributes sockets: sockets [
	slotIdentifier := slot copy.
	attributeSpecs := attributes asArray copy.
	socketIdentifiers := sockets asArray copy.
	^ self
]

{ #category : 'descriptions' }
CIGearType >> inspectorIdentityFor: item [
	| fields armour |
	fields := super inspectorIdentityFor: item.
	(item isKindOf: CIInventoryCatalogGear) ifFalse: [ ^ fields ].
	armour := fields at: 'inspectorArmour' ifAbsent: [ 0 ].
	{item primaryAttribute} , item rolledAttributes
		do: [ :attribute |
			attribute attributeIdentifier = 'armor'
				ifTrue: [ armour := armour + attribute value ] ].
	armour > 0 ifTrue: [ fields at: 'inspectorArmour' put: armour ].
	^ fields
]

{ #category : 'private' }
CIGearType >> inspectorRowFor: attribute [
	| amount text spec maximum |
	amount := attribute value.
	text := attribute valueFormat = 'signedPercent'
			ifTrue: [ (amount * 100 printShowingDecimalPlaces: 1) , '%' ]
			ifFalse: [ amount asString ].
	amount > 0 ifTrue: [ text := '+' , text ].
	spec := attributeSpecs
			detect: [ :each | each first = attribute attributeIdentifier ]
			ifNone: [ nil ].
	maximum := (spec notNil and: [ (spec at: 5) < (spec at: 6) ])
			ifTrue: [ spec at: 6 ].
	^ {attribute displayName.
		text.
		amount.
		maximum.
		attribute attributeType}
]

{ #category : 'descriptions' }
CIGearType >> inspectorSectionsAtUtilityTier: tier item: item [
	(item isKindOf: CIInventoryCatalogGear) ifFalse: [ ^ #() ].
	^ {{'primary'.
			'Core Attribute'.
			{self inspectorRowFor: item primaryAttribute}}.
		{'modifiers'.
			'Attributes'.
			item rolledAttributes collect: [ :each | self inspectorRowFor: each ]}.
		{'slots'.
			'Mods'.
			item modSlots
				collect: [ :each |
					{each slotIdentifier capitalized.
						each equippedModIdentifier ifNil: [ 'Empty' ]} ]}}
]

{ #category : 'instance creation' }
CIGearType >> inventoryItem: itemIdentifier values: values [
	^ self
		inventoryItem: itemIdentifier
		values: values
		talentIdentifier: nil
]

{ #category : 'spawning' }
CIGearType >> inventoryItem: itemIdentifier values: values talentIdentifier: aTalentIdentifier [
	| attributes item metadata |
	self validateInventoryItemValues: values.
	attributes := attributeSpecs
			collect: [ :spec | 
				| amount |
				amount := values at: spec first.
				CIInventoryGearAttributeSummary
					identifier: spec first
					label: spec second
					type: spec third
					value: amount
					format: spec fourth
					hasMaximum: amount = (spec at: 6) ].
	metadata := Dictionary new
			at: #presentationKind put: 'gear';
			at: #inventoryTypeCount put: 1;
			at: #talentIdentifier put: aTalentIdentifier;
			at: #talentIdentifiers
				put: (aTalentIdentifier ifNil: [ #() ] ifNotNil: [ {aTalentIdentifier} ]);
			at: #gearSlotIdentifier put: slotIdentifier;
			at: #primaryAttribute put: attributes first;
			at: #rolledAttributes put: attributes allButFirst;
			at: #modSlots
				put: (socketIdentifiers
						collect: [ :id | 
							CIInventoryModSlotSummary
								slot: id
								equippedMod: (values at: id ifAbsent: [ nil ]) ]);
			yourself.
	item := CIInventoryCatalogGear
			item: itemIdentifier
			fromDefinition: self
			metadata: metadata.
	item availableEquipmentSlotIdentifiers: {slotIdentifier}.
	item equippedSlotIdentifier: nil.
	^ item
]

{ #category : 'descriptions' }
CIGearType >> inventoryItemDescription [
	^ MAContainer
		withAll: (attributeSpecs
				collect: [ :spec |
					MANumberDescription new
						accessor: (MADictionaryAccessor key: spec first);
						label: spec second;
						min: (spec at: 5);
						max: (spec at: 6);
						beRequired;
						yourself ])
				, (socketIdentifiers
						collect: [ :identifier |
							MAStringDescription new
								accessor: (MADictionaryAccessor key: identifier);
								label: identifier capitalized;
								yourself ])
]

{ #category : 'accessing' }
CIGearType >> talentEligibility [
	^ slotIdentifier asSymbol
]
