extends Node


func _ready():
	Network.start()
	
	get_tree().connect('connection_failed', self, '_on_connected_failed');
	### I moved the following in Network.gd to avoid duplicating player instancing logic
#	var new_player = preload('res://Prefab/Player.tscn').instance();
#	new_player.name = str(get_tree().get_network_unique_id());
#	new_player.set_network_master(get_tree().get_network_unique_id());
#	get_tree().get_root().add_child(new_player);
#	new_player.init(info.name, info.position, false);
	### end ### 
	### I moved the following in _ready() of the player ###
#	var mat = new_player.get_node("AnimatedSprite").get_material().duplicate(true)
#	new_player.get_node("AnimatedSprite").set_material(mat)
	### end ###
	### I think it's useless (for now ;))
#	var info = Network.self_data;
	### end
	
func _process(delta):
	#for peer_id in Network.players:
		#print(Network.players[peer_id].name);
	pass
		



	
func _on_connected_failed():
	get_tree().change_scene("res://Scenes/StartMenu.tscn");
