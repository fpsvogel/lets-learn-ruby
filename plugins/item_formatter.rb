require "nokogiri"

class ItemFormatter
  private attr_reader :item

  def initialize(item_hash)
    @item = item_hash
  end

  def format_item_for_site!
    capitalize_description_first_letter!
    ensure_description_final_period!
    transform_description_first_word_to_sentence_style!
    fetch_github_og_image! if ENV["BRIDGETOWN_ENV"] == "production"
  end

  private

  FIRST_WORD_SENTENCE_STYLE_REPLACEMENTS = {
    "Is" => "It's",
    "Which" => "It"
  }.freeze

  def capitalize_description_first_letter!
    if @item.fetch(:description)
      @item[:description][0] = @item[:description][0].upcase
    end
  end

  def ensure_description_final_period!
    if @item.fetch(:description) && @item[:description].tr("*", "")[-1] != "."
      @item[:description] = "#{@item[:description]}."
    end
  end

  def transform_description_first_word_to_sentence_style!
    if @item.fetch(:description)
      FIRST_WORD_SENTENCE_STYLE_REPLACEMENTS.each do |original, replacement|
        if @item[:description].start_with?(original)
          @item[:description].sub!(original, replacement)
          break
        end
      end
    end
  end

  # Sometimes a "too many requests" response is returned, so retry a few times.
  def fetch_github_og_image!
    if item[:image].nil? && item[:url].match?(/\Ahttps:\/\/git(hub|lab).com\//)
      og_image = nil
      tries = 0
      loop do
        repo_doc = Nokogiri::HTML(Net::HTTP.get(URI(item[:url].delete_suffix(".git"))))
        og_image = repo_doc
          .css('meta[property="og:image"]')
          .first
          .attribute_nodes
          .find { it.name == "content" }
          .value

        break if og_image || tries >= 5
        tries += 1
        sleep(1)
      end

      item[:image] = og_image
    end
  end
end
