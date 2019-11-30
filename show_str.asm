;名称：show_str
;功能：在指定位置，用指定的颜色，显示一个用0结束的字符串
;参数：(dh)=行号（0~24），(dl)=列号（0~79），(cl)=颜色，ds:si指向字符串的首地址
;返回：无


assume cs:code 
data segment
    db 'Hello World!!!',0
data ends

code segment 
start:  mov dh,8       ;行数
        mov dl,3       ;列数
        mov cl,2       ;颜色
        call show_str

          ;死循环显示字符
    all:
        jmp short all

        mov ax,4c00h
        int 21h

show_str:
        push dx
        push ds
        push si
        push ax
        push bx

                       ;准备阶段
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
        mov ds,ax         ;把地址放到段寄存器中        
        mov ax,data
        mov es,ax         ;把字符串地址放到段寄存器中
        mov si,0          ;字符串位置指针
    print:                        ;输出阶段
        push cx            ;先把cx压栈(因为cl储存了颜色)
        mov cl,es:[si]       ;把数据段的对应字符传到cx
        mov ch,0
        jcxz ok           ;如果cx为0，完成打印
        pop cx           ;出栈cx
        mov al,es:[si]  ;传字符
        mov [bx],al
        mov [bx+1],cl     ;传颜色
        inc si            ;指向下一个字符
        add bx,2          ;指向下一处显存
        jmp short print   ;循环执行
    ok:
        pop cx    ;重要！！！压出cx
        pop bx 
        pop ax 
        pop si
        pop ds 
        pop dx
        ret
code ends
end start