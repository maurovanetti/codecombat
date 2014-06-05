CocoView = require 'views/kinds/CocoView'
template = require 'templates/test'

TEST_BASE_PATH = 'test/app/'

module.exports = class TestView extends CocoView
  id: "test-view"
  template: template
  
  # INITIALIZE

  constructor: (options, @subPath='') ->
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
    @initSpecFiles()
    @render()
    @runTests()
    
  # RENDER DATA
    
  getRenderData: ->
    c = super(arguments...)
    c.parentFolders = @getParentFolders()
    c.children = @getChildren()
    parts = @subPath.split('/')
    c.currentFolder = parts[parts.length-1] or parts[parts.length-2] or 'All'
    c

  getParentFolders: ->
    return [] unless @subPath
    paths = []
    parts = @subPath.split('/')
    while parts.length
      parts.pop()
      paths.unshift {
        name: parts[parts.length-1] or 'All'
        url: '/test/' + parts.join('/')
      }
    paths
    
  getChildren: ->
    return [] unless @specFiles
    folders = {}
    files = {}
    prefix = TEST_BASE_PATH + @subPath
    if prefix[prefix.length-1] isnt '/'
      prefix += '/'
    for f in @specFiles
      f = f[prefix.length..]
      continue unless f
      parts = f.split('/')
      name = parts[0]
      group = if parts.length is 1 then files else folders
      group[name] ?= 0
      group[name] += 1

    children = []
    for name in _.keys(folders)
      children.push { 
        type:'folder',
        url:"/test#{@subPath}/#{name}"
        name: name+'/'
        size: folders[name]
      }
    for name in _.keys(files)
      children.push {
        type:'file',
        url:"/test/#{@subPath}/#{name}"
        name: name
      }
    children
    
  # RUNNING TESTS
    
  initSpecFiles: ->
    allFiles = window.require.list()
    @specFiles = (f for f in allFiles when f.indexOf('.spec') > -1)
    if @subPath
      prefix = TEST_BASE_PATH + @subPath
      @specFiles = (f for f in @specFiles when f.startsWith prefix)

  runTests: ->
    describe 'CodeCombat Client', =>
      beforeEach ->
        # TODO get some setup and teardown prepped
      require f for f in @specFiles # runs the tests