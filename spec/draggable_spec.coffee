options =
  dragDistance: 50
  alternateDraggableClass: 'alternateDraggableClass'
  alternateDraggingClass: 'alternateDraggingClass'
  stackMemberClass: 'stackMember'
  callbackTypes: ['start', 'drag', 'stop']
  ineffectualButtons:
    'middle': jQuery.simulate.buttonCode.MIDDLE
    'right': jQuery.simulate.buttonCode.RIGHT
  scrollOffsetVariants:
    'no': 0
    'a non-zero': 50
  distanceConfig:
    'distance': 10
  cursorAtConfigVariants:
    'single':
      left: { left: 5 }
      right: { right: 5 }
      top: { top: 5 }
      bottom: { bottom: 5 }
    'double':
      'top and left': { top: 5, left: 5 }
      'top and right': { top: 5, right: 5 }
      'bottom and right': { bottom: 5, right: 5 }
      'bottom and left': { bottom: 5, left: 5 }
    'competing':
      'left and right': { left: 5, right: 5 }
      'top and bottom': { top: 5, bottom: 5 }
  cursorAtConfigGrabPoints:
    'top-left': (draggable) ->
      left: draggable.offset().left
      top: draggable.offset().top
    'top-right': (draggable) ->
      left: draggable.offset().left + draggable.width()
      top: draggable.offset().top
    'bottom-right': (draggable) ->
      left: draggable.offset().left + draggable.width()
      top: draggable.offset().top + draggable.height()
    'bottom-left': (draggable) ->
      left: draggable.offset().left
      top: draggable.offset().top + draggable.height()
  cancelConfigVariants:
    'selector': -> '#cancelingAgent'
    'DOM element': -> $('#cancelingAgent').get(0)
    'jQuery object': -> $('#cancelingAgent')
  handleConfigVariants:
    'selector': -> '#handle'
    'DOM element': -> $('#handle').get(0)
    'jQuery object': -> $('#handle')
  helperConfigVariants:
    'clone': 'clone'
    'a factory method that produces something DOM-element-like': jasmine.createSpy('helperFactory').andReturn($(sandbox()).text('I’m a helper'))
  containmentConfigVariants:
    'an array of bounds':
      config: -> [50, 300, 250, 100] # [ top, right, bottom, left ]
      target: ->
        shim = $(sandbox()).css
          position: 'absolute'
          top: 50
          left: 100
          width: 200
          height: 200
        appendSetFixtures shim
        shim
    'the string ‘parent’':
      config: -> 'parent'
      target: ($draggable) ->
        target = $draggable.parent()
        appendSetFixtures target
        target
    'the string ‘document’':
      config: -> 'document'
      target: -> $(document.documentElement)
    'the string ‘window’':
      config: -> 'window'
      target: -> $(window)
    'a selector string':
      config: -> '#jasmine-fixtures'
      target: -> $('#jasmine-fixtures')
    'a DOM element':
      config: -> $('#jasmine-fixtures').get(0)
      target: -> $('#jasmine-fixtures')
    'a jQuery Object':
      config: -> $('#jasmine-fixtures')
      target: -> $('#jasmine-fixtures')
  absoluteAnchorEdges:
    'regular':
      fixtureType: 'absolute'
      horizontalEdge: 'left'
      verticalEdge: 'top'
    'opposite':
      fixtureType: 'oppositely_anchored_absolute'
      horizontalEdge: 'right'
      verticalEdge: 'bottom'
  elementPositionVariants: ['static', 'absolute', 'fixed']
  elementTransformednesses:
    'non-transformed': -> {}
    'transformed': -> options.getTransformCSS 0.45, 10, 20, 100, 20, 40
  elementPositionTypes:
    'explicitly': {}
    'implicitly':
      top: 'auto'
      left: 'auto'
  possibleActiveElementSelectors:
    'the body': 'body'
    'a text field': 'input[type="text"]'
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

options.stackConfigVariants =
  'a selector': ".#{options.stackMemberClass}"
  'a factory method that produces a collection of DOM elements': jasmine.createSpy('stackConfigFunction').andCallFake ($draggable, e) -> $(".#{options.stackMemberClass}").get()
  'a factory method that produces a jQuery collection': jasmine.createSpy('stackConfigFunction').andCallFake ($draggable, e) -> $(".#{options.stackMemberClass}")

