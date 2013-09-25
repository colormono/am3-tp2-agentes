// Agentes by Matías Brunacci, Santiago Tula, Mariano Rivas

// Math2d by Emiliano Causa
// Brightness Tracking by Golan Levin
// Syphone Sync by Andres Coulibrí

// Librerías
import codeanticode.syphon.*;
import processing.video.*;
import java.util.Calendar;

// Objetos
Agente a[]; // Agentes
Capture cam; // Camara de video
PGraphics canvas; // Dibujo Mapping
SyphonServer server; // Send Dibujo para Mapping

// Opciones
boolean debugCamera = false;
int cantidad = 500;
float opacidad = 130;
int altoCapsulas = 100;
int brightestMin = 90;
int brightestX; // X-coordinate of the brightest video pixel
int brightestY; // Y-coordinate of the brightest video pixel
float distMin;

//---------------------------------------------

void setup() {
  size( 640, 640, P3D );
  frameRate( 30 );
  smooth();
  background( 0 );

  // Agentes
  a = new Agente[ cantidad ];
  for ( int i=0 ; i<cantidad ; i++ ) {
    a[i] = new Agente();
  }

  // Cámara
  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("No hay cámaras disponibles para la captura.");
    exit();
  } 
  else {
    println("Camaras disponibles:");
    println( "-------------------" );
    for (int i = 0; i < cameras.length; i++) {
      println( "ID " + i +  ": " + cameras[i] );
    }
    println( "-------------------" );
    cam = new Capture( this, cameras[15] ); // iGlass
    //cam = new Capture( this, cameras[22] ); // Logitech
    cam.start();
  }

  // Mapping
  canvas = createGraphics(width, height, P3D);
  server = new SyphonServer(this, "Processing Syphon");
}

//---------------------------------------------

void draw() {

  // Reconocimiento de tracking
  brightestX = 0; // X-coordinate of the brightest video pixel
  brightestY = 0; // Y-coordinate of the brightest video pixel
  float brightestValue = 0; // Brightness of the brightest video pixel
  // Search for the brightest pixel: For each row of pixels in the video image and
  // for each pixel in the yth row, compute each pixel's index in the video
  cam.loadPixels();
  int index = 0;
  for (int y = 0; y < cam.height; y++) {
    for (int x = 0; x < cam.width; x++) {
      // Get the color stored in the pixel
      int pixelValue = cam.pixels[index];
      // Determine the brightness of the pixel
      float pixelBrightness = brightness( pixelValue );
      // If that value is brighter than any previous, then store the
      // brightness of that pixel, as well as its (x,y) location
      if (pixelBrightness > brightestValue && pixelBrightness > brightestMin) {
        brightestValue = pixelBrightness;
        brightestY = y;
        brightestX = x;
      }
      index++;
    }
    if ( debugCamera ) {
      // Draw a large, yellow circle at the brightest pixel
      background( 0 );
      image( cam, 0, 0, width, height ); // Draw the webcam video onto the screen
      noStroke();
      fill(255, 255, 0);
      ellipse(brightestX, brightestY, 100, 100);
    }
  }

  canvas.beginDraw();
  canvas.fill( 0, 0, 255, opacidad );
  canvas.noStroke();  
  canvas.rect( 0, 0, width, height );

  // Relación simétrica
  /*
  for ( int i=0 ; i<cantidad-1 ; i++ ) {
   for ( int j=i+1 ; j<cantidad ; j++ ) {
   a[i].vincular( a[j] );
   }
   } 
   */

  // Relacion NO simétrica
  for ( int i=0 ; i<cantidad ; i++ ) {
    for ( int j=0 ; j<cantidad ; j++ ) {
      if ( i!=j ) {
        a[i].vincularAlVer( a[j] );
      }
    }
  }

  for ( int i=0 ; i<cantidad ; i++ ) {
    for ( int j=0 ; j<cantidad ; j++ ) {
      if ( i!=j ) {
        a[i].vincularAlContacto( a[j] );
      }
    }
  }

  for ( int i=0 ; i<cantidad ; i++ ) {
    a[i].mover();
    a[i].dibujar();
  }

  // TRACKING DESPROLIJO

  // Capsula sanadores: Gente buena onda
  canvas.fill( 0, 255, 0 );
  canvas.ellipse( 100, height-50, 50, 50 );
  if ( (brightestX > 100 && brightestX < 50) || (brightestY > height-50 && brightestY < height) ) {
    //println( "Sanador seleccionado" );
  }
  if ( mouseX > 100 && mouseX < 50 ) {
    println( "Sanador seleccionado" );
  }

  // Capsula agentes: Gente normal
  canvas.fill( 255, 255, 0 );
  canvas.ellipse( 300, height-50, 50, 50 );
  if ( (brightestX > 300 && brightestX < 350) || (brightestY > height-50 && brightestY < height) ) {
    //println( "Presa seleccionado" );
  }
  if ( mouseX > 300 && mouseX < 350 ) {
    println( "Presa seleccionado" );
  }

  // Capsula toxicos: Gente que no
  canvas.fill( 255, 0, 0 );
  canvas.ellipse( 500, height-50, 50, 50 );
  if ( (brightestX > 500 && brightestX < 550) || (brightestY > height-50 && brightestY < height) ) {
    //println( "Depredador seleccionado" );
  }
  if ( mouseX > 500 && mouseX < 550 ) {
    println( "Depredador seleccionado" );
  }

  canvas.endDraw();
  image(canvas, 0, 0);
  server.sendImage(canvas);
}

//---------------------------------------------

// Capturar nuevo fotograma
void captureEvent(Capture cam) {
  cam.read();
}

// Opciones del teclado
void mouseReleased() {
  Agente r = new Agente();
  a = (Agente[]) append(a, r);
}

// Opciones del teclado
void keyReleased() {
  if (key=='s' || key=='S') saveFrame("capturas/"+timestamp()+"_##.png");
  debugCamera = (key=='c') ? debugCamera =! debugCamera : debugCamera;
}

// Obtener fecha para el nombre del archivo
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}

