from fastapi import Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from traceback import print_exception

def exception_handling_middleware(request: Request, exc: Exception):
    print("A server error was caught:")
    print_exception(type(exc), exc, None)

    return JSONResponse(
        status_code=500,
        content={"message": "An unexpected server-side error occured."}
    )

def validation_exception_handler(request: Request, exc: RequestValidationError):
    errors = []
    for err in exc.errors():
        field = err["loc"][-1] if err["loc"] else None
        errors.append({
            "field": str(field),
            "type": err["type"]
        })
    return JSONResponse(
        status_code=422,
        content={"errors": errors}
    )