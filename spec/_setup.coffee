# In test mode, the requestAnimationFrame polyfill plays havoc with the specs. Disable it
window.requestAnimationFrame = (c) -> c (new Date().getTime())
window.cancelAnimationFrame = (id) -> # noop
