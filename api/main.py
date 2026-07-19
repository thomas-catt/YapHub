from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from contextlib import asynccontextmanager
from routers import users
from routers import posts
from routers import comments
from routers import likes
from database import init_db
from traceback import print_exception
from utils import error_handling

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup logic
    await init_db()
    yield
    # Shutdown logic (optional)

app = FastAPI(
    title="YapHub API",
    lifespan=lifespan
)

@app.get("/")
def read_root():
    return {"message": "Welcome to the YapHub API!"}


@app.get("/health")
def health_check():
    return {"status": "ok"}

app.include_router(users.router)
app.include_router(posts.router)
app.include_router(comments.router)
app.include_router(likes.router)

# Register the validation exception handler
app.add_exception_handler(RequestValidationError, error_handling.validation_exception_handler)

@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    print("Server error:")
    print_exception(type(exc), exc, exc.__traceback__, limit=3)

    return JSONResponse(
        status_code=500,
        content={"message": "An unexpected server-side error occured."}
    )
