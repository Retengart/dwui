#!/bin/bash
zenity(){
    /usr/bin/zenity "$@" 2>/dev/null
}

# Function to mount a DwarFS filesystem with real-time output
mount_dwarfs() {
  local input_file=$(zenity --file-selection --title="Select DwarFS Image" --file-filter="*.dwarfs")
  if [ -z "$input_file" ]; then
    zenity --error --text="No file selected!"
    exit 1
  fi

  local mount_point=$(zenity --file-selection --directory --title="Select Mount Point")
  if [ -z "$mount_point" ]; then
    zenity --error --text="No mount point selected!"
    exit 1
  fi

  # Run the command and display output in a Zenity progress dialog
  (
    echo "# Mounting $input_file to $mount_point..."
    dwarfs-u --tool=dwarfs "$input_file" "$mount_point" 2>&1 | while read -r line; do
      echo "# $line"
    done
    echo "100" # Indicate completion
  ) | zenity --progress --title="Mounting DwarFS" --text="Initializing..." --auto-close --no-cancel

  if [ $? -eq 0 ]; then
    zenity --info --text="Mounted successfully at $mount_point"
  else
    zenity --error --text="Failed to mount the filesystem!"
  fi
}

# Function to unmount a DwarFS filesystem
unmount_dwarfs() {
  local mount_point=$(zenity --file-selection --directory --title="Select Mount Point to Unmount")
  if [ -z "$mount_point" ]; then
    zenity --error --text="No mount point selected!"
    exit 1
  fi

  fusermount -u "$mount_point"
  if [ $? -eq 0 ]; then
    zenity --info --text="Unmounted successfully from $mount_point"
  else
    zenity --error --text="Failed to unmount the filesystem!"
  fi
}

# Function to create a DwarFS image with real-time output
create_dwarfs_image() {
  local input_folder=$(zenity --file-selection --directory --title="Select Input Folder")
  if [ -z "$input_folder" ]; then
    zenity --error --text="No input folder selected!"
    exit 1
  fi

  local output_file=$(zenity --file-selection --filename=new --save --title="Save DwarFS Image As")
  if [ -z "$output_file" ]; then
    zenity --error --text="No output file specified!"
    exit 1
  fi

  # Run the command and display output in a Zenity progress dialog
  (
    echo "# Creating DwarFS image from $input_folder..."
    dwarfs-u --tool=mkdwarfs -i "$input_folder" -o "$output_file.dwarfs" 2>&1 | while read -r line; do
      echo "# $line"
    done
    echo "100" # Indicate completion
  ) | zenity --progress --title="Creating DwarFS Image" --text="Initializing..." --auto-close --auto-kill

  if [ $? -eq 0 ]; then
    zenity --info --text="DwarFS image created successfully at $output_file"
  else
    zenity --error --text="Failed to create DwarFS image or operation was canceled!"
  fi
}

# Function to extract a DwarFS image
extract_dwarfs_image() {
  local input_file=$(zenity --file-selection --title="Select DwarFS Image to Extract" --file-filter="*.dwarfs")
  if [ -z "$input_file" ]; then
    zenity --error --text="No file selected!"
    exit 1
  fi

  local output_dir=$(zenity --file-selection --directory --title="Select Output Directory")
  if [ -z "$output_dir" ]; then
    zenity --error --text="No output directory selected!"
    exit 1
  fi

  # Run the command and display output in a Zenity progress dialog
  (
    echo "# Extracting $input_file to $output_dir..."
    dwarfs-u --tool=dwarfsextract -i "$input_file" -o "$output_dir" 2>&1 | while read -r line; do
      echo "# $line"
    done
    echo "100" # Indicate completion
  ) | zenity --progress --title="Extracting DwarFS Image" --text="Initializing..." --auto-close --no-cancel

  if [ $? -eq 0 ]; then
    zenity --info --text="DwarFS image extracted successfully to $output_dir"
  else
    zenity --error --text="Failed to extract the DwarFS image!"
  fi
}

# Main GUI to choose between mount, unmount, create image, and extract image
choice=$(zenity --list --title="DwarFS GUI" --column="Action" "Create Image" "Mount" "Unmount" "Extract Image" --height=350 --width=300)

case $choice in
  "Mount")
    mount_dwarfs
    ;;
  "Unmount")
    unmount_dwarfs
    ;;
  "Create Image")
    create_dwarfs_image
    ;;
  "Extract Image")
    extract_dwarfs_image
    ;;
  *)
    zenity --error --text="Invalid choice!"
    exit 1
    ;;
esac
