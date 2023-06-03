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
VERSION = '1.0 (27/May/2023 by Ricky.Marek)'
SCRIPT = sys.argv[0]
OPENSCAD_COMMAND = "openscad"
SCAD_SCRIPT = "simple_plant_label.scad"
STL_SUBDIR = "output"
XLSX_FILE = "labels.xlsx"

usage_string = f"""
    python3 {SCRIPT} [-h][-v][-o <STL_SUBDIR>][-s <SCAD_SCRIPT>][-x <XLSX_FILE>
       -h                Will print this help message.
       -v                Turn on verbose mode.
       -o STL_SUBDIR     Create the STL files inside the <STL_SUBDIR> directory.
       -s SCAD_SCRIPT    Use a different <SCAD_SCRIPT> for creating the STL files.
       -x XLSX_FILE      Excel file with the labels list to create.

    The Excel file has the following columns:
    - NAME: Name of the variety or plant.
    - CODE: A unique code you may give.
    - FILENAME: The name for the lable, usually composed from the CODE.
    - DIRECTION: "rtl" or "ltr" as text direction (English vs Hebrew)
    
    The default values are:
    - SCAD_SCRIPT....{SCAD_SCRIPT}
    - STL_SUBDIR.....{STL_SUBDIR}
    - XLSX_FILE......{XLSX_FILE}
    - OPENSCAD.......{OPENSCAD_COMMAND}

    The script opens the Excel file and loops on all rows, by calling openscad with:
       openscad <SCAD_SCRIPT> -o <STL_SUBDIR>/<FILENAME> -D 'label_text="<NAME>"' -D 'label_direction="<DIRECTION>"'

    {SCRIPT} {VERSION}
"""

def get_args():
    parser = argparse.ArgumentParser(description='Wrapper for running openscad to generate stl files per label',
                                     formatter_class=argparse.RawTextHelpFormatter, usage=usage_string)

    parser.add_argument('-v', '--verbose', dest='VERBOSE_MODE', action='store_true', default=VERBOSE_MODE,
                        help='Turn on verbose mode on')
    parser.add_argument('-s', '--script', dest='SCAD_SCRIPT', action='store', help='openscad script to use')
    parser.add_argument('-o', '--output', dest='STL_SUBDIR', action='store',
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
        xlsx_file = args['XLSX_FILE']

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

    df = pd.read_excel(xlsx_file, engine='openpyxl')
    for i, row in df.iterrows():
        file_name  = f"{stl_subdir}/{row['FILENAME']}"
        if not os.path.exists(file_name):
            output = f'-o{file_name.strip()}'
            text =  f"-D label_text=\"{row['NAME']}\""
            direction = f"-D label_direction=\"{row['DIRECTION']}\""
            if args['VERBOSE_MODE']:
                print(f"{SCRIPT}: Running {OPENSCAD_COMMAND} {output} {script} {text} {direction}...")
            subprocess.run([OPENSCAD_COMMAND, output, script, text, direction])


