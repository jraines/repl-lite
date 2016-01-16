{Emitter} = require 'atom'

module.exports =
class ReplLiteView
  constructor: (serializedState) ->
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('repl-lite')
    @emitter = new Emitter()

    input = document.createElement('input')
    input.classList.add('repl-port-input')
    input.placeholder = "Enter Your nREPL port"
    input.focus()
    input.onkeyup = (e) =>
      if e.which is 13
        @emitter.emit "repl-lite:port-entered", e.target.value

    @element.appendChild(input)

  onPortEntered: (callback) ->
    @emitter.on 'repl-lite:port-entered', callback

  update: (text) ->
    message = document.createElement('div')
    message.textContent = text
    message.classList.add('message')
    @element.appendChild(message)

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element
