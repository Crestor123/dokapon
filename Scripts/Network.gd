extends Node

@onready var main = get_parent()
var players : Node = null

var multiplayer_peer = ENetMultiplayerPeer.new()
var peers = []

var port = 5000
var address = "localhost"

signal player_joined(peerId)
signal peers_synced()

func set_player_node(playerNode):
	players = playerNode
	#new_player.connect(players._new_player)

func create_server():
	multiplayer_peer.create_server(port)
	multiplayer.multiplayer_peer = multiplayer_peer
	
	add_new_client(1)
	
	multiplayer_peer.peer_connected.connect(
		func(newPeerId):
			await get_tree().create_timer(1).timeout
			rpc('add_new_client', newPeerId)
			#rpc('print_debug')
			print(peers)
			print(newPeerId)
			rpc_id(newPeerId, "add_previous_clients", peers)
			add_new_client(newPeerId)
	)
	pass
	
func join_server():
	print("joining server")
	multiplayer_peer.create_client(address, port)
	multiplayer.multiplayer_peer = multiplayer_peer
	pass

@rpc
func add_new_client(peerId):
	if peerId == 1:
		peers.push_front(1)
	else:
		peers.append(peerId)
	#if players:
	print("emitting new player")
	player_joined.emit(peerId)
	pass

@rpc
func add_previous_clients(peerIds):
	for peerId in peerIds:
		print("adding ", peerId)
		add_new_client(peerId)
	peers_synced.emit()

@rpc("call_local", "any_peer")
func print_debug():
	print("debug: ", multiplayer.get_unique_id())
