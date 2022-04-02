from shutil import copyfile

destiny = 'windows\\runner\\runner.exe.manifest'
releaseconfig = 'bin\\runner.exe.manifest.release'
copyfile(releaseconfig,destiny)