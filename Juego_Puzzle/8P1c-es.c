/**
 * Implementación en C de la práctica, para que tengáis una
 * versión funcional en alto nivel de todas les funciones que tenéis 
 * que implementar en ensamblador.
 * Desde este código se hacen las llamadas a les subrutinas de ensamblador. 
 * ESTE CÓDIGO NO SE PUEDE MODIFICAR Y NO HAY QUE ENTREGARLO.
 * */

#include <stdlib.h>
#include <stdio.h>
#include <termios.h>     //termios, TCSANOW, ECHO, ICANON
#include <unistd.h>      //STDIN_FILENO

extern int developer;   //Variable declarada en ensamblador que indica el nombre del programador

/**
 * Constantes
 */
#define DimMatrix  3     //dimensión de la matriz 3x3
#define SizeMatrix DimMatrix*DimMatrix //=9


/**
 * Definición de variables globales
 */
int spacePos = 0;//Posición del espacio dentro de la matriz tiles (3x3),
                 //spacePos [0 : (SizeMatrix-1)].
                 //Fila = pos / DimMatrix  [0 : (DimMatrix-1)]
                 //Columna = pos % DimMatrix [0 : (DimMatrix-1)]
int newSpacePos; //Nueva posición después de hacer un movimiento.
   
char state = '1';//'0': Salir, hemos pulsado la tecla 'ESC' para salir.
                 //'1': Continuamos jugando.
                 //'2': No se ha podido hacer el movimiento.
                 //'3': Pierdes, no quedan movimientos.
                 //'5': Error, no se ha encontrado el espacio.
   
int moves = 9;   //Movimientos que queden para ordenar les fichas.
   
int  rowScreen;  //Fila para posicionar el cursor en pantalla.
int  colScreen;  //Columna para posicionar el cursor en pantalla.
char charac;     //Carácter leído de teclado y para escribir en pantalla. 

// Matriz 3x3 donde guardamos las fichas iniciales del juego.
char tilesIni[DimMatrix][DimMatrix] = { {'1','2','4'},
                                        {'E','8','A'},
                                        {'C','6',' '} }; 

// Matriz 3x3 donde guardamos las fichas del juego.
char tiles[DimMatrix][DimMatrix]    = { {'1','2','4'},
                                        {'6','8','A'},                                     
                                        {'C','E',' '} };

// matrizs 3x3 donde guardamos las fichas en la posición que queremos conseguir.
char tilesEnd[DimMatrix][DimMatrix] = { {'1','2','4'},
                                        {'E',' ','6'},
                                        {'C','A','8'} }; 
                                        
/**
 * Definición de les funciones de C
 */
void clearscreen_C();
void gotoxyP1_C();
void printchP1_C();
void getchP1_C();

void printMenuP1_C();
void printBoardP1_C();

void updateBoardP1_C();
void spacePosScreenP1_C();
void copyMatrixP1_C();
void moveTileP1_C();
void checkStatusP1_C();
void printMessageP1_C();
void playP1_C();

/**
 * Definición de las subrutinas de ensamblador que se llaman desde C
 */
void updateBoardP1();
void spacePosScreenP1();
void copyMatrixP1();
void moveTileP1();
void checkStatusP1();
void playP1();


/**
 * Borrar la pantalla
 * 
 * Variables globales utilizadas:	
 * Ninguna
 * 
 * Esta función no es llama desde ensamblador
 * y no hay definida una subrutina de ensamblador equivalente.
 */
void clearScreen_C(){
	
    printf("\x1B[2J");
    
}


/**
 * Situar el cursor en una fila indicada por la variable (rowScreen) y 
 * en la columna indicada por la variable (colScreen) de la pantalla.
 * 
 * Variables globales utilizadas:	
 * (rowScreen): Fila de la pantalla donde posicionamos el cursor.
 * (colScreen): Columna de la pantalla donde posicionamos el cursor.
 * 
 * Se ha definido una subrutina en ensamblador equivalente 'gotoxyP1'  
 * para poder llamar a esta función guardando el estado de los registros 
 * del procesador. Esto se hace porque las funciones de C no mantienen 
 * el estado de los registros.
 */
