Class {
	#name : 'CIVenomHitOutcome',
	#superclass : 'Object',
	#instVars : [
		'targetIdentifier',
		'stackCount',
		'triggeredStatuses',
		'pelletHitFraction',
		'damageMultiplier',
		'refreshesDamageDebuff'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIVenomHitOutcome class >> target: targetId stacks: count statuses: statuses pelletHitFraction: fraction damageMultiplier: modifier refreshesDamageDebuff: refresh [
	^ self new
		initializeTarget: targetId
		stacks: count
		statuses: statuses
		pelletHitFraction: fraction
		damageMultiplier: modifier
		refreshesDamageDebuff: refresh
]

{ #category : 'accessing' }
CIVenomHitOutcome >> damageMultiplier [
	^ damageMultiplier
]

{ #category : 'initialization' }
CIVenomHitOutcome >> initializeTarget: targetId stacks: count statuses: statuses pelletHitFraction: fraction damageMultiplier: modifier refreshesDamageDebuff: refresh [
	targetIdentifier := targetId copy.
	stackCount := count.
	triggeredStatuses := statuses asArray copy.
	pelletHitFraction := fraction.
	damageMultiplier := modifier.
	refreshesDamageDebuff := refresh.
	^ self
]

{ #category : 'accessing' }
CIVenomHitOutcome >> pelletHitFraction [
	^ pelletHitFraction
]

{ #category : 'accessing' }
CIVenomHitOutcome >> refreshesDamageDebuff [
	^ refreshesDamageDebuff
]

{ #category : 'accessing' }
CIVenomHitOutcome >> stackCount [
	^ stackCount
]

{ #category : 'accessing' }
CIVenomHitOutcome >> targetIdentifier [
	^ targetIdentifier copy
]

{ #category : 'accessing' }
CIVenomHitOutcome >> triggeredStatuses [
	^ triggeredStatuses copy
]
