from beanie import Document
from pydantic import Field

class User(Document):
    username: str = Field(..., pattern=r"^[a-zA-Z0-9._-]+$")
    password: str
    display_name: str

    class Settings:
        name = "users"
        indexes = [
            "username",
        ]
