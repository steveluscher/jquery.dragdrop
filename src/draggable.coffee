#
# Name      : jquery.dragdrop
# Author    : Steven Luscher, https://twitter.com/steveluscher
# Version   : 0.0.1-dev
# Repo      : https://github.com/steveluscher/jquery.dragdrop
# Donations : http://lakefieldmusic.com
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
        # Attach the element event handlers
        .on
          mousedown: @handleElementMouseDown
          click: @handleElementClick

        # Mark this element as draggable with a class
        .addClass(@getConfig().draggableClass)

      # make the plugin chainable
      this

    #
    # Mouse events
    #

    handleElementMouseDown: (e) =>
      # Store the start position of the draggable
      for edge in ['top', 'left']
        @elementStartPosition[edge] = parseInt(@$element.css edge)
        @elementStartPosition[edge] = 0 if isNaN(@elementStartPosition[edge])

      # Store the start offset of the draggable, with respect to the document
      @elementStartOffset = @$element.offset()

      # Store the mousedown event that started this drag
      @mousedownEvent = e

      # Start to listen for mouse events on the document
      $(document).on
        mousemove: @handleDocumentMouseMove
        mouseup: @handleDocumentMouseUp

      # Stop the mousedown event
      false

    handleElementClick: (e) =>
      # Clicks should be passed through if this interaction didn't result in a drag
      shouldPermitClick = not @dragStarted

      # Clean up
      @dragStarted = false
      @elementStartPosition = {}
      @elementStartOffset = {}
      delete @mousedownEvent

      unless shouldPermitClick
        # Cancel the click
        e.stopImmediatePropagation()
        false

    handleDocumentMouseUp: (e) =>
      # Stop listening for mouse events on the document
      $(document).off
        mousemove: @handleMouseMove
        mouseup: @handleMouseUp

      # Remove the dragging class
      @$element.removeClass @getConfig().draggingClass

      # Trigger the stop event
      @handleDragStop()

    handleDocumentMouseMove: (e) =>
      # Trigger the start event, once
      @handleDragStart() unless @dragStarted

      # Trigger the drag event
      @handleDrag(e)

    #
    # Draggable events
    #

    handleDragStart: ->
      # Call any user-supplied start callback
      @config.start?()

      @$element
        # Apply the dragging class
        .addClass(@getConfig().draggingClass)

        # Position the draggable relative
        .css(position: 'relative')

      # Mark the drag as having started
      @dragStarted = true

    handleDragStop: ->
      # Call any user-supplied stop callback
      @config.stop?()

    handleDrag: (e) ->
      # Call any user-supplied drag callback
      @config.drag?()

      # How far has the mouse moved from its original position
      delta =
        x: e.pageX - @mousedownEvent.pageX
        y: e.pageY - @mousedownEvent.pageY

      # Move the element
      @$element.css
        left: parseInt(@elementStartPosition.left) + delta.x
        top: parseInt(@elementStartPosition.top) + delta.y

  $.fn.draggable = (options) ->
    this.each ->
      unless $(this).data('draggable')?
        plugin = new $.draggable(this, options)
        $(this).data('draggable', plugin)
