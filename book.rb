#!/Users/primer/.rvm/rubies/ruby-1.9.2-p318/bin/ruby
require 'fileutils'
require 'tempfile'

class Book
  attr_accessor :book, :file, :paragraphs
  attr_writer :lines

  def initialize lines = 6, paragraphs = nil, book = nil, file = nil
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
    params.each do |key,value|
      if self.respond_to?(key.to_sym) and value.to_i != 0
        self.instance_variable_set(("@"+key).to_sym, value.to_i)
      end
    end
  end

  def by_lines
    current_line = 100 + rand(@file.count - 200)
    text = []

    while(text.length < @lines) 
      # This line is blank, increment and keep going
      if !line_acceptable?(@file[current_line]) 
        current_line = current_line + 1
      else
        # We've arrived at the last line
        if text.length == @lines - 1  
          # The line doesnt end with terminating punctuation
          if @file[current_line][-3].match(/[\,\"\:\.\?\!\;\'(...)]/).nil? 
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
    text = text.join("\r\n").strip
    text.slice(0,1).capitalize << text.slice(1..-1)
  end
  
  def by_paragraph
    text = []
    counter = 0
    while(counter < @paragraphs)
      text << by_lines
      counter = counter + 1
    end
    text.join("\r\n\n")
  end
  
  def prepare_book_data(text)
    data = {}
    @file.each do |f|
      data[:title] = clean_data(f) if f.match(/Title:/)  
      data[:author] = clean_data(f) if f.match(/Author:/)
      break if f.match(/START OF THIS PROJECT/)
    end

    data[:text] = text    
    data
  end

  private
  def self.all_books
    Dir.entries("books").reject { |b| b[0] == "." }
  end

  def clean_data(line)
    line.gsub(/\r\n/,' ').split(":")[-1].strip 
  end

  def line_acceptable?(line)
    if line.nil? || line == "" || line == "\r\n" || line.match(/\[Illustration:/)
      false
    else
      true
    end
  end 
end