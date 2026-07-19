from beanie import Document
from pydantic import Field
from datetime import datetime, timezone
from typing import Optional

class Comment(Document):
    author_id: str
    post_id: str
    parent_reply_id: Optional[str] = None # null = top-level comment
    
    content: str
    x_coordinate: Optional[float] = None # Used for mapping top-level comments on the image
    y_coordinate: Optional[float] = None
    
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    
    likes_count: int = 0
    replies_count: int = 0 # Denormalized reply count

    class Settings:
        name = "comments"
        indexes = [
            "post_id",
            "parent_reply_id"
        ]
