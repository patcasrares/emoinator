import cv2
import time

frontalcascPath = "./haarcascade_frontalface_default.xml"
frontFaceCascade = cv2.CascadeClassifier(frontalcascPath)

video_capture = cv2.VideoCapture(0)

config = {
    "scaleFactor": 1.1,
    "minNeighbors": 5,
    "minSize": (30, 30)
}

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
    ret, frame = video_capture.read()

    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

    faces = []

    front_faces = frontFaceCascade.detectMultiScale(gray, **config)
    for face in front_faces:
        faces.append(face)

    # Draw a rectangle around the faces
    for (x, y, w, h) in faces:
        cv2.rectangle(frame, (x, y), (x+w, y+h), (0, 255, 0), 2)

    font = cv2.FONT_HERSHEY_DUPLEX
    cv2.putText(frame, "FPS: %d" % fps, (10, 100), font, 1.0, (255, 255, 255), 1)

    # Display the resulting frame
    cv2.imshow('Video', frame)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# When everything is done, release the capture
video_capture.release()
cv2.destroyAllWindows()
