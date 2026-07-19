from pydantic import BaseModel, Field

class LikeToggle(BaseModel):
    target: str = Field(..., description="Must be 'post' or 'comment'")
    target_id: str
