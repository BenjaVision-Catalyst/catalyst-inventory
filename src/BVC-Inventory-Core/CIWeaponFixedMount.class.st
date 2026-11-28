"
A fixed mount reported by the Weapons worksheet. The original assertion and any carry-forward cell are retained. The installed attachment may remain unnamed even when the slot and effect are known.
"
Class {
	#name : 'CIWeaponFixedMount',
	#superclass : 'Object',
	#instVars : [
		'slotKind',
		'effects',
		'evidence',
		'inheritedEvidence',
		'attachment'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIWeaponFixedMount class >> slot: kind effects: modifiers evidence: source inheritedEvidence: carryForward attachment: definition [
	^ self new
		initializeSlot: kind
		effects: modifiers
		evidence: source
		inheritedEvidence: carryForward
		attachment: definition
]

{ #category : 'accessing' }
CIWeaponFixedMount >> attachment [
	^ attachment
]

{ #category : 'accessing' }
CIWeaponFixedMount >> effects [
	^ effects collect: #copy
]

{ #category : 'accessing' }
CIWeaponFixedMount >> evidence [
	^ evidence copy
]

{ #category : 'accessing' }
CIWeaponFixedMount >> inheritedEvidence [
	^ inheritedEvidence ifNotNil: #copy
]

{ #category : 'initialization' }
CIWeaponFixedMount >> initializeSlot: kind effects: modifiers evidence: source inheritedEvidence: carryForward attachment: definition [
	slotKind := kind.
	effects := modifiers collect: #copy.
	evidence := source copy.
	inheritedEvidence := carryForward ifNotNil: #copy.
	attachment := definition
]

{ #category : 'accessing' }
CIWeaponFixedMount >> slotKind [
	^ slotKind
]
