class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def config(&block)
    instance_eval(&block)
  end

  def route(verb, path, destination)
    controller, action = destination[:to].split('#')

    routes << [verb.upcase, path, { controller: controller, action: action }]
  end

  def method_missing(m, *args, &block)
    route(m, args[0], args[1])
  end
end

router = Router.new

router.config do
  get '/cats', to: 'cats#index'
  post '/cats', to: 'cats#create'
  patch '/cats', to: 'cats#update'
  delete '/cats', to: 'cats#destroy'
end

pp router.routes