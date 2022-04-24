class_name EffectsIcon extends Control

onready var texture : TextureRect = $Texture
onready var label : Label = $Texture/Label

var effectRes : Effect

func _ready():
	texture.texture = effectRes.icon
	label.text = str(effectRes.amount)

func init(effectRes: Effect):
	self.effectRes = effectRes
