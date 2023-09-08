import json
import os
import sys

# read json file and return dictionary
def read_json(filename):
    with open(filename, "r") as f:
        return json.load(f)

# read all json files and return a dictionary of all word counts
def reduce_json(partial_path, n_files):
    word_counts = {}
    for i in range(1, n_files+1):
        partial_counts = read_json(f"{partial_path}/counts/{i}.json")
        for word in partial_counts:
            if word in word_counts:
                word_counts[word] += partial_counts[word]
            else:
                word_counts[word] = partial_counts[word]

    # sort word counts in descending order
    word_counts = {k: v for k, v in sorted(word_counts.items(), key=lambda item: item[1], reverse=True)}

    # store word counts in json file
    with open(f"{partial_path}/counts/total_counts.json", "w") as f:
        json.dump(word_counts, f)

def print_usage():
    print("Error: wrong number of arguments. \nUsage: python reduce.py <n_files>\n"
                + "Where:\nn_files (optional): integer representing the number of files to reduce. Defaults to 9.")

if __name__ == "__main__":
    partial_path = f"."

    # check if number of arguments is valid; if not, print usage message and exit
    if len(sys.argv) > 2:
        print_usage()
        sys.exit(1)

    # check if valid input for number of files; if not, use default value
    try:
        n_files = int(sys.argv[1])
    except:
        n_files = 9

    # To check if all map operations were finished, check_maps keeps track of
    # of the files that have yet to be reduced. When a count file appears 
    # in the directory, it is considered mapped and is removed from check_maps.
    # While loop will continue until all files have been mapped

    # Initial condition: all files yet to be reduced.
    check_maps = list(range(1, n_files + 1))   
    while len(check_maps) > 0: 
        for file in check_maps[:]:
            # if count file exits, map operation is finished then remove from check_maps
            if os.path.exists(f"{partial_path}/counts/{file}.json"):
                check_maps.remove(file)

    # reduce all count files
    reduce_json(partial_path, n_files)

