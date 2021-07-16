extends KinematicBody2D

export var baseSpeed = 100
export var Friction = 75

# TODO: Only using this as export for testing purposes
var item : ItemInstance
var itemResource : Item
var playerInZone := false
var mouseInZone := false
var highlightShader := preload("res://FX/HighlightFX.shader")
var LabelContainer := preload("res://UI/TooltipLabel.tscn")
var velocity := Vector2.ZERO
var movement := false
var movementDir := Vector2.ZERO

onready var itemSprite = $ItemSprite
onready var tooltipPanel = $PanelContainer
onready var vboxContainer = $PanelContainer/VBoxContainer
onready var nameLabel = $PanelContainer/VBoxContainer/CenterContainer/Label
onready var animationPlayer = $AnimationPlayer

func init(itemInstance: ItemInstance, shouldMove := false):
	item = itemInstance
	movement = shouldMove
	if movement:
		movementDir = Vector2(rand_range(-1, 1), rand_range(-1, 1))
		movementDir = movementDir.normalized()


# TODO: Adjust starting height and animation height based on sprite size
func _ready():
	tooltipPanel.visible = false
	itemSprite.texture = item.getTexture()
	nameLabel.text = item.itemName
	itemSprite.material = ShaderMaterial.new()
	
	velocity = baseSpeed * movementDir
	
	itemResource = item.resource
	if itemResource is Armor:
		addNewLabel("Type:   " + Armor.Type.keys()[itemResource.type])
		addNewLabel("DEF:   " + str(itemResource.defenseValue))
		addNewLabel("SPD:   " + str(itemResource.speedModifier))
	elif itemResource is Consumable:
		pass
	else:
		pass

func _physics_process(delta):
	if(playerInZone and mouseInZone and Input.is_action_just_pressed("use")):
		Inventory.addItemToBag(item)
		queue_free()
	
	if movement:
		velocity = velocity.move_toward(Vector2.ZERO, Friction * delta)
		
	velocity = move_and_slide(velocity)

func addNewLabel(labelString : String):
	var newContainer = LabelContainer.instance()
	var label = newContainer.get_child(0)
	label.text = labelString
	vboxContainer.add_child(newContainer)

func playFloat():
	animationPlayer.play("Float")

func _on_MouseArea_mouse_entered():
	mouseInZone = true
	tooltipPanel.visible = true
	if playerInZone:
		(itemSprite.material as ShaderMaterial).shader = highlightShader

func _on_MouseArea_mouse_exited():
	mouseInZone = false
	tooltipPanel.visible = false
	(itemSprite.material as ShaderMaterial).shader = null

func _on_PlayerCollision_body_entered(body):
	playerInZone = true
	if mouseInZone:
		(itemSprite.material as ShaderMaterial).shader = highlightShader

func _on_PlayerCollision_body_exited(body):
	playerInZone = false
	(itemSprite.material as ShaderMaterial).shader = null