void gotoxyP1_C(){
	
   printf("\x1B[%d;%dH",rowScreen,colScreen);
   
}


/**
 * Mostrar un carácter guardado en la variable (charac) en pantalla,
 * en la posición donde está el cursor.
 * 
 * Variables globales utilizadas:	
 * (charac): Carácter que queremos mostrar.
 * 
 * Se ha definido un subrutina en ensamblador equivalente 'printchP1' 
 * para llamar a esta función guardando el estado de los registros del 
 * procesador. Esto se hace porque las funciones de C no mantienen 
 * el estado de los registros.
 */
void printchP1_C(){

   printf("%c",charac);
   
}


/**
 * Leer una tecla y guardar el carácter asociado en la variable (charac)
 * sin mostrarlo en pantalla. 
 * 
 * Variables globales utilizadas:	
 * (charac): Caràcter que llegim de teclat.
 * 
 * Se ha definido un subrutina en ensamblador equivalente 'getchP1' para
 * llamar a esta función guardando el estado de los registros del procesador.
 * Esto se hace porque las funciones de C no mantienen el estado de los 
 * registros.
 */
void getchP1_C(){

   static struct termios oldt, newt;

   /*tcgetattr obtener los parámetros del terminal
   STDIN_FILENO indica que se escriban los parámetros de la entrada estándard (STDIN) sobre oldt*/
   tcgetattr( STDIN_FILENO, &oldt);
   /*se copian los parámetros*/
   newt = oldt;

    /* ~ICANON para tratar la entrada de teclado carácter a carácter no como línea entera acabada en /n
    ~ECHO para que no se muestre el carácter leído.*/
   newt.c_lflag &= ~(ICANON | ECHO);          

   /*Fijar los nuevos parámetros del terminal para la entrada estándar (STDIN)
   TCSANOW indica a tcsetattr que cambie los parámetros inmediatamente. */
   tcsetattr( STDIN_FILENO, TCSANOW, &newt);

   /*Leer un carácter*/
   charac = (char) getchar();              
    
   /*restaurar los parámetros originales*/
   tcsetattr( STDIN_FILENO, TCSANOW, &oldt);
   
}


/**
 * Mostrar en pantalla el menú del juego y pedir una opción.
 * Sólo acepta una de las opciones correctas del menú ('0'-'9')
 * 
 * Variables globales utilizadas:		
 * (rowScreen): Fila de la pantalla donde posicionamos el cursor.
 * (colScreen): Columna de la pantalla donde posicionamos el cursor.
 * (charac)   : Carácter que leemos de teclado.
 * (developer): ((char *)&developer): Variable definida en el código ensamblador.
 * 
 * Esta función no se llama desde ensamblador
 * y no hay definida una subrutina de ensamblador equivalente.
 */
void printMenuP1_C(){

   clearScreen_C();
   rowScreen = 1;
   colScreen = 1;
   gotoxyP1_C();
   printf("                               \n");
   printf("         Developed by:         \n");
   printf("      ( %s )    \n",(char *)&developer);
   printf(" _____________________________ \n");
   printf("|                             |\n");
   printf("|          MAIN MENU          |\n");
   printf("|_____________________________|\n");
   printf("|                             |\n");
   printf("|      1. updateBoard         |\n");
   printf("|      2. spacePosScreen      |\n");
   printf("|      3. copyMatrix          |\n");
   printf("|      4. moveTiles           |\n");
   printf("|      5. checkStatus         |\n");
   printf("|      6. Play Game           |\n");
   printf("|      7. Play Game C         |\n");
   printf("|      0. Exit                |\n");
   printf("|_____________________________|\n");
   printf("|                             |\n");
   printf("|         OPTION:             |\n");
   printf("|_____________________________|\n"); 

   charac =' ';
   while (charac < '0' || charac > '7') {
      rowScreen = 19;
      colScreen = 19;
      gotoxyP1_C();           //Posicionar el cursor
      getchP1_C();            //Leer una opción
   }
   
}


