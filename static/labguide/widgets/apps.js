// Launcher column: .desktop entries grouped by hand via app-groups.json.
// Anything unmatched falls into "Other", so a newly installed app never disappears.
import App from 'resource:///com/github/Aylur/ags/app.js';
import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';
import Apps from 'resource:///com/github/Aylur/ags/service/applications.js';

const SOURCE = `${App.configDir}/app-groups.json`;
const COLUMNS = 2;
const FALLBACK_ICON = 'application-x-executable';

const Notice = (text) => Widget.Label({ className: 'notice', xalign: 0, wrap: true, label: text });

const Entry = (app) => Widget.Button({
    className: 'entry',
    hexpand: true,
    tooltipText: app.description || app.name,
    onClicked: () => {
        try {
            app.launch();
        } catch (err) {
            console.error(`labguide: launch failed for ${app.name}: ${err}`);
        }
    },
    child: Widget.Box({
        spacing: 14,
        children: [
            Widget.Icon({ icon: app.icon_name || FALLBACK_ICON, size: 22 }),
            Widget.Label({ className: 'entry-name', xalign: 0, label: app.name, truncate: 'end' }),
        ],
    }),
});

// Round-robin into N vertical boxes: reading order stays left-to-right.
const Columns = (apps) => {
    const cols = Array.from({ length: COLUMNS }, () => []);
    apps.forEach((app, i) => cols[i % COLUMNS].push(Entry(app)));
    return Widget.Box({
        className: 'columns',
        homogeneous: true,
        children: cols.map(children => Widget.Box({ vertical: true, hexpand: true, children })),
    });
};

const Group = (name, apps) => Widget.Box({
    vertical: true,
    children: [
        Widget.Label({ className: 'category', xalign: 0, label: name }),
        Columns(apps),
    ],
});

const matches = (app, patterns) => {
    const name = app.name.toLowerCase();
    const id = (app.app?.get_id?.() ?? '').toLowerCase();
    return patterns.some(p => {
        const needle = p.toLowerCase();
        return name.includes(needle) || id.includes(needle);
    });
};

const build = () => {
    const raw = Utils.readFile(SOURCE);
    if (!raw)
        throw new Error(`${SOURCE} is missing or empty — every app falls into Other without it`);
    const { _hidden = [], ...groups } = JSON.parse(raw);
    const all = Apps.query('').filter(app => !matches(app, _hidden));
    const claimed = new Set();
    const out = [];

    for (const [name, patterns] of Object.entries(groups)) {
        const hits = all.filter(app => !claimed.has(app) && matches(app, patterns));
        hits.forEach(app => claimed.add(app));
        if (hits.length)
            out.push(Group(name, hits));
    }

    const rest = all.filter(app => !claimed.has(app));
    if (rest.length)
        out.push(Group('Other', rest));

    return out.length ? out : [Notice('No applications found — check XDG_DATA_DIRS in the user unit')];
};

export const Applications = () => {
    let children;
    try {
        children = build();
    } catch (err) {
        children = [Notice(`Applications unavailable: ${err.message}`)];
    }
    return Widget.Scrollable({
        className: 'scroll',
        hscroll: 'never',
        vexpand: true,
        child: Widget.Box({ vertical: true, children }),
    });
};
