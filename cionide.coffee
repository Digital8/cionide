fs = require 'fs'
{exec} = require 'child_process'

optimist = require 'optimist'
uuid = require 'node-uuid'
express = require 'express'

argv = optimist.argv

# secret = argv._[1] or uuid()

console.log 'argv', argv

app = do express

app.use express.bodyParser()
app.use app.router

# config = require 

# config = {}
# config.port ?= 6969
# config.secret ?= 'secret'

app.listen config.port, ->
  console.log "*.*:#{config.port}/#{config.secret}"

app.get '/', (req, res) ->
  
  # console.log req.body
  
  # fs.writeFile