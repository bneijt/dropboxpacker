#!/usr/bin/ruby
require 'find'
HOSTPATH='/tmp/banaan'
LISTFILE='/tmp/filelist'
DROPPATH='/tmp/dropped'
SIZE=1024*1024*1024 #1GB

def update()
    currentLinks = Dir.glob(DROPPATH)
    
    #Get the filelist
    # Link as much files from the top of the list as possible (size permits)
    # Unlink any file not in that list
    # Append any new files you can find to the list, if needed write
    # Done!
end

#Load and update the list of files
def loadListFile()
    files = []
    for line in File.new(LISTFILE):
        files.append({:filename => line.strip(), })
   listFile = File.new(LISTFILE).read()
   #Catagorize old and new
   #Randomly remove old, add new
   
end
#Load file list
#Load files already symlinked



FILES = []
Find.find(HOSTPATH) do |p|
    if File.file?(p):
        FILES.push(p)
    end
end

