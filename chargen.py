#!/usr/bin/env python

def main():
    lines = []
    lines.append([])
    lines.append([])
    lines.append([])
    lines.append([])
    lines.append([])
    lines.append([])
    lines.append([])
    lines.append([])

    with open("charmap.txt", "r") as file:
        for textline in file.read().splitlines():
            textline = textline.strip().replace(" ", "").replace("\t", "")
            if len(textline) == 16 and not(textline.startswith("#")):
                lines[7].append(textline[:2])
                lines[6].append(textline[2:4])
                lines[5].append(textline[4:6])
                lines[4].append(textline[6:8])
                lines[3].append(textline[8:10])
                lines[2].append(textline[10:12])
                lines[1].append(textline[12:14])
                lines[0].append(textline[14:])

    newfile = "; Automatically generated file, use charmap.txt and chargen.py\n\n\n.org 0x0400\n\ncharmap:"

    for line in range(8):
        newfile += "\n; Line %d\n" % line
        for idx, item in enumerate(lines[line]):
            if idx % 2:
                newfile += ".dw 0x%s%s ; 0x%02x and 0x%02x\n" % (item, lines[line][idx - 1], idx, idx - 1)

    with open ("charmap.asm", "w") as file:
        file.write(newfile)

if __name__ == "__main__":
    main()
