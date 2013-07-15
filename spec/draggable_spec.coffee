describe 'A draggable', ->
  options =
    dragDistance: 50
    alternateDraggableClass: 'alternateDraggableClass'
    alternateDraggingClass: 'alternateDraggingClass'
    handleConfigVariants:
      'selector': -> '#handle'
      'DOM element': -> $('#handle').get(0)
      'jQuery object': -> $('#handle')
    helperConfigVariants:
      'clone': 'clone'
      'a factory method that produces something DOM-element-like': jasmine.createSpy('helperFactory').andReturn($('<div>').text('I’m a helper'))

  describe 'configured using the default options', ->

    beforeEach ->
      loadFixtures 'draggable.html'
      @$draggable = $('#draggable').draggable()

    it 'should possess the default draggable class', ->
      expect(@$draggable).toHaveClass $.draggable::defaults['draggableClass']

  describe 'configured using the draggableClass option', ->

    beforeEach ->
      loadFixtures 'draggable.html'
      @$draggable = $('#draggable').draggable(draggableClass: options.alternateDraggableClass)

    it 'should possess the supplied draggable class', ->
      expect(@$draggable).toHaveClass options.alternateDraggableClass

  describe 'configured using the draggingClass option', ->

    beforeEach ->
      loadFixtures 'draggable.html'
      @$draggable = $('#draggable').draggable(draggingClass: options.alternateDraggingClass)

    describe 'while in mid-drag', ->

      beforeEach ->
        center = SpecHelper.mouseDownInCenterOf @$draggable

        # Move it by the prescribed amount, without lifting the mouse button
        $(document).simulate 'mousemove',
          clientX: center.x + options.dragDistance
          clientY: center.y + options.dragDistance

      it 'should possess the supplied dragging class', ->
        expect(@$draggable).toHaveClass options.alternateDraggingClass

  describe 'configured with callbacks', ->

    beforeEach ->
      @callback = jasmine.createSpy('callback')

    describe 'such as a start callback', ->

      beforeEach ->
        loadFixtures 'draggable.html'
        @$draggable = $('#draggable').draggable(start: @callback)

      describe 'when clicked without having been dragged', ->

        beforeEach ->
          # Click the draggable, but don't move it
          @$draggable
            .simulate('mousedown')
            .simulate('mouseup')
            .simulate('click')

        it 'should not call the start callback', ->
          expect(@callback).not.toHaveBeenCalled()

      describe 'when dragged', ->

        beforeEach ->
          # Drag the draggable a standard distance
          @$draggable.simulate 'drag',
            dx: options.dragDistance
            dy: options.dragDistance

        it 'should call the start callback', ->
          expect(@callback).toHaveBeenCalled()

        it 'should call the start callback with the jQuery mouse event as the first parameter', ->
          expect(@callback).toHaveBeenCalledWith(jasmine.any(jQuery.Event))

    describe 'such as a drag callback', ->

      beforeEach ->
        loadFixtures 'draggable.html'
        @$draggable = $('#draggable').draggable(drag: @callback)

      describe 'when dragged', ->

        beforeEach ->
          # Drag the draggable a standard distance
          @$draggable.simulate 'drag',
            moves: 10
            dx: options.dragDistance
            dy: options.dragDistance

        it 'should call the drag callback once for every mouse movement', ->
          expect(@callback.callCount).toBe(10)

        it 'should call the drag callback with the jQuery mouse event as the first parameter', ->
          expect(@callback).toHaveBeenCalledWith(jasmine.any(jQuery.Event))

    describe 'such as a stop callback', ->

      beforeEach ->
        loadFixtures 'draggable.html'
        @$draggable = $('#draggable').draggable(stop: @callback)

      describe 'when clicked without having been dragged', ->

        beforeEach ->
          # Click the draggable, but don't move it
          @$draggable
            .simulate('mousedown')
            .simulate('mouseup')
            .simulate('click')

        it 'should not call the stop callback', ->
          expect(@callback).not.toHaveBeenCalled()

      describe 'after having been dragged', ->

        beforeEach ->
          # Drag the draggable a standard distance
          @$draggable.simulate 'drag',
            dx: options.dragDistance
            dy: options.dragDistance

        it 'should call the stop callback', ->
          expect(@callback).toHaveBeenCalled()

        it 'should call the stop callback with the jQuery mouse event as the first parameter', ->
          expect(@callback).toHaveBeenCalledWith(jasmine.any(jQuery.Event))

  for variant, getHandleConfig of options.handleConfigVariants
    do (variant, getHandleConfig) ->

      describe "configured with a #{variant} as a drag handle", ->

        beforeEach ->
          loadFixtures 'draggable_with_handle.html'

          # Get the handle config, and the handle itself
          @handleConfig = getHandleConfig()
          @handle = $(@handleConfig)

          @$draggable = $('#draggable').draggable(handle: @handleConfig)

        describe 'after having been dragged by its handle', ->

          beforeEach ->
            # The draggable's start position
            @start = @$draggable.offset()

            # Drag the draggable a standard distance, using the handle
            @handle.simulate 'drag',
              dx: options.dragDistance
              dy: options.dragDistance

            # The draggable's end position
            @end = @$draggable.offset()

          it 'should have triggered a drag', ->
            expect(@end.top - @start.top).toBe(options.dragDistance)
            expect(@end.left - @start.left).toBe(options.dragDistance)

        describe 'after having been dragged by a descendant of its handle', ->

          beforeEach ->
            # The draggable's start position
            @start = @$draggable.offset()

            # Drag the draggable a standard distance, using the handle
            @handle.children().simulate 'drag',
              dx: options.dragDistance
              dy: options.dragDistance

            # The draggable's end position
            @end = @$draggable.offset()

          it 'should have triggered a drag', ->
            expect(@end.top - @start.top).toBe(options.dragDistance)
            expect(@end.left - @start.left).toBe(options.dragDistance)

        describe 'after having been dragged by something other than its handle', ->

          beforeEach ->
            # The draggable's start position
            @start = @$draggable.offset()

            # Drag the draggable a standard distance, using the handle
            @$draggable.simulate 'drag',
              dx: options.dragDistance
              dy: options.dragDistance

            # The draggable's end position
            @end = @$draggable.offset()

          it 'should not have triggered a drag', ->
            expect(@end.top - @start.top).toBe(0)
            expect(@end.left - @start.left).toBe(0)

        describe 'after having something other than its handle clicked without having been dragged', ->

          beforeEach ->
            # Spy on clicks made on the draggable
            spyOnEvent(@$draggable, 'click')

            # Click the draggable, but don't move it
            @$draggable
              .simulate('mousedown')
              .simulate('mouseup')
              .simulate('click')

          it 'should receive the click event', ->
            expect('click').toHaveBeenTriggeredOn(@$draggable)

  describe 'configured with a helper', ->

    describe 'such as a factory method that doesn’t produce anything DOM-element-like', ->

      beforeEach ->
        loadFixtures 'draggable.html'
        @$draggable = $('#draggable').draggable(helper: -> 'Nothing that quacks like a DOM element')

      describe 'when dragged', ->

        beforeEach ->
          # Drag the draggable a standard distance
          @$draggable.simulate 'drag',
            moves: 1
            dx: options.dragDistance
            dy: options.dragDistance

        # TODO: Figure out how to catch this exception using Jasmine
        # it 'should result in an exception', ->
          # Error: [jQuery DragDrop – Draggable] Helper factory methods must produce a jQuery object, a DOM Element, or a string of HTML

    for variant, helperConfig of options.helperConfigVariants
      do (variant, helperConfig) ->

        describe "such as #{variant}", ->

          beforeEach ->
            loadFixtures 'draggable.html'
            @$draggable = $('#draggable').draggable(helper: helperConfig)

          describe 'while in mid-drag', ->

            beforeEach ->
              # Spy on jQuery.append()
              @append = spyOn(jQuery.fn, 'append').andCallThrough()

              # Record the start position of the draggable
              @originalOffset = @$draggable.offset()

              center = SpecHelper.mouseDownInCenterOf @$draggable

              # Move it by the prescribed amount, without lifting the mouse button
              $(document).simulate 'mousemove',
                clientX: center.x + options.dragDistance
                clientY: center.y + options.dragDistance

              # What was appended?
              @appendedElement = $(@append.mostRecentCall.args?[0])
              @appendedElementHTML = @appendedElement.get(0)?.outerHTML

              # To what?
              @appendReceiver = @append.mostRecentCall.object

            it 'should not possess the default dragging class', ->
              expect(@$draggable).not.toHaveClass $.draggable::defaults['draggingClass']

            if typeof helperConfig is 'function'
              describe 'the helper-factory function', ->
                it 'should be called with the draggable and the event as arguments', ->
                  expect(helperConfig).toHaveBeenCalledWith(@$draggable.get(0), jasmine.any(jQuery.Event))

            describe 'the helper', =>

              it 'should be positioned absolutely', ->
                expect(@appendedElement).toHaveCss { position: 'absolute' }

              it 'should have no id', ->
                expect(@appendedElement).not.toHaveAttr('id')

              it 'should have been appended to the body', ->
                expect(@appendReceiver).toBe('body')

              it 'should possess the default dragging class', ->
                expect(@appendedElement).toHaveClass $.draggable::defaults['draggingClass']

              it 'should find itself the drag distance from the draggable‘s original top offset', ->
                expect(@appendedElement.offset().top).toBe(@originalOffset.top + options.dragDistance)

              it 'should find itself the drag distance from the draggable‘s original left offset', ->
                expect(@appendedElement.offset().left).toBe(@originalOffset.left + options.dragDistance)

              if helperConfig is 'clone'
                it 'should contain a copy of the original element‘s contents', ->
                  expect(@appendedElement.html()).toBe(@$draggable.clone().html())

              if typeof helperConfig is 'function'
                it 'should contain the output of the helper factory', ->
                  factoryOutput = helperConfig(@$draggable.get(0), jQuery.simulate::mouseEvent('mousemove'))
                  expect(@appendedElement.html()).toBe(factoryOutput.html())

          describe 'after having been dragged', ->

            beforeEach ->
              # Spy on jQuery.append()
              @append = spyOn(jQuery.fn, 'append').andCallThrough()

              # Spy on jQuery.remove()
              @remove = spyOn(jQuery.fn, 'remove').andCallThrough()

              # Drag the draggable a standard distance
              @$draggable.simulate 'drag',
                dx: options.dragDistance
                dy: options.dragDistance

              # What was appended?
              @appendedElement = $(@append.mostRecentCall.args?[0])

              # What was removed?
              @removedElement = @remove.mostRecentCall.object

            describe 'the helper', ->

              it 'should have been removed', ->
                expect(@remove).toHaveBeenCalled()
                expect(@removedElement).toBe(@appendedElement)

  describe 'of any sort', ->

    beforeEach ->
      loadFixtures 'draggable.html'
      @$draggable = $('#draggable').draggable()
      @originalOffset = @$draggable.offset()

    describe 'when mousedown’d upon', ->

      beforeEach ->
        spyOnEvent @$draggable, 'mousedown'
        @center = SpecHelper.mouseDownInCenterOf @$draggable

      it 'should not possess the default dragging class', ->
        expect(@$draggable).not.toHaveClass $.draggable::defaults['draggingClass']

      it 'should capture the mousedown event', ->
        expect('mousedown').toHaveBeenPreventedOn(@$draggable)

      describe 'then moved', ->

        beforeEach ->
          # Move it by the prescribed amount, without lifting the mouse button
          $(document).simulate 'mousemove',
            clientX: @center.x + options.dragDistance
            clientY: @center.y + options.dragDistance

        it 'should possess the default dragging class', ->
          expect(@$draggable).toHaveClass $.draggable::defaults['draggingClass']

        describe 'then having been released', ->

          beforeEach ->
            spyOnEvent @$draggable, 'mouseup'

            @$draggable.simulate 'mouseup',
              clientX: @center.x + options.dragDistance
              clientY: @center.y + options.dragDistance

          describe 'inside the browser window', ->

            beforeEach ->
              spyOnEvent @$draggable, 'click'

              @$draggable.simulate 'click',
                clientX: @center.x + options.dragDistance
                clientY: @center.y + options.dragDistance

            it 'should not possess the default dragging class', ->
              expect(@$draggable).not.toHaveClass $.draggable::defaults['draggingClass']

            it 'should not receive the click event', ->
              expect('click').not.toHaveBeenTriggeredOn(@$draggable)

          describe 'outside the browser window', ->

            # Draggables don't receive the click event when they are released outside the browser window.

            describe 'then having been dragged back to its initial position', ->

              beforeEach ->
                @$draggable.simulate 'drag',
                  dx: -options.dragDistance
                  dy: -options.dragDistance

              it 'should find itself at its original top offset', ->
                expect(@$draggable.offset().top).toBe(@originalOffset.top)

              it 'should find itself at its original left offset', ->
                expect(@$draggable.offset().left).toBe(@originalOffset.left)

    describe 'after having been dragged', ->

      beforeEach ->
        spyOnEvent @$draggable, 'click'

        # Drag the draggable a standard distance
        @$draggable.simulate 'drag',
          dx: options.dragDistance
          dy: options.dragDistance

      it 'should not possess the default dragging class', ->
        expect(@$draggable).not.toHaveClass $.draggable::defaults['draggingClass']

      it 'should not receive the click event', ->
        expect('click').not.toHaveBeenTriggeredOn(@$draggable)

  describe 'of the statically positioned sort', ->

    beforeEach ->
      loadFixtures 'draggable.html'
      @$draggable = $('#draggable').draggable()

    describe 'when clicked on', ->

      beforeEach ->
        spyOnEvent @$draggable, 'mousedown'
        SpecHelper.mouseDownInCenterOf @$draggable

      it 'should be positioned statically', ->
        expect(@$draggable).toHaveCss { position: 'static' }

    describe 'while in mid-drag', ->

      beforeEach ->
        center = SpecHelper.mouseDownInCenterOf @$draggable

        # Move it by the prescribed amount, without lifting the mouse button
        $(document).simulate 'mousemove',
          clientX: center.x + options.dragDistance
          clientY: center.y + options.dragDistance

      it 'should be positioned relatively', ->
        expect(@$draggable).toHaveCss { position: 'relative' }

    describe 'after having been dragged', ->

      beforeEach ->
        @originalOffset = @$draggable.offset()

        # Drag the draggable a standard distance
        @$draggable.simulate 'drag',
          dx: options.dragDistance
          dy: options.dragDistance

      it 'should be positioned relatively', ->
        expect(@$draggable).toHaveCss { position: 'relative' }

      it 'should find itself the drag distance from its original top offset', ->
        expect(@$draggable.offset().top).toBe(@originalOffset.top + options.dragDistance)

      it 'should find itself the drag distance from its original left offset', ->
        expect(@$draggable.offset().left).toBe(@originalOffset.left + options.dragDistance)

  describe 'of the absolutely positioned sort', ->

    beforeEach ->
      loadFixtures 'draggable_absolute.html'
      @$draggable = $('#draggable.absolute').draggable()

    describe 'when clicked on', ->

      beforeEach ->
        spyOnEvent @$draggable, 'mousedown'
        SpecHelper.mouseDownInCenterOf @$draggable

      it 'should be positioned absolutely', ->
        expect(@$draggable).toHaveCss { position: 'absolute' }

    describe 'while in mid-drag', ->

      beforeEach ->
        center = SpecHelper.mouseDownInCenterOf @$draggable

        # Move it by the prescribed amount, without lifting the mouse button
        $(document).simulate 'mousemove',
          clientX: center.x + options.dragDistance
          clientY: center.y + options.dragDistance

      it 'should be positioned absolutely', ->
        expect(@$draggable).toHaveCss { position: 'absolute' }

    describe 'after having been dragged', ->

      beforeEach ->
        @originalOffset = @$draggable.offset()

        # Drag the draggable a standard distance
        @$draggable.simulate 'drag',
          dx: options.dragDistance
          dy: options.dragDistance

      it 'should be positioned absolutely', ->
        expect(@$draggable).toHaveCss { position: 'absolute' }

      it 'should find itself the drag distance from its original top offset', ->
        expect(@$draggable.offset().top).toBe(@originalOffset.top + options.dragDistance)

      it 'should find itself the drag distance from its original left offset', ->
        expect(@$draggable.offset().left).toBe(@originalOffset.left + options.dragDistance)

  describe 'of the fixedly positioned sort', ->

    beforeEach ->
      loadFixtures 'draggable_fixed.html'
      @$draggable = $('#draggable.fixed').draggable()

    describe 'when clicked on', ->

      beforeEach ->
        spyOnEvent @$draggable, 'mousedown'
        SpecHelper.mouseDownInCenterOf @$draggable

      it 'should be positioned fixedly', ->
        expect(@$draggable).toHaveCss { position: 'fixed' }

    describe 'while in mid-drag', ->

      beforeEach ->
        center = SpecHelper.mouseDownInCenterOf @$draggable

        # Move it by the prescribed amount, without lifting the mouse button
        $(document).simulate 'mousemove',
          clientX: center.x + options.dragDistance
          clientY: center.y + options.dragDistance

      it 'should be positioned fixedly', ->
        expect(@$draggable).toHaveCss { position: 'fixed' }

    describe 'after having been dragged', ->

      beforeEach ->
        @originalOffset = @$draggable.offset()

        # Drag the draggable a standard distance
        @$draggable.simulate 'drag',
          dx: options.dragDistance
          dy: options.dragDistance

      it 'should be positioned fixedly', ->
        expect(@$draggable).toHaveCss { position: 'fixed' }

      it 'should find itself the drag distance from its original top offset', ->
        expect(@$draggable.offset().top).toBe(@originalOffset.top + options.dragDistance)

      it 'should find itself the drag distance from its original left offset', ->
        expect(@$draggable.offset().left).toBe(@originalOffset.left + options.dragDistance)

