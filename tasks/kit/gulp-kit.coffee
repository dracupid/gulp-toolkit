through = require 'through2'
gutil = require 'gulp-util'
path = require 'path'
kit = require './kit'

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

kit.when = (condition, stream)->
	if condition then stream
	else kit.nothing()

kit.bornStream = (parent, child, children, file, encoding, cb)->
	if children.indexOf child is -1
		child.on 'data', (file)->
			if file then parent.push file
		child.on 'error', (err)->
			parent.emit 'error', err

		children.push child	
	child.write file, encoding
	cb()

kit.changeExt = (newExt)->
	if newExt[0] is '.' then newExt = newExt[1..]
	through.obj (file, encoding, cb)->
		if file.isNull() then return cb null, file
		if file.isStream() then return cb new GError 'gulp-kit-changeExt', 'Streaming not supported'

		newPath = file.path.split '.'
		newPath[newPath.length] = newExt
		file.path = newPath.join '.'

		cb null, file

kit.compile = ()->
	children = []
	through.obj (file, encoding, cb)->
		if file.isNull() then return cb null, file
		if file.isStream() then return cb new GError 'gulp-kit-compile', 'Streaming not supported'

		extname = path.extname file.name

		compiler = kit.getCompiler extname
		
		if not compiler
			return cb null, file

		opts = kit.toArray kit.opts.compile[extname]

		compileStream = kit.require(compiler).apply null, opts

		kit.bornStream @, compileStream, children, file, encoding, cb
	, (cb)->
		i = 0
		if children.length
			children.forEach (child)->
				child.on 'end', ->
					i += 1
					if i is children.length then cb()
				child.end()
		else
			cb()
module.exports = kit

