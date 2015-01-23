# The MIT License (MIT)

# Typed.js | Copyright (c) 2014 Matt Boldt | www.mattboldt.com

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
$ ->
  "use strict"
  Typed = (el, options) ->
    
    # chosen element to manipulate text
    @el = $(el)
    
    # options
    @options = $.extend({}, $.fn.typed.defaults, options)
    
    # attribute to type into
    @isInput = @el.is("input")
    @attr = @options.attr
    
    # show cursor
    @showCursor = (if @isInput then false else @options.showCursor)
    
    # text content of element
    @elContent = (if @attr then @el.attr(@attr) else @el.text())
    
    # html or plain text
    @contentType = @options.contentType
    
    # typing speed
    @typeSpeed = @options.typeSpeed
    
    # add a delay before typing starts
    @startDelay = @options.startDelay
    
    # backspacing speed
    @backSpeed = @options.backSpeed
    
    # amount of time to wait before backspacing
    @backDelay = @options.backDelay
    
    # input strings of text
    @strings = @options.strings
    
    # character number position of current string
    @strPos = 0
    
    # current array position
    @arrayPos = 0
    
    # number to stop backspacing on.
    # default 0, can change depending on how many chars
    # you want to remove at the time
    @stopNum = 0
    
    # Looping logic
    @loop = @options.loop
    @loopCount = @options.loopCount
    @curLoop = 0
    
    # for stopping
    @stop = false
    
    # custom cursor
    @cursorChar = @options.cursorChar
    
    # All systems go!
    @build()
    return

  Typed:: =
    constructor: Typed
    init: ->
      
      # begin the loop w/ first current string (global self.string)
      # current string will be passed as an argument each time after this
      self = this
      self.timeout = setTimeout(->
        
        # Start typing
        self.typewrite self.strings[self.arrayPos], self.strPos
        return
      , self.startDelay)
      return

    build: ->
      
      # Insert cursor
      if @showCursor is true
        @cursor = $("<span class=\"typed-cursor\">" + @cursorChar + "</span>")
        @el.after @cursor
      @init()
      return

    
    # pass current string state to each function, types 1 char per call
    typewrite: (curString, curStrPos) ->
      
      # exit when stopped
      return  if @stop is true
      
      # varying values for setTimeout during typing
      # can't be global since number changes each time loop is executed
      humanize = Math.round(Math.random() * (100 - 30)) + @typeSpeed
      self = this
      
      # ------------- optional ------------- //
      # backpaces a certain string faster
      # ------------------------------------ //
      # if (self.arrayPos == 1){
      #  self.backDelay = 50;
      # }
      # else{ self.backDelay = 500; }
      
      # contain typing function in a timeout humanize'd delay
      self.timeout = setTimeout(->
        
        # check for an escape character before a pause value
        # format: \^\d+ .. eg: ^1000 .. should be able to print the ^ too using ^^
        # single ^ are removed from string
        charPause = 0
        substr = curString.substr(curStrPos)
        if substr.charAt(0) is "^"
          skip = 1 # skip atleast 1
          if /^\^\d+/.test(substr)
            substr = /\d+/.exec(substr)[0]
            skip += substr.length
            charPause = parseInt(substr)
          
          # strip out the escape character and pause value so they're not printed
          curString = curString.substring(0, curStrPos) + curString.substring(curStrPos + skip)
        if self.contentType is "html"
          
          # skip over html tags while typing
          if curString.substr(curStrPos).charAt(0) is "<"
            tag = ""
            while curString.substr(curStrPos).charAt(0) isnt ">"
              tag += curString.substr(curStrPos).charAt(0)
              curStrPos++
            curStrPos++
            tag += ">"
        
        # timeout for any pause after a character
        self.timeout = setTimeout(->
          if curStrPos is curString.length
            
            # fires callback function
            self.options.onStringTyped self.arrayPos
            
            # is this the final string
            if self.arrayPos is self.strings.length - 1
              
              # animation that occurs on the last typed string
              self.options.callback()
              self.curLoop++
              
              # quit if we wont loop back
              return  if self.loop is false or self.curLoop is self.loopCount
            self.timeout = setTimeout(->
              self.backspace curString, curStrPos
              return
            , self.backDelay)
          else
            
            # call before functions if applicable 
            self.options.preStringTyped self.arrayPos  if curStrPos is 0
            
            # start typing each new char into existing string
            # curString: arg, self.el.html: original text inside element
            nextString = self.elContent + curString.substr(0, curStrPos + 1)
            if self.attr
              self.el.attr self.attr, nextString
            else
              if self.contentType is "html"
                self.el.html nextString
              else
                self.el.text nextString
            
            # add characters one by one
            curStrPos++
            
            # loop the function
            self.typewrite curString, curStrPos
          return
        
        # end of character pause
        , charPause)
        return
      
      # humanized value for typing
      , humanize)
      return

    backspace: (curString, curStrPos) ->
      
      # exit when stopped
      return  if @stop is true
      
      # varying values for setTimeout during typing
      # can't be global since number changes each time loop is executed
      humanize = Math.round(Math.random() * (100 - 30)) + @backSpeed
      self = this
      self.timeout = setTimeout(->
        
        # ----- this part is optional ----- //
        # check string array position
        # on the first string, only delete one word
        # the stopNum actually represents the amount of chars to
        # keep in the current string. In my case it's 14.
        # if (self.arrayPos == 1){
        #  self.stopNum = 14;
        # }
        #every other time, delete the whole typed string
        # else{
        #  self.stopNum = 0;
        # }
        if self.contentType is "html"
          
          # skip over html tags while backspacing
          if curString.substr(curStrPos).charAt(0) is ">"
            tag = ""
            while curString.substr(curStrPos).charAt(0) isnt "<"
              tag -= curString.substr(curStrPos).charAt(0)
              curStrPos--
            curStrPos--
            tag += "<"
        
        # ----- continue important stuff ----- //
        # replace text with base text + typed characters
        nextString = self.elContent + curString.substr(0, curStrPos)
        if self.attr
          self.el.attr self.attr, nextString
        else
          if self.contentType is "html"
            self.el.html nextString
          else
            self.el.text nextString
        
        # if the number (id of character in current string) is
        # less than the stop number, keep going
        if curStrPos > self.stopNum
          
          # subtract characters one by one
          curStrPos--
          
          # loop the function
          self.backspace curString, curStrPos
        
        # if the stop number has been reached, increase
        # array position to next string
        else if curStrPos <= self.stopNum
          self.arrayPos++
          if self.arrayPos is self.strings.length
            self.arrayPos = 0
            self.init()
          else
            self.typewrite self.strings[self.arrayPos], curStrPos
        return
      
      # humanized value for typing
      , humanize)
      return

    
    # Start & Stop currently not working
    
    # , stop: function() {
    #     var self = this;
    
    #     self.stop = true;
    #     clearInterval(self.timeout);
    # }
    
    # , start: function() {
    #     var self = this;
    #     if(self.stop === false)
    #        return;
    
    #     this.stop = false;
    #     this.init();
    # }
    
    # Reset and rebuild the element
    reset: ->
      self = this
      clearInterval self.timeout
      id = @el.attr("id")
      @el.after "<span id=\"" + id + "\"/>"
      @el.remove()
      @cursor.remove()
      
      # Send the callback
      self.options.resetCallback()
      return

  $.fn.typed = (option) ->
    @each ->
      $this = $(this)
      data = $this.data("typed")
      options = typeof option is "object" and option
      $this.data "typed", (data = new Typed(this, options))  unless data
      data[option]()  if typeof option is "string"
      return


  $.fn.typed.defaults =
    strings: [
      "These are the default values..."
      "You know what you should do?"
      "Use your own!"
      "Have a great day!"
    ]
    
    # typing speed
    typeSpeed: 0
    
    # time before typing starts
    startDelay: 0
    
    # backspacing speed
    backSpeed: 0
    
    # time before backspacing
    backDelay: 500
    
    # loop
    loop: false
    
    # false = infinite
    loopCount: false
    
    # show cursor
    showCursor: true
    
    # character for cursor
    cursorChar: "|"
    
    # attribute to type (null == text)
    attr: null
    
    # either html or text
    contentType: "html"
    
    # call when done callback function
    callback: ->

    
    # starting callback function before each string
    preStringTyped: ->

    
    #callback for every typed string
    onStringTyped: ->

    
    # callback for reset
    resetCallback: ->

  return
(window.jQuery)