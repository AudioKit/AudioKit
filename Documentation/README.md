AudioKit Documentation
======================

AudioKit is heavily documented using standard practices that result in Xcode-style documentation within pop-overs and sidebars.  Additionally, a web-based class reference document and a DocSet that can be installed into your '~/Library/Developer/Shared/Documentation/DocSets/' folder are availabe at <http://audiokit.io/docs/>.

Information for Developers
--------------------------

It is possible to create Apple-style DocSets directly from the source files using AppleDoc:

http://gentlebytes.com/appledoc/

Follow their instruction to install, which was basically to:
* Clone the repository
* Open Xcode Project, built target
* Either run the script or manually copy the executable and template files
* Test with appledoc --help

After installation, use this command from within the AudioKit Xcode folder to run documentation generator.

    appledoc --project-name "AudioKit" \
    --project-company "AudioKit" \
    --company-id io.AudioKit \
    --no-repeat-first-par \
    --output ~/AppleDoc \
    .

