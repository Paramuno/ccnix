// System readout. .poll() is tied to the widget's lifetime, so no manual teardown.
import App from 'resource:///com/github/Aylur/ags/app.js';
import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';

const REFRESH_MS = 30000;
const CONFIG = `${App.configDir}/fastfetch.jsonc`;

export const Fastfetch = () => Widget.Label({
    className: 'fastfetch',
    xalign: 0,
    yalign: 0,
    vexpand: false,
    label: 'Reading system info…',
}).poll(REFRESH_MS, self => Utils
    .execAsync(['fastfetch', '--pipe', '-c', CONFIG])
    .then(out => self.label = out.trim())
    .catch(err => self.label = `fastfetch failed:\n${err}`));
