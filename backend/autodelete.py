import os
import time

# Set the folder path you want to monitor
folder_path = './data'

# Set the time in seconds after which files should be deleted
delete_after = 100

def delete_old_files():
    # Get the current time
    current_time = time.time()

    # Loop through all files in the folder
    for filename in os.listdir(folder_path):
        file_path = os.path.join(folder_path, filename)

        # Only delete files, not directories
        if os.path.isfile(file_path):
            # Check the last modified time of the file
            file_age = current_time - os.path.getmtime(file_path)

            # Delete the file if it's older than the specified time
            if file_age > delete_after:
                print(f"Deleting file: {filename}")
                os.remove(file_path)

while True:
    delete_old_files()
    time.sleep(10)  # Check every 10 seconds
