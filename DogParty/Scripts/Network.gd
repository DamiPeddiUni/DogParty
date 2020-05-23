extends Node

const DEFAULT_IP = '127.0.0.1';
const DEFAULT_PORT = 8081;
const MAX_PLAYERS = 4;

# not sure it is really useful to keep track of player positions since 
# slaves will be updated almost immediately
var players = {}
var self_data = {
	name = "", 
	position = Vector2(0, 0),
}
var host_IP

onready var network = NetworkedMultiplayerENet;

func _ready():
	get_tree().connect("network_peer_disconnected", self, "_player_disconnect");
	get_tree().connect("connected_to_server", self, "_connected_to_server");
	### this signal is useful !
	get_tree().connect("network_peer_connected", self, "_player_connected");
	### end
	
func start():
	if host_IP:
		connect_to_server()
	else:
		create_server()
	
func create_server():
#	self_data.name = player_nickname;
	var peer = network.new();
	peer.create_server(DEFAULT_PORT, MAX_PLAYERS);
	get_tree().set_network_peer(peer);
	pop_player(1, self_data)


func connect_to_server():
#	self_data.name = player_nickname;
	
	var peer = network.new();
	peer.create_client(host_IP, DEFAULT_PORT);
	get_tree().set_network_peer(peer);
	


func _connected_to_server():
#	players[get_tree().get_network_unique_id()] = self_data;
### I think it is better to manage sending info in the _player_connected callback
### and not herer since it guarantees that infos are received by all peers
#	rpc('_send_player_info', get_tree().get_network_unique_id(), self_data)
### end
### However you can pop yourself here !
	print("BBBBBBBBBBBBBBBB");
	pop_player(get_tree().get_network_unique_id(), self_data)
### end


func _player_connected(id):
	print("Player connected: " + str(id));
	pop_player(id)
	rpc_id(id, "_send_player_info", get_tree().get_network_unique_id(), self_data)
	### end

func _player_disconnect(id):
	print("Player disconnected: " + str(id));
	get_tree().get_root().get_node(str(id)).queue_free();
	players.erase(id);
	### there might be more things to do here ? Don't know :-)
	
func pop_player(id, info = null):
	var new_player = load("res://Prefab/Player.tscn").instance();
	new_player.name = str(id);
	new_player.set_network_master(id);
	get_tree().get_root().add_child(new_player);
	if info:
		players[id] = info;
		new_player.call_deferred("init", info.name, info.position, id != get_tree().get_network_unique_id());
		
	
remote func _send_player_info(id, info):
	players[id] = info;
	get_node("/root/" + str(id)).init(info.name, info.position, true)
	### that was a bit problematic and provoked errors for more than 4 players
#	if get_tree().is_network_server():
#		for peer_id in players:
#			rpc_id(id, "_send_player_info", peer_id, players[peer_id]);
	### end

func update_position(id, position):
	if players.has(id):
		players[id].position = position;
		

	
	

	
	
