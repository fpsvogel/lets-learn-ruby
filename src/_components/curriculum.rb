class Curriculum < Bridgetown::Component
  def initialize(curriculum:, title:, subtitle:, callout:)
    @curriculum = curriculum
    @callout = callout
    @title = title
    @subtitle = subtitle
  end

  private

  def id_formatted(section_name)
    section_name
      .downcase
      .gsub(/[^\w\s]/, "")
      .gsub(/\s/, "-")
  end
end
