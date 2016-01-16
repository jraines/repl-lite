module.exports =
class ReplLiteEditor
  constructor: (conn) ->
    @conn = conn
    @ns = "user"
    atom.workspace.open("Clojure REPL", split:'right').done (textEditor) =>
      @textEditor = textEditor
      grammar = atom.grammars.grammarForScopeName('source.clojure')
      @textEditor.setGrammar(grammar)
      @textEditor.isModified = -> false
      @appendText("Connected on port #{@conn.remotePort}")
      @appendPrompt()

  clear: ->
    @textEditor?.setText("")

  appendText: (text)->
    text = "\n#{text}"
    @textEditor?.getBuffer().append(text)
    @textEditor?.scrollToBottom()

  # Appends the namespace prompt
  appendPrompt: ()->
    @appendText("\n#{@ns}=> ")

  sendToRepl: (text) ->
    @conn?.eval text, @ns, (err, messages) =>
      for msg in messages
        if msg.value
          @appendText(msg.value)
          @ns = msg.ns
      @appendPrompt()