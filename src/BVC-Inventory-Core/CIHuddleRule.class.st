"
The Measured Assembly four-piece talent and its chest and backpack modifiers. The caller supplies unique allies in range of the wearer's Hive or Smart Cover and elapsed event times.
"
Class {
	#name : 'CIHuddleRule',
	#superclass : 'Object',
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'accessing' }
CIHuddleRule >> evidence [
	^ 'Gearsets!E31:G31; Ubisoft Crossroads, Measured Assembly'
]

{ #category : 'evaluating' }
CIHuddleRule >> gadgetTierBonusForAlliesInRange: allyCount equippedPieces: pieceCount [
	^ (self isActiveWithEquippedPieces: pieceCount)
		ifTrue: [ allyCount ]
		ifFalse: [ 0 ]
]

{ #category : 'accessing' }
CIHuddleRule >> interceptionCooldownSecondsWithSmartCooperation: hasSmartCooperation [
	^ hasSmartCooperation ifTrue: [ 1 ] ifFalse: [ 10 ]
]

{ #category : 'evaluating' }
CIHuddleRule >> interceptsTargetEnteringRange: target equippedPieces: count cooldownReady: ready [
	^ (self isActiveWithEquippedPieces: count)
		and: [ ready and: [ #(mortar enemyGadget) includes: target ] ]
]

{ #category : 'testing' }
CIHuddleRule >> isActiveWithEquippedPieces: count [
	^ count >= 4
]

{ #category : 'accessing' }
CIHuddleRule >> overchargeCooldownSecondsWithHivemind: hasHivemind [
	^ hasHivemind ifTrue: [ 25 ] ifFalse: [ 40 ]
]

{ #category : 'evaluating' }
CIHuddleRule >> overchargeSecondsAtGadgetTier: tier equippedPieces: count secondsQualifying: qualifyingSeconds secondsSinceLastActivation: elapsed hivemind: hasHivemind [
	"Qualifying seconds are continuous time with an ally in range while at tier six."

	((self isActiveWithEquippedPieces: count) and: [ qualifyingSeconds >= 4 ])
		ifFalse: [ ^ 0 ].
	(elapsed notNil
		and: [ elapsed < (self overchargeCooldownSecondsWithHivemind: hasHivemind) ])
		ifTrue: [ ^ 0 ].
	tier = #overcharge ifTrue: [ ^ nil ].
	^ tier = 6 ifTrue: [ 15 ] ifFalse: [ 0 ]
]

{ #category : 'accessing' }
CIHuddleRule >> reportedInterceptionSpeedBonusPerAlly [
	^ 0.20
]
