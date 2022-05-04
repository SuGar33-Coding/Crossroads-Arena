extends KinematicBody2D

export var baseSpeed = 100
export var Friction = 75

# TODO: Only using this as export for testing purposes
var item : ItemInstance
var itemResource : Item
var playerInZone := false
var mouseInZone := false
var highlightShader := preload("res://FX/HighlightFX.shader")
var ToolTipClass = preload("res://UI/Inventory/ToolTip.tscn")
var velocity := Vector2.ZERO
var movement := false
var movementDir := Vector2.ZERO
var ttip: ToolTip
var outlineColor : Color = Color.white

onready var itemSprite = $ItemSprite
onready var animationPlayer = $AnimationPlayer
onready var pickupMessage = $PickupMessage

func init(itemInstance: ItemInstance, shouldMove := false):
	item = itemInstance
	itemResource = item.resource
	movement = shouldMove
	if movement:
		movementDir = Vector2(rand_range(-1, 1), rand_range(-1, 1))
		movementDir = movementDir.normalized()
	
	outlineColor = Constants.getRarityColor(itemResource.rarity)


# TODO: Adjust starting height and animation height based on sprite size
func _ready():
	pickupMessage.visible = false
	itemSprite.texture = item.getTexture()
	itemSprite.flip_h = item.flip
	itemSprite.flip_v = item.flip
	
	itemSprite.material = ShaderMaterial.new()
	
	velocity = baseSpeed * movementDir

func _physics_process(delta):
	if(playerInZone and mouseInZone):
		if Input.is_action_just_pressed("use"):
			Inventory.addItemToBag(item)
			queue_free()
		else:
			pickupMessage.visible = true
	elif pickupMessage.visible == true:
		pickupMessage.visible = false
	
	if(mouseInZone and Input.is_action_pressed("info")):
		pickupMessage.visible = false
	
	if movement:
		velocity = velocity.move_toward(Vector2.ZERO, Friction * delta)
		
	velocity = move_and_slide(velocity)

func playFloat():
	animationPlayer.play("Float")

func displayPickup():
	(itemSprite.material as ShaderMaterial).shader = highlightShader
	itemSprite.material.set_shader_param("outline_color", outlineColor)
	pickupMessage.visible = true

func hidePickup():
	(itemSprite.material as ShaderMaterial).shader = null
	pickupMessage.visible = false

func _on_MouseArea_mouse_entered():
	mouseInZone = true
	
	# create tooltip
	ttip = ToolTipClass.instance()
	add_child(ttip)
	ttip.init(item)
	
	if playerInZone:
		displayPickup()

func _on_MouseArea_mouse_exited():
	mouseInZone = false
	
	# destroy tooltip
	if is_instance_valid(ttip):
		ttip.queue_free()
	
	hidePickup()

func _on_PlayerCollision_body_entered(body):
	playerInZone = true
	if mouseInZone:
		displayPickup()

func _on_PlayerCollision_body_exited(body):
	playerInZone = false
	hidePickup()

