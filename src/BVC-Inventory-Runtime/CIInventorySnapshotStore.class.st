Class {
	#name : 'CIInventorySnapshotStore',
	#superclass : 'CIInventoryReadStore',
	#instVars : [
		'snapshotFile'
	],
	#category : 'BVC-Inventory-Runtime',
	#package : 'BVC-Inventory-Runtime'
}

{ #category : 'instance creation' }
CIInventorySnapshotStore class >> at: aPath [
	^ self new openSnapshotAt: aPath
]

{ #category : 'writing' }
CIInventorySnapshotStore >> modStorageAllowance: allowance forOwner: identity [
	^ self saveAfter: [ super modStorageAllowance: allowance forOwner: identity ]
]

{ #category : 'initialization' }
CIInventorySnapshotStore >> openSnapshotAt: aPath [
	| snapshot validVersion |
	snapshotFile := aPath asFileReference asAbsolute.
	snapshotFile exists ifFalse: [ ^ self ].
	snapshot := STON fromString: snapshotFile contents.
	validVersion := snapshot isArray
			and: [ (snapshot size = 3 and: [ snapshot first = 1 ])
					or: [ snapshot size = 4 and: [ snapshot first = 2 ] ] ].
	(validVersion and: [ snapshot second isKindOf: Dictionary ])
		ifFalse: [ self error: 'Invalid inventory snapshot' ].
	snapshot second
		keysAndValuesDo: [ :owner :rows | super replaceRows: rows forOwner: owner ].
	snapshot third
		ifNotNil: [ :allowances | 
			allowances
				keysAndValuesDo: [ :owner :allowance | super modStorageAllowance: allowance forOwner: owner ] ].
	snapshot size = 4
		ifTrue: [ snapshot fourth
				ifNotNil: [ :selections | 
					selections
						keysAndValuesDo: [ :owner :selection | super specialization: selection forOwner: owner ] ] ].
	^ self
]

{ #category : 'writing' }
CIInventorySnapshotStore >> replaceRows: aCollection forOwner: identity [
	^ self saveAfter: [ super replaceRows: aCollection forOwner: identity ]
]

{ #category : 'private' }
CIInventorySnapshotStore >> saveAfter: mutation [
	| previousRows previousAllowances previousSpecializations result |
	previousRows := rowsByOwner.
	previousAllowances := modStorageAllowancesByOwner.
	previousSpecializations := specializationsByOwner.
	rowsByOwner := previousRows copy.
	modStorageAllowancesByOwner := previousAllowances ifNotNil: #copy.
	specializationsByOwner := previousSpecializations ifNotNil: #copy.
	[ result := mutation value.
	self writeSnapshot ]
		ifCurtailed: [ rowsByOwner := previousRows.
			modStorageAllowancesByOwner := previousAllowances.
			specializationsByOwner := previousSpecializations ].
	^ result
]

{ #category : 'writing' }
CIInventorySnapshotStore >> specialization: selection forOwner: identity [
	^ self saveAfter: [ super specialization: selection forOwner: identity ]
]

{ #category : 'private' }
CIInventorySnapshotStore >> writeSnapshot [
	| temporary |
	snapshotFile parent ensureCreateDirectory.
	temporary := snapshotFile parent
			/ (snapshotFile basename , '.' , UUID new asString , '.tmp').
	[ temporary
		writeStreamDo: [ :stream | 
			STON
				put: {2.
						rowsByOwner.
						modStorageAllowancesByOwner.
						specializationsByOwner}
				onStream: stream ].
	File
		rename: (File encodePathString: temporary pathString)
		to: (File encodePathString: snapshotFile pathString) ]
		ensure: [ temporary ensureDelete ]
]
