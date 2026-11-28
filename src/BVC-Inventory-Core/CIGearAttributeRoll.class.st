Class {
	#name : 'CIGearAttributeRoll',
	#superclass : 'Object',
	#instVars : [
		'attributeIdentifier',
		'value'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIGearAttributeRoll class >> attribute: identifier value: amount [
	^ self new initializeAttribute: identifier value: amount
]

{ #category : 'accessing' }
CIGearAttributeRoll >> attributeIdentifier [
	^ attributeIdentifier copy
]

{ #category : 'initialization' }
CIGearAttributeRoll >> initializeAttribute: identifier value: amount [
	(identifier isString and: [ amount isNumber ])
		ifFalse: [ self error: 'Invalid attribute roll' ].
	attributeIdentifier := identifier copy.
	value := amount.
	^ self
]

{ #category : 'accessing' }
CIGearAttributeRoll >> value [
	^ value
]
