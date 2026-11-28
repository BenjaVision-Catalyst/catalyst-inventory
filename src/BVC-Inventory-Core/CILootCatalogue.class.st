Class {
	#name : 'CILootCatalogue',
	#superclass : 'Object',
	#instVars : [
		'poolsById'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'initialization' }
CILootCatalogue >> initialize [
	super initialize.
	poolsById := Dictionary new
]

{ #category : 'accessing' }
CILootCatalogue >> poolAt: identifier [
	^ poolsById at: identifier
]

{ #category : 'querying' }
CILootCatalogue >> poolsForItem: definitionId [
	^ ((poolsById values
		select: [ :pool | (pool entriesForItem: definitionId) notEmpty ])
		sorted: [ :a :b | a id < b id ]) asArray
]

{ #category : 'registration' }
CILootCatalogue >> register: aPool [
	(poolsById includesKey: aPool id)
		ifTrue: [ self error: 'Duplicate loot pool: ' , aPool id ].
	poolsById at: aPool id put: aPool.
	^ aPool
]
