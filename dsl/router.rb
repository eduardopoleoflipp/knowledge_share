# router = Router.new.config do
#   get '/cats', to: 'cats#index'
#   post '/cats', to: 'cats#create'
#   patch '/cats', to: 'cats#update'

#   resources :dogs
# end

# router.routes

# [
#   [ 'GET', '/cats', { action: 'index', controller: 'cats' } ],
#   [ 'POST',  '/cats', { action: 'create', controller: 'cats'} ],
#   [ 'PATCH',  '/cats', { action: 'update', controller: 'cats'} ],
#   [ 'GET',  '/dogs', { action: 'index', controller: 'dogs'} ]
# ]

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def config(&block)
    instance_eval(&block)
  end

  def get(path, destination)
    controller, action = destination[:to].split('#')

    routes << ['GET', path, { controller: controller, action: action }]
  end

  def post(path, destination)
    controller, action = destination[:to].split('#')

    routes << ['POST', path, { controller: controller, action: action }]
  end

  def patch(path, destination)
    controller, action = destination[:to].split('#')

    routes << ['PATCH', path, { controller: controller, action: action }]
  end

  def put(path, destination)
    controller, action = destination[:to].split('#')

    routes << ['PUT', path, { controller: controller, action: action }]
  end

  def delete(path, destination)
    controller, action = destination[:to].split('#')

    routes << ['DELETE', path, { controller: controller, action: action }]
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

# Homework => implement resources, nested routing etc
# TODO have an idea on how to implement nested stuff
