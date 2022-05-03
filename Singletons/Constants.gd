extends Node

var UBIQ_COLOR := Color.gray
var COMMON_COLOR := Color.whitesmoke
var UNCOMMON_COLOR := Color.aquamarine
var RARE_COLOR := Color.green
var VRARE_COLOR := Color.blue
var EXOTIC_COLOR := Color.purple
var LEGEND_COLOR := Color.orange

func getRarityColor(rarity) -> Color:
	match rarity:
		Item.RARITY.UBIQUITOS:
			return UBIQ_COLOR
		Item.RARITY.COMMON:
			return COMMON_COLOR
		Item.RARITY.UNCOMMON:
			return UNCOMMON_COLOR
		Item.RARITY.RARE:
			return RARE_COLOR
		Item.RARITY.VERY_RARE:
			return VRARE_COLOR
		Item.RARITY.EXOTIC:
			return EXOTIC_COLOR
		Item.RARITY.LEGENDARY:
			return LEGEND_COLOR
	
	return UBIQ_COLOR

var FIGHTER_PATH = "res://Actors/Fighters/Fighter.tscn"
var BRUTE_PATH = "res://Actors/Brute/Brute.tscn"
var CHARGER_PATH = "res://Actors/Chargers/Charger/Charger.tscn"
var DASHER_PATH = "res://Actors/Dashers/Rogue/Rogue.tscn"
