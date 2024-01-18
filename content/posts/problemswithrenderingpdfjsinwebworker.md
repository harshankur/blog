---
title: "Problems with rendering pdf.js in Web Worker"
date: 2024-01-18T22:58:31+01:00
draft: false
tags: ['rendering', 'programming', 'webworker', 'offscreencanvas', 'code', 'development']
categories: ['technology', 'programming']
---

I was tinkering with pdf.js and pdf-lib. I was trying to see what open source free technologies can do. Then I thought of how efficient it would be to move the main computation of working with pdf-lib and pdf.js to a web worker.

I did a small test.

I created a small html file that places a select file input control on the UI and a div to hold images.

I created a main.js file with the following responsibilities:
1. Initialize a web worker
2. Listen to file input changes, read file contents and send to the worker
3. Listen to worker messages which should contain png base64 data for each page of the pdf file uploaded via file input control and add them as source of dynamically created img elements and added to the image container in the html file.

I created a worker.js file with the following responsibilities:
1. Import pdf.js library
2. Listen to the file UInt8Array data from main.js and build a pdfDocument object from pdf.js.
3. Get pdf pages in png format and message the base64 array image data to main.js


In order to achieve this, I tried to find how to get png data from pdf.js. A google search indicated that pdf.js needs a canvas to render the page images. Now, using an HTML Canvas element cannot work inside a web worker. So, I chose to use OffscreenCanvas element instead. I had to change some of the code to not get dataUrl from the canvas directly becasue it is not supported in OffscreenCanvas. Rather, I had to convert it to a blob of png format, read that from file reader and return this png data array to main.js.

Sounds done, right? This was my output!

![Rendered Image](/renderingProblemsPdfJsWebWorker.png "Problems with rendering pdf.js in Web Worker")


I tried several other ways of figuring out what was the source of the problem. I tried rendering it using OffscreenCanvas on main thread instead of using web workers. Worked perfectly.

I moved everything back to web worker and instead of rendering a page of the pdf, I tried rendering custom text on the Offscreen Canvas from within the worker. Worked correctly.

The only possibility is that pdf.js does not render stuffs correctly inside a web worker. Probably because it uses a dedicated worker of its own.

But it was good to learn that these kinds of limitations exist in pdf.js when used in a web worker.


Here is my sample code for you to play around.

```html
<!-- index.html -->

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PDF Rendering</title>
</head>
<body>
    <input type="file" id="fileInput" />
    <div id="imageContainer"></div>

    <!-- Your main.js script -->
    <script src="main.js"></script>
</body>
</html>
```

```js
// main.js

// Create a web worker
const worker = new Worker('worker_.js');

// Listen for messages from the worker
worker.addEventListener('message', (event) => {
    const { pngDataArray } = event.data;


    // Display the PNG images in the HTML
    if (pngDataArray)
        displayImages(pngDataArray);
});

// Handle file selection
function handleFileSelection(event) {
    const file = event.target.files[0];

    if (file && file.type === 'application/pdf') {
        // Send the PDF file to the web worker
        const reader = new FileReader();
        reader.onload = function (loadEvent) {
            const pdfBytes = new Uint8Array(loadEvent.target.result);
            worker.postMessage({ pdfBytes });
        };
        reader.readAsArrayBuffer(file);
    } else {
        alert('Please select a valid PDF file.');
    }
}

// Display PNG images in the HTML
function displayImages(pngDataArray) {
    const imageContainer = document.getElementById('imageContainer');

    // Clear previous images
    imageContainer.innerHTML = '';

    // Create img elements for each PNG data
    for (const pngData of pngDataArray) {
        const imgElement = document.createElement('img');
        imgElement.src = `data:image/png;base64,${pngData}`;
        imageContainer.appendChild(imgElement);
    }
}

// Attach the file selection event listener
const fileInput = document.getElementById('fileInput');
fileInput.addEventListener('change', handleFileSelection);
```

```js
// worker.js

// Import pdf.js dynamically
import('https://mozilla.github.io/pdf.js/build/pdf.mjs')
.then(pdfjsLibModule => {
    const pdfjsLib = pdfjsLibModule;

    // Specify the path to the pdf.js worker source file
    pdfjsLib.GlobalWorkerOptions.workerSrc = 'https://mozilla.github.io/pdf.js/build/pdf.worker.mjs';

    // Listen for messages from the main code
    self.addEventListener('message', (event) => {
        const { pdfBytes } = event.data;

        // Load the PDF using pdf.js
        pdfjsLib.getDocument({ data: pdfBytes }).promise
        .then(pdf => {
            // Render all pages to PNG images
            const pngDataArray = [];
            for (let pageNumber = 1; pageNumber <= pdf.numPages; pageNumber++) {
                pdf.getPage(pageNumber).then(page => {
                    const viewport = page.getViewport({ scale: 5 });

                    // Render the page to a canvas
                    const canvas = new OffscreenCanvas(viewport.width, viewport.height);
                    const context = canvas.getContext('2d');
                    page.render({ canvasContext: context, viewport }).promise.then(() => {
                        // Convert the canvas content to PNG Blob
                        canvas.convertToBlob({ type: 'image/png' }).then(blob => {
                            const reader = new FileReader();
                            reader.onloadend = function () {
                                // Get data URL from Blob
                                const pngData = reader.result.split(',')[1];
                                pngDataArray.push(pngData);

                                console.log(pngDataArray.length, pdf.numPages)

                                // If all pages are processed, send PNG data back to the main code
                                if (pngDataArray.length === pdf.numPages) {
                                    self.postMessage({ pngDataArray });
                                }
                            };
                            reader.readAsDataURL(blob);
                        });
                    });
                });
            }
        })
        .catch(error => {
            console.error('Error loading PDF with pdf.js:', error);
            self.postMessage({ error: 'PDF loading error' });
        });
    });
})
.catch(error => {
    console.error('Error loading pdf.js:', error);
    self.postMessage({ error: 'pdf.js loading error' });
});
```