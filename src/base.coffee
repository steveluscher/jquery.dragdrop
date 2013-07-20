return if jQuery.dragdrop?
class jQuery.dragdrop

  #
  # Utility functions
  #

  getConfig: -> @config ||= @applyDefaults @options, @defaults
  isNumber: (obj) -> (obj is +obj) or toString.call(obj) is '[object Number]'
  isNaN: (obj) -> @isNumber(obj) and window.isNaN(obj)
  applyDefaults: (obj, sources...) ->
    for source in sources
      continue unless source
      for prop of source
        obj[prop] = source[prop] if obj[prop] is undefined
    obj
  getEventMetadata: (position, offset) ->
    metadata =
      # Report the position of the helper
      position: position or {
        top: parseFloat(@$helper.css('top')) or 0
        left: parseFloat(@$helper.css('left')) or 0
      }
      # Report the offset of the helper
      offset: offset or @$helper.offset()

    # Supply a reference to the helper's DOM element, if available
    metadata.helper = @$helper if @$helper?

    # Return the metadata
    metadata
