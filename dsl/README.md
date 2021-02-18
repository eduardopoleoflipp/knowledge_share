# Domain specific language (DSL)

- Language built for a specific domain as opposed to a general purpose language (e.g C, ruby, python)

## Why learn and build them?
- Allows you to more naturally and easily express concepts of that domain
- They are a pretty common pattern specially in gems and packages used by other devs

Some examples:

```ruby
# rspec -> testing
describe Factorial do
  it "finds the factorial of 5" do
    calculator = Factorial.new
    expect(calculator.factorial_of(5)).to eq(120)
  end
end

# rails - routing 
Rails.application.routes.draw do
  get '/patients/:id', to: 'patients#show'
  resources :brands, only: [:index, :show] do
    resources :products, only: [:index, :show]
  end
end

# Deimos!
Deimos.configure do |_config|
  consumer do
    class_name 'Kafka::Handlers::AutoBoxDrawResponseHandler'
    topic "FlyerProcessing.AutoBoxDrawResponse#{suffix}"
    schema 'AutoBoxDrawResponse'
    key_config :plain => true
    group_id "Fadmin.#{Rails.env}.FlyerProcessing.AutoBoxDrawRequest"
    max_bytes_per_partition 32_768
    namespace 'com.flipp.fadmin'
    delivery :message
  end
end
```

## What do they all have common?
- BLOCKS!!! e.g `do end`
- Allow to easily encapsulating pieces of code (even visually they look nice ;)! )
- They allow you to execute some arbitrary pieces of code within a specific context

## Blocks
- Ruby methods are NOT first class citizens.

```ruby
def method1(a)
  a
end

# This will NOT work
def method2(method1, a, b)
  method1(a) + b
end
```

- But we do have blocks which serve a similar purpose

```ruby
[1,2,3].map do |n|
  n + 1
end
```

## Implicit blocks
- Usually paired up with the `yield` keyword

```ruby
# Implicit blocks.
def map(array)
  new_array = []

  for i in 0...array.length
    new_value = yield array[i]
    new_array << new_value 
  end

  new_array
end

a = [1,2,3]

map(a) do |e|
  2 * e
end

#=> [2,4,6]
```
## Explicit blocks
- Allows for code reuse. You use / pass that block around as you like
- Used as `block.call()`

```ruby
def map2(array, &block)
  length = array.length
  new_array = []

  for i in 0...length
    new_value = block.call(array[i])
    new_array << new_value 
  end

  new_array
end

a = [1,2,3]

map2(a) do |e|
  2 * e
end
```
- There are more subtleties to this e.g `Procs`, `lamdas`, etc but they are outside the scope for this presentation.

source: https://blog.appsignal.com/2018/09/04/ruby-magic-closures-in-ruby-blocks-procs-and-lambdas.html

## Blocks and context

- Normally, blocks have access and are executed in the context that they are defined

```ruby
def calculation
  1
end

number = 1

a = [1,2,3]

r = map2(a) do |e|
 e + calculation + number
end

r #=> [3, 4, 5]
```

## DSL and context

- We want to create a similar (much simplified version of Rails router)

```ruby
router = Router.new

router.config do
  get '/cats', to: 'cats#index'
  post '/cats', to: 'cats#create'
  patch '/cats', to: 'cats#update'

  resources :dogs
end

router.routes

[
  [ 'GET', '/cats', { action: 'index', controller: 'cats' } ],
  [ 'POST',  '/cats', { action: 'create', controller: 'cats'} ],
  [ 'PATCH',  '/cats', { action: 'update', controller: 'cats'} ],
  [ 'GET',  '/dogs', { action: 'index', controller: 'dogs'} ]
  # ... a bunch of other dog routes
]
# Getting to a rake routes print out is just a matter of iterating over this
```
Top Level requirement
- Our job is to translate the DSL into the set of routes.

Important questions
- Where should the routes be store -> probably @routes which are state of Router.new
- But wait what do all these methods do and where are the defined??
- Wouldn't my program crash?

Answers 
- All of them are defined inside the Router class as instance variables.
- So for our program to work the given block would need to be executed inside the router instance context
- But how do we do that? -> we use `instance_eval`

```ruby
class Router
  def config(&block)
    instance_eval(&block) # works cuz the block is executed inside the instance
    block.call # fails cuz the block it's executes in the main program context
  end

  def get(word)
    puts "Printing '#{word}' from inside the instance"
  end
end

Router.new.config do
  get('Hola')
end
```

This was somewhat inspired by a fellow Torontonian https://www.leighhalliday.com/creating-ruby-dsl