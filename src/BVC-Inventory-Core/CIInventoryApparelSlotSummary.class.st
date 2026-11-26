Class {
	#name : 'CIInventoryApparelSlotSummary',
	#superclass : 'Object',
	#instVars : [
		'categoryIdentifier',
		'inventoryTypeCount',
		'equippedDefinitionIdentifier',
		'tierId'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIInventoryApparelSlotSummary class >> category: category tier: tier inventoryCount: amount equippedDefinition: equippedDefinition [
	^ self new
		initializeCategory: category
		tier: tier
		inventoryCount: amount
		equippedDefinition: equippedDefinition
]

{ #category : 'accessing' }
CIInventoryApparelSlotSummary >> categoryIdentifier [
	^ categoryIdentifier copy
]

{ #category : 'accessing' }
CIInventoryApparelSlotSummary >> equippedDefinitionIdentifier [
	^ equippedDefinitionIdentifier copy
]

{ #category : 'initialization' }
CIInventoryApparelSlotSummary >> initializeCategory: category tier: tier inventoryCount: amount equippedDefinition: equippedDefinition [
	(category isString and: [ category size between: 1 and: 128 ])
		ifFalse: [ self error: 'Invalid apparel category' ].
	(tier isInteger and: [ tier between: 1 and: 6 ])
		ifFalse: [ self error: 'Invalid apparel tier' ].
	(amount isInteger and: [ amount >= 0 ])
		ifFalse: [ self error: 'Invalid apparel inventory count' ].
	(equippedDefinition isNil
		or: [ equippedDefinition isString
				and: [ equippedDefinition size between: 1 and: 128 ] ])
		ifFalse: [ self error: 'Invalid equipped apparel definition' ].
	categoryIdentifier := category copy.
	inventoryTypeCount := amount.
	equippedDefinitionIdentifier := equippedDefinition copy.
	tierId := tier.
	^ self
]

{ #category : 'accessing' }
CIInventoryApparelSlotSummary >> inventoryTypeCount [
	^ inventoryTypeCount
]

{ #category : 'descriptions' }
CIInventoryApparelSlotSummary >> magritteDescription [
	^ MAContainer
		withAll: {MAStringDescription new
					accessor: #categoryIdentifier;
					label: 'Apparel category';
					readOnly: true;
					beRequired;
					yourself.
				MANumberDescription new
					accessor: #inventoryTypeCount;
					label: 'Items of this type';
					min: 0;
					readOnly: true;
					beRequired;
					yourself.
				MANumberDescription new
					accessor: #tierId;
					label: 'Tier';
					min: 1;
					max: 6;
					readOnly: true;
					beRequired;
					yourself.
				MAStringDescription new
					accessor: #equippedDefinitionIdentifier;
					label: 'Equipped definition';
					readOnly: true;
					yourself}
]

{ #category : 'accessing' }
CIInventoryApparelSlotSummary >> tierId [
	^ tierId
]
