Class {
	#name : 'CIInventoryCatalogGear',
	#superclass : 'CIInventoryGearSummary',
	#instVars : [
		'rolledAttributes'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'initialization' }
CIInventoryCatalogGear >> initializeMetadata: metadata [
	super initializeMetadata: metadata.
	rolledAttributes := (metadata at: #rolledAttributes) asArray copy.
	^ self
]

{ #category : 'accessing' }
CIInventoryCatalogGear >> rolledAttributes [
	^ rolledAttributes copy
]
