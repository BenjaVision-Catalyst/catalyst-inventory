Class {
	#name : 'CIGearFamilyFixture',
	#superclass : 'Object',
	#category : 'BVC-Inventory-GearSimulation-Tests',
	#package : 'BVC-Inventory-GearSimulation-Tests'
}

{ #category : 'simulation' }
CIGearFamilyFixture >> catalogue [
	| gear boots |
	gear := CIGearSimulationFixture new catalogue.
	(gear reject: [ :item | item id = #vest ])
		do: [ :item | item familyId: #response ].
	boots := CIGearDefinition
			id: #boots
			name: 'Response Boots'
			icon: 'gearIcon_Boots.png'
			type: #armour
			slot: #feet
			modifiers: {CIGearSimulationFixture new
						add: 5
						to: #armour
						against: nil}.
	boots familyId: #response.
	^ gear copyWith: boots
]

{ #category : 'simulation' }
CIGearFamilyFixture >> family [
	^ CIGearPlaystyleCatalogue new responseFamily
]

{ #category : 'simulation' }
CIGearFamilyFixture >> run [
	^ CIGearSimulator new runCatalogue: self catalogue scenarios: self scenarios
]

{ #category : 'simulation' }
CIGearFamilyFixture >> scenarios [
	| base family |
	base := CIGearSimulationFixture new scenarios first.
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
