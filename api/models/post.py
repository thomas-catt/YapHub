from beanie import Document
from pydantic import Field
from datetime import datetime, timezone

class Post(Document):
    # What the user sends
    caption: str
    image: str
    
    # What we set internally
    author_id: str
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    likes_count: int = 0
    comments_count: int = 0

    class Settings:
        name = "posts"
        indexes = [
            "author_id",
        ]
