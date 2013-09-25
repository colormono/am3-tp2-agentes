// Actualizada al 19/Ago/2012 v8.0 (con seno corregido)
// con urna
//------------------------------------------------------------------------------------------
// MARCA: FUNCIONES MATEMATICAS
//
// by Emiliano Causa 2008
// emiliano.causa@gmail.com
// www.emiliano-causa.com.ar
// www.biopus.com.ar
//====================================================================================
// class Punto
// class Promedio
// class Urna
// class Circulo
//====================================================================================

float seno( float x, float x1, float x2, float y1, float y2, float ang1, float ang2 ) {
  float angulo = map( x, x1, x2, ang1, ang2 );
  float valor = sin( angulo );  
  return map( valor, -1, 1, y1, y2 );
}
//------------------------------------------------------------------------------------------

float linea( float x, float x1, float x2, float y1, float y2 ) {
  return (x-x1)/(x2-x1)*(y2-y1)+y1;
}
//---------------------------------------------------------------------------------------------------------------------------

float lineaLim( float x, float x1, float x2, float y1, float y2 ) {
  float valor = (x-x1)/(x2-x1)*(y2-y1)+y1;
  valor = min(valor,y2);
  valor = max(valor,y1);
  return valor;
}
// ------------------------------------------------------------------------------------------
// Funci√î√∏Œ©n que limite valores de √î√∏Œ©ngulos en [0;2*PI)
//
float limitarAnguloRad(float valor) {
  float nuevo = valor;
  for(int i=0 ; nuevo < 0 && i<100 ; i++) {
    nuevo += TWO_PI;
  }
  for(int i=0 ; nuevo >= TWO_PI && i<100 ; i++) {
    nuevo -= TWO_PI;
  }
  return nuevo;
}

//---------------------------------------------------------------------------------------------------------------------------

float menorDistAngulos( float origen, float destino ) {
  float distancia = destino - origen;
  return anguloRangoPI( distancia );
}
//---------------------------------------------------------------------------------------------------------------------------

float anguloRango2PI( float angulo ) {
  float este = angulo;

  for( int i=0 ; i<100 ; i++ ) {
    if( este >= TWO_PI ) {
      este -= TWO_PI;
    }
    else if( este < 0 ) {
      este += TWO_PI;
    }
    if( este >= 0 && este <= TWO_PI ) {
      break;
    }
  }
  return este;
}
//---------------------------------------------------------------------------------------------------------------------------

float anguloRangoMenos2PI( float angulo ) {
  float este = angulo;

  for( int i=0 ; i<100 ; i++ ) {
    if( este > 0 ) {
      este -= TWO_PI;
    }
    else if( este <= -TWO_PI ) {
      este += TWO_PI;
    }
    if( este > - TWO_PI && este <= 0 ) {
      break;
    }
  }
  return este;
}
//---------------------------------------------------------------------------------------------------------------------------

float anguloRangoPI( float angulo ) {
  float este = angulo;
  for( int i=0 ; i<100 ; i++ ) {
    if( este > PI ) {
      este -= TWO_PI;
    }
    else if( este <= -PI ) {
      este += TWO_PI;
    }
    if( este >= -PI && este <= PI ) {
      break;
    }
  }
  return este;
}
//---------------------------------------------------------------------------------------------------------------------------
// MARCA: PUNTO - PUNTO - PUNTO - PUNTO - PUNTO - PUNTO - PUNTO - PUNTO - PUNTO - PUNTO - PUNTO - PUNTO - PUNTO - PUNTO -
//---------------------------------------------------------------------------------------------------------------------------
class Punto {
  float x,y;
  //--------------------------

  Punto() {
    iniciar( 0, 0 );
  }
  //--------------------------

  Punto( Punto otro ) {
    iniciar( otro.x, otro.y );
  }
  //--------------------------

  Punto( float x_, float y_ ) {
    iniciar( x_, y_ );
  }
  //--------------------------

  void iniciar( float x_, float y_ ) {
    x = x_;
    y = y_;
  }
  //--------------------------

  void copiarDe( Punto otro ) {
    x = otro.x;
    y = otro.y;
  }
  //--------------------------
  void string() {
    println( "(  "+x+"  ;   "+y+"  )");
  }
  //--------------------------

