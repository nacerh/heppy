set(heppy_module_file ${HEPPY_DIR}/modules/heppy/1.0)

function(module_append_command)
    # message(STATUS "module_append_command::${ARGV0} ${ARGV1} ${ARGV2} ${ARGV3}")
    set(_unchecked ${ARGV4})
    get_cmake_property(_variableNames VARIABLES)
    list (SORT _variableNames)
    foreach (_variableName ${_variableNames})
        if (${ARGV2} STREQUAL ${_variableName})
            # message (STATUS "matched ${ARGV2}")
            set(_path ${ARGV3})
            get_filename_component(_abs_path ${_path} ABSOLUTE)
            if ((EXISTS ${_path}) OR (_unchecked))
                # file(APPEND ${HEPPY_DIR}/modules/heppy.module "# ${ARGV2}\n")
                file(APPEND ${heppy_module_file} "${ARGV0} ${ARGV1} ${_abs_path} \n")
                # message(STATUS "appending to ${HEPPY_DIR}/modules/heppy.module: ${ARGV0} ${ARGV1} ${ARGV3}")
                break()
            endif()
        endif()
    endforeach()
endfunction(module_append_command)

function(module_append_command_no_prop)
    set(_abs_path ${ARGV2})
    if(${ARGV3})
        get_filename_component(_abs_path ${ARGV2} ABSOLUTE)
    endif()
    file(APPEND ${heppy_module_file} "${ARGV0} ${ARGV1} ${_abs_path} \n")
endfunction(module_append_command_no_prop)

function(make_module)
    message(STATUS "${Yellow}Making a module file: ${heppy_module_file}${ColourReset}")
    file(WRITE ${heppy_module_file} "#%Module\n")
    file(APPEND ${heppy_module_file} "set version HEPPY1.0\n")
    foreach(_pack PYTHIA8_DIR ROOT_HEPPY_PREFIX HEPMC3_DIR HEPMC_DIR LHAPDF6_DIR FASTJET_DIR HEPPY_DIR)
        message(STATUS "make_module::${_pack}")
        module_append_command("prepend-path" "PATH" "${_pack}" "${${_pack}}/bin")
        module_append_command("prepend-path" "DYLD_LIBRARY_PATH" "${_pack}" "${${_pack}}/lib")
        module_append_command("prepend-path" "LD_LIBRARY_PATH" "${_pack}" "${${_pack}}/lib")
        module_append_command("prepend-path" "DYLD_LIBRARY_PATH" "${_pack}" "${${_pack}}/lib64")
        module_append_command("prepend-path" "LD_LIBRARY_PATH" "${_pack}" "${${_pack}}/lib64")
        module_append_command("prepend-path" "PYTHONPATH" "${_pack}" "${${_pack}}/lib")
        module_append_command("prepend-path" "PYTHONPATH" "${_pack}" "${${_pack}}/lib64")

        module_append_command_no_prop("setenv" "${_pack}" "${${_pack}}" TRUE)
        if (${_pack} STREQUAL ROOT_HEPPY_PREFIX)
            module_append_command_no_prop("setenv" "ROOTSYS" "${${_pack}}" TRUE)
        endif()

    endforeach(_pack)
    execute_process ( COMMAND find -L ${FASTJET_DIR} -name "fastjet.py" WORKING_DIRECTORY /tmp OUTPUT_VARIABLE FASTJET_PYTHON OUTPUT_STRIP_TRAILING_WHITESPACE )
    execute_process ( COMMAND find -L ${FASTJET_DIR} -name "_fastjet.so" WORKING_DIRECTORY /tmp OUTPUT_VARIABLE FASTJET_PYTHON_SO OUTPUT_STRIP_TRAILING_WHITESPACE )
    get_filename_component(FASTJET_PYTHON_SUBDIR ${FASTJET_PYTHON} DIRECTORY)
    module_append_command("prepend-path" "PYTHONPATH" "FASTJET_DIR" "${FASTJET_PYTHON_SUBDIR}")
    get_filename_component(FASTJET_PYTHON_SUBDIR_SO ${FASTJET_PYTHON_SO} DIRECTORY)
    module_append_command("prepend-path" "PYTHONPATH" "FASTJET_DIR" "${FASTJET_PYTHON_SUBDIR_SO}")
    get_filename_component(Python_EXECUTABLE_SUBDIR ${Python_EXECUTABLE} DIRECTORY)
    module_append_command("prepend-path" "PATH" "HEPPY_DIR" "${Python_EXECUTABLE_SUBDIR}")

    module_append_command("prepend-path" "PYTHONPATH" "${HEPPY_DIR}" "${HEPPY_DIR}/cpptools/lib" TRUE)
    module_append_command("prepend-path" "PYTHONPATH" "${HEPPY_DIR}" "${HEPPY_DIR}/cpptools/lib64" TRUE)
    module_append_command("prepend-path" "PYTHONPATH" "${HEPPY_DIR}" "${HEPPY_DIR}" TRUE)

    module_append_command_no_prop("setenv" "HEPPY_DIR" "${HEPPY_DIR}" TRUE)
    module_append_command_no_prop("setenv" "HEPPY_PYTHON_EXECUTABLE" "${Python_EXECUTABLE}" TRUE)
    module_append_command_no_prop("set-alias" "heppython" "\"${Python_EXECUTABLE}\"" FALSE)
    module_append_command_no_prop("set-alias" "heppy_cd" "\"cd ${HEPPY_DIR}\"" FALSE)


endfunction(make_module)
