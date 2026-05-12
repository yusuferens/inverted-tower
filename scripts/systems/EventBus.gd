extends Node

signal player_damaged(amount: int)
signal player_died
signal player_respawned(position: Vector2)
signal player_healed(amount: int)
signal sanity_changed(value: int)
signal sanity_depleted
signal lore_collected(scroll_id: String)
signal zone_changed(zone_index: int)
signal enemy_died(enemy: Node)
signal boss_hit(current_hp: int, max_hp: int)
signal boss_died
signal boss_phase_changed(phase: int)
signal boss_sound_rupture(duration: float)
signal camera_shake(intensity: float, duration: float)
signal checkpoint_reached(position: Vector2)
signal show_dialogue(speaker: String, text: String)
signal hide_dialogue
signal show_info(text: String)
signal health_changed(current: int, max_val: int)
signal stamina_changed(current: float, max_val: float)
signal potions_changed(count: int)
