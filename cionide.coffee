optimist = require 'optimist'
uuid = require 'node-uuid'
express = require 'express'

{exec} = require 'child_process'

argv = optimist.argv

secret = do uuid

app = do express

app.all "/#{secret}", (req, res) ->
  console.log 'hit'
  
  path = argv._[0]
  
  backupPath = "#{path}-backup-#{moment().format 'DD-MM-YYYY-HH-MM-SS'}"
  
  exec """cd #{path} && mkdir #{backupPath} && cp -R #{argv._[0]}/* #{backupPath} && git pull""", (error, stdout, stderr) ->
    console.log arguments...
    
    res.send status: 200

port = 8888

app.listen port, ->
  console.log "Listening on localhost:#{port}/#{secret}"