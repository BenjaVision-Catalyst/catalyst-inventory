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
	| snapshot |
	snapshotFile := aPath asFileReference asAbsolute.
	snapshotFile exists ifFalse: [ ^ self ].
	snapshot := STON fromString: snapshotFile contents.
	((snapshot isArray and: [ snapshot size = 3 ])
		and: [ snapshot first = 1 and: [ snapshot second isKindOf: Dictionary ] ])
		ifFalse: [ self error: 'Invalid inventory snapshot' ].
	snapshot second
		keysAndValuesDo: [ :owner :rows | super replaceRows: rows forOwner: owner ].
	snapshot third
		ifNotNil: [ :allowances | 
			allowances
				keysAndValuesDo: [ :owner :allowance | super modStorageAllowance: allowance forOwner: owner ] ].
	^ self
]

{ #category : 'writing' }
CIInventorySnapshotStore >> replaceRows: aCollection forOwner: identity [
	^ self saveAfter: [ super replaceRows: aCollection forOwner: identity ]
]

{ #category : 'private' }
CIInventorySnapshotStore >> saveAfter: mutation [
	| previousRows previousAllowances result |
	previousRows := rowsByOwner.
	previousAllowances := modStorageAllowancesByOwner.
	rowsByOwner := previousRows copy.
	modStorageAllowancesByOwner := previousAllowances ifNotNil: #copy.
	[ result := mutation value.
	self writeSnapshot ]
		ifCurtailed: [ rowsByOwner := previousRows.
			modStorageAllowancesByOwner := previousAllowances ].
	^ result
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
				put: {1.
						rowsByOwner.
						modStorageAllowancesByOwner}
				onStream: stream ].
	File
		rename: (File encodePathString: temporary pathString)
		to: (File encodePathString: snapshotFile pathString) ]
		ensure: [ temporary ensureDelete ]
]
