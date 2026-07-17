from datetime import datetime
from models.schemas.posts import PostCreate
from fastapi import APIRouter, Depends
from database import posts_collection
from utils.auth import get_current_user

router = APIRouter(
    prefix="/posts",
    tags=["Posts"],
    dependencies=[Depends(get_current_user)]
)

@router.get("/")
async def get_all_posts():
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

    posts_cursor = posts_collection.aggregate(pipeline)
    all_posts = await posts_cursor.to_list(length=100)
    
    for post in all_posts:
        post["_id"] = str(post["_id"])
        if "author" in post:
            post["author"]["_id"] = str(post["author"]["_id"])
        
    return {"message": "Get all posts", "posts": all_posts}

@router.post("/create")
async def create_post(post: PostCreate, user_id: str = Depends(get_current_user)):
    post_dict = post.model_dump()
    
    post_dict["timestamp"] = datetime.now()
    post_dict["author_id"] = user_id
    
    result = await posts_collection.insert_one(post_dict)
    return {"message": "Post created", "post_id": str(result.inserted_id)}
