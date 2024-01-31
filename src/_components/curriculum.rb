class Curriculum < Bridgetown::Component
  def initialize(curriculum:, title:, subtitle:, callout:)
    @curriculum = curriculum
    @callout = callout
    @title = title
    @subtitle = subtitle
  end

  private

  def id_formatted(str, namespace: nil)
    id = str
      .downcase
      .gsub(/[^\w\s-]/, "")
      .gsub(/\s/, "-")

    if namespace
      "#{id_formatted(namespace)}-#{id}"
    else
      id
    end
  end
end
