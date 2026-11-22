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
			spec
				package: 'BVC-Inventory-GearSimulation'
				with: [ spec requires: #('BVC-Inventory-Core') ].
			spec
				package: 'BVC-Inventory-GearSimulation-Tests'
				with: [ spec requires: #('BVC-Inventory-GearSimulation') ].
			spec group: 'Core' with: #('BVC-Inventory-Core').
			spec group: 'GearSimulation' with: #('BVC-Inventory-GearSimulation').
			spec
				group: 'GearSimulationTests'
				with: #('BVC-Inventory-GearSimulation-Tests').
			spec group: 'default' with: #('Core') ]
]
