// agsdesk — desktop widget, second AGS instance (bus name: agsdesk).
// Imports no Hyprland service, so it also runs under Plasma 6 Wayland.
import App from 'resource:///com/github/Aylur/ags/app.js';
import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import Gdk from 'gi://Gdk';

import { Layout } from './widgets/layout.js';

const Desktop = (monitor) => Widget.Window({
    name: `agsdesk-${monitor}`,
    monitor,
    layer: 'bottom',          // above hyprpaper's background, below normal windows
    exclusivity: 'ignore',    // never reserve space from other clients
    anchor: ['top', 'bottom', 'left', 'right'],
    child: Layout(),
});

const monitorCount = Gdk.Display.get_default()?.get_n_monitors() ?? 1;

App.config({
    style: `${App.configDir}/style.css`,
    windows: Array.from({ length: monitorCount }, (_, i) => Desktop(i)),
});
