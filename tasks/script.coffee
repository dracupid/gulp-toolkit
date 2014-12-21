gulp = require 'gulp'
kit = require './kit/kit'
gkit = require './kit/gulp-kit'
tool = require './kit/tool.json'

gulp.task '$script', ->
	sopt = kit.opts.script
	min = kit.getCompressor '.js' or kit.nothing
	minExt = if sopt.onlyMined then '.js' else '.min.js'

	gulp.src sopt.from
	.pipe gkit.compile()  # todo: it doesn't work
	.pipe gkit.when (not sopt.onlyMined), gulp.dest(sopt.to)
	.pipe gkit.when sopt.min, min(sopt.min)
	.pipe gkit.changeExt minExt
	.pipe gulp.dest sopt.to
