#!/usr/bin/ruby
require 'find'
require 'etc'
require 'inotify'
require 'syslog'

LOG=Syslog.open()
HOSTPATH=File.join(Etc.getpwuid.dir, 'Videos')
DROPPATH=File.join(Etc.getpwuid.dir, 'Dropbox', 'dropboxpacker')
LISTFILE=File.join(DROPPATH, 'list.txt')
MAX_SIZE=Integer(1.5 * 1024 * 1024 * 1024) #1.5GB


#Load and update the list of files
def loadListFile()
    files = []
    for line in File.new(LISTFILE)
        #A small piece of security
        if line.start_with?(" ") or line.start_with?("/") or line.start_with?(".")
            LOG.warning("Skipping line: #{line}")
            next
        end
        file = {:filename => line.strip()}
        files.push(file)
    end
    files
end
#Load file list
#Load files already symlinked
def main(args)
    #If the appropriate directories do not exist, create them
    if not File.exists?(DROPPATH)
        Dir.mkdir(DROPPATH)
    end
    if not File.exists?(HOSTPATH)
        puts "You need to have something at\n\t#{HOSTPATH}\nso it can be symlinked to\n\t#{DROPPATH}"
        return 1
    end
    if not File.exists?(LISTFILE)
        LOG.warning("No list file found, generating")
        list = File.new(LISTFILE, 'w')
        Find.find(HOSTPATH) do |filename|
            if File.file?(filename)
                if not filename.start_with?(HOSTPATH)
                    throw Exception("Found file without propper base path??\n\t#{filename}")
                end
                list.write("#{filename[HOSTPATH.size + 1..-1]}\n")
            end
        end
        list.flush()
        list.close()
    end
    
    puts "Dropbox path: #{DROPPATH}"
    puts "Host path:    #{HOSTPATH}"
    puts "List file:    #{LISTFILE}"
    iNotify = Inotify.new
    iNotify.add_watch(LISTFILE, Inotify::ALL_EVENTS)#Inotify::CLOSE_WRITE 
    iNotify.each_event do |event|
        puts "EVENT"
        puts event
        #update()
        puts "Waiting for next"
    end
    return 0
end

def update()    
    files = loadListFile()
    puts "Loaded #{files.size} files"
    #See if the file is symlinked, if not, symlink it. Keep the size below MAX_SIZE
    totalSize = 0
    candidates = []
    for file in files
        file[:hostLocation] = File.join(HOSTPATH, file[:filename])
        if not File.exists?(file[:hostLocation])
            puts "STALE File mentioned in list, but not in host path\n\t#{file[:filename]}"
            next
        end
        file[:size] = File.size(file[:hostLocation])
        totalSize += file[:size]
        if totalSize > MAX_SIZE
            break
        end
        
        file[:dropLocation] = File.join(DROPPATH, File.basename(file[:filename]))
        candidates.push(file)
    end
    
    puts "Found #{candidates.size} symlink candidates"
    #Remove symlinks that need to be removed
    basenames = candidates.collect {|i| File.basename(i[:filename])}
    
    for alreadyThere in Dir.glob(File.join(DROPPATH, "*"))
        #Clean up broken symlinks
        if File.symlink?(alreadyThere) and not File.exists?(alreadyThere)
            File.unlink(alreadyThere)
            next        
        end
        #Already symlinked, NEXT
        if basenames.member?(File.basename(alreadyThere))
            next
        end
        #Not a member, unlink
        if File.symlink?(alreadyThere)
            File.unlink(alreadyThere)
        end
    end
        
    #Symlink rest
    for candidate in candidates
        if File.exists?(candidate[:dropLocation])
            puts "Already available file #{candidate[:filename]}"
            next
        end
        #Symlink... finally
        File.symlink(candidate[:hostLocation], candidate[:dropLocation])
    end
    return 0
end
if __FILE__ == $0
    Process.exit(main(ARGV))
end
