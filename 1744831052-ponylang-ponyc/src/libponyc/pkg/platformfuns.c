#include "platformfuns.h"
#include "../codegen/genopt.h"
#include "ponyassert.h"
#include <string.h>


// Report whether the named platform attribute is true
bool os_is_target(const char* attribute, bool release, bool* out_is_target, pass_opt_t* options)
{
  pony_assert(attribute != NULL);
  pony_assert(out_is_target != NULL);
  pony_assert(options != NULL);

  if(!strcmp(attribute, OS_BSD_NAME))
  {
    *out_is_target = target_is_bsd(options->triple);
    return true;
  }

  if(!strcmp(attribute, OS_FREEBSD_NAME))
  {
    *out_is_target = target_is_freebsd(options->triple);
    return true;
  }

  if(!strcmp(attribute, OS_DRAGONFLY_NAME))
  {
    *out_is_target = target_is_dragonfly(options->triple);
    return true;
  }

  if(!strcmp(attribute, OS_OPENBSD_NAME))
  {
    *out_is_target = target_is_openbsd(options->triple);
    return true;
  }

  if(!strcmp(attribute, OS_LINUX_NAME))
  {
    *out_is_target = target_is_linux(options->triple);
    return true;
  }

  if(!strcmp(attribute, OS_MACOSX_NAME))
  {
    *out_is_target = target_is_macosx(options->triple);
    return true;
  }

  if(!strcmp(attribute, OS_WINDOWS_NAME))
  {
    *out_is_target = target_is_windows(options->triple);
    return true;
  }

  if(!strcmp(attribute, OS_POSIX_NAME))
  {
    *out_is_target = target_is_posix(options->triple);
    return true;
  }

  if(!strcmp(attribute, OS_X86_NAME))
  {
    *out_is_target = target_is_x86(options->triple);
    return true;
  }

  if(!strcmp(attribute, OS_ARM_NAME))
  {
    *out_is_target = target_is_arm(options->triple);
    return true;
  }

  if(!strcmp(attribute, OS_LP64_NAME))
  {
    *out_is_target = target_is_lp64(options->triple);
    return true;
  }

  if(!strcmp(attribute, OS_LLP64_NAME))
  {
    *out_is_target = target_is_llp64(options->triple);
    return true;
  }

  if(!strcmp(attribute, OS_ILP32_NAME))
  {
    *out_is_target = target_is_ilp32(options->triple);
    return true;
  }

  if(!strcmp(attribute, OS_NATIVE128_NAME))
  {
    *out_is_target = target_is_native128(options->triple);
    return true;
  }

  if(!strcmp(attribute, OS_DEBUG_NAME))
  {
    *out_is_target = !release;
    return true;
  }

  if(!strcmp(attribute, OS_BIGENDIAN_NAME))
  {
    *out_is_target = target_is_bigendian(options->triple);
    return true;
  }

  if(!strcmp(attribute, OS_LITTLEENDIAN_NAME))
  {
    *out_is_target = target_is_littleendian(options->triple);
    return true;
  }

  if(!strcmp(attribute, OS_RUNTIMESTATS_NAME))
  {
#if defined(USE_RUNTIMESTATS) || defined(USE_RUNTIMESTATS_MESSAGES)
    *out_is_target = true;
#else
    *out_is_target = false;
#endif

    return true;
  }

  if(!strcmp(attribute, OS_RUNTIMESTATSMESSAGES_NAME))
  {
#ifdef USE_RUNTIMESTATS_MESSAGES
    *out_is_target = true;
#else
    *out_is_target = false;
#endif

    return true;
  }

  return false;
}
