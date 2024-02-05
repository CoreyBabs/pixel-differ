// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use std::fs::File;
use image::{GenericImage, GenericImageView, DynamicImage, ImageBuffer, Pixel, Rgb, codecs::gif::GifEncoder, EncodableLayout};

fn main() {
  tauri::Builder::default()
    .invoke_handler(tauri::generate_handler![corrupt_image])
    .run(tauri::generate_context!())
    .expect("error while running tauri application");
}

// #[tauri::command]
// fn greet(name: &str) -> String {
//   format!("Hello, {}!", name)
// }

#[tauri::command]
fn corrupt_image(input_path: &str, threshold: u8) -> &str {
  println!("{}", input_path);
  let img = image::open(input_path).unwrap();
  let output_path = "/home/corey/src/pixel-differ/rust/simple.gif";

  simple_corruption(&img, output_path, threshold);

  output_path
}

fn simple_corruption(img: &DynamicImage, output_path: &str, threshold: u8) {
  let num_steps = 255 as f32 / threshold as f32;
  let num_steps = num_steps.ceil() as u8;

  let mut next_frame = img.to_rgb8();
  println!("{}", num_steps);
  let mut gif_file = File::create(output_path).expect("File cannot be created");
  let mut gif = GifEncoder::new(&mut gif_file);
  let _ = gif.set_repeat(image::codecs::gif::Repeat::Infinite);
  for i in 0..(num_steps + 1) {
    let mut frame = ImageBuffer::new(img.width(), img.height());
    println!("New frame: {}", i);
    for (x, y, pixel) in next_frame.enumerate_pixels() {
      let new_pixel = Rgb::from([
        pixel.0[0].wrapping_add(threshold),
        pixel.0[1].wrapping_add(threshold),
        pixel.0[2].wrapping_add(threshold)]);
      frame.put_pixel(x, y, new_pixel);
    } 

    let _ = gif.encode(frame.as_bytes(), img.width(), img.height(), image::ColorType::Rgb8);
    next_frame = frame;
  }
} 
