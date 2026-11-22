Class {
	#name : 'CIGearPlaystyleComparison',
	#superclass : 'Object',
	#category : 'BVC-Inventory-GearSimulation',
	#package : 'BVC-Inventory-GearSimulation'
}

{ #category : 'simulation' }
CIGearPlaystyleComparison >> bestIn: rows group: group profile: profile simulator: simulator [
	| candidates ranking winner |
	candidates := rows select: [ :row | (row at: #gearGroup) = group ].
	ranking := simulator
			rank: candidates
			scenario: profile first
			goals: profile fourth.
	ranking
		ifEmpty: [ ^ {#group -> group.
				#cases -> candidates size.
				#qualified -> 0} asDictionary ].
	winner := candidates detect: [ :row | (row at: #outfit) = ranking first key ].
	^ {#group -> group.
		#cases -> candidates size.
		#qualified -> ranking size.
		#score -> ranking first value.
		#ties -> (ranking count: [ :entry | entry value = ranking first value ]).
		#row -> winner} asDictionary
]

{ #category : 'simulation' }
CIGearPlaystyleComparison >> compare: profile [
	| catalogue simulator scenario outfits rows |
	catalogue := CIGearPlaystyleCatalogue new itemsFor: profile second.
	simulator := CIGearSimulator new.
	scenario := self scenarioFor: profile.
	outfits := simulator outfitsFor: catalogue.
	rows := outfits
			collect: [ :outfit | 
				| row count |
				row := simulator evaluate: outfit in: scenario.
				count := outfit pieces count: [ :item | item familyId = profile second ].
				row at: #gearGroup put: (self groupForSetCount: count).
				row ].
	^ {#role -> profile first.
		#caseCount -> rows size.
		#winners
			-> (#(standalone mixed fullSet)
					collect: [ :group | 
						self
							bestIn: rows
							group: group
							profile: profile
							simulator: simulator ])} asDictionary
]

{ #category : 'simulation' }
CIGearPlaystyleComparison >> groupForSetCount: count [
	count = 0 ifTrue: [ ^ #standalone ].
	count = 4 ifTrue: [ ^ #fullSet ].
	^ #mixed
]

{ #category : 'simulation' }
CIGearPlaystyleComparison >> profiles [
	^ #(#(runAndGun traverse #(sprint closeHit) #(#(mobility 4 6 1) #(damage 440 500 1))) #(sniper stillpoint #(settle aimedHit) #(#(precision 4 6 1) #(damage 440 500 1))) #(overwatch watchline #(takeCover sustainBurst) #(#(suppression 4 6 1) #(damage 440 500 1))) #(crowdControl containment #(interrupt deploySlow) #(#(control 3 5 1) #(damage 440 500 1))) #(support response #(interrupt heal) #(#(control 3 3 1) #(healing 30 30 1))))
]

{ #category : 'simulation' }
CIGearPlaystyleComparison >> run [
	^ self profiles collect: [ :profile | self compare: profile ]
]

{ #category : 'simulation' }
CIGearPlaystyleComparison >> scenarioFor: profile [
	^ {#id -> profile first.
		#version -> 'gear-playstyles-v3'.
		#character -> #shaki.
		#weapon -> #trainingRifle.
		#targetClass -> #raider.
		#events -> profile third.
		#families -> {CIGearPlaystyleCatalogue new familyFor: profile second}.
		#encounterSeconds -> 10.
		#incomingDamage -> 80.
		#shots -> 4.
		#criticalMultiplier -> 2.
		#criticalCap -> (2 / 5).
		#baseStats
			-> {#armour -> 0.
					#criticalChance -> (1 / 10).
					#weaponDamage -> 100.
					#controlSeconds -> 1.
					#healing -> 10.
					#mobility -> 1.
					#precision -> 1.
					#suppression -> 1} asDictionary} asDictionary
]
