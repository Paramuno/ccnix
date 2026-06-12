import 'gi://Gtk?version=3.0';
import Hyprland from 'resource:///com/github/Aylur/ags/service/hyprland.js';
import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import Variable from 'resource:///com/github/Aylur/ags/variable.js';
import App from 'resource:///com/github/Aylur/ags/app.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';

// --- 1. DATA LOADING ---
const jsonPath = `${App.configDir}/keyboard-layout.json`;
let kbData = { layout: [], binds: {} };

try {
  const rawData = Utils.readFile(jsonPath);
  if (rawData) {
    kbData = JSON.parse(rawData);
  }
} catch (err) {
  console.error(`Failed to load JSON: ${err}`);
}


// --- 2. STATE MANAGEMENT ---

const currentContext = Variable("default");
const displayLayer = Variable("default");
const intendedEditLayer = Variable("default");
const currentModString = Variable("none");
const activeChord = Variable("none");
const cssLayer = Variable("none");

const editState = Variable({
  isActive: false, targetKey: null, targetLayer: null, currentText: "", currentIcon: "", type: "action"
});

// 1. Monitor the Active Application
const updateContext = () => {
  const client = Hyprland.active.client;
  const appClass = (client.class || "default").toLowerCase();
  const appTitle = (client.title || "").toLowerCase();

  let targetContext = appClass;

  if (appClass === "kitty") {
    if (appTitle.includes("nvim") || appTitle.includes("neovim")) targetContext = "nvim";
    else if (appTitle.includes("yazi")) targetContext = "yazi";
    else if (appTitle.includes("lazygit")) targetContext = "lazygit";
  }

  // Check 2: Native Electron Apps (Obsidian on NixOS)
  else if (appClass === "electron" || appClass === "obsidian") {
    // If the title contains obsidian, force the context to 'obsidian'
    if (appTitle.includes("obsidian")) {
      targetContext = "obsidian";
    } else {
      // Fallback if you open a different electron app later
      targetContext = "electron";
    }
  }

  currentContext.value = targetContext;
};

Hyprland.active.client.connect('notify::class', updateContext);
Hyprland.active.client.connect('notify::title', updateContext);
updateContext();

// 2. Binary Modifier Tracking (Event-Driven RPC)

const mods = {
  ctrl: Variable("0"),
  alt: Variable("0"),
  shift: Variable("0"),
  super: Variable("0")
};

const setupModTracker = (modName) => {
  const path = `/tmp/ags-mod-${modName}`;
  Utils.exec(`sh -c "echo '0' > ${path}"`);

  // Inotify pushes the update the exact microsecond the file changes
  Utils.monitorFile(path, () => {
    try {
      mods[modName].value = Utils.readFile(path).trim() || "0";
    } catch (err) {
      // Ignore read errors during rapid file locks
    }
  });
};

Object.keys(mods).forEach(setupModTracker);

// 2.5 Monitor the active chord file
const setupChordTracker = () => {
  const path = `/tmp/ags-active-chord`;
  Utils.exec(`sh -c "echo 'none' > ${path}"`);
  Utils.monitorFile(path, () => {
    try { activeChord.value = Utils.readFile(path).trim() || "none"; } catch (err) { }
  });
};
setupChordTracker();


// 3. Compute the Final Display Layer (Purely Reactive, No Timers)
const updateDisplayLayer = () => {
  let activeMods = [];
  if (mods.ctrl.value === "1") activeMods.push("ctrl");
  if (mods.alt.value === "1") activeMods.push("alt");
  if (mods.shift.value === "1") activeMods.push("shift");

  const standardModStr = activeMods.length > 0 ? activeMods.join("-") : "none";
  const chord = activeChord.value.toLowerCase();

  // --- THE STRICT OS-LEVEL OVERRIDE ---
  if (mods.super.value === "1") {
    const superLayerName = standardModStr !== "none" ? `super-${standardModStr}` : "super";
    currentModString.value = `HYPR ${superLayerName.toUpperCase()}`;
    intendedEditLayer.value = superLayerName;
    displayLayer.value = kbData.binds[superLayerName] ? superLayerName : "super";

    // Force CSS to lock to pure "super" so the entire grid always inverts
    cssLayer.value = "super";
    return;
  }

  // --- STANDARD APPLICATION CONTEXT ---
  const app = currentContext.value;

  // --- CHORD LEVEL OVERRIDE ---
  if (chord !== "none") {
    currentModString.value = `${chord.toUpperCase()} CHORD`;
    const targetLayerName = `${app}-${chord}`;
    intendedEditLayer.value = targetLayerName;

    if (kbData.binds[targetLayerName]) {
      displayLayer.value = targetLayerName;
    } else if (kbData.binds[app]) {
      displayLayer.value = app;
    } else {
      displayLayer.value = "default";
    }

    // Force CSS to lock to the specific chord (e.g., "space", "z")
    cssLayer.value = chord;
    return;
  }

  currentModString.value = standardModStr.toUpperCase();
  const targetLayerName = standardModStr !== "none" ? `${app}-${standardModStr}` : app;
  intendedEditLayer.value = targetLayerName;

  if (standardModStr !== "none" && kbData.binds[targetLayerName]) {
    displayLayer.value = targetLayerName;
  } else if (kbData.binds[app]) {
    displayLayer.value = app;
  } else {
    displayLayer.value = "default";
  }

  // Output standard combinations (e.g., "shift", "ctrl-shift", or "none")
  cssLayer.value = standardModStr;
};


