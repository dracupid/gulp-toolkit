through = require 'through2'
gutil = require 'gulp-util'
path = require 'path'
kit = require './kit'

tool = require './tool.json'

GError = gutil.PluginError
kit = {}
# Do nothing, used to turn off a transform.
kit.nothing = ->
	through.obj (file, encoding, cb)->
		cb null, file

# Apply any function as a transform.
kit.func = (func, thisArg = null)->
	through.obj (file, encoding, cb)->
		if file.isNull() then return cb null, file
		if file.isStream() then return cb new GError 'gulp-kit-func', 'Streaming not supported'

		content = file.contents.toString()
		try
			res = func.call thisArg, content
			file.contents = new Buffer res
			cb null, file
		catch err
			cb new GError 'gulp-kit-func', err, fileName: file.path

kit.bornStream = (parent, child, children, file, encoding, cb)->
	if children.indexOf child is -1
		child.on 'data', (file)->
			if file then parent.push file
		child.on 'error', (err)->
			parent.emit 'error', err

		children.push child	
	child.write file, encoding
	cb()

kit.compile = (opts)->
	children = []
	through.obj (file, encoding, cb)->
		if file.isNull() then return cb null, file
		if file.isStream() then return cb new GError 'gulp-kit-compile', 'Streaming not supported'

		extname = path.extname file.name

		compiler = tool.compiler[extname]
		
		if not compiler
			return cb null, file

		compile = kit.require compiler

		kit.bornStream @, compile(opts), children, file, encoding, cb
	, (cb)->
		i = 0
		if children.length
			children.forEach (child)->
				child.on 'end', ->
					i ++
					if i is children.length then cb()
				child.end()
		else
			cb()
module.exports = kit

