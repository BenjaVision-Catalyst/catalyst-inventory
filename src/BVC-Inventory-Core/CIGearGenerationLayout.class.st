Class {
	#name : 'CIGearGenerationLayout',
	#superclass : 'Object',
	#instVars : [
		'slots',
		'evidence'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIGearGenerationLayout class >> slots: statSlots evidence: reference [
	^ self new initializeSlots: statSlots evidence: reference
]

{ #category : 'generating' }
CIGearGenerationLayout >> attributesFor: supplied [
	| completed |
	completed := self completeValues: supplied.
	^ slots collect: [ :slot | slot summaryFor: (completed at: slot id) ]
]

{ #category : 'generating' }
CIGearGenerationLayout >> completeValues: supplied [
	| result allowed |
	(supplied isKindOf: Dictionary)
		ifFalse: [ self error: 'Inventory item values must be a dictionary' ].
	allowed := slots collect: #id.
	(supplied keys allSatisfy: [ :key | allowed includes: key ])
		ifFalse: [ self error: 'Unexpected generation slot' ].
	result := Dictionary new.
	slots
		do: [ :slot | result at: slot id put: (slot resolve: (supplied at: slot id ifAbsent: [ nil ])) ].
	^ result
]

{ #category : 'accessing' }
CIGearGenerationLayout >> evidence [
	^ evidence copy
]

{ #category : 'initialization' }
CIGearGenerationLayout >> initializeSlots: statSlots evidence: reference [
	(statSlots notEmpty and: [ statSlots first role = #core ])
		ifFalse: [ self error: 'Gear layout requires a core slot' ].
	(statSlots collect: #id) asSet size = statSlots size
		ifFalse: [ self error: 'Duplicate generation slot' ].
	slots := statSlots asArray copy.
	evidence := reference copy.
	^ self
]

{ #category : 'accessing' }
CIGearGenerationLayout >> slots [
	^ slots copy
]
