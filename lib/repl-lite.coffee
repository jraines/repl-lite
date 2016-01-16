ReplLiteView = require './repl-lite-view'
_     = require('underscore')
nrepl = require('nrepl-client')
ReplLiteEditor = require('./repl-lite-editor')

{CompositeDisposable} = require 'atom'

module.exports = ReplLite =
  replLiteView: null
  modalPanel: null
  subscriptions: null


  activate: (state) ->
    @connectToPort = (p) =>
      @port = p
      @conn = nrepl.connect({port: @port, verbose: false})
      @conn.once 'connect', =>
        @replEditor = new ReplLiteEditor(@conn)

        @modalPanel.hide()

    @replLiteView = new ReplLiteView(state.replLiteViewState)
    @replLiteView.onPortEntered(@connectToPort)
    @modalPanel = atom.workspace.addModalPanel(item: @replLiteView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace',
      'repl-lite:toggle': => @toggle()
      'repl-lite:eval-selected': => @evalSelectedText()
      'repl-lite:clear': => @replEditor.clear()

  evalSelectedText: ->
    if editor = atom.workspace.getActiveTextEditor()
      @replEditor.sendToRepl(editor.getSelectedText().trim())

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @replLiteView.destroy()

  serialize: ->
    replLiteViewState: @replLiteView.serialize()

  toggle: ->
    if @conn
      @replEditor = new ReplLiteEditor(@conn)
    else
      if @modalPanel.isVisible()
        @modalPanel.hide()
      else
        @modalPanel.show()
