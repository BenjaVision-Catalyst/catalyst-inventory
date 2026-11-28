Class {
	#name : 'CIInventoryGearAttributeSummary',
	#superclass : 'Object',
	#instVars : [
		'attributeIdentifier',
		'displayName',
		'attributeType',
		'value',
		'valueFormat',
		'isMaximum',
		'generationSlotIdentifier'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIInventoryGearAttributeSummary class >> identifier: identifier label: label type: category value: amount format: format hasMaximum: maximum [
	^ self new
		initializeIdentifier: identifier
		label: label
		type: category
		value: amount
		format: format
		hasMaximum: maximum
]

{ #category : 'accessing' }
CIInventoryGearAttributeSummary >> attributeIdentifier [
	^ attributeIdentifier copy
]

{ #category : 'accessing' }
CIInventoryGearAttributeSummary >> attributeType [
	^ attributeType copy
]

{ #category : 'accessing' }
CIInventoryGearAttributeSummary >> displayName [
	^ displayName copy
]

{ #category : 'accessing' }
CIInventoryGearAttributeSummary >> generationSlotIdentifier [
	^ generationSlotIdentifier ifNotNil: #copy
]

{ #category : 'initialization' }
CIInventoryGearAttributeSummary >> generationSlotIdentifier: identifier [
	generationSlotIdentifier := identifier copy
]

{ #category : 'initialization' }
CIInventoryGearAttributeSummary >> initializeIdentifier: identifier label: label type: category value: amount format: format hasMaximum: maximum [
	({identifier.
		label}
		allSatisfy: [ :text | text isString and: [ text size between: 1 and: 128 ] ])
		ifFalse: [ self error: 'Invalid gear attribute text' ].
	(#('offensive' 'defensive' 'utility') includes: category)
		ifFalse: [ self error: 'Invalid gear attribute type' ].
	(amount isNumber and: [ amount asFloat isFinite ])
		ifFalse: [ self error: 'Invalid gear attribute value' ].
	(#('number' 'signedNumber' 'signedPercent') includes: format)
		ifFalse: [ self error: 'Invalid gear attribute format' ].
	(maximum == true or: [ maximum == false ])
		ifFalse: [ self error: 'Invalid maximum attribute state' ].
	attributeIdentifier := identifier copy.
	displayName := label copy.
	attributeType := category copy.
	value := amount.
	valueFormat := format copy.
	isMaximum := maximum.
	^ self
]

{ #category : 'accessing' }
CIInventoryGearAttributeSummary >> isMaximum [
	^ isMaximum
]

{ #category : 'descriptions' }
CIInventoryGearAttributeSummary >> magritteDescription [
	^ MAContainer
		withAll: {MAStringDescription new
					accessor: #attributeIdentifier;
					label: 'Attribute identifier';
					readOnly: true;
					beRequired;
					yourself.
				MAStringDescription new
					accessor: #displayName;
					label: 'Display name';
					readOnly: true;
					beRequired;
					yourself.
				MAStringDescription new
					accessor: #attributeType;
					label: 'Attribute type';
					readOnly: true;
					beRequired;
					yourself.
				MANumberDescription new
					accessor: #value;
					label: 'Value';
					readOnly: true;
					beRequired;
					yourself.
				MAStringDescription new
					accessor: #valueFormat;
					label: 'Value format';
					readOnly: true;
					beRequired;
					yourself.
				MABooleanDescription new
					accessor: #isMaximum;
					label: 'At maximum';
					readOnly: true;
					yourself}
]

{ #category : 'accessing' }
CIInventoryGearAttributeSummary >> value [
	^ value
]

{ #category : 'accessing' }
CIInventoryGearAttributeSummary >> valueFormat [
	^ valueFormat copy
]
