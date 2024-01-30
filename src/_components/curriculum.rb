class Curriculum < Bridgetown::Component
  def initialize(curriculum:, site_intro:)
    @curriculum = curriculum
    @site_intro = site_intro
  end
end
