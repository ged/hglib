#!/usr/bin/env rake

begin
	require 'hoe'
rescue LoadError
	abort "This Rakefile requires hoe (gem install hoe)"
end

GEMSPEC = 'hglib.gemspec'


Hoe.plugin :mercurial
Hoe.plugin :signing
Hoe.plugin :deveiate

Hoe.plugins.delete :rubyforge

hoespec = Hoe.spec 'hglib' do |spec|
	spec.readme_file = 'README.md'
	spec.history_file = 'History.md'

	spec.extra_rdoc_files = FileList[ '*.rdoc', '*.md' ]
	spec.license 'BSD-3-Clause'

	spec.urls = {
		home:   'http://deveiate.org/projects/hglib',
		code:   'http://bitbucket.org/ged/hglib',
		docs:   'http://deveiate.org/code/hglib',
		github: 'http://github.com/ged/hglib',
	}

	spec.developer 'Michael Granger', 'ged@FaerieMUD.org'

	spec.dependency 'loggability', '~> 0.11'

	spec.dependency 'hoe-deveiate',            '~> 0.10', :developer
	spec.dependency 'simplecov',               '~> 0.7', :developer
	spec.dependency 'rdoc-generator-sixfish',  '~> 0', :developer
	spec.dependency 'rdoc',                    '~> 6.0', :developer

	spec.require_ruby_version( '>=2.5.0' )
	spec.hg_sign_tags = true if spec.respond_to?( :hg_sign_tags= )
	spec.check_history_on_release = true if spec.respond_to?( :check_history_on_release= )

	self.rdoc_locations << "deveiate:/usr/local/www/public/code/#{remote_rdoc_dir}"
end


ENV['VERSION'] ||= hoespec.spec.version.to_s

# Run the tests before checking in
task 'hg:precheckin' => [ :check_history, :check_manifest, :gemspec, :spec ]

task :test => :spec

# Rebuild the ChangeLog immediately before release
task :prerelease => 'ChangeLog'
CLOBBER.include( 'ChangeLog' )

desc "Build a coverage report"
task :coverage do
	ENV["COVERAGE"] = 'yes'
	Rake::Task[:spec].invoke
end
CLOBBER.include( 'coverage' )


# Use the fivefish formatter for docs generated from development checkout
if File.directory?( '.hg' )
	require 'rdoc/task'

	Rake::Task[ 'docs' ].clear
	RDoc::Task.new( 'docs' ) do |rdoc|
	    rdoc.main = "README.rdoc"
		rdoc.markup = 'markdown'
	    rdoc.rdoc_files.include( "*.rdoc", "ChangeLog", "lib/**/*.rb" )
	    rdoc.generator = :sixfish
		rdoc.title = 'hglib'
	    rdoc.rdoc_dir = 'doc'
	end
end

task :gemspec => GEMSPEC
file GEMSPEC => __FILE__
task GEMSPEC do |task|
	Rake.application.trace "Rebuilding gemspec."
	spec = $hoespec.spec
	spec.files.delete( '.gemtest' )
	spec.signing_key = nil
	spec.cert_chain = ['certs/ged.pem']
	spec.version = "#{spec.version.bump}.pre#{Time.now.strftime("%Y%m%d%H%M%S")}"
	File.open( task.name, 'w' ) do |fh|
		fh.write( spec.to_ruby )
	end
end
CLOBBER.include( GEMSPEC.to_s )

task :default => :gemspec

