(function() {
  var __slice = [].slice;

  if (jQuery.dragdrop != null) {
    return;
  }

  jQuery.dragdrop = (function() {
    var getCSSEdge;

    function dragdrop() {}

    getCSSEdge = function(edge, oppositeEdge, $element) {
      return parseFloat($element.css(edge)) || (parseFloat($element.css(oppositeEdge)) ? $element.position()[edge] : null || 0);
    };

    dragdrop.prototype.getCSSLeft = function($element) {
      return getCSSEdge('left', 'right', $element);
    };

    dragdrop.prototype.getCSSTop = function($element) {
      return getCSSEdge('top', 'bottom', $element);
    };

    dragdrop.prototype.getConfig = function() {
      return this.config || (this.config = this.applyDefaults(this.options, this.defaults));
    };

    dragdrop.prototype.isArray = Array.isArray || function(putativeArray) {
      return Object.prototype.toString.call(putativeArray) === '[object Array]';
    };

    dragdrop.prototype.isNumber = function(obj) {
      return (obj === +obj) || toString.call(obj) === '[object Number]';
    };

    dragdrop.prototype.isNaN = function(obj) {
      return this.isNumber(obj) && window.isNaN(obj);
    };

    dragdrop.prototype.applyDefaults = function() {
      var obj, prop, source, sources, _i, _len;
      obj = arguments[0], sources = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      for (_i = 0, _len = sources.length; _i < _len; _i++) {
        source = sources[_i];
        if (!source) {
          continue;
        }
        for (prop in source) {
          if (obj[prop] === void 0) {
            obj[prop] = source[prop];
          }
        }
      }
      return obj;
    };

    dragdrop.prototype.synthesizeEvent = function(type, originalEvent) {
      var event, key, value;
      event = jQuery.Event(originalEvent);
      event.type = type;
      event.target = this.$element.get(0);
      for (key in originalEvent) {
        value = originalEvent[key];
        if (!(key in event)) {
          event[key] = value;
        }
      }
      return event;
    };

    dragdrop.prototype.getEventMetadata = function(position, offset) {
      var metadata;
      metadata = {
        position: position || {
          top: this.getCSSTop(this.$helper),
          left: this.getCSSLeft(this.$helper)
        },
        offset: offset || this.$helper.offset()
      };
      if ((this.helperStartPosition != null) || (this.draggable != null)) {
        metadata.originalPosition = {
          top: (this.helperStartPosition || this.draggable.helperStartPosition).y,
          left: (this.helperStartPosition || this.draggable.helperStartPosition).x
        };
      }
      if (this.$helper != null) {
        metadata.helper = this.$helper;
      }
      if (this.draggable != null) {
        metadata.draggable = this.draggable.$element;
      }
      return metadata;
    };

    return dragdrop;

  })();

}).call(this);

