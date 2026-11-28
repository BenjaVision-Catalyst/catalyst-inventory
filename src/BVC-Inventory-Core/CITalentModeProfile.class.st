Class {
	#name : 'CITalentModeProfile',
	#superclass : 'Object',
	#instVars : [
		'status',
		'parameters',
		'sources'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CITalentModeProfile class >> status: aStatus parameters: overrides sources: workbookCells [
	^ self new
		initializeStatus: aStatus
		parameters: overrides
		sources: workbookCells
]

{ #category : 'initialization' }
CITalentModeProfile >> initializeStatus: aStatus parameters: overrides sources: workbookCells [
	(#(documented conflicting unspecified) includes: aStatus)
		ifFalse: [ self error: 'Unknown talent mode status' ].
	status := aStatus.
	parameters := overrides copy.
	sources := workbookCells collect: [ :value | value ifNotNil: #copy ].
	^ self
]

{ #category : 'accessing' }
CITalentModeProfile >> isResolved [
	^ status = #documented
]

{ #category : 'accessing' }
CITalentModeProfile >> parameters [
	^ parameters copy
]

{ #category : 'accessing' }
CITalentModeProfile >> sources [
	^ sources collect: [ :value | value ifNotNil: #copy ]
]

{ #category : 'accessing' }
CITalentModeProfile >> status [
	^ status
]
