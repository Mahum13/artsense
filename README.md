# artsense
Dissertation at King's College London. This is an iOS application which converts coloured images to sound and is meant for visually impaired users.

This prototype can be run only on a mobile simulator in XCode. 

Once the application is running on your device, you can either take a photo or upload a photo, which is then processed and the image pixels are assigned to the relevant audio frequencies for output. 

After the image is converted, it is then displayed back to the user where the user can now interact with the image using their fingers. As they tap over the image, the different pixels of the image will output the corresponding frequencies. 

The user has the option to switch between different oscillators to vary the sound they hear: Sine, Sawtooth, Triangle, Square and White Noise. 

DEVELOPMENT
This project was developed on XCode, written in Swift specifically for iOS. Research included looking at Sir Isaac Newton's colour wheel theory (1704) where he correlated musical notes (D octave) to different colours. His research since has been extended by several scientists who also apply laws of music theory to get a more accurate correlation colour wheel. For this project, I used one developed by R.W Pridmore.

IMAGE PROCESSING
The values of correlation were hardcoded into the program, so when a user taps a pixel, the hex value of the coloured pixel is estimated according to the closest hex value from the pre existing dictionary which holds the correlation values. The camera on most iOS devices are of very high quality, therefore in order to cut down on performance time, the image is first resized to reduce the number of total pixels.
