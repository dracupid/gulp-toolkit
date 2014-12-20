gulp = require 'gulp'
kit = require './kit/kit'
gkit = require './kit/gulp-kit'

gulp.task '$coffee', ->
	coffee = kit.require 'gulp-coffee'
	uglify = if kit.opts.uglify then kit.require 'gulp-uglify' else gkit.nothing