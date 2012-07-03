Documentation Instructions
==========================

We use appledoc to create Apple-style documentation and Quick Help from within Xcode.

http://gentlebytes.com/appledoc/

After installation, use this command to run documentation generator:

    appledoc --project-name Objective-Csound \\
    --project-company "Hear For Yourself" \\
    --company-id com.hearforyourself \\
    --no-repeat-first-par \\
    --output ~/help \\
    .

Documentation will be automatically reloaded in Xcode, but Quick Help will not be updated until you manually restart Xcode.

Since appledoc uses file comments to generate the documentation, engaging in good, consistent commenting habits is essential. 
