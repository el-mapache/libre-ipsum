#TODO Needs to be abstracted and cleaned up
require "open-uri"
require "nokogiri"
require "json"
require "./book.rb"

class GutenbergReader
  attr_accessor :books, :rss_file
  attr_reader :existing_books

  def initialize
    @existing_books = Dir.entries("books").reject { |b| b[0] == "." }
    @books = []
    @rss_link = "http://www.gutenberg.org/feeds/today.rss"
    @epub_link = "http://gutenberg.readingroo.ms/"
  end
  
  def download_from_manifest
    manifest = File.open("manifest.txt", 'a+')
    book_records = manifest.each_line.map { |line| line }
    
    book_records.each do |record|
      book = JSON.parse(record)
      book_id = book['id']
      filename = "#{book_id}.txt"

      next if @existing_books.find { |b| /^#{filename}"/ =~ b }

      link = build_link(@epub_link, id_to_fragment(book_id), book_id, filename)

      download("books/"+filename, "w+", link)
    end

    manifest.close
  end

  # Latest rss feed of new books
  def get_latest_rss
    @rss_file = download("gutenberg.rss",'w+', @rss_link)
  end
  
  def get_book_info
    items = Nokogiri::XML.parse(File.open(@rss_file, "r" )).css("item")
    
    @books = items.map do |item|
      { id: item.css("link").children.text.split("/")[-1] }
    end
  end
  
  def from_directory(dir)
    files = Dir.open(dir).reject { |b| b[0] == "." }
    books = files.map do |file|
      { id: file.split('.')[0] }
    end
  end

  def process_books
    downloaded = @books.map do |book|
      book_id = book[:id]
      filename = "#{book_id}.txt"
      next if @existing_books.find { |b| /^#{book_id}.txt"/ =~ b }
      link = build_link(@epub_link, id_to_fragment(book_id), book_id, filename)
      book if download("books/"+filename, "w+", link) != false
    end

    save_record(downloaded.compact) 
  end
  
  # This loop appears to be looping over each book many more times than it should
  def save_record(books)
    manifest = File.open("manifest.txt", 'a+')
    existing_books = manifest.each_line.map { |line| line }

    books.each do |book|
      File.open("books/#{book[:id]}" + ".txt", 'r').each do |f|
        book[:link] = "http://www.gutenberg.org/ebooks/#{book[:id]}"
        book[:title] = clean_data(f) if f.match(/Title:/)  
        book[:author] = clean_data(f) if f.match(/Author:/)
        break if f.match(/START OF THIS PROJECT/)
      end

      manifest.write(book.to_json + "\n") unless existing_books.include?(book.to_json + "\n")
    end
    manifest.close
  end

  private 

  def download(filename, mode, remote_resource)
    p 'Starting download...'
    begin
      URI.parse(remote_resource).open do |resource|
        p 'Resource found!'
        book_2_txt_file(filename, mode, resource)
      end
    rescue Exception => e
      puts 'Error getting resource:'
      puts e
      return false
    end
    filename
  end
  
  def book_2_txt_file(filename, mode, resource)
    file = File.open(filename, mode)

    p 'Writing book to text file'

    resource.each_line do |line|
      file.write(line)
    end

    p 'Writing finished, closing'

    file.close
  end

  def build_link(*args)
    args.join('/')
  end
  
  def id_to_fragment(book_id)
    book_id.split('')[0...-1].join("/")
  end
  
  def clean_data(line)
    line.gsub(/\r\n/,' ').split(":")[-1].strip 
  end
end
