from fastapi import APIRouter, Depends, HTTPException, status
from models.schemas.comments import CommentCreate, ReplyCreate
from models.comment import Comment
from models.post import Post
from utils.auth import get_current_user
from bson.errors import InvalidId

router = APIRouter(
    tags=["Comments"],
)

def get_comments_pipeline(match_stage: dict) -> list:
    return [
        {"$match": match_stage},
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
            "$unwind": {
                "path": "$author",
                "preserveNullAndEmptyArrays": True
            }
        },
        {
            "$project": {
                "author_id_obj": 0,
                "author.password": 0 
            }
        }
    ]

def format_comments(comments_list: list) -> list:
    for comment in comments_list:
        comment["_id"] = str(comment["_id"])
        if "author" in comment and comment["author"]:
            comment["author"]["_id"] = str(comment["author"]["_id"])
    return comments_list

@router.post("/posts/{post_id}/comments", status_code=status.HTTP_201_CREATED)
async def create_comment(post_id: str, comment: CommentCreate, user_id: str = Depends(get_current_user)):
    try:
        post = await Post.get(post_id)
    except InvalidId:
        raise HTTPException(status_code=400, detail="Invalid post ID")
        
    if not post:
        raise HTTPException(status_code=404, detail="Post not found")
        
    new_comment = Comment(
        **comment.model_dump(),
        post_id=post_id,
        author_id=user_id,
        parent_reply_id=None
    )
    await new_comment.insert()
    
    post.comments_count += 1
    await post.save()
    
    return {"comment_id": str(new_comment.id)}

@router.get("/posts/{post_id}/comments")
async def get_post_comments(post_id: str, limit: int = 50, skip: int = 0):
    pipeline = get_comments_pipeline({
        "post_id": post_id,
        "parent_reply_id": None
    })
    pipeline.extend([
        {"$skip": skip},
        {"$limit": limit}
    ])
    comments = await Comment.aggregate(pipeline).to_list(length=limit)
    return format_comments(comments)

@router.post("/comments/{comment_id}/replies", status_code=status.HTTP_201_CREATED)
async def create_reply(comment_id: str, reply: ReplyCreate, user_id: str = Depends(get_current_user)):

    try:
        parent_comment = await Comment.get(comment_id)
    except InvalidId:
        raise HTTPException(status_code=400, detail="Invalid comment ID")
        
    if not parent_comment:
        raise HTTPException(status_code=404, detail="Parent comment not found")

    new_reply = Comment(
        **reply.model_dump(),
        post_id=parent_comment.post_id,
        author_id=user_id,
        parent_reply_id=comment_id
    )
    await new_reply.insert()
    
    parent_comment.replies_count += 1
    await parent_comment.save()
    
    post = await Post.get(parent_comment.post_id)
    if post:
        post.comments_count += 1
        await post.save()
        
    return {"reply_id": str(new_reply.id)}

@router.get("/comments/{comment_id}/replies")
async def get_comment_replies(comment_id: str, limit: int = 50, skip: int = 0):
    pipeline = get_comments_pipeline({
        "parent_reply_id": comment_id
    })
    pipeline.extend([
        {"$skip": skip},
        {"$limit": limit}
    ])
    replies = await Comment.aggregate(pipeline).to_list(length=limit)
    return format_comments(replies)
