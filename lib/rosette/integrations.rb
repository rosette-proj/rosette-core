# encoding: UTF-8

module Rosette

  # Base classes and other scaffolding for Rosette's integrations.
  module Integrations
    autoload :Errors,           'rosette/integrations/errors'
    autoload :Integration,      'rosette/integrations/integration'
    autoload :Integratable,     'rosette/integrations/integratable'
  end

end
