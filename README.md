# profileViewerApp
This MATLAB App handles raw Licel Data. It can read both binary files and ASCII files (generated with the Licel Advanced Viewer software). With Save Data you can save all the data in the licel file into a MATLAB struct.

![immagine](https://github.com/eavoc/profileViewerApp/assets/34692571/6faae2a6-97d6-48d1-b230-eecad379223b)

Unfortunately the project was abandoned, hence there could be bugs and missing functions.
Two missing functions are the background removal and a converter for SCC (the push button Export) while one bug is that, depending on your configuration of the Licel software TCPIP Acquis, you may have to edit the matlab functions readLicel.m and readLicelBin.m.
