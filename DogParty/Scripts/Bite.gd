extends Area2D


func _ready():
	$AnimationPlayer.play("Bite");


func destroy():
	queue_free();
