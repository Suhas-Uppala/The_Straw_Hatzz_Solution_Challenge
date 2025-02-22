from sportai_app import create_app


app, celery_app = create_app()

if __name__ == "__main__":
    app.run(debug = True)
