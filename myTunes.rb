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
			new_file_name = [info.tag.artist, info.tag.album, "%02d" % info.tag.tracknum?:0, info.tag.title ].join(" - ")
			new_file_name = sanitize_filename(new_file_name)
			puts new_file_name
			File.rename(path, new_file_name + ".mp3")
		end
	end
end

def sanitize_filename(filename)
  # Split the name when finding a period which is preceded by some
  # character, and is followed by some character other than a period,
  # if there is no following period that is followed by something
  # other than a period (yeah, confusing, I know)
  fn = filename.split /(?<=.)\.(?=[^.])(?!.*\.[^.])/m

  # We now have one or two parts (depending on whether we could find
  # a suitable period). For each of these parts, replace any unwanted
  # sequence of characters with an underscore
  fn.map! { |s| s.gsub /[^a-z0-9\-]+/i, '_' }

  # Finally, join the parts with a period and return the result
  return fn.join '.'
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
	

