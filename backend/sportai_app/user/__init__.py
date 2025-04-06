from sportai_app.utils import DecoratedBlueprint
from sportai_app.utils import handle_exceptions, login_required

user = DecoratedBlueprint(
    "user",
    __name__,
    decorators=[login_required(), handle_exceptions],
)

from .routes import *
