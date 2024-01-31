class Curriculum < Bridgetown::Component
  def initialize(curriculum:, title:, subtitle:, callout:)
    @curriculum = curriculum
    @callout = callout
    @title = title
    @subtitle = subtitle
  end
end
