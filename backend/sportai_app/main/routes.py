from flask import jsonify, request, current_app
from sportai_app import db, bcrypt
from sportai_app.models import User
from sportai_app.utils import (
    save_file,
    form_errors,
    validate_file,
    generate_secure_password,
    send_password_email,
)
from sportai_app.main.forms import (
    ResetRequestForm,
    ResetPasswordForm,
    LoginForm,
    RegistrationForm,
)
from . import main
from datetime import datetime, timezone, timedelta
import jwt
import os
import re


@main.route("/register", methods=["POST"])
def register():
    data = request.form.to_dict()
    form = RegistrationForm(data=data)
    print(form.data)
    print(form.validate())
    if not form.validate():
        print(form_errors(form.errors))
        return (
            jsonify({"error": form_errors(form.errors)}),
            400,
        )
    print("Hello")
    if profile_picture_data := request.files.get("profile_picture"):
        if return_val := validate_file(profile_picture_data, "image"):
            return jsonify(return_val), 400
        profile_picture = save_file(
            profile_picture_data, os.path.join("user", "profile_pictures")
        )
    else:
        profile_picture = "default_profile_picture.png"
    print(profile_picture)
    user = User(
        name=form.name.data,
        email=form.email.data,
        username=form.username.data,
        password=form.password.data,
        profile_picture=profile_picture,
        phone=form.phone.data,
        gender=form.gender.data,
        dob=form.dob.data,
    )
    db.session.add(user)
    db.session.commit()
    return jsonify({"message": f"Account created for {form.username.data}!"}), 201


@main.route("/login", methods=["POST"])
def login():
    if not request.is_json:
        return jsonify({"error": "Request must be JSON"}), 400
    data = request.get_json()
    form = LoginForm(data=data)
    print(form.data)
    if not form.validate():
        return (
            jsonify({"error": form_errors(form.errors)}),
            400,
        )
    user = None
    identifier = form.identifier.data
    if re.match(r"^[a-z][a-z0-9_]{4,31}$", identifier):
        user = User.query.filter_by(username=identifier).first()
    elif re.match(r"^[0-9]{10}$", identifier):
        user = User.query.filter_by(phone=identifier).first()
    elif re.match(
        r"^([a-z\d\.-]+)@([a-z\d-]+)\.([a-z]{2,8})(\.[a-z]{2,8})?$", identifier
    ):
        user = User.query.filter_by(email=identifier).first()

    print(identifier)
    print(user)

    if not user or not bcrypt.check_password_hash(user.password, form.password.data):
        return jsonify({"error": "Invalid Username/Email/Phone or Password"}), 404
    try:
        token = jwt.encode(
            {
                "userid": user.userid,
                "exp": datetime.now(timezone.utc) + timedelta(days=1),
            },
            current_app.config["SECRET_KEY"],
            algorithm="HS256",
        )
    except Exception as e:
        return (
            jsonify(
                {
                    "error": "An unexpected error has occurred. Please try again. Couldn't generate the token."
                }
            ),
            400,
        )
    user.authenticated = True
    db.session.commit()
    return (
        jsonify({"message": "Logged in successfully.", "token": token}),
        200,
    )


@main.route("/reset", methods=["POST"])
def reset_request():
    if not request.is_json:
        return jsonify({"error": "Request must be JSON"}), 400
    data = request.get_json()
    form = ResetRequestForm(data=data)
    print(form.data)
    if not form.validate():
        return (
            jsonify({"error": form_errors(form.errors)}),
            400,
        )
    user = None
    identifier = form.identifier.data
    print(identifier)
    print(re.match(r"^[a-z][a-z0-9_]{4,31}$", identifier))
    if re.match(r"^[a-z][a-z0-9_]{4,31}$", identifier):
        print(1)
        user = User.query.filter_by(username=identifier).first()
    elif re.match(r"^[0-9]{10}$", identifier):
        print(2)
        user = User.query.filter_by(phone=identifier).first()
    elif re.match(
        r"^([a-z\d\.-]+)@([a-z\d-]+)\.([a-z]{2,8})(\.[a-z]{2,8})?$", identifier
    ):
        print(3)
        user = User.query.filter_by(email=identifier).first()
    print(user)
    if not user:
        return jsonify({"error": "No user found with that Username/Email/Phone"}), 404
    password = generate_secure_password(16)
    user.password = bcrypt.generate_password_hash(password).decode("utf-8")
    db.session.commit()
    send_password_email(user, password)
    return jsonify({"message": "Verification Complete. Password has been sent."}), 200