  void dibujarNormalizado( float x1 , float y1 , float w , float h , float ancho) {
    line( x1+(x*w)-ancho, y1+(y*h), x1+(x*w)+ancho, y1+(y*h) );
    line( x1+(x*w), y1+(y*h)-ancho, x1+(x*w), y1+(y*h)+ancho );
  }
  //--------------------------

  void dibujarCruz( ) {
    dibujarCruz( color(0,255,0), 20 );
  }
  //--------------------------

  void dibujarCirculo( color esteCol, float ancho ) {
    stroke( esteCol );
    ellipse( x, y, ancho*2, ancho*2 );
  }
  //--------------------------

  void dibujarCruz( color esteCol, float ancho ) {
    stroke( esteCol );
    line( x-ancho, y, x+ancho, y );
    line( x, y-ancho, x, y+ancho );
  }
}
//--------------------------------  
float direccion( Punto a, Punto b ) {
  return atan2( b.y-a.y, b.x-a.x );
}
//--------------------------------  
float distancia( Punto a, Punto b ) {
  return dist( a.x, a.y, b.x, b.y );
}
//--------------------------------  
void dibujaLinea( Punto a, Punto b ) {
  line( a.x, a.y, b.x, b.y );
}
//--------------------------------  
Punto toPunto( float x , float y ){
  Punto aux = new Punto( x , y );
  return aux;
}
//--------------------------------  
Punto obtieneCruceDosLineas( Punto p1, Punto p2, Punto p3, Punto p4 ) {
  Punto aux = new Punto();

  float x = 0;
  float y = 0;

  float a = p2.y - p1.y;
  float b = p2.x - p1.x;
  float c = p4.y - p3.y;
  float d = p4.x - p3.x;

  if( b != 0 && d != 0 ) {

    float ab = a/b;
    float cd = c/d;

    float e = p3.y - p1.y + p1.x*ab - p3.x*cd;

    float p = ab-cd;

    if( p != 0) {
      x = e / p;
      y = linea( x, p1.x, p2.x, p1.y, p2.y );
    }
  }
  else {
    if( b == 0 && d != 0 ) {
      x = p1.x;
      y = linea( x, p3.x, p4.x, p3.y, p4.y );
    } 
    else if( b != 0 && d == 0 ) {
      x = p3.x;
      y = linea( x, p1.x, p2.x, p1.y, p2.y );
    }
  }

  aux.iniciar(x,y);

  return aux;
}
//---------------------------------------------------------------------------------------------------------------------------
// MARCA: PROMEDIO - PROMEDIO - PROMEDIO - PROMEDIO - PROMEDIO - PROMEDIO - PROMEDIO - PROMEDIO - PROMEDIO - PROMEDIO - 
//---------------------------------------------------------------------------------------------------------------------------
// Obtiene promedios en forma din√î√∏Œ©mica
class Promedio {
  float valor,incidencia, ultimo;
  int cont;
  int limite = 10000;
  //--------------------------------------------

  Promedio() {
    cont = 0;
    valor = 0;
    incidencia = 1;
  }
  //--------------------------------------------

  void agregar( float nuevo ) {
    cont++;
    ultimo = nuevo;
    if( cont == 1 ) {
      valor = nuevo;
    }
    else if( cont>limite ) {
      incidencia = 1.0/limite;
      valor = valor * (1-incidencia) + nuevo * incidencia;
    }
    else {
      incidencia = 1.0/cont;
      valor = valor * (1-incidencia) + nuevo * incidencia;
    }
  }
  //--------------------------------------------

  void reset( float nuevo ) {
    cont = 1;
    valor = nuevo;
  }
  //--------------------------------------------

  void reset( float nuevo, int cont_) {
    cont = cont_;
    valor = nuevo;
  }
  //--------------------------------------------

  void string() {
    println( "Valor = " + valor + "  | Incidencia = " + incidencia  + "  | Ultimo = " + ultimo );
  }
}
//--------------------------------------------------
class Urna {

  int cantidad;
  boolean urn[];
  int sacados;
  int cont;

  //-------------------------------------
  Urna( int cantidad_ ) {

    cantidad = cantidad_;
    urn = new boolean [cantidad];
    reset();
  }

