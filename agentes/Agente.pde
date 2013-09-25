float radioPercepcion = 50;
float radioContacto = 10;

class Agente {

  float x, y;
  float dir, vel;
  float t;
  color relleno;
  color contorno;

  float desvio;
  float variacionAngular;

  String especie;
  boolean vivo;

  //-------------------------

  Agente() {
    vivo = true;
    x = random( width );
    y = random( height );
    dir = random( TWO_PI );

    variacionAngular = radians( 20 );

    // Asigno especie
    int _especie = (int) random( 100 );
    if ( _especie <= 1 ) {
      especie = "depredador";
    }
    if ( _especie > 1 && _especie < 99 ) {
      especie = "presa";
    }
    if ( _especie >= 99 ) {
      especie = "sanador";
    }

    // Propiedades de la especie
    if ( especie.equals( "presa" ) ) {
      vel = random( 2, 3 );
      t = 4;
      relleno = color( 0, 255, 0 );
    }
    if ( especie.equals( "depredador" ) ) {
      vel = random( 3, 7 );
      t = 7;
      relleno = color( 255, 0, 0 );
    }
    if ( especie.equals( "sanador" ) ) {
      vel = random( 1, 2 );
      t = 10;
      relleno = color( 255, 255, 0 );
    }
  }

  //-------------------------

  void vincularAlVer( Agente otro ) {

    if ( otro.vivo ) {

      float distancia = dist( x, y, otro.x, otro.y );

      if ( distancia < radioPercepcion ) {

        if ( especie.equals( "depredador" ) ) { //yo soy depredador
          if ( otro.especie.equals( "depredador" ) ) { //d vs d
          }
          else { //d vs p
            perseguir( otro.x, otro.y );
          }
        }
        else { //yo soy presa
          if ( otro.especie.equals( "depredador" ) ) { //p vs d
            huirDe( otro.x, otro.y );
          }
          else { //p vs p
          }
        }
      }
    }
  }
  //-------------------------

  void vincularAlContacto( Agente otro ) {

    if ( otro.vivo ) {

      float distancia = dist( x, y, otro.x, otro.y );

      if ( distancia < radioContacto ) {

        // Si Depredador
        if ( especie.equals( "depredador" ) ) {
          // Toca Depredador
          if ( otro.especie.equals( "depredador" ) ) {
            huirDe( otro.x, otro.y );
            vel += 0.1;
          }
          // Toca Presa
          if ( otro.especie.equals( "presa" ) ) {
            perseguir( otro.x, otro.y );
            t += 0.6;
            vel -= 0.6;
          }
          // Toca Sanador
          if ( otro.especie.equals( "sanador" ) ) {
            huirDe( otro.x, otro.y );
            t -= 0.6;
          }
        }

        // Si Presa
        if ( especie.equals( "presa" ) ) {
          // Toca Depredador
          if ( otro.especie.equals( "depredador" ) ) {
            huirDe(  otro.x, otro.y );
            vivo = false;
          }
          // Toca Presa
          if ( otro.especie.equals( "presa" ) ) {
            perseguir( otro.x, otro.y );
          }
          // Toca Sanador
          if ( otro.especie.equals( "sanador" ) ) {
            huirDe( otro.x, otro.y );
          }
        }

        // Si Sanador
        if ( especie.equals( "sanador" ) ) {
          // Toca Depredador
          if ( otro.especie.equals( "depredador" ) ) {
            perseguir( otro.x, otro.y );
            t -= 0.6;
          }
          // Toca Presa
          if ( otro.especie.equals( "presa" ) ) {
            perseguir( otro.x, otro.y );
            vel += 0.1;
          }
          // Toca Sanador
          if ( otro.especie.equals( "sanador" ) ) {
            huirDe( otro.x, otro.y );
            t += 0.6;
          }
        }

        // Para todos
        if ( t <=0 ) {
          vivo = false;
        }
        t = constrain( t, -1, 20);
        vel = constrain( vel, 0.3, 4);
      }
    }
  }
  //-------------------------

  void dibujar() {
    if ( vivo ) {
      canvas.pushMatrix();
      canvas.pushStyle();
      canvas.noStroke( );
      canvas.fill( relleno );

      canvas.translate( x, y );
      canvas.rotate( dir );
      canvas.ellipse( t, 0, -t, t/2 );

      canvas.popStyle();
      canvas.popMatrix();
    }
  }
  //-------------------------

  void mover() {
    if ( vivo ) {
      desvio = random( -variacionAngular, variacionAngular );
      dir += desvio;

      float dx = vel * cos( dir );
      float dy = vel * sin( dir );

      x += dx;
      y += dy;

      x = ( x>width ? x-width : x );
      x = ( x<0 ? x+width : x );
      y = ( y>height-altoCapsulas ? y-height : y );
      y = ( y<0 ? y+height-altoCapsulas : y );
    }
  }
  //-------------------------

  void perseguir( float ox, float oy ) {

    float nuevaDir = atan2( oy-y, ox-x );
    float diferencia = menorDistAngulos( dir, nuevaDir );
    float f = 0.1;

    dir += diferencia * f;
  }
  //-------------------------

  void huirDe( float ox, float oy ) {
    float nuevaDir = atan2( oy-y, ox-x ) + PI;
    float diferencia = menorDistAngulos( dir, nuevaDir );
    float f = 0.1;

    dir += diferencia * f;
  }
  //-------------------------
}

