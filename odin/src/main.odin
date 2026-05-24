package src

import "base:runtime"
import "core:c"
import "core:fmt"
import "core:mem"
import "core:strings"

import rl "vendor:raylib"

DIM :: 1024

main :: proc () {
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.printf("=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.printf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}

			mem.tracking_allocator_destroy(&track)
		}
	}

	rl.InitWindow(DIM, DIM, "Pixel Differ")
	rl.SetTargetFPS(60)

	texture : rl.Texture2D
	image : rl.Image
	
	builder : strings.Builder
	strings.builder_init_len_cap(&builder, 0, 4096)
	defer strings.builder_destroy(&builder)

	path := strings.to_cstring(&builder)
	fmt.printfln("%v", path)

	threshold : c.int = 10
	text_editing := false
	threshold_editing := false
	corrupting := false
	show_err := false 
	image_loaded := false

	frame_delay := 5
	frame_count := 0

	path_label_rect := rl.Rectangle { 5, 5, 60, 50 }
	path_rect := rl.Rectangle { 65, 5, DIM/2, 50 }
	threshold_label_rect := rl.Rectangle { 5, 55, 60, 50 }
	threshold_rect := rl.Rectangle { 65, 55, 50, 50 }
	corrupt_rect := rl.Rectangle { 5, 105, 50, 50 }
	load_rect := rl.Rectangle { 585, 5, 65, 50 }
	msg_rect := rl.Rectangle { DIM/2, DIM/2, 150, 100 }
	for !rl.WindowShouldClose() {
		if rl.IsFileDropped() && !image_loaded {
			files := rl.LoadDroppedFiles()
			image = load_image(files.paths[0], 160)

			texture = rl.LoadTextureFromImage(image)
			image_loaded = true
			rl.UnloadDroppedFiles(files)
		}


		rl.BeginDrawing()
		rl.ClearBackground(rl.WHITE)


		rl.GuiLabel(path_label_rect, "Image path:")
		if rl.GuiTextBox(path_rect, path, 64, text_editing) {
			text_editing = !text_editing
		}

		if rl.GuiButton(load_rect, "Load Image") {
			if !corrupting && !rl.FileExists(path) {
				show_err = true
			}
			else if !corrupting {
				image = load_image(path, 160)
				texture = rl.LoadTextureFromImage(image)
				image_loaded = true
			}
		}

		rl.GuiValueBox(threshold_rect, "Threshold:", &threshold, 1, 255, !text_editing && !corrupting)

		if rl.GuiButton(corrupt_rect, "Corrupt") {
			corrupting = !corrupting
			if corrupting && !image_loaded && !rl.IsFileNameValid(path) {
				corrupting = false
				show_err = true
			}
			else if corrupting {
				text_editing = false
				frame_count = frame_delay
			}
		}

		if corrupting && frame_count == frame_delay {
			corrupt_image(&image, u8(threshold))
			rl.UpdateTexture(texture, image.data)
			frame_count = 0
		}

		if image_loaded {
			rl.DrawTexture(texture, 0, 160, rl.WHITE)
		}

		if show_err {
			result := rl.GuiMessageBox(msg_rect, "Error", "Failed to load image file.", "Ok")
			if result == 1 {
				show_err = false
				text_editing = true
			}
		}



		// rl.DrawText("Hello, World!", 512, 512, 20, rl.BLACK)
		frame_count += 1
		rl.EndDrawing()
	}

	rl.UnloadTexture(texture)
	rl.UnloadImage(image)
	rl.CloseWindow()
}

load_image :: proc(path: cstring, height: i32) -> rl.Image {
	img := rl.LoadImage(path)
	rl.ImageResize(&img, DIM, DIM - height)
	return img
}

corrupt_image :: proc(img: ^rl.Image, threshold: u8) {
	colors := rl.LoadImageColors(img^)
	size := img.width * img.height

	for i in 0..<size {
		color := colors[i]
		color[0] += threshold 
		color[1] += threshold 
		color[2] += threshold 

		rl.ImageDrawPixel(img, i % img.width, i/img.width, color)
	}
}
