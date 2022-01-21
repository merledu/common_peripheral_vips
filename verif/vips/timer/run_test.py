import os
import shutil
import random
import sys

# Setting relative path (__file__)
ROOT_DIR = os.path.realpath(os.path.join(os.path.dirname(__file__), ""))
OUT = "out"


def run_test():
    cmd = "python3 script.py"
    print("Command to run = ", cmd)
    os.system(cmd)


# Function to list number of sub directories in output directory
def list_immediate_sub_directories():
    path = ROOT_DIR + "/" + OUT
    print("Path to list the sub directories = ", path)
    directory_contents = os.listdir(path)
    print(directory_contents)
    return directory_contents


def process_sub_dir(sub_directorires):
    for item in sub_directorires:
        print("For seed directory =", item)
        path = ROOT_DIR + "/" + OUT + "/" + item + "/" + "xrun.log"
        if os.path.isfile(path):
            print("Path to log file in", item, "directory = ", path)
        else:
            print("Log file in", item, "directory does not exist")


def find_string(string_to_find, in_file):
    # opening a text file
    file = open(in_file, "r")
    # read file content
    readfile = file.read()
    # checking condition for string found or not
    if string_to_find in readfile:
        print("String", string_to_find, "Found In File")
        return 1
    else:
        print("String", string_to_find, "Not Found")
        return 0
    # closing a file
    file.close()


if __name__ == "__main__":
    # This is run-time argument, which can be set from command line to instruct how many tests to run
    no_of_tests = sys.argv
    # Converting this list object to integer
    num_of_tests = int(no_of_tests[1])
    print("number of test to run = ", num_of_tests)

    # "num_of_tests" number of test to run
    for x in range(num_of_tests):
        run_test()

    # Function to list number of sub directories in output directory
    sub_directory_list = list_immediate_sub_directories()
    # Process sub directories
    process_sub_dir(sub_directory_list)
