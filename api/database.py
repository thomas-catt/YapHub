from motor.motor_asyncio import AsyncIOMotorClient
import os
import certifi
from dotenv import load_dotenv

load_dotenv()

MONGO_URI = os.getenv("MONGO_URI", "mongodb://localhost:27017")

print("Connected to:", MONGO_URI)

client = AsyncIOMotorClient(MONGO_URI, tlsCAFile=certifi.where())

db = client.YapHub

users_collection = db.get_collection("users")
posts_collection = db.get_collection("posts")
comments_collection = db.get_collection("comments")
