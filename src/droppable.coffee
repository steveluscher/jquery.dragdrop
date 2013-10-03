#
# Name      : jQuery DragDrop Droppable
# Author    : Steven Luscher, https://twitter.com/steveluscher
# Version   : 0.0.1-dev
# Repo      : https://github.com/steveluscher/jquery.dragdrop
# Donations : http://lakefieldmusic.com
#

jQuery ->

  class jQuery.droppable extends jQuery.dragdrop

    #
    # Config
    #

    defaults:
      # Applied when the droppable is initialized
      droppableClass: 'ui-droppable'

      # Applied when a draggable is hovering over this droppable
      hoverClass: 'ui-droppable-hovered'

      # Accept options:
      # * selector string: original draggable DOM element must match this selector
      # * ($draggable) ->: a function that returns true if the draggable is acceptable to this droppable
      accept: -> true

    #
    # Initialization
    #

    constructor: (element, @options = {}) ->
      # Coerce the accept option to be a function if it appears to be a selector string
      if typeof (selector = @options.accept) is 'string'
        @options.accept = (metadata) => metadata.draggable.is(selector)

      super

      throw new Error '[jQuery DragDrop – Droppable] Missing dependency jQuery Draggable' unless jQuery.draggable?

      # jQuery version of DOM element attached to the plugin
      @$element = $ element

      @$element
        # Mark this element as droppable with a class
        .addClass(@getConfig().droppableClass)

      # Subscribe to draggable start events
      $(jQuery.draggable::).on
        start: @handleDraggableStart

      # If there is already a draggable in the air, handle the draggable start event right away
      @handleDraggableStart(jQuery.draggable.latestEvent, jQuery.draggable.draggableAloft) if jQuery.draggable.draggableAloft?

      # Make the plugin chainable
      this

    setupElement: ->
      config = @getConfig()

      # Bind any supplied callbacks to this plugin
      for callbackName in ['over', 'out', 'drop']
        config[callbackName] = config[callbackName].bind(this) if typeof config[callbackName] is 'function'

      # Done!
      @setupPerformed = true

    setupMouseOverListener: ->
      # Attach a handler to catch mouse enter events
      @$element.on 'mouseover', (e) =>
        return if (
          # Bail if there is no drag in progress
          not @dragStarted or
          # …or if we are already the drop target
          @isDropTarget
        )

        # Crawl backward from the origin of this mouse over event until we find a droppable
        $closestDroppableToOrigin = getClosestDroppable(e.target)

        # If we're the closest droppable to this mouse over event, fire the drop over event
        @handleOver(e) if @$element.is($closestDroppableToOrigin)

      @mouseOverListenerSetupPerformed = true

    setupMouseOutListener: ->
      # Attach a handler to catch mouse leave events
      @$element.on 'mouseout', (e) =>
        # Bail if there is no drag in progress
        return unless @dragStarted

        # Crawl backward from the origin of this mouse out event until we find a droppable
        $closestDroppableToOrigin = getClosestDroppable(e.target)
        $closestDroppableToNextElement = getClosestDroppable(e.relatedTarget)

        # If we are moving away from this droppable, fire the drop out event
        @handleOut(e) if @$element.is($closestDroppableToOrigin) and not @$element.is($closestDroppableToNextElement)

      @mouseOutListenerSetupPerformed = true

    #
    # Draggable events
    #

    handleDraggableStart: (e, draggable) =>
      # Lazily perform setup on the element
      @setupElement() unless @setupPerformed

      # Lazily attach a mouse over listener to the element
      @setupMouseOverListener() unless @mouseOverListenerSetupPerformed

      # Mark the drag as having started
      @dragStarted = true

      # Store a reference to the draggable
      @draggable = draggable

      # Store a reference to the drag helper
      @$helper = @draggable.$helper

      # Did this drag start over top of this droppable?
      elementUnderMouse = document.elementFromPoint(e.originalEvent.clientX, e.originalEvent.clientY)
      $closestDroppableUnderMouse = getClosestDroppable(elementUnderMouse)

      # If this drag started over top of this droppable, handle the over event right away
      @handleOver(e) if @$element.is($closestDroppableUnderMouse)

      # Watch for the draggable to be dropped
      $(jQuery.draggable::).on
        stop: @handleDraggableStop

    handleDraggableStop: (e, draggable) =>
      if @isDropTarget
        @$element
          # Remove the hover class
          .removeClass(@getConfig().hoverClass)

        # Unmark this droppable as being the drop target
        @isDropTarget = false

        # Trigger the drop handler
        @handleDrop(e.originalEvent)

      # Stop watching for the draggable to be dropped
      $(jQuery.draggable::).off
        stop: @handleDraggableStop

      # Clean up
      @cleanUp()

    #
    # Droppable events
    #

    handleOver: (e) ->
      # Compute the event metadata
      eventMetadata = @getEventMetadata()

      # Ensure that this draggable is acceptable to this droppable
      return unless @getConfig().accept(eventMetadata)

      # Lazily attach a mouse leave listener to the element
      @setupMouseOutListener() unless @mouseOutListenerSetupPerformed

      @$element
        # Apply the hover class
        .addClass(@getConfig().hoverClass)

      # Mark this droppable as being the drop target
      @isDropTarget = true

      # Synthesize a new event to represent this drop over
      dropOverEvent = @synthesizeEvent('dropover', e)

      # Call any user-supplied over callback
      @getConfig().over?(dropOverEvent, eventMetadata)

      # Trigger the drop over event on this droppable's element
      @$element.trigger(dropOverEvent, eventMetadata)

    handleOut: (e) ->
      @$element
        # Remove the hover class
        .removeClass(@getConfig().hoverClass)

      # Unmark this droppable as being the drop target
      @isDropTarget = false

      # Compute the event metadata
      eventMetadata = @getEventMetadata()

      # Synthesize a new event to represent this drop out
      dropOutEvent = @synthesizeEvent('dropout', e)

      # Call any user-supplied out callback
      @getConfig().out?(dropOutEvent)

      # Trigger the drop out event on this droppable's element
      @$element.trigger(dropOutEvent, eventMetadata)

    handleDrop: (e) ->
      # Compute the event metadata
      eventMetadata = @getEventMetadata()

      # Synthesize a new event to represent this drop out
      dropEvent = @synthesizeEvent('drop', e)

      # Call any user-supplied drop callback
      @getConfig().drop?(dropEvent, eventMetadata)

      # Trigger the drop event on this droppable's element
      @$element.trigger(dropEvent, eventMetadata)

    #
    # Helpers
    #

    cleanUp: ->
      # Clean up
      @dragStarted = false
      @isDropTarget = false
      delete @draggable
      delete @$helper

    getClosestDroppable = (element) ->
      $putativeDroppable = $(element)

      # Crawl up the DOM, starting at the supplied element
      $putativeDroppable = $putativeDroppable.parent() until (
        # Stop searching when we run out of candidates
        not $putativeDroppable.length or
        # …or when we reach the first droppable
        $putativeDroppable.data('droppable')
      )

      # Return our findings
      $putativeDroppable

  $.fn.droppable = (options) ->
    this.each ->
      unless $(this).data('droppable')?
        plugin = new $.droppable(this, options)
        $(this).data('droppable', plugin)
