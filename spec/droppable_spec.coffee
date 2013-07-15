describe 'A droppable', ->
  options =
    alternateDroppableClass: 'alternateDroppableClass'

  describe 'configured using the default options', ->

    beforeEach ->
      loadFixtures 'droppable.html'
      @$droppable = $('#droppable').droppable()

    it 'should possess the default droppable class', ->
      expect(@$droppable).toHaveClass $.droppable::defaults['droppableClass']

  describe 'configured using the droppableClass option', ->

    beforeEach ->
      loadFixtures 'droppable.html'
      @$droppable = $('#droppable').droppable(droppableClass: options.alternateDroppableClass)

    it 'should possess the supplied droppable class', ->
      expect(@$droppable).toHaveClass options.alternateDroppableClass
