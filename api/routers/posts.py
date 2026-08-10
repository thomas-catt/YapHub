from datetime import datetime
from models.schemas.posts import PostCreate
from fastapi import APIRouter, Depends
from models.post import Post
from models.like import Like
from utils.auth import get_current_user, get_optional_user
from beanie.operators import In

router = APIRouter(
    prefix="/posts",
    tags=["Posts"]
)

@router.get("/")
async def get_all_posts(user_id: str | None = Depends(get_optional_user)):
    pipeline = [
        {
            "$addFields": {
                "author_id_obj": { "$toObjectId": "$author_id" }
            }
        },
        {
            "$lookup": {
                "from": "users",
                "localField": "author_id_obj",
                "foreignField": "_id",
                "as": "author"
            }
        },
        {
            "$unwind": "$author"
        },
        {
            "$project": {
                "author_id_obj": 0,
                "author.password": 0 
            }
        }
    ]

    all_posts = await Post.aggregate(pipeline).to_list(length=100)
    
    for post in all_posts:
        post["_id"] = str(post["_id"])
        if "author" in post:
            post["author"]["_id"] = str(post["author"]["_id"])
            
    if user_id and all_posts:
        post_ids = [p["_id"] for p in all_posts]
        liked_posts = await Like.find(
            Like.author_id == user_id,
            Like.target == "post",
            In(Like.target_id, post_ids)
        ).to_list()
        liked_ids = {l.target_id for l in liked_posts}
        for p in all_posts:
            p["is_liked"] = p["_id"] in liked_ids
        
    return {"posts": all_posts}

@router.post("/create")
async def create_post(post: PostCreate, user_id: str = Depends(get_current_user)):
    new_post = Post(**post.model_dump(), author_id=user_id)
    await new_post.insert()
    
    return {"post_id": str(new_post.id)}
