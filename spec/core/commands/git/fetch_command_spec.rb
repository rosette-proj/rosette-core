# encoding: UTF-8

require 'spec_helper'

include Rosette::Core::Commands

describe FetchCommand do
  let(:source_repo) { TmpRepo.new }
  let(:dest_repo) { TmpRepo.new }
  let(:repo_name) { 'my_repo' }

  let(:configuration) do
    Rosette.build_config do |config|
      config.add_repo(repo_name) do |repo_config|
        repo_config.set_path(dest_repo.working_dir.join('.git').to_s)
      end
    end
  end

  let(:command) do
    Rosette::Core::Commands::FetchCommand.new(configuration)
  end

  context 'validation' do
    it 'requires a valid repo name' do
      expect(command).to_not be_valid
    end

    it 'should be valid if repo name is set' do
      command.set_repo_name(repo_name)
      expect(command).to be_valid
    end
  end

  context '#execute' do
    before do
      command.set_repo_name(repo_name)
    end

    it 'fetches new commits from origin' do
      source_repo.create_file('foo.txt') { |f| f.write('foo') }
      source_repo.add_all
      source_repo.commit('Initial commit')

      source_repo.create_branch('new_branch')
      source_repo.create_file('bar.txt') { |f| f.write('bar') }
      source_repo.add_all
      source_repo.commit('Second commit')
      source_repo.checkout('master')

      expect(dest_repo.git('branch -a').strip.split("\n")).to be_empty

      dest_repo.git("remote add origin #{source_repo.working_dir}")
      command.execute

      expect(dest_repo.git('branch -a').split("\n").map(&:strip)).to(
        eq(['remotes/origin/master', 'remotes/origin/new_branch'])
      )
    end
  end
end
