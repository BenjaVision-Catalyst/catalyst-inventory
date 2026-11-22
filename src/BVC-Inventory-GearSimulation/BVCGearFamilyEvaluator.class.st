Class {
	#name : 'BVCGearFamilyEvaluator',
	#superclass : 'Object',
	#category : 'BVC-Inventory-GearSimulation',
	#package : 'BVC-Inventory-GearSimulation'
}

{ #category : 'accessing' }
BVCGearFamilyEvaluator >> activationsFor: tier events: events [
	| armed used |
	tier trigger ifNil: [ ^ 1 ].
	armed := false.
	used := 0.
	events
		do: [ :event | 
			(armed and: [ event = tier consumeEvent ])
				ifTrue: [ armed := false.
					used := used + 1 ].
			(event = tier trigger and: [ used < tier limit ]) ifTrue: [ armed := true ] ].
	^ used
]

{ #category : 'accessing' }
BVCGearFamilyEvaluator >> contributionsFor: tier family: family equipped: count events: events target: target [
	| eligible activations |
	eligible := count >= tier pieceCount.
	activations := eligible
			ifTrue: [ self activationsFor: tier events: events ]
			ifFalse: [ 0 ].
	^ tier modifiers
		collect: [ :modifier | 
			| applied |
			modifier operation = #add
				ifFalse: [ self error: 'Family modifiers must be additive' ].
			modifier duration
				= (tier trigger isNil ifTrue: [ #whileEquipped ] ifFalse: [ #onConsume ])
				ifFalse: [ self error: 'Family modifier duration must match its tier' ].
			applied := (modifier appliesTo: target)
					ifTrue: [ activations ]
					ifFalse: [ 0 ].
			{#family -> family id.
				#threshold -> tier pieceCount.
				#equipped -> count.
				#eligible -> eligible.
				#activations -> applied.
				#active -> (applied > 0).
				#modifier -> modifier.
				#rawDelta -> (applied * modifier magnitude)} asDictionary ]
]

{ #category : 'accessing' }
BVCGearFamilyEvaluator >> contributionsFor: outfit in: scenario [
	| counts families events |
	counts := Bag new.
	outfit pieces do: [ :item | item familyId ifNotNil: [ :id | counts add: id ] ].
	families := scenario at: #families ifAbsent: [ #() ].
	events := scenario at: #events ifAbsent: [ #() ].
	^ families
		flatCollect: [ :family | 
			family tiers
				flatCollect: [ :tier | 
					self
						contributionsFor: tier
						family: family
						equipped: (counts occurrencesOf: family id)
						events: events
						target: (scenario at: #targetClass) ] ]
]
