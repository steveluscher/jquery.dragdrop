/*global module:false*/
module.exports = function(grunt) {
  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    uglify: {
      plugin: {
        files: [{
          expand: true,
          cwd: 'dist/',
          src: '*.js',
          dest: 'dist/',
          ext: '.min.js'
        }],
        options: {
          banner : '/*! <%= pkg.title || pkg.name %> - v<%= pkg.version %> - ' +
            '<%= grunt.template.today("yyyy-mm-dd") %>\n' +
            '<%= pkg.homepage ? "* " + pkg.homepage + "\\n" : "" %>' +
            '* Copyright (c) <%= grunt.template.today("yyyy") %> <%= _(pkg.authors).pluck("name").join(", ") %>;' +
            ' Licensed <%= _.pluck(pkg.licenses, "type").join(", ") %> */\n'
        }
      }
    },
    coffee: {
      plugin: {
        files: [{
          expand: true,
          cwd: 'src/',
          src: '*.coffee',
          dest: 'dist/',
          ext: '.js'
        }]
      },
      specs: {
        files: [{
          expand: true,
          cwd: 'spec/',
          src: '*.coffee',
          dest: 'spec/javascripts/',
          ext: '.js'
        }]
      },
      helpers: {
        files: [{
          expand: true,
          cwd: 'spec/helpers/',
          src: '*.coffee',
          dest: 'spec/javascripts/helpers/',
          ext: '.js'
        }]
      }
    },
    jasmine: {
      src: 'dist/*[^(min)].js',
      options: {
        '--web-security': false,
        keepRunner: true,
        helpers: 'spec/javascripts/helpers/*.js',
        specs: 'spec/javascripts/*.js',
        styles: 'spec/*.css',
        vendor: 'spec/lib/*.js'
      }
    },
    watch: {
      files: [
        'src/*.coffee',
        'spec/**/*.coffee',
        'spec/javascripts/*.css',
        'spec/javascripts/fixtures/*'
      ],
      tasks: ['coffee', 'growl:coffee', 'jasmine', 'growl:jasmine']
    },
    growl: {
      coffee: {
        title: 'CoffeeScript',
        message: 'Compiled successfully'
      },
      jasmine: {
        title: 'Jasmine',
        message: 'Specs passed successfully'
      }
    }
  });

  // Lib tasks.
  grunt.loadNpmTasks('grunt-growl');
  grunt.loadNpmTasks('grunt-contrib-jasmine');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-uglify');

  // Default and Build tasks
  mainTasks = ['coffee', 'growl:coffee', 'jasmine', 'growl:jasmine']
  grunt.registerTask('default', mainTasks);
  grunt.registerTask('build', mainTasks.concat(['uglify']));

  // Travis CI task.
  grunt.registerTask('travis', ['coffee', 'jasmine']);
};
