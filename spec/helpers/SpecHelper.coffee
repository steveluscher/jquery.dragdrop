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

    if options.expectedOriginalPosition
      it 'should have an originalPposition property that represents the start position of the helper', ->
        expectedOriginalPosition = options.expectedOriginalPosition.call(this)
        actualOriginalPosition = @[options.spyName].mostRecentCall.args[options.argNumber].originalPosition
        expect(actualOriginalPosition).toEqual(expectedOriginalPosition)

    if options.expectedPosition
      it 'should have a position property that represents the position of the helper', ->
        expectedPosition = options.expectedPosition.call(this)
        actualPosition = @[options.spyName].mostRecentCall.args[options.argNumber].position
        expect(actualPosition).toEqual(expectedPosition)

    if options.expectedOffset
      it 'should have an offset property that represents the offset of the helper', ->
        expectedOffset = options.expectedOffset.call(this)
        actualOffset = @[options.spyName].mostRecentCall.args[options.argNumber].offset
        expect(actualOffset).toEqual(expectedOffset)

    if options.expectedHelper
      it 'should have a helper property that represents a reference to the drag helper’s DOM element', ->
        expectedHelper = options.expectedHelper.call(this)
        actualHelper = @[options.spyName].mostRecentCall.args[options.argNumber].helper
        expect(actualHelper).toBe(expectedHelper)

    if options.expectedDraggable
      it 'should have a draggable property that represents a reference to the draggable’s original DOM element', ->
        expectedDraggable = options.expectedDraggable.call(this)
        actualDraggable = @[options.spyName].mostRecentCall.args[options.argNumber].draggable
        expect(actualDraggable).toBe(expectedDraggable)

  @isNumber: (obj) -> (obj is +obj) or toString.call(obj) is '[object Number]'
  @isNaN: (obj) -> @isNumber(obj) and window.isNaN(obj)
  @applyDefaults: (obj, sources...) ->
    for source in sources
      continue unless source
      for prop of source
        obj[prop] = source[prop] if obj[prop] is undefined
    obj
