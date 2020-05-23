extends KinematicBody2D

const MOVE_SPEED = 500;
const MAX_HP = 100;

var myId;

puppet var slave_position = Vector2();
puppet var slave_movement = Vector2();
puppet var slave_direction = 1;

var health_points = MAX_HP;

var bite = load("res://Prefab/Bite.tscn");

func init(name, pos, is_slave):
	$nameLabel.text = name;
	global_position = pos
	if is_slave:
		$Camera2D.current = false;
		$AnimatedSprite.get_material().set_shader_param("outline_color", Color.red);
	else:
		$Camera2D.current = true;
		$AnimatedSprite.get_material().set_shader_param("outline_color", Color.white);
	myId = get_tree().get_network_unique_id();
	
	
	

func _ready():
	get_tree().connect('server_disconnected', self, '_on_server_disconnected', [], CONNECT_DEFERRED)
	
	var mat = $AnimatedSprite.get_material().duplicate(true)
	$AnimatedSprite.set_material(mat)
	
	
func _physics_process(delta):
	
	var direction = Vector2();
	if is_network_master():
		if Input.is_action_pressed("ui_left"):
			direction.x = -1;
		elif Input.is_action_pressed("ui_right"):
			direction.x = 1;
		else:
			direction.x = 0;
		if Input.is_action_pressed("ui_up"):
			direction.y = -1;
		elif Input.is_action_pressed("ui_down"):
			direction.y = 1;
		else:
			direction.y = 0;
		
		rset_unreliable("slave_position", position);
		rset("slave_movement", direction);
		rset("slave_direction", -1 if $AnimatedSprite.flip_h else 1);
		_move(direction);
		
		if Input.is_action_just_pressed("attackQ"):
			var new_bite = bite.instance();
			new_bite.position = position;
			var rot = get_angle_to(get_global_mouse_position()) + rotation
			new_bite.rotation = rot;
			get_parent().add_child(new_bite);
		
	else:
		_move(slave_movement);
		position = slave_position;
		
		
	if get_tree().is_network_server():
		Network.update_position(int(name), position);
		
	
	
		
func _move(direction):
	$AnimatedSprite.play("run" if direction != Vector2.ZERO else "idle");

	if is_network_master():
		$AnimatedSprite.flip_h = get_global_mouse_position().x < position.x;
	else:
		$AnimatedSprite.flip_h = true if slave_direction == -1 else false;
		
	move_and_collide(direction.normalized() * MOVE_SPEED * get_physics_process_delta_time());
	
	
func _on_server_disconnected():
	get_node("/root/Game").queue_free()
	get_tree().set_network_peer(null);
	get_tree().change_scene("res://Scenes/StartMenu.tscn");
	
	
	