describe 'A draggable', ->

  describe 'configured using the default options', ->

    beforeEach ->
      loadFixtures 'draggable_static.html'
      @$draggable = $('#draggable_static').draggable()

    it 'should possess the default draggable class', ->
      expect(@$draggable).toHaveClass $.draggable::defaults['draggableClass']

  describe 'configured using the distance option', ->

    beforeEach ->
      loadFixtures 'draggable_static.html'
      @$draggable = $('#draggable_static').draggable(options.distanceConfig)

    describe 'when dragged less than the drag distance threshold', ->

      beforeEach ->
        # Save the original position
        @originalPosition = @$draggable.offset()

        # Start at the top corner of the draggable
        center = SpecHelper.mouseDownInCenterOf @$draggable

        # Move it by less than the drag distance
        lessThanDistance = options.distanceConfig.distance - 0.1
        delta = Math.floor Math.sqrt((lessThanDistance*lessThanDistance) / 2)
        $(document).simulate 'mousemove',
          clientX: center.x + delta
          clientY: center.y + delta

      it 'should not have moved from original position', ->
        expect(@$draggable.offset()).toEqual @originalPosition

      it 'should not possess the default draggable class', ->
        expect(@$draggable).not.toHaveClass $.draggable::defaults['draggingClass']

    describe 'when dragged exactly or greater than the drag distance threshold', ->

      beforeEach ->
        # Save the original position
        @originalPosition = @$draggable.offset()

        # Start at the top corner of the draggable
        center = SpecHelper.mouseDownInCenterOf @$draggable

        # Move it by at least the drag distance
        distance = options.distanceConfig.distance
        @delta = Math.ceil Math.sqrt((distance*distance) / 2)
        $(document).simulate 'mousemove',
          clientX: center.x + @delta
          clientY: center.y + @delta

      it 'should have moved the drag distance from the original position', ->
        expectedPosition =
          left: @originalPosition.left + @delta
          top: @originalPosition.top + @delta

        expect(@$draggable.offset()).toEqual expectedPosition

      it 'should possess the default draggable class', ->
        expect(@$draggable).toHaveClass $.draggable::defaults['draggingClass']

  describe 'configured using the draggableClass option', ->

    beforeEach ->
      loadFixtures 'draggable_static.html'
      @$draggable = $('#draggable_static').draggable(draggableClass: options.alternateDraggableClass)

    it 'should possess the supplied draggable class', ->
      expect(@$draggable).toHaveClass options.alternateDraggableClass

  describe 'configured using a cursorAt option', ->
    for type, cursorAtConfigs of options.cursorAtConfigVariants
      do (type, cursorAtConfigs) ->

        describe "such as a #{type} edge one", ->

          for edge, cursorAtConfig of cursorAtConfigs
            do (edge, cursorAtConfig) ->

              describe "configured with a #{edge} edge", ->

                beforeEach ->
                  loadFixtures 'draggable_static.html'
                  @$draggable = $('#draggable_static').draggable(cursorAt: cursorAtConfig)

                describe 'while in mid-drag', ->

                  for grabPoint, getGrabPointOffset of options.cursorAtConfigGrabPoints
                    do (grabPoint, getGrabPointOffset) ->

                      describe "grabbed from the #{grabPoint}", ->

                        beforeEach ->
                          # Record the start position of the draggable
                          @originalOffset = @$draggable.offset()

                          # Where are we going to grab the thing from?
                          @grabPointOffset = getGrabPointOffset(@$draggable)

                          # Start at the top corner of the draggable
                          @$draggable.simulate 'mousedown',
                            clientX: @grabPointOffset.left
                            clientY: @grabPointOffset.top

                          # Move it by one pixel
                          $(document).simulate 'mousemove',
                            clientX: @grabPointOffset.left + 1
                            clientY: @grabPointOffset.top + 1

                          # Grab the helper
                          @$helper = @$draggable.data('draggable').$helper

                        it 'should find itself horizontally offset by the drag distance, minus the nearest horizontal anchor point', ->
                          if cursorAtConfig.left? or cursorAtConfig.right?
                            # Find the cursor's start position in node coordinates
                            cursorNodeOffset =
                              left: @grabPointOffset.left - @originalOffset.left
                              top: @grabPointOffset.top - @originalOffset.top

                            # Find the anchor's node offset
                            leftAnchorNodeOffset = cursorAtConfig.left
                            rightAnchorNodeOffset = @$helper.width() - cursorAtConfig.right if cursorAtConfig.right?

                            # Find the difference between the two
                            delta =
                              left: cursorNodeOffset.left - leftAnchorNodeOffset if leftAnchorNodeOffset?
                              right: cursorNodeOffset.left - rightAnchorNodeOffset if rightAnchorNodeOffset?

                            # Choose the nearest anchor edge
                            anchorTranslationDistance = if delta.left? and delta.right?
                              if Math.abs(delta.left) < Math.abs(delta.right)
                                delta.left
                              else
                                delta.right
                            else
                              delta.left or delta.right or cursorNodeOffset.left

                            expect(@$helper.offset().left).toBe(@originalOffset.left + 1 + anchorTranslationDistance)

                        it 'should find itself vertically offset by the drag distance, minus the nearest vertical anchor point', ->
                          if cursorAtConfig.top? or cursorAtConfig.bottom?
                            # Find the cursor's start position in node coordinates
                            cursorNodeOffset =
                              top: @grabPointOffset.top - @originalOffset.top
                              top: @grabPointOffset.top - @originalOffset.top

                            # Find the anchor's node offset
                            topAnchorNodeOffset = cursorAtConfig.top
                            bottomAnchorNodeOffset = @$helper.height() - cursorAtConfig.bottom if cursorAtConfig.bottom?

                            # Find the difference between the two
                            delta =
                              top: cursorNodeOffset.top - topAnchorNodeOffset if topAnchorNodeOffset?
                              bottom: cursorNodeOffset.top - bottomAnchorNodeOffset if bottomAnchorNodeOffset?

                            # Choose the nearest anchor edge
                            anchorTranslationDistance = if delta.top? and delta.bottom?
                              if Math.abs(delta.top) < Math.abs(delta.bottom)
                                delta.top
                              else
                                delta.bottom
                            else
                              delta.top or delta.bottom or cursorNodeOffset.top

                            expect(@$helper.offset().top).toBe(@originalOffset.top + 1 + anchorTranslationDistance)

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

    for callbackType in options.callbackTypes
      do (callbackType) ->

        describe "such as a #{callbackType} callback", ->

          beforeEach ->
            # Craft a callback that stores the value of "this" somewhere we can analyze it later on
            self = this
            @callback.andCallFake -> self.valueOfThis = this

          describe 'that does not return false', ->

            beforeEach ->
              loadFixtures 'draggable_static.html'
              config = {}
              config[callbackType] = @callback
              @$draggable = $('#draggable_static').draggable(config)

            describe 'when dragged', ->

              beforeEach ->
                @originalPosition =
                  top: parseFloat(@$draggable.css('top')) or 0
                  left: parseFloat(@$draggable.css('left')) or 0

                @originalOffset = @$draggable.offset()

                # Drag the draggable a standard distance
                @$draggable.simulate 'drag',
                  moves: 1
                  dx: options.dragDistance
                  dy: options.dragDistance

              describe "the #{callbackType} callback", ->

                it 'should have been called with a jQuery event as the first parameter, and an object as the second parameter', ->
                  expect(@callback).toHaveBeenCalledWith(jasmine.any(jQuery.Event), jasmine.any(Object))

                it 'should have been bound to the draggable’s plugin instance', ->
                  expect(@valueOfThis).toBe(@$draggable.data('draggable'))

    describe 'such as a start callback', ->

      describe 'that returns false', ->

        beforeEach ->
          @callback.andReturn(false)

          loadFixtures 'draggable_static.html'
          @$draggable = $('#draggable_static').draggable(start: @callback)

        describe 'when dragged', ->

          beforeEach ->
            @originalOffset = @$draggable.offset()

            # Watch the draggable for the dragstart event
            spyOnEvent @$draggable, 'dragstart'

            # Drag the draggable a standard distance
            @$draggable.simulate 'drag',
              dx: options.dragDistance
              dy: options.dragDistance

          it 'should find itself at its original top offset', ->
            expect(@$draggable.offset().top).toBe(@originalOffset.top)

          it 'should find itself at its original left offset', ->
            expect(@$draggable.offset().left).toBe(@originalOffset.left)

          it 'should not have the dragstart event fired upon it', ->
            expect('dragstart').not.toHaveBeenTriggeredOn(@$draggable)
            # TODO: When jQuery Jasmine supports the same spy attributes as do regular Jasmine spies (mostRecentCall.args, callCount, etc…) write specs for the metadata argument of this event

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

            @originalOffset = @$draggable.offset()

            # Drag the draggable a standard distance
            @$draggable.simulate 'drag',
              dx: options.dragDistance
              dy: options.dragDistance

          describe 'the start callback', ->

            it 'should have been called once', ->
              expect(@callback.callCount).toBe(1)

          describe 'the first argument to the start callback', ->

            SpecHelper.eventArgumentSpecs.call this,
              instanceType: -> 'draggable'
              callback: -> @callback
              expectedEvent: -> 'dragstart'
              expectedTarget: -> @$draggable.get(0)

          describe 'the second argument to the start callback', ->

            SpecHelper.metadataSpecs.call this,
              expectedOriginalPosition: -> @originalPosition
              expectedPosition: -> @originalPosition
              expectedOffset: -> @originalOffset

    describe 'such as a drag callback', ->

      describe 'that returns false', ->

        beforeEach ->
          @callback.andReturn(false)

          loadFixtures 'draggable_static.html'
          @$draggable = $('#draggable_static').draggable(drag: @callback)

        describe 'when dragged', ->

          beforeEach ->
            @originalOffset = @$draggable.offset()

            # Watch the draggable for the dragstart event
            spyOnEvent @$draggable, 'drag'

            # Drag the draggable a standard distance
            @$draggable.simulate 'drag',
              moves: 2
              dx: options.dragDistance
              dy: options.dragDistance

          it 'should find itself at its original top offset', ->
            expect(@$draggable.offset().top).toBe(@originalOffset.top)

          it 'should find itself at its original left offset', ->
            expect(@$draggable.offset().left).toBe(@originalOffset.left)

          it 'should not have the drag event fired upon it', ->
            expect('drag').not.toHaveBeenTriggeredOn(@$draggable)
            # TODO: When jQuery Jasmine supports the same spy attributes as do regular Jasmine spies (mostRecentCall.args, callCount, etc…) write specs for the metadata argument of this event

          describe 'the drag callback', ->

            it 'should have been called once', ->
              expect(@callback.callCount).toBe(1)

      describe 'that does not return false', ->

        beforeEach ->
          loadFixtures 'draggable_static.html'
          @$draggable = $('#draggable_static').draggable(drag: @callback)

        describe 'when dragged', ->

          beforeEach ->
            @originalPosition =
              top: parseFloat(@$draggable.css('top')) or 0
              left: parseFloat(@$draggable.css('left')) or 0

            @moves = 10

            # Drag the draggable a standard distance
            @$draggable.simulate 'drag',
              moves: @moves
              dx: options.dragDistance
              dy: options.dragDistance

          describe 'the drag callback', ->

            it 'should have been called once for every mouse movement', ->
              expect(@callback.callCount).toBe(@moves)

          describe 'the first argument to the drag callback', ->

            SpecHelper.eventArgumentSpecs.call this,
              instanceType: -> 'draggable'
              callback: -> @callback
              expectedEvent: -> 'drag'
              expectedTarget: -> @$draggable.get(0)

          describe 'the second argument to the drag callback', ->

            SpecHelper.metadataSpecs.call this,
              expectedOriginalPosition: -> @originalPosition
              expectedPosition: ->
                top: parseFloat(@$draggable.css('top')) or 0
                left: parseFloat(@$draggable.css('left')) or 0
              expectedOffset: -> @$draggable.offset()
              expectedHelper: -> @$draggable

      describe 'that modifies the position property', ->

        beforeEach ->
          @modifiedTopPosition = 123
          @modifiedLeftPosition = 456

          @callback.andCallFake (event, metadata) =>
            metadata.position.top += @modifiedTopPosition
            metadata.position.left += @modifiedLeftPosition

          loadFixtures 'draggable_static.html'
          @$draggable = $('#draggable_static').draggable(drag: @callback)

        describe 'when dragged', ->

          beforeEach ->
            @originalOffset = @$draggable.offset()

            # Drag the draggable a standard distance
            @$draggable.simulate 'drag',
              dx: options.dragDistance
              dy: options.dragDistance

          it 'should find itself at the modified top offset', ->
            expect(@$draggable.offset().top).toBe(@originalOffset.top + options.dragDistance + @modifiedTopPosition)

          it 'should find itself at the modified left offset', ->
            expect(@$draggable.offset().left).toBe(@originalOffset.left + options.dragDistance + @modifiedLeftPosition)

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
          @originalPosition =
            top: parseFloat(@$draggable.css('top')) or 0
            left: parseFloat(@$draggable.css('left')) or 0

          # Drag the draggable a standard distance
          @$draggable.simulate 'drag',
            dx: options.dragDistance
            dy: options.dragDistance

        describe 'the stop callback', ->

          it 'should have been called once', ->
            expect(@callback.callCount).toBe(1)

        describe 'the first argument to the stop callback', ->

          SpecHelper.eventArgumentSpecs.call this,
            instanceType: -> 'draggable'
            callback: -> @callback
            expectedEvent: -> 'dragstop'
            expectedTarget: -> @$draggable.get(0)

        describe 'the second argument to the stop callback', ->

          SpecHelper.metadataSpecs.call this,
            expectedOriginalPosition: -> @originalPosition
            expectedPosition: ->
              top: parseFloat(@$draggable.css('top')) or 0
              left: parseFloat(@$draggable.css('left')) or 0
            expectedOffset: -> @$draggable.offset()
            expectedHelper: -> @$draggable

  for variant, getCancelConfig of options.cancelConfigVariants
    do (variant, getCancelConfig) ->

      describe "configured with a #{variant} as a canceling agent", ->

        beforeEach ->
          loadFixtures 'draggable_with_canceling_agent.html'

          # Get the cancel config, and the canceling agent itself
          @cancelConfig = getCancelConfig()
          @cancelingAgent = $(@cancelConfig)

          @$draggable = $('#draggable_static').draggable(cancel: @cancelConfig)

        describe 'after having been dragged by its canceling agent', ->

          beforeEach ->
            # The draggable's start position
            @start = @$draggable.offset()

            # Drag the draggable a standard distance, using the canceling agent
            @cancelingAgent.simulate 'drag',
              dx: options.dragDistance
              dy: options.dragDistance

            # The draggable's end position
            @end = @$draggable.offset()

          it 'should not have triggered a drag', ->
            expect(@end.top - @start.top).toBe(0)
            expect(@end.left - @start.left).toBe(0)

        describe 'after having been dragged by a descendant of its canceling agent', ->

          beforeEach ->
            # The draggable's start position
            @start = @$draggable.offset()

            # Drag the draggable a standard distance, using a descendant of the canceling agent
            @cancelingAgent.children().simulate 'drag',
              dx: options.dragDistance
              dy: options.dragDistance

            # The draggable's end position
            @end = @$draggable.offset()

          it 'should not have triggered a drag', ->
            expect(@end.top - @start.top).toBe(0)
            expect(@end.left - @start.left).toBe(0)

        describe 'after having been dragged by something other than its canceling agent', ->

          beforeEach ->
            # The draggable's start position
            @start = @$draggable.offset()

            # Drag the draggable a standard distance
            @$draggable.simulate 'drag',
              dx: options.dragDistance
              dy: options.dragDistance

            # The draggable's end position
            @end = @$draggable.offset()

          it 'should have triggered a drag', ->
            expect(@end.top - @start.top).toBe(options.dragDistance)
            expect(@end.left - @start.left).toBe(options.dragDistance)

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

            # Drag the draggable a standard distance, using a descendant of the handle
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

            # Drag the draggable a standard distance
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

                it 'should be called with a jQuery object and the event as arguments', ->
                  expect(helperConfig).toHaveBeenCalledWith(jasmine.any(jQuery), jasmine.any(jQuery.Event))

                it 'should be receive the draggable as its first argument', ->
                  expect(helperConfig.mostRecentCall.args[0]).toBe(@$draggable)

            describe 'the helper', ->

              it 'should be positioned absolutely', ->
                expect(@appendedElement).toHaveCss { position: 'absolute' }

              it 'should have been appended to the body', ->
                expect(@appendReceiver).toBe('body')

              it 'should possess the default dragging class', ->
                expect(@appendedElement).toHaveClass $.draggable::defaults['draggingClass']

              it 'should find itself the drag distance from the draggable‘s original top offset', ->
                expect(@appendedElement.offset().top).toBe(@originalOffset.top + options.dragDistance)

              it 'should find itself the drag distance from the draggable‘s original left offset', ->
                expect(@appendedElement.offset().left).toBe(@originalOffset.left + options.dragDistance)

              if helperConfig is 'clone'
                it 'should have no id', ->
                  expect(@appendedElement).not.toHaveAttr('id')

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

  describe 'configured with a containment option', ->

    for variant, containmentOptions of options.containmentConfigVariants
      do (variant, containmentOptions) ->

        describe "such as #{variant}", ->

          beforeEach ->
            loadFixtures 'draggable_containable.html'
            @$draggable = $('#draggable_containable').draggable(containment: containmentOptions.config())

            # Calculate properties of the container
            container = containmentOptions.target(@$draggable)
            containerWidth = container.width()
            containerHeight = container.height()
            containerOffset = container.offset()
            containerPadding =
              top: parseFloat(container.css('paddingTop')) or 0
              right: parseFloat(container.css('paddingRight')) or 0
              bottom: parseFloat(container.css('paddingBottom')) or 0
              left: parseFloat(container.css('paddingLeft')) or 0
            containerBorder =
              top: parseFloat(container.css('borderTopWidth')) or 0
              right: parseFloat(container.css('borderRightWidth')) or 0
              bottom: parseFloat(container.css('borderBottomWidth')) or 0
              left: parseFloat(container.css('borderLeftWidth')) or 0

            # Get the bounding box of the container
            @bounds = if $(window).is(container)
              top: container.scrollTop()
              right: container.scrollLeft() + container.width()
              bottom: container.scrollTop() + container.height()
              left: container.scrollLeft()
            else
              top: containerOffset.top + containerPadding.top + containerBorder.top
              right: containerOffset.left + containerWidth - (containerPadding.right + containerBorder.right)
              bottom: containerOffset.top + containerHeight - (containerPadding.bottom + containerBorder.bottom)
              left: containerOffset.left + containerPadding.left + containerBorder.left

          describe 'when dragged', ->

            beforeEach ->
              draggableOffset = @$draggable.offset()

              # Grab the draggable by the very top corner to simplify the upcoming math
              @$draggable.simulate 'mousedown',
                clientX: draggableOffset.left
                clientY: draggableOffset.top
              # Start the drag
              $(document).simulate 'mousemove',
                clientX: draggableOffset.left + 1
                clientY: draggableOffset.top + 1

              # Grab the helper
              @$helper = @$draggable.data('draggable').$helper

            describe 'above the boundary', ->

              beforeEach ->
                $(document).simulate 'mousemove',
                  clientX: @bounds.left
                  clientY: @bounds.top - 1

                @topOverflow = Math.max 0, @bounds.top - @$helper.get(0).getBoundingClientRect().top
                @bottomOverflow = Math.max 0, @$helper.get(0).getBoundingClientRect().bottom - @bounds.bottom

              it 'should equalize the top and bottom overflow', ->
                expect(@topOverflow - @bottomOverflow).toBe(0)

            describe 'to the right of the boundary', ->

              beforeEach ->
                $(document).simulate 'mousemove',
                  clientX: @bounds.left + (@bounds.right - @bounds.left) + 1
                  clientY: @bounds.top

                @leftOverflow = Math.max 0, @bounds.left - @$helper.get(0).getBoundingClientRect().left
                @rightOverflow = Math.max 0, @$helper.get(0).getBoundingClientRect().right - @bounds.right

              it 'should equalize the left and right overflow', ->
                expect(@leftOverflow - @rightOverflow).toBe(0)

            describe 'below the boundary', ->

              beforeEach ->
                $(document).simulate 'mousemove',
                  clientX: @bounds.left
                  clientY: @bounds.top + (@bounds.bottom - @bounds.top) + 1

                @topOverflow = Math.max 0, @bounds.top - @$helper.get(0).getBoundingClientRect().top
                @bottomOverflow = Math.max 0, @$helper.get(0).getBoundingClientRect().bottom - @bounds.bottom

              it 'should equalize the top and bottom overflow', ->
                expect(@topOverflow - @bottomOverflow).toBe(0)

            describe 'to the left of the boundary', ->

              beforeEach ->
                $(document).simulate 'mousemove',
                  clientX: @bounds.left - 1
                  clientY: @bounds.top

                @leftOverflow = Math.max 0, @bounds.left - @$helper.get(0).getBoundingClientRect().left
                @rightOverflow = Math.max 0, @$helper.get(0).getBoundingClientRect().right - @bounds.right

              it 'should equalize the left and right overflow', ->
                expect(@leftOverflow - @rightOverflow).toBe(0)

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

        describe 'then moved', ->

          beforeEach ->
            # Watch the draggable for the dragstart/drag events
            spyOnEvent @$draggable, 'dragstart'
            spyOnEvent @$draggable, 'drag'

            # Move it by the prescribed amount, without lifting the mouse button
            $(document).simulate 'mousemove',
              clientX: @center.x + options.dragDistance
              clientY: @center.y + options.dragDistance

          it 'should possess the default dragging class', ->
            expect(@$draggable).toHaveClass $.draggable::defaults['draggingClass']

          it 'should have the dragstart event fired upon it', ->
            expect('dragstart').toHaveBeenTriggeredOn(@$draggable)
            # TODO: When jQuery Jasmine supports the same spy attributes as do regular Jasmine spies (mostRecentCall.args, callCount, etc…) write specs for the metadata argument of this event

          it 'should have the drag event fired upon it', ->
            expect('drag').toHaveBeenTriggeredOn(@$draggable)
            # TODO: When jQuery Jasmine supports the same spy attributes as do regular Jasmine spies (mostRecentCall.args, callCount, etc…) write specs for the metadata argument of this event

          it 'should not have caused any text to be selected in the document body', ->
            expect(document.getSelection().type).toBe('None') # FIXME: This will never fail, because jQuery simulate doesn't cause text selection to happen with the mousedown/mousemove combo

          describe 'then having been released', ->

            beforeEach ->
              spyOnEvent @$draggable, 'mouseup'

              # Watch the draggable for the dragstart/drag events
              spyOnEvent @$draggable, 'dragstop'

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

              it 'should have the dragstop event fired upon it', ->
                expect('dragstop').toHaveBeenTriggeredOn(@$draggable)
                # TODO: When jQuery Jasmine supports the same spy attributes as do regular Jasmine spies (mostRecentCall.args, callCount, etc…) write specs for the metadata argument of this event

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

    for variant, edgeConfig of options.absoluteAnchorEdges
      do (variant, edgeConfig) ->

        describe "anchored #{variant}ly", ->
          beforeEach ->
            loadFixtures "draggable_#{edgeConfig.fixtureType}.html"
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

            it 'should find itself the drag distance from its original top offset', ->
              expect(@$draggable.offset().top).toBe(@originalOffset.top + options.dragDistance)

            it 'should find itself the drag distance from its original left offset', ->
              expect(@$draggable.offset().left).toBe(@originalOffset.left + options.dragDistance)

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

        for elementTransformedness, transformCSS of options.elementTransformednesses
          do (elementTransformedness, transformCSS) ->

            describe "being #{elementTransformedness}", ->

              beforeEach ->
                # Set the transformedness according to the transformedness type
                @$draggable.css transformCSS()

              for positionType, positionValues of options.elementPositionTypes
                do (positionType, positionValues) ->

                  describe "with an #{positionType} defined position", ->

                    beforeEach ->
                      # Set the position according to the position type
                      @$draggable.css positionValues

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

                        # Let's use imprecise matchers for the transformed elements
                        @matcher = if elementTransformedness is 'transformed' then 'toBeCloseTo' else 'toBe'

                      it 'should find itself the drag distance from its original top offset', ->
                        expect(@$draggable.offset().top)[@matcher](@originalOffset.top + options.dragDistance)

                      it 'should find itself the drag distance from its original left offset', ->
                        expect(@$draggable.offset().left)[@matcher](@originalOffset.left + options.dragDistance)

                    for scrollVariant, scrollOffset of options.scrollOffsetVariants
                      do (scrollVariant, scrollOffset) ->

                        describe "in a container with #{scrollVariant} scroll offset", ->

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

  describe 'with another draggable nested inside it', ->

    beforeEach ->
      loadFixtures "draggable_nested.html"
      @$parentDraggable = $("#draggable_nested_parent").draggable()
      @$childDraggable = $("#draggable_nested_child").draggable()

    describe 'when its nested draggable is dragged', ->

      beforeEach ->
        # Store the offset of the parent draggable
        @originalParentOffset = @$parentDraggable.offset()

        # Drag the draggable a standard distance
        @$childDraggable.simulate 'drag',
          dx: options.dragDistance
          dy: options.dragDistance

      it 'should find itself at its original top offset', ->
        expect(@$parentDraggable.offset().top).toBe(@originalParentOffset.top)

      it 'should find itself at its original left offset', ->
        expect(@$parentDraggable.offset().left).toBe(@originalParentOffset.left)

