// Outer frame: left half launcher, right half reference.
import Widget from 'resource:///com/github/Aylur/ags/widget.js';

import { Applications } from './apps.js';
import { Packages } from './packages.js';
import { Fastfetch } from './fastfetch.js';
import { Banner } from './banner.js';
import { NixHelp } from './nixhelp.js';

// grow=false sizes to content vertically; wide=false sizes to content horizontally.
const Pane = (title, child, { cls = '', grow = true, wide = true } = {}) => Widget.Box({
    className: `pane ${cls}`,
    vertical: true,
    hexpand: wide,
    vexpand: grow,
    children: [
        Widget.Label({ className: 'pane-title', xalign: 0, label: title.toUpperCase() }),
        child,
    ],
});

export const Layout = () => Widget.Box({
    className: 'desktop',
    children: [
        // hexpand false: the launcher takes its natural width, the reference half
        // absorbs everything left over.
        Widget.Box({
            className: 'half launcher',
            hexpand: false,
            children: [
                Pane('Applications', Applications(), { cls: 'pane-apps' }),
                Pane('Packages', Packages(), { cls: 'pane-packages', wide: false }),
            ],
        }),
        Widget.Box({
            className: 'half reference',
            vertical: true,
            hexpand: true,
            children: [
                Pane('System', Widget.Box({
                    className: 'system-row',
                    spacing: 32,
                    children: [Fastfetch(), Banner()],
                }), { cls: 'pane-system', grow: false }),
                Pane('Cheatsheet', NixHelp(), { cls: 'pane-nix' }),
            ],
        }),
    ],
});
