.data

file_a_path: .asciiz "/home/luke/Dokumenty/Code/ARKO/mips/2/1.bmp"
file_a_disc: .word 0	#deskryptor
buffer_a_adr: .word 0	#adres do bufora z plikiem 
file_a_size: .word 0	#rozmar pliku w bajtach
width_a: .word 0	#wszerokosc obrazu w pikselach
height_a: .word 0	#wysokosc obrazu w pikselach
padding_a: .word 0	#padding dla obrazu 
offset_a: .word 0	#ofset do bitmapy
size_line_a: .word 0	#ilosc bajtów w jednej lini obazu wraz z paddingiem

file_b_path: .asciiz "/home/luke/Dokumenty/Code/ARKO/mips/2/lov.bmp"
file_b_disc: .word 0
buffer_b_adr: .word 0	#adres do bufora z plikiem 
file_b_size: .word 0	#rozmar pliku w bajtach
width_b: .word 0	#wszerokosc obrazu w pikselach
height_b: .word 0	#wysokosc obrazu w pikselach
padding_b: .word 0	#padding dla obrazu 
offset_b: .word 0	#ofset do bitmapy	
size_line_b: .word 0	#ilosc bajtów w jednej lini obazu wraz z paddingiem

file_w_path: .asciiz "/home/luke/Dokumenty/Code/ARKO/mips/2/w.bmp"
file_w_disc: .word 0

point_x: .word 	0	#x punktu przesuniecia obrazu b wzgledem a
point_y: .word 	0	#y punktu przesuniecia obrazu b wzgledem a
alfa: 	.byte 0

start_offset_a: .word 0		#przesuniecie do piksela gdzie zaczynamy liczyc  alfablending
start_offset_b: .word 0		#przesuniecie do piksela gdzie zaczynamy liczyc  alfablending

number_lines_b: .word 0		#ilosc lini obrazu b do przerobirnia

buffer:  .space 100
msg:	 .asciiz "Alpha Blending\n"
alfa_msg:.asciiz "Podaj alfe(0-255): "
err:	 .asciiz "Blad pliku\n"
x_msg: 	 .asciiz "Podaj x: "
y_msg: 	 .asciiz "Podaj y: "

.text

_start:


#IDNTYFIKACJA PLIKU A
	#otwieramy plik do odczytu
	li $v0, 13       	
	la $a0, file_a_path     
	li $a1, 0        
	li $a2, 0
	syscall	 
	
	move $t0, $v0
	bltz $t0, error
	                    
	sw $v0, file_a_disc 

	#odczytujemy 2 bajty "BM"
	li $v0, 14       
	lw $a0, file_a_disc      
	la $a1, buffer   
	li $a2, 2
	syscall        

	#odczytujemy 4 bajty - rozmiar pliku
	li $v0, 14       
	lw $a0, file_a_disc      
	la $a1, file_a_size
	li $a2, 4
	syscall      

	#odczytujemy 4 bajty - zarezerwowane
	li $v0, 14       
	lw $a0, file_a_disc      
	la $a1, buffer
	li $a2, 4
	syscall       

	#odczytujemy 4 bajty - ofset do bitmapy
	li $v0, 14       
	lw $a0, file_a_disc      
	la $a1, offset_a
	li $a2, 4
	syscall       

	#odczytujemy 4 bajty - wielkosc naglowka
	li $v0, 14       
	lw $a0, file_a_disc      
	la $a1, buffer
	li $a2, 4
	syscall       

	#odczytujemy 8 bajtow - szerokosc i wysokosc
	li $v0, 14       
	lw $a0, file_a_disc      
	la $a1, width_a
	li $a2, 8
	syscall       

	#zamykamy plik
	li $v0, 16       
	lw $a0, file_a_disc     
	syscall           

