#!/usr/bin/env python3

import os
import argparse

from typing import Set


#######################################################################################################################
##Class Definitions
#######################################################################################################################
class YoctoPackage:
    packageName = ""
    packageVersion = ""
    recipeName = ""
    licenses = list()

    def __init__(self, packageName, packageVersion, recipeName, licenses):
        self.packageName = packageName
        self.packageVersion = packageVersion
        self.recipeName = recipeName
        self.licenses = licenses

    def containsLicense(self, license):
        lowerSearch = str(license).lower()
        for license in self.licenses:
            lower = str(license).lower()
            if(lowerSearch in lower):
                return True
        return False

#######################################################################################################################
##Function Definitions
#######################################################################################################################
def extractWordsFromHittetLineOfFile(inputFilePath, stringToFindInLine):
    matchedLines = set()  # type: Set[str] # This creates a empty set
    with open(inputFilePath, "r") as file:
        for line in file:
            if stringToFindInLine in line:
                matchedLines.update(line.strip().split(" "))  # Remove newline from end of line, and split words
    return matchedLines

########################################################################################################################
## Main Definition
########################################################################################################################
def main():
    #Execute the main functionality of this script:
    #Either Search for lines with a special keyword and extract all
    #       "words" of these lines (keyword and defined character(s) excluded)
    #Or     search all packages which have a specific license

    parser = argparse.ArgumentParser()
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("-s", help="Specify the generic search string (case insensitive). For example \"foo bar\"")
    group.add_argument("-l", help="Specify the license search string (case insensitive). For example \"GPLv2\"")
    parser.add_argument("-i", required=True, help="Specify the input file")
    parser.add_argument("-o", required=False, help="Specify the output file for the results")
    parser.add_argument("-r", required=False, help="Specify characters or words which should get removed at output file. For Example \"( ) foobar\"")

    args = parser.parse_args()

    matchedLines = set()  # This creates a empty set
    if(args.s):
        #Search for a specific string
        stringToFind = args.s
        matchedLines = extractWordsFromHittetLineOfFile(args.i, stringToFind)

        if(len(matchedLines) > 0):
            #Remove stringToFind from results and sort the list alphabetically
            sortedList = sorted(matchedLines, key=str.lower)
            sortedList.remove(stringToFind)

            #If user gave some characters/string to remove, apply it now
            if(args.r):
                toRemoveCharacters = args.r.split(" ")
                clearedListOfCharacters = list()
                for line in sortedList:
                    for remove in toRemoveCharacters:
                        line = line.replace(remove,"")
                    clearedListOfCharacters.append(line)
                sortedList = clearedListOfCharacters

            #If user wants to write results in a file, do it now
            if(args.o):
                with open(args.o, "w") as file:
                    for item in sortedList:
                        file.write("%s\n" % item)

            #Write results on console, without newline
            for item in sortedList:
                print(item + ", ")
        else:
            print("No lines with " + args.s +" found")

    if(args.l):
        #Search for specific licences
        #Create a list of all packages of given manifest file
        #One package has following layout:
        #1. Line: PACKAGE VERSION:
        #2. Line: RECIPE NAME:
        #3. Line: LICENSE:
        #4. Line: \n
        listPackages = list()
        with open(args.i, "r") as file:
            lines = []
            for line in file:
                lines.append(line)
                if len(lines) >= 5:
                    listLicenses = lines[3].strip().split(" ")
                    listLicenses.remove("LICENSE:")
                    listPackages.append(YoctoPackage(lines[0].strip().replace("PACKAGE NAME: ", ""),
                                                     lines[1].strip().replace("PACKAGE VERSION: ", ""),
                                                     lines[2].strip().replace("RECIPE NAME: ", ""),
                                                     listLicenses))
                    lines = []

        print("Search for " + args.l + " in " + str(len(listPackages)) + " packages: ")
        #Print all packages which contains specific license
        counterFoundPackages = 0
        for package in listPackages:
            if(package.containsLicense(args.l)):
                counterFoundPackages = counterFoundPackages+1
                print("Recipe: %-*s Package: %-*s Licenses: %-*s" %\
                      (25, package.recipeName, 25, package.packageName, 25, str(package.licenses).strip("[]")))
        print("Found " + str(counterFoundPackages) + " matching packages!")

        #If user wants to write results file, just do it
        if (args.o):
            with open(args.o, "w") as file:
                for package in listPackages:
                    if (package.containsLicense(args.l)):
                        file.write(
                            "Recipe: %-*s Package: %-*s Licenses: %-*s\n" %\
                            (25, package.recipeName, 25, package.packageName, 25, str(package.licenses).strip("[]")))


########################################################################################################################
## Execute main, if this script is not just imported
########################################################################################################################
if __name__ == "__main__":
    main()