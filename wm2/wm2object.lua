-- WM2Object implements class based logging utilities.
--
local class = require('wm2.lib.middleclass')
local log = require('wm2.lib.log')
local WM2Object = class('wm2object')

function WM2Object:initialize(wm2, replication_key)
    self._logpreamble = tostring(self) .. ':'
end

function clslog(f)
    return function(self, ...)
        local arg = {...}
        f(self._logpreamble, table.unpack(arg))
    end
end

WM2Object.trace = clslog(log.trace)
WM2Object.debug = clslog(log.debug)
WM2Object.info = clslog(log.info)
WM2Object.warn = clslog(log.warn)
WM2Object.error = clslog(log.error)
WM2Object.fatal = clslog(log.fatal)

return WM2Object
