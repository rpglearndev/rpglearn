extends Node
## Autoload: carga data/mvp al inicio (US-090).

const MvpDataLoader := preload("res://scripts/data/mvp_data_loader.gd")
const MvpDataStore := preload("res://scripts/data/mvp_data_store.gd")

var store: MvpDataStore = null


func _ready() -> void:
	reload()


func reload() -> bool:
	var loaded = MvpDataLoader.load_all()
	if loaded == null:
		store = null
		return false
	store = loaded
	return true


func is_loaded() -> bool:
	return store != null
