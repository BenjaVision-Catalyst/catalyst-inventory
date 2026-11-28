"
The inventory definition for a workbook specialization grenade. The original perk supplies descriptive text, evidence and the reported status effects. A reward entry records ownership of the grenade type.
"
Class {
	#name : 'CIWorkbookGrenadeType',
	#superclass : 'CIItemType',
	#instVars : [
		'rewardPerk'
	],
	#category : 'BVC-Inventory-TypeCatalog',
	#package : 'BVC-Inventory-TypeCatalog'
}

{ #category : 'instance creation' }
CIWorkbookGrenadeType class >> forSpecializationPerk: perk [
	^ (self
		id: 'grenade.specialization.' , perk id
		name: perk name
		icon: nil) initializeRewardPerk: perk
]

{ #category : 'initialization' }
CIWorkbookGrenadeType >> initializeRewardPerk: perk [
	rewardPerk := perk.
	^ self
]

{ #category : 'inventory' }
CIWorkbookGrenadeType >> inventoryItem: itemIdentifier values: values [
	self validateInventoryItemValues: values.
	^ CIInventoryItemSummary
		item: itemIdentifier
		definition: self id
		name: rewardPerk name
]

{ #category : 'accessing' }
CIWorkbookGrenadeType >> rewardPerk [
	^ rewardPerk
]
