from fastapi import APIRouter, Depends, HTTPException, status
from models.schemas.likes import LikeToggle
from models.like import Like
from models.post import Post
from models.comment import Comment
from utils.auth import get_current_user
from bson.errors import InvalidId

router = APIRouter(
    prefix="/likes",
    tags=["Likes"],
    dependencies=[Depends(get_current_user)]
)

@router.post("/toggle", status_code=status.HTTP_200_OK)
async def toggle_like(like_data: LikeToggle, user_id: str = Depends(get_current_user)):
    target_type = like_data.target
    target_id = like_data.target_id
    
    # 1. Verify target exists
    try:
        if target_type == "post":
            target_obj = await Post.get(target_id)
        elif target_type == "comment":
            target_obj = await Comment.get(target_id)
        else:
            raise HTTPException(status_code=400, detail="Invalid target type")
    except InvalidId:
        raise HTTPException(status_code=400, detail="Invalid target ID format")
        
    if not target_obj:
        raise HTTPException(status_code=404, detail=f"{target_type.capitalize()} not found")
        
    # 2. Check if like already exists
    existing_like = await Like.find_one(
        Like.author_id == user_id,
        Like.target == target_type,
        Like.target_id == target_id
    )
    
    if existing_like:
        # Unlike (Toggle off)
        await existing_like.delete()
        target_obj.likes_count -= 1
        await target_obj.save()
        return {"action": "unlike", "likes_count": target_obj.likes_count}
    else:
        # Like (Toggle on)
        new_like = Like(
            author_id=user_id,
            target=target_type,
            target_id=target_id
        )
        await new_like.insert()
        target_obj.likes_count += 1
        await target_obj.save()
        return {"action": "like", "likes_count": target_obj.likes_count}
