class Agente {

  String especie;
  int especieId;
  float radioPercepcion;
  float radioContacto = 6;

  PVector location;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxforce; // Velocidad de atracción máxima
  float maxspeed; // Velocidad máxima
  boolean vivo;
  color relleno;
  float dir;
  float desvio;
  float variacionAngular;
  float easing; // Suavizado para movimientos

  Agente( float _x, float _y, String _especie ) {
    vivo = true;
    especie = _especie;
    acceleration = new PVector( 0, 0 );
    location = new PVector( _x, _y );
    maxspeed = 3;
    maxforce = 0.1;
    dir = random( TWO_PI );
    variacionAngular = radians( 10 );
    easing = random(1)/10;

    // Caracteristicas de la especie
    if ( especie.equals( "presa" ) ) {
      especieId = 1;
      radioPercepcion = 130;
      relleno = color( 0, 200 );
      velocity = new PVector( random(1, 2), random(1, 2) );
      r = 10;
    }

    if ( especie.equals( "depredador" ) ) {
      especieId = 2;
      radioPercepcion = 50;
      relleno = color( 255, 60, 60, 200 );
      velocity = new PVector( random(1, 2.5), random(1, 2.5) );
      r = 17;
    }

    if ( especie.equals( "sanador" ) ) {
      especieId = 3;
      radioPercepcion = 130;
      relleno = color( 255, 255, 0, 200 );
      velocity = new PVector( random(1.5, 2.5), random(1.5, 2.5) );
      r = 13;
    }
  }


  //-------------------------------
  // COMPORTAMIENTOS DEL AGENTE
  //-------------------------------

  void mover() {
    if ( vivo ) {
      desvio = random( -variacionAngular, variacionAngular );
      dir += desvio;

      float dx = velocity.x * cos( dir );
      float dy = velocity.y * sin( dir );
      location.x += dx;
      location.y += dy;

      checkEdges();
    }
  }

  void checkEdges() {

    // Bounce
    /*
    if( ( location.x > width-r || location.x < r ) ||  (location.y > height-r || location.y < r) ){
     velocity.mult( -1 );
     dir = dir + 90;
     }
     */

    // Espacio toroideal
    location.x = ( location.x>width ? location.x-width : location.x );
    location.x = ( location.x<0 ? location.x+width : location.x );
    location.y = ( location.y>height ? location.y-height : location.y );
    location.y = ( location.y<0 ? location.y+height : location.y );
  }

  //-------------------------

  void comer( float _xComida, float _yComida ) {

    // Presa
    if ( especie.equals( "presa" ) ) {
      PVector destino = new PVector( _xComida, _yComida );
      float dx = destino.x - location.x;
      if ( abs(dx) > 1 ) {
        location.x += dx * easing;
      }
      float dy = destino.y - location.y;
      if ( abs(dy)  > 1 ) {
        location.y += dy * easing;
      }
    }

    // Sanadores
    if ( especie.equals( "sanador" ) ) {
    }

    // Predadores
    if ( especie.equals( "depredador" ) ) {
    }
  }

  //-------------------------

  void perseguir( float ox, float oy ) {
    float nuevaDir = atan2( oy-location.y, ox-location.x );
    float diferencia = menorDistAngulos( dir, nuevaDir );
    float f = 0.1;
    dir += diferencia * f;
  }

  //-------------------------

  void huirDe( float ox, float oy ) {
    float nuevaDir = atan2( oy-location.y, ox-location.x ) + PI;
    float diferencia = menorDistAngulos( dir, nuevaDir );
    float f = 0.1;
    dir += diferencia * f;
  }


  //-------------------------------
  // COMPORTAMIENTOS ENTRE AGENTES
  //-------------------------------

  void vincularAlVer( Agente otro ) {
    if ( otro.vivo ) {
      float distancia = dist( location.x, location.y, otro.location.x, otro.location.y );
      if ( distancia < radioPercepcion ) {

        // Si Depredador
        if ( especie.equals( "depredador" ) ) {
          // Ve Depredador
          if ( otro.especie.equals( "depredador" ) ) {
            huirDe( otro.location.x, otro.location.y );
          }
          // Ve Presa
          if ( otro.especie.equals( "presa" ) ) {
            perseguir( otro.location.x, otro.location.y );
          }
          // Ve Sanador
          if ( otro.especie.equals( "sanador" ) ) {
            huirDe( otro.location.x, otro.location.y );
          }
        }

        // Si Presa
        if ( especie.equals( "presa" ) ) {
          // Ve Depredador
          if ( otro.especie.equals( "depredador" ) ) {
            huirDe( otro.location.x, otro.location.y );
          }
          // Ve Presa
          if ( otro.especie.equals( "presa" ) ) {
            //huirDe( otro.location.x, otro.location.y );
          }
          // Ve Sanador
          if ( otro.especie.equals( "sanador" ) ) {
            //huirDe( otro.location.x, otro.location.y );
          }
        }

        // Si Sanador
        if ( especie.equals( "sanador" ) ) {
          // Ve Depredador
          if ( otro.especie.equals( "depredador" ) ) {
            perseguir( otro.location.x, otro.location.y );
          }
          // Ve Presa
          if ( otro.especie.equals( "presa" ) ) {
            //perseguir( otro.location.x, otro.location.y );
          }
          // Ve Sanador
          if ( otro.especie.equals( "sanador" ) ) {
            //huirDe( otro.location.x, otro.location.y );
          }
        }
      }
    }
  }

