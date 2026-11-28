Class {
	#name : 'CIWeaponWorkbookReference',
	#superclass : 'Object',
	#instVars : [
		'id',
		'name',
		'weaponClass',
		'kind',
		'fields',
		'fieldReferences',
		'itemDefinitionIdentifier',
		'fixedMounts'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIWeaponWorkbookReference class >> fromWorkbookRow: row sheet: title [
	^ self new initializeWorkbookRow: row sheet: title
]

{ #category : 'initialization' }
CIWeaponWorkbookReference >> addFixedMount: mount [
	fixedMounts := (fixedMounts ifNil: [ #() ]) copyWith: mount
]

{ #category : 'accessing' }
CIWeaponWorkbookReference >> evidenceForField: key [
	^ (fieldReferences at: key ifAbsent: [ nil ]) ifNotNil: #copy
]

{ #category : 'accessing' }
CIWeaponWorkbookReference >> fieldAt: key [
	^ (fields at: key ifAbsent: [ nil ]) ifNotNil: #copy
]

{ #category : 'accessing' }
CIWeaponWorkbookReference >> id [
	^ id copy
]

{ #category : 'initialization' }
CIWeaponWorkbookReference >> initializeWorkbookRow: row sheet: title [
	id := title , '!' , row first.
	name := row second copy.
	weaponClass := row third.
	kind := row fourth.
	itemDefinitionIdentifier := row fifth ifNotNil: #copy.
	fields := Dictionary new.
	fieldReferences := Dictionary new.
	row last
		do: [ :entry | 
			fields at: entry first put: entry second copy.
			fieldReferences at: entry first put: title , '!' , entry third ].
	^ self
]

{ #category : 'accessing' }
CIWeaponWorkbookReference >> itemDefinitionIdentifier [
	^ itemDefinitionIdentifier ifNotNil: #copy
]

{ #category : 'accessing' }
CIWeaponWorkbookReference >> kind [
	^ kind
]

{ #category : 'initialization' }
CIWeaponWorkbookReference >> linkItemDefinition: typeIdentifier [
	(itemDefinitionIdentifier notNil
		and: [ itemDefinitionIdentifier ~= typeIdentifier ])
		ifTrue: [ self error: 'Weapon reference already links to a different item definition' ].
	itemDefinitionIdentifier := typeIdentifier copy
]

{ #category : 'accessing' }
CIWeaponWorkbookReference >> mountLayout [
	^ CIWeaponMountLayout
		fromNotation: (self fieldAt: #socketNotation)
		evidence: (self evidenceForField: #socketNotation)
		fixedMounts: (fixedMounts ifNil: [ #() ])
]

{ #category : 'accessing' }
CIWeaponWorkbookReference >> name [
	^ name copy
]

{ #category : 'accessing' }
CIWeaponWorkbookReference >> weaponClass [
	^ weaponClass
]
