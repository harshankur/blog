---
title: "Using ChatGPT as an Assistant Developer"
date: 2024-01-07T22:12:52+01:00
draft: false
tags: ['chatgpt', 'technology', 'opensource', 'programming', 'development', 'code']
categories: ['Programming', 'Technology']
---

When I first heard that AI will replace software developers soon, I thought it could not have been true as it is just a large language model as of now and not so much of an 'intelligence' in any sense or form. Turns out, I was both right and wrong. It is trained well enough to support a developer but not to operate independently with simple instructions. So, it will take over a few people's jobs, but that would be of the low-skilled software developers who only get to make a couple of small modules in the product at best.

## Generating small utility modules
I was working on an opensource project, Office Parser for Python, called officeparserpy which is a Python port of my NodeJS module officeparser which can extract text from office files and allow the user to modify the result using a few configuration flags.
Since JS is a combination of async and sync operations, converting a JS code directly to Python is no easy thing. I had thought it would take me a bit longer to port it properly as I am not aware of many python libraries and there are more than a few differences between the two languages. I have worked with API handlers on Python with Flask framework but I have not worked a lot in Python. I needed to work on extracting files from a zip that matched a given regular expression. It was straight-forward for me on JS by using the decompress library and passing the regex to its filter function. I was not sure how to do it in Python. So, I asked ChatGPT to do it for me and voila, it gave out a fully working code that could decompress a zip file. It required a few inputs on my end too to get my desired module generated but it was quite easy.

At first, it gave me a decompress function that would decompress all the files in the archive and another function that looks into the decompressed files and returns the file names of the ones that match a regex.

```python
import zipfile
import os
import re

def decompress_zip(zip_path, extract_path):
    with zipfile.ZipFile(zip_path, 'r') as zip_ref:
        zip_ref.extractall(extract_path)

def find_files_with_regex(directory, regex_pattern):
    matching_files = []
    regex = re.compile(regex_pattern)
    
    for root, dirs, files in os.walk(directory):
        for file in files:
            if regex.search(file):
                matching_files.append(os.path.join(root, file))
    
    return matching_files

# Example usage
zip_path = 'path/to/your/archive.zip'
extract_path = 'path/to/extract/folder'
regex_pattern = r'match_this.*\.txt'

# Decompress the folder
decompress_zip(zip_path, extract_path)

# Find files that match the regex pattern
matching_files = find_files_with_regex(extract_path, regex_pattern)

# Display the matching files
print("Matching Files:")
for file_path in matching_files:
    print(file_path)

```

It worked but this is not what I had wanted. I wanted to optimise this. I wanted to not decompress files that I did not need. So, I asked it to give me the code for a module that would only decompress the file names (file paths) that matched a given regex. It did that now.

```python
import zipfile
import re
import os

def extract_files_with_regex(zip_path, extract_path, regex_pattern):
    with zipfile.ZipFile(zip_path, 'r') as zip_ref:
        matching_files = [file for file in zip_ref.namelist() if re.search(regex_pattern, file)]

        for file in matching_files:
            zip_ref.extract(file, extract_path)

# Example usage
zip_path = 'path/to/your/archive.zip'
extract_path = 'path/to/extract/folder'
regex_pattern = r'match_this.*\.txt'

# Extract files matching the regex pattern
extract_files_with_regex(zip_path, extract_path, regex_pattern)

# Display the extracted files
print("Extracted Files:")
for root, dirs, files in os.walk(extract_path):
    for file in files:
        print(os.path.join(root, file))

```

Notice how it still consisted of the test code below. I wanted to have it as an exportable module. I asked for it and it converted this code into that. I also asked it for docstring everywhere in the code for better code documentation. Further, I asked it to have the extract_files_with_regex function to return the list of of files that were decompressed by it too. This was the final output.

```python
from typing import List, Tuple

def extract_files_with_regex(zip_path: str, extract_path: str, regex_pattern: str) -> List[str]:
    """
    Extract files from a ZIP archive based on a regex pattern.

    Args:
        zip_path (str): Path to the ZIP archive.
        extract_path (str): Directory where the files will be extracted.
        regex_pattern (str): Regular expression pattern to match filenames.

    Returns:
        List[str]: List of file names that were extracted.

    Raises:
        FileNotFoundError: If the specified ZIP archive (`zip_path`) does not exist.
        zipfile.BadZipFile: If the specified file (`zip_path`) is not a valid ZIP archive.
    """
    extracted_files = []
    
    try:
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            matching_files = [file for file in zip_ref.namelist() if re.search(regex_pattern, file)]

            for file in matching_files:
                zip_ref.extract(file, extract_path)
                extracted_files.append(file)

    except FileNotFoundError:
        raise FileNotFoundError(f"The specified ZIP archive '{zip_path}' does not exist.")
    except zipfile.BadZipFile:
        raise zipfile.BadZipFile(f"The specified file '{zip_path}' is not a valid ZIP archive.")

    return extracted_files

def display_extracted_files(extract_path: str) -> None:
    """
    Display the paths of the extracted files.

    Args:
        extract_path (str): Directory where the files were extracted.

    Returns:
        None

    Raises:
        FileNotFoundError: If the specified directory (`extract_path`) does not exist.
    """
    if not os.path.exists(extract_path):
        raise FileNotFoundError(f"The specified directory '{extract_path}' does not exist.")

    print("Extracted Files:")
    for root, _, files in os.walk(extract_path):
        for file in files:
            print(os.path.join(root, file))

# Example usage:
# import zip_extractor

# extracted_files = zip_extractor.extract_files_with_regex('path/to/your/archive.zip', 'path/to/extract/folder', r'match_this.*\.txt')
# print("Extracted Files:", extracted_files)

```

Look at how well ChatGPT can document the code and how well it understands what a user's intention is and specially in what context.

You can find the full chat related to this module [here](https://chat.openai.com/share/18cba2a0-8810-4e7c-b4b9-d9d307fc56d5).

## Challenges

It makes mistakes! Many! If the work is extremely easy and to the point, it is extremely good at understanding the intention and works really well. If the task is slightly more challenging, it is not as good.

I asked it to convert a small piece of code in Javascript into Python that required accessing keys of a JSON object. For the uninitiated, accessing a key in an object in Javascript is using the dot notation.
Therefore, if say you have an object called `person` and it has keys `name` and `age`. The way you access the name of this person is `person.name` or the age as `person.age`.
In python, this is done via the bracket notation. So, you would do it as `person['name']` or `person['age]`.

When ChatGPT converted my Javascript code to Python, it could find the relevant libraries from Python for the ones that I had used in Javascript but it failed in converting these different notations into Python. When I asked it to correct it, it appologised for its mistake and the corrected it in a couple of places but not everywhere. I then pointed out that there were atleast 3 more places where this error exists. It apologised again for the oversight and then it corrected it in the remaining places too.

What I understood from this is that it does gets things wrong but it is still good enough to understand what the user wanted fixed. It not only understood the problem but it was also able to fix it.

So, the ultimate challenge in using ChatGPT for programming will be to be extremely clear in instructions to ChatGPT and be cautious enough to notice its gaffes. That would be a bigger challenge from now on. A person who is not very articulate with their thoughts is going to have a rather tough time in taking its help.

## Conclusion

ChatGPT can dramatically augment one's productivity in programming but it cannot replace a senior software engineer yet that needs to understand code beyond a single module. They need to know what architecture their code needs to follow. They also need to keep conversing with ChatGPT to get the code corrected in the way that suits their idea. But no matter what, no one can deny that the AI revolution is here and it is only going to dramatically change the world as we know it.