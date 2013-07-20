describe 'A draggable', ->
  options =
    dragDistance: 50
    alternateDraggableClass: 'alternateDraggableClass'
    alternateDraggingClass: 'alternateDraggingClass'
    ineffectualButtons:
      'middle': jQuery.simulate.buttonCode.MIDDLE
      'right': jQuery.simulate.buttonCode.RIGHT
    scrollOffsetVariants:
      'no': 0
      'a non-zero': 50
    handleConfigVariants:
      'selector': -> '#handle'
      'DOM element': -> $('#handle').get(0)
      'jQuery object': -> $('#handle')
    helperConfigVariants:
      'clone': 'clone'
      'a factory method that produces something DOM-element-like': jasmine.createSpy('helperFactory').andReturn($('<div>').text('I’m a helper'))
    elementPositionVariants: ['static', 'absolute', 'fixed']
    getTransformCSS: (scale, skew, rotate, translate, originXPercent = 1, originYPercent = 1) ->
      originString = "#{originXPercent * 100}% #{originYPercent * 100}%"
      transformString = "rotate(#{rotate}deg) scale(#{scale}) skew(#{skew}deg) translate(#{translate}px)"
      {
        'transform-origin': originString
        '-webkit-transform-origin': originString
        '-moz-transform-origin': originString
        '-o-transform-origin': originString
        '-ms-transform-origin': originString

        'transform': transformString
        '-webkit-transform': transformString
        '-moz-transform': transformString
        '-o-transform': transformString
        '-ms-transform': transformString
      }

  describe 'configured using the default options', ->

    beforeEach ->
      loadFixtures 'draggable_static.html'
      @$draggable = $('#draggable_static').draggable()

    it 'should possess the default draggable class', ->
      expect(@$draggable).toHaveClass $.draggable::defaults['draggableClass']

  describe 'configured using the draggableClass option', ->

    beforeEach ->
      loadFixtures 'draggable_static.html'
      @$draggable = $('#draggable_static').draggable(draggableClass: options.alternateDraggableClass)

    it 'should possess the supplied draggable class', ->
      expect(@$draggable).toHaveClass options.alternateDraggableClass

  describe 'configured using the draggingClass option', ->

    beforeEach ->
      loadFixtures 'draggable_static.html'
      @$draggable = $('#draggable_static').draggable(draggingClass: options.alternateDraggingClass)

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

      describe 'that returns false', ->

        beforeEach ->
          @callback.andReturn(false)

          loadFixtures 'draggable_static.html'
          @$draggable = $('#draggable_static').draggable(start: @callback)

        describe 'when dragged', ->

          beforeEach ->
            @originalOffset = @$draggable.offset()

            # Drag the draggable a standard distance
            @$draggable.simulate 'drag',
              dx: options.dragDistance
              dy: options.dragDistance

          it 'should find itself at its original top offset', ->
            expect(@$draggable.offset().top).toBe(@originalOffset.top)

          it 'should find itself at its original left offset', ->
            expect(@$draggable.offset().left).toBe(@originalOffset.left)

      describe 'that does not return false', ->

        beforeEach ->
          loadFixtures 'draggable_static.html'
          @$draggable = $('#draggable_static').draggable(start: @callback)

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
            @originalPosition =
              top: parseFloat(@$draggable.css('top')) or 0
              left: parseFloat(@$draggable.css('left')) or 0

            # Drag the draggable a standard distance
            @$draggable.simulate 'drag',
              dx: options.dragDistance
              dy: options.dragDistance

          describe 'the start callback', ->

            it 'should have been called once', ->
              expect(@callback.callCount).toBe(1)

            it 'should have been called with the jQuery mouse event as the first parameter, and an object as the second parameter', ->
              expect(@callback).toHaveBeenCalledWith(jasmine.any(jQuery.Event), jasmine.any(Object))

          describe 'the second parameter to the start callback', ->

            SpecHelper.metadataSpecs.call this,
              expectedPosition: -> @originalPosition

    describe 'such as a drag callback', ->

      describe 'that returns false', ->

        beforeEach ->
          @callback.andReturn(false)

          loadFixtures 'draggable_static.html'
          @$draggable = $('#draggable_static').draggable(drag: @callback)

        describe 'when dragged', ->

          beforeEach ->
            @originalOffset = @$draggable.offset()

            # Drag the draggable a standard distance
            @$draggable.simulate 'drag',
              moves: 2
              dx: options.dragDistance
              dy: options.dragDistance

          it 'should find itself at its original top offset', ->
            expect(@$draggable.offset().top).toBe(@originalOffset.top)

          it 'should find itself at its original left offset', ->
            expect(@$draggable.offset().left).toBe(@originalOffset.left)

          describe 'the drag callback', ->

            it 'should have been called once', ->
              expect(@callback.callCount).toBe(1)

      describe 'that does not return false', ->

        beforeEach ->
          loadFixtures 'draggable_static.html'
          @$draggable = $('#draggable_static').draggable(drag: @callback)

        describe 'when dragged', ->

          beforeEach ->
            @moves = 10

            # Drag the draggable a standard distance
            @$draggable.simulate 'drag',
              moves: @moves
              dx: options.dragDistance
              dy: options.dragDistance

          describe 'the drag callback', ->

            it 'should have been called once for every mouse movement', ->
              expect(@callback.callCount).toBe(@moves)

            it 'should have been called with the jQuery mouse event as the first parameter, and an object as the second parameter', ->
              expect(@callback).toHaveBeenCalledWith(jasmine.any(jQuery.Event), jasmine.any(Object))

          describe 'the second parameter to the drag callback', ->

            SpecHelper.metadataSpecs.call this,
              expectedPosition: ->
                top: parseFloat(@$draggable.css('top')) or 0
                left: parseFloat(@$draggable.css('left')) or 0

    describe 'such as a stop callback', ->

      beforeEach ->
        loadFixtures 'draggable_static.html'
        @$draggable = $('#draggable_static').draggable(stop: @callback)

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

        describe 'the stop callback', ->

          it 'should have been called once', ->
            expect(@callback.callCount).toBe(1)

          it 'should have been called with the jQuery mouse event as the first parameter, and an object as the second parameter', ->
            expect(@callback).toHaveBeenCalledWith(jasmine.any(jQuery.Event), jasmine.any(Object))

        describe 'the second parameter to the stop callback', ->

          SpecHelper.metadataSpecs.call this,
            expectedPosition: ->
              top: parseFloat(@$draggable.css('top')) or 0
              left: parseFloat(@$draggable.css('left')) or 0

  for variant, getHandleConfig of options.handleConfigVariants
    do (variant, getHandleConfig) ->

      describe "configured with a #{variant} as a drag handle", ->

        beforeEach ->
          loadFixtures 'draggable_with_handle.html'

          # Get the handle config, and the handle itself
          @handleConfig = getHandleConfig()
          @handle = $(@handleConfig)

          @$draggable = $('#draggable_static').draggable(handle: @handleConfig)

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
        loadFixtures 'draggable_static.html'
        @$draggable = $('#draggable_static').draggable(helper: -> 'Nothing that quacks like a DOM element')

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
            loadFixtures 'draggable_static.html'
            @$draggable = $('#draggable_static').draggable(helper: helperConfig)

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

            describe 'the helper', ->

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
      loadFixtures 'draggable_static.html'
      @$draggable = $('#draggable_static').draggable()
      @originalOffset = @$draggable.offset()

    describe 'when mousedown’d upon', ->

      for buttonName, buttonCode of options.ineffectualButtons
        do (buttonName, buttonCode) ->

          describe "using the #{buttonName} button", ->

            beforeEach ->
              spyOnEvent @$draggable, 'mousedown'
              @center = SpecHelper.mouseDownInCenterOf @$draggable, { button: buttonCode }

            it 'should not capture the mousedown event', ->
              expect('mousedown').not.toHaveBeenPreventedOn(@$draggable)

            describe 'then moved', ->

              beforeEach ->
                # Move it by the prescribed amount, without lifting the mouse button
                $(document).simulate 'mousemove',
                  clientX: @center.x + options.dragDistance
                  clientY: @center.y + options.dragDistance

              it 'should not possess the default dragging class', ->
                expect(@$draggable).not.toHaveClass $.draggable::defaults['draggingClass']

              describe 'then having been released', ->

                beforeEach ->
                  spyOnEvent @$draggable, 'mouseup'
                  spyOnEvent @$draggable, 'click'

                  @$draggable.simulate 'mouseup',
                    clientX: @center.x + options.dragDistance
                    clientY: @center.y + options.dragDistance
                  @$draggable.simulate 'click',
                    clientX: @center.x + options.dragDistance
                    clientY: @center.y + options.dragDistance

                it 'should not possess the default dragging class', ->
                  expect(@$draggable).not.toHaveClass $.draggable::defaults['draggingClass']

                it 'should find itself at its original top offset', ->
                  expect(@$draggable.offset().top).toBe(@originalOffset.top)

                it 'should find itself at its original left offset', ->
                  expect(@$draggable.offset().left).toBe(@originalOffset.left)

      describe 'using the left button', ->
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
      loadFixtures 'draggable_static.html'
      @$draggable = $('#draggable_static').draggable()

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

  describe 'of the absolutely positioned sort', ->

    beforeEach ->
      loadFixtures 'draggable_absolute.html'
      @$draggable = $('#draggable_absolute').draggable()

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

  describe 'of the fixedly positioned sort', ->

    beforeEach ->
      loadFixtures 'draggable_fixed.html'
      @$draggable = $('#draggable_fixed').draggable()

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

    describe 'in a document with a non-zero scroll offset', ->

      beforeEach ->
        @oldScrollLeft = $(window).scrollLeft()
        @oldScrollTop = $(window).scrollTop()

        @spacer = $ '<p style="height: ' + ($(window).height() + 100) + 'px; width: ' + ($(window).width() + 100) + 'px;">'

        $('body')
          # Make sure that the body is larger than the viewport
          .append(@spacer)
        $(window)
          # Scroll the window
          .scrollLeft(@oldScrollLeft + 50)
          .scrollTop(@oldScrollTop + 50)

      afterEach ->
        # Remove the spacer
        @spacer.remove()

        # Restore the scroll position
        $(window)
          .scrollLeft(@oldScrollLeft)
          .scrollTop(@oldScrollTop)

      describe 'after having been dragged', ->

        beforeEach ->
          @originalOffset = @$draggable.offset()

          # Drag the draggable a standard distance
          @$draggable.simulate 'drag',
            dx: options.dragDistance
            dy: options.dragDistance

        it 'should find itself the drag distance from its original top offset', ->
          expect(@$draggable.offset().top).toBe(@originalOffset.top + options.dragDistance)

        it 'should find itself the drag distance from its original left offset', ->
          expect(@$draggable.offset().left).toBe(@originalOffset.left + options.dragDistance)

  for positionVariant in options.elementPositionVariants
    do (positionVariant) ->

      describe "of the #{positionVariant}#{if positionVariant is 'static' then 'al' else ''}ly positioned sort", ->

        beforeEach ->
          loadFixtures "draggable_#{positionVariant}.html"
          @$draggable = $("#draggable_#{positionVariant}").draggable()

        describe 'when clicked on', ->

          beforeEach ->
            spyOnEvent @$draggable, 'mousedown'
            SpecHelper.mouseDownInCenterOf @$draggable

          it "should be positioned #{positionVariant}#{if positionVariant is 'static' then 'al' else ''}ly", ->
            expect(@$draggable).toHaveCss { position: positionVariant }

        describe 'after having been dragged', ->

          beforeEach ->
            @originalOffset = @$draggable.offset()

            # Drag the draggable a standard distance
            @$draggable.simulate 'drag',
              dx: options.dragDistance
              dy: options.dragDistance

          it 'should find itself the drag distance from its original top offset', ->
            expect(@$draggable.offset().top).toBe(@originalOffset.top + options.dragDistance)

          it 'should find itself the drag distance from its original left offset', ->
            expect(@$draggable.offset().left).toBe(@originalOffset.left + options.dragDistance)

        for scrollVariant, scrollOffset of options.scrollOffsetVariants
          do (scrollVariant, scrollOffset) ->

            describe 'in a container with #{scrollVariant} scroll offset', ->

              beforeEach ->
                $('#jasmine-fixtures')
                  # Make sure that something inside the test area is larger than the test area itself
                  .append('<p style="height: 500px; width: 500px;">')
                  .css
                    width: 400
                    height: 400
                    # Make sure the transformed element is scrollable
                    overflow: 'auto'
                  # Scroll the transformed element
                  .scrollLeft(scrollOffset)
                  .scrollTop(scrollOffset)

              describe 'after having been dragged', ->

                beforeEach ->
                  @originalOffset = @$draggable.offset()

                  # Drag the draggable a standard distance
                  @$draggable.simulate 'drag',
                    dx: options.dragDistance
                    dy: options.dragDistance

                it 'should find itself the drag distance from its original top offset', ->
                  expect(@$draggable.offset().top).toBeCloseTo(@originalOffset.top + options.dragDistance, 0)

                it 'should find itself the drag distance from its original left offset', ->
                  expect(@$draggable.offset().left).toBeCloseTo(@originalOffset.left + options.dragDistance, 0)

              describe 'in a transformed coordinate space', ->

                beforeEach ->
                  # Same values as the .funhouse declaration in spec.css
                  scale = 0.45
                  rotate = 10
                  skew = 20
                  translate = 100
                  originXPercent = 20
                  originYPercent = 40

                  # Apply scale, skew, translate, and rotate, with a non-default transform-origin
                  $('#jasmine-fixtures').css options.getTransformCSS(scale, skew, rotate, translate, originXPercent, originYPercent)

                describe 'after having been dragged', ->

                 beforeEach ->
                   @originalOffset = @$draggable.offset()
                   # Drag the draggable a standard distance
                   @$draggable.simulate 'drag',
                     dx: options.dragDistance
                     dy: options.dragDistance

                 it 'should find itself the drag distance from its original top offset', ->
                   expect(@$draggable.offset().top).toBeCloseTo(@originalOffset.top + options.dragDistance, 0)

                 it 'should find itself the drag distance from its original left offset', ->
                   expect(@$draggable.offset().left).toBeCloseTo(@originalOffset.left + options.dragDistance, 0)
