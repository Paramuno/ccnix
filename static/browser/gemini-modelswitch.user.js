// ==UserScript==
// @name        Gemini Model Switcher (Pro ⇌ Thinking) + Auto Submit
// @namespace   Violentmonkey Scripts
// @match       https://gemini.google.com/*
// @grant       none
// @version     3.1
// @author      Gemini
// @description Toggles between Gemini Pro and Thinking models and automatically submits the prompt.
// ==/UserScript==

(function () {
  'use strict';

  // ==========================================
  // CONFIGURATION
  // ==========================================

  const HOTKEY = {
    key: 'y',
    altKey: true,
    ctrlKey: false,
    shiftKey: false
  };

  const PRO_MODEL_TEXT = "Pro";
  const THINKING_MODEL_TEXT = "Thinking";

  // ==========================================
  // DOM TARGETING FUNCTIONS
  // ==========================================

  function findDropdownButton() {
    return document.querySelector('button[data-test-id="bard-mode-menu-button"]');
  }

  function findMenuItem(targetText) {
    const overlayContainer = document.querySelector('.cdk-overlay-container');
    if (!overlayContainer) {
      console.error("Model Switcher: Overlay container not found.");
      return null;
    }

    const menuItems = overlayContainer.querySelectorAll('[role="menuitem"], [role="option"], mat-list-item, button');
    for (const item of menuItems) {
      const text = item.textContent || item.innerText;
      if (text.includes(targetText)) {
        return item;
      }
    }
    return null;
  }

  function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  // ==========================================
  // SUBMISSION LOGIC
  // ==========================================

  /**
   * Attempts to submit the prompt by locating the send button or dispatching an Enter key.
   * Brutally honest truth: DOM selectors in Google products are volatile.
   * We use a multi-tiered fallback approach here to guarantee execution.
   */
  async function submitPrompt() {
    console.log("Model Switcher: Attempting to auto-submit the prompt...");

    // Crucial: Give the SPA's state manager (Angular) time to digest the model switch.
    // Without this, you risk sending the prompt to the previously selected model's endpoint.
    await sleep(200);

    // Tier 1: Look for the physical send button using standard accessibility attributes.
    // Google generally maintains a11y labels even when CSS modules change class names.
    const sendButtonSelectors = [
      'button[aria-label*="Send"]',
      'button[mattooltip*="Send"]',
      'button[data-test-id="send-button"]'
    ];

    let sendButton = null;
    for (const selector of sendButtonSelectors) {
      sendButton = document.querySelector(selector);
      if (sendButton) break;
    }

    if (sendButton && !sendButton.disabled) {
      sendButton.click();
      console.log("Model Switcher: Successfully clicked the Send button.");
      return;
    } else if (sendButton && sendButton.disabled) {
      console.warn("Model Switcher: Send button found, but it is disabled. Is the prompt empty?");
      return;
    }

    // Tier 2 Fallback: If the button is completely hidden or DOM changed, synthesize an Enter stroke.
    console.warn("Model Switcher: Send button not found via standard selectors. Deploying Enter key fallback.");
    const chatInput = document.querySelector('.ql-editor, textarea, [contenteditable="true"]');

    if (chatInput) {
      const enterEvent = new KeyboardEvent('keydown', {
        key: 'Enter',
        code: 'Enter',
        keyCode: 13,
        which: 13,
        bubbles: true,
        cancelable: true
      });
      chatInput.dispatchEvent(enterEvent);
      console.log("Model Switcher: Dispatched synthesized Enter key to chat input.");
    } else {
      console.error("Model Switcher: Critical failure. Could not locate chat input for fallback submission.");
    }
  }

  // ==========================================
  // MAIN LOGIC
  // ==========================================

  async function toggleModel() {
    console.log("Model Switcher: Initiating toggle sequence...");

    const dropdownButton = findDropdownButton();
    if (!dropdownButton) {
      console.error("Model Switcher: Failed to find the model dropdown via data-test-id.");
      return;
    }

    const currentText = dropdownButton.textContent || dropdownButton.innerText;
    const isCurrentlyPro = currentText.includes(PRO_MODEL_TEXT);
    const targetModelText = isCurrentlyPro ? THINKING_MODEL_TEXT : PRO_MODEL_TEXT;

    console.log(`Model Switcher: Current model is [${isCurrentlyPro ? 'Pro' : 'Thinking'}]. Target is [${targetModelText}].`);

    dropdownButton.click();
    await sleep(250);

    const targetMenuItem = findMenuItem(targetModelText);

    if (targetMenuItem) {
      targetMenuItem.click();
      console.log(`Model Switcher: Successfully switched to ${targetModelText}.`);

      // Hook the auto-submit execution here, post-successful switch
      await submitPrompt();

    } else {
      console.error(`Model Switcher: Could not locate "${targetModelText}" inside the dropdown menu.`);
      document.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true }));
      const backdrop = document.querySelector('.cdk-overlay-backdrop');
      if (backdrop) backdrop.click();
    }
  }

  // ==========================================
  // EVENT LISTENER
  // ==========================================

  window.addEventListener('keydown', function (e) {
    if (
      e.key.toLowerCase() === HOTKEY.key &&
      e.altKey === HOTKEY.altKey &&
      e.ctrlKey === HOTKEY.ctrlKey &&
      e.shiftKey === HOTKEY.shiftKey
    ) {
      // We removed the 'isTyping' block you previously commented out to ensure
      // the user can trigger this seamlessly while typing their prompt.
      e.preventDefault();
      toggleModel();
    }
  });

})();
