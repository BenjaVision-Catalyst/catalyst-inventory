"
A workbook-specified named weapon attribute. The value is catalog data. The activation condition determines when it contributes to an effective loadout.
"
Class {
	#name : 'CIWeaponFixedAttribute',
	#superclass : 'Object',
	#instVars : [
		'statIdentifier',
		'label',
		'magnitude',
		'unit',
		'role',
		'condition',
		'evidence'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIWeaponFixedAttribute class >> fromWorkbookRow: row evidence: source [
	^ self new initializeFromWorkbookRow: row evidence: source
]

{ #category : 'testing' }
CIWeaponFixedAttribute >> appliesWhileWeaponInUse: active [
	^ condition = #always or: [ condition = #whileActiveWeapon and: [ active ] ]
]

{ #category : 'accessing' }
CIWeaponFixedAttribute >> condition [
	^ condition
]

{ #category : 'accessing' }
CIWeaponFixedAttribute >> evidence [
	^ evidence copy
]

{ #category : 'initialization' }
CIWeaponFixedAttribute >> initializeFromWorkbookRow: row evidence: source [
	statIdentifier := row first copy.
	label := row second copy.
	magnitude := row third.
	unit := row fourth.
	role := row fifth.
	condition := row sixth.
	evidence := source copy
]

{ #category : 'accessing' }
CIWeaponFixedAttribute >> label [
	^ label copy
]

{ #category : 'accessing' }
CIWeaponFixedAttribute >> magnitude [
	^ magnitude
]

{ #category : 'accessing' }
CIWeaponFixedAttribute >> role [
	^ role
]

{ #category : 'accessing' }
CIWeaponFixedAttribute >> statIdentifier [
	^ statIdentifier copy
]

{ #category : 'accessing' }
CIWeaponFixedAttribute >> unit [
	^ unit
]
