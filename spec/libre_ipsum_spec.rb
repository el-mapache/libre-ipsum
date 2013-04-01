require 'spec_helper'

describe LibreIpsum do
  
  context "Routes" do

    it "returns the the home page on the default route" do
      get '/'
      last_response.should be_ok
    end
    
    it "gets api/v1/book" do
      get '/api/v1/book'
      puts last_response.inspect
      last_response.should be_ok
    end

    it "returns all books from api/v1/books/all" do
      get 'api/v1/books/all'
      last_response.should be_ok
    end

  end

  context Book do
    describe "#initialize" do
      it "returns a class for parsing files on new" do
        Book.new.should be_an_instance_of Book
      end
    end

    describe " #find" do
      before (:each) do
        @book = double("book", lines: 6, paragraphs: nil, book: "24.txt")
      end

      describe "functionality" do
      it "returns a book given an id" do
        book = Book.find(24)
        book.should be_an_instance_of Book
      end

      it "returns a random book without an id" do
        Book.find.should be_an_instance_of Book
      end

      it "sets book attribute to the name of the file it finds" do
        @book.book.should_not be_nil
        @book.book.class.should eq String
      end

      it "reads a book into memory as an array" do
        @book.stub(file: ["a file"])
        @book.file.class.should eq Array
      end
      end
    end

    describe "available public methods" do
      it "responds to trim!, update, by_lines, and by_paragraph" do
        book = Book.find
        public_methods = %w(trim! update by_lines by_paragraph)

        public_methods.each do |method|
          book.respond_to?(method.to_sym).should(eq(true))
        end
      end
      
      describe " #by_lines" do
        before(:all) do
          @lines = Book.find.by_lines
        end

        it "returns an array" do
          @lines.class.should eq Array
        end

        it "has a length equal to the @lines attr" do
          @lines.length.should(be_within(2).of(6))
        end
      end

      describe "#by_paragraph" do
        before (:all) do
          @book = Book.find
          @book.update({"paragraphs" => 2})
          @paragraphs = @book.by_paragraph
        end

        it "returns an array" do
          @paragraphs.class.should eq Array 
        end

        it "has a length equal to the @paragraphs attr" do
          @paragraphs.length.should eq 2
        end
      end

      describe " #update" do
        it "accepts paramters in the form of a hash"
        it "returns immediately if any key isnt't a string"
        it "does not update params it doesn't respond to"
        it "updates params for which there is a valid attr_accessor"
      end
    end
  end

  context "String extension" do
    describe String do
      it "responds to bicameralize" do
        "".respond_to?(:bicameralize).should be_true
      end
    end
  end
end
