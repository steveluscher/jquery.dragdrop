describe 'A droppable', ->
  options =
    alternateHoverClass: 'alternateHoverClass'
    acceptableClass: 'acceptable'

  options.acceptConfigVariants =
    'a string representing a selector': ".#{options.acceptableClass}"
    'an acceptance function': jasmine.createSpy('acceptanceFunction').andCallFake ($draggable) -> $draggable.is(".#{options.acceptableClass}")

  describe 'configured using the default options', ->

    beforeEach ->
      loadFixtures 'droppable_absolute.html'
      @$droppable = $('#droppable_absolute').droppable()

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
      loadFixtures 'droppable_absolute.html'
      @$droppable = $('#droppable_absolute').droppable(hoverClass: options.alternateHoverClass)

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

  describe 'configured with the accept option', ->

    for variant, acceptConfig of options.acceptConfigVariants
      do (variant, acceptConfig) ->

        describe "such as #{variant}", ->

          beforeEach ->
            loadFixtures 'droppable_absolute.html'
            @$droppable = $('#droppable_absolute').droppable(accept: acceptConfig)

          describe 'with an acceptable draggable hovering above it', ->

            beforeEach ->
              appendLoadFixtures 'draggable_static.html'
              @$draggable = $('#draggable_static').addClass(options.acceptableClass).draggable()

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

            if typeof acceptConfig is 'function'
              it 'should call the acceptance function with the draggable as its first argument', ->
                expect(acceptConfig.mostRecentCall.args[0]).toBe(@$draggable)

            it 'should possess the default hover class', ->
              expect(@$droppable).toHaveClass $.droppable::defaults['hoverClass']

          describe 'with an unacceptable draggable hovering above it', ->

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

            it 'should not possess the default hover class', ->
              expect(@$droppable).not.toHaveClass $.droppable::defaults['hoverClass']

  describe 'configured with callbacks', ->

    beforeEach ->
      # Craft a callback that stores the value of "this" somewhere we can analyze it later on
      self = this
      @callback = jasmine.createSpy('callback').andCallFake -> self.valueOfThis = this

    describe 'such as an over callback', ->

      beforeEach ->
        loadFixtures 'droppable_absolute.html'
        @$droppable = $('#droppable_absolute').droppable(over: @callback)

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

          it 'should have been bound to the droppable’s plugin instance', ->
            expect(@valueOfThis).toBe(@$droppable.data('droppable'))

        describe 'the second parameter to the over callback', ->

          SpecHelper.metadataSpecs.call this,
            expectedPosition: ->
              top: parseFloat(@$draggable.css('top')) or 0
              left: parseFloat(@$draggable.css('left')) or 0
            expectedOffset: -> @$draggable.offset()
            expectedHelper: -> @$draggable
            expectedDraggable: -> @$draggable

    describe 'such as an out callback', ->

      beforeEach ->
        loadFixtures 'droppable_absolute.html'
        @$droppable = $('#droppable_absolute').droppable(out: @callback)

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

          describe 'the out callback', ->

            it 'should have been called once', ->
              expect(@callback.callCount).toBe(1)

            it 'should have been called with the jQuery mouse event as the first parameter', ->
              expect(@callback).toHaveBeenCalledWith(jasmine.any(jQuery.Event))

            it 'should have been bound to the droppable’s plugin instance', ->
              expect(@valueOfThis).toBe(@$droppable.data('droppable'))

    describe 'such as a drop callback', ->

      beforeEach ->
        loadFixtures 'droppable_absolute.html'
        @$droppable = $('#droppable_absolute').droppable(drop: @callback)

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

        describe 'the drop callback', ->
          it 'should have been called once', ->
            expect(@callback.callCount).toBe(1)

          it 'should have been called with the jQuery mouse event as the first parameter, and an object as the second parameter', ->
            expect(@callback).toHaveBeenCalledWith(jasmine.any(jQuery.Event), jasmine.any(Object))

          it 'should have been bound to the droppable’s plugin instance', ->
            expect(@valueOfThis).toBe(@$droppable.data('droppable'))

        describe 'the second parameter to the drop callback', ->

          SpecHelper.metadataSpecs.call this,
            expectedPosition: ->
              top: parseFloat(@$draggable.css('top')) or 0
              left: parseFloat(@$draggable.css('left')) or 0
            expectedOffset: -> @$draggable.offset()
            expectedHelper: -> @$draggable
            expectedDraggable: -> @$draggable

describe 'Nested droppables', ->

  beforeEach ->
    # Load two nested droppables
    loadFixtures 'droppable_nested.html'

    @$parentDroppable = $('#droppable_nested_parent').droppable()
    @$childDroppable = $('#droppable_nested_child').droppable()

  describe 'having had a draggable come to hover above the child droppable', ->

    beforeEach ->
      appendLoadFixtures 'draggable_absolute.html'
      @$draggable = $('#draggable_absolute').draggable()

      # Find the center of the elements
      draggableCenter = SpecHelper.findCenterOf @$draggable
      childDroppableCenter = SpecHelper.findCenterOf @$childDroppable

      # Drag the draggable over top of the child droppable
      @$draggable.simulate 'mousedown',
        clientX: draggableCenter.x
        clientY: draggableCenter.y
      $(document).simulate 'mousemove',
        clientX: childDroppableCenter.x
        clientY: childDroppableCenter.y

    describe 'the parent droppable', ->

      it 'should not possess the default hover class', ->
        expect(@$parentDroppable).not.toHaveClass $.droppable::defaults['hoverClass']

    describe 'the child droppable', ->

      it 'should possess the default hover class', ->
        expect(@$childDroppable).toHaveClass $.droppable::defaults['hoverClass']
