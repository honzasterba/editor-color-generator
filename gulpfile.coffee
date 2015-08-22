gulp = require 'gulp'
gutil = require 'gulp-util'
coffee = require 'gulp-coffee'
path = require 'path'
del = require 'del'

# start this before publish
gulp.task 'build', [
  'coffee'
  'demo',
  'libs'
]

# deletes the whole content of build directory
gulp.task 'clean', (callback) ->
  del './build/', callback

gulp.task 'coffee', ->
  gulp.src './src/**/*.coffee'
    # compile Coffee
    .pipe coffee {bare: true}
    .pipe gulp.dest './build/'
  gulp.src './demo/**/*.coffee'
    # compile Coffee
    .pipe coffee {bare: true}
    .pipe gulp.dest './build/'


gulp.task 'demo', ->
  gulp.src './demo/**/*.+(css|html)'
    .pipe gulp.dest './build/'

gulp.task 'libs', ->
  gulp.src './node_modules/onecolor/one-color-all-debug.js'
  .pipe gulp.dest './build/'


gulp.task 'default', [
  'build'
]
