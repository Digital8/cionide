fs = require 'fs'
child_process = require 'child_process'

optimist = require 'optimist'
uuid = require 'node-uuid'
express = require 'express'
request = require 'request'
CoffeeScript = require 'coffee-script'
prompt = require 'prompt'
_ = require 'underscore'

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
    
    app.listen config.port, ->
      console.log "*.*:#{config.port}/#{config.secret}"
    
    app.post '/', (req, res) ->
      
      push = JSON.parse req.body.payload
      
      {commits, repository} = push
      
      cwd = "#{process.cwd()}/#{repository.name}"
      
      console.log 'REQ', repository.name, 'git pull', cwd: cwd
      child_process.exec 'git pull', cwd: cwd, (error, stdout, stderr) ->
        console.log 'RES', repository.name, 'git pull', {error, stdout, stderr}
        
        npm = _.some commits, (commit) ->
          'package.json' in commit.modified
        
        if npm
          console.log 'REQ', repository.name, 'sudo cake install', cwd: cwd
          child_process.exec 'sudo cake install', cwd: cwd, (error, stdout, stderr) ->
            console.log 'RES', repository.name, 'cake install', {error, stdout, stderr}
      
    #   # fs.writeFile