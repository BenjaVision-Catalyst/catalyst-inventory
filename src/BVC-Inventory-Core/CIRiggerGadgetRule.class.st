"
Rigger's Tend and Befriend rule and its Best Buds and Complete Uptime modifiers. The caller supplies the Gadget's interaction, active buff, and cooldown state.
"
Class {
	#name : 'CIRiggerGadgetRule',
	#superclass : 'Object',
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'evaluating' }
CIRiggerGadgetRule >> cooldownAfterGadgetEndsBy: reason remainingSeconds: remaining equippedPieces: count completeUptime: hasCompleteUptime [
	^ (count >= 4 and: [ hasCompleteUptime and: [ reason = #cancel ] ])
		ifTrue: [ 0 ]
		ifFalse: [ remaining ]
]

{ #category : 'evaluating' }
CIRiggerGadgetRule >> damageBuffOnGadgetInteraction: action equippedPieces: count buffActive: active bestBuds: hasBestBuds [
	(count >= 4
		and: [ active not and: [ #(use deploy changeTarget heal) includes: action ] ])
		ifFalse: [ ^ Dictionary new ].
	^ {#interactedGadgetDamageBonus
			-> (hasBestBuds ifTrue: [ 0.50 ] ifFalse: [ 0.25 ]).
		#buffDurationSeconds -> 10} asDictionary
]

{ #category : 'accessing' }
CIRiggerGadgetRule >> evidence [
	^ 'Gearsets!E43:G43'
]
