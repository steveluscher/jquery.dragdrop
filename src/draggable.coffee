#
# Name      : jQuery DragDrop Draggable
# Author    : Steven Luscher, https://twitter.com/steveluscher
# Version   : 0.0.1-dev
# Repo      : https://github.com/steveluscher/jquery.dragdrop
# Donations : http://lakefieldmusic.com
#

jQuery ->

  class jQuery.draggable extends jQuery.dragdrop

    #
    # requestAnimationFrame polyfill
    #

    implementRequestAnimationFramePolyfill =
      # http://paulirish.com/2011/requestanimationframe-for-smart-animating/
      # http://my.opera.com/emoller/blog/2011/12/20/requestanimationframe-for-smart-er-animating
      # requestAnimationFrame polyfill by Erik Möller. fixes from Paul Irish and Tino Zijdel
      # MIT license
      ->
        lastTime = 0
        vendors = ["ms", "moz", "webkit", "o"]
        x = 0

        while x < vendors.length and not window.requestAnimationFrame
          window.requestAnimationFrame = window[vendors[x] + "RequestAnimationFrame"]
          window.cancelAnimationFrame = window[vendors[x] + "CancelAnimationFrame"] or window[vendors[x] + "CancelRequestAnimationFrame"]
          ++x
        unless window.requestAnimationFrame
          window.requestAnimationFrame = (callback, element) ->
            currTime = new Date().getTime()
            timeToCall = Math.max(0, 16 - (currTime - lastTime))
            id = window.setTimeout(->
              callback currTime + timeToCall
            , timeToCall)
            lastTime = currTime + timeToCall
            id
        unless window.cancelAnimationFrame
          window.cancelAnimationFrame = (id) ->
            clearTimeout id

        # Prevent this function from running again
        implementRequestAnimationFramePolyfill = -> # noop

    #
    # Config
    #

    defaults:
      # Applied when the draggable is initialized
      draggableClass: 'ui-draggable'

      # Applied when a draggable is in mid-drag
      draggingClass: 'ui-draggable-dragging'

      # Helper options:
      # * original: drag the actual element
      # * clone: stick a copy of the element to the mouse
      # * (element, e) ->: stick the return value of this function to the mouse; must return something that produces a DOM element when run through jQuery
      helper: 'original'

    #
    # Initialization
    #

    constructor: (element, @options = {}) ->
      super

      # Lazily implement a requestAnimationFrame polyfill
      implementRequestAnimationFramePolyfill()

      # jQuery version of DOM element attached to the plugin
      @$element = $ element

      @$element
        # Attach the element event handlers
        .on
          mousedown: @handleElementMouseDown
          click: @handleElementClick

        # Mark this element as draggable with a class
        .addClass(@getConfig().draggableClass)

      # Make the plugin chainable
      this

    setupElement: ->
      # Position the draggable relative if it's currently statically positioned
      @$element.css(position: 'relative') if @getConfig().helper is 'original' and @$element.css('position') is 'static'

      # Done!
      @setupPerformed = true

    #
    # Mouse events
    #

    handleElementMouseDown: (e) =>
      @cancelAnyScheduledDrag()

      # Until told otherwise, the interaction started by this mousedown should not cancel any subsequent click event
      @shouldCancelClick = false

      # Bail if this is not a valid handle
      return unless @isValidHandle(e.target)

      # Store the mousedown event that started this drag
      @mousedownEvent = e

      # Start to listen for mouse events on the document
      $(document).on
        mousemove: @handleDocumentMouseMove
        mouseup: @handleDocumentMouseUp

      # Stop the mousedown event
      false

    handleDocumentMouseMove: (e) =>
      # Trigger the start event, once
      @handleDragStart(e) unless @dragStarted

      # Trigger the drag event
      @handleDrag(e)

    handleDocumentMouseUp: (e) =>
      # Stop listening for mouse events on the document
      $(document).off
        mousemove: @handleMouseMove
        mouseup: @handleMouseUp

      # Lest a click event follow this mouseup, decide whether it should be permitted or not
      @shouldCancelClick = !!@dragStarted

      return unless @dragStarted

      if @getConfig().helper is 'original'
        # Remove the dragging class
        @$helper.removeClass @getConfig().draggingClass
      else
        # Destroy the helper
        @$helper.remove()
        # Trigger the click event on the original element
        @$element.trigger('click', e)

      # Trigger the stop event
      @handleDragStop(e)

      # Clean up
      @cleanUp()

    handleElementClick: (e) =>
      # Clicks should be cancelled if the last mousedown/mouseup interaction resulted in a drag
      if @shouldCancelClick
        # Cancel the click
        e.stopImmediatePropagation()
        false

    #
    # Draggable events
    #

    handleDragStart: (e) ->
      @cancelAnyScheduledDrag()

      # Lazily perform setup on the element
      @setupElement() unless @setupPerformed

      # Call any user-supplied start callback
      @getConfig().start?(e)

      # Store the start offset of the draggable, with respect to the document
      @elementStartDocumentOffset = @$element.offset()

      # Configure the drag helper
      helperConfig = @getConfig().helper
      @$helper =
        if helperConfig is 'clone' then @synthesizeHelperByCloning @$element
        else if typeof helperConfig is 'function' then @synthesizeHelperUsingFactory helperConfig, e
        else @$element # Use the element itself

      if @isPositionedAbsoluteish(@$helper)
        # Store the start offset of the helper, with respect to its offset parent
        @helperStartPosition = @$helper.position()
      else
        # Store the start position of the helper with respect to itself
        @helperStartPosition ||= {}
        for edge in ['top', 'left']
          @helperStartPosition[edge] = parseInt(@$helper.css edge)
          @helperStartPosition[edge] = 0 if @isNaN(@helperStartPosition[edge])

      # Store the start offset of the helper, with respect to the document
      @helperStartDocumentOffset = @$helper.offset()

      @$helper
        # Apply the dragging class
        .addClass(@getConfig().draggingClass)

      # Mark the drag as having started
      @dragStarted = true

    handleDrag: (e) ->
      @scheduleDrag =>
        # Call any user-supplied drag callback
        @getConfig().drag?(e)

        # How far has the mouse moved from its original position
        delta =
          x: e.pageX - @mousedownEvent.pageX
          y: e.pageY - @mousedownEvent.pageY

        # Move the helper
        @$helper.css
          left: parseInt(@helperStartPosition .left) + delta.x
          top: parseInt(@helperStartPosition .top) + delta.y

    handleDragStop: (e) ->
      @cancelAnyScheduledDrag()

      # Call any user-supplied stop callback
      @getConfig().stop?(e)

    #
    # Validators
    #

    isValidHandle: (element) ->
      if @getConfig().handle
        $element = $(element)

        # Is this element the handle itself, or a descendant of the handle?
        !!$element.closest(@getConfig().handle).length
      else
        # No handle was specified; anything is fair game
        true

    isPositionedAbsoluteish: (element) -> /fixed|absolute/.test element.css('position')

    #
    # Helpers
    #

    cancelAnyScheduledDrag: ->
      return unless @scheduledDragId

      cancelAnimationFrame(@scheduledDragId)
      @scheduledDragId = null

    scheduleDrag: (invocation) ->
      @cancelAnyScheduledDrag()
      @scheduledDragId = requestAnimationFrame =>
        invocation()
        @scheduledDragId = null

    synthesizeHelperByCloning: (element) ->
      # Clone the original element
      helper = element.clone()

      # Post process the helper element
      @prepareHelper helper

    synthesizeHelperUsingFactory: (factory, e) ->
      # Run the factory
      output = factory @$element.get(0), e

      # Process the output with jQuery
      helper = $(output).first()

      throw new Error '[jQuery DragDrop – Draggable] Helper factory methods must produce a jQuery object, a DOM Element, or a string of HTML' unless helper.length

      # Post process the helper element
      @prepareHelper helper.first()

    prepareHelper: (helper) ->
      css = {}

      # Position the helper absolutely, unless it already is-ish
      css.position = 'absolute' unless @isPositionedAbsoluteish(helper)

      # Move the clone to the position of the original
      css.top = @elementStartDocumentOffset.top
      css.left = @elementStartDocumentOffset.left

      helper
        # Remove the ID attribute
        .removeAttr('id')
        # Style it
        .css(css)
        # Attach it to the body
        .appendTo('body')

    cleanUp: ->
      # Clean up
      @dragStarted = false
      @$helper = null
      @helperStartPosition = {}
      @elementStartDocumentOffset = {}
      @helperStartDocumentOffset = {}
      delete @mousedownEvent

  $.fn.draggable = (options) ->
    this.each ->
      unless $(this).data('draggable')?
        plugin = new $.draggable(this, options)
        $(this).data('draggable', plugin)
