module.exports = (grunt) ->

   grunt.loadNpmTasks 'grunt-contrib-coffee'
   grunt.loadNpmTasks 'grunt-contrib-watch'
   grunt.loadNpmTasks 'grunt-mocha-cli'

   grunt.initConfig
      pkg: grunt.file.readJSON 'package.json'

      mochacli:
         options:
            compilers: ['coffee:coffee-script/register']
            timeout: 5000
            ignoreLeaks: false
            ui: 'bdd'
            reporter: 'dot'
         all: 'spec/**/*.coffee'

      coffee:
         src:
            expand: true
            cwd: 'src'
            src: ['**/*.coffee']
            dest: 'lib'
            ext: '.js'

         websrc:
            expand: true
            cwd: 'websrc'
            src: ['**/*.coffee']
            dest: 'webroot'
            ext: '.js'

      watch:
         src:
            files: 'src/**/*.coffee'
            tasks: 'coffee:src'
         websrc:
            files: 'websrc/**/*.coffee'
            tasks: 'coffee:websrc'

   grunt.registerTask 'default', ['compile', 'test']
   grunt.registerTask 'test', ['mochacli']
   grunt.registerTask 'compile', ['coffee']