// React instantly to any context or modifier change
currentContext.connect('changed', updateDisplayLayer);
Object.values(mods).forEach(modVar => modVar.connect('changed', updateDisplayLayer));
activeChord.connect('changed', updateDisplayLayer); // Connect the new chord tracker

// --- 3. SAVE LOGIC ---

const saveEdit = (newText, newIcon) => {
  const key = editState.value.targetKey;
  // Read the locked layer, completely ignoring what modifiers are currently being held
  const layer = editState.value.targetLayer;

  // If this is a brand new combo (e.g. obsidian-shift), this line automatically creates the JSON branch!
  if (!kbData.binds[layer]) kbData.binds[layer] = {};

  if (newText.trim() === "" && newIcon.trim() === "") {
    delete kbData.binds[layer][key];
  } else {
    kbData.binds[layer][key] = {
      desc: newText,
      icon: newIcon,
      type: editState.value.type
    };
  }

  const newJsonString = JSON.stringify(kbData, null, 2);

  Utils.writeFile(newJsonString, jsonPath)
    .then(() => {
      print(`Saved ${key} to ${jsonPath}`);
      currentContext.setValue(currentContext.value);
    })
    .catch(err => print(`Save Error: ${err}`));

  // Reset the state, including targetLayer
  editState.value = { isActive: false, targetKey: null, targetLayer: null, currentText: "", currentIcon: "", type: "action" };
};

// --- 4. UI COMPONENTS ---

const Keycap = (keyStr) => Widget.Button({
  className: `keycap key-${keyStr.toLowerCase().replace(/\\/g, 'backslash').replace(/#/g, 'hash')}`,

  onClicked: () => {
    // CRITICAL: Lock onto the intended modifier combo, NOT the visual fallback
    const lockedLayer = intendedEditLayer.value;

    const activeBinds = kbData.binds[lockedLayer] || {};
    const bindInfo = activeBinds[keyStr] || { desc: "", type: "action" };

    editState.value = {
      isActive: true,
      targetKey: keyStr,
      targetLayer: lockedLayer,
      currentText: bindInfo.desc || "",
      currentIcon: bindInfo.icon || "",
      type: (bindInfo.type && bindInfo.type !== "unbound") ? bindInfo.type : "action"
    };
  },

  setup: self => {
    // Create widgets ONCE
    const idLabel = Widget.Label({
      className: 'key-id',
      hpack: 'start',
      vpack: 'start',
      css: 'margin: 5px;',
    });
    const iconLabel = Widget.Label({
      className: 'key-icon',
      vpack: 'start',
      hpack: 'center',
      hexpand: true,
    });
    const descLabel = Widget.Label({
      className: 'key-desc',
      vpack: 'center',
      vexpand: true,
      wrap: true,
      justify: 'center',
      xalign: 0.5,
      setup: self => {
        self.halign = 0; // GTK_ALIGN_FILL = 0, bypasses AGS string mapping
      }
    });

    idLabel.label = keyStr.replace(/_[LR]$/, '');

    self.child = Widget.Overlay({
      child: Widget.Box({ vertical: true, vexpand: true, hexpand: true, children: [descLabel] }),
      overlays: [idLabel,
        iconLabel]
    });

    // Hook only updates labels, never rebuilds
    self.hook(displayLayer, button => {
      const activeBinds = kbData.binds[displayLayer.value] || {};
      const bindInfo = activeBinds[keyStr];
      const typeClass = bindInfo?.type || 'unbound';

      iconLabel.label = bindInfo?.icon || '';
      descLabel.label = bindInfo?.desc || '';

      button.toggleClassName('unbound', typeClass === 'unbound');
      button.toggleClassName('modifier', typeClass === 'modifier');
      button.toggleClassName('action', typeClass === 'action');
    });

    self.hook(currentModString, button => {
      const k = keyStr.toLowerCase();
      const isActive =
        (k.includes('shift') && mods.shift.value === "1") ||
        (k.includes('ctrl') && mods.ctrl.value === "1") ||
        (k.includes('alt') && mods.alt.value === "1") ||
        (k === 'super' && mods.super.value === "1") ||
        (activeChord.value.toLowerCase() === k);
      button.toggleClassName('active-mod', isActive);
    });
  }

});


