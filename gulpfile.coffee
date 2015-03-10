gulp = require 'gulp'
sass = require 'gulp-sass'
clean = require 'gulp-clean'
assemble = require 'assemble'
htmlmin = require 'gulp-htmlmin'
extname = require 'gulp-extname'
map = require 'map-stream'
path = require 'path'
nunjucks = require 'template-nunjucks'
fs = require 'fs'
_ = require 'lodash'
tap = require 'gulp-tap'

###*
 * basic reporter
###
handleError = (err)->
	console.log err


###*
 * Template Data
 * @type {Object}
###
data = 
	pkg: require './package.json'
	site: {}


###*
 * Configuration
 * @type {Object}
###
defaults =
	filters:
		all: '*{,*/*}'
		data: '*{,*/*}.{coffee,json,yml}'
		fonts: '*{,*/*}.{otf,ttf,eot,woff}'
		images: '*{,*/*}.{png,jpg,jpeg,gif,bmp,svg,apng}'
		styles: '*{,*/*}.{scss,css}'
		scripts: '*{,*/*}.{js,coffee,litcoffee}'
		templates: '*{,*/*}.html'

	# @TODO: remove 'src' from here (leave root alone) and its references, use path.join
	source:
		root: './src'
		data: './src/data'
		pages: './src/patterns/pages'
		fonts: './src/fonts'
		images: './src/images'
		styles: './src/styles'
		scripts: './src/scripts'
		patterns: './src/patterns'

	target:
		root: './tmp'


gulp.task 'clean', [
	'clean:scripts'
	'clean:styles'
	'clean:images'
	'clean:fonts'
	'clean:templates'
]


gulp.task 'clean:scripts', (done)->
	gulp.src path.join(defaults.target.root, defaults.filters.scripts), read: false
		.pipe clean()
		.on 'error', handleError
	done()


gulp.task 'clean:styles', (done)->
	gulp.src path.join(defaults.target.root, defaults.filters.styles), read: false
		.pipe clean()
		.on 'error', handleError
	done()

gulp.task 'clean:images', (done)->
	gulp.src path.join(defaults.target.root, defaults.filters.images), read: false
		.pipe clean()
		.on 'error', handleError
	done()

gulp.task 'clean:fonts', (done)->
	gulp.src path.join(defaults.target.root, defaults.filters.fonts), read: false
		.pipe clean()
		.on 'error', handleError
	done()

gulp.task 'clean:templates', (done)->
	gulp.src path.join(defaults.target.root, defaults.filters.templates), read: false
		.pipe clean()
		.on 'error', handleError
	done()


###*
 * @TODO: 
 *  - generate file revs
 *  - minifiy
 *  - fingerprint rev'd assets
 *  - inject rev'd data into data.site.assets
###

gulp.task 'styles', ['clean:styles'], (done)->
	gulp.src path.join(defaults.source.styles, defaults.filters.styles)
		.pipe sass()
		# .pipe autoprefix()
		# .pipe minify()
		# .pipe rev.manifest 'styles.json'
		.pipe gulp.dest defaults.target.root + '/styles'
		.on 'error', handleError
	done()

gulp.task 'images', ['clean:images'], (done)->
	gulp.src path.join(defaults.source.images, defaults.filters.images)
		# .pipe rev.manifest 'images.json'
		# .pipe imagemin()
		.pipe gulp.dest defaults.target.root + '/images'
		.on 'error', handleError
	done()

gulp.task 'fonts', ['clean:fonts'], (done)->
	gulp.src path.join(defaults.source.fonts, defaults.filters.fonts)
		# .pipe rev.manifest 'fonts.json'
		.pipe gulp.dest defaults.target.root + '/fonts'
		.on 'error', handleError
	done()

gulp.task 'scripts', ['clean:scripts'], (done)->
	gulp.src path.join(defaults.source.scripts, defaults.filters.scripts)
		# .pipe browserify()
		# .pipe minify()
		# .pipe rev.manifest 'scripts.json'
		.pipe gulp.dest defaults.target.root + '/scripts'
		.on 'error', handleError
	done()



gulp.task 'pages', ['data', 'templates']

gulp.task 'templates', ['clean:templates'], (done)->
	site = assemble.init()
	site.disable 'default engines'
	nunjucks.configure root: defaults.source.patterns
	site.engine ['*', 'hbs', 'md', 'html'], nunjucks
	site.src path.join(defaults.source.pages, defaults.filters.templates)
		.on 'data', (file)->
			console.log 'Processing %s', file.path
		.pipe site.dest defaults.target.root

gulp.task 'data', (done)->

	readFile = (filename)->
		stats = fs.lstatSync filename
		baseName = path.basename filename
		info = 
			path: filename
			label: baseName

		info.type = "file" unless not stats.isFile()

		if stats.isDirectory()
			info.children = readDir filename
			info.type = 'dir'

		return info

	readDir = (filename)->
		children = fs
			.readdirSync(filename)
			.map (child)->
				return readFile path.join(filename + '/' + child)

		return _.reject children, (elm)-> elm is null

	data.site = readDir defaults.source.pages

	done()


gulp.task 'watch', ()->
	gulp.watch path.join(defaults.source.styles, defaults.filters.styles), ['styles']
	gulp.watch path.join(defaults.source.scripts, defaults.filters.scripts), ['scripts']
	gulp.watch path.join(defaults.source.patterns, defaults.filters.templates), ['templates']
	gulp.watch path.join(defaults.source.pages, defaults.filters.templates), ['pages']


gulp.task 'compile', ['clean', 'styles', 'scripts', 'images', 'fonts', 'pages']


gulp.task 'default', ['compile', 'watch']
