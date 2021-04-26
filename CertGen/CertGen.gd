extends Node

onready var cert_dir_path = "user://certificate/"
onready var cert_path = cert_dir_path + "cert.crt"
onready var key_path = cert_dir_path + "key.key"

var credentials = "CN=bjarne_games.xyz,O=bjarne_games,C=DE"
var not_before = "20210425000000"
var not_after = "20220426000000"

func _ready() -> void:
	var cert_dir: = Directory.new()
	if not cert_dir.dir_exists(cert_dir_path):
		cert_dir.make_dir(cert_dir_path)
	var crypto = Crypto.new()
	var crypto_key = crypto.generate_rsa(4096)
	var crypto_cert = crypto.generate_self_signed_certificate(crypto_key, credentials, not_before, not_after)
	crypto_key.save(key_path)
	crypto_cert.save(cert_path)
	print("certificate generated.")
