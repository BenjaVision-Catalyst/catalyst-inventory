Class {
	#name : 'CIInventoryApparelItemSummary',
	#superclass : 'CIInventoryItemSummary',
	#instVars : [
		'brandName'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIInventoryApparelItemSummary class >> item: itemIdentifier fromDefinition: definition brandName: aName [
	^ (self item: itemIdentifier fromDefinition: definition)
		initializeBrandName: aName
]

{ #category : 'accessing' }
CIInventoryApparelItemSummary >> brandName [
	^ brandName copy
]

{ #category : 'initialization' }
CIInventoryApparelItemSummary >> initializeBrandName: aName [
	(aName isNil or: [ aName isString and: [ aName size between: 1 and: 128 ] ])
		ifFalse: [ self error: 'Invalid apparel brand name' ].
	brandName := aName copy.
	^ self
]

{ #category : 'descriptions' }
CIInventoryApparelItemSummary >> magritteDescription [
	^ MAContainer
		withAll: super magritteDescription children asArray
				, {MAStringDescription new
							accessor: #brandName;
							label: 'Brand name';
							readOnly: true;
							yourself}
]