  //-------------------------

  void vincularAlContacto( Agente otro ) {
    if ( otro.vivo ) {
      float distancia = dist( location.x, location.y, otro.location.x, otro.location.y );
      if ( distancia < radioContacto ) {

        // Si Depredador
        if ( especie.equals( "depredador" ) ) {
          // Toca Depredador
          if ( otro.especie.equals( "depredador" ) ) {
          }
          // Toca Presa
          if ( otro.especie.equals( "presa" ) ) {
            r++;
          }
          // Toca Sanador
          if ( otro.especie.equals( "sanador" ) ) {
            r--;
            if ( r <= 3 ) {
              playSoundDepredador( (int) random(1, 3) );
              vivo = false;
              cantidad --;
            }
          }
        }

        // Si Presa
        if ( especie.equals( "presa" ) ) {
          // Toca Depredador
          if ( otro.especie.equals( "depredador" ) ) {
            playSoundPresa( (int) random(1, 3) );
            vivo = false;
            cantidad --;
          }
          // Toca Presa
          if ( otro.especie.equals( "presa" ) ) {
          }
          // Toca Sanador
          if ( otro.especie.equals( "sanador" ) ) {
          }
        }

        // Si Sanador
        if ( especie.equals( "sanador" ) ) {
          // Toca Depredador
          if ( otro.especie.equals( "depredador" ) ) {
            r--;
            if ( r <= 3 ) {
              playSoundDepredador( (int) random(1, 3) );
              vivo = false;
              cantidad --;
            }
          }
          // Toca Presa
          if ( otro.especie.equals( "presa" ) ) {
          }
          // Toca Sanador
          if ( otro.especie.equals( "sanador" ) ) {
            //r += 0.6;
          }
        }
        r = constrain( r, -1, 40);
      }
    }
  }

  //-------------------------------
  // REPRESENTACION
  //-------------------------------

  void dibujar() {
    if ( vivo ) {

      canvas.pushMatrix();
      canvas.pushStyle();
      canvas.noStroke();
      canvas.fill( relleno );
      canvas.translate( location.x, location.y );
      canvas.rotate( dir );
      canvas.imageMode( CENTER );
      canvas.tint( 255, 255 );

      canvas.strokeWeight( 1 );
      canvas.stroke( relleno, 0, 0, 30 );

      // Presa
      if ( especie.equals( "presa" ) ) {
        //canvas.ellipse( 0, 0, r*2, r );
        canvas.image( imgPresa, 0, 0, r, r );
      }

      // Sanadores
      if ( especie.equals( "sanador" ) ) {
        //canvas.ellipse( -r/2, 0, r*1.2, r*1.2 );
        //canvas.ellipse( 0, 0, r*0.9, r*0.9 );
        canvas.image( imgSanador, 0, 0, r, r );
      }

      // Predadores
      if ( especie.equals( "depredador" ) ) {
        //canvas.ellipse( -r/2, 0, r, r );
        //canvas.triangle( r, 0, -r, r/2, -r, -r/2 );
        canvas.image( imgDepredador, 0, 0, r, r );
      }

      // Debug
      if ( debug ) {
        canvas.strokeWeight( 1 );
        canvas.stroke( 255, 0, 0 );
        canvas.noFill();
        canvas.ellipse( 0, 0, radioPercepcion, radioPercepcion );
      }

      canvas.popStyle();
      canvas.popMatrix();
    }
  }

  void matar( int _duracion, float _x, float _y  ) {
    if ( _duracion != 0 ) {
      canvas.pushMatrix();
      canvas.pushStyle();
      canvas.noStroke();
      canvas.fill( relleno, _duracion );

      canvas.translate(  _x, _y );
      canvas.rotate( dir );

      canvas.ellipse( 0, 0, _duracion, _duracion );

      canvas.popStyle();
      canvas.popMatrix();

      _duracion --;
    }
    println( "muerto" );
  }

  void playSoundPresa( int sonido ) {
    if ( sonido == 1 ) {
      depredador_1.play();
    }
    if ( sonido == 2 ) {
      depredador_2.play();
    }
    if ( sonido == 3 ) {
      depredador_3.play();
    }
  }
  
  void  playSoundDepredador( int sonido ) {
    if ( sonido == 1 ) {
      come_1.play();
    }
    if ( sonido == 2 ) {
      come_2.play();
    }
    if ( sonido == 3 ) {
      come_3.play();
    }
  }
}

