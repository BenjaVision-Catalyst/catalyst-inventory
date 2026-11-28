"
An inventory ownership entry for a workbook signature weapon. Its source perk identifies the weapon. Combat stats and equip behavior require a complete weapon definition.
"
Class {
	#name : 'CIWorkbookSignatureWeaponType',
	#superclass : 'CIItemType',
	#instVars : [
		'rewardPerk'
	],
	#category : 'BVC-Inventory-TypeCatalog',
	#package : 'BVC-Inventory-TypeCatalog'
}

{ #category : 'instance creation' }
CIWorkbookSignatureWeaponType class >> forSpecializationPerk: perk [
	^ (self
		id: 'weapon.signature.' , perk id
		name: perk name
		icon: nil) initializeRewardPerk: perk
]

{ #category : 'initialization' }
CIWorkbookSignatureWeaponType >> initializeRewardPerk: perk [
	rewardPerk := perk.
	^ self
]

{ #category : 'inventory' }
CIWorkbookSignatureWeaponType >> inventoryItem: itemIdentifier values: values [
	self validateInventoryItemValues: values.
	^ (CIInventoryItemSummary
		item: itemIdentifier
		definition: self id
		name: rewardPerk name)
		availableEquipmentSlotIdentifiers: #();
		yourself
]

{ #category : 'accessing' }
CIWorkbookSignatureWeaponType >> rewardPerk [
	^ rewardPerk
]
