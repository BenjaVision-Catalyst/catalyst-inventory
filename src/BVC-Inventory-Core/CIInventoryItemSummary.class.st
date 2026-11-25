"
A detached, read-only Inventory row. An instance identifier addresses an owned item. A definition identifier identifies its catalogue entry.
"
Class {
	#name : 'CIInventoryItemSummary',
	#superclass : 'Object',
	#instVars : [
		'itemIdentifier',
		'definitionIdentifier',
		'displayName',
		'tierId'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIInventoryItemSummary class >> item: anItemIdentifier definition: aDefinitionIdentifier name: aName [
	^ self new
		initializeItem: anItemIdentifier
		definition: aDefinitionIdentifier
		name: aName
]

{ #category : 'instance creation' }
CIInventoryItemSummary class >> item: anItemIdentifier fromDefinition: aDefinition [
	^ (self
		item: anItemIdentifier
		definition: aDefinition id
		name: aDefinition displayName) initializeTierFrom: aDefinition
]

{ #category : 'accessing' }
CIInventoryItemSummary >> definitionIdentifier [
	^ definitionIdentifier copy
]

{ #category : 'accessing' }
CIInventoryItemSummary >> displayName [
	^ displayName copy
]

{ #category : 'initialization' }
CIInventoryItemSummary >> initializeItem: anItemIdentifier definition: aDefinitionIdentifier name: aName [
	itemIdentifier := anItemIdentifier copy.
	definitionIdentifier := aDefinitionIdentifier copy.
	displayName := aName copy
]

{ #category : 'initialization' }
CIInventoryItemSummary >> initializeTierFrom: aDefinition [
	tierId := aDefinition tierId.
	^ self
]

{ #category : 'accessing' }
CIInventoryItemSummary >> itemIdentifier [
	^ itemIdentifier copy
]

{ #category : 'descriptions' }
CIInventoryItemSummary >> magritteDescription [
	| tier |
	tier := MANumberDescription new
			accessor: #tierId;
			label: 'Tier';
			min: 1;
			max: 6;
			beRequired;
			yourself.
	(tier respondsTo: #readOnly:)
		ifTrue: [ tier readOnly: true ]
		ifFalse: [ tier readonly: true ].
	^ MAContainer
		withAll: {self readOnlyField: #itemIdentifier label: 'Item identifier'.
				self readOnlyField: #definitionIdentifier label: 'Definition identifier'.
				self readOnlyField: #displayName label: 'Name'.
				tier}
]

{ #category : 'descriptions' }
CIInventoryItemSummary >> readOnlyField: aSelector label: aLabel [
	| description |
	description := MAStringDescription new
			accessor: aSelector;
			label: aLabel;
			beRequired;
			yourself.
	(description respondsTo: #readOnly:)
		ifTrue: [ description readOnly: true ]
		ifFalse: [ description readonly: true ].
	^ description
]

{ #category : 'accessing' }
CIInventoryItemSummary >> tierId [
	^ tierId ifNil: [ 1 ]
]
