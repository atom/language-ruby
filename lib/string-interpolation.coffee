module.exports =
  activate: (state) ->
    atom.workspaceView.command "string-interpolation:insert", => @insert()

  insert: ->
    editor = atom.workspace.activePaneItem
    if editor.getCursorScopes().indexOf("string.quoted.double.interpolated.ruby") != -1
      selection = editor.getSelection()
      selection.insertText("\#{#{selection.getText()}}")
      if selection.getText().length == 0
        editor.moveCursorLeft()
    else
      editor.insertText('#')
