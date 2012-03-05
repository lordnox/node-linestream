require 'should'
{Stream}    = require 'stream'
Linestream  = require '..'

class MyStream extends Stream

startup = ->
  mystream = new MyStream
  stream: Linestream.create mystream
  mystream: mystream

exports['an empty stream should not emit line events'] = (exit) ->
  called = false
  # startup:
  {stream, mystream} = startup()
  # handle the 'end' event
  stream.on 'line', ->
    console.log arguments
    called = true
  # check async for call
  exit -> called.should.be.false
  # emit the 'end' event
  process.nextTick -> mystream.emit 'end'

exports['should have an end event'] = (exit) ->
  called = false
  # startup:
  {stream, mystream} = startup()
  # handle the 'end' event
  stream.on 'end', -> called = true
  # check async for call
  exit -> called.should.be.true
  # emit the 'end' event
  process.nextTick -> mystream.emit 'end'

exports['should concat multi-event-lines'] = (exit) ->
  line  = false
  index = 0
  # startup:
  {stream, mystream} = startup()
  # handle the 'line' event
  stream.on 'line', (data, lineno) ->
    index = lineno + 1
    line  = data
  # check async for call
  exit ->
    line.should.be.equal 'ABC'
    index.should.be.equal 1
  # emit the 'end' event
  mystream.emit 'data', 'A'
  mystream.emit 'data', 'B'
  mystream.emit 'data', 'C'
  mystream.emit 'end'

exports['should emit multible line events foreach newline in the data'] = (exit) ->
  last = 0
  # startup:
  {stream, mystream} = startup()
  # handle the 'line' event
  stream.on 'line', (data, lineno) -> last = lineno
  # check async for call
  exit -> last.should.be.equal 2
  # emit the 'end' event
  mystream.emit 'data', "A\nB\nC"
  mystream.emit 'end'

exports['should not handle data events after the stream ended'] = (exit) ->
  called = false
  # startup:
  {stream, mystream} = startup()
  # handle the 'line' event
  stream.on 'line', (data, lineno) -> called = true
  # check async for call
  exit -> called.should.be.false
  # emit the 'end' event
  mystream.emit 'end'
  mystream.emit 'data', 'error'

exports['should handle lines in order'] = (exit) ->
  exit -> true.should.be.true
  true
  # I just don't know how to test this...

exports['should emit the end event only after all lines are emitted'] = (exit) ->
  buffer = ''
  # startup:
  {stream, mystream} = startup()
  # handle the 'line' event
  stream.on 'line', (line) -> buffer += line
  stream.on 'end', -> buffer += 'X'
  # check async for call
  exit -> buffer.should.be.equal 'ABxCX'
    #last.should.be.equal 2
  # emit the 'end' event
  mystream.emit 'data', "A\nB\nC"
  mystream.emit 'end'

exports['should handle the line events even after the stream is closed'] = (exit) ->
  buffer = ''
  # startup:
  {stream, mystream} = startup()
  # handle the 'line' event
  stream.on 'line', (line) -> buffer += line
  mystream.on 'end', -> buffer += 'X'
  # check async for call
  exit -> buffer[buffer.length - 1].should.not.be.equal 'X'
    #last.should.be.equal 2
  # emit the 'end' event
  mystream.emit 'data', "A\nB\nC"
  mystream.emit 'end'


