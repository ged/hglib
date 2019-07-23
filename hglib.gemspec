# -*- encoding: utf-8 -*-
# stub: hglib 0.3.pre20190723103004 ruby lib

Gem::Specification.new do |s|
  s.name = "hglib".freeze
  s.version = "0.3.pre20190723103004"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Michael Granger".freeze]
  s.cert_chain = ["certs/ged.pem".freeze]
  s.date = "2019-07-23"
  s.description = "This is a client library for the Mercurial distributed revision control tool\nthat uses the [Command Server][cmdserver] for efficiency.".freeze
  s.email = ["ged@FaerieMUD.org".freeze]
  s.extra_rdoc_files = ["History.md".freeze, "LICENSE.txt".freeze, "Manifest.txt".freeze, "README.md".freeze, "History.md".freeze, "README.md".freeze]
  s.files = [".simplecov".freeze, "ChangeLog".freeze, "History.md".freeze, "LICENSE.txt".freeze, "Manifest.txt".freeze, "README.md".freeze, "Rakefile".freeze, "examples/clone.rb".freeze, "integration/commands/clone_spec.rb".freeze, "integration/spec_helper.rb".freeze, "lib/hglib.rb".freeze, "lib/hglib/config.rb".freeze, "lib/hglib/mixins.rb".freeze, "lib/hglib/repo.rb".freeze, "lib/hglib/repo/bookmark.rb".freeze, "lib/hglib/repo/id.rb".freeze, "lib/hglib/repo/log_entry.rb".freeze, "lib/hglib/repo/tag.rb".freeze, "lib/hglib/server.rb".freeze, "spec/.status".freeze, "spec/hglib/config_spec.rb".freeze, "spec/hglib/mixins_spec.rb".freeze, "spec/hglib/repo/id_spec.rb".freeze, "spec/hglib/repo/log_entry_spec.rb".freeze, "spec/hglib/repo_spec.rb".freeze, "spec/hglib/server_spec.rb".freeze, "spec/hglib_spec.rb".freeze, "spec/spec_helper.rb".freeze]
  s.homepage = "http://deveiate.org/projects/hglib".freeze
  s.licenses = ["BSD-3-Clause".freeze]
  s.rdoc_options = ["--main".freeze, "README.md".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.5.0".freeze)
  s.rubygems_version = "3.0.3".freeze
  s.summary = "This is a client library for the Mercurial distributed revision control tool that uses the [Command Server][cmdserver] for efficiency.".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<loggability>.freeze, ["~> 0.11"])
      s.add_development_dependency(%q<hoe-mercurial>.freeze, ["~> 1.4"])
      s.add_development_dependency(%q<hoe-deveiate>.freeze, ["~> 0.10"])
      s.add_development_dependency(%q<hoe-highline>.freeze, ["~> 0.2"])
      s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.7"])
      s.add_development_dependency(%q<rdoc-generator-sixfish>.freeze, ["~> 0"])
      s.add_development_dependency(%q<rdoc>.freeze, ["~> 6.0"])
      s.add_development_dependency(%q<hoe>.freeze, ["~> 3.18"])
    else
      s.add_dependency(%q<loggability>.freeze, ["~> 0.11"])
      s.add_dependency(%q<hoe-mercurial>.freeze, ["~> 1.4"])
      s.add_dependency(%q<hoe-deveiate>.freeze, ["~> 0.10"])
      s.add_dependency(%q<hoe-highline>.freeze, ["~> 0.2"])
      s.add_dependency(%q<simplecov>.freeze, ["~> 0.7"])
      s.add_dependency(%q<rdoc-generator-sixfish>.freeze, ["~> 0"])
      s.add_dependency(%q<rdoc>.freeze, ["~> 6.0"])
      s.add_dependency(%q<hoe>.freeze, ["~> 3.18"])
    end
  else
    s.add_dependency(%q<loggability>.freeze, ["~> 0.11"])
    s.add_dependency(%q<hoe-mercurial>.freeze, ["~> 1.4"])
    s.add_dependency(%q<hoe-deveiate>.freeze, ["~> 0.10"])
    s.add_dependency(%q<hoe-highline>.freeze, ["~> 0.2"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.7"])
    s.add_dependency(%q<rdoc-generator-sixfish>.freeze, ["~> 0"])
    s.add_dependency(%q<rdoc>.freeze, ["~> 6.0"])
    s.add_dependency(%q<hoe>.freeze, ["~> 3.18"])
  end
end
