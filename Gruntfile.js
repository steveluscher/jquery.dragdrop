/*global module:false*/
module.exports = function(grunt) {
  var getBanner = function(module) {
    return '/*! <%= pkg.title || pkg.name %> ' + module + ' - v<%= pkg.version %> - ' +
           '<%= grunt.template.today("yyyy-mm-dd") %>\n' +
           '<%= pkg.homepage ? "* " + pkg.homepage + "\\n" : "" %>' +
           '* Copyright (c) <%= grunt.template.today("yyyy") %> <%= _(pkg.authors).pluck("name").join(", ") %>;' +
           ' Licensed <%= _.pluck(pkg.licenses, "type").join(", ") %> */\n'
  };

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    uglify: {
      draggablePlugin: {
        files: { 'dist/jquery.draggable.min.js': 'dist/jquery.draggable.js' },
        options: { banner: getBanner('Draggable') }
      },
      droppablePlugin: {
        files: { 'dist/jquery.droppable.min.js': 'dist/jquery.droppable.js' },
        options: { banner: getBanner('Droppable') }
      }
    },
    coffee: {
      plugin: {
        files: {
          'dist/jquery.draggable.js': ['src/base.coffee', 'src/draggable.coffee'],
          'dist/jquery.droppable.js': ['src/base.coffee', 'src/droppable.coffee']
        }
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
