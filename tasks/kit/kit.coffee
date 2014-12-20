path = require 'path'

kit = {}

requireCache = {}

kit.require = (name)->
	if requireCache[name] then return requireCache[name]

	try
		requireCache[name] = require name 
	catch
		console.log "You should install #{name} first".red
		process.exit 1

kit.opts = do ->
	require path.join process.cwd(), 'gulpfile'
	
module.exports = kit