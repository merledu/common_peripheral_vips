# importing os module
import os

# Setting relative path (__file__)
ROOT_DIR = os.path.realpath(os.path.join(os.path.dirname(__file__), ""))
print("ROOT_DIR =", ROOT_DIR)


def make_directory(make_dir):
    # Parent Directory path
    parent_dir = ROOT_DIR
    # Directory to create
    directory = make_dir
    # Complete of directory to be created
    path = os.path.join(parent_dir, directory)
    print("path=", path)
    # Check if directory already exist
    is_dir = os.path.isdir(path)
    print(is_dir)
    # Create the directory

    if make_dir == os.environ.get("OUT"):
        if is_dir == False:
            print("Directory '% s' created" % directory)
            os.mkdir(path)
        else:
            print("Directory '% s' already exist" % directory)
    else
        if is_dir == False:
            print("Directory '% s' created" % directory)
            os.mkdir(path)
        else:
            print("Directory '% s' already exist" % directory)

# def make_directory (args):
#    # Parent Directory path
#    parent_dir = ROOT_DIR
#    # Directory to create
#    directory = os.environ.get("OUT")
#    # Complete of directory to be created
#    path = os.path.join(parent_dir, directory)
#    print("path=", path)
#    # Check if directory already exist
#    is_dir = os.path.isdir(path)
#    print(is_dir)
#    # Create the directory
#    if is_dir == False:
#        print("Directory '% s' created" % directory)
#        os.mkdir(path)
#    else:
#        print("Directory '% s' already exist" % directory)

# for x in range(5):
#    print(os.environ.get("SEED"))
#    print(os.environ.get("OUT"))
#    print(os.environ.get("OUT-SEED"))
#    print(os.environ.get("GEN_OPTS"))


def main():
    make_directory(os.environ.get("OUT"))


if __name__ == "__main__":
    main()
