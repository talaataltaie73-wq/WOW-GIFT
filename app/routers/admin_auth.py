from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel

router = APIRouter(prefix="/auth/admin", tags=["admin-auth"])


class LoginRequest(BaseModel):
    email: str
    password: str


class LoginResponse(BaseModel):
    token: str
    user: dict


# Demo credentials for development
DEMO_ADMIN = {
    "id": "admin-001",
    "email": "admin@wowgift.app",
    "name": "مدير النظام",
    "role": "admin",
}

DEMO_PASSWORD = "admin123"


@router.post("/login", response_model=LoginResponse)
async def admin_login(request: LoginRequest):
    """Admin login endpoint with credentials validation"""
    
    # Validate credentials
    if request.email != DEMO_ADMIN["email"]:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="البريد الإلكتروني أو كلمة المرور غير صحيحة"
        )
    
    if request.password != DEMO_PASSWORD:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="البريد الإلكتروني أو كلمة المرور غير صحيحة"
        )
    
    # Generate a simple token (in production, use JWT)
    token = f"admin_token_{DEMO_ADMIN['id']}"
    
    return LoginResponse(
        token=token,
        user=DEMO_ADMIN
    )


@router.get("/me")
async def get_current_admin():
    """Get current admin user info"""
    return DEMO_ADMIN
