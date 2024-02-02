class ItemFormatter
  private attr_reader :item

  def initialize(item_hash)
    @item = item_hash
  end

  def format_item_for_site!
    capitalize_description_first_letter!
    ensure_description_final_period!
    transform_description_first_word_to_sentence_style!
  end

  private

  FIRST_WORD_SENTENCE_STYLE_REPLACEMENTS = {
    "Is" => "It's",
    "Which" => "It",
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
end
