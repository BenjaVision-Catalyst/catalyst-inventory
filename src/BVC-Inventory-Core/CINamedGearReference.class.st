Class {
	#name : 'CINamedGearReference',
	#superclass : 'Object',
	#instVars : [
		'name',
		'slot',
		'kind',
		'fields',
		'fieldReferences',
		'itemDefinitionIdentifier'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CINamedGearReference class >> fromWorkbookRow: row [
	^ self new initializeWorkbookRow: row
]

{ #category : 'accessing' }
CINamedGearReference >> evidenceForField: key [
	^ (fieldReferences at: key ifAbsent: [ nil ]) ifNotNil: #copy
]

{ #category : 'accessing' }
CINamedGearReference >> fieldAt: key [
	^ (fields at: key ifAbsent: [ nil ]) ifNotNil: #copy
]

{ #category : 'initialization' }
CINamedGearReference >> initializeWorkbookRow: row [
	name := row first copy.
	slot := row second copy.
	kind := row third.
	itemDefinitionIdentifier := row fourth ifNotNil: #copy.
	fields := Dictionary new.
	fieldReferences := Dictionary new.
	row fifth
		do: [ :entry | 
			fields at: entry first put: entry second copy.
			fieldReferences at: entry first put: entry third copy ].
	^ self
]

{ #category : 'accessing' }
CINamedGearReference >> itemDefinitionIdentifier [
	^ itemDefinitionIdentifier ifNotNil: #copy
]

{ #category : 'accessing' }
CINamedGearReference >> kind [
	^ kind
]

{ #category : 'accessing' }
CINamedGearReference >> name [
	^ name copy
]

{ #category : 'accessing' }
CINamedGearReference >> slot [
	^ slot copy
]
