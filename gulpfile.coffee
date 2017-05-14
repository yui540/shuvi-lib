gulp    = require 'gulp'
uglify  = require 'gulp-uglify'
coffee  = require 'gulp-coffee'
plumber = require 'gulp-plumber'

gulp.task 'default', ->
	gulp.src 'src/*.coffee'
		.pipe plumber()
		.pipe coffee { bare: true }
		.pipe uglify()
		.pipe gulp.dest 'lib'

gulp.task 'watch', ->
	gulp.watch ['src/*.coffee'], ['default']