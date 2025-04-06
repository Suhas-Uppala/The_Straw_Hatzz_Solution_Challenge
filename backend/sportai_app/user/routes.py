from datetime import datetime
import os
from flask import jsonify, request, current_app
from sportai_app import db, bcrypt, ist
from sportai_app.models import User, BlacklistedToken
from sportai_app.utils import (
    delete_file,
    save_file,
    form_errors,
    validate_file,
    generate_secure_password,
    send_password_email,
)
from sportai_app.user.forms import (
    UpdateProfileForm,
    ChangePasswordForm,
    DeleteAccountForm,
    ChatForm,
)
from . import user
from .rag.qa_chain import create_qa_chain  # Updated import path
import jwt
import threading


qa_chain = create_qa_chain()


@user.route("/chat", methods=["POST"])
def chat():
    if not request.is_json:
        return jsonify({"error": "Request must be JSON"}), 400

    form = ChatForm(data=request.get_json())
    if not form.validate():
        return jsonify({"error": form_errors(form.errors)}), 400

    try:
        response = qa_chain.run(form.query.data)
        return jsonify({"response": response}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@user.route("/is-valid", methods=["GET"])
def is_valid(userid):
    if userid:
        return jsonify({"message": "The token is still valid."}), 200
    else:
        return jsonify({"error": "The token is expired or invalid."}), 400


@user.route("/account", methods=["GET"])
def account(userid):
    current_user = User.query.get(userid)
    user = User.query.get(current_user.userid)
    return jsonify(user.to_dict()), 200


@user.route("/account", methods=["POST"])
def update_profile(userid):
    current_user = User.query.get(userid)
    data = request.form.to_dict()
    form = UpdateProfileForm(data=data, current_user=current_user)
    print(form.data)
    if not form.validate():
        return (
            jsonify({"error": form_errors(form.errors)}),
            400,
        )
    print("Hello")
    if not bcrypt.check_password_hash(current_user.password, form.password.data):
        return jsonify({"error": "The password is incorrect."}), 400
    if profile_picture_data := request.files.get("profile_picture"):
        if return_val := validate_file(profile_picture_data, "image"):
            return jsonify(return_val), 400
        if current_user.profile_picture != "default_profile_picture.png":
            delete_file(
                os.path.join("user", "profile_pictures"),
                current_user.profile_picture,
            )
        current_user.profile_picture = save_file(
            profile_picture_data, "user/profile_pictures"
        )

    current_user.name = form.name.data
    current_user.username = form.username.data
    current_user.email = form.email.data
    current_user.phone = form.phone.data
    current_user.gender = form.gender.data
    current_user.dob = form.dob.data

    db.session.commit()
    return jsonify({"message": "Account has been updated successfully."}), 200


@user.route("/account", methods=["PUT"])
def change_password(userid):
    current_user = User.query.get(userid)
    if not request.is_json:
        return jsonify({"error": "Request must be JSON"}), 400
    data = request.get_json()
    form = ChangePasswordForm(data=data)
    if not form.validate():
        return (
            jsonify({"error": form_errors(form.errors)}),
            400,
        )
    if bcrypt.check_password_hash(current_user.password, form.current_password.data):
        current_user.password = bcrypt.generate_password_hash(
            form.new_password.data
        ).decode("utf-8")
        db.session.commit()
        return jsonify({"message": "Your password has been updated!"}), 200
    else:
        return jsonify({"error": "The password is incorrect."}), 400


@user.route("/reset", methods=["GET"])
def reset_request(userid):
    user = User.query.get(userid)
    password = generate_secure_password(16)
    user.password = bcrypt.generate_password_hash(password).decode("utf-8")
    db.session.commit()
    send_password_email(user, password)
    return jsonify({"message": "Verification Complete. Password has been sent."}), 200


@user.route("/logout", methods=["GET"])
def logout(userid):
    token = request.headers.get("Authorization")
    try:
        if token.startswith("Bearer "):
            token = token[len("Bearer ") :]
        decoded = jwt.decode(
            token, current_app.config["SECRET_KEY"], algorithms=["HS256"]
        )
        expiry = datetime.fromtimestamp(decoded["exp"], ist)
        blacklisted_token = BlacklistedToken(token=token, expiry=expiry)
        user = User.query.get(userid)
        user.authenticated = False
        db.session.add(blacklisted_token)
        db.session.commit()
        return jsonify({"message": "Logged out successfully."}), 200
    except jwt.ExpiredSignatureError:
        return jsonify({"error": "Token already expired."}), 400
    except jwt.InvalidTokenError:
        return jsonify({"error": "Invalid token."}), 400
    except Exception:
        return jsonify({"error": "An error occurred."}), 500


@user.route("/account", methods=["POST"])
def delete_account(userid):
    current_user = User.query.get(userid)
    if not request.is_json:
        return jsonify({"error": "Request must be JSON"}), 400
    data = request.get_json()
    form = DeleteAccountForm(data=data)
    if form.validate():
        if bcrypt.check_password_hash(current_user.password, form.password.data):
            if current_user.profile_picture != "default_profile_picture.png":
                delete_file(
                    os.path.join("user", "profile_pictures"),
                    current_user.profile_picture,
                )
            db.session.delete(current_user)
            db.session.commit()

            return jsonify({"message": "Account deleted successfully."}), 200
        else:
            return jsonify({"error": "The password is incorrect."}), 400
    else:
        return (
            jsonify({"error": form_errors(form.errors)}),
            400,
        )