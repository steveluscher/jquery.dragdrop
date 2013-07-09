describe 'Draggable', ->
  options =
    dragDistance: 50
    alternateDraggableClass: 'alternateDraggableClass'
    alternateDraggingClass: 'alternateDraggingClass'

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
          @$draggable.simulate 'click'

        it 'should not call the start callback', ->
          expect(@callback).not.toHaveBeenCalled()

      describe 'when dragged', ->

        beforeEach ->
          # Drag the draggable a standard distance
          @$draggable.simulate 'drag',
            moves: 1
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
          @$draggable.simulate 'click'

        it 'should not call the stop callback', ->
          expect(@callback).not.toHaveBeenCalled()

      describe 'after having been dragged', ->

        beforeEach ->
          # Drag the draggable a standard distance
          @$draggable.simulate 'drag',
            moves: 1
            dx: options.dragDistance
            dy: options.dragDistance

        it 'should call the stop callback', ->
          expect(@callback).toHaveBeenCalled()

        it 'should call the stop callback with the jQuery mouse event as the first parameter', ->
          expect(@callback).toHaveBeenCalledWith(jasmine.any(jQuery.Event))

  describe 'any draggable', ->

    beforeEach ->
      loadFixtures 'draggable.html'
      @$draggable = $('#draggable').draggable()

    describe 'when mousedowned upon', ->

      beforeEach ->
        spyOnEvent @$draggable, 'mousedown'
        SpecHelper.mouseDownInCenterOf @$draggable

      it 'should not possess the default dragging class', ->
        expect(@$draggable).not.toHaveClass $.draggable::defaults['draggingClass']

      it 'should capture the mousedown event', ->
        expect('mousedown').toHaveBeenPreventedOn(@$draggable)

    describe 'when clicked without having been dragged', ->

      beforeEach ->
        spyOnEvent @$draggable, 'click'

        # Click the draggable, but don't move it
        @$draggable.simulate 'click'

      it 'should receive the click event', ->
        expect('click').toHaveBeenTriggeredOn(@$draggable)

    describe 'while in mid-drag', ->

      beforeEach ->
        center = SpecHelper.mouseDownInCenterOf @$draggable

        # Move it by the prescribed amount, without lifting the mouse button
        $(document).simulate 'mousemove',
          clientX: center.x + options.dragDistance
          clientY: center.y + options.dragDistance

      it 'should possess the default dragging class', ->
        expect(@$draggable).toHaveClass $.draggable::defaults['draggingClass']

    describe 'after having been dragged', ->

      beforeEach ->
        spyOnEvent @$draggable, 'click'

        # Drag the draggable a standard distance
        @$draggable.simulate 'drag',
          moves: 1
          dx: options.dragDistance
          dy: options.dragDistance

      it 'should not possess the default dragging class', ->
        expect(@$draggable).not.toHaveClass $.draggable::defaults['draggingClass']

      it 'should not receive the click event', ->
        expect('click').not.toHaveBeenTriggeredOn(@$draggable)

  describe 'a statically positioned draggable', ->

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
        for edge in ['top', 'left']
          value = parseInt @$draggable.css(edge)
          @["original#{edge.charAt(0).toUpperCase()}#{edge.slice(1)}"] = if SpecHelper.isNaN(value) then 0 else value

        # Drag the draggable a standard distance
        @$draggable.simulate 'drag',
          moves: 1
          dx: options.dragDistance
          dy: options.dragDistance

      it 'should be positioned relatively', ->
        expect(@$draggable).toHaveCss { position: 'relative' }

      it 'should find itself the drag distance from its original top', ->
        expect(@$draggable).toHaveCss { top: "#{@originalTop + options.dragDistance}px" }

      it 'should find itself the drag distance from its original left', ->
        expect(@$draggable).toHaveCss { left: "#{@originalLeft + options.dragDistance}px" }

