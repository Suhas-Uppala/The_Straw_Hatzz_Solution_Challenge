import secrets
import os
import redis
from functools import wraps
import pandas as pd
from sqlalchemy.exc import SQLAlchemyError
from werkzeug.utils import secure_filename
from flask import Blueprint, current_app, jsonify, request
from sportai_app import db, ist
from flask_mail import Message
from sportai_app import mail
from datetime import datetime, timedelta
import jwt
from weasyprint import HTML
import inspect
import matplotlib
import random
import string

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import seaborn as sns


class DecoratedBlueprint(Blueprint):
    def __init__(self, name, import_name, decorators=None, **kwargs):
        super().__init__(name, import_name, **kwargs)
        self.decorators = decorators

    def add_url_rule(self, rule, endpoint=None, view_func=None, **options):
        if view_func and self.decorators:
            for decorator in reversed(self.decorators):
                view_func = decorator(view_func)
        super().add_url_rule(rule, endpoint, view_func, **options)


def login_required():
    def wrapper(fn):
        @wraps(fn)
        def func(*args, **kwargs):
            token = request.headers.get("Authorization")
            if not token:
                return "Token is missing", 403
            from sportai_app.models import User, BlacklistedToken

            try:
                if token.startswith("Bearer "):
                    token = token[len("Bearer ") :]
                blacklisted_token = BlacklistedToken.query.filter_by(
                    token=token
                ).first()
                if blacklisted_token:
                    if blacklisted_token.is_expired():
                        db.session.delete(blacklisted_token)
                        db.session.commit()
                        return (
                            jsonify(
                                {"error": "Token has expired. Please login again."}
                            ),
                            403,
                        )
                    else:
                        return jsonify({"message": "Token is blacklisted"}), 401
                decoded_token = jwt.decode(
                    token, current_app.config["SECRET_KEY"], algorithms=["HS256"]
                )
                userid = decoded_token.get("userid")
                user = User.query.get(userid)
                print(user)
                if not user:
                    return jsonify({"error": "Please login again."}), 404
                sig = inspect.signature(fn)
                if "userid" in sig.parameters:
                    return fn(userid=userid, *args, **kwargs)
                else:
                    return fn(*args, **kwargs)
            except jwt.ExpiredSignatureError:
                return (
                    jsonify({"error": "Token has expired. Please login again."}),
                    403,
                )
            except jwt.InvalidTokenError:
                return jsonify({"error": "Invalid token. Please login"}), 403
            except Exception:
                db.session.rollback()
                return jsonify({"error": "An unexpected error occurred."}), 500

        return func

    return wrapper