/**
 * Mostrar el tablero de juego en pantalla. Las líneas del tablero.
 * 
 * Variables globales utilizadas:	
 * (rowScreen): Fila de la pantalla donde posicionamos el cursor.
 * (colScreen): Columna de la pantalla donde posicionamos el cursor.
 *  
 * Esta función se llama des de C y desde ensamblador,
 * y no hay definida una subrutina de ensamblador equivalente.
 */
void printBoardP1_C(){

   rowScreen = 0;
   colScreen = 0;
   gotoxyP1_C();                                      //Filas
                                                      //Tablero
   printf(" _____________________________________ \n"); //01
   printf("|                                     |\n"); //02
   printf("|           8-PUZZLE  v1.0            |\n"); //03
   printf("|                                     |\n"); //04
   printf("|      Order the tiles as shown!      |\n"); //05
   printf("|_____________________________________|\n"); //06
   printf("|                                     |\n"); //07
   printf("|  Remaining Moves[_]    FINAL GOAL   |\n"); //08
   printf("|                                     |\n"); //09
   //             8   12  16                           <- Columnas Tablero               
   printf("|      0   1   2         0   1   2    |\n"); //10
   printf("|    +---+---+---+     +---+---+---+  |\n"); //11
   printf("|  0 |   |   |   |   0 | 1 | 2 | 4 |  |\n"); //12
   printf("|    +---+---+---+     +---+---+---+  |\n"); //13
   printf("|  1 |   |   |   |   1 | E |   | 6 |  |\n"); //14
   printf("|    +---+---+---+     +---+---+---+  |\n"); //15
   printf("|  2 |   |   |   |   2 | C | A | 8 |  |\n"); //16
   printf("|    +---+---+---+     +---+---+---+  |\n"); //17
   printf("|_____________________________________|\n"); //18
   printf("|                                     |\n"); //20
   printf("|   (i)Up (j)Left (k)Down (l)Right    |\n"); //21
   printf("|             (ESC)  Exit             |\n"); //22
   printf("|_____________________________________|\n"); //23
            
}


/**
 * Mostrar los valores de la matriz (tiles), en pantalla, 
 * dentro del tablero en las posiciones correspondientes.
 * Se tiene que recorrer toda la matriz (tiles), de tipo char (1 byte 
 * cada posición), y para cada elemento de la matriz:
 * Posicionar el cursor en el tablero llamando a la función gotoxyP1_C.
 * La posición inicial del cursor es la fila 12 de la pantalla (fila 0 
 * de la matriz), columna 8 de la pantalla (columna 0 de la matriz).
 * Mostrar los caracteres de cada posición de la matriz (tiles) 
 * llamando a la función printchP1_C.
 * Actualizar la columna (colScreen) de 4 en 4 y al cambiar de fila
 * (rowScreen) de 2 en 2.
 * Mostrar los movimientos que quedan por hacer (moves) dentro del tablero 
 * en la fila 8, columna 22 de la pantalla.
 * 
 * Variables globales utilizadas:   
 * (tiles)    : Matriz donde guardamos las fichas del juego.
 * (moves)    : Movimientos que quedan para ordenar las fichas.
 * (rowScreen): Fila de la pantalla donde posicionamos el cursor.
 * (colScreen): Columna de la pantalla donde posicionamos el cursor.
 * (charac)   : Carácter a escribir en pantalla.
 * 
 * Esta función no se llama desde ensamblador.
 * Hay una subrutina de ensamblador equivalente 'updateBoardP1'.
 */