(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  jQuery(function() {
    jQuery.draggable = (function(_super) {
      var getCamelizedVendor, getTransformMatrixString, implementConvertPointPolyfill, implementRequestAnimationFramePolyfill, vendors;

      __extends(draggable, _super);

      vendors = ["ms", "moz", "webkit", "o"];

      getCamelizedVendor = function(vendor) {
        if (vendor === 'webkit') {
          return 'WebKit';
        } else {
          return vendor.charAt(0).toUpperCase() + vendor.slice(1);
        }
      };

      implementRequestAnimationFramePolyfill = function() {
        var lastTime, vendor, _i, _len;
        lastTime = 0;
        for (_i = 0, _len = vendors.length; _i < _len; _i++) {
          vendor = vendors[_i];
          window.requestAnimationFrame || (window.requestAnimationFrame = window[vendor + "RequestAnimationFrame"]);
          window.cancelAnimationFrame || (window.cancelAnimationFrame = window[vendor + "CancelAnimationFrame"] || window[vendor + "CancelRequestAnimationFrame"]);
          if (window.requestAnimationFrame && window.cancelAnimationFrame) {
            break;
          }
        }
        if (!window.requestAnimationFrame) {
          window.requestAnimationFrame = function(callback, element) {
            var currTime, id, timeToCall;
            currTime = new Date().getTime();
            timeToCall = Math.max(0, 16 - (currTime - lastTime));
            id = window.setTimeout(function() {
              return callback(currTime + timeToCall);
            }, timeToCall);
            lastTime = currTime + timeToCall;
            return id;
          };
        }
        if (!window.cancelAnimationFrame) {
          window.cancelAnimationFrame = function(id) {
            return clearTimeout(id);
          };
        }
        return implementRequestAnimationFramePolyfill = function() {};
      };

      implementConvertPointPolyfill = function() {
        var vendor, _i, _len;
        for (_i = 0, _len = vendors.length; _i < _len; _i++) {
          vendor = vendors[_i];
          window.convertPointFromPageToNode || (window.convertPointFromPageToNode = window[vendor + "ConvertPointFromPageToNode"]);
          window.convertPointFromNodeToPage || (window.convertPointFromNodeToPage = window[vendor + "ConvertPointFromNodeToPage"]);
          window.Point || (window.Point = window[getCamelizedVendor(vendor) + "Point"]);
          if (window.convertPointFromPageToNode && window.convertPointFromNodeToPage && window.Point) {
            break;
          }
        }
        if (!window.Point) {
          throw '[jQuery DragDrop] TODO: Implement Point() polyfill';
        }
        if (!window.convertPointFromPageToNode) {
          throw '[jQuery DragDrop] TODO: Implement convertPointFromPageToNode() polyfill';
        }
        if (!window.convertPointFromNodeToPage) {
          throw '[jQuery DragDrop] TODO: Implement convertPointFromNodeToPage() polyfill';
        }
        return implementConvertPointPolyfill = function() {};
      };

      draggable.prototype.defaults = {
        draggableClass: 'ui-draggable',
        draggingClass: 'ui-draggable-dragging',
        helper: 'original',
        stack: false,
        containment: false,
        cursorAt: false,
        distance: false
      };

      function draggable(element, options) {
        this.options = options != null ? options : {};
        this.handleElementClick = __bind(this.handleElementClick, this);
        this.handleDocumentMouseUp = __bind(this.handleDocumentMouseUp, this);
        this.handleDocumentMouseMove = __bind(this.handleDocumentMouseMove, this);
        this.handleElementMouseDown = __bind(this.handleElementMouseDown, this);
        draggable.__super__.constructor.apply(this, arguments);
        implementRequestAnimationFramePolyfill();
        this.$element = $(element);
        this.$element.on({
          mousedown: this.handleElementMouseDown,
          click: this.handleElementClick
        }).addClass(this.getConfig().draggableClass);
        this;
      }

      draggable.prototype.setupElement = function() {
        var callbackName, config, _i, _len, _ref;
        config = this.getConfig();
        if (config.helper === 'original' && this.$element.css('position') === 'static') {
          this.$element.css({
            position: 'relative'
          });
        }
        _ref = ['start', 'drag', 'stop'];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          callbackName = _ref[_i];
          if (typeof config[callbackName] === 'function') {
            config[callbackName] = config[callbackName].bind(this);
          }
        }
        return this.setupPerformed = true;
      };

      draggable.prototype.handleElementMouseDown = function(e) {
        var isLeftButton;
        if (e.originalEvent.jQueryDragdropAlreadyHandled === true) {
          return;
        }
        isLeftButton = e.which === 1;
        if (!isLeftButton) {
          return;
        }
        this.cancelAnyScheduledDrag();
        this.shouldCancelClick = false;
        if (this.isCancelingAgent(e.target)) {
          return;
        }
        if (!this.isValidHandle(e.target)) {
          return;
        }
        implementConvertPointPolyfill();
        e.originalEvent.jQueryDragdropAlreadyHandled = true;
        $(document.body).one('mousedown', function(e) {
          var activeElement;
          e.preventDefault();
          activeElement = $(document.activeElement);
          if (!activeElement.is(this)) {
            return activeElement.blur();
          }
        });
        this.mousedownEvent = e;
        return $(document).on({
          mousemove: this.handleDocumentMouseMove,
          mouseup: this.handleDocumentMouseUp
        });
      };

      draggable.prototype.handleDocumentMouseMove = function(e) {
        var deltaX, deltaY, distanceMoved, thresholdDistance;
        if (this.dragStarted) {
          return this.handleDrag(e);
        } else {
          thresholdDistance = this.getConfig().distance;
          if (thresholdDistance != null) {
            deltaX = e.clientX - this.mousedownEvent.clientX;
            deltaY = e.clientY - this.mousedownEvent.clientY;
            distanceMoved = Math.sqrt(Math.pow(deltaX, 2) + Math.pow(deltaY, 2));
            if (distanceMoved < thresholdDistance) {
              return true;
            }
          }
          this.handleDragStart(e);
          if (this.dragStarted) {
            this.handleDrag(e, true);
            return this.broadcast('start', e);
          }
        }
      };

      draggable.prototype.handleDocumentMouseUp = function(e) {
        var isLeftButton;
        isLeftButton = e.which === 1;
        if (!isLeftButton) {
          return;
        }
        return this.handleDragStop(e);
      };

      draggable.prototype.handleElementClick = function(e) {
        if (this.shouldCancelClick) {
          e.stopImmediatePropagation();
          return false;
        }
      };

      draggable.prototype.handleDragStart = function(e) {
        var bottomAnchorNodeOffset, cursorAtConfig, cursorNodeOffset, delta, dragStartEvent, elementPreTransformStartPageOffset, eventMetadata, helperConfig, helperIsSynthesized, helperPlaceholder, horizontalAnchorOffset, leftAnchorNodeOffset, mouseAnchorPageOffset, preTransformOffset, rightAnchorNodeOffset, savedTransform, shouldCalculateOffset, stackConfig, startOffset, startPosition, topAnchorNodeOffset, verticalAnchorOffset, _base, _ref;
        if (!this.setupPerformed) {
          this.setupElement();
        }
        helperConfig = this.getConfig().helper;
        helperIsSynthesized = helperConfig !== 'original';
        helperPlaceholder = helperIsSynthesized ? $('<div style="height: 0; width: 0; visibility: none">').appendTo('body') : this.$element;
        this.parent = helperIsSynthesized ? this.getOffsetParentOrTransformedParent(helperPlaceholder) : this.getOffsetParentOrTransformedParent(this.$element);
        if (helperIsSynthesized) {
          helperPlaceholder.remove();
        }
        shouldCalculateOffset = helperIsSynthesized || (this.isAbsoluteish(this.$element) && this.isPositionedImplicitly(this.$element));
        this.elementStartPageOffset = convertPointFromNodeToPage(this.$element.get(0), new Point(0, 0));
        this.helperStartPosition = shouldCalculateOffset ? (elementPreTransformStartPageOffset = !helperIsSynthesized && this.isTransformed(this.$element.get(0)) ? (savedTransform = this.$element.css('transform'), this.$element.css('transform', 'none'), preTransformOffset = convertPointFromNodeToPage(this.$element.get(0), new Point(0, 0)), this.$element.css('transform', savedTransform), preTransformOffset) : this.elementStartPageOffset, startPosition = convertPointFromPageToNode(this.parent, elementPreTransformStartPageOffset), this.isTransformed(this.parent) ? (startPosition.x += this.parent.scrollLeft, startPosition.y += this.parent.scrollTop) : void 0, startPosition) : new Point(this.getCSSLeft(this.$element), this.getCSSTop(this.$element));
        if (cursorAtConfig = this.getConfig().cursorAt) {
          cursorNodeOffset = convertPointFromPageToNode(this.$element.get(0), new Point(this.mousedownEvent.clientX, this.mousedownEvent.clientY));
          leftAnchorNodeOffset = cursorAtConfig.left;
          if (cursorAtConfig.right != null) {
            rightAnchorNodeOffset = this.$element.width() - cursorAtConfig.right;
          }
          topAnchorNodeOffset = cursorAtConfig.top;
          if (cursorAtConfig.bottom != null) {
            bottomAnchorNodeOffset = this.$element.height() - cursorAtConfig.bottom;
          }
          horizontalAnchorOffset = (leftAnchorNodeOffset != null) && (rightAnchorNodeOffset != null) ? Math.abs(cursorNodeOffset.x - leftAnchorNodeOffset) < Math.abs(cursorNodeOffset.x - rightAnchorNodeOffset) ? leftAnchorNodeOffset : rightAnchorNodeOffset : leftAnchorNodeOffset || rightAnchorNodeOffset || cursorNodeOffset.x;
          verticalAnchorOffset = (topAnchorNodeOffset != null) && (bottomAnchorNodeOffset != null) ? Math.abs(cursorNodeOffset.y - topAnchorNodeOffset) < Math.abs(cursorNodeOffset.y - bottomAnchorNodeOffset) ? topAnchorNodeOffset : bottomAnchorNodeOffset : topAnchorNodeOffset || bottomAnchorNodeOffset || cursorNodeOffset.y;
          mouseAnchorPageOffset = convertPointFromNodeToPage(this.$element.get(0), new Point(horizontalAnchorOffset, verticalAnchorOffset));
          delta = {
            left: this.mousedownEvent.clientX - mouseAnchorPageOffset.x,
            top: this.mousedownEvent.clientY - mouseAnchorPageOffset.y
          };
          this.helperStartPosition.x += delta.left;
          this.helperStartPosition.y += delta.top;
          this.elementStartPageOffset.x += delta.left;
          this.elementStartPageOffset.y += delta.top;
        }
        startPosition = this.pointToPosition(this.helperStartPosition);
        startOffset = this.pointToPosition(this.elementStartPageOffset);
        eventMetadata = this.getEventMetadata(startPosition, startOffset);
        dragStartEvent = this.synthesizeEvent('dragstart', e);
        if ((typeof (_base = this.getConfig()).start === "function" ? _base.start(dragStartEvent, eventMetadata) : void 0) === false) {
          this.handleDragStop(e);
          return;
        }
        this.cancelAnyScheduledDrag();
        this.originalPointerEventsPropertyValue = this.$element.css('pointerEvents');
        this.$helper = helperConfig === 'clone' ? this.synthesizeHelperByCloning(this.$element) : typeof helperConfig === 'function' ? this.synthesizeHelperUsingFactory(helperConfig, e) : this.$element;
        this.$helper.addClass(this.getConfig().draggingClass).css({
          pointerEvents: 'none'
        });
        if (helperIsSynthesized) {
          this.$helper.appendTo('body');
        }
        if (!helperIsSynthesized && (stackConfig = this.getConfig().stack)) {
          this.moveHelperToTopOfStack(stackConfig, e);
        }
        if (this.getConfig().containment !== false) {
          this.bounds = this.calculateContainmentBounds();
        }
        _ref = convertPointFromPageToNode(this.parent, new Point(this.mousedownEvent.pageX, this.mousedownEvent.pageY)), this.mousedownEvent.LocalX = _ref.x, this.mousedownEvent.LocalY = _ref.y;
        this.dragStarted = true;
        jQuery.draggable.draggableAloft = this;
        return this.$element.trigger(dragStartEvent, eventMetadata);
      };

      draggable.prototype.handleDrag = function(e, immediate) {
        var dragHandler,
          _this = this;
        if (immediate == null) {
          immediate = false;
        }
        dragHandler = function() {
          var adjustedLocalMousePosition, delta, dragEvent, eventMetadata, helperOriginalPosition, helperPositionIsFinal, localMousePosition, overflowBottom, overflowLeft, overflowRight, overflowTop, pageRelativeHelperBoundsWithMargin, pageRelativeXAdjustment, pageRelativeYAdjustment, targetOffset, targetOverlap, targetPosition, _base;
          localMousePosition = convertPointFromPageToNode(_this.parent, new Point(e.pageX, e.pageY));
          delta = {
            x: localMousePosition.x - _this.mousedownEvent.LocalX,
            y: localMousePosition.y - _this.mousedownEvent.LocalY
          };
          targetPosition = {
            left: _this.helperStartPosition.x + delta.x,
            top: _this.helperStartPosition.y + delta.y
          };
          targetOffset = {
            left: _this.elementStartPageOffset.x + (e.pageX - _this.mousedownEvent.pageX),
            top: _this.elementStartPageOffset.y + (e.pageY - _this.mousedownEvent.pageY)
          };
          if (_this.bounds) {
            helperOriginalPosition = {
              top: _this.$helper.css('top'),
              left: _this.$helper.css('left')
            };
            _this.$helper.css(targetPosition);
            pageRelativeHelperBoundsWithMargin = _this.getPageRelativeBoundingBox(_this.$helper, [0, _this.helperSize.width, _this.helperSize.height, 0]);
            overflowTop = _this.bounds[0] - pageRelativeHelperBoundsWithMargin[0];
            overflowRight = pageRelativeHelperBoundsWithMargin[1] - _this.bounds[1];
            overflowBottom = pageRelativeHelperBoundsWithMargin[2] - _this.bounds[2];
            overflowLeft = _this.bounds[3] - pageRelativeHelperBoundsWithMargin[3];
            if (overflowLeft > 0 || overflowRight > 0) {
              targetOverlap = Math.max(0, (overflowLeft + overflowRight) / 2);
              pageRelativeXAdjustment = overflowLeft > overflowRight ? overflowLeft - targetOverlap : targetOverlap - overflowRight;
            }
            if (overflowTop > 0 || overflowBottom > 0) {
              targetOverlap = Math.max(0, (overflowTop + overflowBottom) / 2);
              pageRelativeYAdjustment = overflowTop > overflowBottom ? overflowTop - targetOverlap : targetOverlap - overflowBottom;
            }
            if (pageRelativeXAdjustment || pageRelativeYAdjustment) {
              if (pageRelativeXAdjustment) {
                targetOffset.left += pageRelativeXAdjustment;
              }
              if (pageRelativeYAdjustment) {
                targetOffset.top += pageRelativeYAdjustment;
              }
              adjustedLocalMousePosition = convertPointFromPageToNode(_this.parent, new Point(e.pageX + (pageRelativeXAdjustment || 0), e.pageY + (pageRelativeYAdjustment || 0)));
              targetPosition.left += adjustedLocalMousePosition.x - localMousePosition.x;
              targetPosition.top += adjustedLocalMousePosition.y - localMousePosition.y;
            } else {
              helperPositionIsFinal = true;
            }
          }
          eventMetadata = _this.getEventMetadata(targetPosition, targetOffset);
          dragEvent = _this.synthesizeEvent('drag', e);
          if ((typeof (_base = _this.getConfig()).drag === "function" ? _base.drag(dragEvent, eventMetadata) : void 0) === false) {
            if (helperOriginalPosition) {
              _this.$helper.css(helperOriginalPosition);
            }
            _this.handleDragStop(e);
            return;
          }
          if (!helperPositionIsFinal) {
            _this.$helper.css(eventMetadata.position);
          }
          return _this.$element.trigger(dragEvent, eventMetadata);
        };
        if (immediate) {
          return dragHandler();
        } else {
          return this.scheduleDrag(dragHandler);
        }
      };

      draggable.prototype.handleDragStop = function(e) {
        var dragStopEvent, eventMetadata, _base;
        this.cancelAnyScheduledDrag();
        $(document).off({
          mousemove: this.handleMouseMove,
          mouseup: this.handleMouseUp
        });
        if (this.dragStarted) {
          delete jQuery.draggable.draggableAloft;
          delete jQuery.draggable.latestEvent;
          this.shouldCancelClick = !!this.dragStarted;
          dragStopEvent = this.synthesizeEvent('dragstop', e);
          eventMetadata = this.getEventMetadata();
          if (typeof (_base = this.getConfig()).stop === "function") {
            _base.stop(dragStopEvent, eventMetadata);
          }
          this.$element.trigger(dragStopEvent, eventMetadata);
          this.broadcast('stop', e);
          if (this.getConfig().helper === 'original') {
            this.$helper.removeClass(this.getConfig().draggingClass);
          } else {
            this.$helper.remove();
            this.$element.trigger('click', e);
          }
          this.$element.css({
            pointerEvents: this.originalPointerEventsPropertyValue
          });
        }
        return this.cleanUp();
      };

      draggable.prototype.isAbsoluteish = function(element) {
        return /fixed|absolute/.test($(element).css('position'));
      };

      draggable.prototype.isPositionedImplicitly = function(element) {
        var $element;
        $element = $(element);
        if ($element.css('top') === 'auto' && $element.css('bottom') === 'auto') {
          return true;
        }
        if ($element.css('left') === 'auto' && $element.css('right') === 'auto') {
          return true;
        }
      };

      draggable.prototype.isCancelingAgent = function(element) {
        if (this.getConfig().cancel) {
          return !!$(element).closest(this.getConfig().cancel).length;
        } else {
          return false;
        }
      };

      draggable.prototype.isValidHandle = function(element) {
        if (this.getConfig().handle) {
          return !!$(element).closest(this.getConfig().handle).length;
        } else {
          return true;
        }
      };

      draggable.prototype.isTransformed = function(element) {
        return getTransformMatrixString(element) !== 'none';
      };

      draggable.prototype.broadcast = function(type, originalEvent) {
        var event;
        event = this.synthesizeEvent(type, originalEvent);
        jQuery.draggable.latestEvent = event;
        return $(jQuery.draggable.prototype).trigger(event, this);
      };

      draggable.prototype.getPageRelativeBoundingBox = function(element, elementEdges) {
        var coord, elementCoords, p, xCoords, yCoords, _i, _len;
        xCoords = [];
        yCoords = [];
        elementCoords = [[elementEdges[3], elementEdges[0]], [elementEdges[1], elementEdges[0]], [elementEdges[1], elementEdges[2]], [elementEdges[3], elementEdges[2]]];
        for (_i = 0, _len = elementCoords.length; _i < _len; _i++) {
          coord = elementCoords[_i];
          p = convertPointFromNodeToPage(element.get(0), new Point(coord[0], coord[1]));
          xCoords.push(p.x);
          yCoords.push(p.y);
        }
        return [Math.min.apply(this, yCoords), Math.max.apply(this, xCoords), Math.max.apply(this, yCoords), Math.min.apply(this, xCoords)];
      };

      draggable.prototype.calculateContainmentBounds = function() {
        var bottomEdge, container, containerHeight, containerLeftBorder, containerLeftPadding, containerTopBorder, containerTopPadding, containerWidth, containmentConfig, leftEdge, pageRelativeContainmentBounds, pageRelativeHelperBounds, pageRelativeHelperBoundsWithMargin, rightEdge, topEdge, windowLeftEdge, windowTopEdge;
        containmentConfig = this.getConfig().containment;
        pageRelativeContainmentBounds = this.isArray(containmentConfig) ? containmentConfig.slice(0) : (container = (function() {
          switch (containmentConfig) {
            case 'parent':
              return this.$element.parent();
            case 'window':
              return $(window);
            case 'document':
              return $(document.documentElement);
            default:
              return $(containmentConfig);
          }
        }).call(this), container.length ? $(window).is(container) ? (windowLeftEdge = container.scrollLeft(), windowTopEdge = container.scrollTop(), [windowLeftEdge, windowLeftEdge + container.width(), windowTopEdge + container.height(), windowLeftEdge]) : (containerWidth = container.width(), containerHeight = container.height(), containerTopPadding = parseFloat(container.css('paddingTop')) || 0, containerLeftPadding = parseFloat(container.css('paddingLeft')) || 0, containerTopBorder = parseFloat(container.css('borderTopWidth')) || 0, containerLeftBorder = parseFloat(container.css('borderLeftWidth')) || 0, topEdge = containerTopPadding + containerTopBorder, bottomEdge = topEdge + containerHeight, leftEdge = containerLeftPadding + containerLeftBorder, rightEdge = leftEdge + containerWidth, this.getPageRelativeBoundingBox(container, [topEdge, rightEdge, bottomEdge, leftEdge])) : void 0);
        if (!pageRelativeContainmentBounds) {
          return;
        }
        this.helperMargins = {
          top: parseFloat(this.$helper.css('marginTop')) || 0,
          right: parseFloat(this.$helper.css('marginRight')) || 0,
          bottom: parseFloat(this.$helper.css('marginBottom')) || 0,
          left: parseFloat(this.$helper.css('marginLeft')) || 0
        };
        this.helperSize = {
          height: this.$helper.outerHeight(),
          width: this.$helper.outerWidth()
        };
        if (this.helperMargins.top || this.helperMargins.right || this.helperMargins.bottom || this.helperMargins.left) {
          pageRelativeHelperBounds = this.getPageRelativeBoundingBox(this.$helper, [0, this.helperSize.width, this.helperSize.height, 0]);
          pageRelativeHelperBoundsWithMargin = this.getPageRelativeBoundingBox(this.$helper, [-this.helperMargins.top, this.helperSize.width + this.helperMargins.right, this.helperSize.height + this.helperMargins.bottom, -this.helperMargins.left]);
          pageRelativeContainmentBounds[0] -= pageRelativeHelperBoundsWithMargin[0] - pageRelativeHelperBounds[0];
          pageRelativeContainmentBounds[1] -= pageRelativeHelperBoundsWithMargin[1] - pageRelativeHelperBounds[1];
          pageRelativeContainmentBounds[2] -= pageRelativeHelperBoundsWithMargin[2] - pageRelativeHelperBounds[2];
          pageRelativeContainmentBounds[3] -= pageRelativeHelperBoundsWithMargin[3] - pageRelativeHelperBounds[3];
          if (pageRelativeContainmentBounds[0] > pageRelativeContainmentBounds[2]) {
            pageRelativeContainmentBounds[0] = pageRelativeContainmentBounds[2] = pageRelativeContainmentBounds[2] + (pageRelativeContainmentBounds[0] - pageRelativeContainmentBounds[2]) / 2;
          }
          if (pageRelativeContainmentBounds[1] < pageRelativeContainmentBounds[3]) {
            pageRelativeContainmentBounds[1] = pageRelativeContainmentBounds[3] = pageRelativeContainmentBounds[1] + (pageRelativeContainmentBounds[3] - pageRelativeContainmentBounds[1]) / 2;
          }
        }
        return pageRelativeContainmentBounds;
      };

      draggable.prototype.cancelAnyScheduledDrag = function() {
        if (!this.scheduledDragId) {
          return;
        }
        cancelAnimationFrame(this.scheduledDragId);
        return this.scheduledDragId = null;
      };

      getTransformMatrixString = function(element) {
        var computedStyle;
        if (!(computedStyle = getComputedStyle(element))) {
          return 'none';
        }
        return computedStyle.WebkitTransform || computedStyle.msTransform || computedStyle.MozTransform || computedStyle.OTransform || 'none';
      };

      draggable.prototype.getOffsetParentOrTransformedParent = function(element) {
        var $element, ancestor, foundAncestor, _i, _len, _ref;
        $element = $(element);
        foundAncestor = document.documentElement;
        _ref = $element.parents().get();
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          ancestor = _ref[_i];
          if ($(ancestor).css('position') !== 'static' || this.isTransformed(ancestor)) {
            foundAncestor = ancestor;
            break;
          }
        }
        return foundAncestor;
      };

      draggable.prototype.scheduleDrag = function(invocation) {
        var _this = this;
        this.cancelAnyScheduledDrag();
        return this.scheduledDragId = requestAnimationFrame(function() {
          invocation();
          return _this.scheduledDragId = null;
        });
      };

      draggable.prototype.synthesizeHelperByCloning = function(element) {
        var helper;
        helper = element.clone();
        helper.removeAttr('id');
        return this.prepareHelper(helper);
      };

      draggable.prototype.synthesizeHelperUsingFactory = function(factory, e) {
        var helper, output;
        output = factory(this.$element, e);
        helper = $(output).first();
        if (!helper.length) {
          throw new Error('[jQuery DragDrop – Draggable] Helper factory methods must produce a jQuery object, a DOM Element, or a string of HTML');
        }
        return this.prepareHelper(helper.first());
      };

      draggable.prototype.moveHelperToTopOfStack = function(stackConfig, e) {
        var $stackMembers, sortedStackMembers, topIndex, topStackMember;
        $stackMembers = $((typeof stackConfig === "function" ? stackConfig(this.$helper, e) : void 0) || stackConfig);
        if (!$stackMembers.length) {
          return;
        }
        sortedStackMembers = $stackMembers.get().sort(function(a, b) {
          return (parseInt($(b).css('zIndex'), 10) || 0) - (parseInt($(a).css('zIndex'), 10) || 0);
        });
        if (this.$helper.is(topStackMember = sortedStackMembers[0])) {
          return;
        }
        topIndex = $(topStackMember).css('zIndex');
        return this.$helper.css('zIndex', parseInt(topIndex, 10) + 1);
      };

      draggable.prototype.positionToPoint = function(position) {
        return new Point(position.left, position.top);
      };

      draggable.prototype.pointToPosition = function(point) {
        return {
          left: point.x,
          top: point.y
        };
      };

      draggable.prototype.prepareHelper = function($helper) {
        var css;
        css = {};
        if ($helper.css('position') !== 'absolute') {
          css.position = 'absolute';
        }
        css.left = this.elementStartPageOffset.x;
        css.top = this.elementStartPageOffset.y;
        return $helper.css(css);
      };

      draggable.prototype.cleanUp = function() {
        this.dragStarted = false;
        delete this.$helper;
        delete this.bounds;
        delete this.elementStartPageOffset;
        delete this.helperMargins;
        delete this.helperSize;
        delete this.helperStartPosition;
        delete this.mousedownEvent;
        delete this.originalPointerEventsPropertyValue;
        return delete this.parent;
      };

      return draggable;

    })(jQuery.dragdrop);
    return $.fn.draggable = function(options) {
      return this.each(function() {
        var plugin;
        if ($(this).data('draggable') == null) {
          plugin = new $.draggable(this, options);
          return $(this).data('draggable', plugin);
        }
      });
    };
  });

}).call(this);
