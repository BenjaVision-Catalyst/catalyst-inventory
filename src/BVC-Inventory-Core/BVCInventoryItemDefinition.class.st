Class {
	#name : 'BVCInventoryItemDefinition',
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
BVCInventoryItemDefinition class >> id: anId name: aName icon: anIcon [
	^ self new
		initializeId: anId
		name: aName
		icon: anIcon
]

{ #category : 'accessing' }
BVCInventoryItemDefinition >> displayName [
	^ displayName
]

{ #category : 'accessing' }
BVCInventoryItemDefinition >> icon [
	^ icon
]

{ #category : 'accessing' }
BVCInventoryItemDefinition >> id [
	^ id
]

{ #category : 'accessing' }
BVCInventoryItemDefinition >> initializeId: anId name: aName icon: anIcon [
	id := anId.
	displayName := aName.
	icon := anIcon
]
