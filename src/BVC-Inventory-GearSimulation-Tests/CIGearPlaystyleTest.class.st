Class {
	#name : 'CIGearPlaystyleTest',
	#superclass : 'TestCase',
	#category : 'BVC-Inventory-GearSimulation-Tests',
	#package : 'BVC-Inventory-GearSimulation-Tests'
}

{ #category : 'tests' }
CIGearPlaystyleTest >> testAllRolesHaveChoices [
	| comparison catalogue |
	catalogue := CIGearPlaystyleCatalogue new.
	self assert: catalogue standalone size equals: 24.
	self assert: (catalogue standalone allSatisfy: [ :gear | gear familyId isNil ]).
	comparison := CIGearPlaystyleComparison new run.
	self assert: comparison size equals: 5.
	comparison
		do: [ :role | 
			| winners |
			winners := role at: #winners.
			self assert: (role at: #caseCount) equals: 4096.
			self
				assert: (winners collect: [ :winner | winner at: #cases ])
				equals: #(2401 1694 1).
			self assert: (winners allSatisfy: [ :winner | (winner at: #qualified) > 0 ]) ]
]

{ #category : 'tests' }
CIGearPlaystyleTest >> testResponseTradeoff [
	| role winners standalone fullSet |
	role := CIGearPlaystyleComparison new
			compare: CIGearPlaystyleComparison new profiles last.
	winners := role at: #winners.
	standalone := (winners first at: #row) at: #metrics.
	fullSet := (winners last at: #row) at: #metrics.
	self assert: (standalone at: #healing) >= 30.
	self assert: (standalone at: #control) >= 3.
	self assert: (fullSet at: #healing) equals: 44.
	self assert: (fullSet at: #control) equals: 4
]
