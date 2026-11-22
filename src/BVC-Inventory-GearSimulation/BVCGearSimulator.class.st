Class {
	#name : 'BVCGearSimulator',
	#superclass : 'Object',
	#category : 'BVC-Inventory-GearSimulation',
	#package : 'BVC-Inventory-GearSimulation'
}

{ #category : 'simulation' }
BVCGearSimulator >> comparisonsFor: row in: rows [
	| pieces |
	pieces := row at: #outfit.
	^ (rows
		select: [ :candidate | 
			| ids |
			ids := candidate at: #outfit.
			(candidate at: #scenario) = (row at: #scenario)
				and: [ ids isEmpty or: [ ids size = 1 and: [ pieces includes: ids first ] ] ] ])
		collect: [ :candidate | 
			(candidate at: #outfit)
				-> ((row at: #metrics) associations
						collect: [ :metric | metric key -> (metric value - ((candidate at: #metrics) at: metric key)) ])
						asDictionary ]
]

{ #category : 'simulation' }
BVCGearSimulator >> evaluate: outfit in: scenario [
	| raw effective contributions chance shots damage bonus incoming metrics |
	raw := (scenario at: #baseStats) copy.
	contributions := outfit pieces
			flatCollect: [ :item | 
				item modifiers
					collect: [ :modifier | 
						| active delta |
						(modifier operation = #add and: [ modifier duration = #whileEquipped ])
							ifFalse: [ self error: 'Only while-equipped additive modifiers are supported' ].
						active := modifier appliesTo: (scenario at: #targetClass).
						delta := active ifTrue: [ modifier magnitude ] ifFalse: [ 0 ].
						{#item -> item id.
							#modifier -> modifier.
							#active -> active.
							#rawDelta -> delta} asDictionary ] ].
	contributions := contributions
			, (BVCGearFamilyEvaluator new contributionsFor: outfit in: scenario).
	contributions
		do: [ :entry | 
			| stat |
			stat := (entry at: #modifier) stat.
			raw at: stat put: (raw at: stat) + (entry at: #rawDelta) ].
	effective := raw collect: [ :value | value max: 0 ].
	effective
		at: #criticalChance
		put: ((effective at: #criticalChance) min: (scenario at: #criticalCap)).
	effective
		at: #controlSeconds
		put: ((effective at: #controlSeconds) min: (scenario at: #encounterSeconds)).
	chance := effective at: #criticalChance.
	shots := scenario at: #shots.
	damage := effective at: #weaponDamage.
	bonus := damage * ((scenario at: #criticalMultiplier) - 1).
	incoming := scenario at: #incomingDamage.
	metrics := {#damage -> (shots * (damage + (chance * bonus))).
			#damageVariance -> (shots * chance * (1 - chance) * bonus squared).
			#damageTaken -> (incoming - (effective at: #armour) max: 0).
			#control -> (effective at: #controlSeconds).
			#healing -> (effective at: #healing)} asDictionary.
	#(mobility precision suppression)
		do: [ :stat | effective at: stat ifPresent: [ :value | metrics at: stat put: value ] ].
	^ {#outfit -> outfit itemIds.
		#scenario -> (scenario at: #id).
		#raw -> raw.
		#effective -> effective.
		#contributions -> contributions.
		#metrics -> metrics} asDictionary
]

{ #category : 'simulation' }
BVCGearSimulator >> outfitsFor: catalogue [
	| slots combinations |
	(catalogue collect: #id) asSet size = catalogue size
		ifFalse: [ self error: 'Catalogue item IDs must be unique' ].
	slots := (catalogue collect: #slot) asSet asSortedCollection.
	combinations := {#()}.
	slots
		do: [ :slot | 
			| choices |
			choices := catalogue select: [ :item | item slot = slot ].
			combinations := combinations
					flatCollect: [ :pieces | {pieces} , (choices collect: [ :item | pieces copyWith: item ]) ] ].
	^ combinations collect: [ :pieces | BVCGearOutfit withPieces: pieces ]
]

{ #category : 'simulation' }
BVCGearSimulator >> rank: rows scenario: scenarioId goals: goals [
	"Each goal is {metric. minimum. positive normalization value. weight}."

	| eligible scored |
	eligible := rows
			select: [ :row | 
				(row at: #scenario) = scenarioId
					and: [ goals
							allSatisfy: [ :goal | ((row at: #metrics) at: goal first) >= goal second ] ] ].
	scored := eligible
			collect: [ :row | 
				(row at: #outfit)
					-> (goals
							sum: [ :goal | ((row at: #metrics) at: goal first) / goal third * goal fourth ]) ].
	^ scored
		sorted: [ :left :right | 
			left value = right value
				ifTrue: [ left key printString <= right key printString ]
				ifFalse: [ left value > right value ] ]
]

{ #category : 'simulation' }
BVCGearSimulator >> runCatalogue: catalogue scenarios: scenarios [
	^ (self outfitsFor: catalogue)
		flatCollect: [ :outfit | scenarios collect: [ :scenario | self evaluate: outfit in: scenario ] ]
]
