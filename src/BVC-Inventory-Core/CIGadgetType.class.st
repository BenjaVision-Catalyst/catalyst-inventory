Class {
	#name : 'CIGadgetType',
	#superclass : 'CIItemType',
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'accessing' }
CIGadgetType >> baseStats [
	self subclassResponsibility
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
