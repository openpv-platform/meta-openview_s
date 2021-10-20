// render.js handles the low level grunt work.
const { exec } = require('child_process');

// get the button element
const element = document.getElementById('Btn')

element.addEventListener("click", () => {
    exec("./led-toggle", (error, stdout, stderr) => console.log(stdout));
    console.log("button press");
})