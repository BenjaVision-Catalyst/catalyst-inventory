"
A specialization Gadget upgrade from the workbook. Its owning perk preserves the original description, workbook reference and prerequisites. The reported stat, magnitude and unit preserve the numeric annotation. A supported target track can be recorded with review evidence while a conflict prevents applying the upgrade. Only a resolved track and magnitude affect Gadget stats.
"
Class {
	#name : 'CISpecializationGadgetUpgrade',
	#superclass : 'Object',
	#instVars : [
		'gadgetTypeIdentifier',
		'reportedStatLabel',
		'reportedMagnitude',
		'unit',
		'resolvedTrack',
		'reviewedTargetTrack',
		'reviewEvidence'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CISpecializationGadgetUpgrade class >> forGadgetType: typeIdentifier reportedStat: statLabel magnitude: magnitude unit: magnitudeUnit resolvedTrack: track [
	^ self new
		initializeForGadgetType: typeIdentifier
		reportedStat: statLabel
		magnitude: magnitude
		unit: magnitudeUnit
		resolvedTrack: track
]

{ #category : 'accessing' }
CISpecializationGadgetUpgrade >> gadgetTypeIdentifier [
	^ gadgetTypeIdentifier copy
]

{ #category : 'initialization' }
CISpecializationGadgetUpgrade >> initializeForGadgetType: typeIdentifier reportedStat: statLabel magnitude: magnitude unit: magnitudeUnit resolvedTrack: track [
	gadgetTypeIdentifier := typeIdentifier copy.
	reportedStatLabel := statLabel copy.
	reportedMagnitude := magnitude.
	unit := magnitudeUnit.
	resolvedTrack := track
]

{ #category : 'testing' }
CISpecializationGadgetUpgrade >> isResolved [
	^ resolvedTrack notNil
]

{ #category : 'accessing' }
CISpecializationGadgetUpgrade >> reportedMagnitude [
	^ reportedMagnitude
]

{ #category : 'accessing' }
CISpecializationGadgetUpgrade >> reportedStatLabel [
	^ reportedStatLabel copy
]

{ #category : 'accessing' }
CISpecializationGadgetUpgrade >> resolvedMagnitude [
	^ self isResolved ifTrue: [ reportedMagnitude ]
]

{ #category : 'accessing' }
CISpecializationGadgetUpgrade >> resolvedTrack [
	^ resolvedTrack
]

{ #category : 'accessing' }
CISpecializationGadgetUpgrade >> reviewEvidence [
	^ reviewEvidence ifNil: [ #() ] ifNotNil: [ reviewEvidence collect: #copy ]
]

{ #category : 'initialization' }
CISpecializationGadgetUpgrade >> reviewTargetTrack: track evidence: sources [
	reviewedTargetTrack := track.
	reviewEvidence := sources collect: #copy
]

{ #category : 'accessing' }
CISpecializationGadgetUpgrade >> supportedTargetTrack [
	^ reviewedTargetTrack ifNil: [ resolvedTrack ]
]

{ #category : 'accessing' }
CISpecializationGadgetUpgrade >> unit [
	^ unit
]
