Class {
	#name : 'CIInventoryItemDefinition',
	#superclass : 'Object',
	#instVars : [
		'id',
		'displayName',
		'icon'
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
