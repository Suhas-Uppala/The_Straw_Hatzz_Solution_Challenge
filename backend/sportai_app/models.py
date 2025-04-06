import jwt
from datetime import datetime, timedelta, timezone
from flask import current_app
from sportai_app import db, bcrypt, ist
from sqlalchemy import CheckConstraint
from sportai_app.utils import custom_sort


class User(db.Model):
    __tablename__ = "user"
    userid = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name = db.Column(db.String(60), nullable=False)
    username = db.Column(db.String(32), unique=True, nullable=False)
    dob = db.Column(db.DateTime, nullable=False)
    email = db.Column(db.String(60), unique=True, nullable=False)
    phone = db.Column(db.String(10), unique=True, nullable=False)
    gender = db.Column(db.String(10), nullable=False)
    password = db.Column(db.String(60), nullable=False)
    profile_picture = db.Column(
        db.String(60), nullable=False, default="default_profile_picture.png"
    )
    authenticated = db.Column(db.Boolean, default=False)
    health_records = db.relationship("Health", back_populates="user", lazy=True)

    __table_args__ = (
        CheckConstraint(
            "phone IS NULL OR (LENGTH(phone) = 10 AND phone ~ '^[0-9]+$')",
            name="check_phone_format",
        ),
        CheckConstraint(
            "gender IS NULL OR gender IN ('male', 'female', 'Other')",
            name="check_gender",
        ),
        CheckConstraint(
            "email ~ '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'",
            name="check_email_format",
        ),
        CheckConstraint(
            "username ~ '^[A-Za-z0-9_]{3,32}$'", name="check_username_format"
        ),
        CheckConstraint(
            "LENGTH(password) >= 8 AND password ~ '[A-Z]' AND password ~ '[a-z]' AND password ~ '[0-9]'",
            name="check_password_format",
        ),
    )

    def __repr__(self):
        return f"User('{self.userid}', '{self.name}', '{self.username}', '{self.email}', '{self.password}', '{self.profile_picture}', '{self.authenticated}')"

    def __init__(
        self,
        name,
        username,
        email,
        password,
        dob,
        phone=None,
        gender=None,
        profile_picture="default_profile_picture.png",
        authenticated=False,
    ):
        self.name = name
        self.email = email
        self.username = username
        self.password = bcrypt.generate_password_hash(password).decode("utf-8")
        self.dob = dob
        self.phone = phone
        self.gender = gender
        self.profile_picture = profile_picture
        self.authenticated = authenticated

    def get_reset_token(self, expires_sec=1800):
        secret_key = jwt.encode(
            {
                "userid": self.userid,
                "exp": datetime.now(timezone.utc) + timedelta(seconds=expires_sec),
            },
            current_app.config["SECRET_KEY"],
            algorithm="HS256",
        )
        return secret_key

    @staticmethod
    def verify_reset_token(token):
        try:
            data = jwt.decode(
                token,
                current_app.config["SECRET_KEY"],
                leeway=timedelta(seconds=10),
                algorithms=["HS256"],
                options={"verify_exp": True},
            )
        except:
            return None
        return User.query.filter(User.userid == int(data["userid"])).first()

    def to_dict(self, include_relationships=[]):
        dt = {
            "userid": self.userid,
            "name": self.name,
            "username": self.username,
            "dob": self.dob.isoformat(),
            "email": self.email,
            "phone": self.phone,
            "gender": self.gender,
            "profile_picture": self.profile_picture,
        }
        if "health_records" in include_relationships:
            dt["health_records"] = custom_sort(self.health_records)
        return dt


class Health(db.Model):
    __tablename__ = "health"
    healthid = db.Column(db.Integer, primary_key=True, autoincrement=True)
    userid = db.Column(db.Integer, db.ForeignKey("user.userid"), nullable=False)
    timestamp = db.Column(
        db.DateTime, nullable=False, default=datetime.now(ist).replace(tzinfo=None)
    )
    heartbeat = db.Column(db.Integer)
    blood_pressure_systolic = db.Column(db.Integer)
    blood_pressure_diastolic = db.Column(db.Integer)
    hydration = db.Column(db.Float)
    sleep_hours = db.Column(db.Float)
    blood_oxygen = db.Column(db.Float)
    ecg_reading = db.Column(db.String(500))
    walking_steps = db.Column(db.Integer)
    running_duration = db.Column(db.Integer)
    cycling_duration = db.Column(db.Integer)
    skipping_duration = db.Column(db.Integer)
    badminton_duration = db.Column(db.Integer)
    basketball_duration = db.Column(db.Integer)
    football_duration = db.Column(db.Integer)
    swimming_duration = db.Column(db.Integer)
    elliptical_duration = db.Column(db.Integer)

    user = db.relationship("User", back_populates="health_records")

    __table_args__ = (
        CheckConstraint("heartbeat BETWEEN 40 AND 220", name="check_heartbeat"),
        CheckConstraint(
            "blood_pressure_systolic BETWEEN 70 AND 200", name="check_bp_systolic"
        ),
        CheckConstraint(
            "blood_pressure_diastolic BETWEEN 40 AND 130", name="check_bp_diastolic"
        ),
        CheckConstraint("hydration BETWEEN 0 AND 100", name="check_hydration"),
        CheckConstraint("sleep_hours BETWEEN 0 AND 24", name="check_sleep"),
        CheckConstraint("blood_oxygen BETWEEN 0 AND 100", name="check_bo"),
        CheckConstraint("walking_steps >= 0", name="check_steps"),
    )

    def __init__(self, userid, **kwargs):
        self.userid = userid
        for key, value in kwargs.items():
            setattr(self, key, value)

    def to_dict(self):
        return {
            "healthid": self.healthid,
            "userid": self.userid,
            "timestamp": self.timestamp.isoformat(),
            "heartbeat": self.heartbeat,
            "blood_pressure_systolic": self.blood_pressure_systolic,
            "blood_pressure_diastolic": self.blood_pressure_diastolic,
            "hydration": self.hydration,
            "sleep_hours": self.sleep_hours,
            "blood_oxygen": self.blood_oxygen,
            "ecg_reading": self.ecg_reading,
            "walking_steps": self.walking_steps,
            "running_duration": self.running_duration,
            "cycling_duration": self.cycling_duration,
            "skipping_duration": self.skipping_duration,
            "badminton_duration": self.badminton_duration,
            "basketball_duration": self.basketball_duration,
            "football_duration": self.football_duration,
            "swimming_duration": self.swimming_duration,
            "elliptical_duration": self.elliptical_duration,
        }


class BlacklistedToken(db.Model):
    __tablename__ = "blacklistedtoken"
    blacklistedid = db.Column(db.Integer, primary_key=True)
    token = db.Column(db.String(512), unique=True, nullable=False)
    expiry = db.Column(db.DateTime, nullable=False)

    def __init__(self, token, expiry):
        self.token = token
        self.expiry = expiry

    def __repr__(self):
        return (
            f"BlacklistedToken('{self.blacklistedid}', '{self.token}', '{self.expiry}')"
        )

    def is_expired(self):
        return datetime.now(ist).replace(tzinfo=None) > self.expiry

    def to_dict(self):
        return {
            "blacklistedid": self.blacklistedid,
            "token": self.token,
            "expiry": self.expiry.isoformat(),
        }
