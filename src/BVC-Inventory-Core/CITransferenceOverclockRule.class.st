"
The Transference Overclock talent on BTSU Datagloves. An ally's most recent successful transfer is measured across wearers. The caller supplies elapsed time and applies the reported effects.
"
Class {
	#name : 'CITransferenceOverclockRule',
	#superclass : 'Object',
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'evaluating' }
CITransferenceOverclockRule >> effectsOnHiveDetonationFor: recipient detonatorGadgetTier: tier secondsSinceLastTransfer: elapsed [
	"The caller supplies nil for an ally who has never received this talent's effect."

	(recipient = #self
		or: [ recipient = #ally
				and: [ tier = 6 and: [ elapsed isNil or: [ elapsed >= 120 ] ] ] ])
		ifFalse: [ ^ Dictionary new ].
	^ {#refreshGadgetCooldowns -> true.
		#overchargeSeconds -> 15} asDictionary
]

{ #category : 'accessing' }
CITransferenceOverclockRule >> evidence [
	^ 'Gear Named + Exotics!F101:G101'
]

{ #category : 'evaluating' }
CITransferenceOverclockRule >> hiveHasteAtGadgetTier: tier [
	tier = #overcharge ifTrue: [ ^ nil ].
	(tier isInteger and: [ tier between: 0 and: 6 ])
		ifFalse: [ self error: 'Invalid Gadget tier' ].
	^ 0.15 * tier
]
