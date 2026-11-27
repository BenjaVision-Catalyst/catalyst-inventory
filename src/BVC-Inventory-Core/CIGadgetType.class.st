Class {
	#name : 'CIGadgetType',
	#superclass : 'CIItemType',
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'accessing' }
CIGadgetType >> baseStats [
	self subclassResponsibility
]

{ #category : 'accessing' }
CIGadgetType >> statsAtUtilityTier: aTier [
	(aTier isInteger and: [ aTier >= 0 ])
		ifFalse: [ self error: 'Invalid Utility Tier' ].
	^ self baseStats
]
