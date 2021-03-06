fs = require 'fs'
crypto = require 'crypto'
contract = require '../models/contract'
out = require './out'
yaml = require 'js-yaml'

interval = 3000
intervalId = null
watching = false

module.exports = class Watcher
   constructor: (endpoints, filename) ->
      @endpoints = endpoints
      @filename = filename
      @parser = yaml.load

      extension = filename.replace /^.*\.([a-zA-Z0-9]+)$/, '$1'
      if extension is 'json' then @parser = JSON.parse

      shasum = crypto.createHash 'sha1'
      shasum.update fs.readFileSync @filename, 'utf8'
      @sha = shasum.digest 'hex'

      @activate()

   deactivate: ->
      watching = false
      clearInterval intervalId

   activate: ->
      return if watching

      watching = true
      out.status "Watching for changes in #{@filename}..."
      intervalId = setInterval @refresh, interval

   refresh: =>
      shasum = crypto.createHash 'sha1'
      data = fs.readFileSync @filename, 'utf8'

      shasum.update data
      sha = shasum.digest 'hex'

      if sha isnt @sha
         try
            data = @parser data
            errors = contract data
            if errors
               out.error errors
            else
               @endpoints.db = []
               @endpoints.create data, (->)
               out.notice "'#{@filename}' was changed. It has been reloaded."
         catch e
            out.warn "Couldn't parse '#{@filename}' due to syntax errors:"
            out.log e.message

      @sha = sha
