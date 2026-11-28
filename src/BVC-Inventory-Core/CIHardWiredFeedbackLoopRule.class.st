"
Hard Wired's four-piece Feedback Loop with the Positive Reinforcement and Short Circuit set modifiers. The caller supplies the triggering Gadget event and time since the last activation.
"
Class {
	#name : 'CIHardWiredFeedbackLoopRule',
	#superclass : 'Object',
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'accessing' }
CIHardWiredFeedbackLoopRule >> cooldownSecondsWithShortCircuit: hasShortCircuit [
	^ hasShortCircuit ifTrue: [ 5 ] ifFalse: [ 10 ]
]

{ #category : 'evaluating' }
CIHardWiredFeedbackLoopRule >> effectsOnGadgetEvent: event equippedPieces: count secondsSinceLastActivation: elapsed positiveReinforcement: hasPositiveReinforcement shortCircuit: hasShortCircuit [
	| bonus |
	(count >= 4 and: [ #(use cancel) includes: event ])
		ifFalse: [ ^ Dictionary new ].
	(elapsed notNil
		and: [ elapsed < (self cooldownSecondsWithShortCircuit: hasShortCircuit) ])
		ifTrue: [ ^ Dictionary new ].
	bonus := hasPositiveReinforcement ifTrue: [ 0.25 ] ifFalse: [ 0.10 ].
	^ {#otherGadgetCooldownReductionSeconds -> 30.
		#totalGadgetDamageBonus -> bonus.
		#totalGadgetRepairBonus -> bonus.
		#buffDurationSeconds -> 20} asDictionary
]

{ #category : 'accessing' }
CIHardWiredFeedbackLoopRule >> evidence [
	^ 'Gearsets!E23:G23'
]
