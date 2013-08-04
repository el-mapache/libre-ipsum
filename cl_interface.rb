#!/Users/primer/.rvm/rubies/ruby-1.9.2-p318/bin/ruby
require "./file_download.rb"
require "./book.rb"

class LibreIpsumCLI
  BLACKLIST = ["19831.txt"]
  def initialize
    @reader = GutenbergReader.new
    @book = Book.new
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
  end
  
  def update_manifest dir
    @reader.save_record(@reader.from_directory(dir))
  end
  
  def trim_book dir
    p dir
    if File.exists?(dir) && File.directory?(dir) 
      Dir.entries(dir).reject { |b| b[0] == "." }.each do |b|
        p b
        @book.book = dir+'/'+b
        @book.trim! unless BLACKLIST.include?(@book.book)
      end
    else
      puts "Sorry, that isn't a valid directory."
    end
  end
end

LibreIpsumCLI.new.run
