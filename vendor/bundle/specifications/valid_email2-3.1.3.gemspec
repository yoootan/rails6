# -*- encoding: utf-8 -*-
# stub: valid_email2 3.1.3 ruby lib

Gem::Specification.new do |s|
  s.name = "valid_email2".freeze
  s.version = "3.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Micke Lisinge".freeze]
  s.date = "2019-12-03"
  s.description = "ActiveModel validation for email. Including MX lookup and disposable email blacklist".freeze
  s.email = ["hi@micke.me".freeze]
  s.homepage = "https://github.com/micke/valid_email2".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3".freeze)
  s.rubygems_version = "3.1.2".freeze
  s.summary = "ActiveModel validation for email. Including MX lookup and disposable email blacklist".freeze

  s.installed_by_version = "3.1.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<bundler>.freeze, ["~> 2.0"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 11.3.0"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.5.0"])
    s.add_runtime_dependency(%q<mail>.freeze, ["~> 2.5"])
    s.add_runtime_dependency(%q<activemodel>.freeze, [">= 3.2"])
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 2.0"])
    s.add_dependency(%q<rake>.freeze, ["~> 11.3.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.5.0"])
    s.add_dependency(%q<mail>.freeze, ["~> 2.5"])
    s.add_dependency(%q<activemodel>.freeze, [">= 3.2"])
  end
end
