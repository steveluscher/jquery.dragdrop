# jquery.dragdrop [![Build Status](https://travis-ci.org/steveluscher/jquery.dragdrop.png)](https://travis-ci.org/steveluscher/jquery.dragdrop)

You are looking at a developmental version of jQuery DragDrop. This library is not yet ready for use.

This project is distinct from jQuery UI Draggable/Droppable in its approach. jQuery UI implements a drag manager that performs collision detection between objects as you drag. The primary benefit of this approach is the ability to specify various [collision modes](http://api.jqueryui.com/droppable/#option-tolerance), such as “fit,” “intersect,” and “touch.”

The cost of implementing a drag manager to support those collision modes is massive.

                                                                  | jQuery UI       | jQuery DragDrop
------------------------------------------------------------------|:---------------:|:--------------:
Drop zones are z-index stackable                                  | :no_entry_sign: | :+1:
Draggables and drop zones can be transformed using CSS Transforms | :no_entry_sign: | :+1:

jQuery DragDrop trades sophisticated collision detection for performance, simplicity, and durability.

## Building

Clone the repository

    git clone https://github.com/steveluscher/jquery.dragdrop.git
    cd jquery.dragdrop

Install the build system globally

    npm install -g grunt

Install all required Node modules

    npm install

Build it!

    grunt build # The built files will be found in ./dist/

## Version

v0.1.0-dev

## Website Url

https://github.com/steveluscher/jquery.dragdrop

## Bug tracker

If you find a bug or have a suggestion, please [raise the issue here](https://github.com/steveluscher/jquery.dragdop/issues) on Github!

## Documentation

    $('#draggable').draggable();
