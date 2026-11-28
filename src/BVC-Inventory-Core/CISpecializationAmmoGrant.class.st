Class {
	#name : 'CISpecializationAmmoGrant',
	#superclass : 'Object',
	#instVars : [
		'ticks',
		'personalFraction',
		'partyFraction'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CISpecializationAmmoGrant class >> ticks: occurrences personal: personal party: party [
	^ self new
		initializeTicks: occurrences
		personal: personal
		party: party
]

{ #category : 'initialization' }
CISpecializationAmmoGrant >> initializeTicks: occurrences personal: personal party: party [
	ticks := occurrences.
	personalFraction := personal.
	partyFraction := party.
	^ self
]

{ #category : 'accessing' }
CISpecializationAmmoGrant >> partyFraction [
	^ partyFraction
]

{ #category : 'accessing' }
CISpecializationAmmoGrant >> personalFraction [
	^ personalFraction
]

{ #category : 'accessing' }
CISpecializationAmmoGrant >> ticks [
	^ ticks
]
