class this.SpecHelper
  @findCenterOf: (element) ->
    $document = $(document)
    offset = element.offset()
    return {
      x: Math.floor(offset.left + element.outerWidth() / 2 - $document.scrollLeft())
      y: Math.floor(offset.top + element.outerHeight() / 2 - $document.scrollTop())
    }

  @mouseDownInCenterOf: (element, options = {}) ->
    center = @findCenterOf element
    element.simulate 'mousedown', @applyDefaults options,
      clientX: center.x
      clientY: center.y
    center

  @metadataSpecs: (options = {}) ->
    options = SpecHelper.applyDefaults options,
      spyName: 'callback'
      argNumber: 1

    it 'should be an object', ->
      expect(@[options.spyName].mostRecentCall.args[options.argNumber]).toEqual(jasmine.any(Object))

    if options.expectedPosition
      it 'should have a position property that represents the position of the helper', ->
        expectedPosition = options.expectedPosition.call(this)
        actualPosition = @[options.spyName].mostRecentCall.args[options.argNumber].position
        expect(actualPosition).toEqual(expectedPosition)

  @isNumber: (obj) -> (obj is +obj) or toString.call(obj) is '[object Number]'
  @isNaN: (obj) -> @isNumber(obj) and window.isNaN(obj)
  @applyDefaults: (obj, sources...) ->
    for source in sources
      continue unless source
      for prop of source
        obj[prop] = source[prop] if obj[prop] is undefined
    obj
