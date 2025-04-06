from datetime import timezone, timedelta
from flask import Flask
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
from flask_mail import Mail
from flask_caching import Cache
from sportai_app.config import Config
from sportai_app.worker import celery_init_app
from celery.schedules import crontab
import flask_excel as excel

db = SQLAlchemy()
bcrypt = Bcrypt()
mail = Mail()
cache = Cache()
celery_app = None
ist = timezone(timedelta(hours=5, minutes=30))


def create_app(config_class=Config):
    app = Flask(__name__)
    CORS(app)
    app.config.from_object(Config)

    db.init_app(app)
    bcrypt.init_app(app)
    mail.init_app(app)
    cache.init_app(app)
    excel.init_excel(app)
    celery_app = celery_init_app(app)

    from sportai_app.models import User

    with app.app_context():
        db.create_all()

    from sportai_app.tasks import (
        daily_mail,
        weekly_report,
    )

    celery_app.conf.beat_schedule = {
        "weekly-report": {
            "task": "sportai_app.tasks.weekly_report",
            "schedule": crontab(minute="*/10"),
        },
        # "delete-blacklisted-tokens": {
        #     "task": "sportai_app.tasks.delete_blacklisted_tokens",
        #     "schedule": crontab(minute="*/10"),
        # },
        "daily-mail": {
            "task": "sportai_app.tasks.daily_mail",
            "schedule": crontab(minute="*/10"),
        },
    }

    from sportai_app.main import main
    from sportai_app.user import user

    app.register_blueprint(main, url_prefix="/api/main")
    app.register_blueprint(user, url_prefix="/api/user")

    return app, celery_app
