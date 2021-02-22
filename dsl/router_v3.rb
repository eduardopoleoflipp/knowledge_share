# Resources

# GET /photos photos#index  display a list of all photos
# GET /photos/new photos#new  return an HTML form for creating a new photo
# POST  /photos photos#create create a new photo
# GET /photos/:id photos#show display a specific photo
# GET /photos/:id/edit  photos#edit return an HTML form for editing a photo
# PATCH/PUT /photos/:id photos#update update a specific photo
# DELETE  /photos/:id photos#destroy
require 'pp'

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def config(&block)
    instance_eval(&block)
  end

  def resources(name)
    plural = pluralize(name)

    get "/#{plural}", to: "#{plural}#index"
    get "/#{plural}/new", to: "#{plural}#new"
    post  "/#{plural}", to: "#{plural}#create"
    get "/#{plural}/:id/edit", to: "#{plural}#edit"
    patch "/#{plural}/:id", to: "#{plural}#update"
    delete "/#{plural}/:id", to: "#{plural}#destroy"
  end

  def route(verb, path, destination)
    controller, action = destination[:to].split('#')

    routes << [verb.upcase, path, { controller: controller, action: action }]
  end

  def method_missing(m, *args, &block)
    route(m, args[0], args[1])
  end

  def pluralize(name)
    # maybe you want something more sophisticated here
    "#{name}s"
  end
end

router = Router.new

router.config do
  get '/cats', to: 'cats#index'
  post '/cats', to: 'cats#create'
  patch '/cats', to: 'cats#update'
  delete '/cats', to: 'cats#destroy'

  resources :dogs
end

pp router.routes