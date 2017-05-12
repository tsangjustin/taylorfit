!function(){this.global=this,this.window=this}(),function(e){function n(s){if(t[s])return t[s].exports;var r=t[s]={exports:{},id:s,loaded:!1};return e[s].call(r.exports,r,r.exports,n),r.loaded=!0,r.exports}var t={};return n.m=e,n.c=t,n.p="",n(0)}([/*!************************!*\
  !*** multi subworkers ***!
  \************************/
function(module,exports,__webpack_require__){eval("module.exports = __webpack_require__(/*! /Users/tsukumo/Dropbox/school/2017-spring/jack/cs-424/taylorfit/engine/worker/subworkers.js */2);\n\n\n//////////////////\n// WEBPACK FOOTER\n// multi subworkers\n// module id = 0\n// module chunks = 3\n//# sourceURL=webpack:///multi_subworkers?")},,/*!*************************************!*\
  !*** ./engine/worker/subworkers.js ***!
  \*************************************/
function(module,exports){eval("(function(){\n\n  /* Detect if we're in a worker or not */\n  var isWorker = false;\n  try {\n    document;\n  } catch (e){\n    isWorker = true;\n  }\n\n  if (isWorker){\n    if (!self.Worker){\n      self.Worker = function(path){\n        var that = this;\n        this.id = Math.random().toString(36).substr(2, 5);\n\n        this.eventListeners = {\n          \"message\": []\n        };\n        self.addEventListener(\"message\", function(e){\n          if (e.data._from === that.id){\n            var newEvent = new MessageEvent(\"message\");\n            newEvent.initMessageEvent(\"message\", false, false, e.data.message, that, \"\", null, []);\n            that.dispatchEvent(newEvent);\n            if (that.onmessage){\n              that.onmessage(newEvent);\n            }\n          }\n        });\n\n        var location = self.location.pathname;\n        var absPath = location.substring(0, location.lastIndexOf('/')) + '/' + path;\n        self.postMessage({\n          _subworker: true,\n          cmd: 'newWorker',\n          id: this.id,\n          path: absPath\n        });\n      };\n      Worker.prototype = {\n        onerror: null,\n        onmessage: null,\n        postMessage: function(message){\n          self.postMessage({\n            _subworker: true,\n            id: this.id,\n            cmd: 'passMessage',\n            message: message\n          });\n        },\n        terminate: function(){\n          self.postMessage({\n            _subworker: true,\n            cmd: 'terminate',\n            id: this.id\n          });\n        },\n        addEventListener: function(type, listener, useCapture){\n          if (this.eventListeners[type]){\n            this.eventListeners[type].push(listener);\n          }\n        },\n        removeEventListener: function(type, listener, useCapture){\n          if(!(type in this.eventListeners)) return;\n          var index = this.eventListeners[type].indexOf(listener);\n          if (index !== -1){\n            this.eventListeners[type].splice(index, 1);\n          }\n        },\n        dispatchEvent: function(event){\n          var listeners = this.eventListeners[event.type];\n          for (var i = 0; i < listeners.length; i++) {\n            listeners[i](event);\n          }\n        }\n      };\n    }\n  }\n\n  var allWorkers = {};\n  var cmds = {\n    newWorker: function(event){\n      var worker = new Worker(event.data.path);\n      worker.addEventListener(\"message\", function(e){\n        var envelope = {\n          _from: event.data.id,\n          message: e.data\n        }\n        event.target.postMessage(envelope);\n      });\n      allWorkers[event.data.id] = worker;\n    },\n    terminate: function(event){\n      allWorkers[event.data.id].terminate();\n    },\n    passMessage: function(event){\n      allWorkers[event.data.id].postMessage(event.data.message);\n    }\n  }\n  var messageRecieved = function(event){\n    if (event.data._subworker){\n      cmds[event.data.cmd](event);\n    }\n  };\n\n\n  /* Hijack Worker */\n  var oldWorker = Worker;\n  Worker = function(path){\n    if (this.constructor !== Worker){\n      throw new TypeError(\"Failed to construct 'Worker': Please use the 'new' operator, this DOM object constructor cannot be called as a function.\");\n    }\n\n    var blobIndex = path.indexOf('blob:');\n    \n    if (blobIndex !== -1 && blobIndex !== 0 ) {\n      path = path.substring(blobIndex);\n    }\n\n    var newWorker = new oldWorker(path);\n    newWorker.addEventListener(\"message\", messageRecieved);\n\n    return newWorker;\n  };\n\n})();\n\n\n//////////////////\n// WEBPACK FOOTER\n// ./engine/worker/subworkers.js\n// module id = 2\n// module chunks = 0 1 3\n//# sourceURL=webpack:///./engine/worker/subworkers.js?")}]);