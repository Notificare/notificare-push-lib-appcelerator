/* C++ code produced by gperf version 3.0.3 */
/* Command-line: /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/gperf -L C++ -E -t /private/var/folders/hg/f0vr3vv54pqfc1hpxwnx3zsh0000gn/T/joeloliveira/notificare-titanium-android-generated/KrollGeneratedBindings.gperf  */
/* Computed positions: -k'' */

#line 3 "/private/var/folders/hg/f0vr3vv54pqfc1hpxwnx3zsh0000gn/T/joeloliveira/notificare-titanium-android-generated/KrollGeneratedBindings.gperf"


#include <string.h>
#include <v8.h>
#include <KrollBindings.h>

#include "ti.notificare.NotificareTitaniumAndroidModule.h"


#line 13 "/private/var/folders/hg/f0vr3vv54pqfc1hpxwnx3zsh0000gn/T/joeloliveira/notificare-titanium-android-generated/KrollGeneratedBindings.gperf"
struct titanium::bindings::BindEntry;
/* maximum key range = 1, duplicates = 0 */

class NotificareTitaniumAndroidBindings
{
private:
  static inline unsigned int hash (const char *str, unsigned int len);
public:
  static struct titanium::bindings::BindEntry *lookupGeneratedInit (const char *str, unsigned int len);
};

inline /*ARGSUSED*/
unsigned int
NotificareTitaniumAndroidBindings::hash (register const char *str, register unsigned int len)
{
  return len;
}

struct titanium::bindings::BindEntry *
NotificareTitaniumAndroidBindings::lookupGeneratedInit (register const char *str, register unsigned int len)
{
  enum
    {
      TOTAL_KEYWORDS = 1,
      MIN_WORD_LENGTH = 45,
      MAX_WORD_LENGTH = 45,
      MIN_HASH_VALUE = 45,
      MAX_HASH_VALUE = 45
    };

  static struct titanium::bindings::BindEntry wordlist[] =
    {
      {""}, {""}, {""}, {""}, {""}, {""}, {""}, {""}, {""},
      {""}, {""}, {""}, {""}, {""}, {""}, {""}, {""}, {""},
      {""}, {""}, {""}, {""}, {""}, {""}, {""}, {""}, {""},
      {""}, {""}, {""}, {""}, {""}, {""}, {""}, {""}, {""},
      {""}, {""}, {""}, {""}, {""}, {""}, {""}, {""}, {""},
#line 15 "/private/var/folders/hg/f0vr3vv54pqfc1hpxwnx3zsh0000gn/T/joeloliveira/notificare-titanium-android-generated/KrollGeneratedBindings.gperf"
      {"ti.notificare.NotificareTitaniumAndroidModule", ::ti::notificare::NotificareTitaniumAndroidModule::bindProxy, ::ti::notificare::NotificareTitaniumAndroidModule::dispose}
    };

  if (len <= MAX_WORD_LENGTH && len >= MIN_WORD_LENGTH)
    {
      unsigned int key = hash (str, len);

      if (key <= MAX_HASH_VALUE)
        {
          register const char *s = wordlist[key].name;

          if (*str == *s && !strcmp (str + 1, s + 1))
            return &wordlist[key];
        }
    }
  return 0;
}
#line 16 "/private/var/folders/hg/f0vr3vv54pqfc1hpxwnx3zsh0000gn/T/joeloliveira/notificare-titanium-android-generated/KrollGeneratedBindings.gperf"

