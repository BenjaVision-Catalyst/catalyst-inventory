"
The grenade-throw trigger and passive bonuses on Acosta's Go-Bag. The caller supplies Gadget tier and time since the last activation.
"
Class {
	#name : 'CIAcostaGoBagRule',
	#superclass : 'Object',
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'accessing' }
CIAcostaGoBagRule >> cooldownSeconds [
	^ 60
]

{ #category : 'evaluating' }
CIAcostaGoBagRule >> effectsOnGrenadeThrowAtGadgetTier: tier secondsSinceLastActivation: elapsed [
	"The caller supplies nil when this talent has never activated."

	(elapsed notNil and: [ elapsed < self cooldownSeconds ])
		ifTrue: [ ^ Dictionary new ].
	tier = #overcharge ifTrue: [ ^ nil ].
	(tier isInteger and: [ tier between: 0 and: 6 ])
		ifFalse: [ self error: 'Invalid Gadget tier' ].
	^ tier = 6
		ifTrue: [ {#grenadesRefunded -> 1.
				#overchargeSeconds -> 15} asDictionary ]
		ifFalse: [ {#grenadesRefunded -> 1.
				#gadgetTierBonus -> 1.
				#gadgetTierBonusSeconds -> 15} asDictionary ]
]

{ #category : 'accessing' }
CIAcostaGoBagRule >> evidence [
	^ 'Gear Named + Exotics!F79:G79; https://www.dailymotion.com/video/xbkblva (04:12)'
]

{ #category : 'accessing' }
CIAcostaGoBagRule >> passiveBonuses [
	^ {#armorKitCapacity -> 1.
		#grenadeCapacity -> 3.
		#ammoCapacity -> 0.25.
		#repairSkills -> 0.10.
		#statusEffects -> 0.10} asDictionary
]
