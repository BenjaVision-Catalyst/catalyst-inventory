Class {
	#name : 'CIThatGameLaunchCatalog',
	#superclass : 'Object',
	#category : 'BVC-Inventory-TypeCatalog',
	#package : 'BVC-Inventory-TypeCatalog'
}

{ #category : 'definitions' }
CIThatGameLaunchCatalog class >> gearFamilies [
	^ #(#('vossAndVale' 'Voss & Vale' #('weaponDamage' 'Weapon damage' 'offensive' 'signedPercent' 0 0.15) vest backpack) #('rookStandard' 'Rook Standard' #('armor' 'Armor' 'defensive' 'signedNumber' 0 170000) vest backpack) #('morrowWorks' 'Morrow Works' #('skillTier' 'Skill Tier' 'utility' 'signedNumber' 1 1) vest backpack) #('redLotusAssault' 'Red Lotus Assault' #('weaponDamage' 'Weapon damage' 'offensive' 'signedPercent' 0 0.15) redLotusVest redLotusBackpack) #('jupiterTechnologies' 'Jupiter Technologies' #('skillTier' 'Skill Tier' 'utility' 'signedNumber' 1 1) jupiterVest jupiterBackpack))
]

{ #category : 'definitions' }
CIThatGameLaunchCatalog class >> gearIdentifierFor: family slot: slot [
	^ 'gear.launch.' , family first , '.' , slot first asLowercase
]

{ #category : 'definitions' }
CIThatGameLaunchCatalog class >> gearSlots [
	^ #(#('Mask' 'Mask') #('Chest' 'Vest') #('Backpack' 'Backpack') #('Gloves' 'Gloves') #('KneePads' 'Kneepads'))
]

{ #category : 'registration' }
CIThatGameLaunchCatalog class >> registerGear: family slot: slot in: catalog [
	| piece profile |
	piece := CIThatGameLaunchGearType
			id: (self gearIdentifierFor: family slot: slot)
			name: family second , ' ' , slot second
			slot: slot first
			attributes: {family third}
			sockets: #().
	piece familyId: family first name: family second.
	piece
		inspectorIdentity: (Dictionary new
				at: 'inspectorManufacturer' put: family second;
				yourself).
	catalog register: piece.
	profile := slot first = 'Chest'
			ifTrue: [ family fourth ]
			ifFalse: [ slot first = 'Backpack' ifTrue: [ family fifth ] ].
	profile
		ifNotNil: [ CIGameItemTypes
				configureTalentPoolFor: piece id
				profile: profile
				in: catalog ]
]

{ #category : 'registration' }
CIThatGameLaunchCatalog class >> registerIn: catalog [
	self weaponSpecs do: [ :spec | self registerWeapon: spec in: catalog ].
	self gearFamilies
		do: [ :family | 
			self gearSlots
				do: [ :slot | 
					self
						registerGear: family
						slot: slot
						in: catalog ] ]
]

{ #category : 'registration' }
CIThatGameLaunchCatalog class >> registerWeapon: spec in: catalog [
	| slot weapon reference range |
	slot := spec fourth = #pistol
			ifTrue: [ 'LeftHandWeapon' ]
			ifFalse: [ 'RangedWeapon' ].
	weapon := CIWeaponType
			id: spec first
			name: spec second
			slot: slot
			core: {{'Damage per hit'.
						spec fifth}.
					{'Fire rate'.
						(spec at: 6) asString , ' RPM'}.
					{'Magazine'.
						(spec at: 7) asString , ' rounds'}.
					{'Optimal range'.
						spec last}.
					{'Reload time'.
						(spec at: 8) asString , ' s'}}
			handling: #()
			sockets: #().
	weapon
		inspectorIdentity: (Dictionary new
				at: 'inspectorCategory' put: spec fourth asString;
				yourself).
	reference := catalog
			typeAt: (spec fourth = #pistol
					ifTrue: [ 'weapon.sidearm.relay' ]
					ifFalse: [ 'weapon.ranged.pathfinder' ]).
	range := spec last.
	weapon
		damageFalloff: ((reference inspectorFalloffRows allButFirst: 2)
				collect: [ :point |
					{(point third * range / reference optimalRangeMetres) rounded.
						point second} ]).
	catalog register: weapon.
	CIGameItemTypes
		configureTalentPoolFor: weapon id
		profile: spec third
		in: catalog
]

{ #category : 'spawning' }
CIThatGameLaunchCatalog class >> spawnSpecs [
	| entries |
	entries := OrderedCollection new.
	self weaponSpecs
		do: [ :spec | 
			entries
				add: spec first
						-> (Dictionary new
								at: 'weaponDamage' put: 0.15;
								yourself) ].
	self gearFamilies
		do: [ :family | 
			self gearSlots
				do: [ :slot | 
					entries
						add: (self gearIdentifierFor: family slot: slot)
								-> (Dictionary new
										at: family third first put: family third last;
										yourself) ] ].
	^ entries asArray
]

{ #category : 'definitions' }
CIThatGameLaunchCatalog class >> weaponSpecs [
	^ #(#('weapon.launch.akM' 'AK-M' assaultRifle assaultRifle 67175 600 30 2.3 27) #('weapon.launch.tacticalMk16' 'Tactical Mk 16' assaultRifle assaultRifle 59221 650 30 2.02 31) #('weapon.launch.famas2010' 'FAMAS 2010' assaultRifle assaultRifle 45272.5 900 30 2.49 26) #('weapon.launch.capacitor' 'Capacitor' capacitor assaultRifle 57617.5 700 30 1.85 31) #('weapon.launch.vectorSbr9mm' 'Vector SBR 9mm' smg smg 39306.5 1200 33 2.38 15) #('weapon.launch.mp5St' 'MP5 ST' smg smg 53903.5 800 30 1.79 21) #('weapon.launch.pp19' 'PP-19' smg smg 63593 700 53 1.46 21) #('weapon.launch.chatterbox' 'The Chatterbox' chatterbox smg 39457 850 50 1.43 21) #('weapon.launch.m249B' 'M249 B' lmg lmg 48300 850 100 4.54 35) #('weapon.launch.mg5' 'MG5' lmg lmg 54322 800 50 2.96 35) #('weapon.launch.classicRpk74' 'Classic RPK-74' lmg lmg 71538 600 40 4 30) #('weapon.launch.bluescreen' 'Bluescreen' bluescreen lmg 62361 720 200 2.22 40) #('weapon.launch.m870Express' 'M870 Express' shotgun shotgun 703672 75 5 3.35 11) #('weapon.launch.super90' 'Super 90' shotgun shotgun 389936 160 8 4.65 11) #('weapon.launch.acs12' 'ACS-12' shotgun shotgun 180748 300 20 3.35 16) #('weapon.launch.scorpio' 'Scorpio' scorpio shotgun 409568 130 7 2.5 14) #('weapon.launch.leverAction1886' '1886' rifle rifle 386988.5 100 8 3.46 35) #('weapon.launch.classicM1a' 'Classic M1A' rifle rifle 231346 180 10 2.6 60) #('weapon.launch.urbanMdr' 'Urban MDR' rifle rifle 102970 380 20 2.85 60) #('weapon.launch.doctorHome' 'Doctor Home' doctorHome rifle 129269.5 320 10 1.93 60) #('weapon.launch.model700' 'Model 700' marksmanRifle marksmanRifle 441569.5 55 7 7.05 50) #('weapon.launch.sr1' 'SR-1' marksmanRifle marksmanRifle 409357 60 5 3.15 50) #('weapon.launch.paratrooperSvd' 'Paratrooper SVD' marksmanRifle marksmanRifle 156662.5 260 10 2.85 50) #('weapon.launch.nemesis' 'Nemesis' nemesis marksmanRifle 940240 50 5 2.78 60) #('weapon.launch.d50' 'D50' pistol pistol 189171.5 200 8 2.24 18) #('weapon.launch.m45a1' 'M45A1' pistol pistol 117435.5 310 7 2.33 12) #('weapon.launch.93r' '93R' pistol pistol 52977.5 700 20 1.71 12) #('weapon.launch.liberty' 'Liberty' liberty pistol 189171.5 230 8 1.95 18))
]
