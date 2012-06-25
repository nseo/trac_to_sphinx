#!/bin/bash
rm -rf _cleanup
cp -a _convert _cleanup
find _cleanup -name 'Wiki*' | xargs rm -f
find _cleanup -name 'Trac*' | xargs rm -f 
find _cleanup -name 'Inter*.rst' | xargs rm -f
find _cleanup -name 'TitleIndex*' | xargs rm -f
find _cleanup -name 'Tc.rst' | xargs rm -f
find _cleanup -name 'Review.rst' | xargs rm -f
find _cleanup -name 'SandBox.rst' | xargs rm -f
find _cleanup -name 'RecentChanges.rst' | xargs rm -f
find _cleanup -name 'PageTemplates.rst' | xargs rm -f
find _cleanup -name 'PageTemplates' | xargs rm -rf
find _cleanup | xargs grep -l '?$' | xargs sed -i 's/\?$//g'
find _cleanup | xargs grep -l '? ' | xargs sed -i 's/\? / /g'
find _cleanup | xargs grep -l '?)' | xargs sed -i 's/\?)/)/g'
find _cleanup | xargs grep -l '?(' | xargs sed -i 's/\?(/(/g'

exit 0

