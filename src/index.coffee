'use strict'
module = null
try
  module = angular.module 'ndx'
catch e
  module = angular.module 'ndx', []
module.provider 'Confirmer', ->
  modalOpen = false
  styles = "
    <style type=\"text/css\">
      .confirm-backdrop {
        position: fixed;
        display: flex;
        justify-content: center;
        align-items: center;
        width: 100%;
        height: 100%;
        top: 0;
        left: 0;
        background: rgba(0,0,0,0.1);
        transition: 0.1s;
        opacity: 0;
        z-index: 9999
      }

      .confirm-backdrop .confirm-box {
        margin: 1rem;
        box-sizing: border-box;
        padding: 1rem;
        border-radius: 0.4rem;
        box-shadow: 0 0.61rem 1.28rem rgba(57,74,88,0.182);
        background: #fff;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        transition: 0.2s;
        opacity: 0;
        transform: translate3D(0, 50px, 0);
      }

      .confirm-backdrop.open {
        opacity: 1;
      }

      .confirm-backdrop.open .confirm-box {
        opacity: 1;
        transform: translate3D(0, 0, 0);
      }
    </style>
  "
  template = "
    <div class=\"confirm-backdrop {{class}}\" ng-click=\"backdropClick($event)\">
      <div class=\"confirm-box\" ng-click=\"boxClick($event)\"><i class=\"{{iconClass}}\">{{iconText}}</i>
        <h1 class=\"title\">{{title}}</h1>
        <div class=\"message\">{{message}}</div>
        <div class=\"controls\"> 
          <button class=\"btn ok {{okClass}}\" ng-click=\"ok()\">{{okText}}</button>
          <button class=\"btn cancel {{cancelClass}}\" ng-click=\"cancel()\">{{cancelText}}</button>
        </div>
      </div>
    </div>
  "
  setTemplate: (_template) ->
    template = _template
  setStyles: (_styles) ->
    styles = _styles
  $get: ($templateCache, $compile, $document, $window, $rootScope, $timeout, $q) ->
    body = $document.find('body').eq 0
    body.append styles
    confirm: (args) ->
      defer = $q.defer()
      myScope = (args.scope or $rootScope).$new()
      myScope.message = args.message or myScope.message
      myScope.title = args.title or myScope.title
      myScope.okText = args.okText or myScope.okText or 'OK'
      myScope.cancelText = args.cancelText or myScope.cancelText or 'Cancel'
      myScope.iconText = args.iconText or myScope.iconText
      myScope.okClass = args.okClass or myScope.okClass
      myScope.cancelClass = args.cancelClass or myScope.cancelClass
      myScope.iconClass = args.iconClass or myScope.iconClass
      backdropCancel = args.backdropCancel or myScope.backdropCancel
      animTime = 200
      if angular.isDefined args.animTime
        animTime = args.animTime
      com = null
      keyDown = (ev) ->
        if ev.keyCode is 27
          close()
      close = ->
        com.removeClass 'open'
        $window.removeEventListener 'keydown', keyDown
        $timeout ->
          modalOpen = false
          com.remove()
        , animTime
      open = ->
        if not modalOpen
          modalOpen = true
          if args.template
            el = $templateCache.get args.template
          else
            el = template
          com = $compile(el) myScope
          body.append com
          $window.addEventListener 'keydown', keyDown
          $timeout ->
            com.find('button')[0].focus()
            com.addClass 'open'
      myScope.ok = ->
        defer.resolve true
        close()
      myScope.cancel = ->
        defer.reject true
        close()
      myScope.boxClick = (ev) ->
        ev.stopPropagation()
      myScope.backdropClick = (ev) ->
        if backdropCancel
          myScope.cancel()
        ev.stopPropagation()
      open()
      defer.promise