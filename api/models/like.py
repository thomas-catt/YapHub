from beanie import Document
from pydantic import Field
from datetime import datetime, timezone

class Like(Document):
    author_id: str
    target: str # "post" or "comment"
    target_id: str
    
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))

    class Settings:
        name = "likes"
        indexes = [
            # Compound index to quickly find/prevent duplicate likes
            ["author_id", "target", "target_id"], 
            "target_id"
        ]
