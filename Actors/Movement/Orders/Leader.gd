# This node is referenced by followers to influence their movement.
# 
# It can be used on its own or can be attached to an Actor. Once the Actor
# dies, the expectation is that the Leader node will also die and the
# followers will no longer have a reference to the Leader and thus will
# be steered by other means.
class_name Leader extends Node2D

var formation : Formation
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
	var followerIdx := followers.find(follower)
	if (followerIdx >= 0):
		return formation.getTarget(followerIdx)
	
	assert(false, "Follower is not following this leader. Should never get here. Follower index: %d" % followerIdx)

# Returns true if the add succeeded
func addFollower(follower: KinematicBody2D) -> bool :
	print(followers.size())
	print(formation.maxFollowers)
	print()
	if followers.size() < formation.maxFollowers:
		followers.push_back(follower)
		follower.leader = self
		return true
	else:
		push_warning("Max followers for the formation has been reached. Max: %d" % formation.maxFollowers)
		return false
	# TODO: Error handling/better system for adding followers
