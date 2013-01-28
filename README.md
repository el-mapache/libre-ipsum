libre-ipsum
===========

libre-ipsum provides you with placeholder text for your web projects and mockups from the annals of western
literature. Your clients will be shamed by your superb taste, and awed by the endless depth of your 
knowledge of esoteric literary miscellany.  

#Usage
Simply use your favorite (asyn)chronous HTTP request method to call the following URL:
    http://[:url]/api/v1/book

This will provide you with about 6 lines ( generally a single paragraph) of text from a random book.
* * *

If you'd like more fine grained control, you can issue the following request:
    http://[:url]/api/v1/books/[:book_id]/[:lines]/[:paragraphs]
    
Parameters:
* :book_id - If left blank, a random book will be fetched
* :lines - Defaults to six
* :paragraphs - Defaults to 1
* * *

For a list of all available titles, compose your request thusly:
    http://[:url]/api/v1/books/all
    
This call will provide you with a JSON object containing all our books.

Note: All requests are GET requests.
* * *

#License
MIT

copyright adam biagianti