require "net/http"

class Builders::LoadCurriculum < SiteBuilder
  def build
    hook :site, :post_read do |site|
      generator do
        site.data.curriculum =
          CurriculumParser
            .new(local_file_contents || github_file_contents)
            .parse
      end
    end
  end

  private

  # The contents of the local copy of github.com/fpsvogel/learn-ruby/README.md
  # @return [String]
  def local_file_contents
    readme_path = File.join(config.learn_ruby_repo.local_path, "README.md")
    File.read(readme_path)
  rescue Errno::ENOENT
    nil
  end

  # The contents of github.com/fpsvogel/learn-ruby/README.md
  # @return [String]
  def github_file_contents
    Net::HTTP
      .get(URI(config.learn_ruby_repo.github_url))
      .force_encoding("UTF-8")
  end
end
