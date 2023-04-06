section .data               
;Cambiar Nombre y Apellido por vuestros datos.
developer db "_Nombre_ _Apellido1_",0

;Constantes que también están definidas en C.
DimMatrix    equ 3
SizeMatrix   equ DimMatrix*DimMatrix ;=9 

section .text            

;Variables definidas en Ensamblador.
global developer                        

;Subrutinas de ensamblador que se llaman desde C.
global updateBoardP1, spacePosScreenP1, copyMatrixP1,
global moveTileP1, checkStatusP1, playP1

;Variables definidas en C.
extern rowScreen, colScreen, charac, spacePos, newSpacePos
extern state, moves, tilesIni, tiles, tilesEnd

;Funciones de C que se llaman desde ensamblador.
extern clearScreen_C, printBoardP1_C, gotoxyP1_C, printchP1_C, getchP1_C
extern printMessageP1_C


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ATENCIÓN: Recordad que en ensamblador las variables y los parámetros 
;;   de tipo 'char' se tienen que asignar a registros de tipo
;;   BYTE (1 byte): al, ah, bl, bh, cl, ch, dl, dh, sil, dil, ..., r15b
;;   las de tipo 'short' se tiene que assignar a registros de tipo 
;;   WORD (2 bytes): ax, bx, cx, dx, si, di, ...., r15w
;;   las de tipo 'int' se tiene que assignar a registros de tipo  
;;   DWORD (4 bytes): eax, ebx, ecx, edx, esi, edi, ...., r15d
;;   las de tipo 'long' se tiene que assignar a registros de tipo 
;;   QWORD (8 bytes): rax, rbx, rcx, rdx, rsi, rdi, ...., r15
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Les subrutinas en ensamblador que hay que implementar son:
;;   updateBoardP1, spacePosScreenP1, copyMatrixP1 
;;   moveTileP1, checkStatusP1
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Esta subrutina se da hecha. NO LA PODÉIS MODIFICAR.
; Situar el cursor en una fila indicada por la variable (rowScreen) y en 
; una columna indicada por la variable (colScreen) de pantalla 
; llamando a la función gotoxyP1_C.
; 
; Variables globales utilizadas:	
; rowScreen: Fila de la pantalla donde posicionamos el cursor.
; colScreen: Columna de la pantalla donde posicionamos el cursor.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gotoxyP1:
   push rbp
   mov  rbp, rsp
   ;guardamos el estado de los registros del procesador porque
   ;las funciones de C no mantienen el estado de los registros.
   push rax
   push rbx
   push rcx
   push rdx
   push rsi
   push rdi
   push r8
   push r9
   push r10
   push r11
   push r12
   push r13
   push r14
   push r15

   call gotoxyP1_C
 
   pop r15
   pop r14
   pop r13
   pop r12
   pop r11
   pop r10
   pop r9
   pop r8
   pop rdi
   pop rsi
   pop rdx
   pop rcx
   pop rbx
   pop rax

   mov rsp, rbp
   pop rbp
   ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Esta subrutina se da hecha. NO LA PODÉIS MODIFICAR.
; Mostrar un carácter guradado en la varaile (charac) en pantalla, en
; la posición donde está el cursor llamando a la función printchP1_C.
; 
; Variables globales utilizadas:	
; charac   : Carácter que queremos mostrar.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printchP1:
   push rbp
   mov  rbp, rsp
   ;guardamos el estado de los registros del procesador porque
   ;las funciones de C no mantienen el estado de los registros.
   push rax
   push rbx
   push rcx
   push rdx
   push rsi
   push rdi
   push r8
   push r9
   push r10
   push r11
   push r12
   push r13
   push r14
   push r15

   call printchP1_C
 
   pop r15
   pop r14
   pop r13
   pop r12
   pop r11
   pop r10
   pop r9
   pop r8
   pop rdi
   pop rsi
   pop rdx
   pop rcx
   pop rbx
   pop rax

   mov rsp, rbp
   pop rbp
   ret
   

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Esta subrutina se da hecha. NO LA PODÉIS MODIFICAR.
; Leer una tecla y guardar el carácter asociado en la varaible (charac) 
; sin mostrarlo en pantalla, llamando a la función getchP1_C
; 
; Variables globales utilizadas:	
; charac   : Carácter que queremos mostrar.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getchP1:
   push rbp
   mov  rbp, rsp
   ;guardamos el estado de los registros del procesador porque
   ;las funciones de C no mantienen el estado de los registros.
   push rax
   push rbx
   push rcx
   push rdx
   push rsi
   push rdi
   push r8
   push r9
   push r10
   push r11
   push r12
   push r13
   push r14
   push r15
   push rbp

   call getchP1_C
 
   pop rbp
   pop r15
   pop r14
   pop r13
   pop r12
   pop r11
   pop r10
   pop r9
   pop r8
   pop rdi
   pop rsi
   pop rdx
   pop rcx
   pop rbx
   pop rax
   
   mov rsp, rbp
   pop rbp
   ret 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Mostrar los valores de la matriz (tiles), en pantalla, 
