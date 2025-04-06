import os
from dotenv import load_dotenv
from base64 import b64decode

load_dotenv()

class Config:
    SECRET_KEY = os.environ.get("SECRET_KEY")
    SQLALCHEMY_DATABASE_URI = os.environ.get("SQLALCHEMY_DATABASE_URI")
    SQLALCHEMY_TRACK_MODIFICATIONS = os.environ.get("SQLALCHEMY_TRACK_MODIFICATIONS")
    CACHE_TYPE = os.environ.get("CACHE_TYPE")
    CACHE_DEFAULT_TIMEOUT = os.environ.get("CACHE_DEFAULT_TIMEOUT")
    CACHE_REDIS_HOST = os.environ.get("CACHE_REDIS_HOST")
    CACHE_REDIS_PORT = os.environ.get("CACHE_REDIS_PORT")
    CELERY_BROKER_URL = os.environ.get("CELERY_BROKER_URL")
    CELERY_RESULT_BACKEND = os.environ.get("CELERY_RESULT_BACKEND")
    CELERY_TIMEZONE = os.environ.get("CELERY_TIMEZONE")
    CELERY_BEAT_SCHEDULER = os.environ.get("CELERY_BEAT_SCHEDULER")
    MAIL_SERVER = os.environ.get("MAIL_SERVER")
    MAIL_PORT = os.environ.get("MAIL_PORT")
    MAIL_USE_TLS = os.environ.get("MAIL_USE_TLS")
    MAIL_USERNAME = b64decode(os.environ.get("MAIL_USERNAME")).decode("utf-8")
    MAIL_PASSWORD = b64decode(os.environ.get("MAIL_PASSWORD") + "==").decode("utf-8")
