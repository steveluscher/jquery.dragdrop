describe 'A droppable', ->
  options =
    alternateHoverClass: 'alternateHoverClass'

  describe 'configured using the default options', ->

    beforeEach ->
      loadFixtures 'droppable.html'
      @$droppable = $('#droppable').droppable()

    describe 'with a draggable hovering above it', ->

      beforeEach ->
        appendLoadFixtures 'draggable.html'
        @$draggable = $('#draggable').draggable()

        # Find the center of the elements
        draggableCenter = SpecHelper.findCenterOf @$draggable
        droppableCenter = SpecHelper.findCenterOf @$droppable

        # Drag the draggable over top of the droppable
        @$draggable.simulate 'mousedown',
          clientX: draggableCenter.x
          clientY: draggableCenter.y
        $(document).simulate 'mousemove',
          clientX: droppableCenter.x
          clientY: droppableCenter.y

      it 'should possess the default hover class', ->
        expect(@$droppable).toHaveClass $.droppable::defaults['hoverClass']

  describe 'configured using the hoverClass option', ->

    beforeEach ->
      loadFixtures 'droppable.html'
      @$droppable = $('#droppable').droppable(hoverClass: options.alternateHoverClass)

    describe 'with a draggable hovering above it', ->

      beforeEach ->
        appendLoadFixtures 'draggable.html'
        @$draggable = $('#draggable').draggable()

        # Find the center of the elements
        draggableCenter = SpecHelper.findCenterOf @$draggable
        droppableCenter = SpecHelper.findCenterOf @$droppable

        # Drag the draggable over top of the droppable
        @$draggable.simulate 'mousedown',
          clientX: draggableCenter.x
          clientY: draggableCenter.y
        $(document).simulate 'mousemove',
          clientX: droppableCenter.x
          clientY: droppableCenter.y

      it 'should possess the supplied hover class', ->
        expect(@$droppable).toHaveClass options.alternateHoverClass
