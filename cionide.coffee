optimist = require 'optimist'
uuid = require 'node-uuid'
express = require 'express'
moment = require 'moment'

{exec} = require 'child_process'

argv = optimist.argv

secret = argv._[1] or uuid()

app = do express

app.all "/#{secret}", (req, res) ->
  console.log 'hit'
  
  path = argv._[0]
  
  backupPath = "#{path}-backup-#{moment().format 'DD-MM-YYYY-HH-MM-SS'}"
  
  exec """cd #{path} && mkdir #{backupPath} && cp -R #{argv._[0]}/* #{backupPath} && git pull""", (error, stdout, stderr) ->
    console.log arguments...
    
    res.send status: 200

port = argv._[2] or 8888

app.listen port, ->
  console.log "Listening on localhost:#{port}/#{secret}"