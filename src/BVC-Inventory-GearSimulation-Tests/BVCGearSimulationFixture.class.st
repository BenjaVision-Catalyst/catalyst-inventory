Class {
	#name : 'BVCGearSimulationFixture',
	#superclass : 'Object',
	#category : 'BVC-Inventory-GearSimulation-Tests',
	#package : 'BVC-Inventory-GearSimulation-Tests'
}

{ #category : 'simulation' }
BVCGearSimulationFixture >> add: magnitude to: stat against: targetClass [
	^ BVCGearModifier
		stat: stat
		operation: #add
		magnitude: magnitude
		targetClass: targetClass
		duration: #whileEquipped
]

{ #category : 'simulation' }
BVCGearSimulationFixture >> catalogue [
	^ {BVCGearDefinition
			id: #helmet
			name: 'Field Helmet'
			icon: 'gearIcon_Helmet.png'
			type: #armour
			slot: #head
			modifiers: {self
						add: 10
						to: #armour
						against: nil.
					self
						add: 1 / 5
						to: #criticalChance
						against: nil}.
		BVCGearDefinition
			id: #goggles
			name: 'Field Goggles'
			icon: 'gearIcon_Mask.png'
			type: #accessory
			slot: #eyes
			modifiers: {self
						add: 1 / 5
						to: #criticalChance
						against: nil.
					self
						add: 2
						to: #controlSeconds
						against: #raider}.
		BVCGearDefinition
			id: #vest
			name: 'Field Vest'
			icon: 'gearIcon_Vest.png'
			type: #armour
			slot: #chest
			modifiers: {self
						add: 25
						to: #armour
						against: nil.
					self
						add: 15
						to: #weaponDamage
						against: #raider}.
		BVCGearDefinition
			id: #pouchVest
			name: 'Aid Vest'
			icon: 'gearIcon_VestWithPouch.png'
			type: #armour
			slot: #chest
			modifiers: {self
						add: 15
						to: #armour
						against: nil.
					self
						add: 20
						to: #healing
						against: nil}}
]

{ #category : 'simulation' }
BVCGearSimulationFixture >> damageGoals [
	^ #(#(damage 440 440 1))
]

{ #category : 'simulation' }
BVCGearSimulationFixture >> mixedGoals [
	^ #(#(control 3 3 1) #(healing 30 30 1))
]

{ #category : 'simulation' }
BVCGearSimulationFixture >> run [
	^ BVCGearSimulator new runCatalogue: self catalogue scenarios: self scenarios
]

{ #category : 'simulation' }
BVCGearSimulationFixture >> scenarios [
	^ #(raider drone)
		collect: [ :targetClass | 
			{#id -> targetClass.
				#version -> 'gear-v1'.
				#character -> #shaki.
				#weapon -> #trainingRifle.
				#targetClass -> targetClass.
				#encounterSeconds -> 10.
				#incomingDamage -> 80.
				#shots -> 4.
				#criticalMultiplier -> 2.
				#criticalCap -> (2 / 5).
				#baseStats
					-> {#armour -> 0.
							#criticalChance -> (1 / 10).
							#weaponDamage -> 100.
							#controlSeconds -> 1.
							#healing -> 10} asDictionary} asDictionary ]
]
