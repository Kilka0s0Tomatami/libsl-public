#pragma once

#ifdef _WIN32
  #ifdef BUILD_LIB
    #define DLL_MODIFIER __declspec(dllexport)
  #else
    #define DLL_MODIFIER __declspec(dllimport)
  #endif
#else
  #define DLL_MODIFIER
#endif
