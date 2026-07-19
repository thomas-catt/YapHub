from motor.motor_asyncio import AsyncIOMotorClient
from beanie import init_beanie
import os
import certifi
from dotenv import load_dotenv

# Import our models
from models.user import User
from models.post import Post
from models.comment import Comment
from models.like import Like

load_dotenv()

MONGO_URI = os.getenv("MONGO_URI", "mongodb://localhost:27017")

async def init_db():
    client = AsyncIOMotorClient(MONGO_URI, tlsCAFile=certifi.where())
    print("MongoDB connected.")
    
    # Initialize Beanie with the YapHub database and our document models
    await init_beanie(
        database=client.YapHub,
        document_models=[
            User,
            Post,
            Comment,
            Like
        ]
    )
    print("Beanie initialised.")
