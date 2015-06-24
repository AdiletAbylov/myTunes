require "optparse"
require "mp3info"

def process_dir(dir)
	Dir.chdir(dir)
	dir.each do |path|
		next if path == '.' or path == '..' or File.basename(path).start_with?(".")
			process_file path
	end
end

def process_file(path)
	if File.extname(path) == ".mp3"
		Mp3Info.open(path) do |info|
			new_file_name = [info.tag.artist, info.tag.album, "%02d" % info.tag.tracknum,info.tag.title ].join(" - ")
			puts new_file_name
			File.rename(path, new_file_name + ".mp3")
		end
	end
end

options = {}

OptionParser.new do |opts|
	opts.banner = "Usage:  #{File.basename($PROGRAM_NAME)} [OPTIONS] OTHER_ARGS"
	
	opts.separator ""
	opts.separator "Specific Options:"
	
	
	opts.on('-i', '--input DIR', 'Source directory') { |v| options[:source_dir] = v }
 	opts.on('-o', '--output DIR', 'Output direcotry') { |v| options[:output_dir] = v }

	opts.separator "Common Options:"
	
	opts.on( "-h", "--help", "Show this message." ) do
		puts opts
		exit
	end
	
	begin
		opts.parse!
	rescue
		puts opts
		exit
	end
end

if  not Dir.exist? options[:source_dir]
 	exit
end 

if options[:output_dir]
	if Dir.exist? options[:output_dir]
		output_dir = Dir.open(options[:output_dir])
	else
		output_dir = Dir.new(options[:output_dir])
	end
end

process_dir Dir.open options[:source_dir]
	