describe 'A stack of draggables', ->

  beforeEach ->
    # Load three absolutely positioned fixtures
    f = 'draggable_absolute.html'
    loadFixtures f, f, f

    # Define the indices they can have
    @indices =
      bottom: 'auto'
      middle: '1'
      top: '3'

    # Add the stack member class to each
    $('[id="draggable_absolute"]').addClass(options.stackMemberClass)

    # Stack them
    @$bottomDraggable = $('[id="draggable_absolute"]:eq(0)').css(zIndex: @indices.bottom)
    @$middleDraggable = $('[id="draggable_absolute"]:eq(1)').css(zIndex: @indices.middle)
    @$topDraggable = $('[id="draggable_absolute"]:eq(2)').css(zIndex: @indices.top)

  describe 'configured with the stack option', ->

    for variant, stackConfig of options.stackConfigVariants
      do (variant, stackConfig) ->

        describe "such as #{variant}", ->

          beforeEach ->
            @$bottomDraggable.draggable(stack: stackConfig)
            @$middleDraggable.draggable(stack: stackConfig)
            @$topDraggable.draggable(stack: stackConfig)

          if typeof stackConfig is 'function'
            describe 'after dragging any draggable', ->

              beforeEach ->
                @$topDraggable.simulate 'drag',
                  dx: options.dragDistance
                  dy: options.dragDistance

              describe 'the stack config function', ->

                it 'should be called with a jQuery object and the event as arguments', ->
                  expect(stackConfig).toHaveBeenCalledWith(jasmine.any(jQuery), jasmine.any(jQuery.Event))

                it 'should be receive the draggable as its first argument', ->
                  expect(stackConfig.mostRecentCall.args[0]).toBe(@$topDraggable)

          describe 'after dragging the top draggable', ->

            beforeEach ->
              @$topDraggable.simulate 'drag',
                dx: options.dragDistance
                dy: options.dragDistance

            it 'should not have changed the z-index of the bottom draggable', ->
              expect(@$bottomDraggable).toHaveCss { zIndex: @indices.bottom }

            it 'should not have changed the z-index of the middle draggable', ->
              expect(@$middleDraggable).toHaveCss { zIndex: @indices.middle }

            it 'should not have changed the z-index of the top draggable', ->
              expect(@$topDraggable).toHaveCss { zIndex: @indices.top }

          describe 'after dragging the middle draggable', ->

            beforeEach ->
              @$middleDraggable.simulate 'drag',
                dx: options.dragDistance
                dy: options.dragDistance

            it 'should not have changed the z-index of the bottom draggable', ->
              expect(@$bottomDraggable).toHaveCss { zIndex: @indices.bottom }

            it 'should have changed the z-index of the middle draggable to that of the top draggable plus one', ->
              expect(@$middleDraggable).toHaveCss { zIndex: "#{parseFloat(@indices.top) + 1}" }

            it 'should not have changed the z-index of the top draggable', ->
              expect(@$topDraggable).toHaveCss { zIndex: @indices.top }

          describe 'after dragging the bottom draggable', ->

            beforeEach ->
              @$bottomDraggable.simulate 'drag',
                dx: options.dragDistance
                dy: options.dragDistance

            it 'should have changed the z-index of the bottom draggable to that of the top draggable plus one', ->
              expect(@$bottomDraggable).toHaveCss { zIndex: "#{parseFloat(@indices.top) + 1}" }

            it 'should not have changed the z-index of the middle draggable', ->
              expect(@$middleDraggable).toHaveCss { zIndex: @indices.middle }

            it 'should not have changed the z-index of the top draggable', ->
              expect(@$topDraggable).toHaveCss { zIndex: @indices.top }

describe 'An active element', ->

  for description, activeElementSelector of options.possibleActiveElementSelectors
    do (description, activeElementSelector) ->

      describe "such as #{description}", ->

        beforeEach ->
          loadFixtures 'focussable_elements.html'

          # Get the active element
          @activeElement = $(activeElementSelector)

          # Focus it
          @activeElement.focus()

        describe 'when a draggable is mousedown’d upon', ->

          beforeEach ->
            appendLoadFixtures 'draggable_static.html'
            @$draggable = $('#draggable_static').draggable()

            center = SpecHelper.mouseDownInCenterOf @$draggable

          if activeElementSelector is 'body'
            it 'should still be the active element', ->
              expect(@activeElement.get(0)).toBe(document.activeElement)
          else
            it 'should no longer be the active element', ->
              expect(@activeElement.get(0)).not.toBe(document.activeElement)
