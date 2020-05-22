extends Node

var _player_name = "";
var _host_IP = "";

func _ready():
	pass


func _on_NameInput_text_changed(new_text):
	_player_name = new_text;


func _on_JoinButton_pressed():
	if _player_name == "" || _host_IP == "":
		return
	Network.self_data.name = _player_name # just setting the player name for now
	Network.host_IP = _host_IP;
	_load_game();


func _on_HostButton_pressed():
	if _player_name == "":
		return
	### I create the server and add dogs when everything is ready
#	Network.create_server(_player_name);
	Network.self_data.name = _player_name # just setting the player name for now
	_load_game();
	
func _load_game():
	get_tree().change_scene("res://Scenes/Game.tscn");


func _on_IpInput_text_changed(new_text):
	_host_IP = new_text;
