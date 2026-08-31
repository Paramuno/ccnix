// ASCII banner beside the fastfetch readout. The hostname is read at runtime, so
// this file is identical across workstations.
import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';
import GLib from 'gi://GLib';

const TITLE = 'CODESHIP';
// Hostnames are alphanumeric plus hyphen; strip anything else before it reaches sh.
const HOST = GLib.get_host_name().replace(/[^A-Za-z0-9-]/g, '').toUpperCase();
const FONT = 'basic';

export const Banner = () => Widget.Label({
    className: 'banner',
    xalign: 0,
    yalign: 0,
    vexpand: false,
label: `${TITLE}\n${HOST}`,
    setup: self => Utils
        .execAsync(['sh', '-c',
            `figlet -f ${FONT} -w 200 ${TITLE}; figlet -f ${FONT} -w 200 ${HOST}`])
// .then(out => self.label = `${out.replace(/\s+$/, '')}`)

        .then(out => {
            const lines = out.replace(/\s+$/, '').split('\n');
            self.label = lines.map((l, i) => (i === 0 ? ` ${l}` : l)).join('\n');
        })

        // figlet missing or font unavailable: plain text is a fine banner.
.catch(() => self.label = `${TITLE}\n${HOST}>`),
});
