import face_recognition as fr
import cv2
import time

# Get a reference to webcam #0 (the default one)
video_capture = cv2.VideoCapture(0)

# Initialize some variables
face_locations = []

fps_time = time.time()
fps_counter = 0
fps = 0

while True:
    t = time.time()
    if t - fps_time >= 1:
        fps = fps_counter
        fps_counter = 0
        fps_time = t
    fps_counter += 1

    # Grab a single frame of video
    ret, frame = video_capture.read()

    # Convert the image from BGR color (which OpenCV uses) to RGB color (which fr uses)
    rgb_frame = frame[:, :, ::-1]

    # Find all the faces and face encodings in the current frame of video
    face_locations = fr.face_locations(rgb_frame, model="cnn")

    # Display the results
    for top, right, bottom, left in face_locations:
        # Draw a box around the face
        cv2.rectangle(frame, (left, top), (right, bottom), (0, 255, 0), 2)

    font = cv2.FONT_HERSHEY_DUPLEX
    cv2.putText(frame, "FPS: %d" % fps, (10, 100), font, 1.0, (255, 255, 255), 1)

    # Display the resulting image
    cv2.imshow('Video', frame)

    # Hit 'q' on the keyboard to quit!
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# Release handle to the webcam
video_capture.release()
cv2.destroyAllWindows()