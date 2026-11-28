Class {
	#name : 'CILoadoutFamilyEvaluator',
	#superclass : 'Object',
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'private' }
CILoadoutFamilyEvaluator >> activationFor: family pieces: equipped mode: mode [
	| count tiers talents setTalent |
	count := equipped size.
	tiers := family tiers select: [ :tier | tier pieceCount <= count ].
	talents := OrderedCollection new.
	setTalent := family setTalent.
	(setTalent notNil and: [ count >= (setTalent parameters at: #requiredPieces) ])
		ifTrue: [ talents add: setTalent.
			equipped
				do: [ :row | 
					(family upgradeAtSlot: row equippedSlotIdentifier)
						ifNotNil: [ :upgrade | 
							count >= (upgrade parameters at: #requiredPieces)
								ifTrue: [ talents add: upgrade ] ] ] ].
	^ CIGearFamilyActivation
		family: family
		count: count
		mode: mode
		tiers: tiers
		talents: talents
]

{ #category : 'evaluating' }
CILoadoutFamilyEvaluator >> evaluateRows: rows catalogue: catalog mode: mode [
	| slots piecesByFamily |
	(#(pve pvp) includes: mode) ifFalse: [ self error: 'Unknown loadout mode' ].
	slots := Set new.
	piecesByFamily := Dictionary new.
	rows
		do: [ :row | 
			| type slot |
			(row isKindOf: CIInventoryGearSummary)
				ifTrue: [ slot := row equippedSlotIdentifier.
					slot
						ifNotNil: [ (slots includes: slot)
								ifTrue: [ self error: 'Multiple gear pieces equipped in one slot' ].
							slots add: slot.
							type := catalog typeAt: row definitionIdentifier ifAbsent: [ nil ].
							(type respondsTo: #gearFamilyIdentifier)
								ifTrue: [ (piecesByFamily
										at: type gearFamilyIdentifier
										ifAbsentPut: [ OrderedCollection new ]) add: row ] ] ] ].
	^ catalog gearFamilies
		collect: [ :family | 
			self
				activationFor: family
				pieces: (piecesByFamily at: family id ifAbsent: [ #() ])
				mode: mode ]
]
