Class {
	#name : 'CISpecializationPerk',
	#superclass : 'Object',
	#instVars : [
		'id',
		'name',
		'category',
		'description',
		'evidence',
		'prerequisites',
		'exclusions',
		'rewardIdentifier',
		'modifiers',
		'eventParameters',
		'armorKitEffects'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CISpecializationPerk class >> fromWorkbookRow: row [
	^ self new initializeWorkbookRow: row
]

{ #category : 'accessing' }
CISpecializationPerk >> armorKitEffects [
	^ armorKitEffects ifNil: [ #() ] ifNotNil: #copy
]

{ #category : 'accessing' }
CISpecializationPerk >> armorKitEffects: effects [
	armorKitEffects := effects asArray copy
]

{ #category : 'accessing' }
CISpecializationPerk >> category [
	^ category copy
]

{ #category : 'accessing' }
CISpecializationPerk >> description [
	^ description ifNotNil: #copy
]

{ #category : 'accessing' }
CISpecializationPerk >> equipmentReward [
	^ eventParameters
		ifNotNil: [ eventParameters at: #equipmentReward ifAbsent: [ nil ] ]
]

{ #category : 'accessing' }
CISpecializationPerk >> eventParameters [
	^ eventParameters ifNotNil: #copy
]

{ #category : 'initialization' }
CISpecializationPerk >> eventParameters: values [
	eventParameters := values copy
]

{ #category : 'accessing' }
CISpecializationPerk >> evidence [
	^ evidence copy
]

{ #category : 'accessing' }
CISpecializationPerk >> exclusions [
	^ exclusions collect: #copy
]

{ #category : 'accessing' }
CISpecializationPerk >> gadgetUpgrade [
	^ eventParameters
		ifNotNil: [ eventParameters at: #gadgetUpgrade ifAbsent: [ nil ] ]
]

{ #category : 'accessing' }
CISpecializationPerk >> id [
	^ id copy
]

{ #category : 'initialization' }
CISpecializationPerk >> initializeWorkbookRow: row [
	id := row first copy.
	name := row second copy.
	category := row third copy.
	description := row fourth ifNotNil: #copy.
	evidence := row fifth copy.
	prerequisites := (row at: 6) collect: #copy.
	exclusions := (row at: 7) collect: #copy.
	rewardIdentifier := (row at: 8) ifNotNil: #copy.
	modifiers := row last
			collect: [ :spec | 
				| effect |
				effect := CIGearModifier
						stat: spec first
						operation: #add
						magnitude: spec second
						targetClass: spec fourth
						duration: #whileEquipped.
				effect unit: spec third.
				effect ].
	^ self
]

{ #category : 'accessing' }
CISpecializationPerk >> modifiers [
	^ modifiers copy
]

{ #category : 'accessing' }
CISpecializationPerk >> name [
	^ name copy
]

{ #category : 'accessing' }
CISpecializationPerk >> prerequisites [
	^ prerequisites collect: #copy
]

{ #category : 'accessing' }
CISpecializationPerk >> rewardIdentifier [
	^ rewardIdentifier ifNotNil: #copy
]

{ #category : 'initialization' }
CISpecializationPerk >> rewardIdentifier: typeIdentifier [
	rewardIdentifier := typeIdentifier copy
]
