import sys
import json
import os

def count_words(index:str, partial_path:str):
    filename = f"{partial_path}/titles/{index}.txt"

    # check if counts directory exists; if not, create it
    if not os.path.exists(f"{partial_path}/counts"):
        os.mkdir(f"{partial_path}/counts")

    # open file and read contents
    with open(filename, "r") as f:
        contents = f.read()

    # find counts for all different words in the file
    words = contents.split()
    word_counts = {}
    for word in words:
        if word.lower() in word_counts:
            word_counts[word.lower()] += 1
        else:
            word_counts[word.lower()] = 1

    # write word counts to file
    with open(f"{partial_path}/counts/{index}.json", "w") as f:
        json.dump(word_counts, f)

def print_usage():
    print("Usage: python3 map.py <index>\n"
            + "Where:\nindex: integer between 1 and 9 (inclusive)")

if __name__ == "__main__":
    partial_path = f"."
    
    # check if index argument was provided if not, print usage message and exit
    if len(sys.argv) != 2:
        print_usage()
        sys.exit(1)

    # retrieve CMD arguments; removing spaces
    index = sys.argv[1].replace(" ", "")
    count_words(index, partial_path)
    


    


    


    