def handle_exceptions(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except SQLAlchemyError:
            db.session.rollback()
            return jsonify({"error": "A database error occurred."}), 500
        except Exception:
            db.session.rollback()
            return jsonify({"error": "An unexpected error occurred."}), 500

    return wrapper


def make_cache_key(userid=None, *args, **kwargs):
    return f"{request.endpoint}:{'userid:'+userid+':' if userid else ''}{':'.join(map(str, args))}:{':'.join(f'{k}={v}' for k, v in kwargs.items())}"


def clear_user_cache(user_id):
    redis_client = redis.Redis(
        host=current_app.config["CACHE_REDIS_HOST"],
        port=current_app.config["CACHE_REDIS_PORT"],
        db=0,
    )
    cache_key_pattern = f"user_id:{user_id}:*"
    for key in redis_client.scan_iter(pattern=cache_key_pattern):
        redis_client.delete(key)


def form_errors(errors):
    return next(iter(errors)) + " : " + errors[next(iter(errors))][0]


def validate_file(file, type="image"):
    filename = secure_filename(file.filename)
    file_ext = os.path.splitext(filename)[1].lower()
    if type == "image":
        if file.mimetype not in ["image/jpeg", "image/png", "image/jpg"]:
            return {"error": "Image type must be jpg or jpeg or png."}
        if file_ext not in [".jpeg", ".jpg", ".png"]:
            return {"error": "Image extension must be .jpg or .jpeg or .png."}
        return ""
    elif type == "pdf":
        if file.mimetype != "application/pdf":
            return {"error": "PDF type must be pdf."}
        if file_ext != ".pdf":
            return {"error": "PDF extension must be .pdf."}
        return ""
    else:
        return {"error": "Unsupported file type."}


def export_empty(file_name, column_names):
    file_path = os.path.join(
        current_app.root_path, "static", "user", "stats", file_name
    )
    with open(file_path, "w", newline="", encoding="utf-8") as file:
        file.write(",".join(column_names) + "\n")
    return file_name


def save_file(file, path):
    filename = secure_filename(file.filename)
    file_ext = os.path.splitext(filename)[1].lower()
    file_name = secrets.token_hex(16) + file_ext
    file_path = os.path.join(current_app.root_path, "static", path, file_name)
    with open(file_path, "wb") as f:
        f.write(file.read())
    return file_name


def delete_file(path, file):
    file_path = os.path.join(current_app.root_path, "static", path, file)
    if os.path.exists(file_path):
        os.remove(file_path)


def send_password_email(user, password):
    message = Message(
        "Your New Password", sender="noreply@demo.com", recipients=[user.email]
    )

    message.body = f"""Dear {user.name},

As per your request, we have generated a new password for your account. Please find your new login credentials below:

New Password: {password}

For security reasons, we strongly recommend that you log in immediately and change your password to something more secure.

If you did not request a password reset, please contact our support team at support@demo.com immediately.

Best regards,  
SportAI Team
"""

    mail.send(message)

def format_date(date):
    if not isinstance(date, datetime):
        date = datetime.fromisoformat(date)
    return date.strftime("%B %d, %Y at %I:%M %p")


def send_daily_mail():
    today = datetime.now(ist).strftime("%B %d, %Y")

    message = Message(
        "Daily Update", sender="noreply@demo.com", recipients=["naveentummala2308@gmail.com"]
    )

    message.body = f"""Hi Naveen,

Here's your training update for {today}:

Workout Summary:

Warm-up: 10 minutes of light cardio and dynamic stretches
Main Session:
• Compound Exercises: Squats, Deadlifts, Bench Press (4 sets x 6 reps)
• Accessory Movements: Shoulder Press, Bent-over Rows (3 sets x 8 reps)
• Technique Drills: Clean & Jerk practice for form correction
Cool-Down: 10 minutes of static stretching and foam rolling
Performance Metrics:

Total Duration: 60 minutes
Average Heart Rate: 85 BPM
Calories Burnt: 800 kcal
Highlights & Insights:

Your posture detection accuracy improved by 5% compared to yesterday.
Your consistent training is contributing to a 40% reduction in injury risk over time.
Recommendations for Tomorrow:

Focus on core stability exercises to further improve lifting technique.
Maintain hydration and consider a protein-rich post-workout meal to optimize recovery.
Check the app for your scheduled workout and personalized tips.
Keep pushing towards your goals—your dedication is the key to success!

Best regards,
The SportAI Team
"""

    mail.send(message)


def send_report_mail():

    message = Message(
        f"Weekly Report",
        sender="noreply@demo.com",
        recipients=["naveentummala2308@gmail.com"],
    )

    message.body = """Hi Naveen,

Here’s your detailed weekly performance report for the period [Week Start Date] to [Week End Date]:

1. Weekly Workout Summary
Total Sessions: 6 workouts completed
Average Training Duration: 60 minutes per session
Workout Breakdown:
Warm-up: Consistent 10-15 minutes of cardio and dynamic stretches
Main Session: Focus on compound exercises (Squats, Deadlifts, Bench Press) and technique drills
Cool-Down: 10 minutes of static stretching and foam rolling
2. Performance Metrics & Trends
Average Heart Rate: 83 BPM (slight improvement from last week)
Calories Burnt: ~800 kcal per session on average
Posture Detection Accuracy: Improved by 5% overall
Injury Risk Index: Notable 40% reduction observed through consistent training and proper recovery practices
3. Highlights & Insights
Strength Gains: Your Clean & Jerk performance is trending upward. Keep monitoring technique during main lifts.
Recovery: Improved recovery metrics as shown by steady Resting Heart Rate (RHR) and Heart Rate Variability (HRV).
Consistency: You maintained a strong training schedule, contributing to significant performance and safety improvements.
4. Areas for Improvement
Core Stability: Consider incorporating additional core exercises to further enhance lifting mechanics.
Technique Refinement: Continue focusing on posture and form during compound lifts to reduce strain.
Nutritional Balance: Evaluate your post-workout nutrition to ensure optimal recovery and muscle repair.
5. Recommendations for Next Week
Incorporate Core Workouts: Add 2 sessions of targeted core stability exercises.
Technique Sessions: Dedicate one session exclusively to form refinement using lighter weights and additional video analysis.
Rest & Recovery: Ensure adequate sleep (7-8 hours) and maintain hydration to support your training load.
We’re proud of the progress you’re making. Keep up the great work, and let’s aim for even better results in the coming week!

Best regards,
The SportAI Team
"""

    mail.send(message)


def custom_sort(lis, include_relationships=None):
    if include_relationships is None:
        include_relationships = []
    if len(lis) == 0:
        return []

    records = sorted(
        lis,
        key=lambda x: x.timestamp,
        reverse=True,
    )

    return [item.to_dict(include_relationships) for item in records]


def generate_secure_password(length=12):
    """Generate a secure password that matches the required pattern."""
    lowercase = string.ascii_lowercase
    uppercase = string.ascii_uppercase
    digits = string.digits
    special = "!@#$%^&*()-_=+{};:,<.>"

    password = [
        random.choice(uppercase),
        random.choice(lowercase),
        random.choice(digits),
        random.choice(special),
    ]

    all_characters = lowercase + uppercase + digits + special
    password.extend(random.choice(all_characters) for _ in range(length - 4))

    random.shuffle(password)

    return "".join(password)
