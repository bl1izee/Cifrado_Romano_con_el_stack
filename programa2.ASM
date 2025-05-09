; This is a basic template file for writing 48K Spectrum code.
AppFilename             equ "NewFile"                   ; What we're called (for file generation)

AppFirst                equ $8000                       ; First byte of code (uncontended memory)

                        zeusemulate "48K","ULA+"        ; Set the model and enable ULA+


; Start planting code here. (When generating a tape file we start saving from here)

                        org AppFirst                    ; Start of application

AppEntry                LD BC, (MesA)                   ; Cargamos en C el contenido de MesA
                        LD A, C                         ; Cargamos en el acumulador el contenido de B
                        LD BC, (MesB)                   ; Cargamos en C el contenido de MesB
                        ADD C                           ; Sumamos el contenido de C en el acumulador
                        SRL A                           ; Movemos 1 bit a la derecha para dividir
                        LD (RomanKey), A                ; Cargamos en RomanKey el contenido de A
                        LD IX, TextoOriginal            ; Movemos a IX la dirección de memoria de la cadena que queremos cifrar/descrifrar
                        LD IY, TextoFinal               ; Movemos a IY la dirección de memoria de la cadena donde guardaremos el resultado
                        LD DE, RomanKey-TextoOriginal   ; Guardamos en E el tamaño del array
                        PUSH IX                         ; Movemos al stack la dirección de memoria de la cadena que queremos cifrar/descrifrar
                        PUSH IY                         ; Movemos al stack la dirección de memoria de la cadena donde guardaremos el resultado
                        PUSH DE                         ; Movemos al stack el contenido de E
                        LD DE, (RomanKey)               ; Movemos a E el contenido de RomanKey
                        PUSH DE                         ; Movemos al stack el contenido de E
                        LD DE, (Operacion)              ; Movemos a E la operación que queramos realizar, C o D
                        PUSH DE                         ; Movemos al stack el contenido de E
                        CALL CifradoRomano              ; Llamamos a la rutina CifradoRomano
                        PUSH BC                         ; Movemos a BC el contenido del acumulador
                        LD A, C                         ; Movemos al acumulador el contenido de C (codigo de salida del programa)
FINAL                   halt                            ; Final del codigo
                        jp FINAL                        ; Final del codigo

CifradoRomano           POP HL                          ; Movemos a HL el PC de retorno al main
                        POP DE                          ; Movemos a E la operación que queremos realizar
                        LD A, E                         ; Movemos al acumulador el contenido de E
                        CP A, 'C'                       ; Comparamos el acumulador con C
                        JP NZ Descifrar                  ; Saltamos a Descifrar si la resta no es 0
                        POP DE                          ; Movemos el contenido de RomanKey a E
                        POP BC                          ; Movemos a C el tamaño de la cadena
                        LD A, C                         ; Movemos al acumulador el contenido de C
                        LD B, A                         ; Movemos a B el contenido del acumulador
                        POP IY                          ; Movemos a IY la dirección de memoria de la cadena donde guardaremos los resultados
                        POP IX                          ; Movemos a IX la dirección de memoria de la cadena que queremos cifrar/descrifrar
BucleCifrado            LD A, (IX)                      ; Cargamos en el acumulador el contenido de IX
                        ADD E                           ; Sumamos el contenido de E en el acumulador para calcular el nuevo caracter ASCII
                        LD (IY), A                      ; Cargamos en IY el nuevo caracter ASCII
                        INC IX                          ; Incrementamos IX para pasar al siguiente caracter
                        INC IY                          ; Incrementamos IY para pasar al siguiente caracter
                        DJNZ BucleCifrado               ; Cerramos el bucle restando 1 a B hasta llegar a 0 y, va llamando a BucleCifrado
                        LD A, 1                         ; Cargamos en el acumulador 1 ya que se ha realizado con exito la operación
                        LD C, A                         ; Movemos el contenido del acumulador en C
                        PUSH BC                         ; Movemos al stack el contenido de C
                        PUSH HL                         ; Movemos al stack la dirección de retorno de la siguiente linea
                        RET                             ; Volvemos al codigo mainn

Descifrar               CP A, 'D'                        ; Restamos D para ver si es 0
                        JP NZ Error                     ; Saltamos a Error  si la resta no es 0
                        POP DE                          ; Movemos el contenido de RomanKey a E
                        POP BC                          ; Movemos a C el tamaño de la cadena
                        LD A, C                         ; Movemos al acumulador el contenido de C
                        LD B, A                         ; Movemos a B el contenido del acumulador
                        POP IY                          ; Movemos a IY la dirección de memoria de la cadena donde guardaremos los resultados
                        POP IX                          ; Movemos a IX la dirección de memoria de la cadena que queremos cifrar/descrifrar

BucleDescifrar          LD A, (IX)                      ; Cargamos en el acumulador el contenido de IX
                        SUB E                           ; Sumamos el contenido de E en el acumulador para calcular el nuevo caracter ASCII
                        LD (IY), A                      ; Cargamos en IY el nuevo caracter ASCII
                        INC IX                          ; Incrementamos IX para pasar al siguiente caracter
                        INC IY                          ; Incrementamos IY para pasar al siguiente caracter
                        DJNZ BucleDescifrar             ; Cerramos el bucle restando 1 a B hasta llegar a 0 y, va llamando a BucleDescifrar
                        LD A, 1                         ; Cargamos en el acumulador 1 ya que se ha realizado con exito la operación
                        LD C, A                         ; Movemos el contenido del acumulador en C
                        PUSH BC                         ; Movemos al stack el contenido de C
                        PUSH HL                         ; Movemos al stack la dirección de retorno de la siguiente linea
                        RET                             ; Volvemos al codigo main

Error                   LD A, 0                         ; Cargamos en el acumulador 0 ya que no existe la operación indicada
                        LD C, A                         ; Movemos el contenido del acumulador en C
                        PUSH BC                         ; Movemos al stack el contenido de C
                        PUSH HL                         ; Movemos al stack la dirección de retorno de la siguiente linea
                        RET                             ; Volvemos al codigo main

; Stop planting code after this. (When generating a tape file we save bytes below here)
AppLast                 equ *-1                         ; The last used byte's address

MesA                    defb 1                          ; Mes de nacimiento de uno del grupo
MesB                    defb 1                          ; Mes de nacimiento de uno del grupo
TextoOriginal           defb "BEATI HISPANI QUIBUS BIBERE VIVERE EST" ; Texto original
RomanKey                defs 1                          ; Se guardará el valor de la clave
TextoFinal              defs RomanKey-TextoOriginal     ; Guarda el texto cifrado/descifrado
Operacion               defb 'D'                        ; Guarda la operación que queramos realizar
; Generate some useful debugging commands

                        profile AppFirst,AppLast-AppFirst+1     ; Enable profiling for all the code

; Setup the emulation registers, so Zeus can emulate this code correctly

Zeus_PC                 equ AppEntry                            ; Tell the emulator where to start
Zeus_SP                 equ $FF40                               ; Tell the emulator where to put the stack

; These generate some output files

                        ; Generate a SZX file
                        output_szx AppFilename+".szx",$0000,AppEntry    ; The szx file

                        ; If we want a fancy loader we need to load a loading screen
;                        import_bin AppFilename+".scr",$4000            ; Load a loading screen

                        ; Now, also generate a tzx file using the loader
                        output_tzx AppFilename+".tzx",AppFilename,"",AppFirst,AppLast-AppFirst,1,AppEntry ; A tzx file using the loader


