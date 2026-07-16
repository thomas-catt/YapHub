from fastapi import FastAPI
from routers import users
from routers import posts

app = FastAPI(
    title="YapHub API"
)

@app.get("/")
def read_root():
    return {"message": "Welcome to the YapHub API!"}


@app.get("/health")
def health_check():
    return {"status": "ok"}

app.include_router(users.router)
app.include_router(posts.router)
