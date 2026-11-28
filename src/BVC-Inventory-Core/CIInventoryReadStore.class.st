Class {
	#name : 'CIInventoryReadStore',
	#superclass : 'Object',
	#instVars : [
		'rowsByOwner',
		'modStorageAllowancesByOwner'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'accessing' }
CIInventoryReadStore class >> defaultModStorageAllowance [
	^ 100
]

{ #category : 'reading' }
CIInventoryReadStore >> allRowsForOwner: identity [
	self validateOwner: identity.
	^ (rowsByOwner at: identity ifAbsent: [ #() ]) copy
]

{ #category : 'private' }
CIInventoryReadStore >> copyRow: row inSlot: slot outfit: isOutfit [
	| candidate |
	candidate := row copy.
	isOutfit
		ifTrue: [ candidate equippedApparelSlotIdentifier: slot ]
		ifFalse: [ candidate equippedSlotIdentifier: slot ].
	^ candidate
]

{ #category : 'private' }
CIInventoryReadStore >> equippedSlotOf: row outfit: isOutfit [
	^ isOutfit
		ifTrue: [ row equippedApparelSlotIdentifier ]
		ifFalse: [ row equippedSlotIdentifier ]
]

{ #category : 'reading' }
CIInventoryReadStore >> equippedSlotsForOwner: identity outfit: isOutfit [
	| rows slots |
	self validateOwner: identity.
	rows := rowsByOwner at: identity ifAbsent: [ ^ #() ].
	slots := OrderedCollection new.
	rows
		do: [ :row |
			| slot |
			slot := isOutfit
					ifTrue: [ (row isKindOf: CIInventoryApparelItemSummary)
							ifTrue: [ row equippedApparelSlotIdentifier ] ]
					ifFalse: [ self gearSetSlotFor: row ].
			slot
				ifNotNil: [ slots
						add: {slot.
								row itemIdentifier copy} ] ].
	^ slots asArray
]

{ #category : 'private' }
CIInventoryReadStore >> gearSetSlotFor: row [
	| slot |
	(row isKindOf: CIInventoryEquipmentSummary) ifFalse: [ ^ nil ].
	slot := row equippedSlotIdentifier.
	slot ifNil: [ ^ nil ].
	row presentationKind = 'weapon' ifTrue: [ ^ slot ].
	(#('Chest' 'Backpack' 'Gloves' 'KneePads' 'Mask' 'Watch' 'GadgetLeft' 'GadgetRight')
		includes: slot) ifTrue: [ ^ slot ].
	^ nil
]

{ #category : 'writing' }
CIInventoryReadStore >> grantItem: itemIdentifier type: typeIdentifier values: values from: catalog forOwner: identity [
	^ self
		grantItem: itemIdentifier
		type: typeIdentifier
		values: values
		from: catalog
		forOwner: identity
		using: [ Random new next ]
]

{ #category : 'spawning' }
CIInventoryReadStore >> grantItem: itemIdentifier type: typeIdentifier values: values from: catalog forOwner: identity using: random [
	| rows item matches count updated |
	self validateOwner: identity.
	(itemIdentifier isString and: [ itemIdentifier isNotEmpty ])
		ifFalse: [ self error: 'Inventory item identifier required' ].
	item := (catalog typeAt: typeIdentifier)
			inventoryItem: itemIdentifier
			values: values
			talentIdentifier: (catalog rollTalentFor: typeIdentifier using: random).
	rows := rowsByOwner at: identity ifAbsent: [ #() ].
	(item isKindOf: CIInventoryEquipmentSummary)
		ifTrue: [ matches := [ :row | 
				(row isKindOf: CIInventoryEquipmentSummary)
					and: [ row definitionIdentifier = typeIdentifier ] ].
			count := (rows count: matches) + 1.
			item inventoryTypeCount: count.
			rows := rows
					collect: [ :row | 
						(matches value: row)
							ifTrue: [ updated := row copy.
								updated inventoryTypeCount: count.
								updated ]
							ifFalse: [ row ] ] ].
	self replaceRows: (rows copyWith: item) forOwner: identity.
	^ item copy
]

{ #category : 'initialization' }
CIInventoryReadStore >> initialize [
	super initialize.
	rowsByOwner := Dictionary new
]

{ #category : 'private' }
CIInventoryReadStore >> isEquipmentRow: row outfit: isOutfit [
	^ isOutfit
		ifTrue: [ row isKindOf: CIInventoryApparelItemSummary ]
		ifFalse: [ row isKindOf: CIInventoryEquipmentSummary ]
]

{ #category : 'writing' }
CIInventoryReadStore >> modStorageAllowance: allowance forOwner: identity [
	self validateOwner: identity.
	(allowance isInteger and: [ allowance >= 0 ])
		ifFalse: [ self error: 'Invalid mod storage allowance' ].
	modStorageAllowancesByOwner
		ifNil: [ modStorageAllowancesByOwner := Dictionary new ].
	modStorageAllowancesByOwner at: identity copy put: allowance
]

{ #category : 'reading' }
CIInventoryReadStore >> modStorageAllowanceForOwner: identity [
	self validateOwner: identity.
	modStorageAllowancesByOwner ifNil: [ ^ self class defaultModStorageAllowance ].
	^ modStorageAllowancesByOwner
		at: identity
		ifAbsent: [ self class defaultModStorageAllowance ]
]

{ #category : 'writing' }
CIInventoryReadStore >> provisionStarterGadgetsFrom: catalog forOwner: identity [
	| rows updated |
	self validateOwner: identity.
	rows := rowsByOwner at: identity ifAbsent: [ #() ].
	updated := rows asOrderedCollection.
	#(#('gadget.drone.scout' 'starter-scout-drone' 'GadgetLeft') #('gadget.pulse.scanner' 'starter-scanner-pulse' 'GadgetRight'))
		do: [ :spec |
			(updated anySatisfy: [ :row | row definitionIdentifier = spec first ])
				ifFalse: [ | item |
					item := (catalog typeAt: spec first)
							inventoryItem: spec second
							values: Dictionary new.
					(updated
						anySatisfy: [ :row |
							(row isKindOf: CIInventoryEquipmentSummary)
								and: [ row equippedSlotIdentifier = spec third ] ])
						ifFalse: [ item equippedSlotIdentifier: spec third ].
					updated add: item ] ].
	updated size = rows size
		ifFalse: [ self replaceRows: updated forOwner: identity ]
]

{ #category : 'writing' }
CIInventoryReadStore >> replaceRows: aCollection forOwner: anOwnerIdentifier [
	| rows identifiers |
	self validateOwner: anOwnerIdentifier.
	rows := aCollection asArray copy.
	identifiers := Set new.
	rows
		do: [ :row |
			(row isKindOf: CIInventoryItemSummary)
				ifFalse: [ self error: 'Inventory item summary required' ].
			(identifiers includes: row itemIdentifier)
				ifTrue: [ self error: 'Duplicate inventory item identifier' ].
			identifiers add: row itemIdentifier ].
	rowsByOwner at: anOwnerIdentifier copy put: rows
]

{ #category : 'reading' }
CIInventoryReadStore >> rowsAfterEquipping: savedSlots forOwner: identity outfit: isOutfit [
	| rows byItem inSlot missing |
	self validateOwner: identity.
	rows := rowsByOwner at: identity ifAbsent: [ ^ #() ].
	byItem := Dictionary new.
	inSlot := Dictionary new.
	rows
		do: [ :row |
			| slot |
			(self isEquipmentRow: row outfit: isOutfit)
				ifTrue: [ byItem at: row itemIdentifier put: row.
					slot := self equippedSlotOf: row outfit: isOutfit.
					slot ifNotNil: [ inSlot at: slot put: row itemIdentifier ] ] ].
	missing := Set new.
	savedSlots
		do: [ :pair |
			| row |
			row := byItem at: pair second ifAbsent: [ nil ].
			((inSlot at: pair first ifAbsent: [ nil ]) ~= pair second
				and: [ row isNil or: [ (row permitsCapturedEquipmentSlot: pair first) not ] ])
				ifTrue: [ missing add: pair first ] ].
	savedSlots
		do: [ :pair |
			| destination itemId row currentSlot displaced |
			destination := pair first.
			itemId := pair second.
			displaced := inSlot at: destination ifAbsent: [ nil ].
			(displaced ~= itemId and: [ (missing includes: destination) not ])
				ifTrue: [ row := byItem at: itemId.
					currentSlot := self equippedSlotOf: row outfit: isOutfit.
					(missing includes: currentSlot)
						ifFalse: [ currentSlot ifNotNil: [ inSlot removeKey: currentSlot ifAbsent: [  ] ].
							displaced
								ifNotNil: [ byItem
										at: displaced
										put: (self
												copyRow: (byItem at: displaced)
												inSlot: nil
												outfit: isOutfit) ].
							inSlot at: destination put: itemId.
							byItem
								at: itemId
								put: (self
										copyRow: row
										inSlot: destination
										outfit: isOutfit) ] ] ].
	^ rows collect: [ :row | byItem at: row itemIdentifier ifAbsent: [ row ] ]
]

{ #category : 'reading' }
CIInventoryReadStore >> rowsForOwner: anOwnerIdentifier offset: anOffset limit: aLimit [
	| rows end |
	self validateOwner: anOwnerIdentifier.
	(anOffset isInteger and: [ anOffset >= 0 ])
		ifFalse: [ self error: 'Invalid Inventory offset' ].
	(aLimit isInteger and: [ aLimit between: 1 and: 32 ])
		ifFalse: [ self error: 'Invalid Inventory page limit' ].
	rows := rowsByOwner at: anOwnerIdentifier ifAbsent: [ ^ #() ].
	anOffset >= rows size ifTrue: [ ^ #() ].
	end := anOffset + aLimit min: rows size.
	^ rows copyFrom: anOffset + 1 to: end
]

{ #category : 'private' }
CIInventoryReadStore >> validateOwner: anOwnerIdentifier [
	(anOwnerIdentifier isString and: [ anOwnerIdentifier isNotEmpty ])
		ifFalse: [ self error: 'Catalyst User identifier required' ]
]
