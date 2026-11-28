Class {
	#name : 'CIWeaponDefinitionRevision',
	#superclass : 'Object',
	#instVars : [
		'definitionIdentifier',
		'revision',
		'state',
		'displayName',
		'manufacturer',
		'ammunitionName',
		'weaponDamage',
		'roundsPerMinute',
		'magazineCapacity',
		'optimalRangeMetres',
		'reloadSeconds',
		'accuracy',
		'stability',
		'falloffPoints',
		'socketIdentifiers',
		'talentIdentifiers',
		'talentDefinitions',
		'presentation',
		'provenance'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIWeaponDefinitionRevision class >> id: identifier revision: number [
	^ self new initializeId: identifier revision: number
]

{ #category : 'editing' }
CIWeaponDefinitionRevision class >> readDraftFrom: aFile [
	| draft |
	draft := STON fromString: aFile asFileReference contents.
	((draft isKindOf: self) and: [ draft isDraft ])
		ifFalse: [ self error: 'The file does not contain a weapon draft' ].
	^ draft
]

{ #category : 'accessing' }
CIWeaponDefinitionRevision >> accuracy [
	^ accuracy
]

{ #category : 'accessing' }
CIWeaponDefinitionRevision >> accuracy: value [
	self requireDraft.
	accuracy := value
]

{ #category : 'accessing' }
CIWeaponDefinitionRevision >> ammunitionName [
	^ ammunitionName copy
]

{ #category : 'accessing' }
CIWeaponDefinitionRevision >> ammunitionName: value [
	self requireDraft.
	ammunitionName := value copy
]

{ #category : 'publishing' }
CIWeaponDefinitionRevision >> asBaselineIn: catalog [
	^ self snapshotAs: #baseline in: catalog
]

{ #category : 'gt' }
CIWeaponDefinitionRevision >> asGtMagritteViewModel [
	| model |
	model := super asGtMagritteViewModel.
	self isDraft
		ifTrue: [ model addAction: (Smalltalk at: #GtMagritteBuilderUtility) newSaveButton ].
	^ model
]

{ #category : 'publishing' }
CIWeaponDefinitionRevision >> asReleaseIn: catalog [
	^ self snapshotAs: #released in: catalog
]

{ #category : 'integration' }
CIWeaponDefinitionRevision >> asWeaponType [
	| type |
	type := CIWeaponType
			id: self definitionIdentifier
			name: self displayName
			slot: self slotIdentifier
			core: {{'Damage per hit'.
						weaponDamage}.
					{'Fire rate'.
						roundsPerMinute asString , ' RPM'}.
					{'Magazine'.
						magazineCapacity asString , ' rounds'}.
					{'Optimal range'.
						optimalRangeMetres}.
					{'Reload time'.
						reloadSeconds asString , ' s'}}
			handling: {{'Accuracy'.
						accuracy}.
					{'Stability'.
						stability}}
			sockets: self socketIdentifiers.
	type
		inspectorIdentity: {'inspectorManufacturer' -> self manufacturer.
				'inspectorCategory' -> 'Carbine'.
				'inspectorConsumable' -> self ammunitionName.
				'inspectorConsumableIcon' -> 'cartridge'} asDictionary.
	self falloffPoints ifNotEmpty: [ :points | type damageFalloff: points ].
	^ type
]

{ #category : 'accessing' }
CIWeaponDefinitionRevision >> definitionIdentifier [
	^ definitionIdentifier copy
]

{ #category : 'accessing' }
CIWeaponDefinitionRevision >> displayName [
	^ displayName copy
]

{ #category : 'accessing' }
CIWeaponDefinitionRevision >> displayName: value [
	self requireDraft.
	displayName := value copy
]

{ #category : 'editing' }
CIWeaponDefinitionRevision >> draftForNextRevision [
	^ self copy initializeNextDraft
]

{ #category : 'accessing' }
CIWeaponDefinitionRevision >> falloffPoints [
	^ falloffPoints
		ifNil: [ #() ]
		ifNotNil: [ falloffPoints collect: #copy as: Array ]
]

{ #category : 'accessing' }
CIWeaponDefinitionRevision >> falloffPoints: values [
	self requireDraft.
	falloffPoints := values collect: #copy as: Array
]

{ #category : 'private' }
CIWeaponDefinitionRevision >> freezeAs: aState talents: talents [
	self requireDraft.
	presentation := presentation immutableCopy.
	talentDefinitions := talents collect: #copy.
	state := aState.
	^ self
]

{ #category : 'gt' }
CIWeaponDefinitionRevision >> gtGenerationPolicyFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Generation fields';
		priority: 22;
		items: [ self asWeaponType inventoryItemDescription children ];
		column: 'Field' text: #label;
		column: 'Required' text: #isRequired
]

{ #category : 'gt' }
CIWeaponDefinitionRevision >> gtOpenDraftFor: anAction [
	<gtAction>
	self isDraft ifTrue: [ ^ anAction noAction ].
	^ anAction button
		label: 'Open next revision draft';
		action: [ :button | button phlow spawnObject: self draftForNextRevision ]
]

{ #category : 'gt' }
CIWeaponDefinitionRevision >> gtRelatedObjectsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Definition details';
		priority: 20;
		items: [ {'UE presentation' -> presentation.
				'Falloff (metres / percent)' -> self falloffPoints.
				'Sockets' -> self socketIdentifiers.
				'Talent IDs' -> self talentIdentifiers.
				'Talent definitions' -> self talentDefinitions.
				'Sources' -> self provenance} ];
		column: 'Field' text: #key;
		column: 'Value' text: [ :row | row value printString ];
		send: #value
]

{ #category : 'gt' }
CIWeaponDefinitionRevision >> hasMagritteDescription [
	^ true
]

{ #category : 'initialization' }
CIWeaponDefinitionRevision >> initializeId: identifier revision: number [
	(identifier isString
		and: [ identifier notEmpty and: [ number isInteger and: [ number > 0 ] ] ])
		ifFalse: [ self error: 'Invalid weapon revision identity' ].
	definitionIdentifier := identifier copy.
	revision := number.
	state := #draft.
	presentation := CIWeaponPresentation new.
	^ self
]

{ #category : 'private' }
CIWeaponDefinitionRevision >> initializeNextDraft [
	self isDraft ifTrue: [ self error: 'This weapon revision is already a draft' ].
	revision := revision + 1.
	state := #draft.
	presentation := presentation editableCopy.
	^ self
]

{ #category : 'accessing' }
CIWeaponDefinitionRevision >> isDraft [
	^ state = #draft
]

{ #category : 'accessing' }
CIWeaponDefinitionRevision >> magazineCapacity [
	^ magazineCapacity
]

{ #category : 'accessing' }
CIWeaponDefinitionRevision >> magazineCapacity: value [
	self requireDraft.
	magazineCapacity := value
]

{ #category : 'descriptions' }
CIWeaponDefinitionRevision >> magritteDescription [
	| editableFields |
	editableFields := {MAStringDescription new
				accessor: #displayName;
				label: 'Name';
				beRequired;
				yourself.
			MAStringDescription new
				accessor: #manufacturer;
				label: 'Manufacturer';
				beRequired;
				yourself.
			MAStringDescription new
				accessor: #ammunitionName;
				label: 'Ammunition name';
				beRequired;
				yourself.
			self positiveNumberDescriptionFor: #weaponDamage label: 'Base damage per hit'.
			self
				positiveNumberDescriptionFor: #roundsPerMinute
				label: 'Fire rate (rounds/min)'.
			MANumberDescription new
				accessor: #magazineCapacity;
				label: 'Magazine capacity (rounds)';
				beRequired;
				min: 1;
				beInteger;
				yourself.
			MANumberDescription new
				accessor: #optimalRangeMetres;
				label: 'Optimal range (m)';
				beRequired;
				min: 1;
				beInteger;
				yourself.
			self positiveNumberDescriptionFor: #reloadSeconds label: 'Reload time (s)'.
			MANumberDescription new
				accessor: #accuracy;
				label: 'Accuracy (0–100)';
				beRequired;
				min: 0;
				max: 100;
				yourself.
			MANumberDescription new
				accessor: #stability;
				label: 'Stability (0–100)';
				beRequired;
				min: 0;
				max: 100;
				yourself.
			MAMemoDescription new
				accessor: #provenanceText;
				label: 'Balance sources';
				yourself.
			MAMemoDescription new
				accessor: #socketIdentifiersText;
				label: 'Sockets (one ID per line)';
				yourself.
			MAMemoDescription new
				accessor: #talentIdentifiersText;
				label: 'Talent pool (one ID per line)';
				yourself}.
	self isDraft ifFalse: [ editableFields do: #beReadOnly ].
	^ MAContainer
		withAll: {MAStringDescription new
					accessor: #definitionIdentifier;
					label: 'Definition ID';
					beReadOnly;
					yourself.
				MANumberDescription new
					accessor: #revision;
					label: 'Revision';
					beReadOnly;
					yourself.
				MAStringDescription new
					accessor: #slotIdentifier;
					label: 'Slot';
					beReadOnly;
					yourself.
				MAStringDescription new
					accessor: #stateLabel;
					label: 'State';
					beReadOnly;
					yourself} , editableFields
]

{ #category : 'accessing' }
CIWeaponDefinitionRevision >> manufacturer [
	^ manufacturer copy
]

{ #category : 'accessing' }
CIWeaponDefinitionRevision >> manufacturer: value [
	self requireDraft.
	manufacturer := value copy
]

{ #category : 'accessing' }
CIWeaponDefinitionRevision >> optimalRangeMetres [
	^ optimalRangeMetres
]

{ #category : 'accessing' }
CIWeaponDefinitionRevision >> optimalRangeMetres: value [
	self requireDraft.
	optimalRangeMetres := value
]

{ #category : 'descriptions' }
CIWeaponDefinitionRevision >> positiveNumberDescriptionFor: selector label: aLabel [
	^ MANumberDescription new
		accessor: selector;
		label: aLabel;
		beRequired;
		addCondition: [ :value | value > 0 ] labelled: 'Must be greater than zero';
		yourself
]

{ #category : 'accessing' }
CIWeaponDefinitionRevision >> presentation [
	^ presentation
]

{ #category : 'accessing' }
CIWeaponDefinitionRevision >> provenance [
	^ provenance ifNil: [ #() ] ifNotNil: [ provenance collect: #copy as: Array ]
]

{ #category : 'accessing' }
CIWeaponDefinitionRevision >> provenance: values [
	self requireDraft.
	provenance := values collect: #copy as: Array
]

{ #category : 'accessing' }
CIWeaponDefinitionRevision >> provenanceText [
	^ String cr join: self provenance
]

{ #category : 'descriptions' }
CIWeaponDefinitionRevision >> provenanceText: text [
	self provenance: (text lines reject: [ :line | line trimBoth isEmpty ])
]

{ #category : 'accessing' }
CIWeaponDefinitionRevision >> reloadSeconds [
	^ reloadSeconds
]

{ #category : 'accessing' }
CIWeaponDefinitionRevision >> reloadSeconds: value [
	self requireDraft.
	reloadSeconds := value
]

{ #category : 'private' }
CIWeaponDefinitionRevision >> requireDraft [
	self isDraft
		ifFalse: [ self error: 'Open a new draft to edit this weapon revision' ]
]

{ #category : 'accessing' }
CIWeaponDefinitionRevision >> revision [
	^ revision
]

{ #category : 'generation' }
CIWeaponDefinitionRevision >> rollTalentUsing: randomSample [
	| pool |
	pool := self talentIdentifiers.
	pool isEmpty ifTrue: [ ^ nil ].
	pool size = 1 ifTrue: [ ^ pool first ].
	^ pool at: (randomSample value * pool size) floor + 1
]

{ #category : 'accessing' }
CIWeaponDefinitionRevision >> roundsPerMinute [
	^ roundsPerMinute
]

{ #category : 'accessing' }
CIWeaponDefinitionRevision >> roundsPerMinute: value [
	self requireDraft.
	roundsPerMinute := value
]

{ #category : 'accessing' }
CIWeaponDefinitionRevision >> slotIdentifier [
	^ 'RangedWeapon'
]

{ #category : 'publishing' }
CIWeaponDefinitionRevision >> snapshotAs: aState in: catalog [
	| snapshot |
	self requireDraft.
	self validateBalance.
	aState = #released
		ifTrue: [ presentation missingBindings
				ifNotEmpty: [ :missing | self error: 'Missing required UE bindings: ' , (', ' join: missing) ] ].
	snapshot := self copy.
	^ snapshot
		freezeAs: aState
		talents: (self talentIdentifiers collect: [ :id | catalog talentAt: id ])
]

{ #category : 'accessing' }
CIWeaponDefinitionRevision >> socketIdentifiers [
	^ socketIdentifiers
		ifNil: [ #() ]
		ifNotNil: [ socketIdentifiers collect: #copy as: Array ]
]

{ #category : 'accessing' }
CIWeaponDefinitionRevision >> socketIdentifiers: values [
	self requireDraft.
	socketIdentifiers := values collect: #copy as: Array
]

{ #category : 'descriptions' }
CIWeaponDefinitionRevision >> socketIdentifiersText [
	^ String cr join: self socketIdentifiers
]

{ #category : 'descriptions' }
CIWeaponDefinitionRevision >> socketIdentifiersText: text [
	self socketIdentifiers: ((text lines collect: #trimBoth) reject: #isEmpty)
]

{ #category : 'accessing' }
CIWeaponDefinitionRevision >> stability [
	^ stability
]

{ #category : 'accessing' }
CIWeaponDefinitionRevision >> stability: value [
	self requireDraft.
	stability := value
]

{ #category : 'accessing' }
CIWeaponDefinitionRevision >> state [
	^ state
]

{ #category : 'accessing' }
CIWeaponDefinitionRevision >> stateLabel [
	^ state asString
]

{ #category : 'accessing' }
CIWeaponDefinitionRevision >> talentAt: identifier [
	^ self talentDefinitions
		detect: [ :talent | talent id = identifier ]
		ifNone: [ nil ]
]

{ #category : 'accessing' }
CIWeaponDefinitionRevision >> talentDefinitions [
	^ talentDefinitions
		ifNil: [ #() ]
		ifNotNil: [ talentDefinitions collect: #copy ]
]

{ #category : 'accessing' }
CIWeaponDefinitionRevision >> talentIdentifiers [
	^ talentIdentifiers
		ifNil: [ #() ]
		ifNotNil: [ talentIdentifiers collect: #copy as: Array ]
]

{ #category : 'accessing' }
CIWeaponDefinitionRevision >> talentIdentifiers: values [
	self requireDraft.
	talentIdentifiers := values collect: #copy as: Array
]

{ #category : 'descriptions' }
CIWeaponDefinitionRevision >> talentIdentifiersText [
	^ String cr join: self talentIdentifiers
]

{ #category : 'descriptions' }
CIWeaponDefinitionRevision >> talentIdentifiersText: text [
	self talentIdentifiers: ((text lines collect: #trimBoth) reject: #isEmpty)
]

{ #category : 'validation' }
CIWeaponDefinitionRevision >> validateBalance [
	({displayName.
		manufacturer.
		ammunitionName}
		allSatisfy: [ :value | value isString and: [ value notEmpty ] ])
		ifFalse: [ self error: 'Weapon name, manufacturer and ammunition name are required' ].
	({weaponDamage.
		roundsPerMinute.
		reloadSeconds} allSatisfy: [ :value | value isNumber and: [ value > 0 ] ])
		ifFalse: [ self error: 'Weapon damage, fire rate and reload time must be positive' ].
	({magazineCapacity.
		optimalRangeMetres}
		allSatisfy: [ :value | value isInteger and: [ value > 0 ] ])
		ifFalse: [ self error: 'Magazine and range must be positive integers' ].
	({accuracy.
		stability}
		allSatisfy: [ :value | value isNumber and: [ value between: 0 and: 100 ] ])
		ifFalse: [ self error: 'Handling values must be between zero and 100' ].
	self provenance ifEmpty: [ self error: 'Weapon balance requires provenance' ].
	self asWeaponType
]

{ #category : 'accessing' }
CIWeaponDefinitionRevision >> weaponDamage [
	^ weaponDamage
]

{ #category : 'accessing' }
CIWeaponDefinitionRevision >> weaponDamage: value [
	self requireDraft.
	weaponDamage := value
]

{ #category : 'editing' }
CIWeaponDefinitionRevision >> writeDraftTo: aFile [
	| path temporary |
	self requireDraft.
	path := aFile asFileReference.
	temporary := path parent / (path basename , '.' , UUID new asString , '.tmp').
	[ temporary writeStreamDo: [ :stream | STON put: self onStream: stream ].
	File
		rename: (File encodePathString: temporary pathString)
		to: (File encodePathString: path pathString) ]
		ensure: [ temporary ensureDelete ]
]
