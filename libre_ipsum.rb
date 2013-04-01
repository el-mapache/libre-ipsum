require 'rubygems'
require 'sinatra/base'
require 'json'
require './ext/core_ext'
require './book.rb'

class LibreIpsum < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :static, true
  set :public_folder, "public"
  set :views, File.dirname(__FILE__) + "/views"
  
  # get a list of all books, in the format of title, author and id
  get "/" do
    erb :index, format: :html5, locals: {books: get_books}
  end
  
  # Retrieve a random book, 6 lines
  get "/api/v1/book", provides: :json do
    book = Book.find
    book.prepare_book_data(book.by_lines,lambda {|text| text.join("\r\n").strip.bicameralize}).to_json
  end

  get "/api/v1/books/all", provides: :json do
    get_books
  end
  
    
  # Retrieves specified or random book, with optional
  # number of lines and/or paragraphs
  get "/api/v1/books/:book_id/:lines/:paragraphs", provides: :json do
    book = params[:book_id].to_i == 0 ? Book.find : Book.find(params[:book_id])
    book.update(params)
    text = book.paragraphs ? book.by_paragraph : book.by_lines
    book.prepare_book_data(text, lambda { |text| text.join("\r\n\n")}).to_json
  end
  
  private
  def get_books
    books = []
    File.open("manifest.txt").each_line do |line|
      books << line
    end.close
    books
  end 
end
