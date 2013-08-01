#
# Name      : jQuery DragDrop Draggable
# Author    : Steven Luscher, https://twitter.com/steveluscher
# Version   : 0.0.1-dev
# Repo      : https://github.com/steveluscher/jquery.dragdrop
# Donations : http://lakefieldmusic.com
#

jQuery ->

  class jQuery.draggable extends jQuery.dragdrop

    vendors = ["ms", "moz", "webkit", "o"]
    getCamelizedVendor = (vendor) ->
      if vendor is 'webkit' then 'WebKit'
      else vendor.charAt(0).toUpperCase() + vendor.slice(1)

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

        for vendor in vendors
          window.requestAnimationFrame ||= window[vendor + "RequestAnimationFrame"]
          window.cancelAnimationFrame ||= window[vendor + "CancelAnimationFrame"] or window[vendor + "CancelRequestAnimationFrame"]
          break if window.requestAnimationFrame and window.cancelAnimationFrame

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
    # convertPoint polyfill
    #

    implementConvertPointPolyfill = ->

      for vendor in vendors
        window.convertPointFromPageToNode ||= window[vendor + "ConvertPointFromPageToNode"]
        window.convertPointFromNodeToPage ||= window[vendor + "ConvertPointFromNodeToPage"]
        window.Point ||= window[getCamelizedVendor(vendor) + "Point"]
        break if window.convertPointFromPageToNode and window.convertPointFromNodeToPage and window.Point

      unless window.Point
        # TODO: Implement Point() polyfill'
        throw '[jQuery DragDrop] TODO: Implement Point() polyfill'
      unless window.convertPointFromPageToNode
        # TODO: Implement convertPointFromPageToNode() polyfill
        throw '[jQuery DragDrop] TODO: Implement convertPointFromPageToNode() polyfill'
      unless window.convertPointFromNodeToPage
        # TODO: Implement convertPointFromNodeToPage() polyfill
        throw '[jQuery DragDrop] TODO: Implement convertPointFromNodeToPage() polyfill'

      # Prevent this function from running again
      implementConvertPointPolyfill = -> #noop

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
      # * ($draggable, e) ->: stick the return value of this function to the mouse; must return something that produces a DOM element when run through jQuery
      helper: 'original'

      # Stack options:
      # * selector string: elements that match this selector are members of the stack
      # * ($draggable, e) ->: a function that returns a jQuery collection, or a collection of DOM elements
      stack: false

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
      config = @getConfig()

      # Position the draggable relative if it's currently statically positioned
      @$element.css(position: 'relative') if config.helper is 'original' and @$element.css('position') is 'static'

      # Bind any supplied callbacks to this plugin
      for callbackName in ['start', 'drag', 'stop']
        config[callbackName] = config[callbackName].bind(this) if typeof config[callbackName] is 'function'

      # Done!
      @setupPerformed = true

    #
    # Mouse events
    #

    handleElementMouseDown: (e) =>
      isLeftButton = e.which is 1
      return unless isLeftButton # Left clicks only, please

      @cancelAnyScheduledDrag()

      # Until told otherwise, the interaction started by this mousedown should not cancel any subsequent click event
      @shouldCancelClick = false

      # Bail if this is not a valid handle
      return unless @isValidHandle(e.target)

      # Lazily implement a set of coordinate conversion polyfills
      implementConvertPointPolyfill()

      # Store the mousedown event that started this drag
      @mousedownEvent = e

      # Start to listen for mouse events on the document
      $(document).on
        mousemove: @handleDocumentMouseMove
        mouseup: @handleDocumentMouseUp

      # Stop the mousedown event
      false

    handleDocumentMouseMove: (e) =>
      if @dragStarted
        # Trigger the drag event
        @handleDrag(e)
      else
        # Trigger the start event
        @handleDragStart(e)

        if @dragStarted
          # Trigger the drag event immediately
          @handleDrag(e, true)

          # Broadcast to interested subscribers that this droppable is now in the air
          @broadcast('start', e)

    handleDocumentMouseUp: (e) =>
      isLeftButton = e.which is 1
      return unless isLeftButton # Left clicks only, please

      # Trigger the stop event
      @handleDragStop(e)

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
      # Lazily perform setup on the element
      @setupElement() unless @setupPerformed

      # Will we use the original element as the helper, or will we synthesize a new one?
      helperConfig = @getConfig().helper
      helperIsSynthesized = helperConfig isnt 'original'

      # Get (or synthesize temporarily) a placeholder for the drag helper
      helperPlaceholder =
        if helperIsSynthesized then $('<div style="height: 0; width: 0; visibility: none">').appendTo('body')
        else @$element # Use the element itself

      # Store the helper's parent; we will use it to map between the page coordinate space and the helper's parent coordinate space
      @parent = if helperIsSynthesized
        # Go to the target attachment point of the syntheized helper, and search up the DOM for a parent
        @getOffsetParentOrTransformedParent(helperPlaceholder)
      else
        # Start from the original element, and search up the DOM for a parent
        @getOffsetParentOrTransformedParent(@$element)

      # Thanks, drag helper placeholder; you can go now
      helperPlaceholder.remove() if helperIsSynthesized

      # Should we calculate the helper's offset, or simply read its 'top' and 'left' CSS properties?
      shouldCalculateOffset =
        # Always calculate the offset if a synthesized helper is involved
        helperIsSynthesized or
        # …or if the original element behaves as though it is absolutely positioned, but has no explicit top or left
        (@isAbsoluteish(@$element) and @isPositionedImplicitly(@$element))

      # Store the start offset of the draggable, with respect to the page
      @elementStartPageOffset = convertPointFromNodeToPage @$element.get(0), new Point(0, 0)

      @helperStartPosition = if shouldCalculateOffset
        elementPreTransformStartPageOffset = if not helperIsSynthesized and @isTransformed(@$element.get(0))
          # Save the element's current transform
          savedTransform = @$element.css('transform')

          # Disable the transform before calculating the element's position
          @$element.css('transform', 'none')

          # Get the element's pre-transform offset, with respect to the page
          preTransformOffset = convertPointFromNodeToPage @$element.get(0), new Point(0, 0)

          # Restore the transform
          @$element.css('transform', savedTransform)

          # Store the pre-transform offset
          preTransformOffset
        else
          @elementStartPageOffset

        # Convert between the offset with respect to the page, and one with respect to its offset or transformed parent's coordinate system
        startPosition = convertPointFromPageToNode @parent, elementPreTransformStartPageOffset

        if @isTransformed(@parent)
          # Apply the scroll offset of the element's transformed parent
          startPosition.x += @parent.scrollLeft
          startPosition.y += @parent.scrollTop

        # Store the result
        startPosition
      else
        # Store the start position of the element with respect to its location in the document flow
        new Point parseFloat(@$element.css('left')), parseFloat(@$element.css('top'))

      # Compute the event metadata
      startPosition = @pointToPosition @helperStartPosition
      startOffset = @pointToPosition @elementStartPageOffset
      eventMetadata = @getEventMetadata(startPosition, startOffset)

      # Synthesize a new event to represent this drag start
      dragStartEvent = @synthesizeEvent('dragstart', e)

      # Call any user-supplied drag callback; cancel the start if it returns false
      if @getConfig().start?(dragStartEvent, eventMetadata) is false
        @handleDragStop(e)
        return

      @cancelAnyScheduledDrag()

      # Save the original value of the pointer-events CSS property
      @originalPointerEventsPropertyValue = @$element.css('pointerEvents')

      # Configure the drag helper
      @$helper =
        if helperConfig is 'clone' then @synthesizeHelperByCloning @$element
        else if typeof helperConfig is 'function' then @synthesizeHelperUsingFactory helperConfig, e
        else @$element # Use the element itself

      @$helper
        # Apply the dragging class
        .addClass(@getConfig().draggingClass)
        # Kill pointer events while in mid-drag
        .css(pointerEvents: 'none')

      if helperIsSynthesized
        @$helper
          # Append the helper to the body
          .appendTo('body')

      @moveHelperToTopOfStack(stackConfig, e) if not helperIsSynthesized and stackConfig = @getConfig().stack

      # Map the mouse coordinates into the helper's coordinate space
      {
        x: @mousedownEvent.LocalX
        y: @mousedownEvent.LocalY
      } = convertPointFromPageToNode @parent, new Point(@mousedownEvent.pageX, @mousedownEvent.pageY)

      # Mark the drag as having started
      @dragStarted = true

      # Trigger the drag start event on this draggable's element
      @$element.trigger(dragStartEvent, eventMetadata)

    handleDrag: (e, immediate = false) ->
      dragHandler = =>
        # Map the mouse coordinates into the element's coordinate space
        @localMousePosition = convertPointFromPageToNode @parent, new Point(e.pageX, e.pageY)

        # How far has the object moved from its original position?
        delta =
          x: @localMousePosition.x - @mousedownEvent.LocalX
          y: @localMousePosition.y - @mousedownEvent.LocalY

        # Calculate the helper's target position
        targetPosition =
          left: @helperStartPosition.x + delta.x
          top: @helperStartPosition.y + delta.y

        # Calculate the target offset
        targetOffset =
          left: @elementStartPageOffset.x + (e.pageX - @mousedownEvent.pageX)
          top: @elementStartPageOffset.y + (e.pageY - @mousedownEvent.pageY)

        # Compute the event metadata
        eventMetadata = @getEventMetadata(targetPosition, targetOffset)

        # Synthesize a new event to represent this drag
        dragEvent = @synthesizeEvent('drag', e)

        # Call any user-supplied drag callback; cancel the drag if it returns false
        if @getConfig().drag?(dragEvent, eventMetadata) is false
          @handleDragStop(e)
          return

        # Move the helper
        @$helper.css eventMetadata.position

        # Trigger the drag event on this draggable's element
        @$element.trigger(dragEvent, eventMetadata)

      if immediate
        # Call the drag handler right away
        dragHandler()
      else
        # Schedule the drag handler to be called when the next frame is about to be drawn
        @scheduleDrag dragHandler

    handleDragStop: (e) ->
      @cancelAnyScheduledDrag()

      # Stop listening for mouse events on the document
      $(document).off
        mousemove: @handleMouseMove
        mouseup: @handleMouseUp

      if @dragStarted

        # Lest a click event occur before cleanup is called, decide whether it should be permitted or not
        @shouldCancelClick = !!@dragStarted

        # Compute the event metadata
        eventMetadata = @getEventMetadata()

        if @getConfig().helper is 'original'
          # Remove the dragging class
          @$helper.removeClass @getConfig().draggingClass
        else
          # Destroy the helper
          @$helper.remove()
          # Trigger the click event on the original element
          @$element.trigger('click', e)

        # Restore the original value of the pointer-events property
        @$element.css(pointerEvents: @originalPointerEventsPropertyValue)

        # Synthesize a new event to represent this drag start
        dragStopEvent = @synthesizeEvent('dragstop', e)

        # Call any user-supplied stop callback
        @getConfig().stop?(dragStopEvent, eventMetadata)

        # Trigger the drag stop on this draggable's element
        @$element.trigger(dragStopEvent, eventMetadata)

        # Broadcast to interested subscribers that this droppable has been dropped
        @broadcast('stop', e)

      # Clean up
      @cleanUp()

    #
    # Validators
    #

    isAbsoluteish: (element) ->
      /fixed|absolute/.test $(element).css('position')

    isPositionedImplicitly: (element) ->
      $element = $(element)

      return true if $element.css('top') is 'auto' and $element.css('bottom') is 'auto'
      return true if $element.css('left') is 'auto' and $element.css('right') is 'auto'

    isValidHandle: (element) ->
      if @getConfig().handle
        $element = $(element)

        # Is this element the handle itself, or a descendant of the handle?
        !!$element.closest(@getConfig().handle).length
      else
        # No handle was specified; anything is fair game
        true

    isTransformed: (element) ->
      getTransformMatrixString(element) isnt 'none'

    #
    # Helpers
    #

    broadcast: (type, originalEvent) ->
      # Synthesize a new event with this type
      event = @synthesizeEvent(type, originalEvent)

      # Broadcast!
      $(jQuery.draggable::).trigger(event, @)

    cancelAnyScheduledDrag: ->
      return unless @scheduledDragId

      cancelAnimationFrame(@scheduledDragId)
      @scheduledDragId = null

    getTransformMatrixString = (element) ->
      # Get the computed styles
      return 'none' unless computedStyle = getComputedStyle(element)

      # Return the matrix string
      computedStyle.WebkitTransform or computedStyle.msTransform or computedStyle.MozTransform or computedStyle.OTransform or 'none'

    getOffsetParentOrTransformedParent: (element) ->
      $element = $(element)

      # If we don't find anything, we'll return the document element
      foundAncestor = document.documentElement

      # Crawl up the DOM, starting at this element's parent
      for ancestor in $element.parents().get()
        # Look for an ancestor of element that is either positioned, or transformed
        if $(ancestor).css('position') isnt 'static' or @isTransformed(ancestor)
          foundAncestor = ancestor
          break

      # Return the ancestor we found
      foundAncestor

    scheduleDrag: (invocation) ->
      @cancelAnyScheduledDrag()
      @scheduledDragId = requestAnimationFrame =>
        invocation()
        @scheduledDragId = null

    synthesizeHelperByCloning: (element) ->
      # Clone the original element
      helper = element.clone()

      # Remove the ID attribute
      helper.removeAttr('id')

      # Post process the helper element
      @prepareHelper helper

    synthesizeHelperUsingFactory: (factory, e) ->
      # Run the factory
      output = factory @$element, e

      # Process the output with jQuery
      helper = $(output).first()

      throw new Error '[jQuery DragDrop – Draggable] Helper factory methods must produce a jQuery object, a DOM Element, or a string of HTML' unless helper.length

      # Post process the helper element
      @prepareHelper helper.first()

    moveHelperToTopOfStack: (stackConfig, e) ->
      # Get the members of the stack
      $stackMembers = $(stackConfig?(@$helper, e) or stackConfig)
      return unless $stackMembers.length

      # Sort the stack members by z-index
      sortedStackMembers = $stackMembers.get().sort (a, b) ->
        (parseInt($(b).css('zIndex'), 10) or 0) - (parseInt($(a).css('zIndex'), 10) or 0)

      return if @$helper.is(topStackMember = sortedStackMembers[0])

      # Get the top element's index
      topIndex = $(topStackMember).css('zIndex')

      # Move this helper to the top of the stack
      @$helper.css('zIndex', parseInt(topIndex, 10) + 1)

    positionToPoint: (position) ->
      new Point position.left, position.top

    pointToPosition: (point) ->
      left: point.x
      top: point.y

    prepareHelper: ($helper) ->
      css = {}

      # Position the helper absolutely, unless it already is
      css.position = 'absolute' unless $helper.css('position') is 'absolute'

      # Move the clone to the position of the original
      css.left = @elementStartPageOffset.x
      css.top = @elementStartPageOffset.y

      # Style it
      $helper.css(css)

    cleanUp: ->
      # Clean up
      @dragStarted = false
      @elementStartPageOffset = {}
      @helperStartPosition = {}
      delete @$helper
      delete @parent
      delete @mousedownEvent

  $.fn.draggable = (options) ->
    this.each ->
      unless $(this).data('draggable')?
        plugin = new $.draggable(this, options)
        $(this).data('draggable', plugin)
