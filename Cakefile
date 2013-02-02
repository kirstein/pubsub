{exec, spawn} = require 'child_process'

task 'assets:watch', 'Watch source files and build JS & CSS', (options) ->
  watch 'coffee', '-wc', '.'

task 'compile', 'Compile .coffee files from directory .js', (options) ->
  compile()

task 'build', 'Build pubsub js files. Builds one js file for development and one minimized', ->
  build minimize

watch = (name, args...) ->
  proc =           spawn name, args
  proc.stderr.on   'data', (buffer) -> console.log buffer.toString()
  proc.stdout.on   'data', (buffer) -> console.log buffer.toString()
  proc.on          'exit', (status) -> process.exit(1) if status

compile = (from = '.', to = '.', callback) ->
  exec "coffee -o #{from} -c #{to}", (err, stdout, stderr) ->
    throw err if err
    console.log "Compiled coffee files"
    callback?()

build = (callback) ->
  exec "coffee -c -o . ./src", (err, stdout, stderr) ->
    throw error if err
    console.log "PubSub Built"
    callback?()

minimize = ->
  pack    = require "./package.json"
  version = pack.version
  dev     = "pubsub.js"
  min     = "pubsub-#{version}.min.js"
  exec "uglifyjs #{dev} -o #{min}", (err, stdout, stderr) ->
    throw err if err
    exec "mv #{dev} pubsub-#{version}.js"
    console.log "PubSub minified"
