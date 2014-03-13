// Vencedores vencidos
// by Matias Brunacci, Mariano Rivas y Santiago Tula

// Funciona en Processing 1.5.1
// TUIO library by Martin Kaltenbrunner
// Math2d by Emiliano Causa
/*

 Config.:
 c = Calibrar mapping
 s = Guardar calibración del mapping
 l = Cargar calibración del mapping
 p = Capturar pantalla
 d = Debug app
 
 TO-DO / Ideas no implementadas:
 - Los predadores cazan y llevan presa a la capsula (nido)
 - La presa come solo del blob más cercano
 - Detectar objetos TUIO
 - Ellipsis alpha para alas colisiones
 
 */

// Librerías
import java.util.Calendar;
import deadpixel.keystone.*;
import TUIO.*;
Maxim maxim;

// Objetos
TuioProcessing tuioClient; // Tracker
PGraphics canvas; // Mapping
Keystone ks; // Mapping
CornerPinSurface surface; // Mapping
Agente a[]; // Agentes
PVector comida; // Comida
AudioPlayer ambiente; // Sonido ambiente
AudioPlayer come_1, come_2, come_3; // Sonidos: rojo toca verde o verde toca rojo
AudioPlayer depredador_1, depredador_2, depredador_3; // Sonidos: depredador toca presa
PImage textura;
PImage imgDepredador, imgPresa, imgSanador;

// Configuraciones iniciales
// these are some helper variables which are used
// to create scalable graphical feedback
boolean debug = false;
float cursor_size = 15;
float object_size = 60;
float table_size = 640;
float scale_factor = 1;
float opacidad = 150; // Easing visual
int cantidad = 60; // Cantidad inicial de agentes
int _cantidad; // Cantidad inicial de agentes
boolean hayComida = false;
int edadMinima = 2; // Edad mínima para reconocer la comida


//---------------------------------------------

void setup() {
  
  // Lienzo
  size( 640, 480, P3D );
  frame.setBackground( new java.awt.Color( 0, 0, 0 ) );
  frameRate( 30 );
  smooth();
  
  // Imagenes
  textura = loadImage("texturaRa5.jpg");
  imgDepredador = loadImage("depredador.png");
  imgPresa = loadImage("bichonegro.png");
  imgSanador = loadImage("sanador.png");

  // TUIO
  scale_factor = height/table_size;
  tuioClient  = new TuioProcessing(this);

  // Agentes
  a = new Agente[ cantidad ];
  for ( int i=0 ; i<cantidad ; i++ ) {
    a[i] = new Agente( random(width), random(height), "presa" );
  }

  // Comida
  comida = new PVector( random(width), random(height) );

  // Sonidos
  maxim = new Maxim(this);
  ambiente = maxim.loadFile("ambiente.wav");
  come_1 = maxim.loadFile("color_come_color.wav");
  come_2 = maxim.loadFile("color_come_color2.wav");
  come_3 = maxim.loadFile("color_come_color3.wav");
  depredador_1 = maxim.loadFile("depredador_come.wav");
  depredador_2 = maxim.loadFile("depredador_come2.wav");
  depredador_3 = maxim.loadFile("depredador_come3.wav");

  ambiente.setLooping(true);
  come_1.setLooping(false);
  come_2.setLooping(false);
  come_3.setLooping(false);
  depredador_1.setLooping(false);
  depredador_2.setLooping(false);
  depredador_3.setLooping(false);

  ambiente.cue(0);
  //ambiente.play();

  // Mapping
  ks = new Keystone(this);
  surface = ks.createCornerPinSurface(800, 600, 30);
  canvas = createGraphics(width, height, P3D);
  
}

//---------------------------------------------

