Class {
	#name : 'CIWeaponType',
	#superclass : 'CIToolType',
	#instVars : [
		'slotIdentifier',
		'coreStats',
		'handlingStats',
		'socketIdentifiers',
		'damageFalloff'
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

{ #category : 'initialization' }
CIWeaponType >> damageFalloff: points [
	| lastDistance lastDamage |
	lastDistance := -1.
	lastDamage := 100.
	(points size >= 2 and: [ points first = #(0 100) ])
		ifFalse: [ self error: 'Falloff must start at full damage at zero range' ].
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

{ #category : 'initialization' }
CIWeaponType >> initializeSlot: slot core: core handling: handling sockets: sockets [
	slotIdentifier := slot copy.
	coreStats := core asArray copy.
	handlingStats := handling asArray copy.
	socketIdentifiers := sockets asArray copy.
	^ self
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
	rows := {{'Damage per hit'.
				damage printShowingDecimalPlaces: 1}} , coreStats allButFirst.
	^ {{'stats'.
			'Core stats'.
			rows}.
		{'primary'.
			'Core attribute'.
			{{roll displayName.
					modifier}}}.
		{'meters'.
			'Weapon handling'.
			handlingStats}.
		{'falloff'.
			'Damage falloff'.
			(damageFalloff ifNil: [ #() ])
				collect: [ :point |
					{point first asString.
						point second.
						point first} ]}.
		{'slots'.
			'Attachments'.
			item modSlots
				collect: [ :mod |
					{mod slotIdentifier capitalized.
						mod equippedModIdentifier ifNil: [ 'Empty' ]} ]}}
]

{ #category : 'instance creation' }
CIWeaponType >> inventoryItem: id values: values [
	| item |
	self validateInventoryItemValues: values.
	item := CIInventoryWeaponToolSummary
			item: id
			fromDefinition: self
			metadata: (Dictionary new
					at: #presentationKind put: 'weapon';
					at: #inventoryTypeCount put: 1;
					at: #comparisonStats
						put: {CIInventoryComparisonStat
									identifier: 'weaponDamage'
									label: 'Weapon damage'
									value: (values at: 'weaponDamage')};
					at: #modSlots
						put: (socketIdentifiers
								collect: [ :socket |
									CIInventoryModSlotSummary
										slot: socket
										equippedMod: (values at: socket ifAbsent: [ nil ]) ]);
					yourself).
	item availableEquipmentSlotIdentifiers: {slotIdentifier}.
	^ item
]

{ #category : 'descriptions' }
CIWeaponType >> inventoryItemDescription [
	^ MAContainer
		withAll: {MANumberDescription new
					accessor: (MADictionaryAccessor key: 'weaponDamage');
					label: 'Weapon damage';
					min: 0.0;
					max: 0.15;
					beRequired;
					yourself}
				, (socketIdentifiers
						collect: [ :socket |
							MAStringDescription new
								accessor: (MADictionaryAccessor key: socket);
								label: socket;
								yourself ])
]
