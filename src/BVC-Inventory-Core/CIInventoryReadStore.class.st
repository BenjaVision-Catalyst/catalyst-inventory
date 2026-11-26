Class {
	#name : 'CIInventoryReadStore',
	#superclass : 'Object',
	#instVars : [
		'rowsByOwner'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'initialization' }
CIInventoryReadStore >> initialize [
	super initialize.
	rowsByOwner := Dictionary new
]

{ #category : 'writing' }
CIInventoryReadStore >> replaceRows: aCollection forOwner: anOwnerIdentifier [
	| rows identifiers |
	self validateOwner: anOwnerIdentifier.
	rows := aCollection asArray copy.
	identifiers := Set new.
	rows
		do: [ :row |
			(row isKindOf: CIInventoryItemSummary)
				ifFalse: [ self error: 'Inventory item summary required' ].
			(identifiers includes: row itemIdentifier)
				ifTrue: [ self error: 'Duplicate inventory item identifier' ].
			identifiers add: row itemIdentifier ].
	rowsByOwner at: anOwnerIdentifier copy put: rows
]

{ #category : 'reading' }
CIInventoryReadStore >> rowsForOwner: anOwnerIdentifier offset: anOffset limit: aLimit [
	| rows end |
	self validateOwner: anOwnerIdentifier.
	(anOffset isInteger and: [ anOffset >= 0 ])
		ifFalse: [ self error: 'Invalid Inventory offset' ].
	(aLimit isInteger and: [ aLimit between: 1 and: 32 ])
		ifFalse: [ self error: 'Invalid Inventory page limit' ].
	rows := rowsByOwner at: anOwnerIdentifier ifAbsent: [ ^ #() ].
	anOffset >= rows size ifTrue: [ ^ #() ].
	end := anOffset + aLimit min: rows size.
	^ rows copyFrom: anOffset + 1 to: end
]

{ #category : 'private' }
CIInventoryReadStore >> validateOwner: anOwnerIdentifier [
	(anOwnerIdentifier isString and: [ anOwnerIdentifier isNotEmpty ])
		ifFalse: [ self error: 'Catalyst User identifier required' ]
]
