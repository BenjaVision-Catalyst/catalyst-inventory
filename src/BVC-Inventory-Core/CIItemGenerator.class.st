Class {
	#name : 'CIItemGenerator',
	#superclass : 'Object',
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'generating' }
CIItemGenerator >> completeValues: suppliedValues for: type [
	| values layout |
	(suppliedValues isKindOf: Dictionary)
		ifFalse: [ self error: 'Inventory item values must be a dictionary' ].
	layout := type generationLayout.
	layout ifNotNil: [ ^ layout completeValues: suppliedValues ].
	values := suppliedValues copy.
	type inventoryItemDescription children
		do: [ :field | 
			| key |
			key := field accessor key.
			(field isRequired and: [ (values includesKey: key) not ])
				ifTrue: [ ((field isKindOf: MANumberDescription)
						and: [ field min notNil and: [ field min = field max ] ])
						ifTrue: [ values at: key put: field min ]
						ifFalse: [ self error: 'Missing generation rule or supplied value for: ' , key ] ] ].
	type validateInventoryItemValues: values.
	^ values
]

{ #category : 'generating' }
CIItemGenerator >> generate: itemIdentifier type: typeIdentifier values: suppliedValues from: catalog using: randomSample [
	| type values item |
	type := catalog typeAt: typeIdentifier.
	values := self completeValues: suppliedValues for: type.
	item := type
			inventoryItem: itemIdentifier
			values: values
			talentIdentifier: (catalog rollTalentFor: typeIdentifier using: randomSample).
	(item isKindOf: CIInventoryEquipmentSummary)
		ifTrue: [ (catalog modCatalogue socketsFor: typeIdentifier)
				do: [ :socket | 
					socket fixedModIdentifier
						ifNotNil: [ :modId | 
							item
								replaceModSocket: (CIInventoryModSlotSummary slot: socket id factoryMod: modId) ]
						ifNil: [ (item modSlots
								anySatisfy: [ :slot | slot slotIdentifier = socket id ])
								ifFalse: [ item
										replaceModSocket: (CIInventoryModSlotSummary slot: socket id equippedMod: nil) ] ] ] ].
	^ item
]
