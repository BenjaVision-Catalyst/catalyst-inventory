"
The basic minor attribute choices that a workbook exotic weapon allows. Each choice retains its Attribute Info cap.
"
Class {
	#name : 'CIExoticWeaponMinorRule',
	#superclass : 'Object',
	#instVars : [
		'definitionsById',
		'evidence'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIExoticWeaponMinorRule class >> basicAttributes: definitions excluding: excluded evidence: source [
	^ self new
		initializeBasicAttributes: definitions
		excluding: excluded
		evidence: source
]

{ #category : 'accessing' }
CIExoticWeaponMinorRule >> attributeAt: identifier [
	^ definitionsById at: identifier ifAbsent: [ nil ]
]

{ #category : 'accessing' }
CIExoticWeaponMinorRule >> attributeIdentifiers [
	^ definitionsById keys sorted collect: #copy
]

{ #category : 'accessing' }
CIExoticWeaponMinorRule >> evidence [
	^ evidence copy
]

{ #category : 'initialization' }
CIExoticWeaponMinorRule >> initializeBasicAttributes: definitions excluding: excluded evidence: source [
	definitionsById := Dictionary new.
	definitions
		do: [ :definition | 
			(excluded includes: definition id)
				ifFalse: [ definitionsById at: definition id put: definition ] ].
	evidence := source copy
]

{ #category : 'validation' }
CIExoticWeaponMinorRule >> validateIdentifier: identifier magnitude: magnitude [
	| definition maximum |
	definition := self attributeAt: identifier.
	definition
		ifNil: [ self error: 'This exotic does not allow that minor attribute' ].
	maximum := definition valueFor: #standardMaximum.
	(maximum notNil and: [ maximum status = #documented ])
		ifFalse: [ self error: 'Minor attribute maximum is unspecified' ].
	(magnitude isNumber and: [ magnitude <= maximum magnitude ])
		ifFalse: [ self error: 'Minor attribute exceeds its workbook maximum' ]
]
