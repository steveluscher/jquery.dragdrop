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
        @options.accept = ($draggable) => $draggable.is(selector)

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

      # Make the plugin chainable
      this

    setupElement: ->
      config = @getConfig()

      # Bind any supplied callbacks to this plugin
      for callbackName in ['over', 'out', 'drop']
        config[callbackName] = config[callbackName].bind(this) if typeof config[callbackName] is 'function'

      # Done!
      @setupPerformed = true

    setupMouseEnterListener: ->
      # Attach a handler to catch mouse enter events
      @$element.on
        mouseenter: @handleOver

      @mouseEnterListenerSetupPerformed = true

    setupMouseLeaveListener: ->
      # Attach a handler to catch mouse leave events
      @$element.on
        mouseleave: @handleOut

      @mouseLeaveListenerSetupPerformed = true

    #
    # Draggable events
    #

    handleDraggableStart: (e, draggable) =>
      # Lazily perform setup on the element
      @setupElement() unless @setupPerformed

      # Lazily attach a mouse enter listener to the element
      @setupMouseEnterListener() unless @mouseEnterListenerSetupPerformed

      # Mark the drag as having started
      @dragStarted = true

      # Store a reference to the draggable
      @draggable = draggable

      # Store a reference to the drag helper
      @$helper = @draggable.$helper

      # Did this drag start over top of this droppable?
      elementUnderMouse = document.elementFromPoint(e.originalEvent.clientX, e.originalEvent.clientY)

      # If this drag started over top of this droppable or one of its descendants, handle the over event right away
      @handleOver(e) if $(elementUnderMouse).closest(@$element).length

      # Watch for the draggable to be dropped
      $(jQuery.draggable::).on
        stop: @handleDraggableStop

    handleDraggableStop: (e, draggable) =>
      if @isDropTarget
        # Trigger the out handler
        @handleOut(e.originalEvent)

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

    handleOver: (e) =>
      return unless @dragStarted and not @isDropTarget

      # Ensure that this draggable is acceptable to this droppable
      return unless @getConfig().accept(@draggable.$element)

      # Lazily attach a mouse leave listener to the element
      @setupMouseLeaveListener() unless @mouseLeaveListenerSetupPerformed

      @$element
        # Apply the hover class
        .addClass(@getConfig().hoverClass)

      # Mark this droppable as being the drop target
      @isDropTarget = true

      # Compute the event metadata
      eventMetadata = @getEventMetadata()

      # Call any user-supplied over callback
      @getConfig().over?(e, eventMetadata)

    handleOut: (e) =>
      return unless @dragStarted

      @$element
        # Remove the hover class
        .removeClass(@getConfig().hoverClass)

      # Unmark this droppable as being the drop target
      @isDropTarget = false

      # Call any user-supplied out callback
      @getConfig().out?(e)

    handleDrop: (e) ->
      # Compute the event metadata
      eventMetadata = @getEventMetadata()

      # Call any user-supplied drop callback
      @getConfig().drop?(e, eventMetadata)

    #
    # Helpers
    #

    cleanUp: ->
      # Clean up
      @dragStarted = false
      @isDropTarget = false
      delete @draggable
      delete @$helper

  $.fn.droppable = (options) ->
    this.each ->
      unless $(this).data('droppable')?
        plugin = new $.droppable(this, options)
        $(this).data('droppable', plugin)
