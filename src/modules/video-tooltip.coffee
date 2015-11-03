Quill   = require('../quill')
Tooltip = require('./tooltip')
_       = Quill.require('lodash')
dom     = Quill.require('dom')
Delta   = Quill.require('delta')
Range   = Quill.require('range')


class ViedoTooltip extends Tooltip
  @DEFAULTS:
    template:
     '<input class="input" type="textbox">
      <hr />
      <a href="javascript:;" class="cancel">Отмена</a>
      <a href="javascript:;" class="insert">Вставить</a>'

  constructor: (@quill, @options) ->
    @options = _.defaults(@options, Tooltip.DEFAULTS)
    super(@quill, @options)
    @textbox = @container.querySelector('.input')
    dom(@container).addClass('ql-video-tooltip')
    this.initListeners()

  initListeners: ->
    dom(@quill.root).on('focus', _.bind(this.hide, this))
    dom(@container.querySelector('.insert')).on('click', _.bind(this.insertVideo, this))
    dom(@container.querySelector('.cancel')).on('click', _.bind(this.hide, this))
    this.initTextbox(@textbox, this.insertVideo, this.hide)
    @quill.onModuleLoad('toolbar', (toolbar) =>
      @toolbar = toolbar
      toolbar.initFormat('video', _.bind(this._onToolbar, this))
    )

  insertVideo: ->
    url = this._normalizeURL(@textbox.value)
    @range = new Range(0, 0) unless @range?   # If we lost the selection somehow, just put image at beginning of document
    if @range
      @textbox.value = ''
      index = @range.end
      @quill.insertEmbed(index, 'video', url, 'user')
      @quill.setSelection(index + 1, index + 1)
    this.hide()

  _onToolbar: (range, value) ->
    if value
      @textbox.value = 'https://www.youtube.com/embed/код-видео' unless @textbox.value
      this.show()
      @textbox.focus()
      _.defer( =>
        @textbox.setSelectionRange(@textbox.value.length, @textbox.value.length)
      )
    else
      @quill.deleteText(range, 'user')

  _matchVideoURL: (url) ->
    return true

  _normalizeURL: (url) ->
    return url


Quill.registerModule('video-tooltip', ViedoTooltip)
module.exports = ViedoTooltip
