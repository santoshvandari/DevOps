from fastapi import FastAPI

app = FastAPI()


@app.get("/")
def read_root():
    return {"Hello": "World from Docker FastAPI GET"}

@app.post("/")
def read_post_root():
    return {"Hello": "World from Docker FastAPI POST"}