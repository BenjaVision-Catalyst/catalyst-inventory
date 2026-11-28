"
One Skill List expertise entry. A nil track or operation leaves the corresponding mapping unspecified while preserving the documented per-grade fraction.
"
Class {
	#name : 'CIGadgetExpertiseScaling',
	#superclass : 'Object',
	#instVars : [
		'reportedStat',
		'targetTrackLabel',
		'operation',
		'fractionPerGrade',
		'evidence'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIGadgetExpertiseScaling class >> stat: stat track: track operation: operation fractionPerGrade: fraction evidence: evidence [
	^ self new
		initializeStat: stat
		track: track
		operation: operation
		fractionPerGrade: fraction
		evidence: evidence
]

{ #category : 'evaluating' }
CIGadgetExpertiseScaling >> contributionAtGrade: grade [
	(grade isInteger and: [ grade >= 0 ])
		ifFalse: [ self error: 'Invalid expertise grade' ].
	^ grade * fractionPerGrade
]

{ #category : 'accessing' }
CIGadgetExpertiseScaling >> evidence [
	^ evidence copy
]

{ #category : 'initialization' }
CIGadgetExpertiseScaling >> initializeStat: stat track: track operation: stacking fractionPerGrade: fraction evidence: source [
	reportedStat := stat copy.
	targetTrackLabel := track ifNotNil: #copy.
	operation := stacking.
	fractionPerGrade := fraction.
	evidence := source copy
]

{ #category : 'accessing' }
CIGadgetExpertiseScaling >> operation [
	^ operation
]

{ #category : 'accessing' }
CIGadgetExpertiseScaling >> reportedStat [
	^ reportedStat copy
]

{ #category : 'accessing' }
CIGadgetExpertiseScaling >> targetTrackLabel [
	^ targetTrackLabel ifNotNil: #copy
]
