Class {
	#name : 'CIInventoryItemDefinition',
	#superclass : 'Object',
	#instVars : [
		'id',
		'displayName',
		'icon',
		'tierId'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'accessing' }
CIInventoryItemDefinition class >> id: anId name: aName icon: anIcon [
	^ self new
		initializeId: anId
		name: aName
		icon: anIcon
]

{ #category : 'descriptions' }
CIInventoryItemDefinition >> descriptionTierId [
	^ MANumberDescription new
		accessor: #tierId;
		label: 'Tier';
		min: 1;
		max: 6;
		default: 1;
		beRequired;
		yourself
]

{ #category : 'accessing' }
CIInventoryItemDefinition >> displayName [
	^ displayName
]

{ #category : 'accessing' }
CIInventoryItemDefinition >> icon [
	^ icon
]

{ #category : 'accessing' }
CIInventoryItemDefinition >> id [
	^ id
]

{ #category : 'accessing' }
CIInventoryItemDefinition >> initializeId: anId name: aName icon: anIcon [
	id := anId.
	displayName := aName.
	icon := anIcon
]

{ #category : 'accessing' }
CIInventoryItemDefinition >> tierId [
	^ tierId ifNil: [ 1 ]
]

{ #category : 'accessing' }
CIInventoryItemDefinition >> tierId: anInteger [
	(anInteger isInteger and: [ anInteger between: 1 and: 6 ])
		ifFalse: [ self error: 'Inventory tier must be an integer from 1 to 6' ].
	tierId := anInteger
]
