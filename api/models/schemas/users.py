from pydantic import BaseModel, Field

class UserCreate(BaseModel):
    username: str = Field(..., pattern=r"^[a-zA-Z0-9._-]+$")
    password: str
    display_name: str

class UserLogin(BaseModel):
    username: str = Field(..., pattern=r"^[a-zA-Z0-9._-]+$")
    password: str
