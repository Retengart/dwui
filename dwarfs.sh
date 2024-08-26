#!/bin/bash

# Function to mount a DwarFS filesystem
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



  dwarfs-u --tool=dwarfs "$input_file" "$mount_point"

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

# Function to create a DwarFS image
create_dwarfs_image() {
  local input_folder=$(zenity --file-selection --directory --title="Select Input Folder")
  if [ -z "$input_folder" ]; then
    zenity --error --text="No input folder selected!"
    exit 1
  fi

  local output_file=$(zenity --file-selection --filename=new --save --confirm-overwrite --title="Save DwarFS Image As")
  if [ -z "$output_file" ]; then
    zenity --error --text="No output file specified!"
    exit 1
  fi

  dwarfs-u --tool=mkdwarfs -i "$input_folder" -o "$output_file.dwarfs"
  if [ $? -eq 0 ]; then
    zenity --info --text="DwarFS image created successfully at $output_file"
  else
    zenity --error --text="Failed to create DwarFS image!"
  fi
}

# Main GUI to choose between mount, unmount, and create image
choice=$(zenity --list --title="DwarFS GUI" --column="Action" "Mount" "Unmount" "Create Image" --height=350 --width=300)

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
  *)
    zenity --error --text="Invalid choice!"
    exit 1
    ;;
esac
