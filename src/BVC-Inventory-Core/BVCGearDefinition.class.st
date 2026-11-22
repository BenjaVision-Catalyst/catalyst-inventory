Class {
	#name : 'BVCGearDefinition',
	#superclass : 'BVCInventoryItemDefinition',
	#instVars : [
		'gearType',
		'slot',
		'modifiers'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'accessing' }
BVCGearDefinition class >> id: anId name: aName icon: anIcon type: aType slot: aSlot modifiers: aCollection [
	^ self new
		initializeId: anId
		name: aName
		icon: anIcon
		type: aType
		slot: aSlot
		modifiers: aCollection
]

{ #category : 'accessing' }
BVCGearDefinition >> gearType [
	^ gearType
]

{ #category : 'accessing' }
BVCGearDefinition >> initializeId: anId name: aName icon: anIcon type: aType slot: aSlot modifiers: aCollection [
	aSlot ifNil: [ self error: 'Gear requires an equipment slot' ].
	super
		initializeId: anId
		name: aName
		icon: anIcon.
	gearType := aType.
	slot := aSlot.
	modifiers := aCollection asArray copy
]

{ #category : 'accessing' }
BVCGearDefinition >> modifiers [
	^ modifiers copy
]

{ #category : 'accessing' }
BVCGearDefinition >> slot [
	^ slot
]
