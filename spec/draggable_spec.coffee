describe 'Draggable', ->
  options =
    dragDistance: 50

  describe 'a statically positioned draggable', ->
    beforeEach ->
      loadFixtures 'draggable.html'
      @$draggable = $('#draggable').draggable()

    it 'should possess the default draggable class', ->
      expect(@$draggable).toHaveClass $.draggable::defaults.classes['draggable']

    describe 'when clicked on', ->
      beforeEach ->
        spyOnEvent @$draggable, 'mousedown'
        SpecHelper.mouseDownInCenterOf @$draggable

      it 'should capture the click event', ->
        expect('mousedown').toHaveBeenPreventedOn(@$draggable)

    describe 'while in mid-drag', ->
      beforeEach ->
        center = SpecHelper.mouseDownInCenterOf @$draggable

        # Move it by the prescribed amount, without lifting the mouse button
        $(document).simulate 'mousemove',
          clientX: center.x + options.dragDistance
          clientY: center.y + options.dragDistance

      it 'should possess the default dragging class', ->
        expect(@$draggable).toHaveClass $.draggable::defaults.classes['dragging']

    describe 'after having been dragged a standard amount', ->
      beforeEach ->
        # Drag the draggable a standard distance
        @$draggable.simulate 'drag',
          moves: 1
          dx: options.dragDistance
          dy: options.dragDistance

      it 'should be positioned relatively', ->
        expect(@$draggable).toHaveCss { position: 'relative' }

      it 'should find itself a standard distance from its original top', ->
        expect(@$draggable).toHaveCss { top: "#{options.dragDistance}px" }

      it 'should find itself a standard distance from its original left', ->
        expect(@$draggable).toHaveCss { left: "#{options.dragDistance}px" }

