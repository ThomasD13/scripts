#!/usr/bin/env python3

import os
import sys
import subprocess
from typing import TextIO

import jsonpickle   # python3 -m pip install jsonpickle
import argparse

#######################################################################################################################
##Class Definitions
#######################################################################################################################
class GitRepository:
#   absolutePath = ""  //We dont use absolute paths anymore, since this should work "portable" on different machines
    repoName = ""
    branchName = ""
    commitID = ""
    upstreamPath= ""
    detachedHead = False
    cleanState = False

    def __init__(self, path):
        #self.absolutePath = os.path.abspath(path)
        #As this is a git repository, I assume it contains a ".git" folder ;)
        self.repoName = os.path.basename(path)

    def __str__(self):
        #return "relativePath = " + self.relativePath +
        # "branchName = " + self.branchName + ", commitID = " + self.commitID
        return "relativePath = %-*s branchName = %-*s   commitID = %*s" % \
               (35, self.repoName, 20, self.branchName, 20, self.commitID)


class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

#######################################################################################################################
##Function Definitions
#######################################################################################################################
def identifyGitRepositories(out_ListOfFoundRepos, absolutePathToSearch, printInformation: bool):
    """
    Searches for git repositories within an given absolute path
    :param out_ListOfFoundRepos: A list of found repositories of type GitRepository
    :param absolutePathToSearch: Directory which will be scanned (one level) for git repositories
    :param printInformation: True: Print which directory is used and its Content
    """
    dirContent = os.listdir(absolutePathToSearch)
    if(printInformation):
        print("Given searchDirectory: " + absolutePathToSearch)
        print("Content of this directory: " + str(dirContent))

    #Search for git repositories (contain .git) and save them in gitRepositories
    for item in dirContent:
        absoluteItemPath = os.path.join(absolutePathToSearch, item)
        if(os.path.isdir(absoluteItemPath)):
            if(os.listdir(absoluteItemPath).count(".git")):
                #print("Git repository found in " + relativeDirPath)
                out_ListOfFoundRepos.append(GitRepository(absoluteItemPath))

    out_ListOfFoundRepos.sort(key=lambda x: x.repoName)

    #We need to know for each repository the branch name, revision id and upstream url
    currentDir = os.curdir
    for repo in out_ListOfFoundRepos:  # type: GitRepository
        #os.chdir(os.path.abspath(repoDir))
        # p1 = subprocess.Popen(["git", "branch"], cwd=os.path.abspath(repoDir), stdout=subprocess.PIPE)
        # p2 = subprocess.Popen(["grep", "\*"], cwd=os.path.abspath(repoDir), stdin=p1.stdout, stdout=subprocess.PIPE)
        # p3 = subprocess.Popen(["cut", "-d ' ' -f2-"], cwd=os.path.abspath(repoDir), stdin=p2.stdout, stdout=subprocess.PIPE)
        # p1.stdout.close()
        # p2.stdout.close()
        # output,err = p3.communicate()
        # print(output)
        # print(err)

        #stdout argument is required to store the stdout-output in a variable
        #universal_newlines is required to get a "string" not byte-values from stdout
        #TODO: Check for detached head
        absoluteRepoPath = os.path.join(absolutePathToSearch, repo.repoName)
        p1 = subprocess.run(["git", "rev-parse", "--abbrev-ref", "HEAD"], cwd=absoluteRepoPath, stdout=subprocess.PIPE, universal_newlines=True)
        repo.branchName = p1.stdout.strip() # remove the trailing newline \n

        p2 = subprocess.run(["git", "rev-parse", "HEAD"], cwd=absoluteRepoPath, stdout=subprocess.PIPE, universal_newlines=True)
        repo.commitID = p2.stdout.strip() # remove the trailing newline \n

        p3 = subprocess.run(["git", "ls-remote", "--get-url"], cwd=absoluteRepoPath, stdout=subprocess.PIPE, universal_newlines=True)
        repo.upstreamPath = p3.stdout.strip() # remove the trailing newline \n

def checkIfRepoIsClean(repo: GitRepository, absolutePathToSearch):
    """
    Checks a given repository if the working directory is "clean".
    :param repo: Git Repository to check
    :param absolutePathToSearch: Absolute Path where repo should be inside
    :return: True: If repository is in a CLEAN state (No changes, nothing in stage), False otherwise
    """
    p1 = subprocess.run(["git", "status", "--porcelain"], cwd=os.path.join(absolutePathToSearch, repo.repoName),
                        stdout=subprocess.PIPE, universal_newlines=True)
    status = p1.stdout.strip()  # remove the trailing newline \n
    if(status == ""):
        print("%-*s is in CLEAR state" % (35, repo.repoName))
        return True
    else:
        print(bcolors.FAIL +  "%-*s is in NOT CLEAR state" % (35, repo.repoName) + bcolors.ENDC)
        return False

