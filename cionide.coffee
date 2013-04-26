fs = require 'fs'
child_process = require 'child_process'
hostname = do (require 'os').hostname

async = require 'async'
optimist = require 'optimist'
uuid = require 'node-uuid'
express = require 'express'
request = require 'request'
CoffeeScript = require 'coffee-script'
prompt = require 'prompt'
_ = require 'underscore'

argv = optimist.argv

[url] = argv._

config = null

getCWD = (key) ->
  "#{process.cwd()}/#{key}"

env = (key) ->
  cwd: (getCWD key)

task = {}

task.scripts = (key, stage, callback = ->) ->
  
  scripts = config.scripts[hostname]?[stage] or []
  async.mapSeries scripts, (script, callback) ->
    child_process.exec script, (env key), callback
  , callback

task.dependents = (key, callback = ->) ->
  
  dependents = config.graph[key]?.dependents or []
  
  async.map dependents, (dependent, callback) ->
    handleKey dependent, callback
  , callback

task.pull = (key, callback = ->) ->
  
  child_process.exec 'git pull', (env key), callback

task.install = (key, callback) ->
  
  child_process.exec 'sudo cake install', (env key), callback

handleKey = (key, callback = ->) ->
  
  console.log '<repo>', key: key
  
  async.series [
    (callback) -> task.scripts key, 'before', callback
    (callback) -> task.pull key, callback
    (callback) -> task.install key, callback
    (callback) -> task.scripts key, 'after', callback
    (callback) -> task.dependents key, callback
  ], ->
    
    console.log '</repo>'
    
    callback arguments...

handlePush = (push, callback = ->) ->
  
  console.log '<push>', owner: push.owner
  
  {commits, repository} = push
  
  key = repository.name
  
  handleKey key, (error) ->
    
    console.log '</push>', error: error
    
    callback arguments...

request url, (error, response, body) ->
  
  prompt.override = optimist.argv
  prompt.override.confirm = 'y'
  
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
    config.scripts ?= {}
    config.graph ?= {}
    
    app = do express
    
    app.use express.bodyParser()
    app.use app.router
    
    app.listen config.port, ->
      console.log "*.*:#{config.port}/#{config.secret}"
    
    app.post '/', (req, res) ->
      
      res.send 200
      
      push = JSON.parse req.body.payload
      
      handlePush push