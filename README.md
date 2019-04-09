# GrapeImageAnalysis
Programs for analyzing grape cluster components (and their accompanying instructions).

## Getting started
0. Read this read me!  It contains valuable information (and I spent valuable time writing it up for you, after all).
1. Ensure you have the correct [software and packages installed](https://github.umn.edu/under188/GrapeImageAnalysis/blob/master/README.md#software-and-package-needs).
2. [Prepare](https://github.umn.edu/under188/GrapeImageAnalysis/blob/master/README.md#image-preparation) and [segment](https://github.umn.edu/under188/GrapeImageAnalysis/blob/master/README.md#image-segmentation) your images.
3. Use [ImageProcess](https://github.umn.edu/under188/GrapeImageAnalysis/blob/master/README.md#using-imageprocess) to extract data from your segmented images.
4. Use [DataProcessing](https://github.umn.edu/under188/GrapeImageAnalysis/blob/master/README.md#using-dataprocessing) to clean and combine output data.

## Software and package needs
To use this set of programs, you'll need:
   * [Food Color Inspector](http://www.cofilab.com/portfolio/food-color-inspector/)
   * [MATLAB](https://www.mathworks.com/products/matlab.html)
   * [R](https://www.r-project.org/) and, for convenience, an R IDE like [RStudio](https://www.rstudio.com/products/rstudio/)
   * A CSV editor - not necessary, but strongly recommended - for inspection of data
   
## Image preparation
This process is designed to work on photos of grape clusters that look like this:

To achieve this quality, here's what the setup looked like:
![Setup](https://github.umn.edu/under188/GrapeImageAnalysis/blob/master/ImageCaptureSetup.tif?raw=true)

Image quality is important, as it will affect your segmentation quality later (which will affect the accuracy of data extracted from those images).

Images were captured as RAW files (.NEF) by a tripod-mounted Nikon D7200 camera, then color-corrected using [RawTherapee](https://rawtherapee.com/) and compressed into 16-bit TIFF files.  Illumination was provided by two Philips 34W, 3500 K fluorescent lights.  For image capture, I'd recommend using a program like [Gphoto2](http://gphoto.org/) - running from the command line means no messing with the camera, no tedious data transfers, and no re-naming files afterward. 

## Image segmentation
This process is carried out using [Food Color Inspector](http://www.cofilab.com/portfolio/food-color-inspector/), which is written and maintained by the COFILAB at the Instituto Valenciano de Investigaciones Agrarias (IVIA).  Their website is a bit sparce on documentation, so here are a few steps to get started.

   *  First, load the first image in your training set (File > Open Image).  It's worth noting here that large images don't work particularly well (you'll get a warning that says 'This image is too large and will be resampled'); I used 600 x 900px, 16-bit TIFF files.  
   * To start your segmentation, use the Background 1 class (0) and select a square of background color with your cursor.  If you do just a point sample (ie, clicking on the background instead of selecting a square) the process will lag.  On the lower right-hand side, you'll now see a black image - this is the current segmentation of the image.  As you keep going, the segmentation will continue in this thumbnail.
   * To continue segmenting, switch to Class 2 (or whichever class you want) and select another region of interest - either berry or stem.  Again, select a square.  Now, everything within this classification will show up red in your segmentation - if you'd like to change it to a different color, you can click on the color square next to the class name.  You can do this step only once, but you can also keep adding colors to Class 2, and it can help refine your segmentation by making it more accurate.  
   * Continue segmenting with remaining classes.  The goal is to have as accurate a segmentation as possible - that is, berries, stem, and background all classified correctly.
   * If you ever add a step that you want to delete, just double-click on the RGB value and follow the prompt to remove that step.  If you ever try to add a step with the same color as one that already exists, it will give you a warning message.  If you ever want to start the segmentation over completely, just go to File > New Segmentation.
   * When you're done segmenting an image, go to File > Save Training to save the class steps you've created.  To save the segmented image itself, go to File > Save Segmented Image.  The program will ask you to select columns for each CSV file; this exports the color data and pixel percentages.  Select as many or as few characteristics as you'd like.  
   * To segment multiple images using your training set, open the desired training set then go to File > Segment Folder.  You'll select a folder with images to segment, then choose a location to save the finished files.  It's a good idea to go back and review the images done by bulk, because sometimes there are differences in images and the segmentation isn't accurate.  
   
The output of the program is a 600 x 900 PNG image.

## Using ImageProcess
This script was written for the processing of segemented images as produced above.  I make no claims of well-written code or functionality in all situtations; although I hope it works for you, there is a chance it won't.  In particular, some types of segmented images cannot be processed by the program.  Those types of images include:
  * Images where the cluster extends past the bottom of the image
  * Images that contain disconnected shapes
  * Images with a high number of disconnected pixels
  
If a parameter cannot be extracted from an image, it will not be stored in the data array, leading to an error when trying to write the output table.  Noting the number of the image causing the issue will aid in diagnosing the problem.  

Both portrait- and landscape-aligned images can be processed.  The program only looks for PNG files as input, though you could rewrite to use a file type of your choice.  There is no GUI at the moment; make sure to set the working directory to the location of your image files beforehand.  The code is commented and some parameters - like the size of the median filter - can be changed to fit your specifications.

To use the program, simply run the code in MATLAB using the correct directory.  An output file will be written to the same directory when analysis is complete.  The image results will be listed in the file in the order in which they were processed.  

## Using DataProcessing
To process the data 

## Other information
### Who are these programs for?
These programs are intended for those undertaking image analysis as part of their whole grape cluster phenotyping pipelines, or those thinking about building similar image analysis-based processes.  

### Why are these programs here?
This work was done as part of my M.S. degree at the University of Minnesota in the Grape Breeding & Enology program.  They are here for those who want code to repeat the same process, or to use as a jumping-off point for further experimentation.  

### Citations, etc.
The method on which the image segmentation is based is derived mainly from:
Cubero, S. , Diago, M. , Blasco, J. , Tardaguila, J. , Prats‐Montalbán, J. , Ibáñez, J. , Tello, J. and Aleixos, N. (2015), Bunch compactness assessment using image analysis. *Australian Journal of Grape and Wine Research*, 21: 101-109. doi:10.1111/ajgw.12118