void updateBoardP1_C(){

   int i, j;
   rowScreen = 12;
   for (i=0;i<DimMatrix;i++){
	  colScreen = 8;
      for (j=0;j<DimMatrix;j++){
         gotoxyP1_C();
         charac = tiles[i][j];
         printchP1_C();
         colScreen = colScreen + 4;
      }
      rowScreen = rowScreen + 2;
   }
   rowScreen = 8;
   colScreen = 20;
   gotoxyP1_C(0);
   charac = moves;
   charac = charac + '0';
   printchP1_C();

}

/**
 * Buscar donde está el espacio en blanco dentro de la matriz (tiles), 
 * posicionar el cursor en el sitio donde haya el espacio.
 * (rowScreen = (pos / DimMatrix) * 2 + 12)
 * (colScreen = (pos % DimMatrix) * 4 + 8)
 * y actualizar la posición (newSpacePos) del espacio dentro de la matriz.
 * Recorrer toda la matriz por filas de izquierda a derecha y de arriba a bajo.
 * Si no hay espacio (pos = sizeMatrix).
 * 
 * Variables globales utilizadas:   
 * (tiles)    : Matriz donde guardamos las fichas del juego.
 * (pos)      : Posición del espacio dentro de la matriz.
 * (rowScreen): Fila de la pantalla donde posicionamos el cursor.
 * (colScreen): Columna de la pantalla donde posicionamos el cursor.
 * 
 * Esta función no se llama desde ensamblador.
 * Hay una subrutina de ensamblador equivalente 'spacePosScreenP1.
 */
void spacePosScreenP1_C(){

   int i=0, j=0, pos=0;
   while ((pos<SizeMatrix) && (tiles[i][j]!=' ')){
      pos++;
      i = pos / DimMatrix;
      j = pos % DimMatrix;
   }
   if (pos < SizeMatrix){  //Hay espacio
   	  rowScreen = i*2 + 12;
	  colScreen = j*4 + 8;
      gotoxyP1_C();       //Posicionar cursor en el tablero donde hay el espacio.
   }
   newSpacePos=pos;
   
}


/**
 * Copiar la matriz (tilesIni), sobre la matriz (tiles).
 * Recorrer toda la matriz por filas de izquierda a derecha y de arriba a abajo.
 * 
 * Variables globales utilizadas:   
 * (tilesIni): Matriz con las fichas iniciales del juego
 * (tiles)   : Matriz donde guardamos la fichas del juego.
 *
 * Esta función no se llama desde ensamblador.
 * Hay una subrutina de ensamblador equivalente 'copyStatusP1'.
 */
void copyMatrixP1_C(){
   
   int i, j;

   for (i=0;i<DimMatrix;i++){
      for (j=0;j<DimMatrix;j++){
         tiles[i][j] = tilesIni[i][j];
      }
   }

}


/**
 * Mover la ficha en la dirección indicada por el carácter (charac), 
 * ('i':arriba, 'k':abajo, 'j':izquierda o 'l':derecha) en la posición 
 * donde hay el espacio dentro de la matriz indicada por la variable 
 * (spacePos), controlando los casos donde no se puede hacer el movimiento.
 * fila    (i = spacePos / DimMatrix)
 * columna (j = spacePos % DimMatrix)
 * Si la casilla donde hay el espacio está en los extremos de la matriz
 * no se podrá hacer el movimiento desde ese lado.
 * Si se puede hacer el movimiento:
 * Mover la ficha a la posición donde está el espacio de la matriz (tiles) 
 * y poner el espacio en la posición donde estaba la ficha movida.
 * 
 * No se tiene que mostrar la matriz con los cambios, se hace en UpdateBoardP1_C().
 * 
 * Variables globales utilizadas:   
 * (tiles)      : Matriz donde guardamos la fichas del juego
 * (charac)     : Carácter a escribir en pantalla.
 * (spacePos)   : Posición del espacio en la matriz (tiles).
 * (newSpacePos): Nueva posición del espacio en la matriz (tiles).
 * 
 * Esta función no se llama desde ensamblador.
 * Hay una subrutina de ensamblador equivalente 'moveTileP1'.
 */
