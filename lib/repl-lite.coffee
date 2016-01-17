ReplLiteView = require './repl-lite-view'
_     = require('underscore')
nrepl = require('nrepl-client')
ReplLiteEditor = require('./repl-lite-editor')
EditorUtils = require('./editor-utils')

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
      'repl-lite:eval-sexp': => @evalBlock()
      'repl-lite:eval-block': => @evalBlock({topLevel: true})
      'repl-lite:set-last-code': => @replEditor.populateLastCode()
      'repl-lite:clear': => @replEditor.clear()
      'repl-lite:pprint-last': => @replEditor.pprintLastVal()

  evalSelectedText: ->
    if editor = atom.workspace.getActiveTextEditor()
      @replEditor.sendToRepl(editor.getSelectedText().trim())

  evalBlock: (options={})->
    if editor = atom.workspace.getActiveTextEditor()
      if range = EditorUtils.getCursorInBlockRange(editor, options)
        text = editor.getTextInBufferRange(range).trim()

        # Highlight the area that's being executed temporarily
        marker = editor.markBufferRange(range)
        decoration = editor.decorateMarker(marker,
            {type: 'highlight', class: "block-execution"})
        # Remove the highlight after a short period of time
        setTimeout(=>
          marker.destroy()
        , 350)

        @replEditor.sendToRepl(text)

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
