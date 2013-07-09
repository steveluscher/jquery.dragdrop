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

  describe 'any draggable', ->

    beforeEach ->
      loadFixtures 'draggable.html'
      @$draggable = $('#draggable').draggable()

    describe 'when clicked on', ->

      beforeEach ->
        spyOnEvent @$draggable, 'mousedown'
        SpecHelper.mouseDownInCenterOf @$draggable

      it 'should not possess the default dragging class', ->
        expect(@$draggable).not.toHaveClass $.draggable::defaults['draggingClass']

      it 'should capture the mousedown event', ->
        expect('mousedown').toHaveBeenPreventedOn(@$draggable)

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
        # Drag the draggable a standard distance
        @$draggable.simulate 'drag',
          moves: 1
          dx: options.dragDistance
          dy: options.dragDistance

      it 'should not possess the default dragging class', ->
        expect(@$draggable).not.toHaveClass $.draggable::defaults['draggingClass']

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

