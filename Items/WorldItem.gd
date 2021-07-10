extends Area2D

# TODO: Only using this as export for testing purposes
var item : ItemInstance
var playerInZone := false

onready var itemSprite = $ItemSprite

func init(itemInstance: ItemInstance):
	item = itemInstance


# TODO: Adjust starting height and animation height based on sprite size
func _ready():
	itemSprite.texture = item.getTexture()

func _physics_process(_delta):
	if(playerInZone and Input.is_action_just_pressed("use")):
		Inventory.addItemToBag(item)
		queue_free()


func _on_Node2D_body_entered(body):
	playerInZone = true


func _on_Node2D_body_exited(body):
	playerInZone = false
