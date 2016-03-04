
AtomProcessingView = require './atom-processing-view'
{CompositeDisposable} = require 'atom'
child_process = require 'child_process'

module.exports = AtomProcessing =
  atomProcessingView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @atomProcessingView = new AtomProcessingView(state.atomProcessingViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @atomProcessingView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'processing:run': => @runSketch()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @atomProcessingView.destroy()

  serialize: ->
    atomProcessingViewState: @atomProcessingView.serialize()

  toggle: ->
    console.log 'AtomProcessing was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()

  runSketch: ->
    editor = atom.workspace.getActiveTextEditor()
    file   = editor.getPath()
    arr    = file.split "/"
    path   = arr[0..arr.length-2].join "/"
    command = "processing-java --sketch=#{path} --output=#{path}/build --force --run"

    child_process.exec(command, (error, stdout, stderr) ->
        if error
          console.log error.stack
          console.log "Error code: #{error.code}"
          console.log "Signal: #{error.signal}"
        console.log "STDOUT: #{stdout}"
        console.log "STDERR: #{stderr}"
    )
