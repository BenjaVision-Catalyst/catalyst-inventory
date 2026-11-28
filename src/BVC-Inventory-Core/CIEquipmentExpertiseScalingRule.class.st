"
The additive Expertise contribution for an individual weapon or armor item. The calculation takes the item's unmodified base stat and reports only the Expertise bonus.
"
Class {
	#name : 'CIEquipmentExpertiseScalingRule',
	#superclass : 'CIAttributeRule',
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'evaluating' }
CIEquipmentExpertiseScalingRule >> bonusAtGrade: grade onBase: base [
	(base isNumber and: [ base >= 0 ]) ifFalse: [ self error: 'Invalid base stat' ].
	^ base * (self contributionAtGrade: grade)
]

{ #category : 'evaluating' }
CIEquipmentExpertiseScalingRule >> contributionAtGrade: grade [
	(grade isInteger and: [ grade >= 0 ])
		ifFalse: [ self error: 'Invalid expertise grade' ].
	^ grade * (parameters at: #fractionPerGrade)
]
