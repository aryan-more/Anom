from shutil import copyfile

destiny = 'windows\\runner\\runner.exe.manifest'
debugconfig = 'bin\\runner.exe.manifest.debug'
copyfile(debugconfig,destiny)