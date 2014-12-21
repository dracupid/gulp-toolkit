path = require 'path'

kit = {}

requireCache = {}

tool = require './tool.json'

kit.require = (name)->
	if requireCache[name] then return requireCache[name]

	try
		requireCache[name] = require name 
	catch
		console.log "You should install #{name} first".red
		process.exit 1

kit.opts = do ->
	require path.join process.cwd(), 'gulp'

kit.toArray = (item)->
	Array::concat.call [], item

kit.getCompiler = (extname)->
	if extname[0] isnt '.' then extname = '.' + extname
	
	compiler = (kit.opts.compiler and kit.opts.compiler[extname]) or tool.compiler[extname]
	if compiler
		kit.require compiler
	else null


kit.getCompressor = (extname)->
	if extname[0] isnt '.' then extname = '.' + extname
	compressor = (kit.opts.compressor and kit.opts.compressor[extname]) or tool.compressor[extname]

	if compressor
		kit.require compressor
	else null



module.exports = kit