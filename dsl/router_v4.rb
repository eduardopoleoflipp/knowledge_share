# Nested Resources

# resources :magazines do
#   resources :ads
# end

# GET /magazines/:magazine_id/ads ads#index
# GET /magazines/:magazine_id/ads/new ads#new
# POST  /magazines/:magazine_id/ads ads#create
# GET /magazines/:magazine_id/ads/:id ads#show
# GET /magazines/:magazine_id/ads/:id/edit  ads#edit
# PATCH/PUT /magazines/:magazine_id/ads/:id ads#update
# DELETE  /magazines/:magazine_id/ads/:id ads#destroy

require 'pp'

class Router
  attr_reader :routes, :current_top_level_path

  def initialize
    @routes = []
    @current_top_level_path = '/'
  end

  def config(&block)
    instance_eval(&block)
  end

  def resources(name)
    if block_given?
      previous_top_level_path = current_top_level_path
      @current_top_level_path = current_top_level_path + "#{name}/:#{singularized(name)}_id/"
      yield
      @current_top_level_path = previous_top_level_path
      resources(name)
    else
      get "#{current_top_level_path}#{name}", to: "#{name}#index"
      get "#{current_top_level_path}#{name}/new", to: "#{name}#new"
      post  "#{current_top_level_path}#{name}", to: "#{name}#create"
      get "#{current_top_level_path}#{name}/:id/edit", to: "#{name}#edit"
      patch "#{current_top_level_path}#{name}/:id", to: "#{name}#update"
      delete "#{current_top_level_path}#{name}/:id", to: "#{name}#destroy"
    end
  end

  def route(verb, path, destination)
    controller, action = destination[:to].split('#')

    routes << [verb.upcase, path, { controller: controller, action: action }]
  end

  def method_missing(m, *args, &block)
    route(m, args[0], args[1])
  end

  def singularized(name)
    # maybe you want the rails version of this.
    name[0...-1]
  end
end

router = Router.new

router.config do
  get '/cats', to: 'cats#index'
  post '/cats', to: 'cats#create'
  patch '/cats', to: 'cats#update'
  delete '/cats', to: 'cats#destroy'

  resources :dogs do
    resources :toys
  end
end

pp router.routes