void moveTileP1_C(){

   int i = spacePos / DimMatrix;
   int j = spacePos % DimMatrix;
   newSpacePos = spacePos;

   switch(charac){
      case 'i': //arriba
         if (i < (DimMatrix-1)) {
			newSpacePos = spacePos + DimMatrix;
            tiles[i][j]= tiles[i+1][j]; //
            tiles[i+1][j] = ' ';
         }
      break;
      case 'k': //abajo
         if (i > 0) {
			newSpacePos = spacePos - DimMatrix;
            tiles[i][j]= tiles[i-1][j];
            tiles[i-1][j] = ' ';
            
         }
      break;
      case 'j': //izquierd
         if (j < (DimMatrix-1)) {
			newSpacePos = spacePos + 1;
            tiles[i][j]= tiles[i][j+1];
            tiles[i][j+1] = ' ';
         }
      break;
      case 'l': //derecha
         if (j > 0) {
			newSpacePos = spacePos - 1;
            tiles[i][j]= tiles[i][j-1];
            tiles[i][j-1] = ' ';
         }
      break;
      
   }

}

/**
 * Verificar el estado del juego.
 * Si se han terminado los movimientos (moves == 0) poner (status='3').
 * Si no se ha podido hacer el movimiento (spacePos == newSpacePos) poner (status='2').
 * Si no poner (state = '1') para continuar jugando.
 * 
 * Variables globales utilizadas:   
 * (moves)      : Movimientos que quedan para ordenar les fichas.
 * (spacePos)   : Posición del espacio dentro de la matriz tiles.
 * (newSpacePos): Nueva posición del espacio dentro de la matriz tiles.
 * (status)     : Estado del juego.
 *                '1': Continuamos jugando.
 *                '2': No se ha podido hacer el movimiento.
 *                '3': Pierdes, no quedan movimientos.
 * 
 * Esta función no se llama desde ensamblador.
 * Hay una subrutina de ensamblador equivalente 'checkStatusP1'.
 */
void checkStatusP1_C() {
   
   if (moves == 0) {
      state = '3';
   } else if (spacePos == newSpacePos) {
	  state = '2';
   } else {
      state = '1';
   }
   
}


/**
 * Mostrar un mensaje debajo del tablero según el valor de la variable 
 * (state).
 * state: '0': Salir, hemos pulsado la tecla 'ESC' para salir.
 *         '1': Continuamos jugando.
 *         '2': No se ha podido hacer el movimiento.
 *         '3': Pierdes, no quedan movimientos.
 *         '5': Error, no se ha encontrado el espacio.
 * Se espera que se pulse una tecla para continuar.
 * 
 * Variables globales utilizadas:   
 * (status)   : Estado del juego.
 * (rowScreen): Fila de la pantalla donde posicionamos el cursor.
 * (colScreen): Columna de la pantalla donde posicionamos el cursor.
 * 
 * Se ha definido un subrutina en ensamblador equivalente 'printMessageP1' 
 * para llamar a esta función guardando el estado de los registros del 
 * procesador. Esto se hace porque las funciones de C no mantienen 
 * el estado de los registros.
 */
void printMessageP1_C() {

   rowScreen = 24;
   colScreen = 2;
   gotoxyP1_C();
   
   switch(state){
      case '0':
         printf("<<<<<<<< EXIT: (ESC) Pressed >>>>>>>>");
      break;
      case '1':
         printf("============  NEXT MOVE  ============");
      break;
      case '2':
         printf("***********  CAN'T  MOVE  ***********");
      break;
      case '3':
         printf("------- SORRY, NO MORE MOVES! -------");
      break;
      case '5':
         printf("xxxxxxxxx ERROR -> NO SPACE xxxxxxxxx");
      break;
   }
   
}


