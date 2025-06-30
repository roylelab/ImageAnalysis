import numpy as np
import tifffile
import imageio.v2 as imageio
import csv
import os
import sys

def extract_pixel_values_in_masks(directory):
    """
    For each TIFF movie file in the directory, finds the corresponding mask file (with _mask.tif suffix),
    extracts pixel values in the mask for each frame and channel, and saves to a CSV file with the same base name.
    """
    for filename in os.listdir(directory):
        if filename.endswith('.tif') and not filename.endswith('_mask.tif'):
            movie_path = os.path.join(directory, filename)
            base = filename[:-4]
            mask_filename = f"{base}_mask.tif"
            mask_path = os.path.join(directory, mask_filename)
            output_csv = os.path.join(directory, f"{base}.csv")
            if not os.path.exists(mask_path):
                print(f"Mask file not found for {filename}, skipping.")
                continue

            # Load the TIFF movie (assume shape: frames x channels x height x width or frames x height x width x channels)
            movie = tifffile.imread(movie_path)
            # Ensure movie shape is (frames, channels, height, width)
            if movie.ndim == 4:
                if movie.shape[1] == 2:  # (frames, channels, height, width)
                    frames, channels, height, width = movie.shape
                elif movie.shape[-1] == 2:  # (frames, height, width, channels)
                    movie = np.moveaxis(movie, -1, 1)
                    frames, channels, height, width = movie.shape
                else:
                    print(f"Movie {filename} does not have 2 channels, skipping.")
                    continue
            else:
                print(f"Movie {filename} is not 4D, skipping.")
                continue

            # Load the mask (assume single channel, same height/width as movie)
            mask = imageio.imread(mask_path)
            if mask.ndim == 3:
                mask = mask[..., 0]
            mask = mask > 0  # Ensure binary

            if mask.shape != (height, width):
                print(f"Mask shape does not match movie frame size for {filename}, skipping.")
                continue

            # Prepare output: list of [pixel_value, frame, channel]
            output_rows = []

            for frame in range(frames):
                for channel in range(channels):
                    img = movie[frame, channel]
                    masked_pixels = img[mask]
                    for val in masked_pixels:
                        output_rows.append([val, frame, channel])

            # Save to CSV
            with open(output_csv, 'w', newline='') as f:
                writer = csv.writer(f)
                writer.writerow(['pixel_value', 'frame', 'channel'])
                writer.writerows(output_rows)
            print(f"Saved: {output_csv}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: python {os.path.basename(__file__)} <directory>")
        sys.exit(1)
    extract_pixel_values_in_masks(sys.argv[1])