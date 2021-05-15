.onAttach <- function(libname, pkg){
  Sys.setenv(V8_running = is_loaded(TRUE))
  packageStartupMessage(paste("Using V8 engine", version()))
}

.onLoad <- function(libname, pkgname){
  # Test for development
  # ct <- v8()
  # ct$source(system.file("js/underscore.js", package = pkgname))
  # rm(ct)
}
