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

      # Save the original value of the pointer-events CSS property
      @originalPointerEventsPropertyValue = @$element.css('pointerEvents')

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
      # Trigger the start event, once
      @handleDragStart(e) unless @dragStarted

      # Trigger the drag event
      @handleDrag(e)

    handleDocumentMouseUp: (e) =>
      isLeftButton = e.which is 1
      return unless isLeftButton # Left clicks only, please

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

      # Store the start offset of the draggable, with respect to the page
      @elementStartPageOffset = convertPointFromNodeToPage @$element.get(0), new Point(0, 0)

      # Configure the drag helper
      helperConfig = @getConfig().helper
      @$helper =
        if helperConfig is 'clone' then @synthesizeHelperByCloning @$element
        else if typeof helperConfig is 'function' then @synthesizeHelperUsingFactory helperConfig, e
        else @$element # Use the element itself

      # Store the helper's parent; use it to map between the page coordinate space and the helper's parent coordinate space
      @parent = @getOffsetParentOrTransformedParent(@$helper)

      helperPosition = @$helper.css('position')
      @helperStartPosition = if helperPosition is 'fixed' and not @isTransformed(@parent)
        # Simply use the position of the helper
        @positionToPoint @$helper.position()
      else if /fixed|absolute/.test helperPosition
        # Convert the helper's start offset with respect to the page, to an offset in its offset parent or transformed parent's coordinate system
        startPosition = convertPointFromPageToNode @parent, @elementStartPageOffset

        if @isTransformed(@parent)
          # Apply the scroll offset of the helper's parent
          startPosition.x += @parent.scrollLeft
          startPosition.y += @parent.scrollTop

        # Store the start position
        startPosition
      else
        # Store the start position of the helper with respect to its position in the document flow
        new Point parseFloat(@$helper.css('left')), parseFloat(@$helper.css('top'))

      # Map the mouse coordinates into the helper's coordinate space
      {
        x: @mousedownEvent.LocalX
        y: @mousedownEvent.LocalY
      } = convertPointFromPageToNode @parent, new Point(@mousedownEvent.pageX, @mousedownEvent.pageY)

      @$helper
        # Apply the dragging class
        .addClass(@getConfig().draggingClass)
        # Kill pointer events while in mid-drag
        .css(pointerEvents: 'none')

      # Mark the drag as having started
      @dragStarted = true

      # Broadcast to interested subscribers that this droppable is now in the air
      @broadcast('start', e)

    handleDrag: (e) ->
      @scheduleDrag =>
        # Call any user-supplied drag callback
        @getConfig().drag?(e)

        # Map the mouse coordinates into the element's coordinate space
        @localMousePosition = convertPointFromPageToNode @parent, new Point(e.pageX, e.pageY)

        # How far has the object moved from its original position?
        delta =
          x: @localMousePosition.x - @mousedownEvent.LocalX
          y: @localMousePosition.y - @mousedownEvent.LocalY

        # Move the helper
        @$helper.css
          left: @helperStartPosition.x + delta.x
          top: @helperStartPosition.y + delta.y

    handleDragStop: (e) ->
      @cancelAnyScheduledDrag()

      # Restore the original value of the pointer-events property
      @$element.css(pointerEvents: @originalPointerEventsPropertyValue)

      # Call any user-supplied stop callback
      @getConfig().stop?(e)

      # Broadcast to interested subscribers that this droppable has been dropped
      @broadcast('stop', e)

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

    isTransformed: (element) ->
      @getTransformMatrix(element) isnt 'none'

    #
    # Helpers
    #

    broadcast: (type, originalEvent) ->
      # Synthesize a new event with this type
      event = new jQuery.Event(type)

      # Attach the original mouse event to it
      event.originalEvent = originalEvent

      # Broadcast!
      $(jQuery.draggable::).trigger(event, @)

    cancelAnyScheduledDrag: ->
      return unless @scheduledDragId

      cancelAnimationFrame(@scheduledDragId)
      @scheduledDragId = null

    getTransformMatrix: (element) ->
      # Get the computed styles
      computedStyle = getComputedStyle $(element).get(0)

      # Return the matrix
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

    positionToPoint: (position) ->
      new Point position.left, position.top

    prepareHelper: ($helper) ->
      css = {}

      # Position the helper absolutely, unless it already is
      css.position = 'absolute' unless $helper.css('position') is 'absolute'

      # Move the clone to the position of the original
      css.left = @elementStartPageOffset.x
      css.top = @elementStartPageOffset.y

      $helper
        # Remove the ID attribute
        .removeAttr('id')
        # Style it
        .css(css)
        # Attach it to the body
        .appendTo('body')

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
