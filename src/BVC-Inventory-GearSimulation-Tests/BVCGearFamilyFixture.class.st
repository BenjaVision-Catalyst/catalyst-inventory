Class {
	#name : 'BVCGearFamilyFixture',
	#superclass : 'Object',
	#category : 'BVC-Inventory-GearSimulation-Tests',
	#package : 'BVC-Inventory-GearSimulation-Tests'
}

{ #category : 'simulation' }
BVCGearFamilyFixture >> catalogue [
	| gear boots |
	gear := BVCGearSimulationFixture new catalogue.
	(gear reject: [ :item | item id = #vest ])
		do: [ :item | item familyId: #response ].
	boots := BVCGearDefinition
			id: #boots
			name: 'Response Boots'
			icon: 'gearIcon_Boots.png'
			type: #armour
			slot: #feet
			modifiers: {BVCGearSimulationFixture new
						add: 5
						to: #armour
						against: nil}.
	boots familyId: #response.
	^ gear copyWith: boots
]

{ #category : 'simulation' }
BVCGearFamilyFixture >> family [
	^ BVCGearPlaystyleCatalogue new responseFamily
]

{ #category : 'simulation' }
BVCGearFamilyFixture >> run [
	^ BVCGearSimulator new runCatalogue: self catalogue scenarios: self scenarios
]

{ #category : 'simulation' }
BVCGearFamilyFixture >> scenarios [
	| base family |
	base := BVCGearSimulationFixture new scenarios first.
	family := self family.
	^ #(#(zero #(heal heal)) #(one #(interrupt heal heal)) #(two #(interrupt heal interrupt heal)))
		collect: [ :entry | 
			base copy
				at: #id put: entry first;
				at: #version put: 'gear-family-v2';
				at: #families put: {family};
				at: #events put: entry second;
				yourself ]
]
