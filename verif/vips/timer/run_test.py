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


if __name__ == "__main__":
    # This is run-time argument, which can be set from command line to instruct how many tests to run
    no_of_tests = sys.argv
    # Converting this list object to integer
    num_of_tests = int(no_of_tests[1])
    print("number of test to run = ", num_of_tests)
    for x in range(num_of_tests):
        run_test()
    # Function to list number of sub directories in output directory
    sub_directory_list = list_immediate_sub_directories()