/**
 * Juego del 8-PUZZLE.
 * Función principal del juego.
 * Permite jugar al juego del 8-PUZZLE llamando todas las funcionalidades.
 * 
 * Pseudo-código:
 * Mostrar el tablero de juego llamado a la función printBoardP1_C.
 * Inicializar el estado del juego, (state='1').
 * Inicializar los movimientos que se pueden hacer  (moves = 9).
 * Inicializar la matriz (tiles) con los valores de la matriz (tilesIni)
 * llamando a la función copyMatrixP1_C.
 * Mientras (state=='1') hacer:
 *   Actualizar el tablero de juego llamando a la función updateBoardP1_C. 
 *   Buscar donde está el espacio en blanco dentro la matriz (tiles) y posicionar el
 *   cursor en el lugar donde hay el espacio llamando a la función spacePosScreenP1_C.
 *   Si se ha encontrado el espacio (newSpacePos < SizeMatrix):
 *     Hacer que la posición del espacio sea la nueva posición obtenida.
 *     (spacePos = newSpacePos)
 *     Leer una tecla llamando a la función getchP1_C.
 *     Según la tecla leída llamaremos a las funciones que correspondan:
 *      - ['i','j','k' o 'l'] desplazar la ficha segú la dirección
 *        escogida llamando a la función moveTileP1_C).
 *        Si se ha realizado un movimiento (newSpacePos != spacePos) decrementar
 *        los movimientos (moves--).
 *        Verificar el estado del juego llamando la función checkStatusP1_C.
 *      - '<ESC>'  (código ASCII 27) poner (state = '0') para salir.   
 *    Si no se ha encontrado el espacio (newSpacePos = SizeMatrix):
 *      poner (state='5') para indicar que no hay espacio en la matriz. 
 *    Mostrar un mensaje debajo del tablero según el valor de la 
 *    variable (state) llamando a la función printMessageP1_C.
 *    Si no se ha podido hacer movimiento (state == '2') poner 
 *    (state = '1') para continuar jugando. 
 * Fin mientras.
 * 
 * Antes de salir, actualizar el tablero de juego llamando a la 
 * función updateBoardP1_C y posicionar el cursor en el lugar donde hay 
 * el espacio llamando a la función spacePosScreenP1_C.
 * Esperar que se pulse una tecla llamando a la función getchP1_C para acabar.
 * Salir: Se acaba el juego.
 * 
 * Variables globales utilizadas:   
 * (moves)      : Movimientos que quedan para ordenar les fichas.
 * (spacePos)   : Posición del espacio dentro de la matriz tiles.
 * (newSpacePos): Nueva posición del espacio dentro de la matriz tiles.
 * (charac)     : Carácter a escribir en pantalla.
 * (status)     : Estado del juego.
 *                '1': Continuamos jugando.
 *                '2': No se ha podido hacer el movimiento.
 *                '3': Pierdes, no quedan movimientos.
 *                '5': Error, no se ha encontrado el espacio.
 * 
 * Esta función no se llama desde ensamblador.
 * Hay una subrutina de ensamblador equivalente 'playP1', para  
 * llamar les subrutinas del juego definidas en ensamblador (copyMatrixP1,
 * updateBoardP1, spacePosScreenP1, moveTileP1, checkStatusP1).
 */
void playP1_C(){

   printBoardP1_C();
   state = '1';
   moves = 9;
   copyMatrixP1_C();
      
   while (state == '1') {     //Bucle principal.
	  updateBoardP1_C();
      spacePosScreenP1_C(); 
      if (newSpacePos < SizeMatrix) {
         spacePos = newSpacePos;
         
         getchP1_C();                   

         if (charac >= 'i' && charac <= 'l') {
            moveTileP1_C();
            if (newSpacePos != spacePos) moves--;
            checkStatusP1_C();             
         } else if (charac == 27) {
            state='0';
         }
      } else {
         state = '5';
      }
      printMessageP1_C();
      if (state == '2') state = '1'; 
   }
   updateBoardP1_C();
   spacePosScreenP1_C();
   getchP1_C();     
   
}


