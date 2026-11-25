Class {
	#name : 'CIInventoryComparisonStat',
	#superclass : 'Object',
	#instVars : [
		'statIdentifier',
		'displayName',
		'value'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIInventoryComparisonStat class >> identifier: identifier label: label value: aNumber [
	^ self new
		initializeIdentifier: identifier
		label: label
		value: aNumber
]

{ #category : 'accessing' }
CIInventoryComparisonStat >> displayName [
	^ displayName copy
]

{ #category : 'initialization' }
CIInventoryComparisonStat >> initializeIdentifier: identifier label: label value: aNumber [
	({identifier.
		label}
		allSatisfy: [ :text | text isString and: [ text size between: 1 and: 128 ] ])
		ifFalse: [ self error: 'Invalid comparison stat text' ].
	(aNumber isNumber and: [ aNumber asFloat isFinite ])
		ifFalse: [ self error: 'Invalid comparison stat value' ].
	statIdentifier := identifier copy.
	displayName := label copy.
	value := aNumber.
	^ self
]

{ #category : 'descriptions' }
CIInventoryComparisonStat >> magritteDescription [
	^ MAContainer
		withAll: {MAStringDescription new
					accessor: #statIdentifier;
					label: 'Stat identifier';
					readOnly: true;
					beRequired;
					yourself.
				MAStringDescription new
					accessor: #displayName;
					label: 'Display name';
					readOnly: true;
					beRequired;
					yourself.
				MANumberDescription new
					accessor: #value;
					label: 'Value';
					readOnly: true;
					beRequired;
					yourself}
]

{ #category : 'accessing' }
CIInventoryComparisonStat >> statIdentifier [
	^ statIdentifier copy
]

{ #category : 'accessing' }
CIInventoryComparisonStat >> value [
	^ value
]
