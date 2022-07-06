# This node is referenced by followers to influence their movement.
# 
# It can be used on its own or can be attached to an Actor. Once the Actor
# dies, the expectation is that the Leader node will also die and the
# followers will no longer have a reference to the Leader and thus will
# be steered by other means.
class_name Leader extends KinematicBody2D

const PERF_THRESHOLD = 500

var formation : Formation
var followers := []
var target : Node2D
var movement : Movement
var pathfindTimer : Timer
var pathIdx := 0
var velocity := Vector2.ZERO
var path : PoolVector2Array

onready var nav2d : Navigation2D = get_tree().get_current_scene().get_node("Navigation2D")
onready var simpleNav2d : Navigation2D = get_tree().get_current_scene().get_node("SimpleNavigation2D")

func _ready():
	pathfindTimer = Timer.new()
	pathfindTimer.one_shot = true
	pathfindTimer.wait_time = 1.0
	add_child(pathfindTimer)

func _physics_process(delta):
#	print(self.rotation_degrees)
#	print(target)
	if is_instance_valid(target):
		self.look_at(target.global_position)
		# can just look at the target without moving towards them
		if is_instance_valid(movement):
			if is_instance_valid(nav2d) and pathfindTimer.is_stopped(): # Last check is to make it not refresh if it doesn't use it
				if self.global_position.distance_to(self.getTargetPos()) > PERF_THRESHOLD:
					path = simpleNav2d.get_simple_path(simpleNav2d.get_closest_point(global_position), simpleNav2d.get_closest_point(self.getTargetPos()), false)
				else:
					path = nav2d.get_simple_path(nav2d.get_closest_point(global_position), nav2d.get_closest_point(self.getTargetPos()), false)
				pathfindTimer.start()
				pathIdx = 0
			velocity = movement.getMovementVelocity(self, self.getTargetPos(), delta)

func getTargetPos():
	return target.global_position

func getFormationPos(follower: KinematicBody2D):
	var followerIdx := followers.find(follower)
	if (followerIdx >= 0):
		return formation.getTarget(followerIdx)
	
	assert(false, "Follower is not following this leader. Should never get here. Follower index: %d" % followerIdx)

# Returns true if the add succeeded
func addFollower(follower: KinematicBody2D) -> bool :
	if followers.size() < formation.maxFollowers:
		followers.push_back(follower)
		follower.leader = self
		return true
	else:
		push_warning("Max followers for the formation has been reached. Max: %d" % formation.maxFollowers)
		return false
	# TODO: Error handling/better system for adding followers
