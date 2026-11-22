Class {
	#name : 'CIGearSimulationTest',
	#superclass : 'TestCase',
	#category : 'BVC-Inventory-GearSimulation-Tests',
	#package : 'BVC-Inventory-GearSimulation-Tests'
}

{ #category : 'tests' }
CIGearSimulationTest >> rowWith: ids scenario: scenario in: rows [
	^ rows
		detect: [ :row | (row at: #outfit) = ids and: [ (row at: #scenario) = scenario ] ]
]

{ #category : 'tests' }
CIGearSimulationTest >> testComparisonsAndRankings [
	| fixture simulator rows row comparisons |
	fixture := CIGearSimulationFixture new.
	simulator := CIGearSimulator new.
	rows := fixture run.
	row := self
			rowWith: #(vest goggles helmet)
			scenario: #raider
			in: rows.
	comparisons := (simulator comparisonsFor: row in: rows) asDictionary.
	self assert: comparisons size equals: 4.
	self assert: ((comparisons at: #()) at: #damage) equals: 204.
	self assert: ((comparisons at: #(vest)) at: #damage) equals: 138.
	self
		assert: (simulator
				rank: rows
				scenario: #raider
				goals: fixture damageGoals) first key
		equals: #(vest goggles helmet).
	self
		assert: (simulator
				rank: rows
				scenario: #raider
				goals: fixture mixedGoals) size
		equals: 2.
	self
		assert: (simulator
				rank: rows
				scenario: #drone
				goals: fixture mixedGoals) isEmpty
]

{ #category : 'tests' }
CIGearSimulationTest >> testConditionsAndCap [
	| rows raider drone |
	rows := CIGearSimulationFixture new run.
	raider := self
			rowWith: #(vest goggles helmet)
			scenario: #raider
			in: rows.
	drone := self
			rowWith: #(vest goggles helmet)
			scenario: #drone
			in: rows.
	self assert: ((raider at: #raw) at: #criticalChance) equals: 1 / 2.
	self assert: ((raider at: #effective) at: #criticalChance) equals: 2 / 5.
	self assert: ((raider at: #metrics) at: #damage) equals: 644.
	self assert: ((drone at: #metrics) at: #damage) equals: 560.
	self assert: ((drone at: #metrics) at: #damageTaken) equals: 45.
	self
		assert: (((drone at: #contributions) reject: [ :each | each at: #active ])
				collect: [ :each | each at: #rawDelta ])
		equals: #(0 0)
]

{ #category : 'tests' }
CIGearSimulationTest >> testCoverage [
	| fixture outfits rows |
	fixture := CIGearSimulationFixture new.
	outfits := CIGearSimulator new outfitsFor: fixture catalogue.
	rows := fixture run.
	self assert: outfits size equals: 12.
	self assert: rows size equals: 24.
	self
		assert: (rows collect: [ :row | (row at: #outfit) -> (row at: #scenario) ]) asSet size
		equals: 24.
	outfits
		do: [ :outfit | 
			self
				assert: (outfit pieces collect: #slot) asSet size
				equals: outfit pieces size ]
]

{ #category : 'tests' }
CIGearSimulationTest >> testSlotAndItemRules [
	| fixture vests plainItem |
	fixture := CIGearSimulationFixture new.
	vests := fixture catalogue select: [ :item | item slot = #chest ].
	self should: [ CIGearOutfit withPieces: vests ] raise: Error.
	plainItem := CIInventoryItemDefinition
			id: #drink
			name: 'Drink'
			icon: 'gearIcon_Drink.png'.
	self assert: plainItem id equals: #drink.
	self should: [ CIGearOutfit withPieces: {plainItem} ] raise: Error
]
