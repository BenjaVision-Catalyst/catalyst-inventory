Class {
	#name : 'CIInventoryConfiguration',
	#superclass : 'CRServiceConfiguration',
	#instVars : [
		'inventorySnapshotPath'
	],
	#category : 'BVC-Inventory-Runtime',
	#package : 'BVC-Inventory-Runtime'
}

{ #category : 'initialization' }
CIInventoryConfiguration >> initialize [
	super initialize.
	serviceClass := CIInventoryService
]

{ #category : 'accessing' }
CIInventoryConfiguration >> inventorySnapshotPath [
	^ inventorySnapshotPath
]

{ #category : 'accessing' }
CIInventoryConfiguration >> inventorySnapshotPath: aString [
	inventorySnapshotPath := aString
]
