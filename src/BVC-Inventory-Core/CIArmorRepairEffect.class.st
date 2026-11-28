Class {
	#name : 'CIArmorRepairEffect',
	#superclass : 'Object',
	#instVars : [
		'fraction',
		'durationSeconds',
		'talentIdentifier'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIArmorRepairEffect class >> fraction: aFraction durationSeconds: seconds talent: talentId [
	^ self new
		initializeFraction: aFraction
		durationSeconds: seconds
		talent: talentId
]

{ #category : 'accessing' }
CIArmorRepairEffect >> durationSeconds [
	^ durationSeconds
]

{ #category : 'accessing' }
CIArmorRepairEffect >> fraction [
	^ fraction
]

{ #category : 'initialization' }
CIArmorRepairEffect >> initializeFraction: aFraction durationSeconds: seconds talent: talentId [
	fraction := aFraction.
	durationSeconds := seconds.
	talentIdentifier := talentId copy.
	^ self
]

{ #category : 'accessing' }
CIArmorRepairEffect >> talentIdentifier [
	^ talentIdentifier copy
]
