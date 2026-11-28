Class {
	#name : 'CIEquipmentModEvaluator',
	#superclass : 'Object',
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'private' }
CIEquipmentModEvaluator >> contributionFor: effect from: definition owned: owned item: item socket: slot [
	| operation magnitude |
	effect first = #referenceText
		ifTrue: [ operation := #referenceText.
			magnitude := effect second copy ]
		ifFalse: [ operation := effect second.
			magnitude := definition kind = #gearMod
					ifTrue: [ owned rolledValue ]
					ifFalse: [ effect third ] ].
	^ CIModContribution
		item: item itemIdentifier
		socket: slot slotIdentifier
		definition: definition
		stat: effect first
		operation: operation
		value: magnitude
]

{ #category : 'evaluating' }
CIEquipmentModEvaluator >> evaluateEquipment: equipment owned: rows catalogue: catalogue [
	| ownedById effects unresolved |
	ownedById := Dictionary new.
	rows do: [ :row | ownedById at: row itemIdentifier put: row ].
	effects := OrderedCollection new.
	unresolved := OrderedCollection new.
	equipment
		do: [ :item | 
			item modSlots
				do: [ :slot | 
					slot equippedModIdentifier
						ifNotNil: [ :reference | 
							| definition owned |
							owned := ownedById at: reference ifAbsent: [ nil ].
							definition := self
									resolve: slot
									owned: owned
									on: item
									catalogue: catalogue.
							definition
								ifNil: [ unresolved
										add: {item itemIdentifier.
												slot slotIdentifier.
												reference} ]
								ifNotNil: [ definition effects
										do: [ :effect | 
											effects
												add: (self
														contributionFor: effect
														from: definition
														owned: owned
														item: item
														socket: slot) ] ] ] ] ].
	^ CIModEvaluation contributions: effects unresolved: unresolved
]

{ #category : 'private' }
CIEquipmentModEvaluator >> resolve: slot owned: owned on: item catalogue: catalogue [
	| socket definition identifier |
	socket := catalogue
			socketAt: slot slotIdentifier
			forItem: item definitionIdentifier.
	socket ifNil: [ ^ nil ].
	identifier := slot equippedModIdentifier.
	slot isLocked
		ifTrue: [ socket fixedModIdentifier = identifier ifFalse: [ ^ nil ].
			^ catalogue definitionAt: identifier ifAbsent: [ nil ] ].
	((owned isKindOf: CIWeaponModUnlock) or: [ owned isKindOf: CIOwnedGearMod ])
		ifFalse: [ ^ nil ].
	definition := catalogue
			definitionAt: owned definitionIdentifier
			ifAbsent: [ ^ nil ].
	(socket fixedModIdentifier isNil
		and: [ definition fitsSocket: socket on: item definitionIdentifier ])
		ifFalse: [ ^ nil ].
	^ definition
]