; dentro del tablero en las posiciones correspondientes.
; Se tiene que recorrer toda la matriz (tiles), de tipo char (1 byte 
; cada posición), y para cada elemento de la matriz:
; Posicionar el cursor en el tablero llamando a la subrutina gotoxyP1.
; La posición inicial del cursor es la fila 12 de la pantalla (fila 0 
; de la matriz), columna 8 de la pantalla (columna 0 de la matriz).
; Mostrar los caracteres de cada posición de la matriz (tiles) 
; llamando a la subrutina printchP1.
; Actualizar la columna (colScreen) de 4 en 4 y al cambiar de fila
; (rowScreen) de 2 en 2.
; Para recorrer la matriz en ensamblador el índice va de 0 (posició [0][0])
; a 8 (posició [2][2]) con incrementos de 1 porque los datos son de 
; tipo char(BYTE) 1 byte.
; Mostrar los movimientos que quedan por hacer (moves) dentro del tablero 
; en la fila 8, columna 22 de la pantalla.
; 
; Variables globales utilizadas:   
; (tiles)    : Matriz donde guardamos las fichas del juego.
; (moves)    : Movimientos que quedan para ordenar las fichas.
; (rowScreen): Fila de la pantalla donde posicionamos el cursor.
; (colScreen): Columna de la pantalla donde posicionamos el cursor.
; (charac)   : Carácter a escribir en pantalla.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
updateBoardP1:
   push rbp
   mov  rbp, rsp
   
   push rax
   push rcx
   push rdi
   push r10
   push r11
   
   mov DWORD[rowScreen], 12            ;rowScreen=12;
   mov r10d, 0                         ;i=0
   mov rcx, 0                          ;indexMat
   updateBoardP1_Bucle_Row:
   cmp r10d, DimMatrix                 ;i<DimMatrix
   jge updateBoardP1_Moves
    
      mov DWORD[colScreen], 8          ;colScreen=8;
      mov r11d, 0                      ;j=0;
      updateBoardP1_Bucle_Col:
      cmp r11d, DimMatrix              ;j<DimMatrix
      jge updateBoardP1_Col_End
         call gotoxyP1                 ;gotoxyP1_C();
         mov  dil, BYTE[tiles+rcx]     ;charac = tiles[i][j];
         mov  BYTE[charac], dil
         call printchP1                ;printchP1_C(); 
         inc  rcx
         inc  r11d                     ;j++;
         add  DWORD[colScreen], 4      ;colScreen = colScreen + 4;
      jmp updateBoardP1_Bucle_Col

      updateBoardP1_Col_End:
      inc  r10d                        ;i++;
      add  DWORD[rowScreen], 2         ;rowScreen = rowScreen + 2;
   jmp updateBoardP1_Bucle_Row
   
   updateBoardP1_Moves:
   mov DWORD[rowScreen], 8               
   mov DWORD[colScreen], 20               
   call gotoxyP1                       ;gotoxyP1_C();
   mov  eax, DWORD[moves]
   mov  BYTE[charac], al               ;charac = moves
   add  BYTE[charac], '0'              ;charac = charac + '0';
   call printchP1                      ;printchP1_C();
      
   updateBoardP1_End:
   pop r11
   pop r10
   pop rdi 
   pop rcx
   pop rax
   
   mov rsp, rbp
   pop rbp
   ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Buscar donde está el espacio en blanco dentro de la matriz (tiles), 
