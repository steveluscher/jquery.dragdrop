#
# Name    : <plugin name>
# Author  : <your name>, <your website url>, <twitter handle>
# Version : <version number>
# Repo    : <repo url>
# Website : <website url>
#


jQuery ->
  # Utility functions
  isNumber = (obj) -> (obj is +obj) or toString.call(obj) is '[object Number]'
  isNaN = (obj) -> isNumber(obj) and window.isNaN(obj)
  applyDefaults = (obj, sources...) ->
    for source in sources
      continue unless source
      for prop of source
        obj[prop] = source[prop] if obj[prop] is undefined
    obj

  $.draggable = class
    defaults:
      # Applied when the draggable is initialized
      draggableClass: 'ui-draggable'

      # Applied when a draggable is in mid-drag
      draggingClass: 'ui-draggable-dragging'

    # Memoize the config
    getConfig: -> @config ||= applyDefaults @options, @defaults

    constructor: (element, @options = {}) ->
      # jQuery version of DOM element attached to the plugin
      @$element = $ element

      # Storage for the start position of the draggable upon mousedown
      @elementStartPosition = {}
      @elementStartOffset = {}

      @$element
        # Attach mouse event handlers
        .on
          mousedown: @handleMouseDown
          mouseup: @handleMouseUp

        # Mark this element as draggable with a class
        .addClass(@getConfig().draggableClass)

      # make the plugin chainable
      this

    handleMouseDown: (e) =>
      # Store the start position of the draggable
      for edge in ['top', 'left']
        @elementStartPosition[edge] = parseInt(@$element.css edge)
        @elementStartPosition[edge] = 0 if isNaN(@elementStartPosition[edge])

      # Store the start offset of the draggable, with respect to the document
      @elementStartOffset = @$element.offset()

      # Store the mousedown event that started this drag
      @mousedownEvent = e

      # Start to listen for mousemove events
      $(document).on
        mousemove: @handleMouseMove

      # Capture the mouse event
      false

    handleMouseUp: (e) =>
      # Stop listening for mousemove events
      $(document).off
        mousemove: @handleMouseMove

      # Remove the dragging class
      @$element.removeClass @getConfig().draggingClass

      # Clean up
      @dragStarted = false
      @elementStartPosition = {}
      @elementStartOffset = {}
      delete @mousedownEvent

    handleMouseMove: (e) =>
      # Mark the drag as having started
      @handleDragStart() unless @dragStarted

      # How far has the mouse moved from its original position
      delta =
        x: e.pageX - @mousedownEvent.pageX
        y: e.pageY - @mousedownEvent.pageY

      # Move the element
      @$element.css
        left: parseInt(@elementStartPosition.left) + delta.x
        top: parseInt(@elementStartPosition.top) + delta.y

    handleDragStart: ->

      @$element
        # Apply the dragging class
        .addClass(@getConfig().draggingClass)

        # Position the draggable relative
        .css(position: 'relative')

      # Mark the drag as having started
      @dragStarted = true

  $.fn.draggable = (options) ->
    this.each ->
      unless $(this).data('draggable')?
        plugin = new $.draggable(this, options)
        $(this).data('draggable', plugin)
