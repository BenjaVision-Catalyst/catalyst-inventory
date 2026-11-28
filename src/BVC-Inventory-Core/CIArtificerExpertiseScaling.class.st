"
Artificer Tech Efficiency adds a fraction of base Buff Amount to the tier's Buff Amount. It leaves the Hive's other stat tracks outside this calculation.
"
Class {
	#name : 'CIArtificerExpertiseScaling',
	#superclass : 'CIGadgetExpertiseScaling',
	#instVars : [
		'buffAmountTrack'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'evaluating' }
CIArtificerExpertiseScaling >> buffAmountAtTier: tier grade: grade [
	| tierAmount |
	tierAmount := buffAmountTrack magnitudeAtTier: tier.
	^ tierAmount
		+ (buffAmountTrack baseMagnitude * (self contributionAtGrade: grade))
]

{ #category : 'initialization' }
CIArtificerExpertiseScaling >> buffAmountTrack: track [
	buffAmountTrack := track
]
