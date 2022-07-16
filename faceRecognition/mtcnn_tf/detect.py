from mtcnn import MTCNN
import time
import cv2

# Get a reference to webcam #0 (the default one)
video_capture = cv2.VideoCapture(0)
detector = MTCNN()

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

    rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

    face_locations = detector.detect_faces(rgb)

    # Display the results
    for item in face_locations:
        x, y, w, h = item['box']
        top, right, bottom, left = y, x + w, y + h, x

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