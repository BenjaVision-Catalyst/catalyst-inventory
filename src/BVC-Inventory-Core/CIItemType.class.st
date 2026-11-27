Class {
	#name : 'CIItemType',
	#superclass : 'CIInventoryItemDefinition',
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIItemType >> inventoryItem: itemIdentifier values: values [
	self subclassResponsibility
]

{ #category : 'descriptions' }
CIItemType >> inventoryItemDescription [
	^ MAContainer new
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
