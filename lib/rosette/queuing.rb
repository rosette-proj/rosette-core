# encoding: UTF-8

module Rosette
  module Queuing

    autoload :Queue,   'rosette/queuing/queue'
    autoload :Job,     'rosette/queuing/job'
    autoload :Worker,  'rosette/queuing/worker'

    autoload :Commits, 'rosette/queuing/commits'

  end
end
