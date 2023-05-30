import csv
import subprocess
import os
import pandas as pd
import argparse
import sys


#
# Constants
#
VERBOSE_MODE = True
VERSION_SCRIPT = '1.0 (27/May/2023 by Ricky.Marek)'
SCRIPT = sys.argv[0]
OPENSCAD_COMMAND = "openscad"
SCAD_SCRIPT = "simple_plant_label.scad"
STL_SUBDIR = "stl_files"
XLSX_FILE = "labels_list.xlsx"


def get_args():
    parser = argparse.ArgumentParser(description='Wrapper for running openscad to generate stl files per label',
                                     formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument('-v', '--verbose', dest='VERBOSE_MODE', action='store_true', default=VERBOSE_MODE,
                        help='Turn on verbose mode on')
    parser.add_argument('-s', '--script', dest='SCAD_SCRIPT', action='store', help='openscad script to use')
    parser.add_argument('-d', '--directory', dest='STL_SUBDIR', action='store',
                        help='Output directory for the stl files')
    parser.add_argument('-x', '--xlsx_file', dest='XLSX_FILE', action='store', help='Excel file with the tags list')

    arguments = vars(parser.parse_args())
    return arguments


if __name__ == '__main__':

    args = get_args()

    script = SCAD_SCRIPT
    if args['SCAD_SCRIPT'] is not None:
        script = args['SCAD_SCRIPT']

    if not os.path.isfile(script):
        print(f"{SCRIPT}[ERROR]: Missing openscad script. File {script} does not exist.")
        sys.exit(1)

    xlsx_file = XLSX_FILE
    if args ['XLSX_FILE'] is not None:
        xls_file = args['XLS_FILE']

    if not os.path.isfile(xlsx_file):
        print(f"{SCRIPT}[ERROR]: Missing Excel file. File {xlsx_file} does not exist.")
        sys.exit(1)

    stl_subdir = STL_SUBDIR
    if args['STL_SUBDIR'] is not None:
        stl_subdir = args['STL_SUBDIR']

    # Create subdir if it does not exist.
    if not os.path.exists(stl_subdir):
        os.makedirs(stl_subdir)

    if args['VERBOSE_MODE']:
        print(f"{SCRIPT}: command:....... {OPENSCAD_COMMAND}")
        print(f"{SCRIPT}: script:........ {script}")
        print(f"{SCRIPT}: stl_subdir:.... {stl_subdir}")
        print(f"{SCRIPT}: xlsx_file:..... {xlsx_file}")

    df = pd.read_excel(xlsx_file)
    for i, row in df.iterrows():
        file_name  = f"{stl_subdir}/{row['FILENAME']}"
        if not os.path.exists(file_name):
            output = f'-o{file_name.strip()}'
            text =  f"-D label_text=\"{row['NAME']}\""
            direction = f"-D label_direction=\"{row['DIRECTION']}\""
            if args['VERBOSE_MODE']:
                print(f"{SCRIPT}: Running {OPENSCAD_COMMAND} {output} {script} {text} {direction}...")
            subprocess.run([OPENSCAD_COMMAND, output, script, text, direction])


