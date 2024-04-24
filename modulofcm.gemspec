# frozen_string_literal: true

require_relative 'lib/modulofcm/version'

Gem::Specification.new do |spec|
  spec.name = 'modulofcm'
  spec.version = Modulofcm::VERSION
  spec.authors = ['Matthieu Ciappara']
  spec.email = ['ciappa_m@modulotech.fr']

  spec.summary = 'Firebase Cloud Messaging client library'
  spec.description = 'Firebase Cloud Messaging client library'
  spec.homepage = 'https://github.com/moduloTech/modulofcm'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = 'https://github.com/moduloTech/modulofcm/blob/master/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.require_paths = ['lib']
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.add_dependency 'activesupport', '< 8.0'
  spec.add_dependency 'fcm', '~> 1.0', '>= 1.0.8'
end