; posicionar el cursor en el sitio donde haya el espacio.
; (rowScreen = (pos / DimMatrix) * 2 + 12)
; (colScreen = (pos % DimMatrix) * 4 + 8)
; y actualizar la posición (newSpacePos) del espacio dentro de la matriz.
; Recorrer toda la matriz por filas de izquierda a derecha y de arriba a bajo.
; Si no hay espacio (pos = sizeMatrix).
; Para recorrer la matriz en ensamblador el índice va de 0 (posició [0][0])
; a 8 (posició [2][2]) con incrementos de 1 porque los datos son de 
; tipo char(BYTE) 1 byte.
;
; Variables globales utilizadas:   
; (tiles)    : Matriz donde guardamos las fichas del juego.
; (pos)      : Posición del espacio dentro de la matriz.
; (rowScreen): Fila de la pantalla donde posicionamos el cursor.
; (colScreen): Columna de la pantalla donde posicionamos el cursor.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
spacePosScreenP1:
   push rbp
   mov  rbp, rsp
   
   push rbx
   push rcx
   push rdx
   push rsi
   push rdi
   push r8
   
   mov esi, 0                 ;i=0
   mov edi, 0                 ;j=0, 
   mov r8d, 0                 ;pos=0;
   pospaceScreenP1_While:     ;while ((pos<SizeMatrix) && (tiles[i][j]!=' ')){
   cmp r8d, SizeMatrix
   jge pospaceScreenP1_If   
   cmp BYTE[tiles+r8d], ' '
   je  pospaceScreenP1_If 
      inc r8d                 ;pos++;
      mov eax, r8d
      mov edx, 0
      mov ebx, DimMatrix      ;i = pos / DimMatrix;
      div ebx                 ;j = pos % DimMatrix;
      mov edi, eax
      mov esi, edx
      jmp pospaceScreenP1_While
   
   pospaceScreenP1_If:  
   cmp r8d, SizeMatrix        ;if (pos < SizeMatrix){ 
   jge pospaceScreenP1_End
      shl edi, 1              ;rowScreen = i*2;
      add edi, 12             ;rowScreen = i*2 + 12;
      mov DWORD[rowScreen],edi
      shl esi, 2              ;colScreen = j*4;
      add esi, 8              ;colScreen = j*4 + 8;
      mov DWORD[colScreen],esi
      call gotoxyP1           ;gotoxyP1_C();
   
   pospaceScreenP1_End:
   mov DWORD[newSpacePos], r8d;newSpacePos=pos;
                         
   pop r8
   pop rdi
   pop rsi
   pop rdx   
   pop rcx
   pop rbx
   
   mov rsp, rbp
   pop rbp
   ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Copiar la matriz (tilesIni), sobre la matriz (tiles).
; Recorrer toda la matriz por filas de izquierda a derecha y de arriba a abajo.
; Para recorrer la matriz en ensamblador el índice va de 0 (posició [0][0])
; a 8 (posició [2][2]) con incrementos de 1 porque los datos son de 
; tipo char(BYTE) 1 byte.
;
; Variables globales utilizadas:   
; (tilesIni): Matriz con las fichas iniciales del juego
; (tiles)   : Matriz donde guardamos la fichas del juego.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
copyMatrixP1:
   push rbp
   mov  rbp, rsp
   
   push rax
   push rbx                        ;i
   push rcx                        ;j
   push rdx                        ;índex matriu
   
   mov rdx, 0   
   mov ebx, 0                      ;i=0
   copyMatrixP1_Bucle_Row:
   cmp ebx, DimMatrix              ;i<DimMatrix
   jge copyMatrixP1_Row_End
   
     mov ecx, 0                    ;j=0
     copyMatrixP1_Bucle_Col:
     cmp ecx, DimMatrix            ;j<DimMatrix
     jge copyMatrixP1_Col_End
       mov  al, BYTE[tilesIni+rdx] ;al = tilesIni[i][j]
       mov  BYTE[tiles+rdx], al    ;t[i][j] = al
       inc  rdx
       inc  ecx                    ;i++
     jmp copyMatrixP1_Bucle_Col

     copyMatrixP1_Col_End:
     inc  ebx                      ;j++
   jmp copyMatrixP1_Bucle_Row

   copyMatrixP1_Row_End:
   
   pop rdx   
   pop rcx
   pop rbx
   pop rax
   
   mov rsp, rbp
   pop rbp
   ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Mover la ficha en la dirección indicada por el carácter (charac), 
; ('i':arriba, 'k':abajo, 'j':izquierda o 'l':derecha) en la posición 
; donde hay el espacio dentro de la matriz indicada por la variable 
; (spacePos), controlando los casos donde no se puede hacer el movimiento.
; fila    (i = spacePos / DimMatrix)
; columna (j = spacePos % DimMatrix)
; Si la casilla donde hay el espacio está en los extremos de la matriz
; no se podrá hacer el movimiento desde ese lado.
; Si se puede hacer el movimiento:
; Mover la ficha a la posición donde está el espacio de la matriz (tiles) 
; y poner el espacio en la posición donde estaba la ficha movida.
; Para recorrer la matriz en ensamblador el índice va de 0 (posició [0][0])
; a 8 (posició [2][2]) con incrementos de 1 porque los datos son de 
; tipo char(BYTE) 1 byte.
; 
; No se tiene que mostrar la matriz con los cambios, se hace en UpdateBoardP1().
; 
; Variables globales utilizadas:   
; (tiles)      : Matriz donde guardamos la fichas del juego
; (charac)     : Carácter a escribir en pantalla.
; (spacePos)   : Posición del espacio en la matriz (tiles).
; (newSpacePos): Nueva posición del espacio en la matriz (tiles).
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
moveTileP1:
   push rbp
   mov  rbp, rsp
   
   push rax
   push rbx
   push rcx
   push rdx
   push rsi
   push rdi
   push r8
   push r10
   push r11
   
   mov r8d, DWORD[spacePos]   ;spacePos
   mov eax, r8d
   mov edx, 0
   mov ebx, DimMatrix
   div ebx               
   mov r10d, eax              ;int i = spacePos / DimMatrix;
   mov r11d, edx              ;int j = spacePos % DimMatrix;
   mov r9d, r8d               ;newspacePos = spacePos;
   mov dil, BYTE[charac]      ;switch(charac){
   moveTileP1_Switchi:         
   cmp dil, 'i'                    ;case 'i':
   jne moveTileP1_Switchk
      cmp r10d, DimMatrix-1        ;if (i < (DimMatrix-1)) {
      jge moveTileP1_SwitchEnd
         mov r9d, r8d
         add r9d, DimMatrix        ;newspacePos = spacePos+DimMatrix;
         mov dl, BYTE[tiles+r9d]   ;tiles[i+1][j];
         mov BYTE[tiles+r8d], dl   ;tiles[i][j]= tiles[i+1][j];
         mov BYTE[tiles+r9d], ' '  ;tiles[i+1][j] = ' ';
         jmp moveTileP1_SwitchEnd  ;break
   moveTileP1_Switchk:
   cmp dil, 'k'                    ;case 'k':
   jne moveTileP1_Switchj
      cmp r10d, 0                  ;if (i > 0) {
      jle moveTileP1_SwitchEnd
         mov r9d, r8d
         sub r9d, DimMatrix        ;newspacePos = spacePos-DimMatrix;
         mov dl, BYTE[tiles+r9d]   ;tiles[i-1][j];
         mov BYTE[tiles+r8d], dl   ;tiles[i][j]= tiles[i-1][j];
         mov BYTE[tiles+r9d], ' '  ;tiles[i-1][j] = ' ';
         jmp moveTileP1_SwitchEnd  ;break
   moveTileP1_Switchj:
   cmp dil, 'j'                    ;case 'j':
   jne moveTileP1_Switchl
      cmp r11d, DimMatrix-1        ;if (j < (DimMatrix-1)) {
      jge moveTileP1_SwitchEnd
         mov r9d, r8d
         inc r9d                   ;newspacePos = spacePos+1;
         mov dl, BYTE[tiles+r9d]   ;tiles[i][j+1];
         mov BYTE[tiles+r8d], dl   ;tiles[i][j]= tiles[i][j+1];
         mov BYTE[tiles+r9d], ' '  ;tiles[i][j+1] = ' ';                
         jmp moveTileP1_SwitchEnd  ;break
   moveTileP1_Switchl:
   cmp dil, 'l'                    ;case 'l':
   jne moveTileP1_SwitchEnd
      cmp r11d, 0                  ;if (j > 0) {
      jle moveTileP1_SwitchEnd
         mov r9d, r8d
         dec r9d                   ;newspacePos = spacePos-1;
         mov dl, BYTE[tiles+r9d]   ;tiles[i][j-1];
         mov BYTE[tiles+r8d], dl   ;tiles[i][j]= tiles[i][j-1];
         mov BYTE[tiles+r9d], ' '  ;tiles[i][j-1] = ' ';
   moveTileP1_SwitchEnd:
   mov DWORD[newSpacePos], r9d     

   moveTileP1_End:
   pop r11
   pop r10
   pop r8
   pop rdi
   pop rsi
   pop rdx
   pop rcx
   pop rbx
   pop rax
   
   mov rsp, rbp
   pop rbp
   ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Verificar el estado del juego.
; Si se han terminado los movimientos (moves == 0) poner (status='3').
; Si no se ha podido hacer el movimiento (spacePos == newSpacePos) poner (status='2').
; Si no poner (state = '1') para continuar jugando.
; Para recorrer la matriz en ensamblador el índice va de 0 (posició [0][0])
; a 8 (posició [2][2]) con incrementos de 1 porque los datos son de 
; tipo char(BYTE) 1 byte.
; 
; Variables globales utilizadas:   
; (moves)      : Movimientos que quedan para ordenar les fichas.
; (spacePos)   : Posición del espacio dentro de la matriz tiles.
; (newSpacePos): Nueva posición del espacio dentro de la matriz tiles.
; (status)     : Estado del juego.
;                '1': Continuamos jugando.
;                '2': No se ha podido hacer el movimiento.
;                '3': Pierdes, no quedan movimientos.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
checkStatusP1:
   push rbp
   mov  rbp, rsp
   
   push rsi
     
   cmp DWORD[moves], 0             ;if (moves == 0) {
   jne checkStatusP1_ElseIf
      mov BYTE[state], '3'         ;state= '3';
      jmp checkStatusP1_End
   checkStatusP1_ElseIf:
   mov esi, DWORD[spacePos]
   cmp esi, DWORD[newSpacePos]     ;} else if (spacePos == newSpacePos) {
   jne checkStatusP1_Else
      mov BYTE[state], '2'         ;state= '2';
      jmp checkStatusP1_End
   checkStatusP1_Else:             ;} else {
      mov BYTE[state], '1'         ;state = '1'
   checkStatusP1_End:
                                   
   pop rsi
      
   mov rsp, rbp
   pop rbp
   ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Esta subrutina se da hecha. NO LA PODÉIS MODIFICAR.
; Mostrar un mensaje debajo del tablero según el valor de la variable 
; (state) cridant la funció printMessageP1_C().
; 
; Variables globals utilitzades:	
; (state)    : Estat del joc.
; (rowScreen): Fila de la pantalla on posicionem el cursor.
; (colScreen): Columna de la pantalla on posicionem el cursor.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printMessageP1:
   push rbp
   mov  rbp, rsp
   ;guardamos el estado de los registros del procesador porque
   ;las funciones de C no mantienen el estado de los registros.
   push rax
   push rbx
   push rcx
   push rdx
   push rsi
   push rdi
   push r8
   push r9
   push r10
   push r11
   push r12
   push r13
   push r14
   push r15
   
   call printMessageP1_C
 
   pop r15
   pop r14
   pop r13
   pop r12
   pop r11
   pop r10
   pop r9
   pop r8
   pop rdi
   pop rsi
   pop rdx
   pop rcx
   pop rbx
   pop rax
   
   mov rsp, rbp
   pop rbp
   ret
   
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Esta subrutina se da hecha. NO LA PODÉIS MODIFICAR.
; Juego del 8-PUZZLE.
; Subrutina principal del juego.
; Permite jugar al juego del 8-PUZZLE llamando todas las funcionalidades.
; 
; Pseudo-código:
; Mostrar el tablero de juego llamado a la función printBoardP1_C.
; Inicializar el estado del juego, (state='1').
; Inicializar los movimientos que se pueden hacer  (moves = 9).
; Inicializar la matriz (tiles) con los valores de la matriz (tilesIni)
; llamando a la subrutina copyMatrixP1.
; Mientras (state=='1') hacer:
;   Actualizar el tablero de juego llamando a la subrutina updateBoardP1. 
;   Buscar donde está el espacio en blanco dentro la matriz (tiles) y posicionar el
;   cursor en el lugar donde hay el espacio llamando a la subrutina spacePosScreenP1.
;   Si se ha encontrado el espacio (newSpacePos < SizeMatrix):
;     Hacer que la posición del espacio sea la nueva posición obtenida.
;     (spacePos = newSpacePos)
;     Leer una tecla llamando a la subrutina getchP1.
;     Según la tecla leída llamaremos a las subrutinas que correspondan:
;      - ['i','j','k' o 'l'] desplazar la ficha segú la dirección
;        escogida llamando a la subrutina moveTileP1).
;        Si se ha realizado un movimiento (newSpacePos != spacePos) decrementar
;        los movimientos (moves--).
;        Verificar el estado del juego llamando la subrutina checkStatusP1.
;      - '<ESC>'  (código ASCII 27) poner (state = '0') para salir.   
;    Si no se ha encontrado el espacio (newSpacePos = SizeMatrix):
;      poner (state='5') para indicar que no hay espacio en la matriz. 
;    Mostrar un mensaje debajo del tablero según el valor de la 
;    variable (state) llamando a la subrutina printMessageP1.
;    Si no se ha podido hacer movimiento (state == '2') poner 
;    (state = '1') para continuar jugando. 
; Fin mientras.
; 
; Antes de salir, actualizar el tablero de juego llamando a la 
; subrutina updateBoardP1 y posicionar el cursor en el lugar donde hay 
; el espacio llamando a la subrutina spacePosScreenP1.
; Esperar que se pulse una tecla llamando a la subrutina getchP1 para acabar.
; Salir: Se acaba el juego.
; 
; Variables globales utilizadas:   
; (moves)      : Movimientos que quedan para ordenar les fichas.
; (spacePos)   : Posición del espacio dentro de la matriz tiles.
; (newSpacePos): Nueva posición del espacio dentro de la matriz tiles.
; (charac)     : Carácter a escribir en pantalla.
; (status)     : Estado del juego.
;                '1': Continuamos jugando.
;                '2': No se ha podido hacer el movimiento.
;                '3': Pierdes, no quedan movimientos.
;                '5': Error, no se ha encontrado el espacio.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
playP1:
   push rbp
   mov  rbp, rsp
   
   call printBoardP1_C   ;printBoard1_C();
   
   push rax
   push rbx
   push r8
   push r9
   push r10
   
   mov r8d, 0             ;int spacePos = 0
   mov r9d, 0             ;int newSpacePos;
   mov r10d, 9            ;int moves = 9
   mov bl , '1'           ;char state = '1';
   
   call copyMatrixP1      ;copyMatrixP1_C();
   
   playP1_While:
   cmp  bl, '1'               ;while (state == '1')
   jne  playP1_EndWhile       ;//Bucle principal.
      mov  DWORD[moves], r10d
      call updateBoardP1      ;updateBoardP1_C();
      call spacePosScreenP1   ; spacePosScreenP1_C();
      mov r9d, DWORD[newSpacePos]
      cmp r9d, SizeMatrix     ;if (newSpacePos < SizeMatrix) {
      jge playP1_ElseIf1
         mov r8d, r9d              ;spacePos = newSpacePos;
            
         call getchP1              ;getchP1_C()
         mov al, BYTE[charac]
         playP1_ReadKey_ijkl:
         cmp al, 'i'
         jl  playP1_ReadKey_ESC    ;(charac>='i')
         cmp al, 'l'
         jg  playP1_ReadKey_ESC    ;(charac<='l')
            mov DWORD[spacePos], r8d
            call moveTileP1        ;moveTileP1_C();
            mov r9d, DWORD[newSpacePos]
            cmp r9d, r8d           ;if (newSpacePos != spacePos) moves--;
            je  playP1_EndIf2
               dec r10d
            playP1_EndIf2:
            mov DWORD[moves], r10d
            mov DWORD[spacePos], r8d
            mov DWORD[newSpacePos], r9d
            call checkStatusP1     ;checkStatusP1_C();
            mov  bl, BYTE[state]
            jmp playP1_ReadKey_noESC   
         playP1_ReadKey_ESC:
         cmp al, 27                 ;if (charac==27)
         jne playP1_ReadKey_noESC
            mov bl, '0'             ;state = '0'  
         playP1_ReadKey_noESC:
         jmp playP1_EndIf1
         playP1_ElseIf1:
            mov bl, '5'             ;state = '0' 
         playP1_EndIf1:
         mov  BYTE[state], bl
         call printMessageP1    ;printMessageP1_C();
         cmp bl, '2'            ;if (state == '2') 
         jne playP1_While
            mov bl, '1'         ;state = '1';
      jmp playP1_While
   
   playP1_EndWhile:
   mov  DWORD[moves], r10d
   call updateBoardP1         ;updateBoardP1_C();
   call spacePosScreenP1      ;spacePosScreenP1_C();
   call getchP1               ;getchP1_C();
   
   pop r10
   pop r9
   pop r8
   pop rbx
   pop rax
   
   mov rsp, rbp
   pop rbp
   ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
