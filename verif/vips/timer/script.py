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
OUT = "out"

print("ROOT_DIR =", ROOT_DIR)


def make_directory(make_dir):
    # Parent Directory path
    parent_dir = ROOT_DIR
    # Directory to create
    directory = make_dir
    # Create the directory
    if make_dir == OUT:
        # Complete of directory to be created
        path = os.path.join(parent_dir, directory)
        print("path of output directory =", path)
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
    # using sys.maxsize
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


def find_latest_dir():
    import os
    import time
    import operator
    import shutil

    alist = {}
    now = time.time()
    path = ROOT_DIR + "/" + OUT
    print("path=", path)
    directory = os.path.join("/home", path)
    os.chdir(directory)
    for file in os.listdir("."):
        if os.path.isdir(file):
            timestamp = os.path.getmtime(file)
            # get timestamp and directory name and store to dictionary
            alist[os.path.join(os.getcwd(), file)] = timestamp
    # sort the timestamp
    for i in sorted(alist.items(), key=operator.itemgetter(1)):
        latest = "%s" % (i[0])
    # latest=sorted(alist.iteritems(), key=operator.itemgetter(1))[-1]
    print("newest directory is ", latest)
    return latest


def copy_files(src_dir, dst_dir, copy_file):
    # os.chdir(latest)

    # For copying the all_args_rand_test.yaml in the latest out/seed directory made for specific test
    src_file_path = src_dir + "/" + copy_file
    dst_file_path = dst_dir + "/" + copy_file
    print("src_file_path = ", src_file_path)
    print("dst_file_path = ", dst_file_path)
    shutil.copy(src_file_path, dst_file_path)
    print("Copied file")


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


def main():
    # make_directory(os.environ.get("OUT"))
    # make_directory(os.environ.get("OUT-SEED"))
    # Generating random seed
    seed = random_num()
    # Printing seed
    print("Random seed = ", seed)
    # Running test on random seed
    run_test(seed)
    # Creating output directory
    make_directory(OUT)
    # Creating directory for a running seed in output directory
    dir_seed = OUT + "/seed-" + str(seed)
    make_directory(dir_seed)
    # Finding a latest directory in output directory
    latest_dir = find_latest_dir()
    # Copy log file in seed direcory
    src_dir = ROOT_DIR
    dst_dir = latest_dir
    copy_file = "xrun.log"
    print("src_dir=", src_dir)
    print("dst_dir=", dst_dir)
    print("copy_file=", copy_file)
    copy_files(src_dir, dst_dir, copy_file)
    # Find weather test pass or not by checking TEST PASSED IN xrun.log
    test_passed = find_string("[TEST PASSED]", dst_dir + "/" + "xrun.log")
    print("TEST PASSED = ", test_passed)


if __name__ == "__main__":
    main()
