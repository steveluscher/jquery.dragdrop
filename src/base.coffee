return if jQuery.dragdrop?
class jQuery.dragdrop

  #
  # Utility functions
  #

  getCSSEdge = (edge, oppositeEdge, $element) ->
    # See if there exists a numeric value for the target edge
    parseFloat($element.css(edge)) or
    # If not, see if there is a numeric value for the opposite edge, then rely on jQuery.position to get the target edge
    if parseFloat($element.css(oppositeEdge)) then $element.position()[edge] else null or
    # Otherwise, return zero
    0
  getCSSLeft: ($element) -> getCSSEdge('left', 'right', $element)
  getCSSTop: ($element) -> getCSSEdge('top', 'bottom', $element)
  getConfig: -> @config ||= @applyDefaults @options, @defaults
  isArray: Array.isArray or (putativeArray) -> Object::toString.call(putativeArray) is '[object Array]'
  isNumber: (obj) -> (obj is +obj) or toString.call(obj) is '[object Number]'
  isNaN: (obj) -> @isNumber(obj) and window.isNaN(obj)
  applyDefaults: (obj, sources...) ->
    for source in sources
      continue unless source
      for prop of source
        obj[prop] = source[prop] if obj[prop] is undefined
    obj
  synthesizeEvent: (type, originalEvent) ->
    # Create an event using the original one as the basis
    event = jQuery.Event(originalEvent)

    # Set the type of the new event
    event.type = type

    # Set the target of the event to the DOM element of this draggable/droppable
    event.target = @$element.get(0)

    # Copy properties from the original event to the new one, except where one already exists
    (event[key] = value unless key of event) for key, value of originalEvent

    # Return the event
    event
  getEventMetadata: (position, offset) ->
    metadata =
      # Report the position of the helper
      position: position or {
        top: @getCSSTop(@$helper)
        left: @getCSSLeft(@$helper)
      }
      # Report the offset of the helper
      offset: offset or @$helper.offset()

    if @helperStartPosition? or @draggable?
      # Supply the original position of the drag helper
      metadata.originalPosition =
        top: (@helperStartPosition or @draggable.helperStartPosition).y
        left: (@helperStartPosition or @draggable.helperStartPosition).x

    # Supply a reference to the helper's DOM element, if available
    metadata.helper = @$helper if @$helper?

    # Supply a reference to the draggable, if available
    metadata.draggable = @draggable.$element if @draggable?

    # Return the metadata
    metadata
