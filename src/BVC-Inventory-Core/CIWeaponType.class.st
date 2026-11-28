Class {
	#name : 'CIWeaponType',
	#superclass : 'CIToolType',
	#instVars : [
		'slotIdentifier',
		'coreStats',
		'handlingStats',
		'socketIdentifiers',
		'damageFalloff',
		'classGenerationRule',
		'fixedAttributes',
		'minorAttributeRule'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIWeaponType class >> id: id name: name slot: slot core: core handling: handling sockets: sockets [
	^ (self
		id: id
		name: name
		icon: nil)
		initializeSlot: slot
		core: core
		handling: handling
		sockets: sockets
]

{ #category : 'accessing' }
CIWeaponType >> baseMagazineCapacity [
	| row value |
	row := coreStats detect: [ :stat | stat first = 'Magazine' ] ifNone: [ ^ nil ].
	value := row second.
	value isNumber ifTrue: [ ^ value ].
	((value isString and: [ value endsWith: ' rounds' ])
		and: [ (value allButLast: ' rounds' size) notEmpty
				and: [ (value allButLast: ' rounds' size) allSatisfy: #isDigit ] ])
		ifFalse: [ ^ nil ].
	^ (value allButLast: ' rounds' size) asNumber
]

{ #category : 'accessing' }
CIWeaponType >> classGenerationRule [
	^ classGenerationRule
]

{ #category : 'initialization' }
CIWeaponType >> classGenerationRule: rule [
	classGenerationRule := rule
]

{ #category : 'inventory' }
CIWeaponType >> comparisonStatsForValues: values [
	| stats |
	stats := OrderedCollection
			with: (CIInventoryComparisonStat
					identifier: 'weaponDamage'
					label: self weaponDamageField label
					value: (values at: 'weaponDamage')).
	classGenerationRule
		ifNotNil: [ classGenerationRule statIdentifier
				ifNotNil: [ :key | 
					values
						at: key
						ifPresent: [ :value | 
							stats
								add: (CIInventoryComparisonStat
										identifier: key
										label: classGenerationRule statLabel
										value: value) ] ] ].
	self fixedAttributes
		do: [ :attribute | 
			attribute statIdentifier = 'weaponDamage'
				ifFalse: [ stats
						add: (CIInventoryComparisonStat
								identifier: attribute statIdentifier
								label: attribute label
								value: attribute magnitude) ] ].
	values
		at: 'minorAttributeIdentifier'
		ifPresent: [ :id | 
			stats
				add: (CIInventoryComparisonStat
						identifier: id
						label: (minorAttributeRule attributeAt: id) label
						value: (values at: 'minorAttributeValue')) ].
	^ stats asArray
]

{ #category : 'initialization' }
CIWeaponType >> damageFalloff: points [
	| lastDistance lastDamage |
	lastDistance := self optimalRangeMetres.
	(lastDistance notNil
		and: [ lastDistance isInteger and: [ lastDistance > 0 and: [ points notEmpty ] ] ])
		ifFalse: [ self error: 'Falloff requires a positive optimal range and at least one point' ].
	lastDamage := 100.
	points
		do: [ :point |
			(point size = 2
				and: [ point first isInteger
						and: [ point first > lastDistance
								and: [ point second isInteger and: [ point second between: 0 and: lastDamage ] ] ] ])
				ifFalse: [ self error: 'Invalid damage falloff point' ].
			lastDistance := point first.
			lastDamage := point second ].
	damageFalloff := points collect: #copy as: Array
]

{ #category : 'accessing' }
CIWeaponType >> damageFalloffPolicy [
	damageFalloff ifNil: [ ^ nil ].
	^ damageFalloff = #none ifTrue: [ #none ] ifFalse: [ #curve ]
]

{ #category : 'initialization' }
CIWeaponType >> disableDamageFalloff [
	damageFalloff := #none
]

{ #category : 'accessing' }
CIWeaponType >> fixedAttributes [
	^ fixedAttributes ifNil: [ #() ] ifNotNil: #copy
]

{ #category : 'initialization' }
CIWeaponType >> fixedAttributes: rule [
	fixedAttributes := rule asArray copy
]

{ #category : 'accessing' }
CIWeaponType >> fixedAttributesWhileWeaponInUse: active [
	^ self fixedAttributes
		select: [ :attribute | attribute appliesWhileWeaponInUse: active ]
]

{ #category : 'initialization' }
CIWeaponType >> initializeSlot: slot core: core handling: handling sockets: sockets [
	slotIdentifier := slot copy.
	coreStats := core asArray copy.
	handlingStats := handling asArray copy.
	socketIdentifiers := sockets asArray copy.
	^ self
]

{ #category : 'descriptions' }
CIWeaponType >> inspectorFalloffRows [
	| points |
	self damageFalloffPolicy = #curve ifFalse: [ ^ #() ].
	points := {#(0 100).
			{self optimalRangeMetres.
				100}} , damageFalloff.
	^ points
		collect: [ :point | 
			{point first asString.
				point second.
				point first} ]
]

{ #category : 'descriptions' }
CIWeaponType >> inspectorSectionsAtUtilityTier: tier item: item [
	| roll modifier damage rows |
	(item isKindOf: CIInventoryWeaponToolSummary) ifFalse: [ ^ #() ].
	roll := item comparisonStats
			detect: [ :stat | stat statIdentifier = 'weaponDamage' ]
			ifNone: [ ^ #() ].
	modifier := '+' , (roll value * 100 printShowingDecimalPlaces: 2) , '%'.
	damage := coreStats first second * (1 + roll value).
	rows := {{'Damage'.
				damage printShowingDecimalPlaces: 1}}
			, (coreStats allButFirst
					collect: [ :stat |
						stat first = 'Optimal range'
							ifTrue: [ {'Optimal Range'.
									stat second asString , ' m'} ]
							ifFalse: [ stat ] ]).
	^ {{'stats'.
			'Core Stats'.
			rows}.
		{'primary'.
			'Core Attribute'.
			{{roll displayName.
					modifier.
					roll value.
					self weaponDamageMaximum.
					'offensive'}}}.
		{'meters'.
			'Weapon Handling'.
			handlingStats}.
		{'falloff'.
			'Damage Falloff'.
			self inspectorFalloffRows}.
		{'slots'.
			'Attachments'.
			item modSlots
				collect: [ :mod |
					{mod slotIdentifier capitalized.
						mod equippedModIdentifier ifNil: [ 'Empty' ]} ]}}
]

{ #category : 'instance creation' }
CIWeaponType >> inventoryItem: id values: values [
	^ self
		inventoryItem: id
		values: values
		talentIdentifier: nil
]

{ #category : 'spawning' }
CIWeaponType >> inventoryItem: id values: values talentIdentifier: aTalentIdentifier [
	| item |
	self validateInventoryItemValues: values.
	item := CIInventoryWeaponToolSummary
			item: id
			fromDefinition: self
			metadata: (Dictionary new
					at: #presentationKind put: 'weapon';
					at: #inventoryTypeCount put: 1;
					at: #talentIdentifier put: aTalentIdentifier;
					at: #talentIdentifiers
						put: (aTalentIdentifier ifNil: [ #() ] ifNotNil: [ {aTalentIdentifier} ]);
					at: #comparisonStats put: (self comparisonStatsForValues: values);
					at: #modSlots
						put: (socketIdentifiers
								collect: [ :socket | 
									CIInventoryModSlotSummary
										slot: socket
										equippedMod: (values at: socket ifAbsent: [ nil ]) ]);
					yourself).
	item
		availableEquipmentSlotIdentifiers: (slotIdentifier ifNil: [ #() ] ifNotNil: [ {slotIdentifier} ]).
	^ item
]

{ #category : 'descriptions' }
CIWeaponType >> inventoryItemDescription [
	| fields maximum |
	fields := OrderedCollection with: self weaponDamageField.
	classGenerationRule
		ifNotNil: [ maximum := classGenerationRule maximumFor: #standardMaximum.
			maximum
				ifNotNil: [ fields
						add: (MANumberDescription new
								accessor: (MADictionaryAccessor key: classGenerationRule statIdentifier);
								label: classGenerationRule statLabel;
								max: maximum;
								yourself) ] ].
	minorAttributeRule
		ifNotNil: [ fields
				add: (MAStringDescription new
						accessor: (MADictionaryAccessor key: 'minorAttributeIdentifier');
						label: 'Minor attribute';
						yourself);
				add: (MANumberDescription new
						accessor: (MADictionaryAccessor key: 'minorAttributeValue');
						label: 'Minor attribute value';
						yourself) ].
	socketIdentifiers
		do: [ :socket | 
			fields
				add: (MAStringDescription new
						accessor: (MADictionaryAccessor key: socket);
						label: socket;
						yourself) ].
	^ MAContainer withAll: fields
]

{ #category : 'accessing' }
CIWeaponType >> minorAttributeRule [
	^ minorAttributeRule
]

{ #category : 'initialization' }
CIWeaponType >> minorAttributeRule: rule [
	minorAttributeRule := rule
]

{ #category : 'private' }
CIWeaponType >> optimalRangeMetres [
	^ (coreStats detect: [ :stat | stat first = 'Optimal range' ] ifNone: [ ^ nil ])
		second
]

{ #category : 'accessing' }
CIWeaponType >> talentEligibility [
	^ #weapon
]

{ #category : 'validation' }
CIWeaponType >> validateInventoryItemValues: values [
	| hasIdentifier hasMagnitude |
	super validateInventoryItemValues: values.
	minorAttributeRule ifNil: [ ^ self ].
	hasIdentifier := values includesKey: 'minorAttributeIdentifier'.
	hasMagnitude := values includesKey: 'minorAttributeValue'.
	hasIdentifier = hasMagnitude
		ifFalse: [ self error: 'An exotic minor attribute requires both its identifier and value' ].
	hasIdentifier
		ifTrue: [ minorAttributeRule
				validateIdentifier: (values at: 'minorAttributeIdentifier')
				magnitude: (values at: 'minorAttributeValue') ]
]

{ #category : 'inventory' }
CIWeaponType >> weaponDamageField [
	| fixedDamage minimum maximum label |
	fixedDamage := self fixedAttributes
			detect: [ :each | each statIdentifier = 'weaponDamage' ]
			ifNone: [ nil ].
	minimum := fixedDamage ifNil: [ 0.0 ] ifNotNil: #magnitude.
	maximum := fixedDamage ifNil: [ self weaponDamageMaximum ] ifNotNil: #magnitude.
	label := fixedDamage ifNil: [ 'Weapon damage' ] ifNotNil: #label.
	^ MANumberDescription new
		accessor: (MADictionaryAccessor key: 'weaponDamage');
		label: label;
		min: minimum;
		max: maximum;
		beRequired;
		yourself
]

{ #category : 'private' }
CIWeaponType >> weaponDamageMaximum [
	^ 0.15
]
