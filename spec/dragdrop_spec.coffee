describe 'A droppable', ->
  options =
    alternateHoverClass: 'alternateHoverClass'

  describe 'configured using the default options', ->

    beforeEach ->
      loadFixtures 'droppable.html'
      @$droppable = $('#droppable').droppable()

    describe 'with a draggable hovering above it', ->

      beforeEach ->
        appendLoadFixtures 'draggable_static.html'
        @$draggable = $('#draggable_static').draggable()

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
        appendLoadFixtures 'draggable_static.html'
        @$draggable = $('#draggable_static').draggable()

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

  describe 'configured with callbacks', ->

    beforeEach ->
      @callback = jasmine.createSpy('callback')

    describe 'such as an over callback', ->

      beforeEach ->
        loadFixtures 'droppable.html'
        @$droppable = $('#droppable').droppable(over: @callback)

      describe 'having had a draggable come to hover above it', ->

        beforeEach ->
          appendLoadFixtures 'draggable_static.html'
          @$draggable = $('#draggable_static').draggable()

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

        describe 'the over callback', ->

          it 'should have been called', ->
            expect(@callback).toHaveBeenCalled()

          it 'should have been called with the jQuery mouse event as the first parameter, and an object as the second parameter', ->
            expect(@callback).toHaveBeenCalledWith(jasmine.any(jQuery.Event), jasmine.any(Object))

        describe 'the second parameter to the over callback', ->

          SpecHelper.metadataSpecs.call this,
            expectedPosition: ->
              top: parseFloat(@$draggable.css('top')) or 0
              left: parseFloat(@$draggable.css('left')) or 0
            expectedOffset: -> @$draggable.offset()
            expectedHelper: -> @$draggable
            expectedDraggable: -> @$draggable.data('draggable')

    describe 'such as an out callback', ->

      beforeEach ->
        loadFixtures 'droppable.html'
        @$droppable = $('#droppable').droppable(out: @callback)

      describe 'having had a draggable come to hover above it', ->

        beforeEach ->
          appendLoadFixtures 'draggable_static.html'
          @$draggable = $('#draggable_static').draggable()

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

        describe 'then having had that draggable leave its bounds', ->

          beforeEach ->
            droppableTopCorner = @$droppable.offset()

            # Move the mouse back in the next run loop
            $(document).simulate 'mousemove',
              clientX: droppableTopCorner.left - 1
              clientY: droppableTopCorner.top - 1
            @$droppable.simulate 'mouseout',
              clientX: droppableTopCorner.left - 1
              clientY: droppableTopCorner.top - 1

          it 'should call the out callback once', ->
            expect(@callback.callCount).toBe(1)

          it 'should call the out callback with the jQuery mouse event as the first parameter', ->
            expect(@callback).toHaveBeenCalledWith(jasmine.any(jQuery.Event))

    describe 'such as a drop callback', ->

      beforeEach ->
        loadFixtures 'droppable.html'
        @$droppable = $('#droppable').droppable(drop: @callback)

      describe 'having had a draggable dropped on it', ->

        beforeEach ->
          appendLoadFixtures 'draggable_static.html'
          @$draggable = $('#draggable_static').draggable()

          # Find the center of the elements
          draggableCenter = SpecHelper.findCenterOf @$draggable
          droppableCenter = SpecHelper.findCenterOf @$droppable

          # Drop the draggable on the droppable
          @$draggable.simulate 'mousedown',
            clientX: draggableCenter.x
            clientY: draggableCenter.y
          $(document).simulate 'mousemove',
            clientX: droppableCenter.x
            clientY: droppableCenter.y
          @$draggable.simulate 'mouseup',
            clientX: droppableCenter.x
            clientY: droppableCenter.y
          @$draggable.simulate 'click',
            clientX: droppableCenter.x
            clientY: droppableCenter.y

        it 'should call the drop callback once', ->
          expect(@callback.callCount).toBe(1)

        it 'should call the drop callback with the jQuery mouse event as the first parameter', ->
          expect(@callback).toHaveBeenCalledWith(jasmine.any(jQuery.Event))
