"
Skill haste is a speed multiplier. The raw conversion leaves skill-specific minimums and other cooldown modifiers to separately documented rules.
"
Class {
	#name : 'CISkillHasteRule',
	#superclass : 'Object',
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'evaluating' }
CISkillHasteRule class >> secondsFromBase: baseSeconds withHaste: hasteFraction [
	((baseSeconds isNumber and: [ baseSeconds >= 0 ])
		and: [ hasteFraction isNumber and: [ hasteFraction > -1 ] ])
		ifFalse: [ self error: 'Invalid cooldown or skill haste' ].
	^ baseSeconds / (1 + hasteFraction)
]
