"
An explicit Skill List overcharge behavior. A variant exposes the rule only for the overcharge tier.
"
Class {
	#name : 'CIGadgetOverchargeRule',
	#superclass : 'Object',
	#instVars : [
		'kind',
		'magnitude',
		'durationSeconds',
		'evidence'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIGadgetOverchargeRule class >> kind: effectKind magnitude: amount seconds: seconds evidence: source [
	^ self new
		initializeKind: effectKind
		magnitude: amount
		seconds: seconds
		evidence: source
]

{ #category : 'evaluating' }
CIGadgetOverchargeRule >> damageAmplificationForPulsedTarget: pulsed recipientIsAgentOrAlly: eligible [
	^ (kind = #weaknessExploit and: [ pulsed and: [ eligible ] ])
		ifTrue: [ magnitude ]
		ifFalse: [ 0 ]
]

{ #category : 'accessing' }
CIGadgetOverchargeRule >> evidence [
	^ evidence copy
]

{ #category : 'initialization' }
CIGadgetOverchargeRule >> initializeKind: effectKind magnitude: amount seconds: seconds evidence: source [
	kind := effectKind.
	magnitude := amount.
	durationSeconds := seconds.
	evidence := source copy
]

{ #category : 'accessing' }
CIGadgetOverchargeRule >> kind [
	^ kind
]

{ #category : 'testing' }
CIGadgetOverchargeRule >> shieldIsInvulnerable [
	^ kind = #shieldWall
]

{ #category : 'evaluating' }
CIGadgetOverchargeRule >> statusImmunitySecondsOnTrapContact [
	^ kind = #immunizingSerum ifTrue: [ durationSeconds ]
]
