Class {
	#name : 'BVCGearPlaystyleCatalogue',
	#superclass : 'Object',
	#category : 'BVC-Inventory-GearSimulation',
	#package : 'BVC-Inventory-GearSimulation'
}

{ #category : 'catalogue' }
BVCGearPlaystyleCatalogue >> add: magnitude to: stat [
	^ self
		add: magnitude
		to: stat
		against: nil
]

{ #category : 'catalogue' }
BVCGearPlaystyleCatalogue >> add: magnitude to: stat against: target [
	^ BVCGearModifier
		stat: stat
		operation: #add
		magnitude: magnitude
		targetClass: target
		duration: #whileEquipped
]

{ #category : 'catalogue' }
BVCGearPlaystyleCatalogue >> containmentFamily [
	^ BVCGearFamily
		id: #containment
		manufacturer: 'Sable Instruments'
		tiers: {self
					tier: 2
					adds: 1
					to: #controlSeconds
					trigger: nil
					consumeOn: nil.
				self
					tier: 3
					adds: 1
					to: #controlSeconds
					trigger: nil
					consumeOn: nil.
				self
					tier: 4
					adds: 2
					to: #controlSeconds
					trigger: #interrupt
					consumeOn: #deploySlow}
]

{ #category : 'catalogue' }
BVCGearPlaystyleCatalogue >> containmentPieces [
	^ {self
			gear: #containmentHead
			named: 'Containment Helmet'
			icon: 'Helmet'
			slot: #head
			family: #containment
			modifiers: {self add: 8 to: #armour.
					self add: 1 / 10 to: #criticalChance}.
		self
			gear: #containmentEyes
			named: 'Containment Goggles'
			icon: 'Mask'
			slot: #eyes
			family: #containment
			modifiers: {self add: 1 to: #controlSeconds.
					self add: 1 to: #suppression}.
		self
			gear: #containmentChest
			named: 'Containment Vest'
			icon: 'Vest'
			slot: #chest
			family: #containment
			modifiers: {self add: 16 to: #armour.
					self add: 1 to: #controlSeconds}.
		self
			gear: #containmentFeet
			named: 'Containment Boots'
			icon: 'Boots'
			slot: #feet
			family: #containment
			modifiers: {self add: 8 to: #armour.
					self add: 1 to: #suppression}}
]

{ #category : 'catalogue' }
BVCGearPlaystyleCatalogue >> familyFor: familyId [
	^ self perform: (familyId asString , 'Family') asSymbol
]

{ #category : 'catalogue' }
BVCGearPlaystyleCatalogue >> gear: id named: name icon: icon slot: slot family: familyId modifiers: modifiers [
	^ (BVCGearDefinition
		id: id
		name: name
		icon: 'gearIcon_' , icon , '.png'
		type: ((#(head chest feet) includes: slot)
				ifTrue: [ #armour ]
				ifFalse: [ #accessory ])
		slot: slot
		modifiers: modifiers)
		familyId: familyId;
		yourself
]

{ #category : 'catalogue' }
BVCGearPlaystyleCatalogue >> itemsFor: familyId [
	^ self standalone , (self perform: (familyId asString , 'Pieces') asSymbol)
]

{ #category : 'catalogue' }
BVCGearPlaystyleCatalogue >> responseFamily [
	^ BVCGearFamily
		id: #response
		manufacturer: 'Relay Works'
		tiers: {self
					tier: 2
					adds: 8
					to: #healing
					trigger: #interrupt
					consumeOn: #heal.
				self
					tier: 3
					adds: 1
					to: #controlSeconds
					trigger: nil
					consumeOn: nil.
				self
					tier: 4
					adds: 6
					to: #healing
					trigger: #interrupt
					consumeOn: #heal}
]

{ #category : 'catalogue' }
BVCGearPlaystyleCatalogue >> responsePieces [
	^ {self
			gear: #responseHead
			named: 'Response Helmet'
			icon: 'Helmet'
			slot: #head
			family: #response
			modifiers: {self add: 10 to: #armour.
					self add: 1 / 5 to: #criticalChance}.
		self
			gear: #responseEyes
			named: 'Response Goggles'
			icon: 'Mask'
			slot: #eyes
			family: #response
			modifiers: {self add: 1 / 5 to: #criticalChance.
					self
						add: 2
						to: #controlSeconds
						against: #raider}.
		self
			gear: #responseChest
			named: 'Response Aid Vest'
			icon: 'VestWithPouch'
			slot: #chest
			family: #response
			modifiers: {self add: 15 to: #armour.
					self add: 20 to: #healing}.
		self
			gear: #responseFeet
			named: 'Response Boots'
			icon: 'Boots'
			slot: #feet
			family: #response
			modifiers: {self add: 5 to: #armour}}
]

{ #category : 'catalogue' }
BVCGearPlaystyleCatalogue >> standalone [
	^ {self
			gear: #trailCap
			named: 'Trail Cap'
			icon: 'Hat'
			slot: #head
			family: nil
			modifiers: {self add: 2 to: #mobility.
					self add: 1 / 10 to: #criticalChance}.
		self
			gear: #surveyHelmet
			named: 'Survey Helmet'
			icon: 'Helmet'
			slot: #head
			family: nil
			modifiers: {self add: 2 to: #precision.
					self add: 3 / 25 to: #criticalChance}.
		self
			gear: #surveyGoggles
			named: 'Survey Goggles'
			icon: 'Mask'
			slot: #eyes
			family: nil
			modifiers: {self add: 3 to: #precision.
					self add: 4 to: #weaponDamage}.
		self
			gear: #signalGoggles
			named: 'Signal Goggles'
			icon: 'Mask'
			slot: #eyes
			family: nil
			modifiers: {self add: 2 to: #suppression.
					self add: 2 to: #controlSeconds}.
		self
			gear: #fieldVest
			named: 'Field Vest'
			icon: 'Vest'
			slot: #chest
			family: nil
			modifiers: {self add: 25 to: #armour.
					self add: 2 to: #suppression}.
		self
			gear: #aidVest
			named: 'Aid Vest'
			icon: 'VestWithPouch'
			slot: #chest
			family: nil
			modifiers: {self add: 15 to: #armour.
					self add: 20 to: #healing}.
		self
			gear: #trailBoots
			named: 'Trail Boots'
			icon: 'Boots'
			slot: #feet
			family: nil
			modifiers: {self add: 3 to: #mobility.
					self add: 5 to: #armour}.
		self
			gear: #anchorBoots
			named: 'Anchor Boots'
			icon: 'Boots'
			slot: #feet
			family: nil
			modifiers: {self add: 3 to: #suppression.
					self add: 10 to: #armour}.
		self
			gear: #ridgeCap
			named: 'Ridge Cap'
			icon: 'Hat'
			slot: #head
			family: nil
			modifiers: {self add: 1 to: #mobility.
					self add: 8 to: #armour}.
		self
			gear: #bastionHelmet
			named: 'Bastion Helmet'
			icon: 'Helmet'
			slot: #head
			family: nil
			modifiers: {self add: 14 to: #armour.
					self add: 1 to: #suppression}.
		self
			gear: #rangeHood
			named: 'Range Hood'
			icon: 'HeadMask'
			slot: #head
			family: nil
			modifiers: {self add: 3 to: #precision.
					self add: 3 to: #armour}.
		self
			gear: #firstAidHood
			named: 'First Aid Hood'
			icon: 'HeadMask'
			slot: #head
			family: nil
			modifiers: {self add: 6 to: #healing.
					self add: 6 to: #armour}.
		self
			gear: #runnerGoggles
			named: 'Runner Goggles'
			icon: 'Mask'
			slot: #eyes
			family: nil
			modifiers: {self add: 2 to: #mobility.
					self add: 2 to: #armour}.
		self
			gear: #interceptorMask
			named: 'Interceptor Mask'
			icon: 'HeadMask'
			slot: #eyes
			family: nil
			modifiers: {self add: 1 to: #controlSeconds.
					self add: 8 to: #armour}.
		self
			gear: #observerGoggles
			named: 'Observer Goggles'
			icon: 'Mask'
			slot: #eyes
			family: nil
			modifiers: {self add: 2 to: #precision.
					self add: 2 to: #suppression}.
		self
			gear: #strikeGoggles
			named: 'Strike Goggles'
			icon: 'Mask'
			slot: #eyes
			family: nil
			modifiers: {self add: 3 / 20 to: #criticalChance.
					self add: 1 to: #suppression}.
		self
			gear: #runnerJacket
			named: 'Runner Jacket'
			icon: 'Jacket'
			slot: #chest
			family: nil
			modifiers: {self add: 2 to: #mobility.
					self add: 10 to: #armour}.
		self
			gear: #plateVest
			named: 'Plate Vest'
			icon: 'Vest'
			slot: #chest
			family: nil
			modifiers: {self add: 32 to: #armour}.
		self
			gear: #rangeJacket
			named: 'Range Jacket'
			icon: 'Jacket'
			slot: #chest
			family: nil
			modifiers: {self add: 2 to: #precision.
					self add: 12 to: #armour}.
		self
			gear: #utilityVest
			named: 'Utility Vest'
			icon: 'VestWithPouch'
			slot: #chest
			family: nil
			modifiers: {self add: 1 to: #controlSeconds.
					self add: 12 to: #healing}.
		self
			gear: #ridgeBoots
			named: 'Ridge Boots'
			icon: 'Boots'
			slot: #feet
			family: nil
			modifiers: {self add: 2 to: #precision.
					self add: 7 to: #armour}.
		self
			gear: #fastBoots
			named: 'Fast Boots'
			icon: 'Boots'
			slot: #feet
			family: nil
			modifiers: {self add: 4 to: #mobility}.
		self
			gear: #rescueBoots
			named: 'Rescue Boots'
			icon: 'Boots'
			slot: #feet
			family: nil
			modifiers: {self add: 5 to: #healing.
					self add: 7 to: #armour}.
		self
			gear: #bracedBoots
			named: 'Braced Boots'
			icon: 'Boots'
			slot: #feet
			family: nil
			modifiers: {self add: 2 to: #suppression.
					self add: 14 to: #armour}}
]

{ #category : 'catalogue' }
BVCGearPlaystyleCatalogue >> stillpointFamily [
	^ BVCGearFamily
		id: #stillpoint
		manufacturer: 'Meridian Range'
		tiers: {self
					tier: 2
					adds: 1
					to: #precision
					trigger: nil
					consumeOn: nil.
				self
					tier: 3
					adds: 1
					to: #precision
					trigger: nil
					consumeOn: nil.
				self
					tier: 4
					adds: 2
					to: #precision
					trigger: #settle
					consumeOn: #aimedHit}
]

{ #category : 'catalogue' }
BVCGearPlaystyleCatalogue >> stillpointPieces [
	^ {self
			gear: #stillpointHead
			named: 'Stillpoint Helmet'
			icon: 'Helmet'
			slot: #head
			family: #stillpoint
			modifiers: {self add: 7 to: #armour.
					self add: 1 to: #precision}.
		self
			gear: #stillpointEyes
			named: 'Stillpoint Goggles'
			icon: 'Mask'
			slot: #eyes
			family: #stillpoint
			modifiers: {self add: 8 to: #weaponDamage.
					self add: 1 to: #precision}.
		self
			gear: #stillpointChest
			named: 'Stillpoint Vest'
			icon: 'Vest'
			slot: #chest
			family: #stillpoint
			modifiers: {self add: 14 to: #armour.
					self add: 1 / 10 to: #criticalChance}.
		self
			gear: #stillpointFeet
			named: 'Stillpoint Boots'
			icon: 'Boots'
			slot: #feet
			family: #stillpoint
			modifiers: {self add: 6 to: #armour.
					self add: 1 to: #precision}}
]

{ #category : 'catalogue' }
BVCGearPlaystyleCatalogue >> tier: threshold adds: magnitude to: stat trigger: trigger consumeOn: event [
	^ BVCGearFamilyTier
		pieces: threshold
		modifiers: {BVCGearModifier
					stat: stat
					operation: #add
					magnitude: magnitude
					targetClass: nil
					duration: (trigger ifNil: [ #whileEquipped ] ifNotNil: [ #onConsume ])}
		trigger: trigger
		consumeOn: event
		limit: 1
]

{ #category : 'catalogue' }
BVCGearPlaystyleCatalogue >> traverseFamily [
	^ BVCGearFamily
		id: #traverse
		manufacturer: 'Crosswind Systems'
		tiers: {self
					tier: 2
					adds: 1
					to: #mobility
					trigger: nil
					consumeOn: nil.
				self
					tier: 3
					adds: 1
					to: #mobility
					trigger: nil
					consumeOn: nil.
				self
					tier: 4
					adds: 2
					to: #mobility
					trigger: #sprint
					consumeOn: #closeHit}
]

{ #category : 'catalogue' }
BVCGearPlaystyleCatalogue >> traversePieces [
	^ {self
			gear: #traverseHead
			named: 'Traverse Hood'
			icon: 'Hat'
			slot: #head
			family: #traverse
			modifiers: {self add: 4 to: #armour.
					self add: 1 to: #mobility}.
		self
			gear: #traverseEyes
			named: 'Traverse Goggles'
			icon: 'Mask'
			slot: #eyes
			family: #traverse
			modifiers: {self add: 5 to: #weaponDamage.
					self add: 1 to: #mobility}.
		self
			gear: #traverseChest
			named: 'Traverse Vest'
			icon: 'Vest'
			slot: #chest
			family: #traverse
			modifiers: {self add: 14 to: #armour.
					self add: 1 to: #mobility}.
		self
			gear: #traverseFeet
			named: 'Traverse Boots'
			icon: 'Boots'
			slot: #feet
			family: #traverse
			modifiers: {self add: 5 to: #armour.
					self add: 1 to: #mobility}}
]

{ #category : 'catalogue' }
BVCGearPlaystyleCatalogue >> watchlineFamily [
	^ BVCGearFamily
		id: #watchline
		manufacturer: 'Bastion Fabrication'
		tiers: {self
					tier: 2
					adds: 1
					to: #suppression
					trigger: nil
					consumeOn: nil.
				self
					tier: 3
					adds: 1
					to: #suppression
					trigger: nil
					consumeOn: nil.
				self
					tier: 4
					adds: 2
					to: #suppression
					trigger: #takeCover
					consumeOn: #sustainBurst}
]

{ #category : 'catalogue' }
BVCGearPlaystyleCatalogue >> watchlinePieces [
	^ {self
			gear: #watchlineHead
			named: 'Watchline Helmet'
			icon: 'Helmet'
			slot: #head
			family: #watchline
			modifiers: {self add: 10 to: #armour.
					self add: 1 to: #suppression}.
		self
			gear: #watchlineEyes
			named: 'Watchline Goggles'
			icon: 'Mask'
			slot: #eyes
			family: #watchline
			modifiers: {self add: 4 to: #weaponDamage.
					self add: 1 to: #suppression}.
		self
			gear: #watchlineChest
			named: 'Watchline Vest'
			icon: 'Vest'
			slot: #chest
			family: #watchline
			modifiers: {self add: 20 to: #armour.
					self add: 1 to: #suppression}.
		self
			gear: #watchlineFeet
			named: 'Watchline Boots'
			icon: 'Boots'
			slot: #feet
			family: #watchline
			modifiers: {self add: 8 to: #armour.
					self add: 1 to: #suppression}}
]
