from touchfish import *
from yfunc import *
import subprocess
import sys

search_text = sys.argv[1]

def query_sdcv(word):
    try:
        result = subprocess.run(['/opt/homebrew/bin/sdcv', '-u', 'quick_eng-zh_CN', '-nj', word], capture_output=True, text=True)
        if result.returncode != 0:
            raise Exception(f"Error occurred: {result.stderr}")
        return result.stdout
    except FileNotFoundError:
        raise Exception("Error: sdcv command not found. Make sure sdcv is installed and in your PATH.")

try:
    res = query_sdcv(search_text)
    hits = ystr(res).json().to_object()
    RecipeView(
        type=RecipeViewType.list1,
        default_item_icon='system:textformat',
        items=[
            RecipeViewItem(
                title = hit['word'],
                description = '|'.join(ystr(hit['definition']).to_rows()),
            ) for hit in hits
        ]
    ).show()
except Exception as e:
    pass