const KeyboardGrid = () => Widget.Box({
  vertical: true,
  spacing: 6,
  className: 'keyboard-board',
  children: kbData.layout.map(row => Widget.Box({
    spacing: 6,
    hpack: 'center',
    children: row.map(keyStr => Keycap(keyStr))
  }))
});

// --- 5. WINDOWS ---

const WhichKeyWindow = Widget.Window({
  name: 'visual-keyboard',
  anchor: ['bottom'],
  margins: [0, 0, 40, 0],
  layer: 'overlay',
  visible: false,
  child: Widget.Box({
    vertical: true,
    spacing: 15,

    // NEW: Use a hook instead of a bind to force GTK to repaint the child keycaps
    setup: self => self.hook(cssLayer, box => {
      box.className = `window-container layer-${cssLayer.value}`;
    }),

    children: [
      // 1. ACTIVE WINDOW DISPLAY (Top)
      Widget.Box({
        hpack: 'center',
        className: 'window-title-display',
        child: Widget.Label({
          label: Hyprland.active.client.bind('title').as(title =>
            title ? `Active Window: ${title}` : 'Desktop'
          )
        })
      }),

      // 2. THE KEYBOARD GRID (Middle)
      KeyboardGrid(),

      // 3. MODIFIER STATUS DISPLAY (Bottom)
      Widget.Box({
        hpack: 'center',
        className: 'mod-status-display',
        child: Widget.Label({
          label: currentModString.bind().as(mod => `[ ${mod} ]`)
        })
      })
    ],
  })
});

const EditorBar = () => {
  // Entry 1: The Icon
  const iconEntry = Widget.Entry({
    placeholder_text: 'Icon',
    css: 'background-color: #11111b; color: #cdd6f4; padding: 5px; border-radius: 4px; font-family: "JetBrainsMono NF", monospace;',
    widthChars: 4,
    setup: self => self.hook(editState, entry => {
      if (editState.value.isActive) entry.text = editState.value.currentIcon;
    }),
    onAccept: () => saveEdit(descEntry.text, iconEntry.text)
  });

  // Entry 2: The Description
  const descEntry = Widget.Entry({
    placeholder_text: 'Description',
    css: 'background-color: #11111b; color: #cdd6f4; padding: 5px 10px; border-radius: 4px;',
    widthChars: 25,
    setup: self => self.hook(editState, entry => {
      if (editState.value.isActive) {
        entry.text = editState.value.currentText;
        // Keep focus on description so you can type immediately
        entry.grab_focus();
      }
    }),
    onAccept: () => saveEdit(descEntry.text, iconEntry.text)
  });

  return Widget.Window({
    name: 'editor-bar',
    anchor: ['bottom'],
    margins: [0, 0, 10, 0],
    layer: 'overlay',
    keymode: 'exclusive',
    visible: false,

    setup: self => self.hook(editState, win => {
      win.visible = editState.value.isActive;
    }),

    child: Widget.Box({
      css: 'background-color: #1e1e2e; padding: 15px; border-radius: 8px; border: 2px solid #89b4fa;',
      spacing: 15,
      children: [
        Widget.Label({
          setup: self => self.hook(editState, label => {
            label.label = `Editing [${editState.value.targetKey}] for ${editState.value.targetLayer}:`;
          }),
          css: 'font-weight: bold; color: #89b4fa;'
        }),
        iconEntry, // Inject the new icon entry here
        descEntry,
        Widget.Button({
          setup: self => self.hook(editState, btn => {
            const isMod = editState.value.type === 'modifier';
            btn.label = isMod ? 'Type: Modifier' : 'Type: Action';
            btn.css = isMod
              ? 'background-color: #2b7a65; color: white; background-image: none; border: none; text-shadow: none;'
              : 'background-color: #2e5b7c; color: white; background-image: none; border: none; text-shadow: none;';
          }),
          onClicked: () => {
            editState.value = {
              ...editState.value,
              type: editState.value.type === 'modifier' ? 'action' : 'modifier'
            };
          }
        }),
        Widget.Button({
          label: 'Cancel',
          css: 'background-color: #313244; color: white; padding: 5px 15px; border-radius: 4px; background-image: none; border: none; text-shadow: none;',
          onClicked: () => {
            editState.value = { isActive: false, targetKey: null, targetLayer: null, currentText: "", currentIcon: "", type: "action" };
          }
        })
      ]
    })
  });
};

// --- 6. INITIALIZATION ---
// This replaces the deprecated 'export default'
App.config({
  style: `${App.configDir}/style.css`,
  windows: [WhichKeyWindow, EditorBar()],
});
