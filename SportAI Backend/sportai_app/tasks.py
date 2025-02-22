from datetime import datetime
from celery import shared_task
from sportai_app.utils import send_daily_mail, send_report_mail


@shared_task(ignore_result=True)
def daily_mail():
    send_daily_mail()
    return "OK"


@shared_task(ignore_result=True)
def weekly_report():
    send_report_mail()
    return "OK"

