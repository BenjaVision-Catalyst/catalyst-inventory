Class {
	#name : 'CIInventoryService',
	#superclass : 'CRWorkerService',
	#instVars : [
		'readStore',
		'savedSetsByOwner',
		'savedSetsLock',
		'itemTypeCatalog'
	],
	#category : 'BVC-Inventory-Runtime',
	#package : 'BVC-Inventory-Runtime'
}

{ #category : 'configuration' }
CIInventoryService class >> configurationClass [
	^ CIInventoryConfiguration
]

{ #category : 'private' }
CIInventoryService >> applySavedSet: savedSet forOwner: identity outfit: isOutfit sets: ownerSets [
	| rows reply |
	rows := readStore
			rowsAfterEquipping: (savedSet at: 'slots')
			forOwner: identity
			outfit: isOutfit.
	reply := CIInventoryProfileGraph
			encodeReply: (CIInventoryProfileGraph
					forVerifiedUser: identity
					rows: rows
					savedSets: ownerSets
					catalog: itemTypeCatalog
					modStorageAllowance: (readStore modStorageAllowanceForOwner: identity)).
	reply ifNotNil: [ readStore replaceRows: rows forOwner: identity ].
	^ reply
]

{ #category : 'writing' }
CIInventoryService >> createSavedSetFor: identity outfit: isOutfit [
	^ savedSetsLock
		critical: [ self newSavedSetReplyFor: identity outfit: isOutfit ]
]

{ #category : 'writing' }
CIInventoryService >> deleteSavedSet: setIdentifier forVerifiedUser: identity [
	^ self
		withSavedSet: setIdentifier
		forVerifiedUser: identity
		do: [ :entry :section :sets |
			self
				replaceSavedSets: ((sets at: section) reject: [ :each | each == entry ])
				in: section
				of: sets
				forOwner: identity ]
]

{ #category : 'writing' }
CIInventoryService >> equipSavedSet: setIdentifier forVerifiedUser: identity [
	^ self
		withSavedSet: setIdentifier
		forVerifiedUser: identity
		do: [ :entry :section :sets |
			self
				applySavedSet: entry
				forOwner: identity
				outfit: section = 'apparel'
				sets: sets ]
]

{ #category : 'writing' }
CIInventoryService >> grantItem: itemIdentifier type: typeIdentifier values: values forVerifiedUser: identity [
	^ savedSetsLock
		critical: [ readStore
				grantItem: itemIdentifier
				type: typeIdentifier
				values: values
				from: itemTypeCatalog
				forOwner: identity ]
]

{ #category : 'writing' }
CIInventoryService >> modStorageAllowance: allowance forVerifiedUser: identity [
	^ savedSetsLock
		critical: [ readStore modStorageAllowance: allowance forOwner: identity ]
]

{ #category : 'private' }
CIInventoryService >> newSavedSetReplyFor: identity outfit: isOutfit [
	| section ownerSets entries name prefix number entry reply |
	section := isOutfit ifTrue: [ 'apparel' ] ifFalse: [ 'gear' ].
	ownerSets := (savedSetsByOwner at: identity ifAbsent: [ Dictionary new ]) copy.
	entries := ownerSets at: section ifAbsent: [ #() ].
	entries size >= 32 ifTrue: [ ^ nil ].
	prefix := isOutfit ifTrue: [ 'Outfit ' ] ifFalse: [ 'Gear Set ' ].
	number := 1.
	[ name := prefix , number asString.
	entries anySatisfy: [ :existing | (existing at: 'displayName') sameAs: name ] ]
		whileTrue: [ number := number + 1 ].
	entry := Dictionary new
			at: 'itemIdentifier' put: UUID new asString;
			at: 'displayName' put: name;
			at: 'slots'
				put: (readStore equippedSlotsForOwner: identity outfit: isOutfit);
			yourself.
	ownerSets at: section put: (entries copyWith: entry).
	reply := CIInventoryProfileGraph
			encodeReply: (CIInventoryProfileGraph
					forVerifiedUser: identity
					rows: (readStore allRowsForOwner: identity)
					savedSets: ownerSets
					catalog: itemTypeCatalog
					modStorageAllowance: (readStore modStorageAllowanceForOwner: identity)).
	reply ifNotNil: [ savedSetsByOwner at: identity copy put: ownerSets ].
	^ reply
]

{ #category : 'writing' }
CIInventoryService >> overwriteSavedSet: setIdentifier forVerifiedUser: identity [
	^ self
		withSavedSet: setIdentifier
		forVerifiedUser: identity
		do: [ :entry :section :sets |
			| entries |
			entries := (sets at: section) copy.
			entries
				at: (entries indexOf: entry)
				put: (entry copy
						at: 'slots'
							put: (readStore equippedSlotsForOwner: identity outfit: section = 'apparel');
						yourself).
			self
				replaceSavedSets: entries
				in: section
				of: sets
				forOwner: identity ]
]

{ #category : 'accessing' }
CIInventoryService >> profileGraphForVerifiedUser: identity [
	^ savedSetsLock
		critical: [ CIInventoryProfileGraph
				forVerifiedUser: identity
				rows: (readStore allRowsForOwner: identity)
				savedSets: (savedSetsByOwner at: identity ifAbsent: [ Dictionary new ])
				catalog: itemTypeCatalog
				modStorageAllowance: (readStore modStorageAllowanceForOwner: identity) ]
]

{ #category : 'writing' }
CIInventoryService >> provisionStarterGadgetsForVerifiedUser: identity [
	^ savedSetsLock
		critical: [ readStore provisionStarterGadgetsFrom: itemTypeCatalog forOwner: identity ]
]

{ #category : 'writing' }
CIInventoryService >> renameSavedSet: setIdentifier to: proposedName forVerifiedUser: identity [
	| name units |
	name := proposedName trimBoth.
	units := name size + (name count: [ :character | character codePoint > 65535 ]).
	((units between: 1 and: 48)
		and: [ name noneSatisfy: [ :character | #(0 10 13) includes: character codePoint ] ])
		ifFalse: [ ^ nil ].
	^ self
		withSavedSet: setIdentifier
		forVerifiedUser: identity
		do: [ :entry :section :sets |
			| entries |
			entries := sets at: section.
			(entries
				anySatisfy: [ :each | each ~~ entry and: [ (each at: 'displayName') sameAs: name ] ])
				ifTrue: [ ^ nil ].
			entries := entries copy.
			entries
				at: (entries indexOf: entry)
				put: (entry copy
						at: 'displayName' put: name;
						yourself).
			self
				replaceSavedSets: entries
				in: section
				of: sets
				forOwner: identity ]
]

{ #category : 'reading' }
CIInventoryService >> replaceReadRows: rows forOwner: identity [
	savedSetsLock critical: [ readStore replaceRows: rows forOwner: identity ]
]

{ #category : 'private' }
CIInventoryService >> replaceSavedSets: entries in: section of: sets forOwner: identity [
	| updated reply |
	updated := sets copy
			at: section put: entries;
			yourself.
	reply := CIInventoryProfileGraph
			encodeReply: (CIInventoryProfileGraph
					forVerifiedUser: identity
					rows: (readStore allRowsForOwner: identity)
					savedSets: updated
					catalog: itemTypeCatalog
					modStorageAllowance: (readStore modStorageAllowanceForOwner: identity)).
	reply ifNotNil: [ savedSetsByOwner at: identity copy put: updated ].
	^ reply
]

{ #category : 'reading' }
CIInventoryService >> rowsForVerifiedUser: anIdentifier offset: anOffset limit: aLimit [
	^ readStore
		rowsForOwner: anIdentifier
		offset: anOffset
		limit: aLimit
]

{ #category : 'lifecycle' }
CIInventoryService >> start [
	super start.
	itemTypeCatalog := CIGameItemTypes buildCatalog.
	readStore := CIInventoryReadStore new.
	savedSetsByOwner := Dictionary new.
	savedSetsLock := Semaphore forMutualExclusion
]

{ #category : 'lifecycle' }
CIInventoryService >> stop [
	savedSetsByOwner := nil.
	savedSetsLock := nil.
	readStore := nil.
	itemTypeCatalog := nil.
	super stop
]

{ #category : 'private' }
CIInventoryService >> withSavedSet: setIdentifier forVerifiedUser: identity do: action [
	^ savedSetsLock
		critical: [ | sets |
			sets := savedSetsByOwner at: identity ifAbsent: [ ^ nil ].
			#('gear' 'apparel')
				do: [ :section |
					| entry |
					entry := (sets at: section ifAbsent: [ #() ])
							detect: [ :each | (each at: 'itemIdentifier') = setIdentifier ]
							ifNone: [ nil ].
					entry
						ifNotNil: [ ^ action
								value: entry
								value: section
								value: sets ] ].
			nil ]
]
