// Curated column: packages.json is written at build time by modules/apps/labguide.nix.
// Shape: [ { name, desc, exec, icon } ]
import App from 'resource:///com/github/Aylur/ags/app.js';
import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';

const SOURCE = `${App.configDir}/packages.json`;
const FALLBACK_ICON = 'utilities-terminal';

const Notice = (text) => Widget.Label({ className: 'notice', xalign: 0, wrap: true, label: text });

const read = () => {
    const raw = Utils.readFile(SOURCE);
    if (!raw)
        throw new Error(`${SOURCE} is missing or empty — rebuild to regenerate it`);
    return JSON.parse(raw);
};

const Entry = (pkg) => Widget.Button({
    className: 'entry',
    hexpand: true,
    tooltipText: pkg.desc || pkg.name,
    onClicked: () => Utils.execAsync(pkg.exec)
        .catch(err => console.error(`labguide: ${pkg.exec} failed: ${err}`)),
    child: Widget.Box({
        spacing: 14,
        children: [
            Widget.Icon({ icon: pkg.icon || FALLBACK_ICON, size: 22 }),
            Widget.Label({ className: 'entry-name', xalign: 0, label: pkg.name }),
        ],
    }),
});

export const Packages = () => {
    let children;
    try {
        children = read().map(Entry);
    } catch (err) {
        children = [Notice(`Packages unavailable: ${err.message}`)];
    }
    return Widget.Scrollable({
        className: 'scroll',
        hscroll: 'never',
        vexpand: true,
        child: Widget.Box({ vertical: true, children }),
    });
};