def checkoutCommit(repo: GitRepository, absolutePathToSearch):
    """
    Try to checkout the working directory of given Git Repository to specific commitID
    :param repo: Git repository to work on
    :param absolutePathToSearch: Absolute Path where repo should be inside
    """
    #First fetch everything, to be able to checkout commits which are still on remote
    p0 = subprocess.run(["git", "fetch", "--all"], cwd=os.path.join(absolutePathToSearch, repo.repoName),
                        stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                        universal_newlines=True)

    print("{0}: {1})".format(repo.repoName, p0.stdout.strip()))

    p1 = subprocess.run(["git", "checkout", repo.commitID], cwd=os.path.join(absolutePathToSearch, repo.repoName),
                        stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                        universal_newlines=True)

    status = p1.stdout.strip()  # remove the trailing newline \n
    print("{0}: {1}".format(repo.repoName, status))

########################################################################################################################
## Main Definition
########################################################################################################################

def main():
    #Execute the main git functionality of this script
    parser = argparse.ArgumentParser()
    parser.add_argument("-d", required=True, help="Specify relative or absolute directory which holds git repositories")
    parser.add_argument("-list", action="store_true", help="Just prints a list of found repositories and their state")
    parser.add_argument("-save", help="Save the found repositories and their state into FILENAME.json file. This can be used to restore the repos state")
    parser.add_argument("-restore", help="Restore repositories according given file FILENAME.json")
    parser.add_argument("-force", action="store_true", help="Force to restore repositories, even if exiting ones are not in clean state")
    args = parser.parse_args()

    searchDirectoryAbsolute = os.path.abspath(args.d)
    gitRepositories = []

    print("")  # Just formating (Newline)
    identifyGitRepositories(gitRepositories, searchDirectoryAbsolute, True)

    if(args.list or args.save):
        print(*gitRepositories, sep="\n")
        print("")   #Just formating (Newline)

    if(args.save):
        frozen = jsonpickle.encode(gitRepositories)
        with open(args.save + ".json", "w") as jsonFile:
            jsonFile.write(frozen)
        print("Saved repository states to " + args.save + ".json")

    if(args.restore):
        try:
            with open(args.restore, "r") as jsonFile:  # type: TextIO
                gitRepositoriesToRestore = jsonpickle.decode(jsonFile.read())
        except (IOError):
            print("Could not open file " + args.restore)
            sys.exit(-1)

        #Check which repositories already exists in given path. If they exists, check if they are in clean state
        #If they are in clean state, I assume its save to checkout another changeset
        #If they are not in clean state, and -force flag was given, restore it anyway
        print("")   #Just formating (Newline)
        print("Restore already existent repositories. Need to check if this is clean. If not, stop here!")
        for repoToRestore in gitRepositoriesToRestore: #type: GitRepository
            repoFound = False
            for alreadyExitentRepo in gitRepositories: #type: GitRepository
                if alreadyExitentRepo.repoName == repoToRestore.repoName:
                    repoFound = True
                    if checkIfRepoIsClean(alreadyExitentRepo, searchDirectoryAbsolute) == False:
                        if(args.force is None):
                            sys.exit(-1)
                            break
                        else:
                            print("Ignoring not clean repo because of forced mode")
            if(repoFound == False):
                #Repo seems not to exist. stop here:
                print("Repository {0} not found! Stopped here!".format(repoToRestore.repoName))
                sys.exit(-1)

        #Every repo to restore has a clear state. Checkout desired commit
        print("")   #Just formating (Newline)
        for repoToRestore in gitRepositoriesToRestore: #type: GitRepository
            for alreadyExitentRepo in gitRepositories: #type: GitRepository
                if alreadyExitentRepo.repoName == repoToRestore.repoName:
                    checkoutCommit(repoToRestore, searchDirectoryAbsolute)


        #Last step is a final check: But only check repos which are got restored by this!
        restoredRepos = []
        identifyGitRepositories(restoredRepos, searchDirectoryAbsolute, False)
        repositoriesAreEqual = True

        #restoredRepos could have more repos, since there could been already git repositories.
        #Therefore, we remove all not known repos before proceed with our checks
        for repoToRestore in gitRepositoriesToRestore:
            if any(x.repoName == repoToRestore.repoName for x in restoredRepos ) == False:
                repositoriesAreEqual = False
                print("Repository to restore {0} was not found in target directory".format(repoToRestore.repoName))
            else:
                #Find that element and test the commit ID
                for restoredRepository in enumerate(restoredRepos):
                    if(restoredRepository[1].repoName == repoToRestore.repoName):
                        if(restoredRepository[1].commitID != repoToRestore.commitID):
                            print("{0}Final check failed at Repository {1}: CommitID is {2} but should be {3}{4}".format(
                            bcolors.FAIL, restoredRepository[1].repoName, restoredRepository[1].commitID,
                            repoToRestore.commitID, bcolors.ENDC))
                            repositoriesAreEqual = False
                        else:
                            #Seems fine, so abort the enumerate loop. We found what we are looking for

                            break

        print("")   #Just formating (Newline)
        if(repositoriesAreEqual):
            print(bcolors.OKGREEN + "Restored Repositories successfully!" + bcolors.ENDC)
            print(*gitRepositoriesToRestore, sep="\n")
            print("")  # Just formating (Newline)
        else:
            print(bcolors.FAIL + "Restored Repositories NOT successfully!" + bcolors.ENDC)


########################################################################################################################
## Execute main, if this script is not just imported
########################################################################################################################
if __name__ == "__main__":
	main()