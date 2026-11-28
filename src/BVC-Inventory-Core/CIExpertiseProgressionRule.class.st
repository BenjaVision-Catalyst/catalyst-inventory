"
Catalog eligibility for the next individual item Grade. Account Expertise and item-type Proficiency are inputs. Stat contributions and upgrade costs have their own rules.
"
Class {
	#name : 'CIExpertiseProgressionRule',
	#superclass : 'CIAttributeRule',
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'evaluating' }
CIExpertiseProgressionRule >> canUpgradeFromGrade: grade expertiseLevel: expertiseLevel proficiencyRank: rank [
	(grade isInteger and: [ grade >= 0 ])
		ifFalse: [ self error: 'Invalid item Grade' ].
	(expertiseLevel isInteger
		and: [ expertiseLevel between: 0 and: self maximumExpertiseLevel ])
		ifFalse: [ self error: 'Invalid account Expertise Level' ].
	(rank isInteger and: [ rank between: 0 and: self maximumProficiencyRank ])
		ifFalse: [ self error: 'Invalid item-type Proficiency Rank' ].
	^ rank = self maximumProficiencyRank and: [ grade < expertiseLevel ]
]

{ #category : 'accessing' }
CIExpertiseProgressionRule >> maximumExpertiseLevel [
	^ parameters at: #maximumExpertiseLevel
]

{ #category : 'accessing' }
CIExpertiseProgressionRule >> maximumProficiencyRank [
	^ parameters at: #maximumProficiencyRank
]
