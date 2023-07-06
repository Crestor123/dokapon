extends Node

@export var playerData : PackedScene

@onready var main = get_parent()
var players : Node = null

var multiplayer_peer = ENetMultiplayerPeer.new()
var peers = []

var port = 5000
var address = "localhost"

signal player_joined(peerID)
signal player_left(peerID)
signal peers_synced()

func set_player_node(playerNode):
	players = playerNode
	#new_player.connect(players._new_player)

func create_server():
	multiplayer_peer.create_server(port)
	multiplayer.multiplayer_peer = multiplayer_peer
	
	add_new_client(1)
	
	multiplayer_peer.peer_connected.connect(
		func(newPeerID):
			await get_tree().create_timer(1).timeout
			rpc('add_new_client', newPeerID)
			#rpc('print_debug')
			print(peers)
			print(newPeerID)
			rpc_id(newPeerID, "add_previous_clients", peers)
			add_new_client(newPeerID)
	)
	
	multiplayer_peer.peer_disconnected.connect(
		func(peerID):
			rpc('remove_client', peerID)
			print(peers)
	)
	pass
	
func join_server():
	print("joining server")
	multiplayer_peer.create_client(address, port)
	multiplayer.multiplayer_peer = multiplayer_peer
	
	multiplayer_peer.peer_disconnected.connect(
		func():
			rpc('remove_client', 1)
			print(peers)
	)
	pass

@rpc
func add_new_client(peerID):
	var newPeer = playerData.instantiate()
	newPeer.ID = peerID
	add_child(newPeer)
	if peerID == 1:
		peers.push_front(1)
	else:
		peers.append(peerID)
	#if players:
	print("emitting new player")
	player_joined.emit(peerID)
	pass

@rpc("call_local")
func remove_client(peerID):
	if peerID == 1:
		print("host left")
	else:
		peers.erase(peerID)
	player_left.emit(peerID)

@rpc
func add_previous_clients(peerIDs):
	for peerID in peerIDs:
		print("adding ", peerID)
		add_new_client(peerID)
	peers_synced.emit()

@rpc("call_local", "any_peer")
func print_debug():
	print("debug: ", multiplayer.get_unique_id())
