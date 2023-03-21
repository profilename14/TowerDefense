import sys, os
from pathlib import Path

TITLE = "-- ferrous fight v2.1.0"
AUTHORS = "-- jeren, jasper, jimmy & kaoushik"

def main():
    if len(sys.argv) < 2:
        raise Exception("Arguments: src_directory game.p8")
    cwd = sys.argv[1]
    pico8File = sys.argv[2]

    if cwd == ".":
        cwd = os.getcwd()
    elif cwd == "..":
        cwd = Path(os.getcwd()).parent
    elif not os.path.exists(cwd):
        raise("Path can't be found")

    print("Writing Label...")
    picoFilePath = os.path.join(cwd, pico8File)
    result = ""
    with open(picoFilePath, encoding="utf8") as pf:
        lines: list[str] = pf.readlines()
        for line in lines:
            if line.lstrip().startswith("--"): continue

            if line.count("__lua__") > 0:
                result += line
                result += TITLE + "\n"
                result += AUTHORS + "\n"
                continue
            result += line

    with open(picoFilePath, "w", encoding="utf8") as f:
        f.write(result)
    print("Finished Writing Label")


main()