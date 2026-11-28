Class {
	#name : 'CIWorkbookTalentReference',
	#superclass : 'Object',
	#instVars : [
		'id',
		'name',
		'perfectName',
		'scope',
		'fields',
		'fieldReferences',
		'talentIdentifier',
		'perfectTalentIdentifier',
		'gadgetTalentRule',
		'perfectGadgetTalentRule'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIWorkbookTalentReference class >> fromWorkbookRow: row sheet: title [
	^ self new initializeWorkbookRow: row sheet: title
]

{ #category : 'accessing' }
CIWorkbookTalentReference >> evidenceForField: key [
	^ (fieldReferences at: key ifAbsent: [ nil ]) ifNotNil: #copy
]

{ #category : 'accessing' }
CIWorkbookTalentReference >> fieldAt: key [
	^ (fields at: key ifAbsent: [ nil ]) ifNotNil: #copy
]

{ #category : 'accessing' }
CIWorkbookTalentReference >> gadgetTalentRule [
	^ gadgetTalentRule
]

{ #category : 'accessing' }
CIWorkbookTalentReference >> gadgetTalentRule: standard perfect: perfect [
	gadgetTalentRule := standard.
	perfectGadgetTalentRule := perfect
]

{ #category : 'accessing' }
CIWorkbookTalentReference >> id [
	^ id copy
]

{ #category : 'initialization' }
CIWorkbookTalentReference >> initializeWorkbookRow: row sheet: title [
	id := title , '!' , row first.
	name := row second copy.
	perfectName := row third ifNotNil: #copy.
	scope := row fourth.
	talentIdentifier := row fifth ifNotNil: #copy.
	perfectTalentIdentifier := (row at: 6) ifNotNil: #copy.
	fields := Dictionary new.
	fieldReferences := Dictionary new.
	row last
		do: [ :entry | 
			fields at: entry first put: entry second copy.
			fieldReferences at: entry first put: title , '!' , entry third ].
	^ self
]

{ #category : 'accessing' }
CIWorkbookTalentReference >> name [
	^ name copy
]

{ #category : 'accessing' }
CIWorkbookTalentReference >> perfectGadgetTalentRule [
	^ perfectGadgetTalentRule
]

{ #category : 'accessing' }
CIWorkbookTalentReference >> perfectName [
	^ perfectName ifNotNil: #copy
]

{ #category : 'accessing' }
CIWorkbookTalentReference >> perfectTalentIdentifier [
	^ perfectTalentIdentifier ifNotNil: #copy
]

{ #category : 'accessing' }
CIWorkbookTalentReference >> scope [
	^ scope
]

{ #category : 'accessing' }
CIWorkbookTalentReference >> talentIdentifier [
	^ talentIdentifier ifNotNil: #copy
]
