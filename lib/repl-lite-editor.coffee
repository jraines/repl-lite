module.exports =
class ReplLiteEditor
  constructor: (conn) ->
    @conn = conn
    @conn.clone (err, messages)=>
      @session = messages[0]["new-session"]
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
    @appendPrompt()

  appendText: (text)->
    text = "\n#{text}"
    @textEditor?.getBuffer().append(text)

  # Appends the namespace prompt
  appendPrompt: ->
    @appendText("\n#{@ns}=> ")
    @positionCursor()

  positionCursor: ->
    lastRow = @textEditor.getLastBufferRow()
    @textEditor.setCursorBufferPosition [lastRow, 0]
    @textEditor.moveToEndOfLine()
    @textEditor.scrollToBottom()

  pprintLastVal: ->
    @sendToRepl "(pprint #{@lastCode})"

  populateLastCode: ->
    pos = @textEditor.getCursorBufferPosition()
    @textEditor.setTextInBufferRange([pos, pos], @lastCode)

  sendToRepl: (text) ->
    @conn?.eval text, @ns, @session, (err, messages) =>
      for msg in messages
        if msg.err
          @appendText(msg.err)
        else if msg.out
          @appendText(msg.out)
        else if msg.value
          @lastCode = text
          @appendText(msg.value)
          @ns = msg.ns
      @appendPrompt()
