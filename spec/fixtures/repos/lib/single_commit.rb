# encoding: UTF-8

require 'repo-fixture'

name = 'single_commit'
wd = File.dirname(__FILE__)
dir = File.expand_path("./#{name}", wd)
zipfile = File.expand_path("../bin/#{name}.zip", wd)

fixture = RepoFixture.create do |fixture|
  files = Dir.glob(File.join(dir, '**/**')).select do |file|
    File.file?(file)
  end

  fixture.copy_files(files) do |file|
    file.gsub(/\A#{Regexp.escape(dir)}/, '')
  end

  fixture.add_all
  fixture.commit('Committing all files')
end

fixture.export(zipfile)
fixture.unlink
