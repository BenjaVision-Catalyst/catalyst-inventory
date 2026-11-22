Class {
	#name : 'CIGearDefinition',
	#superclass : 'CIInventoryItemDefinition',
	#instVars : [
		'gearType',
		'slot',
		'modifiers',
		'familyId'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'accessing' }
CIGearDefinition class >> id: anId name: aName icon: anIcon type: aType slot: aSlot modifiers: aCollection [
	^ self new
		initializeId: anId
		name: aName
		icon: anIcon
		type: aType
		slot: aSlot
		modifiers: aCollection
]

{ #category : 'accessing' }
CIGearDefinition >> familyId [
	^ familyId
]

{ #category : 'accessing' }
CIGearDefinition >> familyId: anId [
	familyId := anId
]

{ #category : 'accessing' }
CIGearDefinition >> gearType [
	^ gearType
]

{ #category : 'accessing' }
CIGearDefinition >> initializeId: anId name: aName icon: anIcon type: aType slot: aSlot modifiers: aCollection [
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
CIGearDefinition >> modifiers [
	^ modifiers copy
]

{ #category : 'accessing' }
CIGearDefinition >> slot [
	^ slot
]
