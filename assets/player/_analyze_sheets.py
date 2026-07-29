from PIL import Image
import numpy as np
from pathlib import Path


def analyze_sheet(path: Path, bg_thresh: int = 30) -> list[dict]:
	im = Image.open(path).convert("RGBA")
	arr = np.array(im)
	rgb = arr[:, :, :3].astype(int)
	alpha = arr[:, :, 3]
	is_bg = (alpha < 20) | (
		(rgb[:, :, 0] < bg_thresh)
		& (rgb[:, :, 1] < bg_thresh)
		& (rgb[:, :, 2] < bg_thresh)
	)
	is_fg = ~is_bg
	h, w = is_fg.shape
	col_fg = is_fg.any(axis=0)

	segments: list[tuple[int, int]] = []
	in_frame = False
	start = 0
	for x in range(w):
		if col_fg[x] and not in_frame:
			start = x
			in_frame = True
		elif not col_fg[x] and in_frame:
			segments.append((start, x - 1))
			in_frame = False
	if in_frame:
		segments.append((start, w - 1))

	frames: list[dict] = []
	for x0, x1 in segments:
		seg = is_fg[:, x0 : x1 + 1]
		ys = np.where(seg.any(axis=1))[0]
		xs = np.where(seg.any(axis=0))[0]
		if len(xs) == 0:
			continue
		frames.append(
			{
				"x0": x0,
				"x1": x1,
				"w": x1 - x0 + 1,
				"content_x": x0 + xs[0],
				"content_w": xs[-1] - xs[0] + 1,
				"content_y": ys[0],
				"content_h": ys[-1] - ys[0] + 1,
			}
		)
	return frames


def main() -> None:
	src = Path(__file__).resolve().parent / "_extract" / "itzan sprites"
	for p in sorted(src.glob("*.png")):
		frames = analyze_sheet(p)
		print(f"{p.stem}: {len(frames)} frames")
		for i, f in enumerate(frames):
			print(
				f"  {i}: col [{f['x0']}-{f['x1']}] "
				f"content {f['content_w']}x{f['content_h']} at y={f['content_y']}"
			)


if __name__ == "__main__":
	main()
