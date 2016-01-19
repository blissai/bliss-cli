Virtualbox Configuration for [Bliss CLI](https://github.com/founderbliss/bliss-cli)
------------------------
**FOR DOCKER MACHINE USERS ONLY**

In order to configure VirtualBox to assign more cores to the VM, do the following:

Firstly, find out how many cores your machine has. Don't try to assign more cores than your physical machine has.

Windows Powershell:
```````````````````
Get-WmiObject -class Win32_processor | ft NumberOfCores
```````````````````
OSX:
``````````
system_profiler SPHardwareDataType | grep 'Total Number of Cores'
``````````

After determining how many cores you want to assign, run the following commands to configure your VM.

OSX:
```````````````
docker-machine stop default
VBoxManage modifyvm default --cpus NUM_CORES_TO_ASSIGN
docker-machine start default
```````````````
Windows:
```````````````
docker-machine stop default
$PATH_TO_VIRTUALBOX_INSTALL/VBoxManage.exe modifyvm default --cpus NUM_CORES_TO_ASSIGN
docker-machine start default
```````````````
