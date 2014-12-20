through = require 'through2'
gutil = require 'gulp-util'

GError = gutil.PluginError
kit = {}
# Do nothing, used to turn off a transform.
kit.nothing = ->
	through.obj (file, encoding, cb)->
		@push file
		cb()

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

module.exports = kit

