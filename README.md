rosette-core
========

[![Build Status](https://travis-ci.org/rosette-proj/rosette-core.svg?branch=master)](https://travis-ci.org/rosette-proj/rosette-core.svg?branch=master) [![Code Climate](https://codeclimate.com/github/rosette-proj/rosette-core/badges/gpa.svg)](https://codeclimate.com/github/rosette-proj/rosette-core) [![Test Coverage](https://codeclimate.com/github/rosette-proj/rosette-core/badges/coverage.svg)](https://codeclimate.com/github/rosette-proj/rosette-core/coverage)

## Installation

`gem install rosette-core`

## Usage

```ruby
require 'rosette/core'
```

## Intro

This repository contains the core classes for the Rosette internationalizaton framework. Full documentation can be found on [rubydoc.info](http://www.rubydoc.info/github/rosette-proj/rosette-core).

Generally, this library is required by other projects like [rosette-server](https://github.com/rosette-proj/rosette-server), which means that most likely you'll make use of it indirectly. Please refer to the documentation that accompanies these other projects to set up and use Rosette.

## Major Components

What follows is a list of the major components in rosette-core. It's not meant to be an exhaustive list, but should give a decent overview of what's going on.

### Commands

Rosette commands are designed to mimic git operations. For example, use the `DiffCommand` to show the added/removed/changed phrases between two git refs. Use the `StatusCommand` to compute the status of a git ref i.e. the percent translated per locale. Commands all follow the builder pattern, meaning you create a blank instance, call setter methods for required fields, then call the `#execute` method. Here's an example for the `ShowCommand`:

```ruby
Rosette::Core::Commands::ShowCommand.new(rosette_config)
  .set_repo_name('my_awesome_repo')
  .set_ref('master')
  .execute
```

### Git Classes

Rosette manages git repos by leveraging the open-source [jGit library](https://eclipse.org/jgit), which is a full git implementation for the JVM. The `Repo` and `DiffFinder` classes wrap jGit and provide a set of methods for interacting with git repositories in a slightly more Ruby-ish way. Specifically, `Repo` offers generic methods like `#parents_of` and `#read_object_bytes`, while `DiffFinder` finds diffs between git refs. Here's an example of creating a `Repo` instance and calculating a diff:

```ruby
repo = Rosette::Core::Repo.from_path('/path/to/my_repo/.git')
repo.diff('master', 'my_branch')  # you can optionally specify a list of paths as well
```

### Resolvers

The resolvers provide a way of looking up class constants for a number of Rosette's sub-components using slash-separated strings. For example, the `ExtractorId` class will resolve the string 'xml/android' into `Rosette::Extractors::XmlExtractor::AndroidExtractor`. Resolvers exist for extractors, integrations, pre-processors, and serializers.

```ruby
Rosette::Core::ExtractorId.resolve('xml/android')
Rosette::Core::SerializerId.resolve('yaml/rails')
```

### Snapshot Classes

Snapshots are Ruby hashes of file paths to git commit ids. The idea of the snapshot is central to Rosette's git model in that Rosette uses them to know when files that contain translatable content last changed. Rather than storing phrases for every file for every commit, Rosette only stores content when files change. Rosette can use a snapshot to gather a complete list of phrases for each commit in the repository.

You probably won't have to take snapshots manually, but if you do, here's an example:

```ruby
Rosette::Core::SnapshotFactory.new
  .set_repo_config(repo_config)
  .set_start_commit_id('abc123')
  .set_paths('path/to/snapshot')  # looks at all paths in repo by default
  .take_snapshot
```

### Queue Classes

You can choose to process new commits by placing them in a queue (perhaps in combination with a github webhook or a plain 'ol git hook). The queuing logic and various queue stages all live in rosette-core. The stages are:

1. Fetch/pull the repo
2. Extract phrases for the given commit, store in datastore
3. Push phrases to TMS (translation management system) for translation
4. Finalize the TMS submission (perform any necessary clean-up)

If you're not using a queue to process new commits, you'll have to process them some other way to stay current.

### Interfaces

rosette-core contains a few base classes that serve as interfaces for implementations that live in other gems. For example, the [rosette-extractor-yaml gem](https://github.com/rosette-proj/rosette-extractor-yaml) defines the `YamlExtractor` class, which inherits from `Rosette::Core::Extractor`. Other interfaces include `Rosette::Tms::Repository`, `Rosette::Serializers::Serializer`, `Rosette::Preprocessors::Preprocessor`, and more.

## Requirements

All Rosette components only run under jRuby. Java dependencies are managed via the [expert gem](https://github.com/camertron/expert). Run `bundle exec expert install` to install Java dependencies.

## Running Tests

`bundle`, then `bundle exec expert install`, then `bundle exec rspec`.

## Authors

* Cameron C. Dutro: http://github.com/camertron
