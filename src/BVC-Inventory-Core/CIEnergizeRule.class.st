"
The armor-kit trigger shared by Energize and Perfect Energize. The caller supplies the current Gadget tier and time since the last activation.
"
Class {
	#name : 'CIEnergizeRule',
	#superclass : 'Object',
	#instVars : [
		'cooldownSeconds',
		'evidence'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIEnergizeRule class >> cooldownSeconds: seconds evidence: source [
	^ self new initializeCooldownSeconds: seconds evidence: source
]

{ #category : 'accessing' }
CIEnergizeRule >> cooldownSeconds [
	^ cooldownSeconds
]

{ #category : 'evaluating' }
CIEnergizeRule >> effectsOnArmorKitUseAtGadgetTier: tier secondsSinceLastActivation: elapsed [
	"The caller supplies nil for an instance that has never activated."

	(elapsed notNil and: [ elapsed < cooldownSeconds ])
		ifTrue: [ ^ Dictionary new ].
	tier = #overcharge ifTrue: [ ^ nil ].
	(tier isInteger and: [ tier between: 0 and: 6 ])
		ifFalse: [ self error: 'Invalid Gadget tier' ].
	^ tier = 6
		ifTrue: [ {#overcharge -> true} asDictionary ]
		ifFalse: [ {#gadgetTierBonus -> 1.
				#gadgetTierBonusSeconds -> 15} asDictionary ]
]

{ #category : 'accessing' }
CIEnergizeRule >> evidence [
	^ evidence copy
]

{ #category : 'initialization' }
CIEnergizeRule >> initializeCooldownSeconds: seconds evidence: source [
	cooldownSeconds := seconds.
	evidence := source copy
]
