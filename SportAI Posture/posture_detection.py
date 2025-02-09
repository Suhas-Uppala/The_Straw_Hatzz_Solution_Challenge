import cv2
import mediapipe as mp
import math
import threading
from playsound import playsound

# Constants for exercise angles
HAND_RAISE_MIN_ANGLE = 150  # Minimum angle for hand raise
HAND_CURL_MAX_ANGLE = 120  # Maximum angle for hand curl


class ExerciseDetector:
    def __init__(self):
        self.running = False
        self.exercise_type = "hand_raise"
        self.cap = None
        self.detection_thread = None

    def calculate_angle(self, a, b, c):
        """Calculates angle at point b"""
        ba = (a[0] - b[0], a[1] - b[1])
        bc = (c[0] - b[0], c[1] - b[1])

        dot_product = ba[0] * bc[0] + ba[1] * bc[1]
        magnitude_ba = math.sqrt(ba[0] ** 2 + ba[1] ** 2)
        magnitude_bc = math.sqrt(bc[0] ** 2 + bc[1] ** 2)

        if magnitude_ba * magnitude_bc == 0:
            return 0

        angle_rad = math.acos(dot_product / (magnitude_ba * magnitude_bc))
        return math.degrees(angle_rad)

    def is_exercise_incorrect(self, shoulder_angle, elbow_angle, exercise_type):
        """Check if exercise form is incorrect"""
        if exercise_type == "hand_raise":
            return (
                shoulder_angle < HAND_RAISE_MIN_ANGLE
            )  # Only detect if arm not raised enough
        elif exercise_type == "hand_curl":
            return (
                elbow_angle > HAND_CURL_MAX_ANGLE
            )  # Only detect if arm extended too much
        return False

    def play_alarm_sound(self):
        try:
            playsound("alarm.wav")
        except Exception as e:
            print("Error playing sound:", e)

    def get_landmark_coords(self, landmarks, landmark_point, w, h):
        """Get coordinates for a landmark point"""
        return (
            int(landmarks[landmark_point].x * w),
            int(landmarks[landmark_point].y * h),
        )

    def detection_loop(self):
        self.cap = cv2.VideoCapture(0)
        if not self.cap.isOpened():
            print("Error: Could not open camera.")
            return

        mp_pose = mp.solutions.pose
        pose = mp_pose.Pose(min_detection_confidence=0.5, min_tracking_confidence=0.5)
        mp_draw = mp.solutions.drawing_utils

        wrong_form_counter = 0
        threshold_wrong_frames = 30

        while self.running and self.cap.isOpened():
            ret, frame = self.cap.read()
            if not ret:
                break

            frame = cv2.flip(frame, 1)
            image_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            image_rgb.flags.writeable = False
            results = pose.process(image_rgb)
            image_rgb.flags.writeable = True
            image = cv2.cvtColor(image_rgb, cv2.COLOR_RGB2BGR)

            if results.pose_landmarks:
                mp_draw.draw_landmarks(
                    image, results.pose_landmarks, mp_pose.POSE_CONNECTIONS
                )

                h, w, _ = image.shape
                landmarks = results.pose_landmarks.landmark

                # Get required landmarks
                left_wrist = self.get_landmark_coords(
                    landmarks, mp_pose.PoseLandmark.LEFT_WRIST.value, w, h
                )
                left_elbow = self.get_landmark_coords(
                    landmarks, mp_pose.PoseLandmark.LEFT_ELBOW.value, w, h
                )
                left_shoulder = self.get_landmark_coords(
                    landmarks, mp_pose.PoseLandmark.LEFT_SHOULDER.value, w, h
                )
                left_hip = self.get_landmark_coords(
                    landmarks, mp_pose.PoseLandmark.LEFT_HIP.value, w, h
                )

                # Calculate angles
                shoulder_angle = self.calculate_angle(
                    left_elbow, left_shoulder, left_hip
                )
                elbow_angle = self.calculate_angle(
                    left_wrist, left_elbow, left_shoulder
                )

                # Display exercise info
                cv2.putText(
                    image,
                    f'Exercise: {self.exercise_type.replace("_", " ").title()}',
                    (10, 30),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    0.7,
                    (255, 255, 255),
                    2,
                )

                # Display relevant angle
                if self.exercise_type == "hand_raise":
                    cv2.putText(
                        image,
                        f"Shoulder Angle: {int(shoulder_angle)}°",
                        (10, 60),
                        cv2.FONT_HERSHEY_SIMPLEX,
                        0.7,
                        (255, 255, 255),
                        2,
                    )
                else:
                    cv2.putText(
                        image,
                        f"Elbow Angle: {int(elbow_angle)}°",
                        (10, 60),
                        cv2.FONT_HERSHEY_SIMPLEX,
                        0.7,
                        (255, 255, 255),
                        2,
                    )

                # Check exercise form and display warnings
                if self.is_exercise_incorrect(
                    shoulder_angle, elbow_angle, self.exercise_type
                ):
                    wrong_form_counter += 1

                    # Display specific warnings for incorrect form
                    if self.exercise_type == "hand_raise":
                        cv2.putText(
                            image,
                            "Warning: Raise your arm higher",
                            (10, 90),
                            cv2.FONT_HERSHEY_SIMPLEX,
                            0.7,
                            (0, 0, 255),
                            2,
                        )
                    else:  # hand_curl
                        cv2.putText(
                            image,
                            "Warning: Curl your arm more",
                            (10, 90),
                            cv2.FONT_HERSHEY_SIMPLEX,
                            0.7,
                            (0, 0, 255),
                            2,
                        )

                    # Trigger alarm after threshold
                    if wrong_form_counter >= threshold_wrong_frames:
                        cv2.putText(
                            image,
                            "ALARM: Fix Your Form!",
                            (50, 50),
                            cv2.FONT_HERSHEY_SIMPLEX,
                            1,
                            (0, 0, 255),
                            3,
                        )
                        threading.Thread(
                            target=self.play_alarm_sound, daemon=True
                        ).start()
                        wrong_form_counter = 0
                else:
                    wrong_form_counter = 0
                    cv2.putText(
                        image,
                        "Good Form!",
                        (10, 90),
                        cv2.FONT_HERSHEY_SIMPLEX,
                        0.7,
                        (0, 255, 0),
                        2,
                    )

            cv2.imshow("Exercise Monitor", image)

            key = cv2.waitKey(1) & 0xFF
            if key == 27:  # ESC to exit
                self.running = False
                break
            elif key == ord("r"):
                self.exercise_type = "hand_raise"
            elif key == ord("c"):
                self.exercise_type = "hand_curl"

        self.cap.release()
        cv2.destroyAllWindows()

    def start(self):
        """Start the exercise detection"""
        if not self.running:
            self.running = True
            self.detection_thread = threading.Thread(target=self.detection_loop)
            self.detection_thread.start()

    def stop(self):
        """Stop the exercise detection"""
        self.running = False
        if self.detection_thread:
            self.detection_thread.join()
        if self.cap:
            self.cap.release()
        cv2.destroyAllWindows()


if __name__ == "__main__":
    detector = ExerciseDetector()
    detector.start()
