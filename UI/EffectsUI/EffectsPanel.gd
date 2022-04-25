class_name EffectsPanel extends Control

const EffectsIconScene = preload("res://UI/EffectsUI/EffectsIcon.tscn")

onready var effectsHBox : HBoxContainer = $EffectsHBox

var effectColTypes = []
var colWidth : int

func _ready():
	colWidth = self.rect_size.x / Effect.EffectType.size()

func addEffect(effectRes : Effect):
	var newEffectIcon = EffectsIconScene.instance()
	newEffectIcon.init(effectRes)
	newEffectIcon.rect_min_size = Vector2(0, colWidth * 0.15)
	
	if (effectColTypes.has(effectRes.effectType)):
		var effectCol = effectsHBox.get_child(effectColTypes.find(effectRes.effectType))
		
		var childIndex : int = effectCol.get_child_count()
		for i in range(childIndex):
			var effectIcon = effectCol.get_child(i) as EffectsIcon
			if effectIcon.effectRes.amount > effectRes.amount:
				childIndex = i
				break
		effectCol.add_child(newEffectIcon)
		effectCol.move_child(newEffectIcon, childIndex)
		
	else:
		effectColTypes.append(effectRes.effectType)
		var effectColVBox = VBoxContainer.new()
		effectColVBox.rect_min_size = Vector2(colWidth, 0)
		effectsHBox.add_child(effectColVBox)
		effectColVBox.add_child(newEffectIcon)

func removeEffect(effectRes : Effect):
	if (effectColTypes.has(effectRes.effectType)):
		var typeIndex : int = effectColTypes.find(effectRes.effectType)
		var effectCol : VBoxContainer = effectsHBox.get_child(typeIndex)
		
		for effectIcon in effectCol.get_children():
			effectIcon = effectIcon as EffectsIcon
			if effectIcon.effectRes == effectRes:
				effectCol.remove_child(effectIcon)
				effectIcon.queue_free()
				break
		
		if effectCol.get_child_count() <= 0:
			effectColTypes.remove(typeIndex)
			effectCol.queue_free()
