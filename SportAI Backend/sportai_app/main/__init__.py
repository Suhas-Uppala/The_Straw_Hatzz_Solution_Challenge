from sportai_app.utils import DecoratedBlueprint
from sportai_app.utils import handle_exceptions

main = DecoratedBlueprint("main", __name__, decorators=[handle_exceptions])

from .routes import *
