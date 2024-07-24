
def resource_callback(policy, resource):
    if type(resource) in ("File"):
        if "pywin" in resource.path or "pypiwin" in resource.path:
            resource.add_location = "filesystem-relative:libs"
            resource.add_include = True
    if type(resource) in ("PythonExtensionModule"):
        if resource.name in ["_ssl", "win32.win32file", "win32.win32pipe"]:
            resource.add_location = "filesystem-relative:libs"
            resource.add_include = True
    elif type(resource) in ("PythonModuleSource", "PythonPackageResource", "PythonPackageDistributionResource"):
        if resource.name in ["pywin32_bootstrap", "pythoncom", "pypiwin32", "pywin32", "pythonwin", "win32", "win32com", "win32comext"]:
            resource.add_location = "filesystem-relative:libs"
            resource.add_include = True

def make_win_exe():
    dist = default_python_distribution()
    policy = dist.make_python_packaging_policy()

    policy.allow_in_memory_shared_library_loading = False

    policy.bytecode_optimize_level_one = True
    policy.extension_module_filter = "all"
    policy.include_non_distribution_sources = False
    policy.include_file_resources = True

    policy.include_test = False
    policy.resources_location_fallback = "in-memory"
    policy.resources_location_fallback = "filesystem-relative:libs"

    policy.allow_files = True
    policy.file_scanner_emit_files = True
    policy.register_resource_callback(resource_callback)

    python_config = dist.make_python_interpreter_config()
    python_config.run_module = "helloworld"

    exe = dist.to_python_executable(
        name="helloworld",
        packaging_policy=policy,
        config=python_config,
    )

    # add pyyaml
    # exe.add_python_resources(exe.pip_download(["pyyaml"]))
    # or load from requirements.txt
    exe.add_python_resources(exe.pip_install(["-r", "requirements.txt"]))

    exe.add_python_resources(exe.read_package_root(
        path=".",
        packages=["helloworld"],
    ))

    exe.windows_runtime_dlls_mode = "always"
    return exe

def make_embedded_resources(exe):
    return exe.to_embedded_resources()

def make_install(exe):
    # Create an object that represents our installed application file layout.
    files = FileManifest()
    files.add_python_resource(".", exe)
    return files

def make_msi(exe):
    # See the full docs for more. But this will convert your Python executable
    # into a `WiXMSIBuilder` Starlark type, which will be converted to a Windows
    # .msi installer when it is built.
    return exe.to_wix_msi_builder(
        # Simple identifier of your app.
        "helloworld",
        # The name of your application.
        "helloworld",
        # The version of your application.
        "1.0.0",
        # The author/manufacturer of your application.
        "taicaile"
    )


def register_code_signers():
    return

# Tell PyOxidizer about the build targets defined above.
register_code_signers()
register_target("winexe", make_win_exe)
register_target("resources", make_embedded_resources, depends=["winexe"], default_build_script=True)
register_target("install", make_install, depends=["winexe"], default=True)
register_target("msi_installer", make_msi, depends=["winexe"])
resolve_targets()
