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
				package: 'BVC-Inventory-TypeCatalog'
				with: [ spec requires: #('BVC-Inventory-Core') ].
			spec group: 'TypeCatalog' with: #('BVC-Inventory-TypeCatalog').
			spec
				package: 'BVC-Inventory-GearSimulation'
				with: [ spec requires: #('BVC-Inventory-Core') ].
			spec
				package: 'BVC-Inventory-GearSimulation-Tests'
				with: [ spec requires: #('BVC-Inventory-GearSimulation') ].
			spec
				package: 'BVC-Inventory-Tests'
				with: [ spec requires: #('BVC-Inventory-Core') ].
			spec
				baseline: 'CatalystRuntime'
				with: [ spec repository: 'github://BenjaVisionPro/CatalystRuntime:main/src' ].
			spec
				package: 'BVC-Inventory-Runtime'
				with: [ spec requires: #('BVC-Inventory-Core' 'CatalystRuntime') ].
			spec
				baseline: 'CatalystUsers'
				with: [ spec repository: 'github://BenjaVision-Catalyst/catalyst-users:main/src'.
					spec loads: #('connect') ].
			spec
				package: 'BVC-Inventory-Connect-Tests'
				with: [ spec requires: #('BVC-Inventory-Runtime' 'CatalystUsers') ].
			spec group: 'Tests' with: #('BVC-Inventory-Tests').
			spec group: 'ConnectTests' with: #('BVC-Inventory-Connect-Tests').
			spec group: 'Runtime' with: #('BVC-Inventory-Runtime').
			spec group: 'Core' with: #('BVC-Inventory-Core').
			spec group: 'GearSimulation' with: #('BVC-Inventory-GearSimulation').
			spec
				group: 'GearSimulationTests'
				with: #('BVC-Inventory-GearSimulation-Tests').
			spec group: 'default' with: #('Core') ]
]
