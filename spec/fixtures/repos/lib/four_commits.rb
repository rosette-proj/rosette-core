# encoding: UTF-8

require 'repo-fixture'

name = 'four_commits'
wd = File.dirname(__FILE__)
dir = File.expand_path("./#{name}", wd)
zipfile = File.expand_path("../bin/#{name}.zip", wd)

def copy_files(files, dir, fixture)
  fixture.copy_files(files) do |file|
    file.gsub(/\A#{Regexp.escape(dir)}/, '')
  end
end

fixture = RepoFixture.create do |fixture|
  copy_files([File.join(dir, 'file1.txt')], dir, fixture)
  fixture.add_all
  fixture.commit('Committing first file')

  copy_files([File.join(dir, 'file2.txt')], dir, fixture)
  fixture.add_all
  fixture.commit('Committing second file')

  copy_files([File.join(dir, 'file3.txt')], dir, fixture)
  fixture.add_all
  fixture.commit('Committing third file')

  copy_files([File.join(dir, 'file4.txt')], dir, fixture)
  fixture.add_all
  fixture.commit('Committing fourth file')
end

fixture.export(zipfile)
fixture.unlink
