from fastapi import APIRouter, HTTPException, Response, status
from models.schemas.users import UserCreate, UserLogin
from database import users_collection
from utils.auth import get_password_hash, verify_password, create_access_token
from bson import ObjectId

router = APIRouter(
    prefix="/users",
    tags=["Users"]
)

@router.post("/register", status_code=status.HTTP_201_CREATED)
async def register(user: UserCreate, response: Response):
    existing_user = await users_collection.find_one({"email": user.email})
    if existing_user:
        raise HTTPException(status_code=400, detail="Email already registered")

    user_dict = user.model_dump()
    user_dict["password"] = get_password_hash(user_dict["password"])

    new_user = await users_collection.insert_one(user_dict)
    user_id = str(new_user.inserted_id)

    access_token = create_access_token(data={"sub": user_id})

    response.set_cookie(
        key="access_token",
        value=f"Bearer {access_token}",
        httponly=True,
        max_age=60 * 60 * 24 * 7,
        samesite="lax"
    )

    return {"message": "Successfully registered", "user_id": user_id}

@router.post("/login")
async def login(user: UserLogin, response: Response):
    db_user = await users_collection.find_one({"email": user.email})
    if not db_user:
        raise HTTPException(status_code=400, detail="Incorrect email or password")

    if not verify_password(user.password, db_user["password"]):
        raise HTTPException(status_code=400, detail="Incorrect email or password")

    user_id = str(db_user["_id"])
    access_token = create_access_token(data={"sub": user_id})

    response.set_cookie(
        key="access_token",
        value=f"Bearer {access_token}",
        httponly=True,
        max_age=60 * 60 * 24 * 7,
        samesite="lax"
    )

    return {"message": "Successfully logged in", "user_id": user_id}

@router.post("/logout")
async def logout(response: Response):
    response.delete_cookie("access_token")
    return {"message": "Successfully logged out"}
