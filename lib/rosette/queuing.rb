# encoding: UTF-8

module Rosette
  module Queuing

    autoload :QueueConfigurator, 'rosette/queuing/queue_configurator'
    autoload :Job,               'rosette/queuing/job'
    autoload :Queue,             'rosette/queuing/queue'
    autoload :Worker,            'rosette/queuing/worker'

    autoload :Commits,           'rosette/queuing/commits'

  end
end
