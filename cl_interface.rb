require "./gutenberg_reader.rb"
require "./book.rb"

class LibreIpsumCLI
  BLACKLIST = ["19831.txt"]

  def initialize
    @reader = GutenbergReader.new
  end

  def run
    puts "LibreIpsum CLI"
    command = ''
    pwd = `pwd`.gsub("\n","/")
    while command != "quit"
      printf "enter command: "
      input = gets.chomp
      parts = input.split
      command = parts[0]
      case command
        when 'quit' then return puts "Exiting....Goodbye!"
        when 'update' then update_manifest(pwd + parts[1])
        when 'process-feed' then process_from_feed
        when 'trim' then trim_book(pwd + parts[1])
        else
          puts "Sorry, I dont know how to #{command}."
      end
    end
  end

  private
  def process_from_feed
    @reader.get_latest_rss
    @reader.get_book_info
    @reader.process_books
    
    trim_books(__dir__ + '/books')
  end

  def update_manifest(dir)
    @reader.save_record(@reader.from_directory(dir))
  end

  def trim_books(dir) 
    if File.exists?(dir) && File.directory?(dir)
      Dir.entries(dir).reject { |b| b[0] == "." }.each do |b|
        book = Book.new
        book.book = dir+'/'+b

        begin
          book.trim! unless BLACKLIST.include?(book.book)
        rescue
          puts "Error trimming or reading book"
          p b
        end
      end
    else
      puts "Sorry, that isn't a valid directory."
    end
  end
end

LibreIpsumCLI.new.run
