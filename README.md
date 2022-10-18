# Cross-compile Wireshark for Android

Based on: https://github.com/luckiday/wireshark-for-android

This repository provides the docker image to cross-compile 
wireshark (3.4.0) for Android automatically.

## Quickstart 
Download this repository, build a docker image and run it. 

```bash
git clone https://github.com/snowy-owll/wireshark-for-android.git
cd wireshark-for-android
sudo docker build -t snowy-owl/build-ws .
sudo docker run -v build_ws_output:/build_ws/output snowy-owl/build-ws:latest
```

It will run and compile the wireshark and related libraries.

This Docker image generates two folders in the volume, `ws_lib` and `ws_bin`. 
`ws_lib` contains the `libwireshark.so` and related libraries. 
`ws_bin` contains the binary programs `android_ws_dissector` 
and `android_ws_dissector_pie`.
