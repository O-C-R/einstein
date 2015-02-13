import sys

from os import system

#for arg in sys.argv:
for x in range(1, len(sys.argv)):
    #print arg
    print sys.argv[x]
    #system('say ' + arg)
    #system('say ' + sys.argv[x])