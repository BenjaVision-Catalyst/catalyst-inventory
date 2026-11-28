Class {
	#name : 'CIGearFamilyWorkbookReference',
	#superclass : 'Object',
	#instVars : [
		'name',
		'kind',
		'fields',
		'evidence',
		'runtimeFamilyIdentifier'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIGearFamilyWorkbookReference class >> name: label kind: familyKind fields: entries runtimeFamily: identifier [
	^ self new
		initializeName: label
		kind: familyKind
		fields: entries
		runtimeFamily: identifier
]

{ #category : 'initialization' }
CIGearFamilyWorkbookReference >> initializeName: label kind: familyKind fields: entries runtimeFamily: identifier [
	name := label copy.
	kind := familyKind.
	runtimeFamilyIdentifier := identifier ifNotNil: #copy.
	fields := Dictionary new.
	evidence := Dictionary new.
	entries
		do: [ :entry | 
			(fields at: entry first ifAbsentPut: [ OrderedCollection new ])
				add: entry second copy.
			(evidence at: entry first ifAbsentPut: [ OrderedCollection new ])
				add: entry third copy ].
	^ self
]

{ #category : 'accessing' }
CIGearFamilyWorkbookReference >> kind [
	^ kind
]

{ #category : 'accessing' }
CIGearFamilyWorkbookReference >> name [
	^ name copy
]

{ #category : 'accessing' }
CIGearFamilyWorkbookReference >> referencesFor: key [
	^ (evidence at: key ifAbsent: [ #() ]) collect: #copy as: Array
]

{ #category : 'accessing' }
CIGearFamilyWorkbookReference >> runtimeFamilyIdentifier [
	^ runtimeFamilyIdentifier ifNotNil: #copy
]

{ #category : 'accessing' }
CIGearFamilyWorkbookReference >> valuesFor: key [
	^ (fields at: key ifAbsent: [ #() ]) collect: #copy as: Array
]
