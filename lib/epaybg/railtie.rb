require 'epaybg/view_helpers'

module Epaybg
  class Railtie < Rails::Railtie
    initializer 'epaybg.view_helpers' do
      ActionView::Base.send :include, Epaybg::ViewHelpers
    end

    initializer 'epaybg.configure' do |app|
      Epaybg.config = YAML.load_file(app.root.join('config', 'epaybg.yml'))
    end
  end
end
