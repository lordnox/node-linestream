###
  @author Tobias Kopelke <nox@demoncode.de>

  The Linestream class will take any stream that emits a 'data'
  and an 'end' event and converts the content that is streamed
  into a string, splits it by '\n' and emits a 'line' event for
  each line found.
  The class ensures that the line events will be emitted in order
  and have the line-number as a second parameter.
  When the 'end' event is emitted the class will not accept
  anymore content.

  @TODO find a way to offset a stream
  @TODO pause & resume handles
###
Stream  = require 'stream'

class Linestream extends Stream
  constructor: (stream) ->
    # A buffer that contains the remainder of a line
    # to prevent emitting 2 lines where only is one
    buffer    = null
    # buffer array to emit
    lines     = []
    # line index
    line      = 0
    # Flag if we are waiting for the process emitting
    # the current line. Only after it is emitted we
    # allow the emitting of the next line
    emitting  = false
    # Flag if the end event was emitted
    ended     = false
    # Flag to stop emitting anything
    # true when ended and lines.length = 0
    done      = false

    # emit-handler
    emit = =>
      # do not emit while waiting or we are done
      return if emitting or done or not lines.length
      emitting = true
      # get the current line and emit it
      current = lines.shift()
      @emit 'line', current, line++ if current isnt null
      # emit the 'end' event if there are no more lines and
      # we have handled the 'end' event from the stream
      if ended and not lines.length
        @emit 'end'

    @on 'line', =>
      # on-line handler, emit more or wait for more content
      emitting = false
      return done = ended or done if not lines.length or done
      process.nextTick emit

    stream.on 'data', (data) ->
      # done do anything if we are done
      return if ended
      # convert to string and add the old buffer
      str       = (buffer or '') + data.toString()
      # split by '\n'
      splitted  = str.split "\n"
      # take the last element and put it in the buffer
      buffer    = splitted.pop()
      # append all new found lines to the lines array
      lines.push.apply lines, splitted
      # and start the emitter
      emit()

    stream.on 'end', ->
      # done do anything if we are done
      return if ended
      # set the ended flag
      ended = true
      # put the buffer into the lines array
      lines.push buffer
      # and start the emitter
      emit()

    stream.on 'error', (err) =>
      @emit 'error', err

Linestream.create = (stream) ->
  new Linestream stream

module.exports = Linestream
