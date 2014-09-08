# encoding: UTF-8

require 'repo-fixture'

name = 'fake_app'
wd = File.dirname(__FILE__)
dir = File.expand_path("./#{name}", wd)
zipfile = File.expand_path("../bin/#{name}.zip", wd)

def copy_files(files, dir, fixture)
  fixture.copy_files(files) do |file|
    file.gsub(/\A#{Regexp.escape(dir)}/, '')
  end
end

fixture = RepoFixture.create do |fixture|
  first_commit_files = [
    'app/controllers/product_controller.txt',
    'app/models/product.txt',
    'app/views/product/edit.txt',
    'app/controllers/file.other'
  ].map { |file| File.join(dir, file) }

  copy_files(first_commit_files, dir, fixture)
  fixture.add_all
  fixture.commit('Adding product editing capabilities')

  second_commit_files = [
    'app/controllers/order_controller.txt',
    'app/models/order.txt',
    'app/models/line_item.txt',
    'app/views/order/index.txt',
    'app/models/another_file.other'
  ].map { |file| File.join(dir, file) }

  copy_files(second_commit_files, dir, fixture)
  fixture.add_all
  fixture.commit('Adding ability to order products')
end

fixture.export(zipfile)
fixture.unlink
