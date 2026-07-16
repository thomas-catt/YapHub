from models.schemas.posts import PostCreate
from fastapi import APIRouter

router = APIRouter(
    prefix="/posts",
    tags=["Posts"]
)

@router.get("/")
def get_all_posts():
    return {"message": "Get all posts"}

@router.post("/create")
def create_post(post: PostCreate):
    return {"message": "Post created", "post": post}