  //-------------------------------------
  int sacar() {
    int resultado = -1;
    if( ! vacia() ) {

      int tirada = int( random (cantidad));
      incrementar( tirada );    

      if ( !urn[ cont ] ) {

        urn[ cont ] = true;
        sacados ++;
        resultado = cont;
      }
      else {
        boolean encontro = false;

        for(int i=0; i<cantidad && !encontro ; i++) {

          incrementar( 1 );
          if( !urn[cont] ) {
            urn[cont] = true;
            sacados ++;
            resultado = cont;
            encontro = true;
          }
        }
      }
    }
    return resultado;
  }
  //----------------------------

  boolean vacia() {
    return sacados>=cantidad;
  }
  //----------------------------

  void incrementar( int valor ) {
    cont = (cont+valor) % cantidad;
  }

  //--------------------------------

  void reset() {
    for(int i=0; i < cantidad; i++) {
      urn [i] = false;
    }
    sacados = 0;
    cont = 0;
  }
}
//====================================================================================

class Circulo {
  Punto centro;
  //float radio;
  float d;
  float r;

  float A, B, C;

  Circulo( float x_, float y_, float radio_ ) {
    centro = new Punto( x_, y_ );
    r = radio_;
    d = r*2.0;

    A = -2*x_;
    B = -2*y_;
    C = x_*x_ + y_*y_ - r*r;
  }


  Circulo( Punto p , float radio_ ) {
    centro = new Punto( p );
    r = radio_;
    d = r*2.0;

    A = -2*p.x;
    B = -2*p.y;
    C = p.x*p.x + p.y*p.y - r*r;
  }

  void dibujar() {    
    //println( " d = "+d);
    ellipse( centro.x, centro.y, d, d );
  }
}
//====================================================================================

Punto desdePuntoAngDist( Punto p, float angulo, float distancia ) {

  Punto aux = new Punto( p );

  float dx = distancia * cos( angulo );
  float dy = distancia * sin( angulo );

  aux.x += dx;
  aux.y += dy;

  return aux;
}
//====================================================================================

class InterseccionCirculos {

  Punto p1,p2;
  boolean existe;

  //------------------------------

  InterseccionCirculos( Punto cc1, Punto cc2, float radio1, float radio2 ) {
    Circulo c1 = new Circulo( cc1, radio1 );
    Circulo c2 = new Circulo( cc2, radio2 );
    iniciar( c1, c2 );
  }
  //------------------------------

  InterseccionCirculos( Circulo c1, Circulo c2 , float sobreRadio ) {
    Circulo c_1 = new Circulo( c1.centro, c1.r+sobreRadio );
    Circulo c_2 = new Circulo( c2.centro, c2.r+sobreRadio );
    iniciar( c_1, c_2 );
  }
  //------------------------------

  InterseccionCirculos( Circulo c1, Circulo c2 ) {
    iniciar( c1, c2 );
  }
  //------------------------------

