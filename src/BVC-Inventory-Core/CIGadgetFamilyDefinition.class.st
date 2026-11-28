Class {
	#name : 'CIGadgetFamilyDefinition',
	#superclass : 'Object',
	#instVars : [
		'name',
		'variants'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIGadgetFamilyDefinition class >> named: label variants: definitions [
	^ self new initializeName: label variants: definitions
]

{ #category : 'initialization' }
CIGadgetFamilyDefinition >> initializeName: label variants: definitions [
	name := label copy.
	variants := definitions asArray copy.
	^ self
]

{ #category : 'accessing' }
CIGadgetFamilyDefinition >> name [
	^ name copy
]

{ #category : 'accessing' }
CIGadgetFamilyDefinition >> variantNamed: label [
	^ variants
		detect: [ :variant | variant name = label ]
		ifNone: [ self error: 'Unknown gadget variant: ' , label ]
]

{ #category : 'accessing' }
CIGadgetFamilyDefinition >> variants [
	^ variants copy
]
