"
The Expertise multiplier for a hit on a zone marked by Achilles Pulse. The caller supplies mark eligibility and resolves all other damage terms.
"
Class {
	#name : 'CIAchillesPulseExpertiseScaling',
	#superclass : 'CIGadgetExpertiseScaling',
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'evaluating' }
CIAchillesPulseExpertiseScaling >> damageMultiplierForMarkedHit: hitsMarkedZone atGrade: grade [
	| contribution |
	contribution := self contributionAtGrade: grade.
	^ hitsMarkedZone ifTrue: [ 1 + contribution ] ifFalse: [ 1 ]
]
