# Solus Journal
project (solus-journal)

# the oldest stable cmake version we support
cmake_minimum_required (VERSION 2.6)

# tell cmake where its modules can be found in our project directory
list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

# where we install data directory (if we have any)
set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")

# what to call that directory where we install data too
set (PKGDATADIR "${DATADIR}/journal")
set (EXEC_NAME "journal")
set (RELEASE_NAME "Solus Journal")
set (VERSION "1.0.1")
set (VERSION_INFO "First stable version of Solus Journal.")

# we're about to use pkgconfig to make sure dependencies are installed so let's find pkgconfig first
find_package(PkgConfig)

# now let's actually check for the required dependencies
pkg_check_modules(DEPS REQUIRED 
	gtk+-3.0
	libsoup-2.4
	json-glib-1.0
	gtksourceview-3.0
)
add_definitions(${DEPS_CFLAGS})
link_libraries(${DEPS_LIBRARIES})
link_directories(${DEPS_LIBRARY_DIRS})

# make sure we have vala
find_package(Vala REQUIRED)

# make sure we use vala
include(ValaVersion)

# make sure it's the desired version of vala
ensure_vala_version("0.16" MINIMUM)

# files we want to compile
include(ValaPrecompile)
vala_precompile(VALA_C ${EXEC_NAME}
    src/Journal.vala
    src/Notebook.vala
    src/Share.vala 
    src/Tab.vala 
    src/Window.vala 
    src/Files.vala

# tell what libraries to use when compiling
PACKAGES
    gtk+-3.0
    libsoup-2.4
    json-glib-1.0
    gtksourceview-3.0
OPTIONS
    --vapidir=${CMAKE_CURRENT_SOURCE_DIR}/vapi/
)


# tell cmake what to call the executable we just made
add_executable(${EXEC_NAME} ${VALA_C})

# install the binaries we just made
install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION bin)

# install our .desktop file so the Applications menu will see it
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/journal.desktop DESTINATION ${DATADIR}/applications/)

#install icons
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/16x16/journal.png DESTINATION ${DATADIR}/icons/hicolor/16x16/apps/)

install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/22x22/journal.png DESTINATION ${DATADIR}/icons/hicolor/22x22/apps/)

install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/24x24/journal.png DESTINATION ${DATADIR}/icons/hicolor/24x24/apps/)

install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/32x32/journal.png DESTINATION ${DATADIR}/icons/hicolor/32x32/apps/)

install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/36x36/journal.png DESTINATION ${DATADIR}/icons/hicolor/36x36/apps/)

install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/48x48/journal.png DESTINATION ${DATADIR}/icons/hicolor/48x48/apps/)

install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/64x64/journal.png DESTINATION ${DATADIR}/icons/hicolor/64x64/apps/)

install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/72x72/journal.png DESTINATION ${DATADIR}/icons/hicolor/72x72/apps/)

install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/96x96/journal.png DESTINATION ${DATADIR}/icons/hicolor/96x96/apps/)

install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/128x128/journal.png DESTINATION ${DATADIR}/icons/hicolor/128x128/apps/)

install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/192x192/journal.png DESTINATION ${DATADIR}/icons/hicolor/192x192/apps/)

install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/256x256/journal.png DESTINATION ${DATADIR}/icons/hicolor/256x256/apps/)

install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/512x512/journal.png DESTINATION ${DATADIR}/icons/hicolor/512x512/apps/)

install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/scalable/journal.svg DESTINATION ${DATADIR}/icons/hicolor/scalable/apps/)

#subdirectories
add_subdirectory (data)
