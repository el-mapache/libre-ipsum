require 'rubygems'
require 'sinatra/base'
require 'json'
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
  
  get "/api/v1/books/all", provides: :json do
    get_books.to_json
  end
  
  # Retrieve a random book, 6 lines
  get "/api/v1/books", provides: :json do
    content_type :json
    book = Book.find
    book.by_lines
    book.prepare_book_data(book.by_lines).to_json
  end
  
  # Retrieves specified or random book, with optional
  # number of lines and/or paragraphs
  get "/api/v1/books/:book_id/:lines/:paragraphs", provides: :json do
    content_type :json
    book = params[:book_id].to_i == 0 ? Book.find : Book.find(params[:book_id])
    book.update(params)
    text = book.paragraphs ? book.by_paragraph : book.by_lines
    book.prepare_book_data(text).to_json
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
