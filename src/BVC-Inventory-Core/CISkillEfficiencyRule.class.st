"
The Attribute Info skill efficiency contribution and its separate reported stat-sheet projection.
"
Class {
	#name : 'CISkillEfficiencyRule',
	#superclass : 'CIAttributeRule',
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'evaluating' }
CISkillEfficiencyRule >> actualContributionsForEfficiency: efficiency [
	| contribution |
	(efficiency isNumber and: [ efficiency >= 0 ])
		ifFalse: [ self error: 'Invalid skill efficiency' ].
	contribution := efficiency * (parameters at: #contributionFactor).
	^ ((parameters at: #affectedStats) collect: [ :stat | stat -> contribution ])
		asDictionary
]

{ #category : 'evaluating' }
CISkillEfficiencyRule >> cooldownSecondsFromBase: baseSeconds efficiency: efficiency [
	^ CISkillHasteRule
		secondsFromBase: baseSeconds
		withHaste: ((self actualContributionsForEfficiency: efficiency) at: #skillHaste)
]

{ #category : 'evaluating' }
CISkillEfficiencyRule >> reportedContributionsForEfficiency: efficiency [
	| contributions |
	contributions := self actualContributionsForEfficiency: efficiency.
	contributions
		at: #skillHaste
		put: (contributions at: #skillHaste) * (parameters at: #observedHasteDisplayFactor).
	^ contributions
]
