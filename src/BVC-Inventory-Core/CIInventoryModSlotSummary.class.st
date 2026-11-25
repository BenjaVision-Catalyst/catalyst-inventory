"
An ordered equipment socket. Nil equipped mod indicates an empty socket.
"
Class {
	#name : 'CIInventoryModSlotSummary',
	#superclass : 'Object',
	#instVars : [
		'slotIdentifier',
		'equippedModIdentifier'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIInventoryModSlotSummary class >> slot: aSlotIdentifier equippedMod: aModIdentifier [
	^ self new initializeSlot: aSlotIdentifier equippedMod: aModIdentifier
]

{ #category : 'accessing' }
CIInventoryModSlotSummary >> equippedModIdentifier [
	^ equippedModIdentifier copy
]

{ #category : 'initialization' }
CIInventoryModSlotSummary >> initializeSlot: aSlotIdentifier equippedMod: aModIdentifier [
	(aSlotIdentifier isString and: [ aSlotIdentifier size between: 1 and: 128 ])
		ifFalse: [ self error: 'Invalid mod slot identifier' ].
	(aModIdentifier isNil
		or: [ aModIdentifier isString and: [ aModIdentifier size between: 1 and: 128 ] ])
		ifFalse: [ self error: 'Invalid equipped mod identifier' ].
	slotIdentifier := aSlotIdentifier copy.
	equippedModIdentifier := aModIdentifier copy.
	^ self
]

{ #category : 'descriptions' }
CIInventoryModSlotSummary >> magritteDescription [
	| fields |
	fields := {MAStringDescription new
				accessor: #slotIdentifier;
				label: 'Mod slot';
				beRequired;
				yourself.
			MAStringDescription new
				accessor: #equippedModIdentifier;
				label: 'Equipped mod';
				yourself}.
	fields
		do: [ :field |
			(field respondsTo: #readOnly:)
				ifTrue: [ field readOnly: true ]
				ifFalse: [ field readonly: true ] ].
	^ MAContainer withAll: fields
]

{ #category : 'accessing' }
CIInventoryModSlotSummary >> slotIdentifier [
	^ slotIdentifier copy
]
