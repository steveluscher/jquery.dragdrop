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
