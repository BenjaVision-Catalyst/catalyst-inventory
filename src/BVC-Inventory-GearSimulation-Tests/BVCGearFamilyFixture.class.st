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
	^ BVCGearFamily
		id: #response
		manufacturer: 'Relay Works'
		tiers: {self responseHeal: 8 at: 2.
				BVCGearFamilyTier
					pieces: 3
					modifiers: {BVCGearSimulationFixture new
								add: 1
								to: #controlSeconds
								against: nil}
					trigger: nil
					consumeOn: nil
					limit: 1.
				self responseHeal: 6 at: 4}
]

{ #category : 'simulation' }
BVCGearFamilyFixture >> responseHeal: amount at: threshold [
	^ BVCGearFamilyTier
		pieces: threshold
		modifiers: {BVCGearModifier
					stat: #healing
					operation: #add
					magnitude: amount
					targetClass: nil
					duration: #onConsume}
		trigger: #interrupt
		consumeOn: #heal
		limit: 1
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
