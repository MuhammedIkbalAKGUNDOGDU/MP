datasg SEGMENT PARA 'data'

    vize       db 77, 85, 64, 96
    final      db 56, 63, 86, 74
    obp        db 0, 0, 0, 0
    siraliobp  db 0, 0, 0, 0
    n_students DB 4
    tmp        dw 0
    tmp2       dw 0
    minIndex   dw 0
    temp       db 0

datasg ENDS
stacksg SEGMENT PARA STACK 'stack'
            DW 12 DUP(?)
stacksg ENDS
codesg SEGMENT PARA 'code'
                 ASSUME DS:datasg, SS:stacksg, CS:codesg
OBPCalculate PROC FAR
                 PUSH   DS
                 XOR    AX, AX
                 PUSH   AX

                 MOV    AX, datasg
                 MOV    DS, AX
                 MOV    CL, n_students                      ; Öğrenci sayısını CX'e yükle
                 MOV    SI, 0                               ; Dolaşmak için SI'yi sıfırla
              
    loop_start:  
    ; Vize notunu hesapla
                 MOV    AL, vize[SI]                        ; Vize notunu AL'ye yükle
                 MOV    DL, 4                               ; 4 ile çarp
                 MUL    DL                                  ; AX = AL * 4 (Sonuç AX'te)
                 MOV    tmp , AX


    ; Final notunu hesapla
                 MOV    AL, final[SI]                       ; Final notunu AL'ye yükle
                 MOV    DL, 6                               ; 6 ile çarp
                 MUL    DL                                  ; AX = AL * 6 (Sonuç AX'te)
 
                 MOV    tmp2, AX                            ; Yuvarlanmış final notunu tmp2'ye sakla

    ; OBP hesapla
                 MOV    AX, tmp                             ; tmp'yi AX'e yükle (burada [tmp] yazmalısınız)
                 ADD    AX, tmp2                            ; tmp2'yi ekle ([tmp2] ile)
                 XOR    DX ,DX
                 mov    bx , 10
                 DIV    bx
                
                 CMP    DX ,5
                 JL     notround                            ; Eğer küçükse, yuvarlama yapma
                 INC    AL                                  ; 5 veya daha büyükse bir artır

    notround:    
                 MOV    obp[SI], AL                         ; Sonucu obp[SI]'ye sakla

    ; İndeksi artır ve döngüye devam et
                 INC    SI                                  ; Sonraki öğrenciye geç
                 LOOP   loop_start                          ; CX sıfıra ulaşana kadar döngüyü tekrarla



    ;----------------------------------------------------------------------------------------------------------------------

                 MOV    CL, n_students                      ; Öğrenci sayısını CX'e yükle
                 MOV    SI, 0                               ; Başlangıç indeksini sıfırla

    ; obp dizisini siraliobp dizisine kopyala
    copy_loop:   
                 MOV    AL, obp[SI]
                 MOV    siraliobp[SI], AL
                 INC    SI
                 LOOP   copy_loop

                 MOV    CL, n_students                      ; Öğrenci sayısını Cl'e yükle (dizinin boyutu).
                 MOV    SI, 0                               ; Dış döngü için başlangıç indeksini SI'ye sıfırla.

    sort_loop:   
                 MOV    minIndex, SI                        ; minIndex değişkenini mevcut SI indeksine ayarla.
    ; Bu, şu anki en büyük elemanın indeksini tutacak.

                 MOV    DI, SI                              ; DI'yi SI'ye ayarla; iç döngüde arama yapacak.
                 INC    DI                                  ; DI'yi bir artırarak sonraki elemandan başla.

    inner_loop:  
                 CMP    DI, CX                              ; DI'yi dizi boyutuyla karşılaştır (sonu kontrol et).
                 JGE    swap_check                          ; Eğer DI >= CX ise, iç döngüyü bitir ve swap_check etiketine git.

                 MOV    AL, siraliobp[DI]                   ; siraliobp[DI] öğesini AL'ye yükle.
                 mov    bx , minIndex
                 CMP    AL, siraliobp[bx]                   ; AL'deki değeri mevcut en büyük değerle karşılaştır.
                 JBE    no_update                           ; Eğer AL <= siraliobp[minIndex] ise, güncelleme yapmadan geç.

                 MOV    minIndex, DI                        ; Eğer AL > siraliobp[minIndex] ise, minIndex'i DI'ye güncelle.

    no_update:   
                 INC    DI                                  ; DI'yi bir artır ve iç döngüye dön.
                 JMP    inner_loop                          ; inner_loop başına geri git ve sıradaki öğeyi kontrol et.

    swap_check:  
                 CMP    minIndex, SI                        ; minIndex'in değişip değişmediğini kontrol et.
                 JE     no_swap                             ; Eğer minIndex = SI ise, swap yapmaya gerek yok, no_swap'a git.

    ; siraliobp[SI] ve siraliobp[minIndex] öğelerini değiştir
                 MOV    AL, siraliobp[SI]                   ; siraliobp[SI] değerini AL'ye yükle.
                 MOV    temp, AL                            ; AL'deki değeri temp değişkenine sakla (geçici saklama).
                 MOV    AL, siraliobp[bx]                   ; siraliobp[minIndex] değerini AL'ye yükle.
                 MOV    siraliobp[SI], AL                   ; AL'deki değeri siraliobp[SI]'ye kaydet (yer değiştirme).
                 MOV    AL, temp                            ; temp'teki eski değeri AL'ye geri yükle.
                 MOV    siraliobp[bx], AL                   ; AL'deki değeri siraliobp[minIndex]'e kaydet (tam yer değiştirme).

    no_swap:     
                 INC    SI                                  ; Bir sonraki eleman için dış döngü indeksini artır.
                 CMP    SI, CX                              ; SI'yi CX ile karşılaştır (dizi sonuna ulaşmadık mı).
                 JL     sort_loop                           ; Eğer SI < CX ise, sort_loop başına geri dön.
OBPCalculate ENDP
codesg ENDS
			END OBPCalculate
			
			