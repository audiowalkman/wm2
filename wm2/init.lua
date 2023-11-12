local wm2 = {name="wm2", version="0.1.0"}

wm2.utils = require('wm2.utils')
wm2.WM2Object = require('wm2.wm2object')

wm2.SmolId = require('wm2.smolid')
wm2.SmolState = require('wm2.smolstate')
wm2.SmolP = require('wm2.smolp')
wm2.SmolCsound = require('wm2.smolcsound')
wm2.SmolTui = require('wm2.smoltui')

wm2.Server = require('wm2.server')

wm2.Patch = require('wm2.patch')
wm2.register_smolp, wm2.parse_yml = require('wm2.parser')

return wm2
