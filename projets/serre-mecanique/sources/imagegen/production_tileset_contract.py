"""Pixel-level production checks shared by generated 32x32 tilesets."""

from __future__ import annotations

from PIL import Image


def tile(sheet: Image.Image, tile_id: int, columns: int = 16, size: int = 32) -> Image.Image:
    x = (tile_id % columns) * size
    y = (tile_id // columns) * size
    return sheet.crop((x, y, x + size, y + size)).convert("RGBA")


def assert_opaque(sheet: Image.Image, tile_id: int, *, label: str = "solid") -> None:
    alpha = tile(sheet, tile_id).getchannel("A")
    assert alpha.getextrema() == (255, 255), f"{label} tile {tile_id} is not fully opaque"


def assert_horizontal_join(sheet: Image.Image, left_id: int, right_id: int, *, rows=range(32)) -> None:
    left = tile(sheet, left_id)
    right = tile(sheet, right_id)
    for y in rows:
        assert left.getpixel((31, y)) == right.getpixel((0, y)), (
            f"horizontal RGB seam between tiles {left_id} and {right_id} at y={y}"
        )


def assert_vertical_join(sheet: Image.Image, top_id: int, bottom_id: int, *, columns=range(32)) -> None:
    top = tile(sheet, top_id)
    bottom = tile(sheet, bottom_id)
    for x in columns:
        assert top.getpixel((x, 31)) == bottom.getpixel((x, 0)), (
            f"vertical RGB seam between tiles {top_id} and {bottom_id} at x={x}"
        )


def assert_no_horizontal_frame(sheet: Image.Image, tile_id: int) -> None:
    current = tile(sheet, tile_id)
    for y in range(32):
        assert current.getpixel((0, y)) == current.getpixel((1, y)), f"left painted frame in tile {tile_id}"
        assert current.getpixel((30, y)) == current.getpixel((31, y)), f"right painted frame in tile {tile_id}"