#IDNTYFIKACJA PLIKU B
	#otwieramy plik do odczytu
	li $v0, 13       	
	la $a0, file_b_path     
	li $a1, 0        
	li $a2, 0
	syscall	   
	
	move $t0, $v0
	bltz $t0, error        
	                        
	sw $v0, file_b_disc 

	#odczytujemy 2 bajty "BM"
	li $v0, 14       
	lw $a0, file_b_disc      
	la $a1, buffer   
	li $a2, 2
	syscall        

	#odczytujemy 4 bajty - rozmiar pliku
	li $v0, 14       
	lw $a0, file_b_disc      
	la $a1, file_b_size
	li $a2, 4
	syscall        

	#odczytujemy 4 bajty - zarezerwowane
	li $v0, 14       
	lw $a0, file_b_disc      
	la $a1, buffer
	li $a2, 4
	syscall       

	#odczytujemy 4 bajty - ofset do bitmapy
	li $v0, 14       
	lw $a0, file_b_disc      
	la $a1, offset_b
	li $a2, 4
	syscall       

	#odczytujemy 4 bajty - wielkosc naglowka
	li $v0, 14       
	lw $a0, file_b_disc      
	la $a1, buffer
	li $a2, 4
	syscall       

	#odczytujemy 8 bajtow - szerokosc i wysokosc
	li $v0, 14       
	lw $a0, file_b_disc      
	la $a1, width_b
	li $a2, 8
	syscall       

	#zamykamy plik
	li $v0, 16       
	lw $a0, file_b_disc     
	syscall    
	
#wprowadzanie parametrow
x_read:	
	la $a0, x_msg	
	li $v0, 4
	syscall
	
	li $v0,5
	syscall
	bltz $v0, x_read
	sw $v0,point_x
	
y_read:
	la $a0, y_msg	
	li $v0, 4
	syscall
	
	li $v0,5
	syscall
	bltz $v0, y_read
	sw $v0,point_y
	
alfa_read:
	la $a0, alfa_msg	
	li $v0, 4
	syscall
	
	li $v0,5
	syscall 
		
	bgt  $v0, 255,alfa_read
	blt  $v0, 0,alfa_read
	sw   $v0, alfa
	            

#Alokacja pamieci na dwa pliki a i b 
#Zakładamy ze na obraz a nakładamy obraz b wiec obraz wynikowy
#bedzie wielkosci obrazu a
#Tu bedziemy rowniez alokowac pamieci na plik wynikowy
#pobierajac plik do bufora file_a_adr bedziemy na tym buforze
#bazowac i rownoczenie go zmieniac do postaciwynikowej ktora 
#ostatecznie zapiszemy do pliku w.bmp

	#alokacja pamieci na plik a
	li $v0,9
	lw $a0, file_a_size
	syscall
	sw $v0, buffer_a_adr	#zapisz adres 

	#otwieramy jeszcze raz plik i go całego odczytujemy do 
	#pamieci która zaalokowalismy
	#otwieramy plik do odczytu
	li $v0, 13       	
	la $a0, file_a_path     
	li $a1, 0        
	li $a2, 0
	syscall	           
	sw $v0, file_a_disc 

	#odczytujemy 
	li $v0, 14       
	lw $a0, file_a_disc      
	lw $a1, buffer_a_adr   
	lw $a2, file_a_size
	syscall        

	#zamykamy plik
	li $v0, 16       
	lw $a0, file_a_disc     
	syscall           	

	
	#alokacja pamieci na plik b
	li $v0,9
	lw $a0, file_b_size
	syscall
	sw $v0, buffer_b_adr	#zapisz adres 

	#otwieramy jeszcze raz plik i go całego odczytujemy do 
	#pamieci która zaalokowalismy
	#otwieramy plik do odczytu
	li $v0, 13       	
	la $a0, file_b_path     
	li $a1, 0        
	li $a2, 0
	syscall	           
	sw $v0, file_b_disc 

	#odczytujemy 
	li $v0, 14       
	lw $a0, file_b_disc      
	lw $a1, buffer_b_adr   
	lw $a2, file_b_size
	syscall        

	#zamykamy plik
	li $v0, 16       
	lw $a0, file_b_disc     
	syscall       

