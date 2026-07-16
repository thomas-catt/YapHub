from fastapi import APIRouter

# This is exactly like `const router = express.Router()`
# We can prefix all routes in this router with "/users"
# and assign them to the "Users" group in the Swagger docs using `tags`.
router = APIRouter(
    prefix="/users",
    tags=["Users"]
)

# Since we have `prefix="/users"`, this route is actually GET /users/
@router.get("/")
def get_all_users():
    return {"message": "Get all users"}

@router.get("/{user_id}")
def get_user(user_id: str):
    return {"message": f"Get user {user_id}"}
