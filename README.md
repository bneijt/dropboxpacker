Dropboxpacker
-------------

Pack the top part of a list of files into your dropbox space.

This daemon (use -d to daemonize) will watch a text file in your Dropbox (using inotify) and will try to make sure that the top list of these files are kept in your Dropbox using only the sum of the size as a limit.

Files are symlinked in, so not a lot of disk impact should occur.

Currently it does not support many options and the basic configuration will have to be done in the source (see the variables at the top). Read the source before running the program.


