Class {
	#name : 'BaselineOfCatalystInventory',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfCatalystInventory',
	#package : 'BaselineOfCatalystInventory'
}

{ #category : 'baselines' }
BaselineOfCatalystInventory >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ spec package: 'BVC-Inventory-Core'.
			spec group: 'Core' with: #('BVC-Inventory-Core').
			spec group: 'default' with: #('Core') ]
]
