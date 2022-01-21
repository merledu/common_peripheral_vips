import os
import shutil
import random
import sys


def run_test():
    cmd = "python3 script.py"
    print("Command to run = ", cmd)
    os.system(cmd)


if __name__ == "__main__":
    for x in range(2):
        run_test()
