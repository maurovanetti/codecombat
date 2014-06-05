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
    for f in ['jasmine', 'jasmine-html', 'boot']
      @queue.loadFile({
        src: "/javascripts/#{f}.js"
        type: createjs.LoadQueue.JAVASCRIPT
      })
    
  scriptsLoaded: ->
    allFiles = window.require.list()
    specFiles = (f for f in allFiles when f.indexOf('.spec') > -1)
    subset = (f for f in specFiles when f.startsWith @subpath)
    require f for f in subset # runs the tests