  void iniciar( Circulo c1, Circulo c2 ) {

    p1 = null;
    p2 = null;
    existe = false;
    //aca estoy restando las dos ecuaciones de los circulos
    // x2 + y2 + A1x + B1x + C1 = 0 (del circulo 1)
    // -
    // x2 + y2 + A2x + B2x + C2 = 0 (del circulo 2)
    // -------------------------
    //     (A1-A2) x + (B1-B2) y + (C1-C2) = 0
    //
    float A = c1.A - c2.A; 
    float B = c1.B - c2.B;
    float C = c1.C - c2.C;

    // Ax + By + C = 0 recta que pasa por los dos puntos de interseccion
    //println( "A="+A +" B="+B +" C="+C);

    float x1, x2, y1, y2;
    // Ecuacion de la linea recta
    //y = (-AX -C) / B
    //X = (-By -C) / A

    if ( B != 0 ) {

      x1 = 0;
      y1 = (-A*x1-C)/B;
      x2 = width;
      y2 = (-A*x2-C)/B;
      //line( x1, y1, x2, y2 );

      // Ahora pongo la ecuacion de la recta
      // y = (-AX -C) / B
      // en la de un circulo
      // x2 + y2 + Ac x + Bc y + Cc = 0
      // es decir:
      // x2 + [-AX-C)/B ]2 + Ac x + Bc [ (-AX-C)/B ] + Cc = 0
      // luego lleva esta ecuacion a la forma
      // aX2 + bX + c = 0 para aplicar la ecuacion cuadratica
      // x = (-b +- sqrt( b2-4ac ) )/2a
      //

      // ya que y = (-AX -C) / B entonces y2 = Dx2 + Ex + F
      // con los siguientes valores de D,E y F (los valores de A,B y C son de la recta)
      //
      float D = (A*A) / (B*B);
      float E = (2*A*C) / (B*B);
      float F = (C*C) / (B*B);

      // ya que y = (-AX -C) / B entonces y = Gx + H con:
      float G = -A / B;
      float H = -C / B;

      // entonces la ecuacion queda
      // x2 + Dx2 + Ex + F + Ac x + Bc.G x + Bc.H + Cc = 0
      // y por lo tanto, la forma a.x2 + b.x + c = 0 se compone asi:
      float a = 1 + D;
      float b = E + c1.A + G*c1.B;
      float c = F + H*c1.B + c1.C;

      //y aqui va la ecuacion cuadratica
      float delta = (b*b) - 4*a*c;

      if ( delta >= 0 ) { //sino entonces el resultado esta en el dominio de los imaginarios
        float xa = ( -b + sqrt( delta ) ) / (2*a);
        float xb = ( -b - sqrt( delta ) ) / (2*a);

        //line( xa, 0, xa, height );
        //line( xb, 0, xb, height );

        //y = (-AX -C) / B
        float ya = (-A*xa -C )/B;
        float yb = (-A*xb -C )/B;

        //ellipse( xa, ya, 20, 20 );
        //ellipse( xb, yb, 20, 20 );
        p1 = new Punto( xa, ya );
        p2 = new Punto( xb, yb );
        existe = true;
      }
    }
    else if ( A!= 0 ) {

      y1 = 0;
      x1 = (-B*y1-C)/A;
      y2 = height;
      x2 = (-B*y2-C)/A;
      //line( x1, y1, x2, y2 );

      // Ahora pongo la ecuacion de la recta
      // X = (-By -C) / A
      // en la de un circulo
      // x2 + y2 + Ac x + Bc y + Cc = 0
      // es decir:
      // [ (-By -C) / A ]2 + y2 + Ac [ (-By -C) / A ] + Bc y + Cc = 0
      // luego lleva esta ecuacion a la forma
      // aX2 + bX + c = 0 para aplicar la ecuacion cuadratica
      // x = (-b +- sqrt( b2-4ac ) )/2a
      //

      // ya que x = (-By -C) / A entonces x2 = Dy2 + Ey + F
      // con los siguientes valores de D,E y F (los valores de A,B y C son de la recta)
      //
      float D = (B*B) / (A*A);
      float E = (2*B*C) / (A*A);
      float F = (C*C) / (A*A);

      // ya que x = (-By -C) / B entonces x = Gy + H con:
      float G = -B / A;
      float H = -C / A;

      // entonces la ecuacion queda
      // Dy2 + Ey + F + y2 + Ac[G.y+H] + Bc.y + Cc = 0
      // y por lo tanto, la forma a.x2 + b.x + c = 0 se compone asi:
      float a = 1 + D;
      float b = E + c1.A * G + c1.B;
      float c = F + H*c1.A + c1.C;

      //y aqui va la ecuacion cuadratica
      float delta = (b*b) - 4*a*c;

      if ( delta >= 0 ) { //sino entonces el resultado esta en el dominio de los imaginarios
        float ya = ( -b + sqrt( delta ) ) / (2*a);
        float yb = ( -b - sqrt( delta ) ) / (2*a);

        //line( width, ya, 0, ya );
        //line( width, yb, 0, yb );

        //X = (-By -C) / A
        float xa = (-B*ya -C) / A;
        float xb = (-B*yb -C) / A;

        //ellipse( xa, ya, 20, 20 );
        //ellipse( xb, yb, 20, 20 );
        p1 = new Punto( xa, ya );
        p2 = new Punto( xb, yb );
        existe = true;
      }
    }
  }
}
//====================================================================================



