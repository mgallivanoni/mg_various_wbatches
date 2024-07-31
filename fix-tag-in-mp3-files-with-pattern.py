#!/usr/bin/env python
# simple script to change tags from command line - i.e.:
# given a directory, for all mp3 found (matching an optional pattern)
# if another pattern is found in a tag, it is replaced with a different string

import json, os, pprint, re, sys

from mutagen.mp3 import MP3
from mutagen.easyid3 import EasyID3
import mutagen.id3
from mutagen.id3 import ID3, TIT2, TIT3, TALB, TPE1, TRCK, TYER


def getFileList(direct, pattern):
    print(direct, pattern)
    pattern=pattern.lower()
    matchingfiles=[]
    for dirpath, dirs, files in os.walk(direct):
        for filename in files:
            filename_lower=filename.lower()
            if pattern in filename_lower:
                if filename_lower[-4:] == '.mp3':
                    matchingfiles.append(os.path.join(dirpath, filename))
                else:
                    print("'.mp3' extension not found into file extension >>%s<<" %  filename_lower[:-4])
                    print("wrong extension for matching file: %s -> skipped!!!" % filename)
    return matchingfiles                


def main(direct, pattern, replac, oldstr, newstr):
    print("###-### start ###-###")
    if oldstr == "":
        oldstr=".*"
        case_ins_oldstr = re.compile(".*", re.IGNORECASE)
    else:
        case_ins_oldstr = re.compile(re.escape(oldstr), re.IGNORECASE)
    for filename in getFileList(direct, pattern):
        try:
            myMp3=MP3(filename, ID3=EasyID3)
            myMp3keys=myMp3.keys()

            try:    
                print( "\n%s -- %s" % (myMp3['artist'][0], myMp3['title'][0]) )
            except KeyError as kkk:
                if myMp3keys == [] or 'artist' not in myMp3keys or 'title' not in myMp3keys :
                    print("\n\n\n WARNING:\n", filename, "<<<<<<<<<<<<<<<<<<<")
                    myMp3['artist']=[input("enter artist field: "),]
                    myMp3['title']=[input("enter tiitle field: "),]
                    
                    myMp3.save()
                    myMp3keys=myMp3.keys()
                else:
                    raise kkk

            # if not replacement is defined, then the 2 main tags are printed
            if replac == "":
                for iii in myMp3keys:
                    print(">>%20s  <<  =>  %50s" % (iii, myMp3[iii][0]))

                print(">>>>>>>> ", filename, " <<<<<<<<<<<<")
    
            else:
                # ###-### performing sanitize() => search-n-replace on the desired field
                if replac.lower() not in myMp3keys:
                    raise Exception("wrong field has been passed - %s not in myMp3 keys = %s" % (replac, myMp3keys))
                else:

                    if oldstr != ".*" and oldstr.lower() not in myMp3[replac][0].lower():
                        print("replacement substring '%s' not found in '%s' -skipping" % (oldstr, myMp3[replac][0] ))
                    else:
                        print("I am about to perform:\n  myMp3[%s]=[myMp3['%s'][0].replace('%s','%s')]" % (replac, replac, oldstr, newstr))
                        if input("confirm (Y/N)?") in ["Y", 'y']:
                            myMp3[replac]=[ case_ins_oldstr.sub(newstr, myMp3[replac][0]) , ]
                            myMp3.save()
                        else:
                            print("skipping replacerment as requested")

            print("\n")
        except Exception as eee:
            print("raise exception >>>%s<<< on file %s - proceed with next file" % ( eee, filename ))
    print("###-### the end ###-###")


if __name__ == '__main__':
    #

    if len(sys.argv) < 2 or sys.argv[-1] in ['-h', '--help']:
        print("""\n  usage:

    %s [ -d directory  [ -p filenamesubstring  [ -r field:old/new ] ] ]

            NB: pattern matching in filename is case-INsensitive

            if -r is not present, a list of matching mp3 files is just printed to stdout
           
            field can be "title", "author", etc - if omitted it is defauled to "title"
           
            old can be the empty string ("") or a specific substring - if old is empty, then the whole field is replaced

            new is the new string to replace "old" - if new is empty old is removed from field

            if both old and new are empty, then the field is set to the empty string ("")

        """ % ( os.path.basename(sys.argv[0]) ))
        exit(0)

    if sys.argv[1] == '-d':
        direct=os.path.abspath(sys.argv[2])
        sys.argv=sys.argv[2:]
    else:
        direct=os.path.abspath(os.path.curdir)

    if len(sys.argv) > 1 and sys.argv[1] == '-p':
        pattern=sys.argv[2]
        sys.argv=sys.argv[2:]        
    else:
        pattern=""

    if len(sys.argv) > 1 and sys.argv[1] == '-r':
        lista=re.split("[:/]", sys.argv[2])
        if lista[0]=="":
            replac="title"
            _, oldstr, newstr=re.split("[:/]", sys.argv[2])
        else:
            replac, oldstr, newstr=re.split("[:/]", sys.argv[2])
           
        sys.argv=sys.argv[2:]        
    else:
        replac=""
        oldstr=""
        newstr=""

    main(direct, pattern, replac, oldstr, newstr)
