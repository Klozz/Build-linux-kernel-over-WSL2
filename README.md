 Build linux kernel over WSL2
 =========================================
Is the same way as normal xD but looks cool to say WSL?
also copy the file automatic to the desktop to avoid time searching the path of the subsystem

## Required packages 
```bash
sudo apt-get install build-essential libncurses-dev bison flex libssl-dev libelf-dev zip -y
```
![](https://i.imgur.com/nPYiGxN.png)

## Building script example
```bash
./build.sh miatoll
```
With yuki clang or proton clang you not need to download GCC etc
![Building kernel](https://i.imgur.com/dFxbW9y.png "building kernel")


to make your life easier you can copy the zip file using bash obviously so if you want to make 
it dinamyc for others pc's instead of hardcode using the path set it using wslpaht:

the magical command is:

```bash
echo "$(wslpath $(cmd.exe /C "echo %USERPROFILE%"))" > a.txt
WDesktop=$(cat a.txt)
```
it can show u the following
![](https://i.imgur.com/zk3RyQM.png)

but if you use > file.txt you can see only the Windows path.

![](https://i.imgur.com/irkQVSb.png)

![](https://i.imgur.com/oezajmm.png)
