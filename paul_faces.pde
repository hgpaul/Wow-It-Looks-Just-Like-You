import gab.opencv.*;
import processing.video.*;
import java.awt.Rectangle;

String cascadePath = "C:/Users/henry/Documents/HAR 371/paul_faces/cascade_files/"; //change it to work on your local machine!
String faceDirectory = "/10kTranspFaces";    // folder of preprocessed transparent faces to search
ImageVector faceToMatch, closest;
ArrayList<ImageVector> otherFaces = new ArrayList<ImageVector>();
OpenCV cv;
Capture camera;
Rectangle[] faces;
PImage currentFace;

void setup() {
  size(640,480);  
  
  println("Getting a list of all image files...");
  ArrayList<String> files = new ArrayList<String>();
  File dir = new File(sketchPath(faceDirectory));
  if (dir.isDirectory()) {
    for (File f : dir.listFiles()) {
      String filename = f.getName();
      String extension = filename.substring(filename.lastIndexOf(".") + 1);
      if (extension.equals("jpg") || extension.equals("png")) {
        files.add(f.getAbsolutePath());
      }
    }
    println("- found " + files.size() + " images");
  } 
  else {
    println("- not a directory, quitting!");
    exit();
  }

  // create vectors from all the other face images too
  println("Creating vectors to test against (may take a while)...");
  for (int i=0; i<files.size(); i++) {
    if (i%1000 == 0) {
      println("- " + i + " / " + files.size());
    }
    ImageVector face = new ImageVector(files.get(i), 16, 16);
    face.minMax();
    otherFaces.add(face);
  }
  
  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("No webcams detected");
    exit();
  }
  camera = new Capture(this, cameras[0]);
  camera.start();
  
  //create openCV instance
  cv = new OpenCV(this, width,height);
  cv.loadCascade(cascadePath + "haarcascade_frontalface_alt2.xml", true);
}

void draw() {

  if (camera.available()) {

    camera.read();
    image(camera, 0,0, width,height);
    cv.loadImage(camera);

    float scaleFactor = 1.1;
    int minNeighbors =  3;
    int minSize =       30;
    int maxSize =       width;
    faces = cv.detect(scaleFactor, minNeighbors, 0, minSize, maxSize);
    
    // display the faces we've found
    for (Rectangle face : faces) {
      currentFace = camera.get(face.x, face.y, face.width, face.height);      

      if (currentFace != null) {

        faceToMatch = new ImageVector(currentFace, 16, 16);
        faceToMatch.minMax();

        float minDist = MAX_FLOAT;
        for (ImageVector other : otherFaces) {

          float dist = faceToMatch.cosineSimilarity(other, true);

          if (dist < minDist) {
            minDist = dist;
            closest = other;
          }
        }

        image(loadImage(closest.label), face.x, face.y, face.width*1.2, face.height*1.4);
      }
    }
  }
}     