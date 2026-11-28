Class {
	#name : 'CIAttributeValue',
	#superclass : 'Object',
	#instVars : [
		'status',
		'rawText',
		'magnitude',
		'unit',
		'evidence'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIAttributeValue class >> status: aStatus raw: raw magnitude: value unit: measurement evidence: reference [
	^ self new
		initializeStatus: aStatus
		raw: raw
		magnitude: value
		unit: measurement
		evidence: reference
]

{ #category : 'accessing' }
CIAttributeValue >> evidence [
	^ evidence copy
]

{ #category : 'initialization' }
CIAttributeValue >> initializeStatus: aStatus raw: raw magnitude: value unit: measurement evidence: reference [
	status := aStatus.
	rawText := raw ifNotNil: #copy.
	magnitude := value.
	unit := measurement.
	evidence := reference copy.
	^ self
]

{ #category : 'accessing' }
CIAttributeValue >> magnitude [
	^ magnitude
]

{ #category : 'accessing' }
CIAttributeValue >> rawText [
	^ rawText ifNotNil: #copy
]

{ #category : 'accessing' }
CIAttributeValue >> status [
	^ status
]

{ #category : 'accessing' }
CIAttributeValue >> unit [
	^ unit
]
