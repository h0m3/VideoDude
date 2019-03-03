#!/usr/bin/env python
# Generate charmap.asm from charmap.txt
# Read charmap.txt for more information
#

from datetime import datetime

def main():
    lines = []

    with open("charmap.txt", "r") as file:
        for textline in file.read().splitlines():
            textline = textline.strip().replace(" ", "").replace("\t", "")
            if len(textline) == 16 and not textline.startswith("#"):
                for line in range(8):
                    if len(lines) <= line:
                        lines.append([])
                    lines[line].append(textline[line * 2:line * 2 + 2])

    newfile = "; Automatically generated file based on charmap.txt\n"
    newfile += "; See charmap.txt and chargen.py for more information\n"
    newfile += "; Generated %s\n" % datetime.now()
    newfile += ";\n"
    newfile += "\n.org 0x400\n"
    newfile += "charmap:\n"

    for line in range(8):
        newfile += "\n; Line %d\n" % line
        for idx, item in enumerate(lines[line]):
            if idx % 2:
                newfile += ".dw 0x%s%s ; 0x%02x and 0x%02x\n" % (
                    item,
                    lines[line][idx - 1],
                    idx,
                    idx - 1
                )

    with open("charmap.asm", "w") as file:
        file.write(newfile)

if __name__ == "__main__":
    main()
