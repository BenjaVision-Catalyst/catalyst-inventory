Class {
	#name : 'CIAttributeDefinition',
	#superclass : 'Object',
	#instVars : [
		'id',
		'label',
		'context',
		'group',
		'values',
		'notes'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIAttributeDefinition class >> id: identifier label: aLabel context: aContext group: aGroup values: workbookValues notes: workbookNotes [
	^ self new
		initializeId: identifier
		label: aLabel
		context: aContext
		group: aGroup
		values: workbookValues
		notes: workbookNotes
]

{ #category : 'accessing' }
CIAttributeDefinition >> context [
	^ context
]

{ #category : 'accessing' }
CIAttributeDefinition >> group [
	^ group copy
]

{ #category : 'accessing' }
CIAttributeDefinition >> id [
	^ id copy
]

{ #category : 'initialization' }
CIAttributeDefinition >> initializeId: identifier label: aLabel context: aContext group: aGroup values: workbookValues notes: workbookNotes [
	id := identifier copy.
	label := aLabel copy.
	context := aContext.
	group := aGroup copy.
	values := workbookValues copy.
	notes := workbookNotes collect: #copy.
	^ self
]

{ #category : 'accessing' }
CIAttributeDefinition >> label [
	^ label copy
]

{ #category : 'accessing' }
CIAttributeDefinition >> notes [
	^ notes collect: #copy
]

{ #category : 'accessing' }
CIAttributeDefinition >> valueFor: usage [
	^ values at: usage ifAbsent: [ nil ]
]
