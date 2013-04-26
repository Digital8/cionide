fs = require 'fs'
{exec} = require 'child_process'

optimist = require 'optimist'
uuid = require 'node-uuid'
express = require 'express'
request = require 'request'
CoffeeScript = require 'coffee-script'
prompt = require 'prompt'

argv = optimist.argv

[url] = argv._

request url, (error, response, body) ->
  
  prompt.override = optimist.argv
  
  prompt.start()
  
  console.log """
  ### <config> ###
  #{body}
  ### </config> ###
  """
  
  prompt.get ['confirm'], (error, result) ->
    
    process.exit() unless result.confirm in ['y', 'Y', 'yes', 'yes', '']
    
    config = CoffeeScript.eval body
    config.port ?= 6969
    config.secret ?= ''
    
    app = do express
    
    app.use express.bodyParser()
    app.use app.router
    
    # # config = require 
    
    # # config = {}
    # # config.port ?= 6969
    # # config.secret ?= 'secret'
    
    app.listen config.port, ->
      console.log "*.*:#{config.port}/#{config.secret}"
    
    app.get '/', (req, res) ->
      
      console.log req.body
      
    #   # fs.writeFile