Class {
	#name : 'CIItemTalent',
	#superclass : 'Object',
	#instVars : [
		'id',
		'displayName',
		'eligibility',
		'parameters'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIItemTalent class >> id: anId name: aName eligibility: aKind parameters: aDictionary [
	^ self new
		initializeId: anId
		name: aName
		eligibility: aKind
		parameters: aDictionary
]

{ #category : 'accessing' }
CIItemTalent >> displayName [
	^ displayName copy
]

{ #category : 'accessing' }
CIItemTalent >> eligibility [
	^ eligibility
]

{ #category : 'accessing' }
CIItemTalent >> id [
	^ id copy
]

{ #category : 'initialization' }
CIItemTalent >> initializeId: anId name: aName eligibility: aKind parameters: aDictionary [
	(anId isString and: [ anId notEmpty ])
		ifFalse: [ self error: 'Talent ID required' ].
	(#(weapon Chest Backpack) includes: aKind)
		ifFalse: [ self error: 'Invalid talent eligibility' ].
	id := anId copy.
	displayName := aName copy.
	eligibility := aKind.
	parameters := aDictionary copy.
	^ self
]

{ #category : 'accessing' }
CIItemTalent >> parameters [
	^ parameters copy
]
