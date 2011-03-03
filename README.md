Dropboxpacker
-------------

Pack the top part of a list of files into your dropbox space using inotify.

This deamon will watch a text file in your Dropbox using inotify and will try to make sure that the top list of these files are kept in your Dropbox using only the sum of the size as a limit.

Files are symlinked in, so no a lot of disk impact should occur.

