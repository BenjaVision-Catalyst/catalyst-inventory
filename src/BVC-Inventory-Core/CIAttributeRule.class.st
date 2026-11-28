Class {
	#name : 'CIAttributeRule',
	#superclass : 'Object',
	#instVars : [
		'id',
		'parameters',
		'description',
		'evidence'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIAttributeRule class >> id: identifier description: text parameters: options evidence: reference [
	^ self new
		initializeId: identifier
		description: text
		parameters: options
		evidence: reference
]

{ #category : 'accessing' }
CIAttributeRule >> description [
	^ description copy
]

{ #category : 'accessing' }
CIAttributeRule >> evidence [
	^ evidence copy
]

{ #category : 'accessing' }
CIAttributeRule >> id [
	^ id copy
]

{ #category : 'initialization' }
CIAttributeRule >> initializeId: identifier description: text parameters: options evidence: reference [
	id := identifier copy.
	description := text copy.
	parameters := options copy.
	evidence := reference copy.
	^ self
]

{ #category : 'accessing' }
CIAttributeRule >> parameters [
	^ parameters copy
]
