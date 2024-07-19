from touchfish import *
from yfunc import *
import sys

host = sys.argv[1]
port = sys.argv[2]
search_text = sys.argv[3]

tfop = tfoperator(host=host, port=port)

res = tfop.search_fish(fuzzys=search_text, tags=[['bookmark']], page_size=999)
fish_list: list[FishResp] = res.data[1]

RecipeView(
    type=RecipeViewType.list2,
    default_item_icon='system:link',
    items=[
        RecipeViewItem(
            title = fish.description,
            description = fish.preview,
            icon = f"fish:{ystr(fish.extra_info).json().to_dic().get('bookmark_icon', None)}",
            actions = [
                RecipeAction(
                    type=RecipeActionType.open,
                    arguments=[
                        RecipeActionArg(
                            type=RecipeActionArgType.plain,
                            value=fish.preview
                        )
                    ]
                ),
                RecipeAction(type=RecipeActionType.hide),
            ]
        ) for fish in fish_list
    ]
).show()
