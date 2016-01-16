ReplLiteView = require './repl-lite-view'
_     = require('underscore')
nrepl = require('nrepl-client')

{CompositeDisposable} = require 'atom'

module.exports = ReplLite =
  replLiteView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @replLiteView = new ReplLiteView(state.replLiteViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @replLiteView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'repl-lite:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @replLiteView.destroy()

  serialize: ->
    replLiteViewState: @replLiteView.serialize()

  toggle: ->
    console.log 'ReplLite was toggled!'
    @conn = nrepl.connect({port: 50882, verbose: false})
    @conn.eval "(+ 1 2)", null, null, (err, messages) =>
      for m in messages
        console.log m

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