#obliczamy padding
	lw $t2, width_a
	li $t3, 3
	mulo $t1, $t2, $t3	#mnozymy 3*szerokosc
	sw $t1, size_line_a	#dlugosc lini w bajtach
	andi $t1, $t1, 3	#maska 3 przyslania 2 najmlodsze bity
	beq $t1,0, padding0
	li $t2,4
	sub $t1, $t2, $t1	#oliczamy pading jako (4 - reszta z dzielnai przez 4)
	sw $t1, padding_a

padding0:
	lw $t2, width_b
	li $t3, 3
	mulo $t1, $t2, $t3	#mnozymy 3*szerokosc
	sw $t1, size_line_b	#dlugosc lini w bajtach	
	andi $t1, $t1, 3	#maska 3 przyslania 2 najmlodsze bity
	beq $t1,0, padding1
	li $t2,4
	sub $t1, $t2, $t1	#oliczamy pading jako (4 - reszta z dzielnai przez 4)
	sw $t1, padding_b
padding1:
#obliczamy dokladna dlugosc lini obrazów
	lw $t1, padding_a
	lw $t2, size_line_a
	add $t3, $t2, $t1 
	sw $t3, size_line_a

	lw $t1, padding_b
	lw $t2, size_line_b
	add $t3, $t2, $t1 
	sw $t3, size_line_b

#obliczamy przesuniecia startowe do bitmap bo sa wzgledem siebie przesuniete
	lw $t1, buffer_b_adr
	lw $t2, height_b
	lw $t3, height_a
	lw $t4, point_y
	lw $t5, size_line_b
	lw $t6, offset_b
	
	#sprawdzamy dwa przypadki ustawienia obrazu b w obrazie a
	add $t7, $t2, $t4	#height_b + point_y
	sub $t7, $t3, $t7	#height_a - (height_b + point_y)
	bltz $t7, offset0
	li $t0, 0

	#obliczamy ilosc lini obrazu b do przerobirnia podczas algorytmu alfablendingu
	lw $t7,height_b
	sw $t7,number_lines_b
	

	j offset1
offset0:	

	#obliczamy ilosc lini obrazu b do przerobirnia podczas algorytmu alfablendingu
	sub $t7,$t3,$t4
	sw $t7, number_lines_b


	sub $t0, $t2, $t3	#t0 = height_b - height_a + point_y	
	add $t0, $t0, $t4
	mulo $t0, $t0, $t5	#t0 = t0 * size_lina_a
	add $t0, $t0, $t1	#t0 = t0 + buffer_a_adr
	add $t0, $t0, $t6	#t0 = t0 + offst_b
	#od teraz t0 wskazuje na pierwszy bajt do alfablendingu brany z obrazu b
	sw $t0, start_offset_b

	#w tym przyapadku przesuniecie dla obrazu a liczmy tak
	lw $t3, buffer_a_adr
	lw $t4, point_x
	lw $t6, offset_a
	mulo $t1, $t4, 3	#t4 = point_x * 3
	add $t1, $t1, $t3	#t1 = t1 + t3
	add $t1, $t1, $t6	#t0 = t0 + offst_a
	#od teraz t1 wskazuje na pierwszy bajt do alfablendingu brany z obrazu a
	sw $t1, start_offset_a		
	j alfa0

offset1:	
	add $t0, $t0, $t1	#t0 = t0 + buffer_b_adr
	add $t0, $t0, $t6	#t0 = t0 + offst_b
	#od teraz t0 wskazuje na pierwszy bajt do alfablendingu brany z obrazu b
	sw $t0, start_offset_b

	lw $t3, buffer_a_adr
	lw $t1,height_b
	lw $t2, height_a
	lw $t4, point_x
	lw $t7, point_y	
	lw $t5, size_line_a
	lw $t6, offset_a
	add $t1, $t1, $t7	#t1 = height_b + point_y
	sub $t1, $t2, $t1		#t1 = height_a - t1
	mulo $t4, $t4, 3	#t4 = point_x * 3
	mulo $t1, $t1, $t5 	#t1 = t1 * size_line_a
	add $t1, $t1, $t4	#t1 = t1 + t4
	add $t1, $t1, $t3	#t1 = t1 + t3
	add $t1, $t1, $t6	#t0 = t0 + offst_a
	#od teraz t1 wskazuje na pierwszy bajt do alfablendingu brany z obrazu a
	sw $t1, start_offset_a		