/**
 * Programa Principal
 * 
 * ATENCIÓN: Podéis probar la funcionalidad de las subrutinas que se tienen
 * que desarrollar eliminando los comentarios de la llamada a la función 
 * equivalente implementada en C que hay debajo de cada opción.
 * Para al juego completo hay una opción para la versión en ensamblador y 
 * una opción para el juego en C.
 */
int main(void){   
   charac = ' ';
   while (charac != '0') {
     printMenuP1_C();    //Mostrar menú.
     clearScreen_C();
     switch(charac){
        case '1'://Actualizar el contenido del tablero.   
          printBoardP1_C();      
          //=======================================================
            updateBoardP1();
            //updateBoardP1_C();
          //=======================================================
          rowScreen = 24;
          colScreen = 12;
          gotoxyP1_C();
          printf(" Press any key ...");
          getchP1_C();
        break;
        case '2': //Busca donde está el espacio en blanco dentro de la matriz 
                  //(tiles), posicionar el cursor en el lugar donde hay el espacio.
          printBoardP1_C();
          updateBoardP1_C();
          rowScreen = 24;
          colScreen = 12;
          gotoxyP1_C();
          printf(" Press any key ...");
          //=======================================================        
            spacePosScreenP1();
            //spacePosScreenP1_C();
          //=======================================================
          if (newSpacePos == SizeMatrix) {
             rowScreen = 24;
             colScreen = 10;
             gotoxyP1_C();
             printf(" ERROR -> NO SPACE: Press any key ...");
          } 
          getchP1_C();
        break;
        case '3': //Copiar la matriz tilesIni a tiles.
          printBoardP1_C();
          rowScreen = 24;
          colScreen = 10;
          gotoxyP1_C();
          //=======================================================
            copyMatrixP1();
            //copyMatrixP1_C(); 
          //=======================================================
          rowScreen = 24;
          colScreen = 12;
          gotoxyP1_C();
          printf(" Press any key ...");
          updateBoardP1_C();
          spacePosScreenP1_C();
          getchP1_C();
        break;
        case '4': //Mover la ficha en la dirección indicada.
          printBoardP1_C();
          rowScreen = 24;
          colScreen = 12;
          gotoxyP1_C();
          printf(" Press i,j,k,l: ");
          updateBoardP1_C();
          spacePosScreenP1_C();
          spacePos = newSpacePos;
          getchP1_C();   
          if (charac>='i' && charac<='l') {
          //=======================================================
             moveTileP1();
             //moveTileP1_C();
          //=======================================================
             updateBoardP1_C();
             spacePosScreenP1_C();
             checkStatusP1_C();
             printMessageP1_C();
             rowScreen = 23;
             colScreen = 12;
             gotoxyP1_C();
             printf(" Press any key ...");
          } else {			 
             rowScreen = 24;
             colScreen = 12;
             gotoxyP1_C();
             printf(" Incorrect key !!!");
          }
          getchP1_C();
        break;
        case '5': // Verificar el estado del juego.
          printBoardP1_C();    
          moves = 5;
          ///moves = 0; //state='3' -> NO MORE MOVES
          updateBoardP1_C();
          spacePosScreenP1_C();
          spacePos = newSpacePos; ///state='2' -> CAN'T MOVE
          ///spacePos = 0; //state='1' -> NEXT MOVE
          //=======================================================
            checkStatusP1();
            //checkStatusP1_C();
          //=======================================================
          printMessageP1_C();
          rowScreen = 23;
          colScreen = 12;
          gotoxyP1_C();
          printf(" Press any key ...");
          getchP1_C();  
        break;
        case '6': // Verificar el estado del juego. 
          //=======================================================
          playP1();
          //=======================================================
        break;
        case '7': //Juego completo en C.    
          //=======================================================
          playP1_C();
          //=======================================================
        break;
     }
  }
  printf("\n\n");
  
  return 0;
  
}
