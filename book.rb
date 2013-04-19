#!/Users/primer/.rvm/rubies/ruby-1.9.2-p318/bin/ruby
require 'fileutils'
require 'tempfile'

class Book
  attr_accessor :book, :file, :paragraphs, :lines

  def initialize(lines = 6, paragraphs = nil, book = nil, file = nil)
    @lines = lines
    @paragraphs = paragraphs 
    @book
  end

  class << self
    def find(id = nil)
      book = self.new
      book.book = id.nil? ? all_books.sample : all_books.select { |b| /^#{id}.txt/ =~ b }.first
      book.file = Book.send(:open_book,book.book)
      book
    end

    def open_book(book)
      IO.readlines("books/#{book}")
    end
  end

  private_class_method :open_book
  
  # Convienience method to remove all the project gutenberg legalese, 
  # as well as other ancillary data from a book file and store a 
  # new versions of it.
  def trim!
    tmp = Tempfile.new("temp")

    File.open("books/#{@book}").each_line do |line|
      if line.match(/(THE END\.?)/) || line.match(/(Transcriber's Notes\:)/) ||
         line.match(/End of the Project Gutenberg EBook/) || 
         line.match(/^\*\*\*END OF THIS PROJECT GUTENBERG EBOOK/) || line.match(/^(INDEX)/) 
        break
      else
        tmp << line
      end
    end
    
    tmp.rewind
    FileUtils.mv(tmp.path,"books/#{@book}")
    tmp.unlink
    tmp.close
  end
  
  # Rather than a database or persistence update, this method allows for
  # the attr_writer accessible instance variables to be overwritten with new values
  def update(params)
    return false unless params.kind_of? Hash

    params.each do |key,value|
      return false unless key.instance_of? String

      if self.respond_to?(key.to_sym) and value.to_i != 0
        self.instance_variable_set(("@"+key).to_sym, value.to_i)
      end
    end
  end

  def by_lines
    current_line = get_random_lines 
    
    text = []

    while(text.count < @lines) 
      # This line is blank, increment and keep going
      if !line_acceptable?(@file[current_line]) 
        current_line = current_line + 1
      else
        # We've arrived at the last line
        if text.count == @lines - 1  
          # The line doesnt end with terminating punctuation
          if @file[current_line][-3].match(/[\,\"\:\;\'(...)]/).nil? 
            text << @file[current_line].strip << "..."
          # The line does end with terminating punctuation, strip out the white space
          else
            text << @file[current_line].strip
          end
        # This is just a regular line
        else
          text << @file[current_line].gsub(/\r/,' ') 
          current_line = current_line + 1 
        end
      end
    end
    text
  end
  
  def by_paragraph
    text = []
    counter = 0
    while(counter < @paragraphs)
      text << by_lines.join("\r\n").strip.bicameralize
      counter = counter + 1
    end
    text 
  end
  
  # @param text - An array of lines or paragraphs to be processed
  # @param process - a block that performs the processing on text
  #
  # This method scans the file in memory for the author's name and 
  # the books title, and, if they exist, places them into a hash along
  # with the processed text to be sent back to the client.

  def prepare_book_data(text,process)
    data = {}
    @file.each do |line|
      data[:title] = format_book_info(line) if line.match(/Title:/)  
      data[:author] = format_book_info(line) if line.match(/Author:/)
      break if line.match(/START OF THIS PROJECT/)
    end
    
    data[:text] = process.call(text)
    data
  end

  private

  def self.all_books
    Dir.entries("books").reject { |b| b[0] == "." }
  end
  
  # Formats title and author's name nicely
  def format_book_info(line)
    line.gsub(/\r\n/,' ').split(":")[-1].strip 
  end

  def line_acceptable?(line)
    if line.nil? || line == "" || line == "\r\n" || line.match(/\[Illustration:/)
      false
    else
      true
    end
  end
  
  # Attempts to pick lines that won't include tables of contents,
  # legalese, etc.. If the random line plus the number of expected lines
  # to return is higher than the total number of lines in the book,
  # try again.

  def get_random_lines
    line = 100 + rand(@file.count - 200)
    if line + @lines > @file.count

      until(line + @lines < @file.count)
        line = 100 + rand(@file.count - 200)
      end
    end

    line
  end
end
