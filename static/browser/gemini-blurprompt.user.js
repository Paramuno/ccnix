// ==UserScript==
// @name        Gemini Auto-Blur Prompt
// @namespace   Violentmonkey Scripts
// @match       https://gemini.google.com/*
// @grant       none
// @version     1.0
// @author      You
// @description Automatically removes focus from the input box after sending a prompt, freeing up keyboard navigation.
// ==/UserScript==

(function () {
  'use strict';

  // Listen for keydown events globally on the page
  document.addEventListener('keydown', function (event) {
    // Check if the 'Enter' key was pressed without the 'Shift' key
    // (Shift+Enter is usually used for multiline inputs and shouldn't trigger a blur)
    if (event.key === 'Enter' && !event.shiftKey) {

      const activeEl = document.activeElement;

      // Verify that the currently focused element is an input area.
      // Gemini uses contenteditable divs or textareas depending on the exact UI iteration.
      if (activeEl && (activeEl.tagName === 'TEXTAREA' || activeEl.isContentEditable || activeEl.tagName === 'INPUT')) {

        // Set a slight delay. If we blur instantly, Gemini's own event listeners
        // might not register the "Enter" key properly, and the prompt won't send.
        // 100ms is usually the sweet spot for modern web apps.
        setTimeout(() => {
          activeEl.blur(); // Remove focus from the text box

          // Explicitly return focus to the document body.
          // This ensures that global keyboard shortcuts or navigation tools
          // immediately register your next keystrokes.
          document.body.focus();
        }, 100);
      }
    }
  }, true); // Use the capture phase to ensure the script catches the event early
})();
