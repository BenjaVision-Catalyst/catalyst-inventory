Class {
	#name : 'CIItemType',
	#superclass : 'CIInventoryItemDefinition',
	#instVars : [
		'inspectorIdentity'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'initialization' }
CIItemType >> inspectorIdentity: fields [
	inspectorIdentity := fields copy
]

{ #category : 'descriptions' }
CIItemType >> inspectorIdentityFor: item [
	^ inspectorIdentity
		ifNil: [ Dictionary new ]
		ifNotNil: [ :fields | fields copy ]
]

{ #category : 'descriptions' }
CIItemType >> inspectorSectionsAtUtilityTier: tier item: item [
	^ #()
]

{ #category : 'instance creation' }
CIItemType >> inventoryItem: itemIdentifier values: values [
	self subclassResponsibility
]

{ #category : 'spawning' }
CIItemType >> inventoryItem: itemIdentifier values: values talentIdentifier: aTalentIdentifier [
	aTalentIdentifier
		ifNotNil: [ self error: 'This item type cannot carry a talent' ].
	^ self inventoryItem: itemIdentifier values: values
]

{ #category : 'descriptions' }
CIItemType >> inventoryItemDescription [
	^ MAContainer new
]

{ #category : 'accessing' }
CIItemType >> talentEligibility [
	^ nil
]

{ #category : 'validation' }
CIItemType >> validateInventoryItemValues: values [
	| description allowedKeys |
	(values isKindOf: Dictionary)
		ifFalse: [ self error: 'Inventory item values must be a dictionary' ].
	description := self inventoryItemDescription.
	allowedKeys := description children collect: [ :field | field accessor key ].
	(values keys allSatisfy: [ :key | allowedKeys includes: key ])
		ifFalse: [ self error: 'Unexpected inventory item field' ].
	description validate: values
]
