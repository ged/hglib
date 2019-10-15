# -*- encoding: utf-8 -*-
# stub: hglib 0.6.0.pre.20191014174315 ruby lib

Gem::Specification.new do |s|
  s.name = "hglib".freeze
  s.version = "0.6.0.pre.20191014174315"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Michael Granger".freeze]
  s.date = "2019-10-14"
  s.description = "This is a client library for the Mercurial distributed revision control tool\nthat uses the {Command Server}[https://www.mercurial-scm.org/wiki/CommandServer] for efficiency.".freeze
  s.email = ["ged@FaerieMUD.org".freeze]
  s.files = ["History.md".freeze, "LICENSE.txt".freeze, "README.md".freeze, "lib/hglib.rb".freeze, "lib/hglib/config.rb".freeze, "lib/hglib/extension.rb".freeze, "lib/hglib/extension/gpg.rb".freeze, "lib/hglib/mixins.rb".freeze, "lib/hglib/repo.rb".freeze, "lib/hglib/repo/bookmark.rb".freeze, "lib/hglib/repo/id.rb".freeze, "lib/hglib/repo/log_entry.rb".freeze, "lib/hglib/repo/status_entry.rb".freeze, "lib/hglib/repo/tag.rb".freeze, "lib/hglib/server.rb".freeze, "lib/hglib/version_info.rb".freeze, "spec/hglib/config_spec.rb".freeze, "spec/hglib/extension/gpg_spec.rb".freeze, "spec/hglib/extension_spec.rb".freeze, "spec/hglib/mixins_spec.rb".freeze, "spec/hglib/repo/id_spec.rb".freeze, "spec/hglib/repo/log_entry_spec.rb".freeze, "spec/hglib/repo/status_entry_spec.rb".freeze, "spec/hglib/repo_spec.rb".freeze, "spec/hglib/server_spec.rb".freeze, "spec/hglib/version_info_spec.rb".freeze, "spec/hglib_spec.rb".freeze, "spec/spec_helper.rb".freeze]
  s.homepage = "https://hg.sr.ht/~ged/hglib".freeze
  s.licenses = ["BSD-3-Clause".freeze]
  s.rubygems_version = "3.0.3".freeze
  s.summary = "This is a client library for the Mercurial distributed revision control tool that uses the {Command Server}[https://www.mercurial-scm.org/wiki/CommandServer] for efficiency.".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<loggability>.freeze, ["~> 0.11"])
      s.add_development_dependency(%q<rake-deveiate>.freeze, ["~> 0.2"])
      s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.7"])
      s.add_development_dependency(%q<rdoc-generator-fivefish>.freeze, ["~> 0.4"])
    else
      s.add_dependency(%q<loggability>.freeze, ["~> 0.11"])
      s.add_dependency(%q<rake-deveiate>.freeze, ["~> 0.2"])
      s.add_dependency(%q<simplecov>.freeze, ["~> 0.7"])
      s.add_dependency(%q<rdoc-generator-fivefish>.freeze, ["~> 0.4"])
    end
  else
    s.add_dependency(%q<loggability>.freeze, ["~> 0.11"])
    s.add_dependency(%q<rake-deveiate>.freeze, ["~> 0.2"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.7"])
    s.add_dependency(%q<rdoc-generator-fivefish>.freeze, ["~> 0.4"])
  end
end
