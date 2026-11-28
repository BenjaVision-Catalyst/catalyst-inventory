"
The documented fixed secondary attribute for a weapon class. The class fixes the attribute kind. Roll bounds come from the attribute definition. Innate headshot damage is a separate class reference.
"
Class {
	#name : 'CIWeaponClassGenerationRule',
	#superclass : 'Object',
	#instVars : [
		'weaponClass',
		'attribute',
		'statIdentifier',
		'statLabel',
		'innateHeadshotDamage',
		'evidence'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIWeaponClassGenerationRule class >> weaponClass: classId attribute: definition stat: stat label: label innateHeadshotDamage: innate evidence: source [
	^ self new
		initializeWeaponClass: classId
		attribute: definition
		stat: stat
		label: label
		innateHeadshotDamage: innate
		evidence: source
]

{ #category : 'accessing' }
CIWeaponClassGenerationRule >> attribute [
	^ attribute
]

{ #category : 'accessing' }
CIWeaponClassGenerationRule >> evidence [
	^ evidence copy
]

{ #category : 'initialization' }
CIWeaponClassGenerationRule >> initializeWeaponClass: classId attribute: definition stat: stat label: label innateHeadshotDamage: innate evidence: source [
	weaponClass := classId.
	attribute := definition.
	statIdentifier := stat ifNotNil: #copy.
	statLabel := label ifNotNil: #copy.
	innateHeadshotDamage := innate.
	evidence := source copy
]

{ #category : 'accessing' }
CIWeaponClassGenerationRule >> innateHeadshotDamage [
	^ innateHeadshotDamage
]

{ #category : 'accessing' }
CIWeaponClassGenerationRule >> maximumFor: capKind [
	| value |
	value := attribute valueFor: capKind.
	^ (value notNil and: [ value status = #documented ])
		ifTrue: [ value magnitude ]
]

{ #category : 'accessing' }
CIWeaponClassGenerationRule >> statIdentifier [
	^ statIdentifier ifNotNil: #copy
]

{ #category : 'accessing' }
CIWeaponClassGenerationRule >> statLabel [
	^ statLabel ifNotNil: #copy
]

{ #category : 'accessing' }
CIWeaponClassGenerationRule >> weaponClass [
	^ weaponClass
]