#teraz dokonujemy alfablendingu
alfa0:
	lw $t5, start_offset_b
	lw $t6, start_offset_a

	lw $s0, point_x		#licznik pikseli obrazu a, dla szerokosci
	lw $s2, width_a		#ilosc pikseli a w lini
	li $s1, 0		#licznik pikseli obrazu b, dla szerokosci
	lw $s3, width_b		#ilosc pikseli b w lini
	li $s4, 0		#ilosc przerobionych lin	
	lw $s5, number_lines_b		#ilosc lini obrazu b do przerobienia	
		
	#przekazujemy ofsety tymczasowe	
	add $t0, $t5, 0		
	add $t1, $t6, 0	
	
	#obliczamy alfa i 1-alfa
	lw $s6,alfa
	subu $s7,$s6,255
	neg  $s7,$s7
		
	
	j alfa2
	
alfa1:
	add $s4, $s4,1		#zwiekszmya ilosc lini
	bgt $s4,$s5, save
			
	#przesun o linie dalej
	lw $a0, size_line_b
	add $t5, $t5, $a0		
	lw $a1, size_line_a
	add $t6, $t6, $a1	
	
	#przekazujemy ofsety tymczasowe	
	add $t0, $t5, 0		
	add $t1, $t6, 0			

	#zerujemy liczniki
	lw $s0, point_x		#licznik pikseli obrazu a, dla szerokosci
	li $s1, 0		#licznik pikseli obrazu b, dla szerokosci
				
alfa2:
	bge $s0, $s2, alfa1	#gdy doszedl do konca lini w a to przeadresuj na nastepna linie
	bge $s1, $s3, alfa1	#gdy doszedl do konca lini w b to przeadresuj na nastepna linie

	#pobieramy bajty
	lb $t2, ($t0)	 #pobieramy bajt z b 
	lb $t3, ($t1)	 #pobieramy bajt z a 
	and $t2, $t2, 0xFF
	and $t3, $t3, 0xFF

	#Obliczanie koloru bitu
	mulo $t2, $t2, $s6
	mulo $t3, $t3, $s7
	add $t3,$t3,$t2
	sra $t3, $t3, 8
	sb $t3,($t1) 

	#pobieramy bajty
	lb $t2, 1($t0)	 #pobieramy bajt z b 
	lb $t3, 1($t1)	 #pobieramy bajt z a 
	and $t2, $t2, 0xFF
	and $t3, $t3, 0xFF

	#Obliczanie koloru bitu
	mulo $t2, $t2, $s6
	mulo $t3, $t3, $s7
	add $t3,$t3,$t2
	sra $t3, $t3, 8
	sb $t3,1($t1) 

	#pobieramy bajty
	lb $t2, 2($t0)	 #pobieramy bajt z b 
	lb $t3, 2($t1)	 #pobieramy bajt z a 
	and $t2, $t2, 0xFF
	and $t3, $t3, 0xFF

	#Obliczanie koloru bitu
	mulo $t2, $t2, $s6
	mulo $t3, $t3, $s7
	add $t3,$t3,$t2
	sra $t3, $t3, 8
	sb $t3,2($t1) 

	
	#przejscei do kolejnego piksela w lini
	add $s0,$s0,1
	add $s1,$s1,1
	add $t0,$t0,3
	add $t1,$t1,3
	
	j alfa2

#zapisujemy plik wynikowy
save:
	#otwieramy plik do odczytu
	li $v0, 13
	la $a0, file_w_path
	li $a1, 1
	li $a2, 0
	syscall	
	sw $v0, file_w_disc 

	#wypelniamy plik wynikowy
	li $v0, 15       
	lw $a0, file_w_disc      
	lw $a1, buffer_a_adr   
	lw $a2, file_a_size
	syscall

	#zamykamy plik
	li $v0, 16
	lw $a0, file_w_disc
	syscall 


	#koniec programu
	li $v0, 10 
	syscall

error:
	la $a0, err
	li $v0, 4
	syscall
	li $v0, 10
	syscall	
