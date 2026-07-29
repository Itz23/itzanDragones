"""Extrae frames de las hojas de sprites y genera PNG listos para Godot."""
from __future__ import annotations

import shutil
from pathlib import Path

import numpy as np
from PIL import Image


ROOT = Path(__file__).resolve().parent
EXTRACT = ROOT / "_extract" / "itzan sprites"
OUT = ROOT

STAND_SIZE = (28, 44)
CROUCH_SIZE = (28, 24)
FOOT_PADDING = 2


def is_background_pixel(r: int, g: int, b: int, a: int, bg_thresh: int = 30) -> bool:
	if a < 20:
		return True
	if abs(r - g) <= 12 and abs(g - b) <= 12 and r >= 90:
		return True
	return r < bg_thresh and g < bg_thresh and b < bg_thresh


def sheet_to_array(path: Path) -> np.ndarray:
	return np.array(Image.open(path).convert("RGBA"))


def find_segments(arr: np.ndarray, min_width: int = 20) -> list[tuple[int, int]]:
	h, w, _ = arr.shape
	col_fg = np.zeros(w, dtype=bool)
	for x in range(w):
		for y in range(h):
			p = arr[y, x]
			if not is_background_pixel(int(p[0]), int(p[1]), int(p[2]), int(p[3])):
				col_fg[x] = True
				break

	segments: list[tuple[int, int]] = []
	in_frame = False
	start = 0
	for x in range(w):
		if col_fg[x] and not in_frame:
			start = x
			in_frame = True
		elif not col_fg[x] and in_frame:
			if x - start >= min_width:
				segments.append((start, x - 1))
			in_frame = False
	if in_frame and w - start >= min_width:
		segments.append((start, w - 1))
	return segments


def split_segment(arr: np.ndarray, x0: int, x1: int, frame_count: int) -> list[Image.Image]:
	width = x1 - x0 + 1
	frame_w = width // frame_count
	frames: list[Image.Image] = []
	for i in range(frame_count):
		fx0 = x0 + i * frame_w
		fx1 = fx0 + frame_w - 1
		frames.append(Image.fromarray(arr[:, fx0 : fx1 + 1]))
	return frames


def crop_to_content(img: Image.Image) -> Image.Image:
	arr = np.array(img)
	h, w, _ = arr.shape
	ys: list[int] = []
	xs: list[int] = []
	for y in range(h):
		for x in range(w):
			p = arr[y, x]
			if not is_background_pixel(int(p[0]), int(p[1]), int(p[2]), int(p[3])):
				ys.append(y)
				xs.append(x)
	if not xs:
		return img
	return img.crop((min(xs), min(ys), max(xs) + 1, max(ys) + 1))


def fit_to_canvas(img: Image.Image, canvas: tuple[int, int]) -> Image.Image:
	cropped = crop_to_content(img)
	cw, ch = canvas
	scale = min(cw / cropped.width, (ch - FOOT_PADDING) / cropped.height)
	new_w = max(1, int(cropped.width * scale))
	new_h = max(1, int(cropped.height * scale))
	resized = cropped.resize((new_w, new_h), Image.NEAREST)
	canvas_img = Image.new("RGBA", canvas, (0, 0, 0, 0))
	x = (cw - new_w) // 2
	y = ch - FOOT_PADDING - new_h
	canvas_img.paste(resized, (x, y), resized)
	return canvas_img


def save_frame(img: Image.Image, name: str, canvas: tuple[int, int]) -> None:
	fit_to_canvas(img, canvas).save(OUT / name)


def extract_frames(path: Path, frame_counts: list[int]) -> list[Image.Image]:
	arr = sheet_to_array(path)
	segments = find_segments(arr)
	if len(segments) != len(frame_counts):
		raise ValueError(f"{path.name}: expected {len(frame_counts)} segments, got {len(segments)}")
	frames: list[Image.Image] = []
	for (x0, x1), count in zip(segments, frame_counts):
		frames.extend(split_segment(arr, x0, x1, count))
	return frames


def extract_victory_frames(path: Path, frame_count: int = 6) -> list[Image.Image]:
	arr = sheet_to_array(path)
	_, w, _ = arr.shape
	frame_w = w // frame_count
	frames: list[Image.Image] = []
	for i in range(frame_count):
		x0 = i * frame_w
		x1 = x0 + frame_w - 1
		frames.append(Image.fromarray(arr[:, x0 : x1 + 1]))
	return frames


def build() -> None:
	idle_frames = extract_frames(EXTRACT / "idle.png", [1, 6])
	run_frames = extract_frames(EXTRACT / "run.png", [1, 4, 4])
	jump_frames = extract_frames(EXTRACT / "jump.png", [1, 1])
	hurt_frames = extract_frames(EXTRACT / "hurt.png", [1, 1, 1])
	fall_frames = extract_frames(EXTRACT / "fall.png", [1])

	save_frame(idle_frames[0], "iltzan_idle.png", STAND_SIZE)
	for i, frame in enumerate(idle_frames[1:7], start=1):
		save_frame(frame, f"iltzan_idle_{i}.png", STAND_SIZE)
	save_frame(run_frames[0], "iltzan_run_1.png", STAND_SIZE)
	save_frame(run_frames[1], "iltzan_run_2.png", STAND_SIZE)
	save_frame(jump_frames[0], "iltzan_jump.png", STAND_SIZE)
	save_frame(fall_frames[0], "iltzan_fall.png", STAND_SIZE)
	save_frame(hurt_frames[0], "iltzan_hurt.png", STAND_SIZE)
	save_frame(idle_frames[0], "iltzan_crouch.png", CROUCH_SIZE)
	save_frame(run_frames[5], "iltzan_attack_1.png", STAND_SIZE)
	save_frame(run_frames[6], "iltzan_attack_2.png", STAND_SIZE)
	save_frame(jump_frames[1], "iltzan_dash.png", STAND_SIZE)

	victory_src = EXTRACT / "victory.png"
	victory_frames = extract_victory_frames(victory_src, 6)
	for i, frame in enumerate(victory_frames, start=1):
		save_frame(frame, f"iltzan_victory_{i}.png", STAND_SIZE)

	print("Sprites generados en", OUT)
	print(f"  idle: {len(idle_frames)} frames")
	print(f"  run: {len(run_frames)} frames")
	print(f"  victory: {len(victory_frames)} frames")


if __name__ == "__main__":
	victory_user = Path(
		r"C:\Users\usuario\.cursor\projects\c-PROYECTO-ITZAN-itzanDragones\assets"
		r"\c__Users_usuario_AppData_Roaming_Cursor_User_workspaceStorage_empty-window_images"
		r"_victoria-b5364504-c22a-4e40-9ef2-09e479c3f95a.png"
	)
	if victory_user.exists():
		shutil.copy2(victory_user, EXTRACT / "victory.png")
	build()
