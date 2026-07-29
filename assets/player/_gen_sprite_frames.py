"""Genera player/iltzan_sprite_frames.tres desde los PNG en assets/player."""
from pathlib import Path

ASSETS = Path(__file__).resolve().parent
OUT = ASSETS.parent.parent / "player" / "iltzan_sprite_frames.tres"

ANIMATIONS: dict[str, tuple[list[str], bool, float]] = {
	"attack": (["iltzan_attack_1.png"], False, 10.0),
	"attack_fire": (["iltzan_attack_2.png"], False, 10.0),
	"crouch": (["iltzan_crouch.png"], True, 5.0),
	"dash": (["iltzan_dash.png"], False, 10.0),
	"fall": (["iltzan_fall.png"], True, 5.0),
	"hurt": (["iltzan_hurt.png"], False, 8.0),
	"idle": (
		["iltzan_idle.png"] + [f"iltzan_idle_{i}.png" for i in range(1, 7)],
		True,
		8.0,
	),
	"jump": (["iltzan_jump.png"], False, 5.0),
	"run": (["iltzan_run_1.png", "iltzan_run_2.png"], True, 10.0),
	"victory": ([f"iltzan_victory_{i}.png" for i in range(1, 7)], True, 8.0),
}


def main() -> None:
	unique: list[str] = []
	index: dict[str, int] = {}

	def ext_id(name: str) -> int:
		if name not in index:
			index[name] = len(unique) + 1
			unique.append(name)
		return index[name]

	for files, _, _ in ANIMATIONS.values():
		for file_name in files:
			ext_id(file_name)

	lines: list[str] = [
		f'[gd_resource type="SpriteFrames" load_steps={len(unique) + 1} format=3 uid="uid://iltzanspriteframes"]',
		"",
	]
	for i, name in enumerate(unique, start=1):
		lines.append(f'[ext_resource type="Texture2D" path="res://assets/player/{name}" id="{i}"]')

	lines.append("")
	lines.append("[resource]")
	lines.append("animations = [")

	anim_blocks: list[str] = []
	for anim_name, (files, loop, speed) in ANIMATIONS.items():
		frames = ", ".join(
			'{"duration": 1.0, "texture": ExtResource("%d")}' % ext_id(file_name)
			for file_name in files
		)
		anim_blocks.append(
			"{\n"
			f'"frames": [{frames}],\n'
			f'"loop": {"true" if loop else "false"},\n'
			f'"name": &"{anim_name}",\n'
			f'"speed": {speed:.1f}\n'
			"}"
		)

	lines.append(", ".join(anim_blocks) + "]")
	OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
	print(f"Wrote {OUT} ({len(unique)} textures, {len(ANIMATIONS)} animations)")


if __name__ == "__main__":
	main()
