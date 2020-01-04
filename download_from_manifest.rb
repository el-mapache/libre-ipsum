require "./gutenberg_reader.rb"

def process_from_manifest
  reader = GutenbergReader.new
  begin
    reader.download_from_manifest
  rescue => error
    p 'Error reading from manifest'
    p error
  end
end

process_from_manifest
