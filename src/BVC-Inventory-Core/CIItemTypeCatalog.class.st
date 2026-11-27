Class {
	#name : 'CIItemTypeCatalog',
	#superclass : 'Object',
	#instVars : [
		'typesById'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'initialization' }
CIItemTypeCatalog >> initialize [
	super initialize.
	typesById := Dictionary new
]

{ #category : 'accessing' }
CIItemTypeCatalog >> register: aType [
	| identifier |
	identifier := aType id.
	(identifier isString and: [ identifier notEmpty ])
		ifFalse: [ self error: 'Item type requires an identifier' ].
	(typesById includesKey: identifier)
		ifTrue: [ self error: 'Duplicate item type: ' , identifier ].
	typesById at: identifier put: aType.
	^ aType
]

{ #category : 'accessing' }
CIItemTypeCatalog >> typeAt: anIdentifier [
	^ typesById
		at: anIdentifier
		ifAbsent: [ self error: 'Unknown item type: ' , anIdentifier ]
]

{ #category : 'accessing' }
CIItemTypeCatalog >> typeAt: anIdentifier ifAbsent: aBlock [
	^ typesById at: anIdentifier ifAbsent: aBlock
]
