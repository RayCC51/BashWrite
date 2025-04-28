---
title: Code copy JS
description: Add simple code copy button with js
date: 2025-04-28
tags: js tutorial sample
---

```
sample
code
block
```

## 1. Add a \<script\> tag inside the `CUSTOM\_HTML\_HEAD` variable

*bw.sh*

```md
CUSTOM_HTML_HEAD="
<script src=\"$BASE_URL/assets/codecopy.js\" defer></script>
"
```

## 2. Create `codecopy.js` file in the *assets/*

```
your-blog/
├─ assets/
│  ├─ codecopy.js    <<< New!
├─ write/
├─ bw.sh
```

## 3. Wirte codes in `codecopy.js`

*assets/codecopy.js*

```js
// Copy button for code block
const codes = document.querySelectorAll('div.code-container');

codes.forEach(item => {
  // Container style
  item.setAttribute("style", "position: relative;");

  // Create button
  const copyBtn = document.createElement('button');
  copyBtn.textContent = 'Copy';
  copyBtn.setAttribute("style", "position: absolute; top: 0; right: 0; z-index: 3; background: var(--background-color); color: var(--main-theme); border: none;");

  // Add event
  copyBtn.addEventListener("click", () => {
    navigator.clipboard.writeText(copyBtn.previousElementSibling.textContent).then(()
=> {
      copyBtn.textContent = "Copied!"
      setTimeout(() => {
        copyBtn.textContent = "Copy"
      }, 1000)
    })
  });

  // Add element
  item.appendChild(copyBtn);
})
```

## 4. Save the file and run `./bw.sh b`

Fin!
