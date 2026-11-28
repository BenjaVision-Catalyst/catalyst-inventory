"
The Combat Medic talent on Birdie's Quick Fix Pack. Revive events and participants are supplied by the caller.
"
Class {
	#name : 'CICombatMedicRule',
	#superclass : 'Object',
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'evaluating' }
CICombatMedicRule >> damageResistanceAfterSuccessfulRevive: reviveKind for: participant elapsedSeconds: elapsed [
	| duration |
	(elapsed isNumber and: [ elapsed >= 0 ])
		ifFalse: [ self error: 'Invalid elapsed revive time' ].
	(#(reviver revivedAgent) includes: participant) ifFalse: [ ^ 0 ].
	duration := reviveKind
			caseOf: {[ #hive ] -> [ 5 ].
					[ #manual ] -> [ 10 ]}
			otherwise: [ ^ nil ].
	^ elapsed < duration
		ifTrue: [ self damageResistanceDuringReviveFor: participant ]
		ifFalse: [ 0 ]
]

{ #category : 'evaluating' }
CICombatMedicRule >> damageResistanceDuringReviveFor: participant [
	^ (#(reviver revivedAgent) includes: participant)
		ifTrue: [ 0.50 ]
		ifFalse: [ 0 ]
]

{ #category : 'evaluating' }
CICombatMedicRule >> effectsOnSuccessfulReviveAtGadgetTier: tier [
	tier = #overcharge ifTrue: [ ^ nil ].
	(tier isInteger and: [ tier between: 0 and: 6 ])
		ifFalse: [ self error: 'Invalid Gadget tier' ].
	^ tier = 6
		ifTrue: [ {#overchargeSeconds -> 15} asDictionary ]
		ifFalse: [ {#gadgetTierBonus -> 1.
				#gadgetTierBonusSeconds -> 5} asDictionary ]
]

{ #category : 'accessing' }
CICombatMedicRule >> evidence [
	^ 'Gear Named + Exotics!F81:G81; Ubisoft Crossroads, Other Changes'
]

{ #category : 'accessing' }
CICombatMedicRule >> hiveEfficiencyBonus [
	^ 0.45
]

{ #category : 'accessing' }
CICombatMedicRule >> manualReviveSpeedBonus [
	^ 0.80
]

{ #category : 'accessing' }
CICombatMedicRule >> weakenedDurationReduction [
	^ 0.50
]
