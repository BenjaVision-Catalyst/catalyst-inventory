Class {
	#name : 'CIPartyArmorRepairPickup',
	#superclass : 'Object',
	#instVars : [
		'fraction',
		'grantsBonusArmor'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIPartyArmorRepairPickup class >> fraction: anAmount grantsBonusArmor: aBoolean [
	^ self new initializeFraction: anAmount grantsBonusArmor: aBoolean
]

{ #category : 'accessing' }
CIPartyArmorRepairPickup >> fraction [
	^ fraction
]

{ #category : 'accessing' }
CIPartyArmorRepairPickup >> grantsBonusArmor [
	^ grantsBonusArmor
]

{ #category : 'initialization' }
CIPartyArmorRepairPickup >> initializeFraction: anAmount grantsBonusArmor: aBoolean [
	fraction := anAmount.
	grantsBonusArmor := aBoolean.
	^ self
]
