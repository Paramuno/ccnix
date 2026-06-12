// ==UserScript==
// @name        Gemini Direct Upload (Material Target)
// @match       https://gemini.google.com/*
// @grant       none
// @version     2.2
// @author      Gemini
// ==/UserScript==

(function() {
    'use strict';

    const querySelectorDeep = (selector, root = document) => {
        let found = root.querySelector(selector);
        if (found) return found;
        const allElements = root.querySelectorAll('*');
        for (const el of allElements) {
            if (el.shadowRoot) {
                found = querySelectorDeep(selector, el.shadowRoot);
                if (found) return found;
            }
        }
        return null;
    };

    // Hardened heuristic engine for isolating the primary attachment UI
    const findParentMenuButton = () => {
        const allButtons = Array.from(document.querySelectorAll('button[aria-label]'));

        for (const btn of allButtons) {
            // 1. Structural Isolation: Categorically reject anything inside the sidebar
            if (btn.closest('nav') || btn.closest('[role="navigation"]') || btn.closest('sidenav')) {
                continue;
            }

            const label = btn.getAttribute('aria-label').toLowerCase();

            // 2. Intent Matching
            const hasUploadKeyword = label.includes('upload') || label.includes('attach');

            // 3. Semantic Blacklist: Prevent user-generated chat titles from hijacking the selector
            const isNotSidebarLeak = !label.includes('conversation') && !label.includes('chat') && !label.includes('options');

            // 4. Entropy Limit: Valid static UI labels are short. Reject bloated dynamic strings.
            const isShortLabel = label.length < 50;

            // 5. Context Rejection: Reject thumbnails and deletion actions
            const isNotThumbnail = !btn.querySelector('img');
            const isNotAction = !label.includes('remove') && !label.includes('delete');

            if (hasUploadKeyword && isNotSidebarLeak && isShortLabel && isNotThumbnail && isNotAction) {
                return btn;
            }
        }
        return null;
    };

    document.addEventListener('keydown', function(e) {
        if (e.altKey && e.code === 'KeyU') {
            console.log("[Gemini Upload Script] Alt+U intercepted. Initializing targeting routine...");

            const targetSelector = 'button[data-test-id="local-images-files-uploader-button"]';
            let targetBtn = querySelectorDeep(targetSelector);

            // Fast Path: Material menu is already rendered in the DOM
            if (targetBtn) {
                console.log("[Gemini Upload Script] Target acquired via data-test-id. Executing direct click.");
                targetBtn.dispatchEvent(new MouseEvent('mousedown', {bubbles: true, composed: true}));
                targetBtn.click();
                return;
            }

            // Deferred Path: Trigger the primary attachment toggle to mount the component
            console.warn("[Gemini Upload Script] Component unmounted. Executing hardened DOM heuristic search...");

            const parentMenuBtn = findParentMenuButton();

            if (parentMenuBtn) {
                console.log("[Gemini Upload Script] Parent toggle isolated:", parentMenuBtn);
                parentMenuBtn.dispatchEvent(new MouseEvent('mousedown', {bubbles: true, composed: true}));
                parentMenuBtn.click();

                let attempts = 0;
                const interval = setInterval(() => {
                    targetBtn = querySelectorDeep(targetSelector);
                    if (targetBtn) {
                        console.log("[Gemini Upload Script] Component mounted. Executing payload.");
                        clearInterval(interval);

                        setTimeout(() => {
                             targetBtn.dispatchEvent(new MouseEvent('mousedown', {bubbles: true, composed: true}));
                             targetBtn.click();
                        }, 50);
                    } else if (attempts > 40) {
                        console.error("[Gemini Upload Script] Fatal: Angular lifecycle timeout (2000ms). Node insertion failed.");
                        clearInterval(interval);
                    }
                    attempts++;
                }, 50);
            } else {
                 console.error("[Gemini Upload Script] Fatal: DOM heuristic engine failed to isolate the parent trigger.");
            }
        }
    }, true);
})();
