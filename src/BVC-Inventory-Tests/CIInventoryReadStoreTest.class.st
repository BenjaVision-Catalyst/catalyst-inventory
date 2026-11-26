Class {
	#name : 'CIInventoryReadStoreTest',
	#superclass : 'TestCase',
	#instVars : [
		'store'
	],
	#category : 'BVC-Inventory-Tests',
	#package : 'BVC-Inventory-Tests'
}

{ #category : 'running' }
CIInventoryReadStoreTest >> setUp [
	super setUp.
	store := CIInventoryReadStore new
]

{ #category : 'tests' }
CIInventoryReadStoreTest >> testApplyingGearSetPreservesMissingSourcesAndEquipsTheRest [
	| saved current source available displaced forbidden result makeWeapon |
	makeWeapon := [ :id :slot |
		CIInventoryEquipmentSummary
			item: id
			fromDefinition: (CIInventoryItemDefinition
					id: id
					name: id
					icon: nil)
			metadata: (Dictionary new
					at: #presentationKind put: 'weapon';
					at: #inventoryTypeCount put: 1;
					at: #equippedSlotIdentifier put: slot;
					yourself) ].
	current := makeWeapon value: 'current' value: 'MeleeWeapon'.
	source := makeWeapon value: 'target' value: 'LeftHandWeapon'.
	available := makeWeapon value: 'available' value: nil.
	displaced := makeWeapon value: 'displaced' value: 'RangedWeapon'.
	forbidden := makeWeapon value: 'forbidden' value: nil.
	forbidden availableEquipmentSlotIdentifiers: #('LeftHandWeapon').
	store
		replaceRows: {current.
				source.
				available.
				displaced.
				forbidden}
		forOwner: 'owner'.
	saved := #(#('MeleeWeapon' 'target') #('LeftHandWeapon' 'missing') #('RangedWeapon' 'available') #('OtherSlot' 'forbidden')).
	result := store
			rowsAfterEquipping: saved
			forOwner: 'owner'
			outfit: false.
	self
		assert: (result collect: #equippedSlotIdentifier) asArray
		equals: #('MeleeWeapon' 'LeftHandWeapon' 'RangedWeapon' nil nil).
	self assert: available equippedSlotIdentifier isNil.
	self assert: displaced equippedSlotIdentifier equals: 'RangedWeapon'.
	self
		assertEmpty: (store
				rowsAfterEquipping: saved
				forOwner: 'other'
				outfit: false)
]

{ #category : 'tests' }
CIInventoryReadStoreTest >> testApplyingOutfitSwapsItemsAndKeepsUnlistedSlots [
	| first second cap result makeApparel |
	makeApparel := [ :id :slot |
		(CIInventoryApparelItemSummary
			item: id
			fromDefinition: (CIInventoryItemDefinition
					id: id
					name: id
					icon: nil))
			equippedApparelSlotIdentifier: slot;
			yourself ].
	first := makeApparel value: 'first' value: 'Mask'.
	second := makeApparel value: 'second' value: 'Neck'.
	cap := makeApparel value: 'cap' value: 'Hat'.
	store
		replaceRows: {first.
				second.
				cap}
		forOwner: 'owner'.
	result := store
			rowsAfterEquipping: #(#('Mask' 'second') #('Neck' 'first') #('Shoes' 'missing'))
			forOwner: 'owner'
			outfit: true.
	self
		assert: (result collect: #equippedApparelSlotIdentifier)
		equals: #('Neck' 'Mask' 'Hat').
	self assert: first equippedApparelSlotIdentifier equals: 'Mask'.
	self assert: second equippedApparelSlotIdentifier equals: 'Neck'
]

{ #category : 'tests' }
CIInventoryReadStoreTest >> testInvalidBoundsAndMissingOwnerRefuse [
	self
		should: [ store
				rowsForOwner: nil
				offset: 0
				limit: 1 ]
		raise: Error.
	self
		should: [ store
				rowsForOwner: 'user-a'
				offset: -1
				limit: 1 ]
		raise: Error.
	self
		should: [ store
				rowsForOwner: 'user-a'
				offset: 0
				limit: 33 ]
		raise: Error
]

{ #category : 'tests' }
CIInventoryReadStoreTest >> testOwnersSeeTheirOwnRows [
	| boots coat |
	boots := CIInventoryItemSummary
			item: 'one'
			definition: 'boots'
			name: 'Boots'.
	coat := CIInventoryItemSummary
			item: 'two'
			definition: 'coat'
			name: 'Coat'.
	store replaceRows: {boots} forOwner: 'user-a'.
	store replaceRows: {coat} forOwner: 'user-b'.
	self
		assert: (store
				rowsForOwner: 'user-a'
				offset: 0
				limit: 32)
		equals: {boots}.
	self
		assert: (store
				rowsForOwner: 'user-b'
				offset: 0
				limit: 32)
		equals: {coat}.
	self
		assertEmpty: (store
				rowsForOwner: 'unknown'
				offset: 0
				limit: 32)
]

{ #category : 'tests' }
CIInventoryReadStoreTest >> testPageDoesNotExposeBackingCollection [
	| first second rows page |
	first := CIInventoryItemSummary
			item: 'one'
			definition: 'boots'
			name: 'Boots'.
	second := CIInventoryItemSummary
			item: 'two'
			definition: 'coat'
			name: 'Coat'.
	rows := {first.
			second}.
	store replaceRows: rows forOwner: 'user-a'.
	rows at: 2 put: first.
	page := store
			rowsForOwner: 'user-a'
			offset: 1
			limit: 1.
	self assert: page equals: {second}.
	page at: 1 put: first.
	self
		assert: (store
				rowsForOwner: 'user-a'
				offset: 1
				limit: 1)
		equals: {second}.
	self
		assertEmpty: (store
				rowsForOwner: 'user-a'
				offset: 2
				limit: 1)
]

{ #category : 'tests' }
CIInventoryReadStoreTest >> testSavedSetsCaptureOnlyEquippedSlotsForTheirOwnerAndKind [
	| weapon vest gizmo unequipped shoes owned clothes supplies makeEquipment |
	makeEquipment := [ :id :kind :slot |
		CIInventoryEquipmentSummary
			item: id
			fromDefinition: (CIInventoryItemDefinition
					id: id
					name: id
					icon: nil)
			metadata: (Dictionary new
					at: #presentationKind put: kind;
					at: #inventoryTypeCount put: 1;
					at: #equippedSlotIdentifier put: slot;
					yourself) ].
	weapon := makeEquipment
			value: 'rifle'
			value: 'weapon'
			value: 'RangedWeapon'.
	vest := makeEquipment
			value: 'vest'
			value: 'gear'
			value: 'Chest'.
	gizmo := makeEquipment
			value: 'gadget'
			value: 'gadget'
			value: 'GadgetLeft'.
	unequipped := makeEquipment
			value: 'spare'
			value: 'weapon'
			value: nil.
	shoes := CIInventoryApparelItemSummary
			item: 'shoes'
			fromDefinition: (CIInventoryItemDefinition
					id: 'boots'
					name: 'Boots'
					icon: nil).
	shoes equippedApparelSlotIdentifier: 'Shoes'.
	clothes := CIInventoryApparelItemSummary
			item: 'spare-shirt'
			fromDefinition: (CIInventoryItemDefinition
					id: 'shirt'
					name: 'Shirt'
					icon: nil).
	supplies := (1 to: 32)
			collect: [ :number |
				CIInventoryItemSummary
					item: 'supply' , number asString
					definition: 'supply'
					name: 'Supply' ].
	owned := supplies
			, {weapon.
					vest.
					gizmo.
					unequipped.
					shoes.
					clothes}.
	store replaceRows: owned forOwner: 'user-a'.
	store
		replaceRows: {unequipped.
				clothes}
		forOwner: 'user-b'.
	self
		assert: (store equippedSlotsForOwner: 'user-a' outfit: false)
		equals: #(#('RangedWeapon' 'rifle') #('Chest' 'vest') #('GadgetLeft' 'gadget')).
	self
		assert: (store equippedSlotsForOwner: 'user-a' outfit: true)
		equals: #(#('Shoes' 'shoes')).
	self assertEmpty: (store equippedSlotsForOwner: 'user-b' outfit: false).
	self assertEmpty: (store equippedSlotsForOwner: 'user-b' outfit: true)
]