void draw() {

  // Variables iniciales
  PVector surfaceMouse = surface.getTransformedMouse();
  float obj_size = object_size*scale_factor; 
  float cur_size = cursor_size*scale_factor;

  // Comienzo dibujo y limpio el fondo
  canvas.beginDraw();
  pushStyle();
  canvas.tint( 255 );  // Display at half opacity
  canvas.image( textura, 0, 0 );
  canvas.fill( 255, opacidad );
  canvas.noStroke();  
  canvas.rect( 0, 0, width, height );  
  popStyle();


  // Cursores TUIO
  Vector tuioCursorList = tuioClient.getTuioCursors();
  for (int i=0;i<tuioCursorList.size();i++) {
    TuioCursor tcur = (TuioCursor)tuioCursorList.elementAt(i);
    Vector pointList = tcur.getPath();

    if (pointList.size()>0) {
      TuioPoint start_point = (TuioPoint)pointList.firstElement();
      for (int j=0;j<pointList.size();j++) {
        TuioPoint end_point = (TuioPoint)pointList.elementAt(j);
        line(start_point.getScreenX(width), start_point.getScreenY(height), end_point.getScreenX(width), end_point.getScreenY(height));
        start_point = end_point;
      }
      
      println( tcur.getStartTime().getSeconds() );
      println( tcur.getTuioTime().getSeconds() );

      float nacimiento = tcur.getStartTime().getSeconds();
      float edad = tcur.getTuioTime().getSeconds();

      if( edad - nacimiento > edadMinima ){
        
        // Capturo posición del cursor
        float _x = tcur.getScreenX(width);
        float _y = tcur.getScreenY(height);
        
        // Normalizo y asigno posición a la variable comida
        comida.x = _x;  
        comida.y = _y;
        
        // Los mando a comer
        hayComida = true;
  

      } else {
        hayComida = false;
      }

      canvas.pushStyle();
      canvas.fill(192, 192, 192);
      canvas.ellipse( tcur.getScreenX(width), tcur.getScreenY(height), cur_size, cur_size);
      canvas.popStyle();
      
      if ( debug ) {
        canvas.pushStyle();
        canvas.fill( 0, 255, 0 );
        canvas.ellipse( comida.x, comida.y, 30, 30 );
        canvas.popStyle();
      }
      
    }
  }

  // Relacion NO simétrica
  for ( int i=0 ; i<a.length ; i++ ) {
    for ( int j=0 ; j<a.length ; j++ ) {
      if ( i!=j ) {
        a[i].vincularAlVer( a[j] );
      }
    }
  }

  for ( int i=0 ; i<a.length ; i++ ) {
    for ( int j=0 ; j<a.length ; j++ ) {
      if ( i!=j ) {
        a[i].vincularAlContacto( a[j] );
      }
    }
  }

  // Agentes
  for ( int i=0 ; i<a.length ; i++ ) {
    a[i].mover();
    a[i].dibujar();
    if ( hayComida ) {
      a[i].comer( comida.x, comida.y );
    }
  }

  // Termino dibujo y lo imprimo
  //canvas.scale(-1, 1); // this will flip everything! (read: also the coordinates)
  canvas.endDraw();

  // Limpiar fondo
  background( 0 );
  //image( canvas, 0, 0 );
  surface.render( canvas );
  
  // Contador de agentes
  if( cantidad != _cantidad ){
    println( "Cantidad de agentes: " + cantidad );
  }
  _cantidad = cantidad;
}

//---------------------------------------------


// Métodos TUIO para los CURSORES

// called when a cursor is added to the scene
void addTuioCursor(TuioCursor tcur) {
  println("add cursor "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY());
}

// called when a cursor is moved
void updateTuioCursor (TuioCursor tcur) {
  println("update cursor "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY()
    +" "+tcur.getMotionSpeed()+" "+tcur.getMotionAccel() +" Time: " + tcur.getTuioTime().getSeconds() );
}

// called when a cursor is removed from the scene
void removeTuioCursor(TuioCursor tcur) {
  println("remove cursor "+tcur.getCursorID()+" ("+tcur.getSessionID()+")");

  // Detectar posición
  float _x = tcur.getX();
  float _y = tcur.getY();

  // Normalizar posición
  _x = map( _x, 0, 1, 0, width );
  _y = map( _y, 0, 1, 0, height );

  // Raza random
  String raza = "";
  float randomRaza = random( 100 );
  if ( randomRaza >= 10 || randomRaza <= 90 ) { 
    raza = "presa";
  }
  if ( randomRaza < 10 ) { 
    raza = "depredador";
  }
  if ( randomRaza > 90 ) { 
    raza = "sanador";
  }

  // Crear agente
  Agente r = new Agente( _x, _y, raza );
  a = (Agente[]) append( a, r );

}


// called after each message bundle
// representing the end of an image frame
void refresh(TuioTime bundleTime) { 
  redraw();
}


//---------------------------------------------

// Opciones del teclado
void keyReleased() {

  // Calibrate mapping
  if (key=='c') { 
    ks.toggleCalibration();
  }

  // Load Calibration mapping
  if (key=='l') { 
    ks.load();
  }

  // Save Calibration mapping
  if (key=='s') { 
    ks.save();
  }

  // Crear agentes
  if ( key=='1' ) { 
    Agente r = new Agente( random(width), random(height), "presa" );
    a = (Agente[]) append( a, r );
  }
  if ( key=='2' ) { 
    Agente r = new Agente( random(width), random(height), "depredador" );
    a = (Agente[]) append( a, r );
  }
  if ( key=='3' ) { 
    Agente r = new Agente( random(width), random(height), "sanador" );
    a = (Agente[]) append( a, r );
  }

  // Debug
  if ( key=='d' ) { 
    debug =! debug;
  }

  // Capturar pantalla
  if (key=='p' || key=='P') saveFrame("capturas/"+timestamp()+"_##.png");
  
  // Detener ambiente
  if (key=='a' || key=='A') ambiente.play();
  
}

// Obtener fecha para el nombre del archivo
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}

