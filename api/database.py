import motor.motor_asyncio
import os

MONGO_URI = os.getenv("MONGO_URI", "mongodb://localhost:27017")

# Create the async MongoDB client
client = motor.motor_asyncio.AsyncIOMotorClient(MONGO_URI)

# Select the database (it will be created automatically when you insert data)
db = client.yaphub_db

# Example collections (similar to SQL tables)
users_collection = db.get_collection("users")
posts_collection = db.get_collection("posts")
comments_collection = db.get_collection("comments")
