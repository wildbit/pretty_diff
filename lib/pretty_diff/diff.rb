require 'cgi'

#
# Main class to interact with. In fact this is the only class you should interact with
# when using the library.
# 
# === Usage example:
#  pretty = PrettyDiff::Diff.new(udiff)
#  pretty.to_html
#
# Keep in mind that Diff will automatically escape all HTML tags from the intput string
# so that it doesn't interfere with the output.
#
# === Behind The Scenes:
# The Diff class is parsing input string and searching for Chunks.
# It's then asking HtmlGenerator to generate HTML for those chunks. 
#
class PrettyDiff::Diff
  CHUNK_REGEXP = /@@ .+ @@\n/

  attr_reader :input

  # Create new Diff object. Accept a String in unified diff format.
  # Will automatically escape HTML tags from it.
  def initialize(unified_diff)
    @input = escape_html(unified_diff)
  end

  # Generate HTML presentation. Return a string.
  def to_html    
    PrettyDiff::HtmlGenerator.generate_diff(chunks)
  end

private

  # Return an array of Chunk objects that Diff found in the input.
  def chunks
    @_chunks ||= find_chunks(input)
  end

  # Parse the input for diff chunks and initialize a Chunk object for each of them.
  # Return an array of Chunks.
  def find_chunks(text)
    meta_info = text.scan(CHUNK_REGEXP)
    returning(chunks = []) do
      split = text.split(CHUNK_REGEXP)
      split.shift
      split.each_with_index do |lines, idx|        
        chunks << PrettyDiff::Chunk.new(meta_info[idx], lines)
      end
    end
  end
  
  def escape_html(input_text)
    CGI.escapeHTML(input_text)
  end

end