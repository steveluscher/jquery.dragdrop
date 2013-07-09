class this.SpecHelper
  @findCenterOf: (element) ->
    $document = $(document)
    offset = element.offset()
    return {
      x: Math.floor(offset.left + element.outerWidth() / 2 - $document.scrollLeft())
      y: Math.floor(offset.top + element.outerHeight() / 2 - $document.scrollTop())
    }

  @mouseDownInCenterOf: (element) ->
    center = @findCenterOf element
    element.simulate 'mousedown',
      clientX: center.x
      clientY: center.y
    center

  @isNumber: (obj) -> (obj is +obj) or toString.call(obj) is '[object Number]'
  @isNaN: (obj) -> @isNumber(obj) and window.isNaN(obj)
