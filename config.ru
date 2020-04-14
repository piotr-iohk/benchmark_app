require File.dirname(__FILE__) + '/app'

run Rack::URLMap.new({
  "/" => App
})
