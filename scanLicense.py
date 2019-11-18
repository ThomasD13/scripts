import os
import argparse
########################################################################################################################
## Main Definition
########################################################################################################################

def main():
    #Execute the main functionality of this script:
    #Search for lines with a special keyword and extract all
    #"words" of these lines (keyword excluded)

    parser = argparse.ArgumentParser()
    parser.add_argument("-i", required=True, help="Specify the input file")
    parser.add_argument("-s", required=True, help="Specify the search string. For example \"foo bar\"")
    parser.add_argument("-o", required=True, help="Specify the output file for the results")
    args = parser.parse_args()


    stringToFind = args.s
    matchedLines = set()    # This creates a empty set
    with open(args.i, "r") as file:
        for line in file:
            if stringToFind in line:
                matchedLines.update(line.strip().split(" "))    #Remove newline from end of line, and split words

    if(len(matchedLines) > 0):
        sortedList = sorted(matchedLines, key=str.lower)
        with open(args.o, "w") as file:
            for item in sortedList:
                file.write("%s\n" % item)
    else:
        print("No lines with " + args.s +" found")

########################################################################################################################
## Execute main, if this script is not just imported
########################################################################################################################
if __name__ == "__main__":
    main()