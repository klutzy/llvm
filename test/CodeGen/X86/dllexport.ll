; RUN: llc -mtriple i386-pc-win32 < %s | FileCheck -check-prefix=CHECK -check-prefix=WIN32 %s
; RUN: llc -mtriple i386-pc-mingw32 < %s | FileCheck -check-prefix=CHECK -check-prefix=MINGW %s

; CHECK: .text

define void @notExported() {
	ret void
}

; CHECK: .globl _f1
define dllexport void @f1() {
	ret void
}

; CHECK: .globl _f2
define dllexport void @f2() unnamed_addr {
	ret void
}

; CHECK: .globl _stdfun@0
define dllexport x86_stdcallcc void @stdfun() nounwind {
	ret void
}

; CHECK: .globl @fastfun@0
define dllexport x86_fastcallcc i32 @fastfun() nounwind {
	ret i32 0
}

; CHECK: .globl _thisfun
define dllexport x86_thiscallcc void @thisfun() nounwind {
	ret void
}

; CHECK: .section .text,"xr",discard,_lnk1
; CHECK: .globl _lnk1
define linkonce_odr dllexport void @lnk1() {
	ret void
}

; CHECK: .section .text,"xr",discard,_lnk2
; CHECK: .globl _lnk2
define linkonce_odr dllexport void @lnk2() alwaysinline {
	ret void
}

; CHECK: .section .text,"xr",discard,_weak1
; CHECK: .globl _weak1
define weak_odr dllexport void @weak1() {
	ret void
}


; CHECK: .data
; CHECK: .globl _Var1
@Var1 = dllexport global i32 1, align 4

; CHECK: .rdata,"r"
; CHECK: .globl _Var2
@Var2 = dllexport unnamed_addr constant i32 1

; CHECK: .comm _Var3
@Var3 = common dllexport global i32 0, align 4

; CHECK: .section .data,"w",discard,_WeakVar1
; CHECK: .globl _WeakVar1
@WeakVar1 = weak_odr dllexport global i32 1, align 4

; CHECK: .section .rdata,"r",discard,_WeakVar2
; CHECK: .globl _WeakVar2
@WeakVar2 = weak_odr dllexport unnamed_addr constant i32 1


; CHECK: .globl _alias
; CHECK: _alias = _notExported
@alias = dllexport alias void()* @notExported

; CHECK: .globl _alias2
; CHECK: _alias2 = _f1
@alias2 = dllexport alias void()* @f1

; CHECK: .globl _alias3
; CHECK: _alias3 = _alias
@alias3 = dllexport alias void()* @alias

; CHECK: .weak _weak_alias
; CHECK: _weak_alias = _f1
@weak_alias = dllexport alias weak_odr void()* @f1


; CHECK: .section .drectve
; WIN32: /EXPORT:Var1,DATA
; WIN32: /EXPORT:Var2,DATA
; WIN32: /EXPORT:Var3,DATA
; WIN32: /EXPORT:WeakVar1,DATA
; WIN32: /EXPORT:WeakVar2,DATA
; WIN32: /EXPORT:f1
; WIN32: /EXPORT:f2
; WIN32: /EXPORT:stdfun
; WIN32: /EXPORT:fastfun
; WIN32: /EXPORT:thisfun
; WIN32: /EXPORT:lnk1
; WIN32: /EXPORT:lnk2
; WIN32: /EXPORT:weak1
; WIN32: /EXPORT:alias
; WIN32: /EXPORT:alias2
; WIN32: /EXPORT:alias3
; WIN32: /EXPORT:weak_alias
; MINGW: -export:Var1,data
; MINGW: -export:Var2,data
; MINGW: -export:Var3,data
; MINGW: -export:WeakVar1,data
; MINGW: -export:WeakVar2,data
; MINGW: -export:f1
; MINGW: -export:f2
; MINGW: -export:stdfun
; MINGW: -export:fastfun
; MINGW: -export:thisfun
; MINGW: -export:lnk1
; MINGW: -export:lnk2
; MINGW: -export:weak1
; MINGW: -export:alias
; MINGW: -export:alias2
; MINGW: -export:alias3
; MINGW: -export:weak_alias
