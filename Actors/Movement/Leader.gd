# This node is referenced by followers to influence their movement.
# 
# It can be used on its own or can be attached to an Actor. Once the Actor
# dies, the expectation is that the Leader node will also die and the
# followers will no longer have a reference to the Leader and thus will
# be steered by other means.
class_name Leader extends Node2D

onready var defaultForm :Path2D = $DefaultForm

var followers := []

func _process(delta):
	# TODO: Figure out a way to get the positions to not flip when the 
	# parent flips
#	if get_parent().scale.y == -1:
#		self.scale.y = -1
	pass

func _physics_process(delta):
	pass

func getTarget(follower: KinematicBody2D):
	var followerIdx = followers.find(follower)
	if (followerIdx >= 0):
#		return defaultForm.curve.get_point_position(followerIdx % 2) + get_parent().global_position
		return (get_child(followerIdx % 5) as Position2D).global_position #+ get_parent().global_position
	
	assert(false, "No orders found for follower. Should never get here. Follower index: " + followerIdx)

func addFollower(follower: KinematicBody2D):
	followers.push_back(follower)
	follower.leader = self
	# TODO: Error handling/better system for adding followers
#	assert(followers.size() <= 6, "Too many followers.")
