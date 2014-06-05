CocoView = require 'views/kinds/CocoView'
template = require 'templates/test'

module.exports = class TestView extends CocoView
  id: "test-view"
  template: template

  constructor: (options, @subpath) ->
    super(options)
    @loadJasmine()

  loadJasmine: ->
    @queue = new createjs.LoadQueue()
    @queue.on('complete', @scriptsLoaded, @)
    for f in ['jasmine', 'jasmine-html', 'boot', 'mock-ajax', 'test-app']
      @queue.loadFile({
        src: "/javascripts/#{f}.js"
        type: createjs.LoadQueue.JAVASCRIPT
      })
    
  scriptsLoaded: ->
    console.info 'All scripts are now loaded'
    @runTests()
    
  runTests: ->
    describe 'CodeCombat Client', =>
      beforeEach ->
        # TODO get some setup and teardown prepped
      
      allFiles = window.require.list()
      specFiles = (f for f in allFiles when f.indexOf('.spec') > -1)
      if @subpath
        prefix = 'test/app/'+@subpath
        specFiles = (f for f in specFiles when f.startsWith prefix)
      require f for f in specFiles # runs the tests