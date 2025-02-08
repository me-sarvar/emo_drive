import cv2

# Set up video capture from the webcam
video_capture = cv2.VideoCapture(1)  # Use 0 for the default camera

# Define the codec and create VideoWriter object using the static method
fourcc = cv2.VideoWriter.fourcc('M', 'P', '4', 'V')  # Codec for MP4
output_file = 'captured_video.mp4'
fps = 20.0  # Frames per second
frame_width = int(video_capture.get(cv2.CAP_PROP_FRAME_WIDTH))  # Width of the video frame
frame_height = int(video_capture.get(cv2.CAP_PROP_FRAME_HEIGHT))  # Height of the video frame
out = cv2.VideoWriter(output_file, fourcc, fps, (frame_width, frame_height))

# Record for 8 seconds
start_time = cv2.getTickCount()
duration = 8  # Duration in seconds

while True:
    ret, frame = video_capture.read()
    if not ret:
        break  # Break the loop if no frame is captured

    out.write(frame)  # Write the frame to the video file

    # Show the frame in a window
    cv2.imshow('Video Capture', frame)

    # Check if 8 seconds have passed
    elapsed_time = (cv2.getTickCount() - start_time) / cv2.getTickFrequency()
    if elapsed_time > duration:
        break

    # Exit if 'q' is pressed
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# Release everything
video_capture.release()
out.release()
cv2.destroyAllWindows()

print(f"Video saved as '{output_file}'")
