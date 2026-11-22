Class {
	#name : 'BVCGearFamilyTest',
	#superclass : 'TestCase',
	#category : 'BVC-Inventory-GearSimulation-Tests',
	#package : 'BVC-Inventory-GearSimulation-Tests'
}

{ #category : 'simulation' }
BVCGearFamilyTest >> testAllFamilyCases [
	| fixture rows expectedHealing expectedControl |
	fixture := BVCGearFamilyFixture new.
	rows := fixture run.
	self assert: rows size equals: 72.
	self
		assert: (rows collect: [ :row | (row at: #outfit) -> (row at: #scenario) ]) asSet size
		equals: 72.
	expectedHealing := #(0 0 8 8 14).
	expectedControl := #(0 0 0 1 1).
	rows
		do: [ :row | 
			| entries count healing control |
			entries := (row at: #contributions)
					select: [ :entry | entry includesKey: #family ].
			count := entries first at: #equipped.
			healing := (row at: #scenario) = #zero
					ifTrue: [ 0 ]
					ifFalse: [ expectedHealing at: count + 1 ].
			control := expectedControl at: count + 1.
			self
				assert: (entries first at: #rawDelta) + (entries last at: #rawDelta)
				equals: healing.
			self assert: (entries second at: #rawDelta) equals: control.
			entries
				do: [ :entry | self assert: (entry at: #eligible) equals: count >= (entry at: #threshold) ] ]
]

{ #category : 'simulation' }
BVCGearFamilyTest >> testGearV1Regression [
	| rows expected |
	rows := BVCGearSimulationFixture new run.
	expected := #(#(440 3600 80 1 10) #(440 3600 80 1 10) #(520 8400 70 1 10) #(520 8400 70 1 10) #(520 8400 80 3 10) #(520 8400 80 1 10) #(560 9600 70 3 10) #(560 9600 70 1 10) #(506 4761 55 1 10) #(440 3600 55 1 10) #(598 11109 45 1 10) #(520 8400 45 1 10) #(598 11109 55 3 10) #(520 8400 55 1 10) #(644 12696 45 3 10) #(560 9600 45 1 10) #(440 3600 65 1 30) #(440 3600 65 1 30) #(520 8400 55 1 30) #(520 8400 55 1 30) #(520 8400 65 3 30) #(520 8400 65 1 30) #(560 9600 55 3 30) #(560 9600 55 1 30)).
	self
		assert: (rows
				collect: [ :row | 
					#(damage damageVariance damageTaken control healing)
						collect: [ :stat | (row at: #metrics) at: stat ] ])
		equals: expected
]

{ #category : 'simulation' }
BVCGearFamilyTest >> testTriggerMustPrecedeConsumptionAndDoesNotBankCharges [
	| evaluator tier |
	evaluator := BVCGearFamilyEvaluator new.
	tier := BVCGearFamilyFixture new family tiers first.
	self
		assert: (evaluator activationsFor: tier events: #(heal interrupt))
		equals: 0.
	self
		assert: (evaluator activationsFor: tier events: #(interrupt interrupt heal heal))
		equals: 1.
	self
		assert: (evaluator activationsFor: tier events: #(interrupt heal interrupt heal))
		equals: 1
]
