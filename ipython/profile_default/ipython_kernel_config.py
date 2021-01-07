from pathlib import Path

c = get_config()
with open(Path(__file__).parent / "pre_import.py") as f:
    c.InteractiveShellApp.exec_lines = f.readlines()
