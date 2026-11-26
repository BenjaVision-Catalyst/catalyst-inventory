Class {
	#name : 'CIInventoryConfiguration',
	#superclass : 'CRServiceConfiguration',
	#category : 'BVC-Inventory-Runtime',
	#package : 'BVC-Inventory-Runtime'
}

{ #category : 'initialization' }
CIInventoryConfiguration >> initialize [
	super initialize.
	serviceClass := CIInventoryService
]
