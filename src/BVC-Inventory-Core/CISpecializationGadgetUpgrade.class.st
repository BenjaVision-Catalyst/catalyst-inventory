"
One specialization gadget upgrade from the workbook. The owning perk preserves its description, evidence and prerequisites. The reported magnitude and stat label come from the numeric annotation. A missing resolved track means the prose and numeric annotation conflict.
"
Class {
	#name : 'CISpecializationGadgetUpgrade',
	#superclass : 'Object',
	#instVars : [
		'gadgetTypeIdentifier',
		'reportedStatLabel',
		'reportedMagnitude',
		'unit',
		'resolvedTrack'
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
CISpecializationGadgetUpgrade >> resolvedTrack [
	^ resolvedTrack
]

{ #category : 'accessing' }
CISpecializationGadgetUpgrade >> unit [
	^ unit
]
