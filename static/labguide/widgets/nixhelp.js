// Read-only reference. nix-commands.json is hand-written; edit it and rebuild.
// Shape: { "Category": [ { cmd, desc } ] }
import App from 'resource:///com/github/Aylur/ags/app.js';
import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';

const SOURCE = `${App.configDir}/nix-commands.json`;

const Notice = (text) => Widget.Label({ className: 'notice', xalign: 0, wrap: true, label: text });

// String() guards a missing cmd or desc: AGS reads a null prop as a binding and throws.
const Row = ({ cmd, desc }) => Widget.Box({
    className: 'cmd-row',
    children: [
        Widget.Label({ className: 'cmd', xalign: 0, label: String(cmd ?? '') }),
        Widget.Label({
            className: 'cmd-desc',
            xalign: 0,
            hexpand: true,
            wrap: true,
            label: String(desc ?? ''),
        }),
    ],
});

const Intro = (text) => Widget.Label({ className: 'intro', xalign: 0, wrap: true, label: text });

const Category = (name, entries) => Widget.Box({
    vertical: true,
    children: [
        Widget.Label({ className: 'category', xalign: 0, label: name }),
        ...entries.map(Row),
    ],
});

const read = () => {
    const raw = Utils.readFile(SOURCE);
    if (!raw)
        throw new Error(`${SOURCE} is missing or empty`);
    return JSON.parse(raw);
};

export const NixHelp = () => {
    let children;
    try {
 children = Object.entries(read()).map(([name, entries]) =>
            typeof entries === 'string' ? Intro(entries) : Category(name, entries));

    } catch (err) {
        children = [Notice(`Commands unavailable: ${err.message}`)];
    }
    return Widget.Scrollable({
        className: 'scroll',
        hscroll: 'never',
        vexpand: true,
        child: Widget.Box({ vertical: true, children }),
    });
};
