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
    navigator.clipboard.writeText(copyBtn.previousElementSibling.textContent).then(() => {
      copyBtn.textContent = "Copied!"
      setTimeout(() => {
        copyBtn.textContent = "Copy"
      }, 1000)
    })
  });

  // Add element
  item.appendChild(copyBtn);
})

