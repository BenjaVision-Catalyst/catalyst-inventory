Class {
	#name : 'CIInventoryResourceStackSummary',
	#superclass : 'CIInventoryItemSummary',
	#instVars : [
		'count'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIInventoryResourceStackSummary class >> stack: stackIdentifier definition: definitionIdentifier name: aName count: amount [
	^ (self
		item: stackIdentifier
		definition: definitionIdentifier
		name: aName) initializeCount: amount
]

{ #category : 'accessing' }
CIInventoryResourceStackSummary >> count [
	^ count
]

{ #category : 'initialization' }
CIInventoryResourceStackSummary >> initializeCount: amount [
	(amount isInteger and: [ amount > 0 ])
		ifFalse: [ self error: 'Invalid resource stack quantity' ].
	count := amount.
	^ self
]

{ #category : 'descriptions' }
CIInventoryResourceStackSummary >> magritteDescription [
	^ MAContainer
		withAll: {self readOnlyField: #itemIdentifier label: 'Stack identifier'.
				self readOnlyField: #definitionIdentifier label: 'Resource definition'.
				MAStringDescription new
					accessor: #displayName;
					label: 'Name';
					readOnly: true;
					yourself.
				MANumberDescription new
					accessor: #count;
					label: 'Stack quantity';
					min: 1;
					readOnly: true;
					beRequired;
					yourself}
]

{ #category : 'accessing' }
CIInventoryResourceStackSummary >> tierId [
	^ nil
]
