from pydantic import BaseModel, Field

class CommentCreate(BaseModel):
    content: str
    x_coordinate: float = Field(..., ge=0.0, le=100.0)
    y_coordinate: float = Field(..., ge=0.0, le=100.0)

class ReplyCreate(BaseModel):
    content: str
