Class {
	#name : 'CIGadgetType',
	#superclass : 'CIItemType',
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'accessing' }
CIGadgetType >> activationLabel [
	self subclassResponsibility
]

{ #category : 'accessing' }
CIGadgetType >> baseStats [
	self subclassResponsibility
]

{ #category : 'private' }
CIGadgetType >> inspectorAmount: amount unit: unit [
	^ (amount isInteger
		ifTrue: [ amount asString ]
		ifFalse: [ amount asFloat printShowingDecimalPlaces: 1 ]) , ' ' , unit
]

{ #category : 'accessing' }
CIGadgetType >> inspectorSectionsAtUtilityTier: tier item: item [
	| base effective stats bonuses mods controls slot |
	base := self baseStats.
	effective := self statsAtUtilityTier: tier.
	stats := OrderedCollection new.
	bonuses := OrderedCollection
			with: {'Current tier'.
					tier asString}.
	self inspectorStatFields
		do: [ :field |
			effective
				at: field first
				ifPresent: [ :amount |
					| delta |
					stats
						add: {field second.
								self inspectorAmount: amount unit: field third}.
					delta := amount - (base at: field first).
					delta = 0
						ifFalse: [ bonuses
								add: {field second.
										(delta > 0 ifTrue: [ '+' ] ifFalse: [ '' ])
											, (self inspectorAmount: delta unit: field third)} ] ] ].
	mods := item modSlots
			collect: [ :socket |
				{socket slotIdentifier capitalized.
					socket equippedModIdentifier ifNil: [ 'Empty' ]} ].
	slot := item equippedSlotIdentifier.
	controls := slot = 'GadgetLeft'
			ifTrue: [ {{self activationLabel.
						#Gamepad_RightShoulder}} ]
			ifFalse: [ slot = 'GadgetRight'
					ifTrue: [ {{self activationLabel.
								#Gamepad_RightTrigger}} ]
					ifFalse: [ #() ] ].
	^ {{'stats'.
			'Stats'.
			stats}.
		{'tier'.
			'Utility Tier'.
			bonuses}.
		{'slots'.
			'Mods'.
			mods}.
		{'controls'.
			'Controls'.
			controls}}
]

{ #category : 'accessing' }
CIGadgetType >> inspectorStatFields [
	^ #(#(cooldownSeconds 'Cooldown' 's') #(durationSeconds 'Deployment duration' 's') #(revealSeconds 'Reveal duration' 's') #(scanRadiusMetres 'Scan range' 'm'))
]

{ #category : 'instance creation' }
CIGadgetType >> inventoryItem: itemIdentifier values: values [
	| sockets item |
	self validateInventoryItemValues: values.
	sockets := self modSocketIdentifiers
			collect: [ :identifier |
				CIInventoryModSlotSummary
					slot: identifier
					equippedMod: (values at: identifier ifAbsent: [ nil ]) ].
	item := CIInventoryEquipmentSummary
			item: itemIdentifier
			fromDefinition: self
			metadata: (Dictionary new
					at: #presentationKind put: 'gadget';
					at: #inventoryTypeCount put: 1;
					at: #modSlots put: sockets;
					yourself).
	item availableEquipmentSlotIdentifiers: #('GadgetLeft' 'GadgetRight').
	^ item
]

{ #category : 'descriptions' }
CIGadgetType >> inventoryItemDescription [
	^ MAContainer
		withAll: (self modSocketIdentifiers
				collect: [ :identifier |
					MAStringDescription new
						accessor: (MADictionaryAccessor key: identifier);
						label: identifier;
						yourself ])
]

{ #category : 'accessing' }
CIGadgetType >> modSocketIdentifiers [
	^ #('utility')
]

{ #category : 'accessing' }
CIGadgetType >> statsAtUtilityTier: aTier [
	(aTier isInteger and: [ aTier >= 0 ])
		ifFalse: [ self error: 'Invalid Utility Tier' ].
	^ self baseStats
]
