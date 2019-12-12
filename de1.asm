assume cs:codesg,ds:data,ss:table

data segment
   db '1975','1976','1977','1978','1979','1980','1981','1982','1983'
   db '1984','1985','1986','1987','1988','1989','1990','1991','1992'
   db '1993','1994','1995'
   ; 以上是表示21年的21个字符串
   dd 16,22,382,1356,2390,8000,16000,24486,50065,97479,140417,197514
   dd 345980,590827,803530,1183000,1843000,2759000,3753000,4649000,5937000
   ; 以上是表示21年公司总收入的21个dword型数据
   dw 3,7,9,13,28,38,130,220,476,778,1001,1442,2258,2793,4037,5635,8226
   dw 11542,11430,15257,17800
   ; 以上是表示21年公司雇员人数的21个word型数据
data ends

table segment
   db 21 dup ('year summ ne ?? ')
table ends

temp segment
    dd 10 dup (0)
temp ends

codesg segment
start: mov ax,data
       mov ds,ax
       mov bx,0              ; 设置date段的地址
       mov dx, table
       mov ss,dx
       mov bp,0              ; 设置table段的地址

       mov di,54h            ; 公司总收入的起始偏移地址
       mov si,0A8h           ; 公司雇员的起始偏移地址

       mov cx,21
    s: mov ax,[bx]
       mov dx,[bx+2]
       mov [bp],ax
       mov [bp+2],dx         ; 将date段中的年份数据存放到table段的前四个字节单元处
       push ax
       push dx
       push cx
       push si
       push ds
       mov ax,table
       mov ds,ax
       mov ax,21
       sub ax,cx
       mov dh,al
       mov dl,0
       mov cl,2
       mov si,bp
       call show_str
       pop ds
       pop si
       pop cx
       pop dx
       pop ax

       mov ax,[bx+di]
       mov dx,[bx+di+2]
       mov [bp+5], ax
       mov [bp+7], dx        ; 将date段中的总收入存放到table段的第6个位置的双字单元处
       push ds
       push si
       push ax 
       push dx 
       push cx
       mov cx,temp
       mov ds,cx
       mov si,0
       call dtoc
       mov ax,21
       pop cx        ;出栈cx，得到循环次数
       sub ax,cx
       push cx
       mov dh,al
       mov dl,10
       mov cl,2
       mov si,0                ;调试到这里
       call show_str 
       pop cx
       pop dx 
       pop ax 
       pop si  
       pop ds

       div word ptr [si]     ; 得到除数：公司雇员数
       mov [bp+13], ax       ; 将得到的取整后的结果存放到table段的第13个位置的字单元处
       push ax 
       push dx 
       push ds
       push si
       push cx 
       mov dx,temp
       mov ds,dx
       mov dx,0
       mov si,0
       call dtoc 
       mov ax,21
       sub ax,cx 
       mov dh,al
       mov dl,30
       mov cl,2
       call show_str 
       pop cx 
       pop si 
       pop ds
       pop dx 
       pop ax
       mov ax,[si]
       mov [bp+10], ax       ; 将date段中的公司雇员人数存放到table段的第10个位置的字单元处
       push ax 
       push dx 
       push ds
       push si
       push cx 
       mov dx,temp
       mov ds,dx
       mov dx,0
       mov si,0
       call dtoc 
       mov ax,21
       sub ax,cx 
       mov dh,al
       mov dl,20
       mov cl,2
       call show_str 
       pop cx 
       pop si 
       pop ds
       pop dx 
       pop ax

       add bx,4
       add si,2
       add bp,10H
       sub cx,1
       jcxz all
       jmp far ptr s

all:
        jmp short all

dtoc:
        push bx 
        push cx
        push di
        push dx
        push si
        mov di,1            ;计数用
    divide:                 ;开始除法，取出每位数字
        mov cx,10           ;8位除数
        call div1          ;cx为余数  ax低16位 dx高16位
        push  cx             ;储存余数在栈中
        mov cx,dx
        jcxz high_zero           ;如果高16位为0
        inc di
        jmp short divide
    div1:
        push bx   
        push ax   ;压栈低16位
        mov ax,dx
        mov dx,0
        div cx    ;被除数32位，除数16位，商：ax，余数：dx
        mov bx,ax   ;把商保存到bx中
        pop ax   ;把低16位取出
        div cx;    ;被除数32位，除数16位,商:ax,余数：dx
        mov cx,dx  ;保存余数
        mov dx,bx  ;保存高16位
        pop bx
        ret  
    high_zero:
        mov cx,ax          ;如果低16位为0
        jcxz add_           ;完成
        inc di              ;位数+1
        jmp short divide   ;不为0继续做除法
    add_:
        mov cx,di
        s0:
        pop bx         ;依次取出余数
         ;如果为0，结束           ;有问题！！！余数为0时没考虑
        add bx,30h     ;转换到ascll 值
        mov [si],bl    ;移动到指定位置
        inc si         ;指针+1
        loop s0         ;先cx-1,再判断cx?=0
    ok_: 
        ;sub sp,2       ;退回指针
        mov byte ptr [si],20h       ;字符串以空格为结尾
        pop si
        pop dx
        pop di
        pop cx
        pop bx 
        ret


show_str:
        push dx
        push ds
        push si
        push ax
        push bx
        push es

                       ;准备阶段
        
        add dh,1
        add dl,1
        mov al,160
        mov bl,dh
        mul bl            ;计算行数,结果保存在ax中，8bit * 8bit = 16bit 
        push ax           ;先入栈保存
        mov al,2          
        mov bl,dl
        mul bl            ;计算列数,结果保存在ax中
        sub ax,2          ;得到正确列数
        pop bx            ;将之前压栈的行数取出
        add bx,ax         ;两者相加得到对应偏移地址
        mov ax,0b800h     
        mov es,ax         ;把地址放到段寄存器中        
    print:                        ;输出阶段
        push cx            ;先把cx压栈(因为cl储存了颜色)
        mov cl,ds:[si]       ;把数据段的对应字符传到cx
        mov ch,0
        sub cx,20h         ;以空格为分隔符
        jcxz ok           ;如果cx为0，完成打印
        pop cx           ;出栈cx
        mov al,ds:[si]  ;传字符
        mov es:[bx],al
        mov es:[bx+1],cl     ;传颜色
        inc si            ;指向下一个字符
        add bx,2          ;指向下一处显存
        jmp short print   ;循环执行
    ok:
        pop cx    ;重要！！！压出cx
        pop es
        pop bx 
        pop ax 
        pop si
        pop ds 
        pop dx
        ret

        mov ax,4c00h
        int 21h
codesg ends
end start