# for x in range(5):
#    print(os.environ.get("SEED"))
#    print(os.environ.get("OUT"))
#    print(os.environ.get("OUT-SEED"))
#    print(os.environ.get("GEN_OPTS"))
# importing os module

import os
import shutil
import random
import sys

# Setting relative path (__file__)
ROOT_DIR = os.path.realpath(os.path.join(os.path.dirname(__file__), ""))
print("ROOT_DIR =", ROOT_DIR)


def make_directory(make_dir):
    # Parent Directory path
    parent_dir = ROOT_DIR
    # Directory to create
    directory = make_dir
    # Create the directory
    if make_dir == os.environ.get("OUT"):
        # Complete of directory to be created
        path = os.path.join(parent_dir, directory)
        print("path=", path)
        # Check if directory already exist
        is_dir = os.path.isdir(path)
        print(is_dir)
        if is_dir == False:
            print("Directory for output '% s' created" % directory)
            os.mkdir(path)
        else:
            print("Directory for output '% s' already exist" % directory)
    else:
        # Complete of directory to be created
        # path = parent_dir + "/out/" + directory
        path = os.path.join(parent_dir, directory)
        print("path=", path)
        # Check if directory already exist
        is_dir = os.path.isdir(path)
        print(is_dir)

        if is_dir == False:
            print("Directory for Seed '% s' created" % directory)
            os.makedirs(path)
        else:
            print("Directory for Seed '% s' already exist" % directory)
            shutil.rmtree(path)


def run_test(randon_number):
    # cmd = (
    #    "xrun -clean -sv -uvm -access rwc -linedebug -f ./compile_file/run.f -svseed "
    #    + os.environ.get("SEED")
    #    + " +UVM_TESTNAME=tx_test +UVM_VERBOSITY=UVM_LOW +define+UVM_REPORT_DISABLE_FILE_LINE +uvm_set_config_int=uvm_test_top,base_address,23 +UVM_CONFIG_DB_TRACE +UVM_OBJECTION_TRACE"
    # )
    cmd = (
        "xrun -clean -sv -uvm -access rwc -linedebug -f ./compile_file/run.f -svseed "
        + str(randon_number)
        + " +UVM_TESTNAME=tx_test +UVM_VERBOSITY=UVM_LOW +define+UVM_REPORT_DISABLE_FILE_LINE +uvm_set_config_int=uvm_test_top,base_address,23 +UVM_CONFIG_DB_TRACE +UVM_OBJECTION_TRACE"
    )
    print("Command to run = ", cmd)
    os.system(cmd)


def random_num():
    long_int = sys.maxsize + 1
    # The data type is represented as int
    print("maxint + 1 :" + str(long_int) + " - " + str(type(long_int)))
    # Generating a random number within a min and max range
    rand = random.randint(1, 99999)
    return rand


def run_make():
    cmd = "make run_py"
    print("Command to run = ", cmd)
    os.system(cmd)


def main():
    # make_directory(os.environ.get("OUT"))
    # make_directory(os.environ.get("OUT-SEED"))
    # using sys.maxsize
    rand = random_num()
    print("Random seed = ", rand)
    run_test(rand)


if __name__ == "__main__":
    main()
