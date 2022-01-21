import os
import shutil
import random
import sys


def run_test():
    cmd = "python3 script.py"
    print("Command to run = ", cmd)
    os.system(cmd)


if __name__ == "__main__":
    # This is run-time argument, which can be set from command line to instruct how many tests to run
    no_of_tests = sys.argv
    # Converting this list object to integer
    num_of_tests = int(no_of_tests[1])
    print("number of test to run = ", num_of_tests)
    for x in range(num_of_tests):
        run_test()
