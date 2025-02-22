from flask_wtf import FlaskForm
from wtforms import PasswordField, RadioField, StringField, ValidationError, DateField
from wtforms.validators import DataRequired, Length, EqualTo, AnyOf
from datetime import datetime
import re
from sportai_app.models import User
from wtforms.validators import DataRequired


class UpdateProfileForm(FlaskForm):
    class Meta:
        csrf = False

    name = StringField("Name", validators=[DataRequired(), Length(min=3, max=60)])
    email = StringField("Email", validators=[DataRequired()])
    username = StringField(
        "Username", validators=[DataRequired(), Length(min=5, max=32)]
    )
    phone = StringField(
        "Phone",
        validators=[DataRequired(), Length(min=10, max=10)],
    )
    gender = StringField(
        "Gender",
        validators=[DataRequired(), AnyOf(["male", "female", "other"])],
    )
    dob = DateField(
        "Date of Birth",
        validators=[DataRequired()],
    )
    password = PasswordField(
        "Enter Your Password To Update",
        validators=[DataRequired(), Length(min=8, max=60)],
    )

    def __init__(self, *args, **kwargs):
        self.current_user = kwargs.pop("current_user", None)
        super().__init__(*args, **kwargs)

    def validate_name(self, name):
        pattern = r"^[A-Za-z\s,'.]{3,60}$"
        if not re.match(pattern, name.data):
            raise ValidationError(
                "Name can only have only have letters, spaces, apostrophes, commas and period."
            )

    def validate_username(self, username):
        pattern = r"^[a-z][a-z0-9_]{4,31}$"
        if not re.match(pattern, username.data):
            raise ValidationError(
                "Username can only contain lowercase letters, digits and underscore."
            )
        if username.data != self.current_user.username:
            if user := User.query.filter_by(username=username.data).first():
                raise ValidationError(
                    "That username is already taken. Please choose different username."
                )

    def validate_email(self, email):
        pattern = r"^([a-z\d\.-]+)@([a-z\d-]+)\.([a-z]{2,8})(\.[a-z]{2,8})?$"
        if not re.match(pattern, email.data):
            raise ValidationError("Invalid email address.")
        if email.data != self.current_user.email:
            if email := User.query.filter_by(email=email.data).first():
                raise ValidationError(
                    "That email already exists. Please choose a different email."
                )

    def validate_phone(self, phone):
        pattern = r"^[0-9]{10}$"
        if not re.match(pattern, phone.data):
            raise ValidationError("Phone number must be exactly 10 digits.")
        if phone.data != self.current_user.phone:
            if phone_exists := User.query.filter_by(phone=phone.data).first():
                raise ValidationError("This phone number is already registered.")

    def validate_gender(self, gender):
        valid_genders = ["male", "female", "Other"]
        if gender.data not in valid_genders:
            raise ValidationError("Gender must be one of: male, female, Other")


class ChangePasswordForm(FlaskForm):
    class Meta:
        csrf = False

    current_password = PasswordField(
        "Current Password", validators=[DataRequired(), Length(min=8, max=60)]
    )
    new_password = PasswordField(
        "New Password", validators=[DataRequired(), Length(min=8, max=60)]
    )

    def validate_new_password(self, new_password):
        pattern = (
            r"^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#$%^&*()\-_=+{};:,<.>]).{8,60}$"
        )
        if not re.match(pattern, new_password.data):
            raise ValidationError(
                "Password must contain at least eight characters, one uppercase letter, one lowercase letter, one number and one special character."
            )


class DeleteAccountForm(FlaskForm):
    class Meta:
        csrf = False

    password = PasswordField(
        "Password", validators=[DataRequired(), Length(min=8, max=60)]
    )


class ChatForm(FlaskForm):
    class Meta:
        csrf = False

    query = StringField("Query", validators=[DataRequired()])
