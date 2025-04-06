from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from posture_detection import ExerciseDetector
import uvicorn
import threading

app = FastAPI()

# Add CORS middleware
origins = ["*"]  # Update this as needed for production
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

detector = None
detector_thread = None


@app.post("/start", status_code=200)
async def start_detection():
    global detector, detector_thread
    if detector is not None and detector.running:
        raise HTTPException(status_code=400, detail="Detection already running")
    detector = ExerciseDetector()
    detector_thread = threading.Thread(target=detector.start)
    detector_thread.start()
    return {"status": "Detection started"}


@app.post("/stop", status_code=200)
async def stop_detection():
    global detector, detector_thread
    if detector is None or not detector.running:
        raise HTTPException(status_code=400, detail="Detection not running")
    detector.stop()
    detector_thread.join()
    detector = None
    detector_thread = None
    return {"status": "Detection stopped"}


@app.get("/status", status_code=200)
async def get_status():
    return {"running": detector is not None and detector.running}


if __name__ == "__main__":
    uvicorn.run("api:app", host="0.0.0.0", port=9000, reload=False)
